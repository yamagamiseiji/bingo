+++
title = "Deploy Test for GA4"
author = ["YAMAGAMI"]
date = 2023-12-25T00:00:00+09:00
tags = ["test"]
categories = ["comp"]
draft = false
+++

## Adding Google Analytics to this blog {#adding-google-analytics-to-this-blog}

この ****Yam's Peace Blog**** は

```text
Emacs/Hugo/GitHub/Netlify
```

経路で公開しています。

2023年前半まではGoogle Universal Analytics（ ****UA**** ）でアクセス状況をモニターしていました。

****UA**** は2023/07/01で終了したのですが、きちんと新しいバージョンのアナリティクス＝Google Analytics4( ****GA4**** )へ移行する作業をダラダラと後延べしていました。

ようやく年末も押し迫った2023年12月下旬から ****GA4**** への移行に着手し始めました。

当初、ネット上で移行のための日本語サイトをいろいろ探索しましたが、いずれも「帯に短したすきに長し」。というかほとんどがHugoベースのブログにとっては無用な情報が多くて「たすきに長し」でした。

しかし、Rodney Maiatoさんによる
[How to Add Google Analytics to a Hugo Site
](https://rodneymaiato.dev/posts/how-to-add-google-analytics-to-a-hugo-site/)に出会ってからは、記事にも書かれている通り5分程度の作業で移行が終わりました。ほんとうに助かりました。ありがとうございました。


## 手順 {#手順}

上のサイトに紹介されている通りに作業（というほどでもありません&#128517;）

1.  `./config.toml` に次の行を追記
    ```nil
    google_Analytics = "G-XXXXXXXX"
    ```
2.  `./layout/partial/head.html` の次行を確認
    ```nil
    {{ template "_internal/google_analytics.html" }}}
    ```

3.  上の修正を保存
4.  Netlifyにデプロイ
5.  1日から2日ほど待つとGoogle Analytisでアクセス情報を見ることができる

これだけです。
