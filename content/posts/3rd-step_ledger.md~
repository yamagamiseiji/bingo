+++
title = "プレーンテキストファイルで「複式」家計簿（3）"
date = 2019-06-07T18:56:00+09:00
draft = false
+++

この（３）でも「その（２）」に引き続き、ちいさなTipsを備忘的に記します。


## Adjustmentsを使おう {#adjustment}

銀行からの口座残高のお知らせと自分のLedgerとの間で、残高が不一致となることは珍しくはありません。そんな時に、帳合を取るために使うのが **Adjustments** （調整）というトランザクションというか裏ワザ。

たとえば、銀行からの残高をチェックすると35,000円だったけど、ledgerでbalしたら、Bank bal = 45,000になっていた：

```shell
$ led b bank
	 45,000 JPY  Assets:Bank
```

こうした場合、銀行の残高が間違っている可能性はゼロなので、ledgerのトランザクションのどこかに、10,000円分の

-   数値のタイプミス
-   トランザクションの転記もれ

があるわけです。大量のトランザクションを見てそれを発見するのはとても大変です。そこで、とりあえず **Equity:Adjustments** というアカウントに収めることで、バランスを取ります：

```nil
05/17 * Adjustments
    Assets:bankA      = 35,000 JPY
    Equity:Adjustments
```

ポイントは金額の前に `=` を書くことだけ。こうすると、BankAの残高はいわば強制的に35,000円となります：

```shell
$ led b Adjustments
	  10,00 JPY  Equity:Adjustments
```

これで、当面は元帳内部はすっきりピッタリ帳合がとれます。その後、

-   じっくりと時間をかけてjournalを見直しエラーを見つけて、
-   $ led b Adjustmentsした時に 0 JPY になることを目指す

ということになります。

