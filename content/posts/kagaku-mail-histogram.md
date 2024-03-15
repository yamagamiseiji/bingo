+++
title = "投資信託の基準価額メール配信時刻分布"
author = ["YAMAGAMI"]
date = 2024-03-15T00:00:00+09:00
tags = ["投資信託", "価額", "可視化"]
categories = ["comp"]
draft = false
+++

## はじめに {#はじめに}

去年（2023年）の8月から、契約している投資信託の運用会社が顧客の保有している投資信託の ****基準価額**** をユーザ宛にメール配信するサービスを始めました。

若干の実務的要請と ****興味半分**** で

```text
基準価額メールの配信時刻の分布
```

がどうなるかを調べてみました。

図[1](#figure--sample-out) は2023/08/15から2024/03/12 までの ****141営業日**** のメール配信時刻をヒストグラムにしたものです。グラフは営業日の20時10分に自動的[^fn:1]に描かれます。

<a id="figure--sample-out"></a>

{{< figure src="/mufg_mail_histo.svg" caption="<span class=\"figure-number\">&#22259;1:  </span>投資信託の基準価額メール配信時刻の分布。毎営業日の20時30分にグラフは更新される。" width="100%" >}}

X軸は時刻、ヒストグラムの幅(bin)は3分、Y軸はその3分間に配信されたメールの頻度(frequencey)です。チャート右上はデータ数と配信時刻のメディアンです。

およそメディアンにあたる18時23分付近に頻度の **深い谷** があって、その直後に ****最頻値**** となり、19時以降から21時30分前までの時間帯にパラパラとメールが配信されるという不思議な頻度分布になっています。極端な **外れ値** は2024/03/06のもので21時23分です。

価額メールが機械的に計算され発信されているのではなく、何らかの形で人手が入っている様子が伺えます。

ここでは、このヒストグラムをどうやって描いたかを自分への備忘もかねてメモしました。


## 環境 {#環境}

PCはThinkPad X230、Ubuntu22.04でホスト名は `kiri` です。このPCは株価や投信の価額を自動取得する専用機になっています。普段は電源はスリープ状態になっていて、crontabで指定された時刻になったら電源が入って、株価や投資信託の価額を取得し、データの一次処理を済ませたら再びスリープに戻るという運用をしています（[「rtcwake+cronでノートPCを定時にオンオフする」](https://bred-in-bingo.netlify.app/posts/rtcwake/)をご覧ください）。

コードはシェルスクリプト＋gnuplotで書いています。


## フローチャート {#フローチャート}

図[2](#figure--flowchart) は大ざっぱな処理の流れ図です[^fn:2]。

<a id="figure--flowchart"></a>

{{< figure src="/mufg-histo-flowchart.svg" caption="<span class=\"figure-number\">&#22259;2:  </span>価額メール配信時刻分析のフローチャート" width="100%" >}}

これに沿って順番に概要を説明します。


## getmail {#getmail}

-   価額メールは個人用のGmailアドレスに届きます。
-   自動的にGmailを受信するには `getmail` を使いました。
-   getmail のインストールと設定の説明はここでは省略しました。「[archlinux getmail](https://wiki.archlinux.jp/index.php/Getmail)」など分かりやすい記事がありますのでそれらをご覧ください。
-   getmailはcrontabで営業日の20:10に起動するようにしてあります[^fn:3]。
-   着信したメールは `kiri:$HOME/Maildir/new` 配下に格納します。


## 価額メールを抽出 {#価額メールを抽出}

-   上記の受信メール内に価額メールがあるかどうかを、メール発信元のメールアドレスをgrepして調べます。
-   あればメールの日付行からタイムスタンプ（ ****UTC**** ）を抽出し、それを ****JST**** に変換します。
-   JST変換後の日時を `Dropbox` 内の関係ディレクトリ内に `mail受信時刻.log` として格納します。
-   フォーマットは次のとおりです：
    ```nil
     :
    2024/03/05 18:27:40
    2024/03/06 21:22:45
    2024/03/07 18:26:40
    2024/03/08 18:27:46
    ```


## 配信時刻をunixtimeに変換する {#配信時刻をunixtimeに変換する}

-   上記データファイルの ****時分秒（JST）**** のみをunixtimeに変換して、 `~/tmp/unixtime.dat` ファイルに格納。中身はこんな感じです。
    ```nil
    　：
    34060
    44565
    34000
    34066
    ```


## 配信時刻の統計量 {#配信時刻の統計量}

-   上記 時分秒のunixtimeについて、 `gbstat` を使って最大値(max), 最小値(min), メディアン(med)を取得します[^fn:4]。

-   配信時刻はunixtimeのままgnuplotに渡します[^fn:5]。


## gnuplotでヒストグラムを描く {#gnuplotでヒストグラムを描く}

-   gnuplotスクリプトはヒアドキュメントにしてshellスクリプトに埋め込んでいます
-   max, min, med, n_data, until, などの変数はshell scriptから受け取ります
-   コードは次のような感じ：

<!--listend-->

```text
gnuplot <<EOF
# ターミナル設定
  set terminal pdfcairo transparent enhanced font 'Arial, 12'
# スタイル設定
  set style data histogram
  set style fill transparent solid border
#
  set title "価額メール配信時間分布（ 2023/08/15〜 $until）" font "Arial,14"
  set label 1 at screen 0.75,0.8 "N of data = $n_dat"
  set label 2 at screen 0.75,0.75 "Median = $med"
  set ylabel "FREQ" font "Arial,12"
  set grid ytics xtics
# 時間データ宣言
  set xdata time
  set timefmt "%s"
  set format x '%H:%M' # 出力フォーマット
#
# Histogram Trick 2023/10/01
#    UTCとJSTの時差=9時間を補正
  Min = $min + 3600*9
  Max = $max + 3600*9 + 60*3
#    +60*3 無しだと最大データが表示されない
  binwidth = 60*3
  set boxwidth binwidth
#    freq=0 の binがある時のバグ防止用
  set xrange[Min:Max]
  set yrange[0:${freq_max}+1]
  bin(x,width)=width*floor(x/width) + binwidth/2.0
#
  set output '$out_file'
  plot "$HOME/tmp/unix-time.dat"\
       using (bin((column(1)+3600*9),binwidth)):(1.0)\
       smooth freq with boxes notitle
  set output
EOF
```


### おまけ {#おまけ}

Dropbox内のヒストグラム(PDF)出力はSVGに変換して、Joplinノートで配信時刻分布の様子を見えるようにしています。方法は[「アンドロイドタブレットのJoplinをLedgerレポートのビューアにする」](https://bred-in-bingo.netlify.app/posts/joplin-usage-for-ledger/) をご覧ください。

<a id="figure--on-Joplin"></a>

{{< figure src="/2ver-mufg-histo-tablet.svg" caption="<span class=\"figure-number\">&#22259;3:  </span>Android タブレットのJoplinノート内でのヒストグラム表示" width="80%" >}}


## 今後の課題 {#今後の課題}

基準価額のメール配信サービスが始まったのは2023年8月からです。それ以前は、価額は誰でも閲覧できる投信会社のウエッブサイトで公開されていましたので、営業日の夕方から深夜（時には翌日！）の時間帯にサイトを巡回して情報を収集していました。

以前から価額がウエッブ公開される時刻が不安定で困っていましたので、メールになったら（明らかに顧客向けなので）価額の連絡が早くなり時刻も安定するかと期待していました。

しかし、図[1](#figure--sample-out)から見る限り、配信時刻の安定性が大きく改善されたようには思えません。価額、損益などの自家製分析システムは、時刻を定めてcrontabでいくつかのスクリプトを起動させるようになっています。現行の方式だとデータ取得の時刻をどこまで遅くしても、それを超えてメール配信が遅くなる可能性がありますので、確率は小さいですがどうしても手作業の介入が必要となっています。

手作業の介入を避けるためには、いろいろな手段があると思います。たとえば

-   5分とか10分に一度の割合で価額メール配信の有無をチェックするとか
-   価額メール配信があったらそれをトリガーにして各種の分析を開始するとか

などが考えられますが、ちょっと修正に手間がかかりそうなので、時間ができたらおいおい取り組んでみようと思っています[^fn:6]。


## Footnotes: {#footnotes}

[^fn:1]: 価額メールの配信が20時10分よりも遅くなった場合には、メールが届いたことを確認して手動でスクリプト類を起動していますので、完全全自動というわけではありません &#128517;
[^fn:2]: 実際には別々の３つのシェルスクリプトの中に部品としてヒストグラム描出機能がばらばらに入っています。単一のスクリプトにはなっていません。
[^fn:3]: 図[1](#figure--sample-out)を見ると、20時10分までに価額メールが配信されなかったケースが2件あることが分かります。
[^fn:4]: こんな分布のデータでは平均値(mean)は意味がありあませんので使っていません。
[^fn:5]: JSTとUTの間に9時間の時差があるのでgnuplot内で補正しています。
[^fn:6]: けど、手作業が必要になる確率は営業日70日（物理日数≒100日）あたり１回程度なので、それくらいなら大掛かりなスクリプト類の修正よりは手作業を続けるほうがマシという考えもありますよね&#128517;
