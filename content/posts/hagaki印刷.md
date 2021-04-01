+++
title = "わざわざ Emacs/LaTeXでハガキ印刷するわけ"
date = 2018-12-30T11:52:00+09:00
tags = ["LaTeX", "Emacs", "DIY", "social"]
categories = ["comp"]
draft = false
+++

<div class="ox-hugo-toc toc">
<div></div>

<div class="heading">Table of Contents</div>

- [表面（宛名）印刷](#表面-宛名-印刷)
    - [年賀状の宛名面印刷のためのクラスファイル](#年賀状の宛名面印刷のためのクラスファイル)
    - [普通葉書の宛名印刷のためのクラスファイル](#普通葉書の宛名印刷のためのクラスファイル)
- [文面（ウラ面）のためのサンプルファイル](#文面-ウラ面-のためのサンプルファイル)

</div>
<!--endtoc-->

最近でも、年に数回はどうしてもハガキでの通信が必要になります。目上の方へのお中元やお歳暮のお礼とか、住所とお名前だけは分かっているけれど、電話番号やメールやラインなどの情報がない方への連絡というのが主なケースです。

そんな場合に、手書きでハガキをスラスラ書ける筆達者な人はしあわせです。もちろん、きれいな手書き文字のハガキは受け取った人もしあわせになります。残念ながら、わたしにはその才能がありません。

ハガキ印刷のためのパソコンアプリがたくさんあるじゃないか、MS Wordだって書けるし・・・そうなんですが、WinPC/MacOSとも立ち上げに時間がかかるし、操作も難しい（皮肉でも冗談でもありません、本音です）。文字だけの単純な文面なのに、思ったように印刷するまでとてもストレスフルです。「お礼状を書かなければ・・」と思いつつも、気が重くて先送りする、その結果、相手先に対して礼を失することになる、これまでもそんなことが少なからずありました。

このような状況で社会的にまずい人物になるのを避けるためには、使い慣れたEmacs on Linux で文面を作り推敲して、そのままハガキに印刷できる環境があれば良いわけです。短く簡単な内容のテキストファイルなので、Emacs上で書けばハガキ1枚は速ければ数分の作業時間です。

実は先達のみなさんがすでに各種の仕掛けを作って頂いています（eg. [Shin'ya Ueoka](https://github.com/ueokande/jletteraddress/blob/master/LICENSE)）が、使ってみると、何故かボクの環境では、郵便番号が枠からはみ出たりなどの小さなトラブルがありました。というわけで、自分用に普通ハガキと年賀状の宛名面印刷のために、先達のスタイルを試行錯誤的にバラックで修正させていただきました。

この先これが必要な事例数がどれほどになるか分かりませんが、平成最後の年の瀬を迎え、これがあるというだけで心が軽くなりましたｗ。


## 表面（宛名）印刷 {#表面-宛名-印刷}

動作確認環境は、ubuntu16.04 on ThinkPad X230、プリンタは CANON iP7230/Brother HL-L8350CDW です。


### 年賀状の宛名面印刷のためのクラスファイル {#年賀状の宛名面印刷のためのクラスファイル}

```LaTeX
%%          Time-stamp: <2018-12-28 21:15:14 yamagami>
%% Copyright (c) 2014 Shin'ya Ueoka <ibenza@i-beam.org>
%%          年賀状宛名フォーマット modified by Seiji ....
%%
\NeedsTeXFormat{pLaTeX2e}
\ProvidesClass{jletteraddress}

\LoadClass[]{article}

\usepackage{plext}
\usepackage{xstring}
\ifx\kanjiskip\undefined\else
  \usepackage{atbegshi}
  \ifx\ucs\undefined
    \ifnum 42146=\euc"A4A2
      \AtBeginShipoutFirst{\special{pdf:tounicode EUC-UCS2}}
    \else
      \AtBeginShipoutFirst{\special{pdf:tounicode 90ms-RKSJ-UCS2}}
    \fi
  \else
    \AtBeginShipoutFirst{\special{pdf:tounicode UTF8-UCS2}}
  \fi
  \usepackage[dvipdfmx]{hyperref}

  %% Set a paper size for dvipdfmx
  \special{papersize=100truemm,148truemm}
\fi

%% Layouts
\setlength{\hoffset}{-1truein}
\setlength{\voffset}{-1truein}
\setlength{\oddsidemargin}{0pt}
\setlength{\evensidemargin}{0pt}
\setlength{\topmargin}{0pt}
\setlength{\topmargin}{0pt}
\setlength{\headheight}{0pt}
\setlength{\headsep}{0pt}
\setlength{\paperwidth}{100truemm}
\setlength{\paperheight}{148truemm}

\setlength{\tabcolsep}{0pt}
\setlength\tabbingsep{0pt}
\setlength{\unitlength}{1truemm} %

%% Sender macros
\def\sendername#1{\gdef\@sendername{#1}}
\def\senderpostcode#1{\gdef\@senderpostcode{#1}}
\def\senderaddressa#1{\gdef\@senderaddressa{#1}}
\def\senderaddressb#1{\gdef\@senderaddressb{#1}}

%% Make a address-side
\newcommand{\addaddress}[5] {
  % #1 : Receiver name
  % #2 : Receiver name suffix
  % #3 : Receiver postcode
  % #4 : Receiver address 1
  % #5 : Receiver address 2
  \clearpage
  \refstepcounter{section}
  \addcontentsline{toc}{section}{#1}
  \noindent %
  \begin{picture}(100,148)(0,0)%
    \put(42,138){ % 宛先郵便番号
      \vtop to 8truemm{\vfil\hbox{\fontsize{15pt}{0pt}\selectfont%
	\hbox to 7truemm{\hfil\StrChar{#3}{1}\hfil}%
	\hbox to 7truemm{\hfil\StrChar{#3}{2}\hfil}%
	\hbox to 7truemm{\hfil\StrChar{#3}{3}\hfil}\hskip1.3truemm
	\hbox to 7truemm{\hfil\StrChar{#3}{4}\hfil}%
	\hbox to 7truemm{\hfil\StrChar{#3}{5}\hfil}%
	\hbox to 7truemm{\hfil\StrChar{#3}{6}\hfil}%
	\hbox to 7truemm{\hfil\StrChar{#3}{7}\hfil}%
    }\vfil}}
    \put(83,120){\fontsize{15pt}{0pt}\selectfont% 宛先住所１
	\parbox<t>[t]{90truemm}{#4}}
    \put(75,120){\fontsize{15pt}{0pt}\selectfont% 宛先住所２
	\parbox<t>[t]{90truemm}{\hfil#5}}
    \put(50,120){\kanjiskip=.3zw\fontsize{27pt}{0pt}\selectfont% 宛先氏名
	\parbox<t>[t]{90truemm}{\hfil#1\hskip1zw#2}\hfil}
%%
    \put(19,79){\fontsize{12pt}{0pt}\selectfont% 発信者住所１
	\parbox<t>[t]{55truemm}{\@senderaddressa}}
    \put(13,79){\fontsize{12pt}{0pt}\selectfont% 発信者住所２
	\parbox<t>[t]{55truemm}{\@senderaddressb}}
    \put(5,79){\kanjiskip=0.3zw\fontsize{15pt}{0pt}\selectfont% 発信者氏名
	\parbox<t>[t]{55truemm}{\hfil\@sendername}\hfil}
     \put(0.5,21){ %発信者郵便番号
      \vtop to 6.5truemm{\vfil\hbox{\fontsize{12pt}{0pt}\selectfont%
       \hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{1}\hfil}%
	\hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{2}\hfil}%
	\hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{3}\hfil}\hskip1.4truemm %
	\hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{4}\hfil}%
	\hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{5}\hfil}%
	\hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{6}\hfil}%
	\hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{7}\hfil}%
    }\vfil}}
  \end{picture} %
}

```


### 普通葉書の宛名印刷のためのクラスファイル {#普通葉書の宛名印刷のためのクラスファイル}

```LaTeX
%%          Time-stamp: <2018-12-28 21:53:18 yamagami>
%% Copyright (c) 2014 Shin'ya Ueoka <ibenza@i-beam.org>
%%          普通はがき宛名印刷　modified by seiji
%%
\NeedsTeXFormat{pLaTeX2e}
\ProvidesClass{jletteraddress}

\LoadClass[]{article}

\usepackage{plext}
\usepackage{xstring}
\ifx\kanjiskip\undefined\else
  \usepackage{atbegshi}
  \ifx\ucs\undefined
    \ifnum 42146=\euc"A4A2
      \AtBeginShipoutFirst{\special{pdf:tounicode EUC-UCS2}}
    \else
      \AtBeginShipoutFirst{\special{pdf:tounicode 90ms-RKSJ-UCS2}}
    \fi
  \else
    \AtBeginShipoutFirst{\special{pdf:tounicode UTF8-UCS2}}
  \fi
  \usepackage[dvipdfmx]{hyperref}

  %% Set a paper size for dvipdfmx
  \special{papersize=100truemm,148truemm}
\fi

%% Layouts
\setlength{\hoffset}{-1truein}
\setlength{\voffset}{-1truein}
\setlength{\oddsidemargin}{0pt}
\setlength{\evensidemargin}{0pt}
\setlength{\topmargin}{0pt}
\setlength{\topmargin}{0pt}
\setlength{\headheight}{0pt}
\setlength{\headsep}{0pt}
\setlength{\paperwidth}{100truemm}
\setlength{\paperheight}{148truemm}

\setlength{\tabcolsep}{0pt}
\setlength\tabbingsep{0pt}
\setlength{\unitlength}{1truemm} %

%% Sender macros
\def\sendername#1{\gdef\@sendername{#1}}
\def\senderpostcode#1{\gdef\@senderpostcode{#1}}
\def\senderaddressa#1{\gdef\@senderaddressa{#1}}
\def\senderaddressb#1{\gdef\@senderaddressb{#1}}

%% Make a address-side
\newcommand{\addaddress}[5] {
  % #1 : Receiver name
  % #2 : Receiver name suffix
  % #3 : Receiver postcode
  % #4 : Receiver address 1
  % #5 : Receiver address 2
  \clearpage
  \refstepcounter{section}
  \addcontentsline{toc}{section}{#1}
  \noindent %
  %  \begin{picture}(100,148)(0,0)%
  \begin{picture}(100,147)(0,0)%
    \put(42,136){ % 宛先郵便番号
      \vtop to 8truemm{\vfil\hbox{\fontsize{15pt}{0pt}\selectfont%
	\hbox to 7truemm{\hfil\StrChar{#3}{1}\hfil}%
	\hbox to 7truemm{\hfil\StrChar{#3}{2}\hfil}%
	\hbox to 7truemm{\hfil\StrChar{#3}{3}\hfil}\hskip1.6truemm
	\hbox to 7truemm{\hfil\StrChar{#3}{4}\hfil}%
	\hbox to 7truemm{\hfil\StrChar{#3}{5}\hfil}%
	\hbox to 7truemm{\hfil\StrChar{#3}{6}\hfil}%
	\hbox to 7truemm{\hfil\StrChar{#3}{7}\hfil}%
    }\vfil}}
%%
    \put(83,115){\fontsize{15pt}{0pt}\selectfont% 宛先住所１
	\parbox<t>[t]{90truemm}{#4}}
    \put(75,115){\fontsize{15pt}{0pt}\selectfont% 宛先住所２
	\parbox<t>[t]{90truemm}{\hfil#5}}
%%
    \put(50,110){\kanjiskip=.3zw\fontsize{27pt}{0pt}\selectfont% 宛先氏名
	\parbox<t>[t]{90truemm}{\hfil#1\hskip1zw#2}\hfil}
%%
    \put(19,66){\fontsize{12pt}{0pt}\selectfont% 発信者住所１
	\parbox<t>[t]{55truemm}{\@senderaddressa}}
    \put(13,66){\fontsize{12pt}{0pt}\selectfont% 発信者住所２
	\parbox<t>[t]{55truemm}{\@senderaddressb}}
    \put(5,66){\kanjiskip=0.3zw\fontsize{15pt}{0pt}\selectfont% 発信者氏名
	\parbox<t>[t]{55truemm}{\hfil\@sendername}\hfil}
    \put(1,2){ %
%%
      \vtop to 0.1truemm{\vfil\hbox{\fontsize{12pt}{0pt}\selectfont%
       \hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{1}\hfil}%
	\hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{2}\hfil}%
	\hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{3}\hfil}\hskip1.8truemm %
	\hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{4}\hfil}%
	\hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{5}\hfil}%
	\hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{6}\hfil}%
	\hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{7}\hfil}%
    }\vfil}}
  \end{picture} %
}
```


## 文面（ウラ面）のためのサンプルファイル {#文面-ウラ面-のためのサンプルファイル}

```LaTeX
%  　　　　　　　　　　　　　Time-stamp: <2018-12-28 22:02:01 yamagami>
\documentclass[12pt]{tarticle}
\thispagestyle{empty}
\usepackage{bxpapersize}
% ＜余白設定＞　文字数の多寡によって要調整
\papersizesetup{size={100mm,148mm}}
     \setlength\topmargin{-23mm}
     \setlength\oddsidemargin{-15mm}
     \setlength\evensidemargin{5mm}
     \setlength\textwidth{126mm} % 本文縦サイズ
     \setlength\textheight{80mm} % 本文横サイズ
%  ＜印刷の方法＞印刷指定で紙の設定を「はがき」にして印刷すること

\begin{document}

\bigskip
\noindent
前略

\medskip
このたびは結構なお品をご恵贈くださりまことにありがとうございました。

平素から公私にわたり何かとご配慮を賜っておりますうえに、ご厚志を頂戴致し
まして恐縮いたしております。

　　：中略：
{\hfill 草々}
\bigskip
　平成三十年十二月三十日
\end{document}
```