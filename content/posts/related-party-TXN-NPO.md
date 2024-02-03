+++
title = "Ledger-cliによるNPO法人会計注記 – 役員及びその近親者との取引"
author = ["YAMAGAMI"]
date = 2024-02-02T00:00:00+09:00
tags = ["ledger-cli", "NPO", "関連当事者", "注記"]
categories = ["comp"]
draft = false
+++

<div class="ox-hugo-toc toc">

<div class="heading">&#30446;&#27425;</div>

- [はじめに](#はじめに)
- [注記の様式例](#注記の様式例)
- [Ledgerのポスティング例](#ledgerのポスティング例)
- [注記作成に必要な情報の収集手順](#注記作成に必要な情報の収集手順)
- [今後の課題など](#今後の課題など)
- [Appendix: 通貨記号に「円」を使う](#yen_as_commodity)
- [Appendix: NPO法人会計関係記事一覧](#appendix-npo法人会計関係記事一覧)
- [Footnotes:](#footnotes)

</div>
<!--endtoc-->



## はじめに {#はじめに}

ここでは ****Ledger-cli**** を用いて ****NPO法人会計**** の

```text
役員及びその近親者との取引の内容
```

に関する ****注記**** をまとめる方法を紹介します。

なお、役員・近親者とは何かとか、「金銭的重要性の判断」などについては「[みんなで使おう！NPO法人会計基準  Q&amp;A 31-1](https://www.npokaikeikijun.jp/guideline/qa/q31-1/) 」など良い資料がたくさんあります。それらを参考にしてください。


## 注記の様式例 {#注記の様式例}

「役員及びその近親者との取引の内容」に関する注記は次のような様式で文章と表にすることが求められています。

```nil
○ 役員及びその近親者との取引の内容
役員及びその近親者との取引は以下のようになっています（単位：円）。
```

<a id="figure--tbl-1"></a>

{{< figure src="/npo/tbl-関係当事者chuki.png" caption="<span class=\"figure-number\">&#22259;1:  </span>役員及びその近親者との取引内容（引用 [役員及びその近親者との取引](https://www.npokaikeikijun.jp/wp-content/uploads/board.pdf)）" width="100%" >}}

このような注記を作成するために必要な情報は次の4点です。

1.  役員及びその近親者（以後「 <span style="color: red">関連当事者</span>」と略します）との取引の中で、注記が必要な勘定科目は何か
2.  それら勘定科目の、当期の<span style="color: red">総額</span>
3.  関連当事者の内で、「役員」との取引の金額（2.の内数）
4.  関連当事者の内で、「近親者及び支配法人等」との取引の金額（2.の内数）

Ledgerでこの4情報を取得できるように日々の転記を行っておくことが必要です。

具体的には、関連当事者の取引があった場合、関わったのが「役員」なのか、それとも「近親者及び支配法人等」なのかを何らかの形（後日、それをキーワードにしてデータを抽出し集計できる形）でLedgerデータ内に記録しておきます[^fn_motocho]。

[^fn_motocho]: ledgerの日本語訳は「元帳」です。ここで言う「Ledgerデータ内」は元帳内ですね。

いちばん簡単な方法は、Ledgerに備わっている ****<span style="color: red">タグ機能</span>**** を使うことでしょう。


## Ledgerのポスティング例 {#ledgerのポスティング例}

この章で取り上げる（1)から(5)までのポスティング例[^fn_shutten]のデータファイルは[こちら](../static/npo/TXN-関連当事者.ledger)からダウンロードできます。また
Ledger起動に必要なinit-fileは[こちら](../static/npo/init-related-party.dat)からダウンロードできます。

[^fn_shutten]: この例題は  <https://www.npokaikeikijun.jp/guideline/qa/q31-1/> などを参考にして一部改変して使わせて頂きました。ありがとうございました。

以下に順次、例を示します。

```nil
(1)  NPO法人の役員A氏が別途経営している会社（㈱ A's Companey）と
本NPO法人が業務委託契約をしており年間120万円の取引がありました。
```

```text
2022/04/10 ㈱ A's Companey
    ; 関連当事者: 役員: A
    経常費用:管理費:その他経費:業務委託    1,200,000 円
    資産:流動資産:現金預金:ゆうちょ       -1,200,000 円
```

-   第2行目の `;` セミコロンの後ろがタグです。
-   「関連当事者」という名前の ****タグ**** に、「役員」という ****値**** 、さらにその下に「A」という ****値**** を設定しています。
-   この記事内では、通貨記号として「 ****円**** 」を使っています。そのための設定は「 [Appendix: 通貨記号に「円」を使う](#yen_as_commodity)」 を見てください。

<!--listend-->

```nil
(2)  NPO法人役員の親族B氏から短期借入金が90万円あり、
期末でも同額が残っています。
```

```text
2022/04/20 B氏
    ; 関連当事者: 近親者: B
    負債:流動負債:短期借入金                -900,000 円
    資産:流動資産:現金預金:ゆうちょ          900,000 円
```

この取引はNPO法人会計的には「重要性が低い」取引に該当し、これ単体では注記は不要です。しかし期末までに他の科目などが合算されて100万円を超える可能性もあります。発生時にトランザクションに `関連当事者` タグを付けておく必要があります。

```nil
(3)  NPO法人役員のC氏から120万円で中古自動車を購入。
期末に30万円を原価償却して期末残高は90万円になりました。
```

```text
2022/04/20 C氏
    ; 関連当事者: 役員: C
    資産:固定資産:有形固定資産:車両        1,200,000 円
    資産:流動資産:現金預金:ゆうちょ       -1,200,000 円

2023/03/31 車両減価償却
    ; 関連当事者: 役員: C
    経常費用:管理費:その他経費:減価償却費:車両     300,000 円
    資産:固定資産:有形固定資産:車両         -300,000 円
```

```nil
(4)  NPO法人役員の親族D氏から使途指定・制約のない寄付金180万円を受けました。
```

```text
2022/05/10 D氏
    ; 関連当事者: 近親者: D
    経常収益:受取寄付金                    1,800,000 円
    資産:流動資産:現金預金:ゆうちょ
```

Ledgerではポスティング内のトランザクションの合計金額は<span style="color: red">ゼロ</span>になります。１ポスティング中の１トランザクションだけは値を書かなくてもLedgerが ****補完**** してくれます。ゆうちょのTXNに金額は書かなくても良いわけです。

```nil
(5)  NPO法人役員の親族E氏から使途指定・制約のない寄付 50万円を受けました。
```

```text
2022/05/20 E氏
    ; 関連当事者: 近親者: E
    経常収益:受取寄付金                       500,000 円
    資産:流動資産:現金預金:ゆうちょ
```


## 注記作成に必要な情報の収集手順 {#注記作成に必要な情報の収集手順}

この節ではLedgerのクエリ例を上げます。読みやすさのために、例では

-   init-file ( `--init-file ./init-related-party.dat` )
-   Ledgerデータファイル ( `-f ./TXN-関連当事者.ledger` )

のオプション指定を書いてありません。ledgerコマンドの結果を再現するには各ledgerクエリ例の後ろに、上の2つのオプションを追加して実行してください。

****(1)****  `%関連当事者` タグを指定してbalanceレポートを表示します。

```nil
$ ledger bal %関連当事者
```

-   タグ検索語には `%` を語の先頭につけます。Ledgerポスティングの中に、「関連」を含む他のタグが存在していなければ、「関連当事者」とフルで指定する必要はありません。

&nbsp;&nbsp;&nbsp;次のような出力になります。

<a id="figure--out-bal01"></a>

{{< figure src="/npo/out-bal01-relative.png" >}}

&nbsp;&nbsp;&nbsp;➡ `経常収益:受取寄付金` が230万円です。「重要性」が大きく内訳の調査が必要です。その他にも100万円を超える取引・科目があります（ `経常費用` （事務委託）など）。

****(2)**** `関連当事者` に関わる `受取寄付金` のトランザクションをregisterレポート表示して確認します。

```nil
$ ledger reg %関連 and 受取寄付金
```

<a id="figure--out-reg01"></a>

{{< figure src="/npo/out-reg02-relative.png" >}}

&nbsp;&nbsp;&nbsp; ➡ D氏の取引が100万以上なので注記に記述が必要です。

****(3)**** D氏は `関連当事者` ですが、「役員」なのか「役員の近親者」なのか判別出来ていませんので、それを確認します。

```nil
$ ledger print %関連当事者=D and 経常収益
```

&nbsp;&nbsp;&nbsp;printコマンドはクエリでヒットしたトランザクションをそのまま表示します。

<a id="figure--out-print01"></a>

{{< figure src="/npo/out-print01-relative.png" >}}

&nbsp;&nbsp;&nbsp; ➡D氏は関連当事者の内、近親者であることが確認できました[^fn_Mr.D]。

[^fn_Mr.D]: 2022/05/10のトランザクションの他にも、D氏とNPO法人との間に取引があるかどうかは<span class="inline-src language-sh" data-lang="sh">`$ ledger reg %関連=D`</span>で確認できる。

****(4)**** 以上から注記の中の `受取寄付金` は表[1](#table--tbl-2)のようになります。

<a id="table--tbl-2"></a>
<div class="table-caption">
  <span class="table-number"><a href="#table--tbl-2">&#34920; 1</a>:</span>
  注記中の受取寄付金に関する部分（単位:円）
</div>

| 科目          | 財務諸表に計上された金額 | 内、役員との取引 | 内、近親者及び支配法人等との取引 |
|:-----------:|:------------:|:--------:|:----------------:|
| (活動計算書) 受取寄付金 | 2,300,000    | 1,800,000 | 0                |

-   他の科目についても、これと同様な手順で必要な情報を収集します。
-   最終的には、それらをまとめて図[1](#figure--tbl-1)のような形にします。
-   その作業は、Ledgerで得られた情報を元に、NPO注記のために提供されているエクセルのテンプレートなどを使って <span style="color: red">手作業</span>で行います[^fn_tesagyo]。

[^fn_tesagyo]: この作表作業は ふつうは期末に年一回です。もしこの「役員及びその近親者取引」注記表が何十行もあるようなNOP法人なら自動化を考えても良いですが、そうでなければ手作業で十分だと思います。


## 今後の課題など {#今後の課題など}

-   まだ説明不足の点、説明したい点が多々あります。しかし、どんどん記事が長くなってきましたので、とりあえずこの辺でデプロイさせて頂きます。
-   当初は、他の注記（「使途制約のある寄付等」や「固定資産税増減」など）も一括して説明できると思っていましたが甘かったです&#128517;
-   この記事については少しずつ間違いの訂正や説明の追加を進めていきます。よろしくおねがいします。


## Appendix: 通貨記号に「円」を使う {#yen_as_commodity}

この記事内では、通貨記号として `JPY` ではなくて `円` を使っています。「円」を使う時には init-fileの中、またはLedgerファイルの冒頭部のどちらかに、次のように「円」と（ついでに）USD（米ドル）を宣言しておきます[^fn_other_places]。

[^fn_other_places]: 他には、 `configs/` ディレクトリの中に `commodities.dat` のようなデータファイルを作っておいて、init-fileまたはLedgerのデータファイルの中に `include configs/commodities.dat` などと書き込んでおく方法もあります。

```nil
commodities 円
commodities USD
```

そしてLedgerのTXNファイルの中に、円ドルの価格を `P 2024/01/31 円 0.00685 USD` のような形で、書き込んでおきます。下の例を見てください：

```text
commodities 円
commodities USD

P 2024/01/31 円 0.00685 USD

2024/01/31 成田空港
    Expenses:Lunch                              1,450 円
    Liabilities:Visa

2024/01/31 LAX
    Expenses:Lunch                              30.55 USD
    Liabilities:Visa

P 2024/02/01 円 0.00681 USD

2024/02/01 LA Toyota
    Expenses:Car                             4,500.00 USD
    Liabilities:Visa
```

これだけです。

Commoditiesについて何も指定しないでLedgerコマンドを打つと、Ledgerファイル内の通貨記号ついた金額がそのまま、つまりドルはドル、円は円で表示されます。ドル建ての取引を、その日の円ドル価格で円に換算した金額にして表示したければ、<span class="inline-src language-sh" data-lang="sh">`$ ledger reg -f commo-test.ledger --init-file init-tmp.dat --exchange 円`</span>のようにします。

{{< figure src="/npo/out-dollar-yen.png" caption="<span class=\"figure-number\">&#22259;2:  </span>ドルを円に換算したregisterレポート" width="100%" >}}

逆に全部をドルで表示したければ `--exchange USD` とします。 `--exchange` は `-X` と書くことができます。

インターナショナルに活動をしているヒトにはこの為替換算の機能は福音ですよね。

なお、commodityをヌルにする（使わない）ことはLedgerではできません。というか推奨されていません。commodityは単に通貨記号としてだけでなく、株価とか労働時間とかクルマの走行距離とか、いろいろなcommodityに対して文字通り ****汎用的**** に使われるからです。


## Appendix: NPO法人会計関係記事一覧 {#appendix-npo法人会計関係記事一覧}

(updated 2024/02/03)<br />
2024/02/02&nbsp;&nbsp; Ledger-cliによるNPO法人会計注記 -- 役員及びその近親者との取引<br />
2024/01/29&nbsp;&nbsp;  [Ledger-cliでNPO法人会計の可視化 --- かんたん折れ線グラフ](https://bred-in-bingo.netlify.app/posts/VIS-npo-expns.org)<br />
2024/01/25&nbsp;&nbsp; [小規模学会のためのLedgerポスティング例 --- NPO法人会計基準に準拠しながら](https://bred-in-bingo.netlify.app/posts/npo%E4%BC%9A%E8%A8%88/)<br />
2024/01/21&nbsp;&nbsp;  [NPO法人会計に準拠した財務諸表をLedger-cliで書く](https://bred-in-bingo.netlify.app/posts/financial-statements-for-NPO/)


## Footnotes: {#footnotes}
