+++
title = "Mermaidで自分向けフローチャート"
author = ["YAMAGAMI"]
date = 2024-08-30T00:00:00+09:00
tags = ["mermaid", "ledger-cli", "投資信託", "Joplin"]
categories = ["comp"]
draft = false
+++

## はじめに {#はじめに}

2024年6月、 ****Mermaid＋Joplin**** でフローチャートが描けることを知りました。敷居が高かったフローチャート描きのハードルがMermaidのおかげで低くなりました[^fn:1]。

ここでは保有する ****投資信託**** の ****時価評価額の推移**** を銘柄別に折れ線グラフにするシェルスクリプト（ `it-market-value_plotter.sh`&nbsp;[^fn:2]）のフローチャートを紹介します。

> 各投資信託の価額は毎営業日ごとに別のスクリプトで自動取得し、
> Ledger-cliの `.prices.db` フォーマットで蓄積・保存してあります（[状態遷移図をMermaidで描いてみました](https://bred-in-bingo.netlify.app/posts/mermaid-state-diagram/)）。そのDBをledger-cliで `--market` オプションをつけて読み出して、gnuplotで推移チャートにするというシンプルなスクリプトです。


## 自分向けフローチャート {#自分向けフローチャート}

このフローチャートは他人に見せるためではなくて、自分が書いたコードがどんな流れだったか思い出すための ****自分向け**** チャートです。おもな特徴は：

-   ノードを ****色分け**** しました。色分けについては [QUORA Are there standard colors for flow chart symbols?](https://www.quora.com/Are-there-standard-colors-for-flow-chart-symbols) の記事[^fn:4]を参考にしました。
-   色の選定については、まずお好みのパステルカラー風な青色 #dae9fcをベースにして、その色に対するペンタール配色やコンプリメンタリ−色（補色の類似色）から6色（紫、黄、緑、赤、橙、ピンク）それプラス、グレイ、元の青と合わせて合計8色としました。
-   ノードの右側に ****注釈**** ＝ノートをつけました。
-   流れの構造を見やすくするため、できるだけ ****subgraph**** を使うようにしました。


## レンダリングされたフローチャート {#レンダリングされたフローチャート}

コードは[Mermaid Code](#code) 節をごらんください。

<a id="figure--sample-out"></a>

{{< figure src="/mermaid-1724990189005.svg" caption="<span class=\"figure-number\">&#22259;1:  </span>Mermaidで描いたフローチャート例。" width="90%" >}}


## Mermaid Code {#code}

```text
flowchart TB
	%%{init:{'theme':'forest'}}%%

%%%% classDef 設定 %%%%
	classDef blue fill:#dae9fc
	classDef purple fill:#f5dcfc
	classDef yellow fill:#fafcdc
	classDef green fill:#dcfce8
	classDef red fill:#fcdcdd
	classDef orange fill:#fceedc
	classDef pink fill:#ffe5ea
	classDef gray fill:#F5F5E8

%%%% subgraphs %%%%

	subgraph Market_Prices ["＜時価取得・ファイル保存＞"]
		style Market_Prices fill:white,stroke:black
	    direction TB

		LED2[変数定義]:::blue
		LED2 ~~~|"銘柄名-mv.dat"| LED2
		LED2 --> LED3[投信配列宣言]:::blue
		LED2 ~~~|"$from, $b_date"| LED2
		LED3 ~~~|"短縮名 銘柄名-mv.dat 変数名"| LED3
	    LED3 --> LED4[/ループ開始\]
		LED4 --> LED5[("銘柄ごとの\n時価ファイル作成")]:::gray
		LED5 ~~~|"ledger --market\n銘柄名-mv.dat"| LED5
		LED5 --> LED6[\ループ終了/]
		LED6 --> LED7[("全投信の時価合計額\n取得・保存")]:::gray
		LED7 ~~~|"all-trust-mv.dat"| LED7
	end


	subgraph Gnuplot_Variables ["＜Gnuplot用変数の設定＞"]
		style Gnuplot_Variables fill:white,stroke:black
		direction TB
		GNU1["描出対象データファイル名を\n配列に格納"]:::blue --> GNU2[日付、データ区切変換]:::blue
	    GNU1 ~~~|"${file_path_arr[@]}"| GNU1
		GNU2 --> GNU3["最新時価取得・フォーマット変換"]:::blue
		GNU2 ~~~|"%Y%m%d", TAB| GNU2
		GNU3 ~~~|"%'d"| GNU3
		GNU3 --> GNU4[その他の変数設定]:::blue
		GNU4 ~~~|"$out_file,$gtitle,$ymd_date_latest"| GNU4
      end


	subgraph Gnuplot_Plot ["＜Gnuplotスクリプト＞"]
		style Gnuplot_Plot fill:#dcfce8
		direction TB

		GA([gnuplot &lt&ltEOF]) --> GB:::blue
		GB["ターミナル設定\n set terminal"] --> GC:::blue
		GB ~~~ |"pdfcairo, color, transparent,\n enhanced,	font Arial,14"| GB
		GC["タイトル設定\nset title"] --> GD:::blue
		GC ~~~ |"#quot;$gtitle#quot; font #quot;Arial,14#quot;"| GC
		GD["凡例設定\nset key"] --> GD2:::blue
		GD ~~~ |"left top \n inside reverse"| GD
		GD2["STATS_max_y取得\nstats"] --> GF:::blue
		GD2 ~~~ |"#quot;${data_to_plot}#quot; nooutput"| GD2
		GF["時間軸設定"] --> GG:::blue
		GF ~~~ |"set xdata time\n set time format #quot;%Y%m%d#quot;\n set format x #quot;${x_format}#quot;"| GF
		GG["X軸設定"] --> GG2:::blue
		GG ~~~ |"set #quot;${xrange1}#quot;:#quot;${xrange3}#quot;] \n  set xlabel '${xlabel}' font #quot;Arial,12#quot;"| GG
		GG2["Y軸設定"] --> GH:::blue
		GG2 ~~~ |"set yrange [0:(STATS_max_y/1000  + 1000)]\n set ylabel offset 4,0\n   set ylabel '時価評価（千円）' font #quot;Arial, 12#quot; \n   set ytics font #quot;Arial,9#quot;"|GG2
		GH["出力ファイル名設定\nset output"] --> GI:::blue
		GH ~~~ |"$out_file"| GH
		GI["color設定"] --> GJ:::blue
		GI ~~~ |"set colorsequence podo"| GI
		GJ[/"Plot ${all-trust}他\n全個別銘柄"/]:::yellow --> GEND
		GEND([EOF])
	end


	subgraph Clearing_Up ["＜後始末＞"]
		style Clearing_Up fill:white,stroke:black
	    direction TB

		S[[Call\nsymbolic-link-maker_ver2]]:::purple
	   S ~~~|"hot-it-market-value.pdf"|S
		S --> PDF_to_SVG[("PDFをSVG変換・\n保存")]:::gray
		PDF_to_SVG ~~~|"Joplinノート用"| PDF_to_SVG
		PDF_to_SVG --> T[("出力チャートを\nクラウドに保管")]:::gray
		T ~~~ |"Dropbox\nOneDrive"| T
		T --> U{Check\n親プロセス}:::orange
		U -->|Makefile| V[Do nothing]:::blue
		U -->|not Makefile| W[/mupdfで\nPDF表示/]:::yellow
	    V --> X[一時ファイル\n削除]:::blue
		W --> X
	end


%%%% MAIN FLOW OF FLOWCHART %%%%

	A([Start]) --> Load_Functions["関数読込み"]:::blue
	Load_Functions ~~~|"symbolic-link-maker_ver2\ngnuplot-period-setter"| Load_Functions
	Load_Functions --> C{"引数(期間)\nはあるか?"}:::orange
	C ~~~|"w,m,3,6,y"| C
	C -->|Yes| D["引数を$keyinに格納"]:::blue
	D --> F
	C -->|No| E[/"プロンプトへの\n期間入力を$keyinに格納"/]:::yellow
	E --> F[["関数gnuplot-period-setterで\n$keyinから\ngnuplot用変数を生成"]]:::purple
	F ~~~|"xrange1, xrange3, x_format\n xtics1, xtics2, xtics3, xlabel"| F
	F --> Market_Prices
	Market_Prices --> Gnuplot_Variables
	Gnuplot_Variables --> Gnuplot_Plot
	Gnuplot_Plot --> Clearing_Up
	Clearing_Up --> END([End])
```

以上です。


## Footnotes: {#footnotes}

[^fn:1]: Mermaid＋Joplin（エディタはEmacs）で問題は無いのですけど、ちょっとコードが長くなってくるとエラーを発見するのが大変。そこで急遽 Emacsにmermaid-cliとob-mermaidを入れてorg-modeでエラー箇所を教えてもらうようにしました。もっと楽にEmacs--&gt;Markdown--&gt;Mermaidが出来る方法があるとは思うのですが・・・。
[^fn:2]: `it` はinvestment trust(投資信託)の短縮形として使っています。

    とはいえ、Mermaidの存在を知ってわずか2か月ほどですし、
    6月から8月は北群馬の畑の繁忙期なものですから、フローチャートなど書いている時間はほとんどありませんでした。お見せするのはお恥ずかしい限りですが、この程度の初心者でもMermaidなら何とかなるのを見て頂ければと思います[^fn:3]。
[^fn:3]: この記事の目的は、Mermaid codeのフローチャート例をお見せすることですので、スクリプトの中身についての説明は省略します。
[^fn:4]: ノードの推奨色分け：

    | ノードの形（機能)                                   | 色           |
    |---------------------------------------------|-------------|
    | Oval (Start/End)                                    | Green or Red |
    | Rectangle (Process)                                 | Blue         |
    | Diamond (Decision)                                  | Orange       |
    | Parallelogram (Input/Output)                        | Yellow       |
    | Rectangle with Rounded Corners (Predefined Process) | Purple       |
    | Cylinder (Data Storage)                             | Gray         |
