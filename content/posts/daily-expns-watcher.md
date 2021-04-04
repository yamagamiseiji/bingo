+++
title = "予算消化状況を日々 ledger-cliとgnuplotでモニターする"
date = 2020-03-09T19:40:00+09:00
tags = ["ledger", "emacs", "accounting", "viz", "gnuplot"]
categories = ["comp"]
draft = false
+++

<div class="ox-hugo-toc toc">
<div></div>

<div class="heading">Table of Contents</div>

- [日々の累積支出額と予算の関係](#日々の累積支出額と予算の関係)
    - [仕掛け](#仕掛け)
    - [環境](#環境)
- [コーディング](#コーディング)
    - [bashスクリプト](#bashスクリプト)
    - [gnuplotスクリプト](#script-gnu)
    - [（追記）上記「もめ事」解決しました！](#追記-上記-もめ事-解決しました)
- [使いみちなど](#使いみちなど)
- [Acknowledgement](#acknowledgement)

</div>
<!--endtoc-->

**新型コロナウイルス** という外来の危機（ **外患** ）加えて、3月に入ってから、破れかぶれの政府が支離滅裂な迷走状態に入るという **内憂** が重なって、ますます気分が鬱々としています。現在の政府・内閣の挙動はおよそ組織としての体をなしていませんよね。政府と内閣だけでなく、霞が関全体とマスコミが **挙国一致** してこの暴走を見てみぬふりをしている。これまで歴史上、無数の国や組織体が壊れて消滅しましたが、 **「帝国」** はこんな風にして **内側** から崩壊するんですね。


## 日々の累積支出額と予算の関係 {#日々の累積支出額と予算の関係}

それはともかく、[前回](http://org2-wp.kgt-yamy.tk/2020/02/21/post-904/)、グラッフィクな水平ゲージで予算消化率（パーセンテージだけ）をプロットする方法を紹介しました。今回は、新型コロナウィルスで **外遊び** もままならぬので（笑）、さらに一歩を進めて次のようなチャートを作ってみました。

```text
月々の支出目標（予算）に向けて日々の累積支出額がどのように推移しているか
その動きをモニターする
```

まずは例図をみてください（金額はでたらめです）。

<a id="org33e602d"></a>

{{< figure src="/budget-watcher-sample.png" caption="Figure 1: 予算ライン（バイオレット）と現在の支出レベル（緑）。青っぽいところは予算以下、オレンジっぽいところは予算超過。" width="90%" >}}


### 仕掛け {#仕掛け}

月始めから当日までに支出した金額の累計（緑のライン）はledger-cliで算出します。これはとても簡単。次の１行です：

```nil
#  当月の累積支出金額（１日毎） --> tmp-togetsu.dat
ledger reg ^expenses -p 'this month' -J -D --collapse\
       --plot-total-format="%(format_date(date, \"%d\"))\
	%(abs(quantity(scrub(display_total))))\n"  > ./tmp-togetsu.dat
```

上で得られる `tmp-togetsu.dat` は次のような形になります（金額はでたらめです）：

```nil
01   8404
02   49728
03   56663
04   59663
05   62779
：　　　　：
```

あと、予算の **バイオレットライン** ですが、この線の **関数式** は各月ごとの特殊事情などを勘案して目標値と開始値を定めておいて、昔懐かしい **連立方程式** を解いて求めます。紙と鉛筆で計算すると間違えるので、これまた昔懐かしい **Fortran** で `y=ax+b` の係数 a, bを求めます。計算された各月のa,bを次のようなイメージで `budget.tabl` ファイル内に格納しておきます：

```nil
# date  budget   a         b
2020/03	350000 10666.7  19333.3
2020/04	450000 11034.4  18965.5
2020/05 400000 12333.3  17666.7
　　：　　：　　　　：　　　：
```

これを使って、gnuplotで `f(x)=ax+b` をプロットします。この関数の直線と、実際の支出データの折れ線グラフの2本の折れ線に **はさまれた領域** を、関数直線の上下で **色分け** して表示します。なおファイルの第2列はこのスクリプトでは使いません。

実は当初、この **領域色分け** を実現するための  `filledcurves` の書き方がよくわからなかったために手こずりました。できてしまえば簡単ですが変なところでハマって結構時間がかかりました（笑）。コードは[こちら](#script-gnu)を見て下さい。


### 環境 {#環境}

-   Ubuntu 16.04
-   GNU bash, バージョン 4.3.48(1)-release (x86\_64-pc-linux-gnu)
-   Ledger 3.1.1-20160111
-   gnuplot 5.2 patchlevel 8
-   GNU Fortran (Ubuntu 5.4.0-6ubuntu1~16.04.12) 5.4.0 20160609


## コーディング {#コーディング}

次の２つのスクリプトを組み合わせて動かします。

-   **bashスクリプト** ： ledgerを動かして当月の1日ごとの累積支出金額を計算します。その後、下のgnuplotスクリプトをコールします。
-   **gnuplotスクリプト** （ `gp-budget-watcher.plt` ）： filledcurvesを使って2本のラインに囲まれた領域を色分けします。


### bashスクリプト {#bashスクリプト}

```nil
#!/bin/bash
#
#  Ledgerで当月における当日までの支出金額を1日毎にまとめたデータを取得し、
#  当月の支出予算式の係数 a,b をconfig/budgets.tableから抽出し、
#   gnuplotに引き渡す

#  当月の累積支出金額のファイルを作成する --> tmp-togetsu.dat
ledger reg ^expenses -p 'this month' -J -D --collapse\
       --plot-total-format="%(format_date(date, \"%d\"))\
	%(abs(quantity(scrub(display_total))))\n"  > tmp-togetsu.dat
##
#  当月の年月を得る
ym=`date +"%Y/%m"`

# ymの年月文字列を含む行をbudgets.tableから抽出しtmp-hitline.txtに格納
grep $ym ~/hogehoge/configs/budget.table > tmp-hitline.txt

#  係数a,bを獲得し、gnuplotに引き渡す
a=`awk '{printf $3}' tmp-hitline.txt`
b=`awk '{printf $4}' tmp-hitline.txt`

###############################
#  gnuplot の励起
gnuplot -e "a='$a';b='$b';out_file='doya-out.pdf'" gp-budget-daily.plt
###############################
# 端末に表示
mupdf $out_file &
```


### gnuplotスクリプト {#script-gnu}

スクリプト名は `gp-budget-daily.plt` 。

```nil
reset
set terminal pdfcairo  transparent enhanced font "arial,10"

set style fill transparent solid 0.8 noborder
set style increment default
set style data lines
#
set grid ytics xtics
set ylabel '金額（円）'
set xlabel 'Days in Month'
#
set title "支出予算額と当月の支出額 （`date "+%Y/%m"`）" \
   font "arial,14"
set key inside left top
set xrange [ 01 : 31 ] noreverse writeback
set yrange [0:450000] noreverse writeback
set decimal locale
set format y "%'8.0f"
#
set samples 31
#  予算式の係数a,bはbashから受け取る
f(x) = a * x + b

#  出力ファイル名はbashから受け取る
set output out_file

plot '/home/hogehoge/tmp-togetsu.dat'\
   using 1:2:(f($1)) w filledcurves below title '予算以下' lc rgb "skyblue",\
'' using 1:2:(f($1)) w filledcurves above title '予算以上' lc rgb "orange-red",\
'' using 1:2 w lines lt 2 lw 3  title '当月の支出',\
   f(x) lt 2 lw 1 lc rgb "violet" title '支出予算額'

set output
```

ここのミソは次の1行です：

```nil
plot '/home/hogehoge/tmp-togetsu.dat'\
   using 1:2:(f($1)) w filledcurves below title '予算以下' lc rgb "skyblue",\
　　：
```

引っかかったのは、 `f($1)` の `$1` がbashとgnuplotの間で **もめ事** を起こすこと。そのために `gnuplot << EOF` スタイルでgnuplotスクリプトを素直にbashに埋め込むことができませんでした。それを迂回するためにこんな形でしのいでいます。回避できるので大きな問題ではありませんが、簡単にエスケープ？する方法が他にもあるんだとは思いますが・・・（笑）


### （追記）上記「もめ事」解決しました！ {#追記-上記-もめ事-解決しました}

[こちらのサイト](https://groups.google.com/forum/m/#!topic/comp.graphics.apps.gnuplot/JCNS96hGaIg) にすばらしい情報がありました。gnuplotの `column()` 関数を使う方法です。たとえば次のようにします：

```nil
（旧）   using ($2*0.5):0:($2*0.5):(0.35):yticlabels(1)\
（新）   using (column(2)*0.5):0:(column(2)*0.5):(0.35):yticlabels(1)\
```

これで、 `gnuplot <<EOF 〜 EOF` スタイルが使える範囲がぐっと増えます。


## 使いみちなど {#使いみちなど}

前回の水平バーチャートも今回の予算消化チャートも、お金の動きを **ワンクリック** またはコマンド一発で **リアルタイム** に確認するための **道具** として使っています。そうした用途にはいわゆる **ダッシュボード** を使うのが王道のような気もします。現在、そっちに向けて色々考えているところですが、一つの有力な候補は [ **Grafana** ](https://grafana.com/)でしょうか。Ledgerと組み合わせて使っている先例もあるので、そのうちトライしてみたいと思っています。


## Acknowledgement {#acknowledgement}

次のサイトがとても参考になりました。

-   [ledger-reports](https://github.com/cbdevnet/ledger-reports)
-   <https://groups.google.com/d/msg/comp.graphics.apps.gnuplot/YkZJ6EdS5MM/S9jFF0yu6qIJ>