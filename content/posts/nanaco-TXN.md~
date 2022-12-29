+++
title = "nanacoをLedger-cliで複式簿記トラッキング"
author = ["YAMAGAMI"]
date = 2022-12-29T00:00:00+09:00
tags = ["ledger-cli", "マイナポイント", "nanaco", "複式簿記", "電子マネー"]
categories = ["comp"]
draft = false
+++

## nanacoはトップランナー！ {#nanacoはトップランナー}

nanacoを知らないヒトはいませんよね。

「[リテールガイド](https://retailguide.tokubai.co.jp/trend/31578/)」によれば、nanacoの発行枚数は ****7,520万枚**** (2022/02現在）、nanaco利用な店舗数は956,000件（2022/06末現在）。

ボクも1枚持っています :smile:

<div align=left>
<img src="https://dl.dropboxusercontent.com/s/p1czmnknrzzmpm5/senior_nanaco.jpg" alt="" width="50%"><figure caption>図1. nanacoカード（シニア用）</figure>
</div>

コンビニなどで小銭入れの代わりに使えて本当に便利です。

国のマイナポイント事業のキャッシュレス決済サービスにもなりました。そこでnanacoをマイナポイント受取り口座にしてみました。


### nanacoで はまった:sweat: {#nanacoで-はまった-sweat}

nanacoは小銭レベルの少額プリペイドカードなので、仕組みは簡単素朴だと思ったのが間違いの始まり。nanacoのポイントとお金の動きをLedger-cliで ****複式簿記的**** にトラッキングしようとしてハマりました。

-   仕組みが思ったよりも複雑
-   ポイントと電子マネーの移動をリアルタイムに追跡できない[^fn:1]

いろいろ試行錯誤した結果、パーフェクトではありませんが、ようやく そこそこのレベルでnanacoのポイントと電子マネーをトラッキングできるようになりました。

ここではそれを紹介します。細かく解説的に書くと長くなりますので、この記事は複式簿記とLedger-cliについてある程度のリテラシーをお持ちの方をイメージターゲットにしています。


### 勘定科目（アカウント）設定 {#勘定科目-アカウント-設定}


#### nanacoポイントと電子マネーの構造 {#nanacoポイントと電子マネーの構造}

図2はnanacoアプリのスクリーンショットです。

<div align=left>
<img src="https://dl.dropboxusercontent.com/s/gki8ok3b385zzg6/%E4%BC%9A%E5%93%A1%E3%83%A1%E3%83%8B%E3%83%A5%E3%83%BCnanaco.jpg]]" alt="" width="60%">
<figure caption>図2. nanacoアプリのスクリーンショット</figure>

この図からnanacoは次の4つの要素から構成されていることが分かります。

1.  カード内　マネー残高
2.  カード内　ポイント残高
3.  センター預り内　マネー残高
4.  センター預か内　ポイント残高

上の構成要素を次の図3のように複式簿記の ****勘定科目**** にします。

<div align=left><img src="https://dl.dropboxusercontent.com/s/pkwva7kup1xp177/nanaco-AC-tree.png" alt="" width="60%"></div>
<figure caption>図3. nanaco関係の勘定科目樹状図</figure>

要するに nanacoの最上位の勘定科目（アカウント）は ****Assets**** (資産)、その下に ****e-money**** （電子マネー）[^fn:2]を置き、さらにその下にnanacoがあるという構造です。

ここで

-   `card` は「カード内」、 `center` は「センター預り内」です
-   `em` はElectoronic Money（電子マネー）、 `pts` はポイントです
-   nanaco内の勘定科目（アカウント）のコモディティ（通貨単位）は `card_em` （カード内電子マネー）だけが「日本円」 `JPY` です。あとのアカウントはすべて「ポイント」 `pts` にします
-   `JPY` と `pts` との交換率は1:1です(`C 1 JPY = 1 pts`)


#### 日本語でもOKです {#日本語でもokです}

こうした勘定科目（アカウント）の階層構造をLedger-cliでは半角コロン `:` で連結して

```nil
Assets:e-money:nanaco:card_em
```

のように記述します。もちろん これを日本語表記して

```nil
資産:電子マネー:ナナコ:カード内電子マネー
```

と書くこともできます。

記帳の時に毎回日本語変換キーを叩くのが面倒なので、ボクはアカウント名にはできるだけ日本語を使わないようにしています。単なる好みの問題です[^fn:3]。

さて とりあえずこれだけの勘定科目を用意すれば、nanacoのお金とポイントの流れをそれなりにトラッキングすることができます。下に例をあげます。


## nanacoのledger-cliトランザクション例 {#nanacoのledger-cliトランザクション例}

この例で記述しているのは、次のようなnanacoのポイントと電子マネーの流れ：

1.  最初に `Opening Balance` で nanaco各要素の勘定科目の初期値を宣言
2.  nanacoでマイナポイントを受け取り、それを電子マネーに交換
3.  nanaco電子マネーを使って買い物（セブンイレブンとマクドナルド）

<!--listend-->

```txt
account Assets:e_money:nanaco
account Expenses:Grocery
;
alias nanaco=Assets:e_money:nanaco
alias food=Expenses:Grocery
alias lunch=Expenses:Meals:Lunch
;;
2022/12/13 * Opening Balance
    nanaco:card_em                              1788 JPY
    Equity:Opening Balance
2022/12/13 * Opening Balance
    [nanaco:card_pts]                             38 pts
    Equity:Opening Balance
2022/12/13 * Opening Balance
    nanaco:center_em                               0 JPY
    Equity:Opening Balance
2022/12/13 * Opening Balance
    nanaco:center_pts                              0 pts
    Equity:Opening Balance

2022/12/13 * nanacoチャージ
    ; セブンイレブンのレジにてcard points を em へチャージ
    nanaco:card_em                                38 JPY
    [nanaco:card_pts]                            -38 pts

2022/12/15 * マイナポイント取得
    ; 付与されたポイント＝電子マネーをnancoセンター(預り)に収納
    Income:一時所得                          -15,000 JPY
    nanaco:center_pts                         15,000 pts

2022/11/02 * nanacoポイント交換
    ; nanacoセンター(預り)ポイントを nanacoマネーに交換
    nanaco:center_pts                        -10,000 pts
    nanaco:card_em                            10,000 JPY

2022/12/21 * セブンイレブン
    ; 税抜き支払額の 0.5% のポイント付与
    food                                        1862 JPY
    nanaco:card_em                             -1862 JPY
    (nanaco:card_pts)                              8 pts

2022/12/22 * マクドナルド
    ; 毎月10日 6:00AM に前月末までのポイントが付与される
	; 税込み!! 200円ごとに1ポイント
    lunch                                        850 JPY
    nanaco:card_em                              -850 JPY
    (nanaco:card_pts)                              4 pts ;[2023/01/10]
```


### 補足説明 {#補足説明}

-   トランザクションの冒頭2行の `account` 行で勘定科目を宣言しています。次の3行の `alias` 行は勘定科目のエリアス（短縮別名）を定義しています
-   トランザクション最下行の右端にある `;[2023/10/10]` はnanacoポイントが反映される日付けを記述しています[^fn:4]
-   ポイント更新のタイミングの詳細については[nanaco 使い方ページ](<https://www.nanaco-net.jp/how-to/save_point/shopping.html>)を参照してください


## クエリの例 {#クエリの例}

上のトランザクション（ `nanaco.ledger` ファイル) のあるディレクトリ内に、次のような内容のファイル（ `init.ledger` ）を置きます。その中でLedgerのデータファイル名などの基本情報を定義しています。

```txt
--file ./nanaco.ledger
--sort date
--effective
--date_format %Y/%m/%d
```

こうしておけば、そのディレクトリ内で、Ledger起動時に `--init-file init.ledger` のオプションだけを指定すれば済むようになります。


### nanacoのbalanceレポート {#nanacoのbalanceレポート}

balanceレポートでは `pts`, `JPY` のコモディティが並立して表記されます

```txt
$ led bal nanaco --init-file init.ledger
	   9,014 JPY
	   5,012 pts  Assets:e_money:nanaco
	   9,014 JPY    card_em
	      12 pts    card_pts
	   5,000 pts    center_pts
--------------------
	   9,014 JPY
	   5,012 pts
```


#### --exchange JPY オプション {#exchange-jpy-オプション}

コモディティ `pts` は `JPY` に換算して表記されます

```txt
$ led bal nanaco --init-file init.ledger --exchange JPY
	  14,026 JPY  Assets:e_money:nanaco
	   9,014 JPY    card_em
	      12 JPY    card_pts
	   5,000 JPY    center_pts
--------------------
	  14,026 JPY
```


#### ポイントのトラッキング {#ポイントのトラッキング}

nanacoのポイントだけをトラッキングしてレジスター表示

```nil
$ ledger reg nanaco and pts --init-file init.ledger
```

<div align=left>
<img src="https://dl.dropboxusercontent.com/s/7ykhhv9hnw24dh1/nanaco_and_pts.png" alt="" width="100%"></div>


#### 電子マネーのトラッキング {#電子マネーのトラッキング}

nanacoの電子マネーだけをトラッキングしてレジスター表示

```nil
$ ledger reg nanaco and _em --init-file init.ledger
```

<div align=center>
<img src="https://dl.dropboxusercontent.com/s/0bg4wz96bjk57dh/nanaco_and_em.png" alt="" width="100%"></div>


## まとめ {#まとめ}

nanacoカードに収納可能な金額は最大10万円ほどです。自分では普段は数千円ほどしか入れてません:sweat: nanacoは小銭入れ代わりに使うのが一番の使い方だと思います。

<span style="color: red">ポイントが溜まる</span>とか<span style="color: red">お得</span>とか言われますが、nanaco最大キャパの10万円を使っても、せいぜい500円ほどの「おまけ」がつくだけです[^fn:5]。

ボクのように数千円入っていれば安心というような使い方をしている人間に付与されるポイントはほんとうに微々たるものです。それを厳密にトラッキングする意味は家計・経理の面から言えばほとんど無意味です。

ここでは、敢えて複式簿記でnanaco内外のポイントとお金の動きをトラックしてみましたが、「やろうと思えばここまでは出来る」というほどの意味しか無いと思います:sunglasses:


### むしろ {#むしろ}

家計簿的には、nanacoを内部構造まで忠実に勘定科目化するのではなく、nanacoを単一の勘定科目にしておいて

-   nanaco内部はブラックボックスにして
-   そこから先の細かいリワードポイントなどは追跡・分析せず
-   コンビニでチャージした現金とか買い物の結果だけを記帳し（ポイントも記帳しない）
-   しばらく使って、溜まったポイントをチャージしたりした結果、nanaco内の電子マネーの誤差が蓄積してきたら
-   年に1回くらいの頻度でつぎのようなトランザクションを書いて ****調整**** する

という感じ。たとえばある日（2023/10/10)、nanacoの電子マネーが3,510円になっていることを確認したら：

