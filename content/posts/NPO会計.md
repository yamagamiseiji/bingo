+++
title = "Ledger-cliでNPO会計 – 小規模学会の経理例"
author = ["YAMAGAMI"]
date = 2024-01-14T00:00:00+09:00
tags = ["Ledger-cli", "NPO", "会計"]
categories = ["comp"]
draft = false
+++

## イントロダクション {#イントロダクション}

ここでは

-   Ledger-cliを使って1,000名未満の小規模な学会の会計・経理の一例
-   （ほぼ）NPO会計(出典)に準拠

Ledgerとは

-   Ledger-cliは複式簿記、フリー（無料）、プレインテキスト
-   Ledger-cliでは、複式簿記の ****貸方/借方**** （debit/credit）の概念はスルーしてかまいません[^fn:1]。下の図 [1](#figure--four-basic-accounts) に書かれている4つの基本勘定科目（Income, Assets, Liabilities, Expenses）とそのらの間の相互関係を抑えておくだけでOK[^fn:2]。

<a id="figure--four-basic-accounts"></a>

{{< figure src="/basics_AccountRelationships.png" caption="<span class=\"figure-number\">&#22259;1:  </span>4つの基本勘定科目（accounts)    (出典： [GnuCash Tutorial and Concepts Guide](<https://gnucash-docs-rst.readthedocs.io/en/latest/guide/C/ch_basics.html>))" width="90%" >}}

この記事の前提など

-   Ledger-cliの基本的なリテラシのある方がtarget readerです。
-   OSはlinux/windows/MacOS、なんでもOK。トランザクションを記述するためのテキストエディターも何でもOKだがEmacsがベスト。


## 勘定科目構造 {#勘定科目構造}


### トップレベルの４勘定科目 {#トップレベルの４勘定科目}

NPO会計でよく使われる日本語の勘定科目名ですが、

-   「資産」と「負債」は日本語訳のゆらぎはほとんど無いのでだいじょうぶですが
-   ExpensesとIncomeの訳語が個人的にちょっとしっくりこないので

とりあえずトップの4科目は英語のまま使うことこします。

{{< figure src="/top_level-AC.svg" caption="<span class=\"figure-number\">&#22259;2:  </span>勘定科目ツリーのトップレベル４科目" width="50%" >}}

この4勘定科目の関係図


## 経常収益(Income)勘定科目表（簡易版） {#経常収益--income--勘定科目表-簡易版}

{{< figure src="/cutdown-経常収益-tree.svg" caption="<span class=\"figure-number\">&#22259;3:  </span>経常収益（簡易版）" width="50%" >}}


## 資産（Assets）勘定科目表（簡易版) {#資産-assets-勘定科目表-簡易版}

{{< figure src="/cutdown-資産-tree.svg" caption="<span class=\"figure-number\">&#22259;4:  </span>資産（簡易版）" width="35%" >}}


### TXNサンプル {#txnサンプル}


#### 入会金と年会費のTXN例 {#入会金と年会費のtxn例}

(1) 2021/04/10に東京太郎氏が正会員の入会金と年会費を「ゆうちょ」に振り込んだ。東京太郎氏の会員番号（ID）は20220410。

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


#### 受取補助金のTXN例 {#受取補助金のtxn例}

(3) 文科省から補助金が「ゆうちょ」に振り込まれた。

```text
2021/10/01 文部科学省
   Income:受取補助金:公開講演会補助金     -1,100,000 JPY
   Assetes:現金預金:ゆうちょ                  1,100,000 JPY
```


#### 事業収入のTXN例 {#事業収入のtxn例}

(4) 会誌の定期購読料が○○大学図書館から「UFJ」に振り込まれた。

```text
2023/01/31 ○○大学図書館
    Income:事業収入:定期購読                -5,000 JPY
    UFJ
```

(5) 「(一社)学術著作権協会」から著作物使用料金が「ゆうちょ」に振り込まれた。

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


## 経常経費 Expenses {#経常経費-expenses}

事業費 direct cost(expenditure)と管理費 overheads に大別される。

{{< figure src="/cutdown-経常経費-tree.svg" caption="<span class=\"figure-number\">&#22259;5:  </span>経常経費の勘定科目構造" width="45%" >}}

団体の設立目的・本来業務である研究・学術に直接関係した事業に要する経費を事業費とする。(NPO法人の場合）

```text
eg. 事業を遂行するために支出した人件費、売上原価（仕入れや制作費）、チラシやポスターの印刷、講師への謝金、会場の賃貸料、特定事業の寄付金の募集のためのファンドレイジング（資金調達）費等、明らかに事業に関する経費として特定できる金額
```

法人を維持しその事業を管理することに要する経費を管理費 overheads
とする。

```text
eg. 総会および理事会の開催運営費、管理部門に係る役職員の人件費、管理部門に係る事務所の賃貸料および水道光熱費等
```


### 経常経費:事業費 {#事業費}


## TXN例 {#txn例}

(8) 新宿花子氏に学術大会の講師謝金を「ゆうちょ」に振り込んだ。この例では簡単のために源泉税は転記していない（後述する）

```text
2022/12/15 新宿花子
    Expenses:事業費:講師謝金      32,000 JPY
    Expenses:事業費:振込手数料     165 JPY
    yucho      (-32,00 JPY - 165 JPY )
```


### 経常経費:管理費 {#経常経費-管理費}

(9) ㈱業務委託社に理事会の会議費費用を振り込んだ。

```text
2022/07/27 ㈱業務委託社
    Expenses:管理費:会議費:理事会             2,520 JPY
    Assets:現金預金:ゆうちょ                    -2,520 JPY
```


## 負債 Liabilities {#負債-liabilities}

{{< figure src="/cutdown-負債-tree.svg" caption="<span class=\"figure-number\">&#22259;6:  </span>負債の勘定科目構造" width="30%" >}}


#### 源泉税の書き方例 {#源泉税の書き方例}

(10) 大会シンポジストの静岡三郎氏に源泉税を天引した交通費を振り込んだ。

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

ここで、 `（Liabilities:未払源泉税)` は仮想アカウント(virtual account)


#### 立替金 {#立替金}

立替金は `資産:立替金` に収納する。

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


#### 未払金 {#未払金}

(13) 年度末日において、業務委託先に通信郵便費の未払い金がある場合のトランザクション

```text
2022/03/31 ㈱事務代行社
　 Expenses:管理費:通信郵便費        55,232 JPY
   Liabilities:未払金:㈱事務代行社    -55,232 JPY
```


#### 仮受金 {#仮受金}

(14) 2019/07/01にナゾの振込が「ナゾフリコミ」さんから7,000円あった。調査不能のために当面、毎年度、期首振替する

```text
2019/07/01=2022/04/01 ナゾノフリコミ
    ; 振込元について調査不能。毎年度期首振替
    Liabilities:仮受金                        -7,000 JPY
    Assets:現金預金:ゆうちょ                       7,000 JPY
```

(15) 振込元が判明し返金する時のトランザクション。負債:仮受金に収納する。

```text
2023/10/10 ナゾノフリコミ
    Liabilities:仮受金               7,000 JPY
    Assets:現金預金:ゆうちょ            -7,000 JPY
```


## ちょっとした小技 {#ちょっとした小技}


### 領収書等の帳票の扱い {#領収書等の帳票の扱い}

Emacs内で、請求書や領収書などをin-line表示することができる。

```text
2022/07/15=2022/08/10 ㈱事務代行社
    ; 請求書: invoice/㈱事務代行社/20220715_事務代行社.pdf
    ; 領収書: receipt/㈱事務代行社/20220810_事務代行社.pdf
    Expenses:管理費:業務委託費           450,000 JPY
    ゆうちょ                            -450,000 JPY
```

請求書の日付が07/15、振込の日付が08/10などのように使い分けることができる。

書類をin-line表示するには、Emacs内で領収書の行にカーソルを乗せC-x
C-y。ミニバッファに
receiptディレクトリ配下にあるPDFファイルが表示されるので、Enterを叩くとEmacsバッファに領収書が表示される。元の画面に戻るにはC-x
b。ミニバッファに元のバッファが表示されるので、Enter。


### Ledgerの初期設定ファイル {#ledgerの初期設定ファイル}


#### ~/.ledgerrc {#ledgerrc}

-   <https://github.com/yradunchev/ledger/blob/master/.ledgerrc>
-   デフォルトの場所は
    ~/.\`　ledgerをインストールするとホームDIRに作成される。
-   場所を変えるときには、\`ledger --init-file 'PATH/init-file.dat'\`
    か、もしくは...
-   内容例:
    ```text
    --file ~/npo-ledger-dir/
    --color
    --check-payees
    --date-format %Y/%m/%d
    --pager /usr/bin/less
    --price-db ~/.prices.db
    --sort date
    ;--strict
    ;--explicit
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;  Aliases
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    yucho=Assets:現金預金:ゆうちょ
    ufj=Assets:現金預金:UFJ
    smbc=Assets:現金預金:SMBC
    　　：
    ```


#### ~/ledger-schedule.ledger {#ledger-schedule-dot-ledger}

-   see manual


#### payees.dat, accounts.dat tags.dat {#payees-dot-dat-accounts-dot-dat-tags-dot-dat}

```text
include ~/local-ledger-directory/configs/accounts.dat
include ~/local-ledger-directory/configs/payees.dat
include ~/local-ledger-directory/configs/tags.dat
```


## Pros and Cons（後ほど文末に移動する） {#pros-and-cons-後ほど文末に移動する}

-   事務を委託すると毎年の経理はやってくれるが、新しい観点での分析とか長期的なトレンド、将来の予測などは無理（金を積めばなんでもやる）


## Appendix （資料） {#appendix-資料}


### 勘定科目の詳細例 {#勘定科目の詳細例}


#### 経常費用(Expenses) {#経常費用--expenses}

{{< figure src="/expenses_tree.svg" caption="<span class=\"figure-number\">&#22259;7:  </span>Expenses" width="60%" >}}


#### 負債(Liabilities) {#負債--liabilities}

{{< figure src="/liabilities_tree.svg" caption="<span class=\"figure-number\">&#22259;8:  </span>Liabilities" width="60%" >}}


#### 経常収益(Income) {#経常収益--income}

{{< figure src="/income_tree.svg" caption="<span class=\"figure-number\">&#22259;9:  </span>Income" width="60%" >}}


#### 資産(Assets) {#資産--assets}

{{< figure src="/assets_tree.svg" caption="<span class=\"figure-number\">&#22259;10:  </span>Assets" width="60%" >}}

[^fn:1]: Ledger-cliでは、貸方/借方という考え方はまったく使わずに済ませることができます。
[^fn:2]: 会計・経理分野の英単語を日本語に直そうとすると、一つの英単語にいくつもの日本語訳候補があって、どれが正解かよく分からないことがあります。会計・経理の世界の中の細分化あれた分野によって、慣習として使われる日本語が違うらしいです。仕方ないので図[1](#figure--four-basic-accounts)の中では英語のままにしておきました。
