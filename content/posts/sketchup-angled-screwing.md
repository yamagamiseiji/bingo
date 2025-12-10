+++
title = "Sketchup Free で隠しビスの斜め打ちを書く"
author = ["yamagami"]
date = 2025-12-09T00:00:00+09:00
tags = ["woodworking", "sketchup", "DIY", "CAD"]
categories = ["comp"]
draft = false
+++

### はじめに {#はじめに}

DIYで自作したデッキ階段[^fn_decksteps]の図面を書くために2025年10月から [Sketchup Free](https://app.sketchup.com/app?hl=en) を使い始めました。この記事は Sketchupで **階段の踏板** の隠しビスの ****斜め打ち**** （図[1](#figure--tread-o-stair)の手前のビス4本）を書く方法を自分のための備忘として書いたものです。

<a id="figure--tread-o-stair"></a>

{{< figure src="/踏板隠しネジ_20251206.png" caption="<span class=\"figure-number\">&#22259;1:  </span>2x4によるデッキ階段踏板のネジ止めで使った方法" width="90%" >}}

Sketchup 初心者の自分にとっては、図[1](#figure--tread-o-stair)のような **隠しビスの斜め打ち** を書くのは容易ではありませんでした。
Sketchup **PRO** ならエレガントな方法がある？かもしれないし、 **Free** でも別の正解があると思います。一つの素朴なサンプルとしてご覧ください。

[^fn_decksteps]: ちなみに今回作製した **階段踏板の概要** は次のとおりです。
(1) 踏板は 2x4 を3枚並べる。土台の枠も2x4 (2) 踏板を長持ちさせるために、ネジ穴に雨や日が直接当らないようにした (3) 踏板同士の横連結には、40mmの **四角穴付き木ネジ** を水平穴に埋め込んで使用 (4) 踏板と土台の連結には、75mmの **コーススレッド** を斜めの隠し穴に10mmほど埋め込む。

[^fn_why2x4]: 踏板はともかく階段の側板は2x8や2x10を使うのが普通だと思いますが、たまたま物置に2x4の在庫が10本ほどあったのでそれを活かすことにしました。


### 「隠しビスの斜め打ち」を図面化するための練習問題 {#隠しビスの斜め打ち-を図面化するための練習問題}

```nil
下図のように2本の2x4材を重ねて、
上の2x4から下の2x4に向かってコーススレッドを隠しビスで斜め打ちする。
```

{{< figure src="/20251204_19-44-18.png" caption="<span class=\"figure-number\">&#22259;2:  </span>練習問題のX線モード図" width="60%" >}}

練習問題の具体的な条件は次のとおりです。

-   60cm長の2x4材を2本積み重ねて、上部の2x4材の中央から下に向かってコーススレッドを斜め打ちして両材を固定する
-   コーススレッド（以降ビス）のネジ長は75mm、ネジ頭の径は8mm
-   斜め打ちの角度は60度、隠しビス用の穴の深さは10mm
-   隠し穴用の ****ドリルオブジェクト（円柱）**** の直径は 9mm, 長さは25mm


### 図面書きの手順 {#図面書きの手順}

1.  **メジャー (T)** を使って **隠しビス穴** （以降ビス穴）の中心点を決める（水平・垂直ガイドライン＝第1,第2ガイドラインの交叉する点）

2.  第3ガイドラインとして、モデルの床面にビス穴の中心点の<span style="color: red">赤軸</span>座標値で、<span style="color: green">緑軸</span>に平行なガイドラインを引く。

{{< figure src="/20251204_15-16-35.png" caption="<span class=\"figure-number\">&#22259;3:  </span>3本のガイドライン（点線）を引く" width="40%" >}}

3.  床面の第3ガイドラインの上に、ドリルオブジェクト（円柱）底面の中央点、およびビスの先端を乗せる（下図）。ドリル円柱の直径はビスヘッド径と同じで8mm、高さは25mm。

{{< figure src="/20251204_15-27-20.png" caption="<span class=\"figure-number\">&#22259;4:  </span>ドリルオブジェクト（円柱）とビスの ****初期位置**** 。ドリルやビスを穴の中心と同一ライン上に並べておくと後が楽になる。" width="40%" >}}

4.  **分度器** でビス穴中心点を通る **傾き60度** のガイドライン（60度補助線）を引く。

{{< figure src="/20251204_15-30-33.png" caption="<span class=\"figure-number\">&#22259;5:  </span>分度器の固定面を<span style=\"color: red\">赤軸</span>にする。下表参照。" width="40%" >}}

-   この時、分度器を **特定面** に固定することが必要だが、それにはカーソル移動キー（上下左右の矢印キー）を用いる（下表）。

キー|固定する面
---|:---:|
**←** |<span style="color: green">緑軸</span>
**→** |<span style="color: red">赤軸</span>
**↑** |<span style="color: blue">青軸</span>
**↓** |図形に平行 / 垂直|

5.  **直線 (L)** を使って60度補助線（の一部）に **実線** （60度中央線）を重畳する[^fn_guidepoint]。

{{< figure src="/20251204_15-31-44.png" caption="<span class=\"figure-number\">&#22259;6:  </span>直線が2x4材を貫通していることに注目" width="40%" >}}

[^fn_guidepoint]: ガイドラインの点線上にもガイドポイントを打つことができるようですが、見づらいので実線にしてみました。

6.  **回転 (Q)** をつかってドリル円柱を60度に傾ける

{{< figure src="/20251203_09-34-07.png" caption="<span class=\"figure-number\">&#22259;7:  </span>このときも分度器を<span style=\"color: red\">赤軸</span>に固定する" width="40%" >}}

{{< figure src="/20251204_15-37-39.png" caption="<span class=\"figure-number\">&#22259;8:  </span>60度傾いたドリル円柱穴の中心と同一ライン上に円柱がある" width="40%" >}}

7.  60度中心線の材表面から15mm（ドリル円柱長 25mm − ビス穴の深さ 10mm）の場所にガイドポイントを打つ

{{< figure src="/20251204_15-39-54.jpg" caption="<span class=\"figure-number\">&#22259;9:  </span>ガイドポイントは赤丸の中。ドリル円柱は選択された状態" width="40%" >}}

8.  **移動 (M)** を使ってドリル円柱の上面の **中央点** をみつける

{{< figure src="/20251204_15-41-03.png" caption="<span class=\"figure-number\">&#22259;10:  </span>中央点が表示されている　" width="40%" >}}

9.  中央点をつまんで、60度中心線の15mm地点にあるガイドポイントに合わせる。

{{< figure src="/20251204_15-41-25.png" caption="<span class=\"figure-number\">&#22259;11:  </span>ドリル円柱の下半分は2x4材に刺さっている。" width="40%" >}}

10. 材の表面からはみ出している部分円柱を選択し、右クリックしてメニューから **面を交差（Intersect Face）** --&gt;  **モデルと交差（With Model）** 選ぶ（図[13](#figure--fig-interset)）。

{{< figure src="/20251204_15-43-25.png" caption="<span class=\"figure-number\">&#22259;12:  </span>はみだし部を選択した状態" width="40%" >}}

<a id="figure--fig-interset"></a>

{{< figure src="/20251203_09-49-25.png" caption="<span class=\"figure-number\">&#22259;13:  </span>メニューから「面を交差」、「モデルと交差」を選ぶ" width="80%" >}}

11. 材の表面からはみ出している部分円柱を選択して `Backspace` で削除

{{< figure src="/20251204_15-43-37.png" caption="<span class=\"figure-number\">&#22259;14:  </span>はみ出した部分円柱が削除された状態" width="40%" >}}

12. 材の表面のビス穴を選択

{{< figure src="/20251204_15-43-51.png" caption="<span class=\"figure-number\">&#22259;15:  </span>ビス穴が選択されている" width="40%" >}}

13. `Backspace` キーを押して削除、穴があく

{{< figure src="/20251204_15-43-59.png" caption="<span class=\"figure-number\">&#22259;16:  </span>隠し穴の「フタ」が削除された状態" width="40%" >}}

14. X線モードで見ると下図のとおり

{{< figure src="/20251204_15-44-26.png" caption="<span class=\"figure-number\">&#22259;17:  </span>2x4材の内部にはドリル円柱の一部と60度中央線が残っている" width="40%" >}}

15. X線モードで、ビス穴の底面中心から **メジャー (T)** を使ってビスの先端がくる場所にガイドポイントを打つ（距離はおよそビス長 − 1mm）。

{{< figure src="/20251204_15-46-16.jpg" caption="<span class=\"figure-number\">&#22259;18:  </span>下段の2x4材の中程の赤丸にガイドポイントがある" width="40%" >}}

16. ビスをズームアップし **移動 (M)** でビスの先端をつまんで、60度中心線にのせ、先端がガイドポイントに乗るまで移動する。

{{< figure src="/20251204_15-48-09.png" caption="<span class=\"figure-number\">&#22259;19:  </span>ビス先端のズームアップ" width="40%" >}}

{{< figure src="/20251204_15-53-02.png" caption="<span class=\"figure-number\">&#22259;20:  </span>移動の結果、ビス先端がガイドポイントに乗っている" width="40%" >}}

17. 60度中心線の実線を削除してできあがり！

{{< figure src="/20251204_19-44-18.png" caption="<span class=\"figure-number\">&#22259;21:  </span>X線モード図" width="40%" >}}

{{< figure src="/20251204_19-53-39.png" caption="<span class=\"figure-number\">&#22259;22:  </span>パース図" width="40%" >}}


### おわりに {#おわりに}

この歳になって初めて 3D モデリングCADソフトの Sketchup free を使いました。これまで木工DIYでは、フリーハンドでラフな下書きは書きましたが、きちんとした図面を書くことはありませんでした。もっと早くから使う機会があれば良かったのにと後悔しています。

現在、過去に作った木工品の図面を改めて書きながら、来春の雪解け後の懸案事項であるデッキのクロスフェンスなどの図面を書いています。大工道具や電動工具を手にする前に、きちんとした図面を書くことの大事さを痛感しています。


## Appendix: デッキ階段全体の寸法図 {#appendix}

{{< figure src="/20251122_デッキ階段寸法図.jpg" caption="<span class=\"figure-number\">&#22259;23:  </span>デッキ階段全体の寸法図" width="70%" >}}


## Footnotes: {#footnotes}
