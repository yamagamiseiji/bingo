+++
title = "アルファベット文字書き順矯正トレーナーの概要"
author = ["YAMAGAMI"]
date = 2024-03-28T00:00:00+09:00
tags = ["alphabets", "handwriting", "trainer", "script"]
categories = ["comp"]
draft = false
+++

アルファベットの小文字 **ｆ** の [**筆順矯正トレーニング**](https://bred-in-bingo.netlify.app/posts/stroke-order) をするために、
**ｆ** 文字をたくさん含む英単語リストが欲しくて
Googleで検索してみましたがよい情報が見つかりませんでした。

そこでChatGPTで質問してみたら、 **ｆ** を3文字含む単語として **fluffiness** （ふわふわ感）, **fiftyfive** （55）, **effortful** （努力した）があるという回答がありました。さすが！と一瞬感心しましたけれど、よく見ると回答の中には2文字しかない単語も混じっていました[^fn:1]。

どうやら「特定のアルファベット文字をたくさん含む英単語リスト」は手に入りにくそうだったので、一般的な英単語リストから、特定の文字が多く含まれる単語を自分で抽出してリストを作ることにしました。


## 英単語リストの選択 {#英単語リストの選択}

語彙数ができるだけ多くフリーの英単語リストを探したところ、
**山形方人氏（2018）** による10,000単語のリスト（UVL10000）[^fn:2] がありましたので、これを使わせていただくことにしました。

当初は正しい筆順を練習するために、単に **ｆ** をたくさん含む単語リストだけが欲しかったのですが、せっかく良い英単語リストが見つかったので、この際、
**ｆ** だけじゃなくて、 **a** から **z** の全26文字について、それらの文字が単語中に含まれる数をカウントすることにしました。


## 結果 {#結果}

ダウンロードした山形氏のエクセルファイルをCSV変換した後に、簡単なシェルスクリプトを書き実行して、表[1](#table--table1) のような結果を得ました。スクリプトなどの説明は[Appendix](#appendix)を見てください。

第1列がアルファベット文字、左上角の `4133` という数字は、単語中に文字 **a** が１個入っている単語の数が10,000単語中に `4133` 単語あったことを示します。

**a** 行の右端＝合計 `5298` は **a** を **少なくとも１つ** 含んでいる単語が `5298` 個あったということになります。

<a id="table--table1"></a>
<div class="table-caption">
  <span class="table-number"><a href="#table--table1">&#34920; 1</a>:</span>
  英単語中にa〜zのアルファベット文字が入っている数
</div>

|       | 1    | 2    | 3   | 4  | 5 | 合計 |
|:-----:|-----:|-----:|----:|---:|--:|---:|
| **a** | 4133 | 1073 | 87  | 5  | 0 | 5298 |
| **b** | 1284 | 66   | 3   | 0  | 0 | 1353 |
| **c** | 2812 | 491  | 32  | 0  | 0 | 3335 |
| **d** | 2162 | 204  | 5   | 0  | 0 | 2371 |
| **e** | 4277 | 1860 | 375 | 42 | 2 | 6556 |
| **f** | 866  | 153  | 2   | 0  | 0 | 1021 |
| **g** | 1451 | 106  | 6   | 0  | 0 | 1563 |
| **h** | 1212 | 75   | 2   | 0  | 0 | 1289 |
| **i** | 4024 | 1230 | 207 | 19 | 1 | 5481 |
| **j** | 134  | 1    | 0   | 0  | 0 | 135  |
| **k** | 360  | 5    | 1   | 0  | 0 | 366  |
| **l** | 3073 | 473  | 40  | 2  | 0 | 3588 |
| **m** | 1929 | 201  | 14  | 0  | 0 | 2144 |
| **n** | 3541 | 895  | 99  | 7  | 0 | 4542 |
| **o** | 3386 | 771  | 88  | 5  | 0 | 4250 |
| **p** | 2016 | 245  | 9   | 0  | 0 | 2270 |
| **q** | 210  | 0    | 0   | 0  | 0 | 210  |
| **r** | 4154 | 758  | 53  | 0  | 0 | 4965 |
| **s** | 2933 | 576  | 65  | 12 | 1 | 3587 |
| **t** | 4021 | 1009 | 69  | 1  | 0 | 5100 |
| **u** | 2567 | 278  | 16  | 2  | 0 | 2863 |
| **v** | 1016 | 33   | 0   | 0  | 0 | 1049 |
| **w** | 389  | 10   | 0   | 0  | 0 | 399  |
| **x** | 271  | 1    | 0   | 0  | 0 | 272  |
| **y** | 1427 | 27   | 0   | 0  | 0 | 1454 |
| **z** | 165  | 10   | 0   | 0  | 0 | 175  |

注目すべき点をあげると：

-   同じ文字を6文字（以上）含む単語は無いこと
-   同じ文字を5文字含む単語は次の表の4単語のみであること

    | 文字  | 英語            | 意味  |
    |:---:|:--------------|:----|
    | **e** | effervescence   | 泡立ち |
    | **e** | interdependence | 相互依存性 |
    | **i** | incorrigibility | 矯正不能 |
    | **s** | listlessness    | 無気力 |
-   **v, w, x, y, z** を3文字以上含む単語は無いこと
-   **q** を2個以上含む単語は無いこと（ **q** は常に1個だけ！）
-   **j** を2個以上含む単語は jejune（単純,幼稚）1個しか無いこと

などです。


## ｆの単語リスト作成 {#ｆの単語リスト作成}

**f** については、UVL10000の中で、 **f** が2個以上（4個まで）含まれている単語に加えて、先にChatGPTで得られた単語を合わせた合計 **161単語** を `2-4fs.txt` としてファイル化しました。

| fの個数 | 1   | 2   | 3 | 4 | 5 |
|------|-----|-----|---|---|---|
| **f** | 866 | 153 | 6 | 2 | 0 |


### handwriting-trainer.sh {#handwriting-trainer-dot-sh}

上の161単語（ `2-4fs.txt` ）を `eSpeak-NG` を使ってランダム順に読み上げます。

```text
#!/bin/bash
#
#  f が 2〜4個入った英単語ファイル（2-4fx.txt）からランダムに読み上げる
#

awk -F"," '{print $1}' < 2-4fs.txt > tmp-f24-list.txt
# ランダム化
sort -R tmp-f24-list.txt -uo tmp-f24-list.txt
# 1単語語ずつ読み上げる
i=0
exec 3< tmp-f24-list.txt
while read -r -u 3 word; do
    i=$(( i + 1 ))
    echo $i, "${word}"
    espeak-ng -v en-us+f2 "${word}"\
     -g 10\
     -p 80\
     -s 190
    read -r -p "   Hit Enter"
done 3< tmp-f24-list.txt
```

-   単語の読み上げを聞いた後に綴りを手書きすることで、書き順を矯正しようというものです。聞き取れなかったら、ちらっと画面を見ればちゃんと正解が表示されています。

-   `read` で一旦ポーズしてエンターキーの入力を待つようにするために、読み上げ用ファイルの読み込みには **ファイルデスクリプタ** FD3を使っています。


#### eSpeak-NGについて {#espeak-ngについて}

これがフリーソフトで入手できるのは本当にすごい！使用したオプションは次のとおりです(詳しくは `espeake --help` してください)。

-   **-v**  言語指定（ `espeak --voices` で詳細リストが表示されます)
-   **-g**  単語間間隔, 単位=10msec
-   **-p**  ピッチ 0〜99, デフォルト=50
-   **-s**  スピード（単語読上げ数/1分), デフォルト=175

