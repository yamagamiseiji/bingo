+++
title = "Ledger-cliでNPO法人会計の可視化 — チュートリアル"
author = ["YAMAGAMI"]
date = 2024-01-26T00:00:00+09:00
tags = ["ledger-cli", "NPO", "visualization", "可視化"]
categories = ["comp"]
draft = false
+++

## イントロ {#イントロ}

ここでは

```text
経常費用を月ごとに集計して折れ線グラフにする
```

これのあらまし、骨格だけを紹介します。

Ledgerと組み合わせてグラフやチャートを書く方法は多様だと思います。ここではbashのシェルスクリプト内でLedgerとgnuplotを使っています。
gnuplotはヒアドキュメントとしてシェルスクリプト内に組み込んでいます。

とにかく骨格だけの紹介ですから、グラフ内の細かい修飾はいっさい入れていません。でも、この事例をご覧いただければ、各自の用途にマッチしたきれいな図がすぐにかけるようになるでしょう。


## 条件 {#条件}

-   Ledger-cliがインストールされていること
-   LedgerのTXNファイルはこちら
-   configsはこちら
-   前回記事は学会という特殊な団体、人件費が非常にちいさい、「その他事業費」というが変だったので、「人権費」「その他事業費」という二分法を敢えて取らなかった
-   ここでは、できるだけ基準に準ずるという意味で（納得してないが）まそのままの勘定科目構造にしてみた
-   サンプルのLedgerデータは[こちら](https://bred-in-bingo.netlify.app/npo/sample-NPO.ledger)


## 出力サンプル {#出力サンプル}

<a id="figure--sample-chart"></a>

{{< figure src="/npo/monthly-expnese-rolling.svg" width="60%" >}}


## Codeサンプル {#codeサンプル}

```sh
#!/bin/bash
#
#  月ごとの経常経費を折れ線グラフにする
#
ledger reg 経常費用\
       --monthly\
       --amount-data\
       --collapse\
       --init-file .ledgerrc\
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
# X軸設定
  set xtics font 'Arial,10'
  set xlabel "月" font 'Arial,12'
# 出力ファイル指定
  set output '$out_file'
# 描出
  plot '$csv_file' \
     using (column(2)/1000):xticlabels(strftime('%01m', strptime('%Y-%m-%d', strcol(1))))\
	with linespoints  pt 7 ps 0.5 lw 2 notitle, \
     '' using 0:(column(2)/1000):(sprintf("%'d", (column(2))))\
	with labels font "Arial,8" offset 0,0.7 textcolor linestyle 0 notitle

  set output
EOF

evince ${out_file}
exit 0
```
