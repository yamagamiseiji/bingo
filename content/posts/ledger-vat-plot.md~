+++
title = "消費税の取扱い"
author = ["YAMAGAMI"]
date = 2021-05-01T00:00:00+09:00
tags = ["accounting", "ledger", "gnuplot"]
categories = ["comp"]
draft = false
+++

## 消費税のレシート {#消費税のレシート}

わが国では小売レベルの値段札やレシートは「 **内税** 」が主流になりました。これはまさに政府の望むところ、内税にすれば国民に税負担を強く意識させずにお財布からお金を抜くことができます。

家計レベルでは消費税を含めて税金の額をきちんと計算する必要はありません。内税のまま記帳して消費金額に埋め込んでしまうのが普通でしょう。

しかし消費税以外の税金は家計レベルでも把握されていることが多いと思います。たとえば所得税や住民税、固定資産税、それから自動車関係の税金、酒税などは通年で合算するとかなりの金額になります。

消費税もきちんと計算して


## 消費税の把握 {#消費税の把握}

ここでは（「固定費」と同じように） **自動転記** (automated transaction)＋ **仮想アカウント** (virtual account)で消費税を算出します。

Ledgerファイルの(test.ledger)冒頭部に次の4行を追記しましょう。

```nil
= /^Expenses:Grocery:food/
    (Expenses:VAT)                   .07407407407407407407
= /^Expenses/ and not ( /food/ or /租税公課/ )
    (Expenses:VAT)                   .09090909090909090909
```

これはLedgerの **自動転記** （automated transaction）記法で書かれています。<br />
第１番目のトランザクションは次のような意味になります。

> 「これ以降のトランザクションにおいて、すべてのExpenses:Grocery:foodアカウントは、その支出額に .07407407407407407407 を乗じた金額を（Expenses:VAT)という仮想アカウントの支出として転記しなさい」

**.07407407407407407407** という数字にはコモディティ＝通貨記号がありません。これは0.08/1.08 の値、つまり内税で表示された金額を1.08で割って0.08を掛けた **定数** です。この定数をもとの金額に掛けなさい、という意味になります。

第2番めのトランザクションは、8%課税対象のfoodと租税公課 **以外** の支出アカウントでは消費税が10%になることをLedgerに教えています(注[^fn:1])。

日々のトランザクションを記帳するときには普通に「内税」ベースで書いて行きます。

```nil
account Expenses:VAT
account Expenses:Meals
account Expenses:衛生費
account Assets:Bank
account Assets:Cash
account Expenses:Grocery:Food
;;
= /^Expenses:Grocery:food/
    (Expenses:VAT)                  .07407407407407407407
= /^Expenses/ and not ( /food/ or /租税公課/ )
    (Expenses:VAT)                  .09090909090909090909
;;
2020/03/08 * カーディーラ
    Expenses:Cars                             47,300 JPY
    Assets:Cash

2020/03/08 * KFC
    Expenses:Meals                                638 JPY
    Assets:Bank

2020/03/08 * ヨーカドー
    Expenses:Grocery:food                        4,201 JPY
    Assets:Cash

2020/03/08 * ドラッグストア
    Expenses:衛生費　         (floor( 780 JPY * 1.10))
    Expenses:Grocery:food     (floor( 452 JPY * 1.08))
    Assets:Cash
```

クエリはつぎの通りです。

```sh
＜1. 税込みの支出総額を知りたい＞
$ led b ^expenses -f test.ledger
	  58,268 JPY  Expenses
	  47,300 JPY    Cars
	   4,689 JPY    Grocery:food
	     638 JPY    Meals
	   4,783 JPY    VAT
	     858 JPY    衛生費　
--------------------
	  58,268 JPY

＜2. 税抜きの支出総額を知りたい＞
$ led b ^expenses and not vat -f test.ledger
	  53,485 JPY  Expenses
	  47,300 JPY    Cars
	   4,689 JPY    Grocery:food
	     638 JPY    Meals
	     858 JPY    衛生費　
--------------------
	  53,485 JPY

＜3. 消費税の総額を知りたい＞
$ ledger bal vat -f test.ledger
	   4,783 JPY  Expenses:VAT

＜4. KFCの消費税を知りたい＞
$ ledger reg vat and @KFC -f test.ledger
2020/03/08 KFC                  (Expenses:VAT)               58 JPY       58 JPY
```

