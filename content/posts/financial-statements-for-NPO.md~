+++
title = "NPO法人会計に準拠した財務諸表をLedger-cliで書く"
author = ["YAMAGAMI"]
date = 2024-01-21T00:00:00+09:00
tags = ["NPO", "Ledger-cli", "finance"]
categories = ["comp"]
draft = false
+++

<div class="ox-hugo-toc toc">

<div class="heading">&#30446;&#27425;</div>

- [サンプル出力](#サンプル出力)
    - [補足説明](#補足説明)
- [Ledger関係ファイルの配置](#ledger関係ファイルの配置)
    - [Ledger-dir配下のファイル](#ledger-dir配下のファイル)
        - [`financial-statements.sh`](#financial-statements-dot-sh)
        - [`sample-npo-data.ledger`](#sample-npo-data-dot-ledger)
    - [configsディレクトリ配下の設定ファイル](#configsディレクトリ配下の設定ファイル)
        - [`accounts-npo.dat`](#accounts-npo-dot-dat)
        - [`commodities-npo.dat`](#commodities-npo-dot-dat)
        - [`init-npo.dat`](#init-npo-dot-dat)
        - [`payees-npo.dat`](#payees-npo-dot-dat)
        - [`tags-npo.dat`](#tags-npo-dot-dat)
- [Tipsと今後の課題に関するメモ](#tipsと今後の課題に関するメモ)
- [Footnotes:](#footnotes)

</div>
<!--endtoc-->

ここでは:

```text
Ledger-cliを使ってNPO法人会計に準拠した「活動計算書」と「貸借対照表」を書いてみます
```

そのためのシェルスクリプト（ `financial-statements.sh` ）を紹介します。

****Ledger-cli**** はオープンソースの ****複式簿記**** 会計処理システムです。UNIXのコマンドラインベースで動き、元帳などすべてのデータはプレインテキストです。

Ledgerにはユニークで優れた特徴がたくさんありますが、その最たるものは、複式簿記のいわゆる ****貸方/借方**** （debit/credit）の概念をスルーできるということ[^footnote_see_manual]。

[^footnote_see_manual]: 詳細は[公式マニュアル](https://ledger-cli.org/docs.html)などをみてください。
<https://ledger-cli.org/docs.html>

これから Ledgerで経理処理を始めてみようという方は、下の図[1](#figure--from-gnucash) に書かれている4つの基本勘定科目（ `Income`, `Assets`, `Liabilities`, `Expenses` ）とそれらの間の相互関係を抑えておくだけでOKです。

<a id="figure--from-gnucash"></a>

{{< figure src="/basics_AccountRelationships.png" caption="<span class=\"figure-number\">&#22259;1:  </span>4つの基本勘定科目（accounts)    (出典： [GnuCash Tutorial and Concepts Guide](<https://gnucash-docs-rst.readthedocs.io/en/latest/guide/C/ch_basics.html>))" width="90%" >}}

あとはトランザクションの書き方、ポスティングの書き方の具体例を見ながら実際に使って見れば、複式簿記概念に基づく基本的な会計処理が可能になります。


## サンプル出力 {#サンプル出力}

さっそくですが、図[2](#figure--samplefig)は `financial-statements.sh` を起動したときに得られる出力例です。この計算の元となった仮想データは[こちら](https://bred-in-bingo.netlify.app/sample-npo-data.ledger)からダウンロードできます。

<a id="figure--samplefig"></a>

{{< figure src="/sample-leddger-out.svg" caption="<span class=\"figure-number\">&#22259;2:  </span>sammple output" width="70%" >}}


### 補足説明 {#補足説明}

-   上の２表では、金額がゼロの勘定科目は書かれていません。Ledgerのオプション `--empty` を効かせてあるからです。もし金額ゼロの科目も表に含めたいときには、このオプションを外します。
-   通貨記号 `JPY` を入れたままにしてありますが外すのは簡単です。

ちなみにサンプルデータのポスティング数は120ほどですが、この「活動計算書」と「貸借対照表」出力を得るために要した時間は 330msecです[^footnote_env]。

[^footnote_env]: 環境はThinkPad X230, Ubuntu 20.04 です。Ledgerのバージョンは 3.1.3-20190331。現在、スクリプトはまだ未整理なのでもう少し高速化できると思います。


## Ledger関係ファイルの配置 {#ledger関係ファイルの配置}

この記事では、Ledger関係のファイルが図[3](#figure--tree)のように配置されていることを前提としています。

<a id="figure--tree"></a>

{{< figure src="/tree-o-NPO-files.svg" caption="<span class=\"figure-number\">&#22259;3:  </span>Ledger　NPOのファイル構造" width="60%" >}}


### Ledger-dir配下のファイル {#ledger-dir配下のファイル}


#### `financial-statements.sh` {#financial-statements-dot-sh}

図[2](#figure--samplefig)を出力するためのスクリプト。まだできたばかりでベータ版ですが [こちら](https://bred-in-bingo.netlify.app/financial-statements.sh)からダウンロードできます。

-   Ledger-cliをインストールした後、関係ファイルを図[3](#figure--tree)のような形に配置し、Ledgerデータファイル（ `sample-npo-data.ledger` ）、それから `config/` ディレクトリ内にこの下に説明した５個のデータファイルを作成すれば動きます。


#### `sample-npo-data.ledger` {#sample-npo-data-dot-ledger}

これはこの記事のために作った架空のLedgerファイルです。
[こちら](https://bred-in-bingo.netlify.app/sample-npo-data.ledger) からダウンロードできます。

[[<https://bred-in-bingo.netlify.app/sample-npo-data.ledger>][こちら]


### configsディレクトリ配下の設定ファイル {#configsディレクトリ配下の設定ファイル}


#### `accounts-npo.dat` {#accounts-npo-dot-dat}

この設定ファイルには勘定科目（アカウント）がリストされています。内容は次のような形式です。これは[こちら](https://bred-in-bingo.netlify.app/accounts-npo.dat) からダウンロードできます。

```nil
;; 勘定科目構造   Time-stamp: <>

account Opening Balance
account Equity:Adjustments
;;;;;;;;;;;;;;;;;
;; I 経常収益の部
;;;;;;;;;;;;;;;;;
account 経常収益
	;;  I-1. 受取入会金
account 経常収益:受取入会金
account	経常収益:受取入会金:正会員受取入会金
account 経常収益:受取入会金:学生会員受取入会金
	;;  I-2. 受取会費
　：
```


#### `commodities-npo.dat` {#commodities-npo-dot-dat}

使用する通貨記号（など）が格納されています[^footnore_comm]。いまのところこれだけ：

```nil
commodity JPY
commodity USD
commodity EUR
commodity hour
```

[^footnote_comm]: 通貨記号だけでなく `hour` があるように、他にも多様な使い方があります。クルマの走行距離( `km` )なども便利に使っています。


#### `init-npo.dat` {#init-npo-dot-dat}

Ledgerの設定ファイルの中で一番重要なファイルです。デフォルトだと `$HOME/.ledgerrc` がinit-file になります。今回は `configs/` 配下に `init-npo.dat` という名前で保存しています。内容は次のようになっています：

```nil
--file  PATH/sample-npo-data.ledger
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
alias income=経常収益
alias expns=経常費用
alias assets=資産
alias liab=負債
alias cash=資産:流動資産:現金預金:現金
alias ufj=資産:流動資産:現金預金:UFJ
```

この中で大事なのは `--pedantic` , `--explicit` のふたつ。これを指定することでTXN内にタイプミスがあれば、Ledgerはエラーを出して処理を停止してくれます。エラーMSGが沢山でてくるのでドキッとしますが、元帳ledger内のタイプミスを完全に抑止するためにこの機能はとても有効です。

これを有効活用するためにはTXNで新しい勘定科目名、支払先、通貨記号などを使うときには `accounts.dat, payees.dat, commodities.dat` などのDBに追記することが必要です。その手間は、それ無しでタイプミスを元帳内で見つける作業の大変さに比べると ささやかなものです。


#### `payees-npo.dat` {#payees-npo-dot-dat}

TXNの日付の後ろに記述されている `payees` (支払先名)のリストです。

```nil
payee 相模原花子
payee 担当事務職
payee 岩波書店
payee いとうや
payee 東京太郎
payee ○○大学図書館
  :
```

このDBはLedgerではとても大事です。日々、数多くのTXNを書いていると、かならずタイプミスが起こります。とくにこの「支払先」名は綴りがちょっと違うだけで大きな問題になります。上で書いた `--pedantic, --explicit` オプションを忘れずに使いましょう。


#### `tags-npo.dat` {#tags-npo-dot-dat}

次のような内容のタグのリストが格納されます。

```nil
tag ID
tag 会員番号
tag Receipt
```

これの使い方はここでは省略します。すでに他のマイ記事もあります。


## Tipsと今後の課題に関するメモ {#tipsと今後の課題に関するメモ}

-   大急ぎで書いたコードなのであちこちツギハギです(恥)
-   シェルスクリプトで帳票の列揃えをするのはちょっと苦しいですが まぁこの程度ならなんとか付き合っていけますね（汗）
-   Ledgerのbalance-format部はデフォルトのformatを左右入れ替えただけです。書き方が微妙で理解しきっているわけではないので、もっと良い方法があるかと思います。
-   わが国のNPO法人会計で推奨されている勘定科目名の中には、ちょっと馴染みが無いものもあって、スクリプト内の変数名を決めるのがたいへんでした[^footnote_acnt_name]。

[^footnote_acnt_name]: NPO法人会計の勘定科目名には、たとえば「人件費」「その他経費」など同じ科目名が「事業費」にも「管理費」にも含まれるという構造になっています。こうした構造だと、Ledgerでのクエリの際に「事業費:人件費」などと上位カテゴリの科目名をつけることが必要になります。もし勘定科目名ツリーを構成する科目名がどのレベルでもユニークだったら、検索の際の文字入力数はずっと少なくて済みます。ま、そもそも一つずつの科目名をできるだけ短くしたいという意図で作られた科目名構造ではないので仕方ないかとは思いますが・・・。

-   あと「財務諸表」を２種の書類に分けるところ、特に「正味財産」のところでコードの行数をくって全体としてとてもアグリーuglyになりました。基本４勘定科目のバランスシートだけならコードは３分の１で済んだかなぁ（汗）
-   標準的な「勘定科目」からさらに深度の深い勘定科目を設定した方が、将来のデータ分析には便利なように思われます。そのときにはLedgerの `--depth` オプションの値を起動時に引数で渡すようにします。
-   このような財務諸表を ****書くだけ**** なら、エクセルとかネット上のサービスを使えば書けるのでしょうが、過去のデータを可視化したり今後のトレンドを予測したりするときにはLedgerの優位性は圧倒的です。次の記事では可視化例をアップしてみようと思います。
-   NPO法人会計に準拠した ****TXNの書き方**** の解説を先にデプロイすべきだったかも知れません。実は既に下書きはできていますが、まずは財務諸表をLedgerでなんとか書けることを紹介した方がよいだろうということで、急遽方針転換して、こちらを先にデプロイしました。あしからず・・・。
-   正味財産が負になると、金額の前に△ではなくマイナス符号がつきます[^footnote_minus]。

[^footnote_minus]: マイナス記号は他の勘定科目でもつくことがあります。たとえば誰かが立替払いした「立替金」も締め日までに精算していない場合には `立替金  -2,200 JPY` と表示されます。


## Footnotes: {#footnotes}
