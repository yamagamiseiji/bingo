+++
title = "ごあいさつ"
author = ["YAMAGAMI"]
date = 2021-03-26
tags = ["Emacs", "hugo", "ox-hugo", "Netlify", "GitHub"]
categories = ["comp"]
draft = false
toc = true
+++

これまで2年ほどブログ書きは下のようなフローでやってきました。

```text
Emacs > org2blog > WordPress > freenom > AWS
```

しかし

1.  WordPress(WP)ではバージョンアップに追いつくのが大変
2.  サボっていると、画像ファイルが表示されないなどの **トラブル** 頻発
3.  WPトラブルへの対応力不足だけではなく
4.  WPは **隔靴掻痒** （かっかそうよう）っぽい
5.  SSL対応もしなくちゃならないし・・・
6.  AWSも最初の1年間はほぼ無料でありがたかったけど、その後は年間120ドルほどになって結構 **負担** が大きい

などなどから一念発起。この際、ブログ書きの流れをつぎのように変えようと思いました。

```text
Emacs > org-mode > ox-hugo > Hugo > Netlify > GitHub
```

ところが始めてみるとあちこちに地雷や落とし穴が！「新装開店」まで　まだ一山も二山もあるかと思います。


## 四苦八苦 {#四苦八苦}

最大の難関は、NetlifyがGitHubレポジトリを自動的にデプロイしてくれなかったこと。ウエッブで調べてみると、簡単だったという記事がある一方で、英語でも日本語でもこの段階でハマったという記事もたくさんあります。それらを見ながらほんとうにいろいろやりましたｗ

四苦八苦しましたが、2021-03-25に初デプロイ成功！。うまくいった理由は

1.  hugoを `hugo_extended_0.81.0_Linux-64bit.deb` にアップしたこと
2.  Netlifyウエブサイトの'Deploy settings'中の'Build settings'の内容をGitHubのサイトルートにしたこと。

    ```text
    Base = bingo/
    　：
    Publish = public
    　：
    ```

などが奏功したんだと思います。


## 環境 {#環境}

ソフトウエアの環境は次のとおりです。

| Software | Version         |
|----------|----------------:|
| OS       | Ubuntu20.04     |
| Emacs    | 26.3            |
| org-mode | 9.4.4           |
| ox-hugo  | 0.7             |
| hugo     | extended 0.81.0 |
| git      | 2.25.1          |


## Acknowledgment　 {#acknowledgment}

（これはテストページです）