以上です。


## Appendix: {#appendix}


### 表1 はどうやって作ったか {#表1-はどうやって作ったか}

`UVL1000.csv` （10,000語リスト（xlsm）を英単語だけを抽出したCSVファイル）を読み込んで `[a-z]-wordlist.csv` ファイルを作ります[^fn:3]。スクリプトはわずか10行ほどです。

```text
#!/bin/bash
#
# UVL10000.csvを読んで [a-z]-wordlist.csv ファイルをつくる
#
for letter in {a..z}; do
    echo $letter
    while read -r word ; do
	freq=$( echo $word \
	    | grep -io ${letter} \
	    | wc -l)
	if [[ $freq -ne 0 ]]; then
	    echo $word, $freq
	fi
    done < UVL10000.csv  > ${letter}-wordlist.csv
done
```

たとえば `f-wordlist.csv` の中身はこんな感じ。単語の右の数字が **ｆ** の個数です。

```nil
adrift, 1
afar, 1
affable, 2
affair, 2
affect, 2
 ：
```

上で作った `[a-z]-wordlist.com` を読み込んでスプレッドシート[^fn:4]に流し込みやすい形に整形します。

```text
 for letter in {a..z}; do
    printf "%s," "${letter}"
    for ((i=1; i<=5; i++)); do
      	echo -n "$(grep -c ${i} ${letter}-wordlist.csv) ,"
    done
    echo ""
done > for-spreadsheet.csv
```

`for-spreadsheet.csv` はこんな感じです。

```nil
a,4133 ,1073 ,87 ,5 ,0 ,
b,1284 ,66 ,3 ,0 ,0 ,
c,2812 ,491 ,32 ,0 ,0 ,
d,2162 ,204 ,5 ,0 ,0 ,
e,4277 ,1860 ,375 ,42 ,2 ,
f,866 ,153 ,2 ,0 ,0 ,
　　：
```


## Footnotes: {#footnotes}

[^fn:1]: : 英語でのChatGPTでのやり取りでは2度にわたってはっきりと three or more f'sと聞いたのですがその都度 **ｆ** が2文字しかない単語がリストに入っていました&#128517;
    たけども英語のChatGTPでは **riffraff** （下層階級の人々）や **fiftyfifth** （55番目）などの **f** が4個はいったレアな単語を教えてくれました。
[^fn:2]: : [わがまま科学者の英語講座  究極の英単語リストUVL10000（β版）を無料公開（その１）](<https://bioenglish.hatenablog.com/entry/2018/07/22/071416>)
[^fn:3]: : 10,000単語の処理は超型落ちのThinkPad 230Xでも 10分31秒で終わりました。
[^fn:4]: 特にスプレッドシートでやらなければならないことはありませんが、とりあえずLibreOffice Calcで行の合計だけは出してみました。