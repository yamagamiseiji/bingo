+++
title = "Ledger — GnuCashからのデータ インポート"
author = ["YAMAGAMI"]
date = 2021-11-30T00:00:00+09:00
tags = ["ledger", "GnuCash", "複式簿記", "Android", "bash"]
categories = ["comp"]
draft = false
+++

## GnuCashとは {#gnucashとは}

**GnuCash** はオープンソースの **複式簿記** による経理ソフトです。
Ledger-cliに比べると日本国内にも相当数のユーザが存在している気配があります :smile:

{{< figure src="/android-gnucash-icon.png" width="70%" >}}

今回は

```text
アンドロイド版のGnuCashを
Ledger-cliと「組み合わせ」て使ってみます
```


### 具体的には {#具体的には}

Ledger-cliのトランザクションを書くための手段＝ **メモパッド** として使ってみようと思います[^fn:1]。

GnuCashを使おうと思った動機は：

-   Emacs/Ledger-cliの入ったPCを常に持って歩くことはできないこと
-   領収書やレシートをもらえないケースがあること

の2つです。[^fn:2]

**おもて経済** の取引では、さすがのOECD内のガラパゴス国ジャパンでも、ほぼ100%の支出に対してきちんとレシートとか領収書が戻ってきます。

しかし、いまだに **現金払い限定** で、かつレシートをもらえない「取引」も少なくはありません。たとえば[^fn:3]

> 葬儀の香典や祝い事のご祝儀<br />
> 屋台で一杯飲んだとき<br />
> 神社への初穂料や玉串料<br />
> お坊さんへのお布施<br />
> チップや「おひねり」<br />
> 政治屋さんへの裏献金<br />
> etc ...

これらの支出のたびごとに、 **手帳** にメモを残せる几帳面な性格なら問題はありませんが、
**ふつうの人** が後で思い出しながら転記しようと思っても、なかなかむずかしいです。

少し前までは、ボールペンで左手の **手の甲** に金額を書き込んでいました。最近はコロナ禍であちこちに手指消毒用のアルコール液が置いてあります。メモしたことを忘れて消毒すると、大事なメモはアルコールで跡形もなく消えてしまいます。

**手帳** または **手の甲** にメモ書きする代わりに、タブレット（スマホ）で記帳しておいて、旅行や出張が終わった後に、自分のPCにそれらのトランザクションをインポートできれば、記憶力が減退し始めたスボラな性格の自分でも、いくらかちゃんとした転記ができるようになるかも知れません。 :wink:


## GnuCashのインストールと設定 {#gnucashのインストールと設定}

インストールは **Google Playストア** からダウンロードするだけ。

使い始めるためには、自分の **アカウント** （勘定科目）構造をGnuCashに入力します[^fn:4]。

Ledgerのアカウント構造は、XMLでGnuCashにエクスポートできるのかと思いましたが、ver.3 **以降** のLedgerには対応していないようでした[^fn:5]。手動でやっても小一時間で終わるので、手入力しました[^fn:6]。

その際、アカウント（勘定科目）を細部まで完全に用意する必要はありません。まずはよく使うトランザクションに関係するアカウントだけを先に入力して、そうでないアカウントは、取引が発生したときにその都度一つずつ作ります。

準備作業はこれだけです。


## GnuCashからのエクスポート {#gnucashからのエクスポート}

GnuCashトップ画面の左上にあるメニューアイコン（ **≡** ）で次のようなメニューを開きます。

{{< figure src="/gnucash設定menu.jpg" caption="&#22259;1:  GnuCashのメニュー" width="40%" >}}

