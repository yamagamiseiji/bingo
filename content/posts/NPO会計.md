+++
title = "小規模学会のためのLedgerポスティング例 — NPO法人会計基準に準拠しながら"
author = ["YAMAGAMI"]
date = 2024-01-25T00:00:00+09:00
tags = ["Ledger-cli", "NPO", "会計"]
categories = ["comp"]
draft = false
+++

<div class="ox-hugo-toc toc">

<div class="heading">&#30446;&#27425;</div>

- [イントロダクション](#イントロダクション)
- [この記事について](#この記事について)
    - [修正履歴](#修正履歴)
    - [トップレベルの４勘定科目](#トップレベルの４勘定科目)
    - [上の4勘定科目の配下にあるサブ科目構造](#上の4勘定科目の配下にあるサブ科目構造)
        - [経常費用（Expenses）](#経常費用-expenses)
        - [経常収益(Income)](#経常収益--income)
        - [資産（Assets）](#資産-assets)
        - [負債(Liabilities)](#負債--liabilities)
- [ポスティング サンプル](#ポスティング-サンプル)
    - [入会金と年会費の例](#入会金と年会費の例)
    - [受取補助金の例](#受取補助金の例)
    - [事業収入の例](#事業収入の例)
    - [経常費用(Expenses）の例](#経常費用expenses-の例)
    - [源泉税の例](#gensenzei)
    - [立替金の例](#立替金の例)
    - [未払金の例](#未払金の例)
    - [仮受金の例](#仮受金の例)
- [クエリの例](#クエリの例)
- [Appendix: Ledger-cliの設定ファイル](#appendix-ledger-cliの設定ファイル)
    - [~/.ledgerrcについて](#ledgerrc)
    - [init-npo-datファイルの中身](#init-file-sample)
- [Appendix:  NPO法人会計関係記事一覧](#appendix-npo法人会計関係記事一覧)
- [Footnotes:](#footnotes)

</div>
<!--endtoc-->



## イントロダクション {#イントロダクション}

ここでは

```text
会員数1,000名未満の小規模な学会が
Ledger-cliを使ってNPO法人会計基準にそって会計処理する際の
具体的なポスティング例を紹介します
```

NPO法人会計の体系的な説明や勘定科目構造などについてはネット上に良い資料がたくさんありますので、そちらを参照してください[^footnote_whats_npo]。

またLedgerでNPO法人会計の ****財務諸表**** を書く方法は「[NPO法人会計に準拠した財務諸表をLedger-cliで書く](https://bred-in-bingo.netlify.app/posts/financial-statements-for-NPO/)」をみてください。

[^footnote_whats_npo]: 「[NPO 法人会計基準ハンドブック](https://www.npokaikeikijun.jp/wp-content/uploads/handbook201202.pdf)」、「[「ＮＰＯ法人会計」の仕訳](https://www.ssdesign.co.jp/kaiN/kaiN_shiwake.pdf) 」などたくさんあります。


## この記事について {#この記事について}

-   小規模学会の経理を例として使っていますが、一般的なNPO法人会計への適用にもいくらか役立つと思います
-   目に付いたトランザクションをどうポスティングするかに関するメモを寄せ集めたものです。体系的な説明にはなっていません
-   少しずつポスティング例を増やして行く中で、徐々に体系化できればと思っています
-   記事内のサンプルポスティングの勘定科目構造などは次節をみてください。


### 修正履歴 {#修正履歴}

-   ****2024/01/27 :**** 勘定科目構造を変更して、「経常費用」の「管理費」と「事業費」とも「人件費」と「その他経費」に二分し、「その他」の配下に具体的な経費勘定科目を置くようにしました[^fn:hiyo_keihi]。

[^fn:hiyo_keihi]: NPO法人会計ではトップレベル勘定科目のExpensesは「経常<span style="color: red">費用</span>」とされている一方、サブアカウント内では「その他<span style="color: red">経費</span>」となっています。とりあえずこれに沿うように修正しました。


### トップレベルの４勘定科目 {#トップレベルの４勘定科目}

NPO法人会計で使われる日本語の勘定科目名の内、最上位の4科目は図[1](#figure--top-level-accounts) のとおりです。

<a id="figure--top-level-accounts"></a>

{{< figure src="/top_level-AC.svg" caption="<span class=\"figure-number\">&#22259;1:  </span>勘定科目ツリーのトップレベル４勘定科目" width="45%" >}}


### 上の4勘定科目の配下にあるサブ科目構造 {#上の4勘定科目の配下にあるサブ科目構造}

記事内のポスティング例で使っているサブ科目の構造を紹介しておきます。


#### 経常費用（Expenses） {#経常費用-expenses}

{{< figure src="/cutdown-expenses-tree.svg" caption="<span class=\"figure-number\">&#22259;2:  </span>経常費用科目のサブ勘定科目" width="45%" >}}


#### 経常収益(Income) {#経常収益--income}

<a id="figure--income-tree"></a>

{{< figure src="/cutdown-income-tree.svg" caption="<span class=\"figure-number\">&#22259;3:  </span>経常収益科目のサブ勘定科目" width="53%" >}}


#### 資産（Assets） {#資産-assets}

<a id="figure--assets-tree"></a>

{{< figure src="/cutdown-assets-tree.svg" caption="<span class=\"figure-number\">&#22259;4:  </span>資産科目のサブ勘定科目" width="45%" >}}


#### 負債(Liabilities) {#負債--liabilities}

<a id="figure--liab-tree"></a>

{{< figure src="/cutdown-liab-tree.svg" caption="<span class=\"figure-number\">&#22259;5:  </span>負債科目のサブ勘定科目" width="45%" >}}


## ポスティング サンプル {#ポスティング-サンプル}


### 入会金と年会費の例 {#入会金と年会費の例}

****(1)**** 新入の東京太郎氏が正会員入会金と年会費を「ゆうちょ」に振り込んだ。<br />
東京太郎氏の会員番号（ID）は20210405。なお04/10のポスティング（図中の最下行）では、04/05とちがって資産勘定科目は単に「ゆうちょ」としか書いてありません。

「ゆうちょ」は後述([init-npo-datファイルの中身](#init-file-sample))のようにエリアス（別名）定義されていますので、「ゆうちょ」はLedgerによって `Assetes:流動資産:現金預金:ゆうちょ` に展開されます。

```text
2022/04/05 東京太郎
    ; ID: TT-20210405
    経常収益:受取入会金:正会員:2021           -10,000 JPY
    ゆうちょ

2022/04/10 東京太郎
    ; ID: TT-202104105
    経常収益:受取会費:正会員:2021             -6,000 JPY
    ゆうちょ
```

****(2)**** サポーター株式会社から賛助会員の年会費がUFJ銀行に振り込まれた

```text
2022/04/14 サポーター株式会社
    経常収益:受取会費:賛助会員:2021               -50,000 JPY
    資産:流動資産:現金預金:UFJ
```

****(3)**** 2021/03/15に 大阪花子氏が2022年（翌年度）の会費をUFJ銀行に前払いした

```text
2022/03/15 大阪花子
    ; 前受会費
    ; ID:20100515
    経常収益:受取会費:正会員:2022            -6,000 JPY
    資産:流動資産:現金預金:UFJ                 6,000 JPY
```

この例では
`経常収益` アカウント内の最下位科目として設定された ****会費の年度**** を使っています。こうしておけば、あえて `前受会費` を勘定科目化する必要はありません。ただし「前受会費」であることをコメントとしては書き込んであります[^footnote_comment]。

[^footnote_comment]: コメント欄内もLedgerによって検索・抽出して分析対象とすることができます。


### 受取補助金の例 {#受取補助金の例}

****(4)****  文科省から補助金が「ゆうちょ」に振り込まれた。

```text
2022/08/01 文部科学省
    経常収益:受取補助金:公開講演会補助金     -1,100,000 JPY
    ゆうちょ                               1,100,000 JPY
```


### 事業収入の例 {#事業収入の例}

****(5)**** 会誌の定期購読料が XYZ大学図書館からUFJ銀行に振り込まれた。<br />
`UFJ` もエリアス定義されています（[init-npo-datファイルの中身](#init-file-sample) 参照）。

```text
2022/01/31 XYZ大学図書館
    経常収益:事業収入:定期購読                -5,000 JPY
    UFJ
```

最下行のUFJトランザクションでは金額 `5,000 JPY` が省略されています。Ledgerでは1つのポスティング内のトランザクションは ****1つだけ**** 金額を省略できます[^footnote_zerosum]。

[^footnote_zerosum]: ポスティング内の全トランザクションの合計は必ずゼロになりますので、省略された金額はLedgerが補完してくれます。同じ数字を2回書く手間が省けます。

****(6)**** (一社)学術著作権協会　から著作物使用料金がゆうちょに振り込まれた。<br />
`yucho` もエリアスです。

```text
2022/12/20 (一社)学術著作権協会
    経常収益:事業収入:著作物使用料金          -24,529 JPY
    yucho
```

****(7)**** 2022/07/28に京都次郎氏から会誌の「著者負担金」がUFJ銀行に振り込まれた。

```text
2022/07/28 京都次郎
    ; ID: 19920601
    経常収益:事業収入:著者負担金               -50,000 JPY
    UFJ
```

****(8)**** 名古屋良子氏から論文の別刷り代金がUFJ銀行に振り込まれた

```text
2022/07/29 名古屋良子
    ; ID:                                   20150810
    経常収益:事業収入:別刷代                  -3,000 JPY
    UFJ
```


### 経常費用(Expenses）の例 {#経常費用expenses-の例}

****(9)**** 会誌印刷費を ㈱世界印刷に振り込んだ

```text
2022/09/15 ㈱世界印刷
    経常費用:事業費:その他経費:会誌印刷費     340,000 JPY
    ゆうちょ
```

****(10)**** 学術大会の講師謝金をゆうちょから新宿花子氏に振り込んだ。<br />
この例では簡単のために源泉税は転記していません（[後述します](#gensenzei)）。

```text
2022/10/15 新宿花子
    経常費用:事業費:その他経費:講師謝金       32,000 JPY
    yucho

2022/11/15 郵便局
    経常費用:管理費:その他経費:振込手数料        165 JPY
    yucho
```

****(11)****  ㈱業務委託社にゆうちょ口座から業務委託費を振込んだ

```text
2022/06/30  ㈱業務委託社
    経常費用:管理費:その他経費:業務委託費    450,000 JPY
    ゆうちょ
```

****(12)**** ㈱業務委託社にゆうちょ口座から理事会の会議費を振り込んだ

```text
2022/07/27 ㈱業務委託社
    経常費用:管理費:その他経費:会議費:理事会   2,520 JPY
    ゆうちょ                                  -2,520 JPY
```


### 源泉税の例 {#gensenzei}

****(13)**** 大会シンポジストの静岡三郎氏にゆうちょ口座から源泉税を天引した交通費を振り込んだ

```text
2022/12/15 静岡三郎
    ; 大会シンポジストに源泉税天引後の交通費振込
    経常費用:事業費:その他経費:交通費    ( 30,000 JPY -(floor( 30,000 JPY * 0.1021 )))
    経常費用:事業費:その他経費:租税公課:源泉税    (floor( 30,000 JPY * 0.1021 ))
    ;;経常費用:管理費:振込手数料                      165 JPY
    負債:未払源泉税              (floor( -30,000 JPY * 0.1021 ))
    ゆうちょ
```

金額欄で関数 `floor()` （＝小数点以下切捨て）が使われています。四捨五入は `round()` 、切り上げは `ceiling()` です。

****(14)**** 静岡三郎氏の源泉税をUFJ銀行から ABC税務署に振込んだ

```text
2022/12/25 ABC税務署
    ; 静岡三郎氏の源泉税納付
    負債:未払源泉税           (floor( 30,000 JPY * 0.1021 ))
    UFJ
```


### 立替金の例 {#立替金の例}

立替金は `資産:立替金` に収納します。

****(15)**** 2022/02/28に 相模原花子氏が支払った立替金を後日、学会のゆうちょ口座から振り込んだ。

```text
2022/02/28 相模原花子
    ; 会議用Zoom使用料金（立替）
    経常費用:事業費:その他経費:通信郵便費      2,200 JPY
    資産:立替金:H.Sagamihara                  -2,200 JPY

2022/03/30 相模原花子
    資産:立替金:H.Sagamihara                   2,200 JPY
    yucho                                     -2,200 JPY
```


### 未払金の例 {#未払金の例}

****(16)**** 年度末日において、㈱業務代行社への通信郵便費の未払い金がある場合のポスティング

```text
2022/03/31 ㈱事務代行社
    経常費用:管理費:その他経費:通信郵便費     55,232 JPY
    負債:未払金:㈱事務代行社                 -55,232 JPY
```


### 仮受金の例 {#仮受金の例}

****(17)**** 2019/07/01にナゾの振込が「ナゾフリコミ」さんから7,000円あった。調査不能のために当面、毎年度、期首振替する。

```text
2020/07/01=2022/04/01 ナゾノフリコミ
    ; 振込元について調査不能。毎年度期首振替
    負債:仮受金                               -7,000 JPY
    資産:流動資産:現金預金:ゆうちょ            7,000 JPY
```

****(18)**** 振込元が判明し返金する時のポスティング。 `負債:仮受金` に収納する。

```text
2022/10/10 ナゾノフリコミ
    負債:仮受金               7,000 JPY
    ゆうちょ                 -7,000 JPY
```


## クエリの例 {#クエリの例}

ごく基本的なクエリとその出力例を下に例示します。なお、どの例もクエリでは `--init-file` オプションをつけていますが、デフォルトのinit-file ( `$HOME/.ledgerrc` など)を使うときには、この指定は不要です(→ [~/.ledgerrcについて](#ledgerrc))。

****(1)**** すべてのポスティングを対象に、すべての勘定科目のバランスシートを表示する。<br />

クエリコマンドは次のとおりです。

`$ ledger bal --init-file init-blog.dat -f blog-npo.ledger --empty`

この例では、Ledgerのデフォルトのバランスシート フォーマットをそのまま使っていますので、金額欄が左列、勘定科目名が右列の表示形式となっています[^footnote_default-balance-fmt]。

[^footnote_default-balance-fmt]: これを逆にして勘定科目名を右列、金額を左列にするにはLedgerのデフォルトformat文の変更が必要です（→「[NPO法人会計に準拠した財務諸表をLedger-cliで書く](https://bred-in-bingo.netlify.app/posts/financial-statements-for-npo/)」）。

またledgerのオプションとして `--empty` を追加しているので、バランス（残高）がゼロの勘定科目（ `負債:仮受金` など）も表示されています。

<a id="figure--bal-all"></a>

{{< figure src="/npo-balance-example.png" caption="<span class=\"figure-number\">&#22259;6:  </span>基本4勘定科目のバランスレポート" width="80%" >}}

****(2)****  NPO法人会計風に ****資産**** と ****負債**** だけの「貸借対象表」を表示する<br />

{{< figure src="/assets-and-liab-bal.png" caption="<span class=\"figure-number\">&#22259;7:  </span>資産と負債のバランスレポート" width="80%" >}}

****(3)**** 正会員の会費だけを抽出してレジスターレポートを表示する。<br />
init-file指定が不要なら `$ ledger reg 正会員 and 会費` だけの入力で済みます。

{{< figure src="/正会員-regreport.png" width="110%" >}}


## Appendix: Ledger-cliの設定ファイル {#appendix-ledger-cliの設定ファイル}


### ~/.ledgerrcについて {#ledgerrc}

`.ledgerrc` は、
Ledger-cliのもっとも基本的な環境を設定するためのファイルです。デフォルトでは、次の順に探索されて使われます。

1.  `~/.config/ledger/ledgerrc`
2.  `~/.ledgerrc`
3.  `./.ledgerrc`

デフォルトの場所やファイル名を変更するには、Ledger起動時に
`$ ledger --init-file 'PATH/init-file.dat'` します。くわしくは[マニュアル](https://ledger-cli.org/doc/ledger3.html)を参照してください。


### init-npo-datファイルの中身 {#init-file-sample}

```text
--file ./npo-sample.ledger
--color
--check-payees
--date-format %Y/%m/%d
--pager /usr/bin/less
--sort date
;;--pedantic
;;--explicit
;;;;;;;;;;;;;;
;;  Aliases
;;;;;;;;;;;;;;
alias ゆうちょ=資産:流動資産:現金預金:ゆうちょ
alias yucho=資産:流動資産:現金預金:ゆうちょ
alias UFJ=資産:流動資産:現金預金:UFJ
alias ufj=資産:流動資産:現金預金:UFJ
　　：
＜これにならって好きなだけエリアスを追加できます＞
```


## Appendix:  NPO法人会計関係記事一覧 {#appendix-npo法人会計関係記事一覧}

(updated 2024/02/03)<br />
2024/02/02&nbsp;&nbsp;  [Ledger-cliによるNPO法人会計注記 -- 役員及びその近親者との取引](https://bred-in-bingo.netlify.app/posts/related-party-TXN-NPO.org)<br />
2024/01/29&nbsp;&nbsp;  [Ledger-cliでNPO法人会計の可視化 --- かんたん折れ線グラフ](https://bred-in-bingo.netlify.app/posts/VIS-npo-expns.org)<br />
2024/01/25&nbsp;&nbsp; 小規模学会のためのLedgerポスティング例 --- NPO法人会計基準に準拠しながら<br />
2024/01/21&nbsp;&nbsp;  [NPO法人会計に準拠した財務諸表をLedger-cliで書く](https://bred-in-bingo.netlify.app/posts/financial-statements-for-NPO/)


## Footnotes: {#footnotes}
