+++
title = "小規模学会の経理をLedger-cliでやってみる – NPO法人会計基準に沿いながら"
author = ["YAMAGAMI"]
date = 2024-01-31T00:00:00+09:00
tags = ["Ledger-cli", "NPO", "会計"]
categories = ["comp"]
draft = false
+++

<div class="ox-hugo-toc toc">

<div class="heading">&#30446;&#27425;</div>

- [イントロダクション](#イントロダクション)
- [この記事について](#この記事について)
    - [事例は少しずつ増やしていきます](#事例は少しずつ増やしていきます)
    - [トップレベルの４勘定科目](#トップレベルの４勘定科目)
    - [Expenses（経常経費）勘定科目構造（例題用の短縮版）](#expenses-経常経費-勘定科目構造-例題用の短縮版)
    - [Income（経常収益）勘定科目構造（例題用の短縮版）](#income-経常収益-勘定科目構造-例題用の短縮版)
    - [Assets（資産）勘定科目構造（例題用の短縮版)](#assets-資産-勘定科目構造-例題用の短縮版)
    - [Liabilities（負債）勘定科目構造（例題用の短縮版)](#liabilities-負債-勘定科目構造-例題用の短縮版)
- [ポスティング サンプル](#ポスティング-サンプル)
    - [入会金と年会費の例](#入会金と年会費の例)
    - [受取補助金の例](#受取補助金の例)
    - [事業収入の例](#事業収入の例)
    - [Expenses(経常経費）の例](#expenses経常経費-の例)
    - [源泉税の例](#源泉税の例)
    - [立替金の例](#立替金の例)
    - [未払金の例](#未払金の例)
    - [仮受金の例](#仮受金の例)
- [Pros and Cons](#pros-and-cons)
    - [Pros](#pros)
    - [Cons](#cons)
- [（参考資料1） Ledger-cliの設定ファイル](#参考資料1-ledger-cliの設定ファイル)
    - [~/.ledgerrc](#ledgerrc)
    - [内容例](#内容例)
- [（参考資料2） 活動報告書、貸借対照表](#参考資料2-活動報告書-貸借対照表)
- [Footnotes:](#footnotes)

</div>
<!--endtoc-->



## イントロダクション {#イントロダクション}

ここでは

```text
会員数1,000名未満の小規模な学会をイメージしながら
NPO法人会計基準にそった形でLedger-cliを使って会計処理する方法を
具体的なledger-cliポスティングを例示しながら説明します。
```

NPO法人会計の体系的な説明や勘定科目構造などについてはネット上に良い資料がたくさんありますので、そちらを参照してください（「[NPO 法人会計基準ハンドブック](https://www.npokaikeikijun.jp/wp-content/uploads/handbook201202.pdf)」、「[「ＮＰＯ法人会計」の仕訳](https://www.ssdesign.co.jp/kaiN/kaiN_shiwake.pdf) 」など）。

****Ledger-cli**** はオープンソースの ****複式簿記**** 会計処理システムです。UNIXのコマンドラインベースで動き、元帳などすべてのデータはプレインテキストです。

Ledgerにはユニークで優れた特徴がたくさんありますが、その最たるものは、複式簿記のいわゆる ****貸方/借方**** （debit/credit）の概念をスルーできるということ[^footnote_see_manual]。

[^footnote_see_manual]: 詳細は[公式マニュアル](https://ledger-cli.org/docs.html)などをみてください。
<https://ledger-cli.org/docs.html>

これから Ledgerで経理処理を始めてみようという方は、下の図[1](#figure--from-gnucash) に書かれている4つの基本勘定科目（ `Income`, `Assets`, `Liabilities`, `Expenses` ）とそれらの間の相互関係を抑えておくだけでOKです。

<a id="figure--from-gnucash"></a>

{{< figure src="/basics_AccountRelationships.png" caption="<span class=\"figure-number\">&#22259;1:  </span>4つの基本勘定科目（accounts)    (出典： [GnuCash Tutorial and Concepts Guide](<https://gnucash-docs-rst.readthedocs.io/en/latest/guide/C/ch_basics.html>))" width="90%" >}}

あとは具体的なトランザクションの書き方、ポスティングの書き方の具体例を見ながら実際に使って見れば、複式簿記概念に基づく基本的な会計処理が可能になります。


## この記事について {#この記事について}

この記事は形式的には小規模学会の経理を例として使っていますが、一般的なNPO法人会計への適用または応用にもいくらか役立つと思います。


### 事例は少しずつ増やしていきます {#事例は少しずつ増やしていきます}

本日（2024/01/16）ここにデプロイした事例は ****最小限**** のものです。目に付いたトランザクションをどうポスティングするかのメモを寄せ集めたもので体系的な説明にはなっていません。

今後、少しずつポスティング例を増やして行く中で、徐々に体系化をはかっていこうと思います。


### トップレベルの４勘定科目 {#トップレベルの４勘定科目}

NPO法人会計で使われる日本語の勘定科目名の内、「資産（Assets）」と「負債（Liabilities）」は日本語訳のゆらぎはほとんどありませんが、
`Expenses` と `Income` の訳語が個人的にちょっとしっくりこないのでここでは、トップレベルの4勘定科目はとりあえず ****すべて英語のまま**** 使うことにします。

<a id="figure--top-level-accounts"></a>

{{< figure src="/top_level-AC.svg" caption="<span class=\"figure-number\">&#22259;2:  </span>勘定科目ツリーのトップレベル４科目。この記事内では英語を使います。" width="50%" >}}


### Expenses（経常経費）勘定科目構造（例題用の短縮版） {#expenses-経常経費-勘定科目構造-例題用の短縮版}

NPO法人の場合には `Expenses` は「事業費」direct cost(expenditure)と「管理費」overheads に大別されます。

{{< figure src="/cutdown-expenses-tree.svg" caption="<span class=\"figure-number\">&#22259;3:  </span>`Expenses` 科目内のサブ勘定科目(例題用の短縮版)" width="45%" >}}


### Income（経常収益）勘定科目構造（例題用の短縮版） {#income-経常収益-勘定科目構造-例題用の短縮版}

図[4](#figure--income-tree) はこの記事内のポスティング例で使用する `Income` 内のサブ勘定科目です。

<a id="figure--income-tree"></a>

{{< figure src="/cutdown-income-tree.svg" caption="<span class=\"figure-number\">&#22259;4:  </span>`Income` 科目内のサブ勘定科目（例題用の短縮版）" width="50%" >}}


### Assets（資産）勘定科目構造（例題用の短縮版) {#assets-資産-勘定科目構造-例題用の短縮版}

図[5](#figure--assets-tree) はこの記事内のポスティング例で使用する `Assets` 内のサブ勘定科目です。

<a id="figure--assets-tree"></a>

{{< figure src="/cutdown-assets-tree.svg" caption="<span class=\"figure-number\">&#22259;5:  </span>`Assets` 科目内のサブ勘定科目（例題用の短縮版）" width="35%" >}}


### Liabilities（負債）勘定科目構造（例題用の短縮版) {#liabilities-負債-勘定科目構造-例題用の短縮版}

図[6](#figure--liab-tree) は `Liabilities` 内のサブ勘定科目です。

<a id="figure--liab-tree"></a>

{{< figure src="/cutdown-liab-tree.svg" caption="<span class=\"figure-number\">&#22259;6:  </span>`Liabilities` 科目内のサブ勘定科目(例題用の短縮版)" width="35%" >}}


## ポスティング サンプル {#ポスティング-サンプル}


### 入会金と年会費の例 {#入会金と年会費の例}

(1) 2021/04/10に東京太郎氏が正会員の入会金と年会費を「ゆうちょ」に振り込んだ。<br />
東京太郎氏の会員番号（ID）は20220410。

```text
2021/04/10 東京太郎
   ; ID: 20210410
   Income:受取入会金:正会員:2021           -10,000 JPY
   Assets:現金預金:ゆうちょ                 10,000 JPY

2021/04/10 東京太郎
   ; ID: 20210410
   Income:受取会費:正会員:2022             -6,000 JPY
   Assets:現金預金:ゆうちょ                    6,000 JPY
```

(2) 2021/03/15に大阪花子氏が2022年（翌年度）の会費を「UFJ銀行」に前払いした。

```text
2021/03/15=2022/04/01 大阪花子
   ; 前受会費
   ; ID:20100515
   Income:受取会費:正会員:2022             -6,000 JPY
   Assets:現金預金:UFJ                    6,000 JPY
```

`Income` アカウント内の `2022` が翌年度になっていますので、あえて `前受け会費` を勘定科目化する必要はありません。


### 受取補助金の例 {#受取補助金の例}

(3) 文科省から補助金が「ゆうちょ」に振り込まれた。

```text
2021/10/01 文部科学省
   Income:受取補助金:公開講演会補助金     -1,100,000 JPY
   Assetes:現金預金:ゆうちょ                  1,100,000 JPY
```


### 事業収入の例 {#事業収入の例}

(4) 会誌の定期購読料が○○大学図書館から「UFJ」に振り込まれた。<br />
この例では `UFJ` は[~/.ledgerrc](#ledgerrc)で「Assets:現金預金:UFJ」とエリアス定義されています。

```text
2023/01/31 ○○大学図書館
    Income:事業収入:定期購読                -5,000 JPY
    UFJ
```

また第2行目のトランザクションの金額 `5,000 JPY` が省略されています。Ledgerではポスティング内のトランザクションは ****1つだけ**** 省略可能です[^footnote_zerosum]。

[^footnote_zerosum]: ポスティング内の全トランザクションの合計は必ずゼロになりますので、省略された金額はLedgerが補完してくれます。

(5) 「(一社)学術著作権協会」から著作物使用料金が「ゆうちょ」に振り込まれた。 `yucho` は同じくエリアスで内部的に「Assetes:現金預金:ゆうちょ」に展開されます。

```text
2023/03/27 (一社)学術著作権協会
    Income:事業収入:著作物使用料金          -24,529 JPY
    yucho
```

(6) 2022/07/28に京都次郎氏から会誌の「著者負担金」が振り込まれた。

```text
2022/07/28 京都次郎
          ; ID: 19920601
          Income:事業収入:著者負担金          -50,000 JPY
          SMBC
```

(7) 名古屋良子氏から別刷り代金が「SMBC」に振り込まれた。

```text
2022/07/29 名古屋良子
          ; ID:  20150810
          Income:事業収入:別刷代                   -3,000 JPY
          SMBC
```

(8) 学術大会の講師謝金を新宿花子氏の「ゆうちょ」口座に振り込んだ。この例では簡単のために源泉税は転記していません（後述します）。

```text
2022/12/15 新宿花子
    Expenses:事業費:講師謝金      32,000 JPY
    Expenses:事業費:振込手数料     165 JPY
    yucho      (-32,00 JPY - 165 JPY )
```


### Expenses(経常経費）の例 {#expenses経常経費-の例}

(9) ㈱業務委託社に理事会の会議費費用を振り込んだ。

```text
2022/07/27 ㈱業務委託社
    Expenses:管理費:会議費:理事会             2,520 JPY
    Assets:現金預金:ゆうちょ                    -2,520 JPY
```


### 源泉税の例 {#源泉税の例}

(10) 大会シンポジストの静岡三郎氏に源泉税を天引した交通費を振り込んだ。 `exp, liab` ともエリアスで、それぞれ `Expenses, Liabilites` に展開されます。 `ゆうちょ` もエリアス。

```text
2022/12/15 静岡三郎
    ; 大会シンポジストへの交通費
    exp:事業費:交通費                       32,921 JPY
    exp:雑費:振込手数料                       165 JPY
    liab:未払源泉税                         -3,361 JPY
    ゆうちょ                     (-29,560 JPY -165 JPY)
```

(11) 静岡三郎氏の源泉税を「○○税務署」に納付。

```text
2022/12/25 ○○税務署
    ; 静岡三郎氏の源泉税　納付
    Expenses:租税公課:源泉税                   3,361 JPY
    (Liabilities:未払源泉税)                   3,361 JPY
    Assets:現金預金:UFJ                           -3,361 JPY
```

ここで `（Liabilities:未払源泉税)` は ****仮想アカウント**** (virtual account)[^footnote_va]です。

[^footnote_va]: 仮想アカウントについては公式マニュアルなどをみてください。


### 立替金の例 {#立替金の例}

立替金は `資産:立替金` に収納します。

(12) 相模原花子氏が支払った立替金を後日、氏の「ゆうちょ」に振り込んだ。

```text
2022/02/28 相模原花子
    ; 会議用Zoom使用料金（立替）
    Expenses:管理費:通信費郵便費               2,200 JPY
    Assets:立替金:H.Sagamihara                -2,200 JPY

2022/03/30 相模原花子
    Assets:立替金:H.Sagamihara                 2,200 JPY
    yucho                                     -2,200 JPY
```


### 未払金の例 {#未払金の例}

(13) 年度末日において、業務委託先に通信郵便費の未払い金がある場合のポスティング

```text
2022/03/31 ㈱事務代行社
　 Expenses:管理費:通信郵便費        55,232 JPY
   Liabilities:未払金:㈱事務代行社    -55,232 JPY
```


### 仮受金の例 {#仮受金の例}

(14) 2019/07/01にナゾの振込が「ナゾフリコミ」さんから7,000円あった。調査不能のために当面、毎年度、期首振替する。

```text
2019/07/01=2022/04/01 ナゾノフリコミ
    ; 振込元について調査不能。毎年度期首振替
    Liabilities:仮受金                        -7,000 JPY
    Assets:現金預金:ゆうちょ                       7,000 JPY
```

(15) 振込元が判明し返金する時のポスティング。負債:仮受金に収納する。

```text
2023/10/10 ナゾノフリコミ
    Liabilities:仮受金               7,000 JPY
    Assets:現金預金:ゆうちょ            -7,000 JPY
```


## Pros and Cons {#pros-and-cons}


### Pros {#pros}

-   プレインテキストベースなので、勘定科目名や構造、金額、支払先名などを自由に変更できる。
-   会計事務を外部委託すると毎年の経理はやってくれるが、新しい観点での分析とか長期的なトレンド、将来の予測などを依頼することはむずかしい（もちろんお金に糸目をつけなければ何でもやってくれますが（笑））


### Cons {#cons}

-   日本語の入門書が見当たらない（英文のよい入門記事はたくさんありますが）


## （参考資料1） Ledger-cliの設定ファイル {#参考資料1-ledger-cliの設定ファイル}


### ~/.ledgerrc {#ledgerrc}

`.ledgerrc` は、
Ledger-cliのもっとも基本的な環境を設定するためのファイル。
Ledger-cliをインストールするとユーザのホームホーム ディレクトリに作成されます。このデフォルトの場所を変更するには、
\`$ ledger --init-file 'PATH/init-file.dat'\`します。くわしくはマニュアルを参照してください。

-   <https://github.com/yradunchev/ledger/blob/master/.ledgerrc>


### 内容例 {#内容例}

```text
--file ~/npo-ledger-dir/
--color
--check-payees
--date-format %Y/%m/%d
--pager /usr/bin/less
--sort date
--pedantic
--explicit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Aliases
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
aliase yucho=Assets:現金預金:ゆうちょ
aliase ufj=Assets:現金預金:UFJ
aliase smbc=Assets:現金預金:SMBC
　　：
＜これにならって好きなだけエリアスを追加できます＞
```


## （参考資料2） 活動報告書、貸借対照表 {#参考資料2-活動報告書-貸借対照表}


## Footnotes: {#footnotes}