上のメニューから「設定」を選び、設定画面（図[2](#org840fe05)）を開きます。設定が必要なのはこの4,5項目だけです。

<a id="org840fe05"></a>

{{< figure src="/gnucash-export.jpg" caption="&#22259;2:  GnuCash for Androidの取引のエクスポート画面" width="70%" >}}

設定が終わったら、画面右上の「エクスポート」をタップします。これでエクスポートは完了です。

あとは出来上がったCSVを「[参考資料（β版ソースコード）](#siryo)」節で紹介した
`gnucash2ledger.sh` を使ってLedgerタイプのトランザクションに整形しなおすだけです。


## `gnucash2ledger.sh` の使い方 {#gnucash2ledger-dot-sh-の使い方}

ターミナル内で `gnucash2ledger.sh` を起動します。

```text
$ gnucash2leddger.sh
 ** Saved in IMPed-TXN-f-GnuCash/20211129.ledger
```

コンバートされたLedger向けのトランザクションはつぎのような感じになります：

```text
$ cd  IMPed-TXN-f-GnuCash
$ cat 20211129.ledger
2021/11/24 NEXCO
    ; 沼田IC～青梅IC
    Expenses:Cars:Toll 	3420 JPY
    Liabilities:OricoCard

2021/11/24 ENEOS SS
    Expenses:Cars:Gasoline 	6156 JPY
    Liabilities:EneosCard

2021/11/26 ダイエー
    ; バナナなど
    Liabilities:ResonaVisa:seiji 	-1112 JPY
    Expenses:Grocery:Food:YOk
   ：
```


### 補足・注記 {#補足-注記}

-   こうして作成したトランザクションをLedgerファイルの本体にコピペするなどして使います。
-   上の出力例ではアカウント名がすべて英文字ですが、これは単なる偶然です
-   金額のカラム位置が揃っていませんが、EmacsのLedger-modeを使えば簡単に揃います
-   ソースターゲットの行の金額はインポートしていません。

<br />


## 参考資料（β版ソースコード） {#siryo}

GnuCashからLedgerにデータを移行するためのプログラムは、たとえばPythonをつかった[gnucash2ledger.py](https://github.com/MatzeB/pygnucash/blob/master/gnucash2ledger.py) とか、すでにいくつか存在しています。

今回のスクリプトは **bash** で短時間に書いたものです。先人のすぐれたプログラムのように多機能で広い適用範囲を持つものではありません。自分が使う最低限の機能だけを素朴にコーディングしました。ベータ版ですがとりあえず動いています :smile:

```nil
#!/bin/bash
set -eu  # Time-stamp: <2021-11-29 09:33:29 yamagami>
#
#    GnuCashからDropboxにエクスポートされたCSVを
#    ledger-cliトランザクションに変換する
#

## 変数定義
commodity='JPY'
drop_dir='/home/yamagami/Dropbox/アプリ/GnuCash Android'
storage_dir='/home/yamagami/local-ledger-directory/IMPed-TXN-f-GnuCash'

## ファイル初期設定
cp /dev/null ./tmp-transaction.ledger

## Dropboxから最新のGnuCash CSVファイルを抽出する
latest_csv=$(ls -1t "${drop_dir}"/*.csv|head -1)

## ヘッダー行を削除
sed '1d' "${latest_csv}" > ./gnucash.csv

## ダブルクォーテーションに挟まれた文字列中のカンマを外す
gawk -F"\"" '{x=$2;gsub(",","",x);print $1"\""x"\""$3}' ./gnucash.csv > ./tmp-no-comma.csv

## ここから本体 (2行ずつ読み出す)
while read odd_line && read even_line
do
    # トランザクション1行目
    date=$(date -d  `echo ${odd_line} | awk -F"," '{print $1}'`  '+%Y/%m/%d')
    payee=$(echo ${odd_line} | awk -F"," '{print $4}')
    #
    echo "${date} ${payee}" > ./tmp-1st-line.txt

    # notesがあれば追加する
    notes=$(echo ${odd_line} | awk -F"," '{print $5}')
    if [ -n "${notes}" ]; then
	flg_notes='Y'
	echo "    ; ${notes}" > ./tmp-notes.txt
    else
	flg_notes=''
    fi

    # トランザクション2行目
    target_acnt=$(echo ${odd_line} | awk -F"," '{print $10}' )
    amount=$(echo `echo "${odd_line}" | awk -F"," '{print $13}'` |sed 's/\.[0-9,]*$//g')
    # JPYを追加
    j_amount="${amount} ${commodity}"
    echo -e "    "${target_acnt} "\t"${j_amount} > ./tmp-2nd-line.txt

    ## トランザクション3行目
    source_acnt=$(echo "${even_line}" | awk -F"," '{print $10}')
    echo -e "    ${source_acnt}\\n" > ./tmp-3rd-line.txt

    ## 合体してLedgerファイルにする
    if [ -z "${flg_notes}" ]; then
	cat ./tmp-1st-line.txt ./tmp-2nd-line.txt ./tmp-3rd-line.txt  >> ./tmp-transaction.ledger
    else
	cat ./tmp-1st-line.txt ./tmp-notes.txt ./tmp-2nd-line.txt ./tmp-3rd-line.txt  >> ./tmp-transaction.ledger
    fi
#
done < ./tmp-no-comma.csv

# インポートデータの保存
c_date=$(date '+%Y%m%d')
cp ./tmp-transaction.ledger ${storage_dir}/${c_date}.ledger
echo "** Saved in IMPed-TXN-f-GnuCash/${c_date}.ledger"

# 一時ファイルの削除
rm ./tmp-*.csv
rm ./tmp-*.txt
rm ./gnucash.csv
rm ./tmp-transaction.ledger
exit 0
```


## Footnotes: {#footnotes}

[^fn:1]: GnuCashはメモパッドに **限定** して使うことにしました。GnuCashにも分析・レポート機能がついていますが、Ledger-cli＋GnuPlotなどで自分が欲しい機能はそこそこ揃えましたので・・・。
[^fn:2]: Ledger-cliの公式マニュアルにも、GnuCashをLedgerのデータ入力に使うことがgood alternative として推奨されています。
[^fn:3]: ケース的にも金額的にも宗教関係とか政治関係とかが多いですね。あと最近では一部の学校法人関係もこの **黒経済** の仲間かも？ :sunglasses:
[^fn:4]: GnuCashでは複数のセットのアカウント（勘定科目）構造を持てるようです。プライベートな家計簿用とビジネス用、学協会用などに分けて経理ができるので便利かも。
[^fn:5]: もしかしたら最新のGnuCashではできるようになったのかも知れません。未確認です。
[^fn:6]: 本題からは外れますが、手入力のしさすさは、Androidにインストールしたキーボードによって決まります。アカウント名のように英綴りと日本語が混在する場合、自分に使いやすかったのは [Microsoft SwiftKeyキーボード](https://play.google.com/store/apps/details?id=com.touchtype.swiftkey&hl=ja&gl=US) です。