```nil
2023/10/10 nanacoポイント調整
   Assets:e-money:nanaco                  =3,510 JPY
   Equity Adjustments
```

これだけでOKです。これがnanacoとの妥当な付き合い方かと思います。


## Footnotes: {#footnotes}

[^fn:1]: nanacoアプリだけではなく、スマホアプリならもうちょっとできそうですが、ボクのようにスマホを持たずガラケーとタブレットで暮らしている人間にはその恩恵は届きません。
[^fn:2]: ****e-money**** アカウント内にはnanacoの他に、ANA, Costco, Kuroneko, Orico, Suica などがぶら下がっています。
[^fn:3]: 単なる「好み」だけではなく、Ledger-cliではマルチバイト文字を使ったアカウント名にすると、レポートが ****列崩壊**** します。列崩壊を全面的に解消するのはとても大変です。どうしても列崩壊を避けたいときには、文字コードを「小手先でいぢくる」uglyな関数を介在させています:sweat:
[^fn:4]: これはLedger-cliの独特の書式で、 ****Effective/Aux date**** です。詳しくは[マニュアル](https://www.ledger-cli.org/3.0/doc/ledger3.html)を見てください。
[^fn:5]: nanacoは支払った金額のウチ、基本的には税抜きの金額だけがポイント付与のベースになってますし、ポイントがつかない商品やサービスもありますので、<span style="color: red">10万円で300円台のオマケ</span>と考えた方が良いかも知れません。
