+++
title = "Ledger – Emacs内でレシート参照"
author = ["YAMAGAMI"]
date = 2021-05-13T00:00:00+09:00
tags = ["ledger", "accounting", "NPO"]
categories = ["comp"]
draft = false
+++

<div class="ox-hugo-toc toc">
<div></div>

<div class="heading">&#30446;&#27425;</div>

- [プライベートな家計では](#プライベートな家計では)
- [素朴な方法](#素朴な方法)
- [おすすめの方法](#おすすめの方法)
- [ちょっと脇道](#ちょっと脇道)
- [レシートのスキャニング](#レシートのスキャニング)
- [Acknowledgement](#acknowledgement)
- [Footnotes:](#footnotes)

</div>
<!--endtoc-->

いま **頭の体操** として
**NPO法人** の経理をLedger-cliでどこまでやれるかの検証に取り組んでいます。

今日の話題はそれと直接の関係はありませんが、
NPO法人のみならず多くの正式な会計報告では **領収書** はもっとも重要な証憑書類。かりに監督官庁からの保存・開示命令がなくても、担当事務部門としては、日常の仕事のクオリティとスピードを高めるために、デジタル化した **すべての領収書** をLedger内で閲覧できるようにしておくべきだと思います(注[^fn:1])。


## プライベートな家計では {#プライベートな家計では}

すべてのレシートをデジタルデータとして保存しておく意味はほとんどありません。しかし重要なレシートをデジタル保存しておいて、内容を随時チェックできるようにしておくことは **人生の質** （QOL）を高めます:wink:

ここではEmacsでLedger-cliを動かしている場合のやり方を説明します。

たとえば

> 春先にホームセンターで夏野菜などの苗を各種購入した

こんな場合、Ledgerからレシート画像が見えるようにしておくと、翌年 購入計画をたてるときに助かります。


## 素朴な方法 {#素朴な方法}

ソースコード[1](#code-snippet--soboku)がいちばん素朴で原始的な方法です。

<a id="code-snippet--soboku"></a>
```nil
2021/05/11 ジョイフルホンダ
    ; 税抜価格　キュウリ(@250x6), ナス(@250x3), ピーマン(@250x3), トマト(@250x7), バジル(@140x2)　
    Expenses:Farming:種・苗                     5,030 JPY
    Liabilities:Visa
```

<div class="src-block-caption">
  <span class="src-block-number"><a href="#code-snippet--soboku">ソースコード 1</a></span>:
  購入品目と単価x員数をコメントとして記帳
</div>

つまりレシートの内容をコメント `;` マークの後ろにテキストとして手入力しておく方法。これはこれでじゅうぶん役に立ちます。


## おすすめの方法 {#おすすめの方法}

レシートの画像ファイルをEmacsのLedgerモード内で直接見えるようにする方法です。トランザクションはソースコード[2](#code-snippet--osusume) のように書きます。

<a id="code-snippet--osusume"></a>
```nil
2021/05/11 ジョイフルホンダ
    ; Receipt: receipts/20210511_ジョイフルホンダ.jpg
    Expenses:Farming:種・苗                     5,030 JPY
    Liabilities:Visa
```

<div class="src-block-caption">
  <span class="src-block-number"><a href="#code-snippet--osusume">ソースコード 2</a></span>:
  メタタグとその値をつかったレシート指定
</div>

2行目にあるのが、
`Receipt` というメタ **タグ名** の宣言、そしてそのタグの **値** としての画像ファイル「パス名」と「ファイル名( `receipts/20210511_ジョイフルホンダ.jpg` )」です。

`receipts` ディレクトリはメインのLedgerファイルと同じディレクトリにありますので、パスの表記は **相対パス** にしています。


### Emacs内でレシート画像を見る方法 {#emacs内でレシート画像を見る方法}

上のソースコード[2](#code-snippet--osusume) のようなトランザクションを書いておけば、
**Emacsの中で** このレシート画像を表示できます。使うのはEmacsにビルトインされている `ffap-bindings` です。


#### init.elの設定 {#init-dot-elの設定}

次の1行を `.emacs.d/init.el` の適当な場所に追加します。

```emacs-lisp
(ffap-bindings)
```

設定はこれだけ。


#### 使い方 {#使い方}

カーソルをレシートファイル名の上に置いて **`C-x C-f`** します。ファイルが、書かれている通りに存在していればミニバッファにファイル名が表示されます(注[^fn:2])。
 `RET` でレシート画像がEmacsの新しいバッファ内に表示されます。

<a id="org94ac58a"></a>

{{< figure src="/ffap-sample.png" caption="&#22259;1:  Emacsでトランザクション内のレシート画像を表示。標準ではレシート画像はバッファ全体を使って表示されます。" width="90%" >}}

もとのバッファに戻るには **`C-x b`** (change buffer）です。なお、
`init.el` への追加が面倒なら `M-x ffap-bindings` するだけでもOK。


### 応用 {#応用}

このようにLedgerのメタタグの値としてファイルを指定する方法は、多様な経理環境でいろいろな応用可能性があります。

-   請求書ファイル(注[^fn:3])
-   銀行口座の取引状況ファイル
-   アルバイトから提出された作業報告書
-   etc ...

これらについては [Non-profit Accounting With Ledger CLI, A Tutorial](https://github.com/conservancy/npo-ledger-cli/blob/master/npo-ledger-cli-tutorial.md#documentation-tags)
が参考になります(注[^fn:4])。


## ちょっと脇道 {#ちょっと脇道}

図[1](#org94ac58a) のトランザクションはアカウントの **エリアス** （別名）が使われています。エリアスは
`~/.ledgerrc` 内で次のように設定されています(一部のみ抽出）。

```nil
alias toll=Expenses:Cars:Toll
alias orico=Liabilities:OricoCard
alias farming=Expenses:Farming
alias gas=Expenses:Cars:Gasoline
alias eneos=Liabilities:EneosCard
```

このように、よく使うアカウントは自分なりにわかりやすい別名を定義しておけば、記帳の時間が大幅に短縮できます。

NPO法人のアカウント名（= **勘定科目名** ）として内閣府が推奨しているものはとてつもなく文字数が多いです。一部だけをお見せしますと：

```nil
;; NPO法人「活動計算書」の勘定科目一覧
;; filename = npo-accounts.dat
経常利益
経常利益:受取会費
経常利益:受取会費:正会員受取会費
経常利益:受取会費:正会員受取会費:個人正会員受取会費
経常利益:受取会費:正会員受取会費:法人正会員受取会費
  :
```

これを手打ちで入力するのは **時間の無駄** です。タイプミスも誘発します。英数文字で数文字程度の覚えやすいエリアスを定義しておきましょう。


## レシートのスキャニング {#レシートのスキャニング}

一昔前なら、ちゃんとしたスキャナを使うのが正統派なのでしょうが、最近はスマホやタブレットの内蔵カメラを使うアプリがいろいろあります。どれも十分に実用域に到達しているので、どのアプリを選ぶかは個々人の **好み** でよいと思います。

むしろスマホやタブレットでスキャンするときの「 **脇役** 」をどう使うかがポイント。それについては「[紙書類のスキャンはもっぱらスマートフォンで行う俺](https://k-tai.watch.impress.co.jp/docs/column/stapa/1319297.html)」というサイトがとても参考になりました。

その他のちょっとした **小技** ですが、レシートはどうしても財布の中で変な **シワ** や **折り癖** ができます。シワを押さえつけるために、レシートをはさむクリアーホルダーを **高透明度** な製品(注[^fn:5])にしたら、作業がとても快適になります。レシートを平らにするためにガラス板を持ち歩くのは大変だけどクリアーホルダーなら気になりません:smile:


## Acknowledgement {#acknowledgement}

-   [Non-Profit Accounting With Ledger CLI, A Tutorial](https://github.com/conservancy/npo-ledger-cli/blob/master/npo-ledger-cli-tutorial.md#documentation-tags)
-   [NPO法人【活動計算書】の勘定科目一覧表](https://kanjo.biz/%E5%8B%98%E5%AE%9A%E7%A7%91%E7%9B%AE/npo%E6%B3%95%E4%BA%BA/%E6%B4%BB%E5%8B%95%E8%A8%88%E7%AE%97%E6%9B%B8) 経理Web


## Footnotes: {#footnotes}

[^fn:1]: 先進国では **政治資金** は全領収書の保存・公開が原則です。けど日本では「政党・政治資金団体・その他の政治団体」では **5万円以上** の経費のみに領収書が必添です[（出典）](https://www.soumu.go.jp/senkyo/seiji%5Fs/teishutsugimu.html)。本来ならば政治資金規正法を改正して、1円から領収書添付を義務付けるべきでしょうね。法改正されないなら、NPO法人も **政治団体** にした方が会計処理・経理が簡単かも :sunglasses:
[^fn:2]: もしディレクトリは存在するのに、指定されたファイルが存在しない場合には、ミニバッファにはディレクト名だけが表示されます。 `RET` すれば `dired` バッファが開きます。
[^fn:3]: (2021/05/14；追記) 書き忘れていました。:sweat: クレジットカード会社からの月々の請求明細書を「口座振替のトランザクション」内に **`; Invoice: invoices/visa/YYmmdd-visa.pdf`** のような形にしてリンクさせています。こうすると銀行から引き落とされる金額の根拠が一目で確認できます。
[^fn:4]: NPO法人を規制している法律は国によって異なっています。このサイトはとても参考になりますが、わが国の法律には合わない点が多々あります。
[^fn:5]: いま愛用しているのは「PLUS高透明クリアーホルダー」で型番はFL-188HOクリアー 89-178（A4版）です。