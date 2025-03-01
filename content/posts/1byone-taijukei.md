+++
title = "CSVデータをエクスポートできる家庭用体組成計 – １byone smart scale"
author = ["YAMAGAMI"]
date = 2025-03-02T00:00:00+09:00
tags = ["health", "bash", "weight"]
categories = ["comp"]
draft = false
+++

<div class="ox-hugo-toc toc">

<div class="heading">&#30446;&#27425;</div>

- [1byone smart scale って何？](#1byone-smart-scale-って何)
    - [一番の売りはCSVエクスポート！](#一番の売りはcsvエクスポート)
- [1byoneによるCSVデータの取得方法](#1byoneによるcsvデータの取得方法)
- [CSVデータを使った応用例](#csvデータを使った応用例)
- [まとめ](#まとめ)
- [参考資料](#参考資料)
- [Footnotes:](#footnotes)

</div>
<!--endtoc-->

~~【お知らせ】2025/02/24に Android版の1byone health アプリが ver 3.0.2 にバージョンアップされました。2025/02/28 現在、新バージョンでどうやってCSV データをエクスポートするのか良く分かりません。とりあえず一つ前のバージョン ver 2.3.1に戻して使用中です。~~

<span style="color: red"> 【お知らせ】2025/03/02：バージョン 3.0.2 のCSVエクスポート法が分かりました。「設定」の場所が変わってホーム画面最下行の右下です。そこをタップすれば、旧バージョンと同じような方法＝以下の記事と同じ方法でCSVがメールで届きます。</span>

2024年夏、定期検診の時に看護師さんに体重を聞かれました。

「最近は測っていませんが、大体65kgです」<br />
というと、体重は ****毎日**** 測定するものですよと言われました。

自宅には 2018年9月に購入した体重計・体組成計 ****1byone smart scale**** があります。ちょっと古いけど家内はほぼ毎日使っています。わたしも購入時にユーザ登録してあります。<br />
ということで、2024年夏から毎日体重を測ることにしました。


## 1byone smart scale って何？ {#1byone-smart-scale-って何}

購入当時からつい最近まで、他の会社の体組成計に比べると価格はかなりリーズナブルな製品でした[^fn:1]。

その割に（と言っては失礼ですが）なかなか高性能。

-   1byoneのアプリ（家内はiOS、わたしはAndroid）をインストールするとブルートゥースでデータの記録ができます
-   測定項目は次の ****13項目**** ：体重, 内臓脂肪レベル, BMI, 体脂肪率, 体内水分率, 筋肉量, 骨量, 基礎代謝量
-   ****CSVでデータをエクスポートできる****&nbsp;[^fn:2]
-   測定精度もなかなか良い。たとえば[Garmin S2と比べたサイト](https://note.com/naokishoji/n/n35c9e894a9ea)でみるとほぼ遜色ありません
-   Apple Health、Fibit、Google Fit, Garmin connect などと連携できる
-   アンドロイドのアプリの出来もなかなか良い


### 一番の売りはCSVエクスポート！ {#一番の売りはcsvエクスポート}

数千円の体組成計でCSVエクスポートできるのは本当にすばらしい。最近の安価な製品でCSVエクスポートできるものがあるかどうか、 ****chatGPT**** に次のような質問をしてみました：

```text
・10,000円未満（できるだけ安価なのが希望です）
・Apple, Andorid端末にブルートゥースでデータ転送できるアプリがある
・CSVエクスポートができる
・Garminと連携できる
・次のような測定項目が（完全ではなくても）ほぼ含まれている：体重, 内臓脂肪レベル, BMI, 体脂肪率, 体内水分率, 筋肉量, 骨量, 基礎代謝量
・日本国内の一般的な通販サイトで入手できる
```

その結果、次のような製品名の回答がありました。

-   Anker Eufy Smart Scale P3
-   オムロン 体重体組成計 HBF-230T
-   Garmin Index S2
-   タニタ 体組成計 BC-771
-   INSMART 体組成計 CF598

しかしchatGPTの結論は：

```text
ご要望のすべての条件を満たす製品は見つかりませんでしたが、
上記の製品が一部の条件に合致しています。
```

つまり10,000円以下の家庭用体組成計の中には、CSVエクスポートできる製品は現時点では無いということでした。


## 1byoneによるCSVデータの取得方法 {#1byoneによるcsvデータの取得方法}

そこでAndroid端末で、1byoneを使ってCSVデータを取得する方法を紹介しておきます。あらかじめアプリ `1byoOne Health` を自端末にインストールしておきます。

{{< figure src="/1byone-icon.png" caption="<span class=\"figure-number\">&#22259;1:  </span>1byOne Health アプリアイコン（Andoid）" width="10%" >}}

1.  準備として、「ホーム」-&gt;「設定」--&gt;「データのアップロード」--&gt;「はい」をやっておく（最新のデータをエクスポートするにはこれが必須）。
2.  `1byOne Health` を起動し、HOME画面の右上にある「 ****➕**** 」マークをクリック
3.  「データのエクスポート」をクリック
4.  データのエクスポート画面で「開始時間」と「終了時間」を指定し、画面右上の「エクスポート」をクリック
5.  「エクスポートしますか？データはメールボックスに送信されます」というメッセージが表示される
6.  「はい」をクリック
7.  メールボックスに `From: [help]  Subject: Download Body Fat Scale Data` メールが届く。時々、届くまでに数分の遅延がある。たまにメールが届かないことがある。その時は以下のメール文の通りAPPからエクスポートし直してみると届く&#128517;

    <div class="txt">

    Hello！ Please kindly click the link below to download your Body data within 24 hours．Download My Data&gt;&gt; (If the link is invalid, please export your data in APP again.)

    </div>
8.  上の文面中、 <span style="color: red">Download My Data</span> は赤字でリンクになっているのでクリック
9.  Androidのファイルマネージャから「ダウンロード」をクリックすると `BodyFatScale20240922052739.csv` のような名前のデータファイルができている。または、PCからメールを開くと直接PCの `~/ダウンロード/` に入るので、こっちの方が便利
10. メールが届かない時はもう一度、上の手順を繰り返す。
11. CSVデータの冒頭4行は次のとおり（１行目はヘッダー）

    <div class="txt">

    Time,Weight,Weight Unit,BMI,Body Fat(%),Muscle Mass,VisceralFat,Body Water(%),Bone Mass,BMR,Body Type,body Score,Protein Rate,Skeletal Muscle Rate,Subcutaneous Fat,Lean Body Mass,Note<br />
    2024-09-22 08:10:16,63.3,kg,21.2,16.3,48.5,13.0,55.4,2.6,1014.0,Average,91,16.8,45.2,12.9,53.0,<br />
    2024-09-21 07:28:08,63.7,kg,21.3,16.6,48.6,13.0,55.1,2.6,1020.0,Average,91,16.7,45.0,13.1,53.1,<br />
    2024-09-20 07:59:52,63.7,kg,21.3,16.7,48.6,13.0,55.1,2.6,1020.0,Average,91,16.7,45.0,13.1,53.1, <br />
    ：

    </div>


## CSVデータを使った応用例 {#csvデータを使った応用例}

日々の体重の折れ線（青）に7日間の ****移動平均**** （ピンク）を重ね書きしたチャートです。チャートをクリックすると、書き方を説明した記事に飛びます。

<a href="https://bred-in-bingo.netlify.app/posts/taiju-project/"><img src="/out-taiju.svg" alt="体重曲線" width=70%></a>


## まとめ {#まとめ}

家庭用の安価な体組成計・体重計でCSVファイルをエクスポートしてくれる製品は貴重な存在です。1byoneの smart scale は、測定精度も良く、アプリも良くできていて、Garminなどとの連携もできるというスグレモノ。今や日本国内では中古でしか入手できないのは本当に残念です。後継機の国内発売が待たれます。


## 参考資料 {#参考資料}

参考にした 1byoneの関係サイトは次のとおりです。

****2020/07/17****  [【Garmin Connect】”体重”を自動連携させる一番”コスパ”良い方法](https://55544aki.com/body-composition-meter/)<br />
****2023/07/29**** [Garminスマートウォッチとスマホ連携 アプリ設定ポイント](https://bonpon424.com/entry/garmin-1byeone#google_vignette)<br />
****2023/10/12**** [Garmin Connectへ体重を取り込む方法](https://namaraii.com/blog/2023/20231013)<br />
****2020/11/07**** [1byoneの体重計はタニタやオムロンと戦略が異なるが価値は同じだ](https://findep.hatenablog.com/entry/1byone-body-scale)<br />
****2021/05/12**** [Garmin Index S2と1byoneを比較する](https://note.com/naokishoji/n/n35c9e894a9ea)<br />
****2016/09/26**** [Garminユーザーの体重管理はこれで十分ではないでしょうか？ スマートスケールとGarminconnectの接続方法](https://its-there.com/weight_management-9787.html#google_vignette)<br />
****2023/04/27**** [スマートウォッチを導入したら、大好物のお酒と両立して15kgのダイエットに成功した話 Fun！なこと](https://www.rakuten-card.co.jp/minna-money/fun/article_2206_90348/)


## Footnotes: {#footnotes}

[^fn:1]: 今は国内ではAmazon, Rakuten, Yahoo, ヨドバシなどどこでも新品では売っていませんが、中古は出回っています。わが家の1byoneの銘板はこんな感じ：

    {{< figure src="/1byOne.jpg" width="40%" >}}
[^fn:2]: CSVのエクスポート法は後述します。
