+++
title = "Ledger-cliでNPO法人会計の可視化 — かんたん折れ線グラフ"
author = ["YAMAGAMI"]
date = 2024-01-28T00:00:00+09:00
tags = ["ledger-cli", "NPO", "visualization", "可視化"]
categories = ["comp"]
draft = false
+++

## イントロ {#イントロ}

NPO法人会計で求められているのは財務諸表とその注記までです。それらは数値とその表、若干の補足文言です。

しかし日々、月々さらには年ごとの経費、収益や資産、負債などの動きを数値と文字の表だけでなくグラフで可視化して確認できれば・・・

ここでは

```text
経常費用を月ごとに集計して折れ線グラフにする
もっともシンプルな例を紹介します
```

****Ledger-cli**** と他のソフトウエアを組み合わせてグラフやチャートを描く方法はたくさんあります。

この記事では、それらの中で bashのシェルスクリプト内でLedger-cliと ****gnuplot**** を組み合わせて使う例を紹介しています。gnuplotはヒアドキュメントとしてシェルスクリプト内に組み込んでいます。

この記事中のサンプルを見ながら各自の用途にマッチするように改変すれば、すぐにきれいな図が描けると思います。


## 出力サンプル {#出力サンプル}

<a id="figure--sample-chart"></a>

{{< figure src="/npo/monthly-expnese-rolling.svg" width="65%" >}}

-   図の元になったLedgerデータ( `sample-NPO.ledger` )のサンプルは[こちら](https://bred-in-bingo.netlify.app/npo/sample-NPO.ledger)からダウンロードできます。
-   Ledger起動時のinit-fileのサンプル( `init-npo.dat` )は [こちら](https://bred-in-bingo.netlify.app/npo/configs/init-npo.dat) からダウンロードできます。
-   Ledger-cliをインストールして、適当な場所に上のサンプルデータとinit-fileを置き、下のスクリプトを起動すれば上の図が表示されます。


## Codeサンプル {#codeサンプル}

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
sed 's/ /,/g' data-to-plot.dat > csv.dat
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
     using 1:2 w linespoints pt 7 ps 0.5 lw 2 notitle,\
     '' using 1:2:(sprintf("%'d", column(2))) with labels\
	font "Arial,8" offset 0,0.7 textcolor linestyle 0 notitle
  set output
EOF

evince ${out_file}
exit 0
```


## Appendix: {#appendix}

過去のブログで直接・間接的にLedgerの「可視化」に関連したものは次のとおりです：

-   ****2021-10-17:**** [投資信託の評価損益を「見える化」する](https://bred-in-bingo.netlify.app/posts/ledger-pnl-plotting)
-   ****2020-04-22:**** [Give me a break!](https://bred-in-bingo.netlify.app/posts/broken-histogram)
-   ****2020-02-21:**** [予算消化率の水平ゲージをledger-cliとgnuplotで描く](https://bred-in-bingo.netlify.app/posts/horizontal-gauge-by-gnuplot/)
-   ****2020-01-31:**** [ぼちぼちですが可視化してます](https://bred-in-bingo.netlify.app/posts/%E5%8F%AF%E8%A6%96%E5%8C%96)
-   ****2019-07-27:**** [プレーンテキストファイルで「複式」家計簿（6）](https://bred-in-bingo.netlify.app/posts/6th-step_ledger)