上の2. では、VATが仮想アカウントなので、 `and not vat` の代わりに
`--real` とか `--actual` とかしても結果は同じです。


## 自動転記+仮想アカウント {#自動転記-plus-仮想アカウント}

Ledgerファイルのトップに消費税の定義を書いておくだけで、トランザクションごとにいちいち消費税のエントリを書かなくても、全トランザクションについて仮想アカウントで税の金額を計算してくれる、これはほんとうに強力な機能です。

この機能は消費税計算だけでなく広い応用範囲があります。くわしくは（こちら）をご覧ください。


### ちょっと困ったことが {#ちょっと困ったことが}

これは自動転記の問題というよりも仮想アカウントの問題（または仕様？）かもしれませんが、上記の(Expenses:VAT)という仮想アカウントはaux-dateをrespectしてくれません。次のような水道料金のトランザクションで説明します。水道料金は毎月ではなくて2ヶ月分がまとめて徴収されます。

```nil
account Assets:Bank
account Expenses:VAT
account Expenses:水道
account Expenses:Grocery:Food
;;
= /^Expenses:Grocery:food/
    (Expenses:VAT)                  .07407407407407407407
= /^Expenses/ and not ( /food/ or /租税公課/ )
    (Expenses:VAT)                  .09090909090909090909
;;
2021/03/01 * 水道料金
    Expenses:水道               2,574 JPY ; [=2021/01/01]
    Expenses:水道               2,574 JPY ; [=2021/02/01]
    Assets:Bank
```

金額の右側にある `;[=2021/01/01]` はこれが1月徴収分であることを示しています。さてこのファイル(water.ledger)に対して次のようなクエリを発行すると次のようになります：

```nil
＜1. 実アカウント＝水道についてのクエリ  ==>  aux-date が表示されない＞
$ led r 水道 -f water.ledger
2021/03/01 水道料金   Expenses:水道             2,574 JPY    2,574 JPY
　　　　　　　　　　　　 Expenses:水道             2,574 JPY    5,148 JPY
＜2. 実アカウント＝水道についてのクエリ ==> effectiveが効いて aux-dateが表示される＞
$ led r 水道 -f water.ledger  --effective
2021/01/01 水道料金    Expenses:水道             2,574 JPY    2,574 JPY
2021/02/01 水道料金    Expenses:水道             2,574 JPY    5,148 JPY

＜3. 仮想アカウント＝VATについてのクエリ  ==>  aux-date が表示されない＞＞
$ led r vat -f water.ledger
2021/03/01 水道料金  (Expenses:VAT)              234 JPY      234 JPY
　                  (Expenses:VAT)              234 JPY      468 JPY
＜4. 仮想アカウント＝VATについてのクエリ  ==>  --effectiveは効かない＞
$ led r vat -f water.ledger --effective
2021/03/01 水道料金   (Expenses:VAT)              234 JPY      234 JPY
　　　　　　　　　　　　　(Expenses:VAT)              234 JPY      468 JPY
```

上の中で 2. だけが正解。つまり3月に支払った料金は1月、2月按分されたことが表示されています。それ以外はこの按分が表示されていません。

つまり2ヶ月分がまとめて請求される水道料金などに含まれる消費税が（総額はあっているのですが）2ヶ月に按分されて表現されません。これは結構困った問題です。たとえば毎月ごとの水道料金を調べると水道料金がゼロの月と2ヶ月分の月が交替して出てきます。

現在、いろいろ調べ得ていますが未だに解決方法はわかりません。


### なので {#なので}

aux-dateを使って支出を按分している場合には、automated TXNで仮想アカウントを使う方法は避けたほうが良いということになります。その代替としていまは `juzei_plotter` を用意して使っています。


## Footnotes: {#footnotes}

[^fn:1]: みなさんご存知の通り、ガソリン税や酒税やたばこ税は「税に税をかける」悪名高き **二重課税** になっています。しかし今の所、所得税や住民税には消費税はかかっていません。そのうちこれらに平気で「いけしゃーしゃー」と課税される日がきておかしくない国ですがねｗ