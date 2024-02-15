+++
title = "Ledger-cliでNPO法人会計の可視化 — かんたん折れ線グラフ"
author = ["YAMAGAMI"]
date = 2024-01-29T00:00:00+09:00
tags = ["ledger-cli", "NPO", "visualization", "可視化"]
categories = ["comp"]
draft = false
+++

## イントロ[^fn_logs] {#イントロ-fn-logs}

[^fn_logs]: この記事は Ledger-cliによるNPO法人会計シリーズの<span style="color: red">第3弾</span>です。記事リストは次のとおりです（2024/02/15現在）<br />
2024/01/21&nbsp;&nbsp; [NPO法人会計に準拠した財務諸表をLedger-cliで書く](https://bred-in-bingo.netlify.app/posts/financial-statements-for-NPO/)<br />
2024/01/25&nbsp;&nbsp; [小規模学会のためのLedgerポスティング例 --- NPO法人会計基準に準拠しながら](https://bred-in-bingo.netlify.app/posts/npo%E4%BC%9A%E8%A8%88)<br />
2024/01/29&nbsp;&nbsp; Ledger-cliでNPO法人会計の可視化 --- かんたん折れ線グラフ<br />
2024/02/02&nbsp;&nbsp; [Ledger-cliによるNPO法人会計注記 -- 役員及びその近親者との取引](https://bred-in-bingo.netlify.app/posts/related-party-TXN-NPO/)<br />
2024/02/15&nbsp;&nbsp; [Ledger-cliによるNPO法人会計注記 – 使途制約のある寄付等](https://bred-in-bingo.netlify.app/posts/specific-donation-NPO)<br />

NPO法人会計で所管庁[^fn:shokancho]に提出が求められいる会計書類は ****財務諸表**** とその ****注記**** です[^fn:chuki]。それらは数値とその表、若干の補足文言です。

[^fn:shokancho]: [内閣府NPOホームページ 所管庁一覧](https://www.npo-homepage.go.jp/shokatsucho)

[^fn:chuki]: NPO会計で求められている ****注記**** も大半はLedgerクエリ出力でカバーできます。後日紹介しますが、ポイントは「役員及びその近親者との取引」を転記する時に、忘れずにそのトランザクションに、それと分かるタグ（例えば ****:近親者取引:**** など）を付けておくことです。そうすれば簡単にそのタグの付いた取引だけを抽出して集計できます。同様に「使途が制約された寄付等」についてもタグづけしておきましょう。

しかし日々、月々さらには年ごとの ****費用、収益**** や ****資産、負債**** などの動きを、グラフやチャートなどで ****可視化**** できたら、より効率的でかつ合目的的にNPO法人の運営を進めることができると思われます。

ここでは

```text
経常費用を月ごとに集計して折れ線グラフを描く
もっとも初歩的で簡単な例を紹介します
```

****Ledger-cli**** と他のソフトウエアを組み合わせてグラフやチャートを描く方法はたくさんあります[^fn_vis_examples]。

[^fn_vis_examples]: 例えば<br />
(1) [Report Scripts for Ledger CLI with Gnuplot](https://www.sundialdreams.com/report-scripts-for-ledger-cli-with-gnuplot/)<br />
(2) [Easy to use analytics/visualization tool for ledger-cli](https://github.com/kendricktan/ledger-analytics)<br />
(3) [Simple Ledger visualisations using Python](https://wilw.dev/blog/2022/04/24/ledger-python-visualisation/) など<br />
中でもとくに(1)は私自身も参考にさせていただきました。ありがとうございます。

この記事では、それらの中で bashのシェルスクリプト内でLedger-cliと ****gnuplot**** を組み合わせて使う例を紹介しています。gnuplotはヒアドキュメントとしてシェルスクリプト内に組み込んでいます。

この記事中のサンプルを見ながら各自の用途にマッチするように改変すれば、すぐにきれいな図が描けると思います。


## 出力サンプル {#出力サンプル}

<a id="figure--sample-chart"></a>

{{< figure src="/npo/monthly-expnese-rolling.svg" caption="<span class=\"figure-number\">Figure 1: </span>月ごとの経常経費の推移（Y軸は金額（千円単位）、X軸は月）" width="65%" >}}

-   図の元になったLedgerのサンプルデータ( `sample-NPO.ledger` )は[こちら](https://bred-in-bingo.netlify.app/npo/sample-NPO.ledger)からダウンロードできます。
-   Ledger起動時のinit-fileのサンプル( `init-npo.dat` )は [こちら](https://bred-in-bingo.netlify.app/npo/configs/init-npo.dat) からダウンロードできます。
-   Ledger-cliをインストールして、適当なディレクトリ内に上のサンプルデータとinit-fileを置き、下のソースコード[1](#code-snippet--code-sample)を起動すれば図[1](#figure--sample-chart)が表示されます。
-   図[1](#figure--sample-chart)では細かい修飾は抜きにして最小限の情報のみ描出しています。


## Codeサンプル {#codeサンプル}

<a id="code-snippet--code-sample"></a>
```sh
#!/bin/bash
#
#  月ごとの経常経費を折れ線グラフにする
#      $0=expns-linecurve.sh
#
ledger reg 経常費用\
       - f sample-NPO.ledger\
       --init-file ./init-npo.dat\
       --monthly\
       --amount-data\
       --collapse\
       > data-to-plot.dat

# csv化
sed 's/ \+/,/g' data-to-plot.dat > csv.dat
csv_file="csv.dat"

out_file="monthly-expnese-rolling.pdf"

gnuplot <<EOF
  set terminal pdfcairo transparent enhanced font 'Arial, 12'
  set style data linespoints
  set datafile separator ","
# Y軸設定
  set ylabel 'Amount（千円）' font 'Arial,12'
  set ytics font 'Arial,10'
  # 数値に3桁ごとにカンマ（最大8桁）
  set decimal locale
  set format y "%'4.0f"
  set yrange[0:]
# 時間軸設定
  set timefmt "%Y-%m-%d"
  set xdata time
  set format x "%01m" time
# X軸設定
  set xtics font 'Arial,10'
  set xlabel "月" font 'Arial,12'
# 出力ファイル指定
  set output '$out_file'
# 描出
  plot '$csv_file' \
     using 1:(column(2)/1000) w linespoints pt 7 ps 0.5 lw 2 notitle,\
  '' using 1:(column(2)/1000):(sprintf("%'d", column(2))) with labels\
	 font "Arial,8" offset 0,0.7 textcolor linestyle 0 notitle
  set output
EOF

evince ${out_file}
exit 0
```
<div class="src-block-caption">
  <span class="src-block-number"><a href="#code-snippet--code-sample">Code Snippet 1</a>:</span>
  スクリプト expns-linecurve.sh
</div>


### 補足説明 {#補足説明}

1.  金額を表示する時に3桁ごとにカンマを入れる
2.  Y軸の横幅を小さくしてグラフ面をできるだけ広く取るために、ラベルを千円単位にする
3.  X軸の「月」表示ではリーディングゼロを書かないようにする
4.  折れ線グラフのポイントごとに金額を記入する

など、普段gnuplotでは余りやらないことだけ追加しておきました。


## Appendix: {#appendix}

過去のブログで直接・間接的にLedgerの「可視化」に関連したものは次のとおりです：

-   ****2021-10-17:**** [投資信託の評価損益を「見える化」する](https://bred-in-bingo.netlify.app/posts/ledger-pnl-plotting)
-   ****2020-04-22:**** [Give me a break!](https://bred-in-bingo.netlify.app/posts/broken-histogram)
-   ****2020-02-21:**** [予算消化率の水平ゲージをledger-cliとgnuplotで描く](https://bred-in-bingo.netlify.app/posts/horizontal-gauge-by-gnuplot/)
-   ****2020-01-31:**** [ぼちぼちですが可視化してます](https://bred-in-bingo.netlify.app/posts/%E5%8F%AF%E8%A6%96%E5%8C%96)
-   ****2019-07-27:**** [プレーンテキストファイルで「複式」家計簿（6）](https://bred-in-bingo.netlify.app/posts/6th-step_ledger)


## Footnotes: {#footnotes}