なお、 **Equity:Adjustments** を使えば、銀行口座の調整だけでなく、クレジットカードやnanacoやsuicaなどのカードの残高の帳合を簡単に合わせることができます。けれども家計簿では、銀行口座やクレジットカードはともかくとして、nanacoやsuicaの残高までピッタリ合わせる必要はありません。そのやり方は[こちら](#petty_cash)を見て下さい。


## 少額の現金の扱い {#petty_cash}

まずはnanacoにお金をチャージします：

```nil
2019/05/27 * nanacoチャージ
    Assets:nanacoCard
    Assets:Cash                                -2,000 JPY
```

そしてお昼ごはん：

```nil
2019/05/27 * セブンイレブン
    Expenses:Lunch                               698 JPY
    Assets:nanacoCard
```

チャージ時点でnanaco残高がゼロだったら、残高は1,302円になるはずですが、そんなことはめったにありません。今回は、1,469円になっていました。そこで、上に書いた[「調整](#adjustment)」をしておきます：

```nil
2019/05/27 * 調整 nanaco
    Assets:nanacoCard           = 1,469 JPY
    Equity:Adjustments
```

つぎの問題は、nanacoなどでの少額の支出をどう扱うかです。家計簿では、カードにチャージしたところまでを転記して、あとは知らんぷりするのが良策かと・・・。カードで何を買ったかまでは管理しないという感じですね。ただし、家計全般を考えて、どうしても記録していた方がよい物を購入した時、たとえば、お酒への出費をコントローする必要性がある場合（おぅ、これは良い例だ！）には：

```nil
2019/05/29  セブンイレブン
    Expenses:Drinks         2,500 JPY
    Assets:nanacoCard
```

などと書いておくって感じでしょうか。


## 利子・利息の転記方法 {#利子-利息の転記方法}

マイナス金利は国による民衆資産の窃盗（強盗？）という説があるそうですが、それにしても銀行にお金を預けているとスズメの涙レベルの利息がつきます。それを転記する方法：

```nil
2019/06/05  銀行口座への利息
	Assets:横浜銀行
	Income:利息		-34 JPY
```

他に例を見たことが無いので、Incomeにして良いのかどうか分かりませんが、結果的にはこれで辻褄は合います：

```nil
$ led b
	 100,034 JPY  Assets:横浜銀行
	-100,000 JPY  Equity:Opening Balances
	     -34 JPY  Income:利息
--------------------
		   0
```


## 定期的なトランザクションの書き方 {#定期的なトランザクションの書き方}

家計簿（会社の元帳でも？）同じようなトランザクションが繰り返し転記されます。毎月１回の支払いは、それだけを集めたテンプレートファイルを用意して、月初めにそれをLedgerファイルに読み込み、金額と日にちだけを修正追加できるようにしておくと良いそうです。これはなるほど！のアイデアですね。

しかし、２ヶ月に１回とか、年に１回とかのトランザクションはテンプレートにするほうが面倒です。そこで、用意されているのが **periodical transaction** です。具体的には、Ledgerファイルの先頭に、定期的トランザクションの定義を転記します。

次の例を見て下さい。これは **偶数月** に支給される年金（国民年金；NP）と（国家公務員年金;KKR）を定期的なトランザクションとして定義したものです（金額は仮想です）：

```nil
~ bimonthly from 2019/04/15
    Assets:みずほ銀行
    Income:年金:KKR                           40,000 JPY
    Income:年金:NP                            30,000 JPY
```

次の例は、２ヶ月に１回、 **奇数月** に引き落とされる管理費と上下水道代です：

```nil
~ bimonthly from 2019/03/21
    Expenses:管理費                           40,000 JPY
    Expenses:公共:上下水道                     3,500 JPY
    Assets:みずほ銀行
```

そして、３番目は年に１回の諸会費の例です：

```nil
~ yearly    from 2019/03/01
    Expenses:諸会費:JAF                        4,000 JPY
    Expenses:諸会費:JPS	                       8,000 JPY
    Liabilities:Visa
```


### レポートの表示 {#レポートの表示}

これらをLedgerファイルの先頭に書いておいて、次のようなコマンドを入力します。

-   IncomeとExpensesについて定期的（予算）のバランスをレポート：

<!--listend-->

```nil
$ led budget ^income ^expenses
```

-   上のようにbudgetを定義していても、単にbal/regでのレポートには反映されません。bal/regでbudget（定期・予算）定義を反映させるには次のようにします：

<!--listend-->

```nil
$ led bal --add-budget
```

-   より詳細なregレポートを表示するには：

<!--listend-->

```nil
$ led reg --add-budget
```

上のコマンドの結果の抜粋を示します：

```nil
　　　：
2019/04/01 Budget transaction    Assets:みずほ銀行         70,000 JPY   70,000 JPY
2019/04/01 Budget transaction    Income:年金:KKR          -40,000 JPY   30,000 JPY
2019/04/01 Budget transaction    Income:年金:NP           -30,000 JPY            0
2019/05/01 Budget transaction    Expenses:管理費          -40,000 JPY  -40,000 JPY
2019/05/01 Budget transaction    Expenses:公共:上下水道    -3,500 JPY  -43,500 JPY
2019/05/01 Budget transaction    Assets:みずほ銀行         43,500 JPY            0
2019/04/01 Budget transaction    Expenses:諸会費:JAF       -4,000 JPY   -4,000 JPY
2019/04/01 Budget transaction    Expenses:諸会費:JPS       -8,000 JPY  -12,000 JPY
2019/04/01 Budget transaction    Liabilities:Visa          12,000 JPY            0
2019/06/01 Budget transaction    Assets:みずほ銀行         70,000 JPY   70,000 JPY
2019/06/01 Budget transaction    Income:年金:KKR          -40,000 JPY   30,000 JPY
2019/06/01 Budget transaction    Income:年金:NP           -30,000 JPY            0
```

こんな感じです。定期的（予算）をこのように転記すると、日々の転記の工数が大幅に軽減されます。


## 几帳面？ {#几帳面}

これまで、子どもの頃のお小遣い帳、研究費の精算表などいろいろな帳簿をつけてきましたが、帳簿つけで一番大事なのは「継続性」と「即時性」。継続性は連続して長い年月、記録し続けるということ、「即時性」はお金が動いたとき（正確には「トランザクションが発生したとき」）、後回しにしないで、すぐに記帳することです。いずれも言うは易く行うは難しです。実際これまで、何度も痛い目に合いました。自分の性格がだらしなくて几帳面じゃあないからだと思っていました。

それで、「几帳面」と言うのは「帳面」をきちんとつけられることだと思っていましたが、どうやらそれは間違いで、「几帳」という「寝殿造りの間仕切り」の仕上げがとても丁寧だったことに由来するそうです。

<a id="org83f2ddc"></a>

{{< figure src="/kicho.jpg" caption="Figure 1: 几帳です。記帳ではありませんw" width="80%" >}}

それはさておき、Ledgerではプレーンテキストで複式簿記の原データが簡単に入力できます。このことによってボクは生まれて初めてストレスなく帳簿のデータ入力ができるようになりました。自分の性格に問題があって、そもそも帳簿や帳面をつけることに適性がなかったのではなくて、ボクの性分にあった入力方法と出会わなかったからだ、と今は思っています。


## Acknowledgment {#acknowledgment}

![](../static/pacioli.jpg) 　　  ![](../static/jWiegley.jpg)　　![](../static/Emacs-icon.png)