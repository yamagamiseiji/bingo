+++
title = "Joplin CLIをUbuntuで使う — インストールから同期先設定と基本的な使い方の解説"
author = ["YAMAGAMI"]
date = 2024-10-09T00:00:00+09:00
tags = ["joplin", "CLI", "ubuntu", "Dropbox", "install", "usage", "tutorial"]
categories = ["comp"]
draft = false
+++

この記事では、Joplin CLIを使ってUbuntu環境で効率的にメモを管理する方法を解説します。インストール方法、Dropboxやローカルファイルシステムを同期先として使う設定、それから基本的な使い方について解説します。
Joplinをターミナルから操作したいLinuxユーザーの参考になればと思います。


## 1. UbuntuへのJoplin CLIインストール方法 {#1-dot-ubuntuへのjoplin-cliインストール方法}

まずは、Joplin CLIをUbuntuにインストールします。JoplinはNode.jsベースのツールで、npmを使ってインストールします。

<!--list-separator-->

-  ****Node.jsのインストール****

    まず、Node.jsとnpmがインストールされていない場合は、以下のコマンドでインストールします。

    ```text
    sudo apt update
    sudo apt install nodejs npm
    ```

<!--list-separator-->

-  ****Joplin CLIのインストール****

    次に、Joplin CLIをインストールします。 `~/.joplin-bin` ディレクトリにインストールすることで、環境を汚さない設定を行います。

    ```text
    NPM_CONFIG_PREFIX=~/.joplin-bin npm install -g joplin
    ```

    インストールが完了すると、Joplin CLIを使えるようになります。

<!--list-separator-->

-  ****パスの設定****

    Joplin CLIをどこからでも使えるようにするため、パスを設定します。以下のコマンドを `.bashrc` や `.zshrc` に追加します。

    ```text
    export PATH="$HOME/.joplin-bin/bin:$PATH"
    ```

    設定を反映するために、ターミナルを再起動するか、次のコマンドを実行します。

    ```text
    source ~/.bashrc  # or source ~/.zshrc
    ```

    ---


## 2. Dropboxやローカルファイルシステムを同期先とする設定方法 {#2-dot-dropboxやローカルファイルシステムを同期先とする設定方法}

Joplin CLIでノートを保存・同期するには、Dropboxやローカルファイルシステムを同期先として設定する必要があります。ここでは、両方の方法を紹介します。


### Dropboxを同期先に設定する方法 {#dropboxを同期先に設定する方法}

<!--list-separator-->

-  ****同期ターゲットをDropboxに設定****

    次のコマンドでDropboxを同期ターゲットに設定します。

    ```text
    joplin config sync.target 7
    ```

<!--list-separator-->

-  ****Dropboxの認証を行う****

    次に、Joplin CLIをDropboxに接続します。まず、 `joplin sync` を実行すると、Dropboxの認証ページへのリンクが表示されます。

    ```text
    joplin sync
    ```

<!--list-separator-->

-  ****認証コードの入力****

    ブラウザでリンクを開き、DropboxにログインしてJoplinを認証します。認証後に表示されるコードをコピペしてターミナルに入力し、同期を開始します。ノートの数が多いとかなり時間がかかります。


### ローカルファイルシステムを同期先に設定する方法 {#ローカルファイルシステムを同期先に設定する方法}

ローカルのフォルダを同期先として使う場合は、以下の設定を行います。

<!--list-separator-->

-  ****同期ターゲットをローカルファイルシステムに設定****

    次のコマンドで同期ターゲットをローカルファイルシステムに設定します。

    ```text
    joplin config sync.target 2
    ```

<!--list-separator-->

-  ****同期先フォルダを設定****

    ローカルのディレクトリを指定します。例えば、 `~/joplin-sync` というディレクトリを同期先にする場合は次のように設定します。

    ```text
    joplin config sync.2.path ~/joplin-sync
    ```

<!--list-separator-->

-  ****同期を実行****

    設定が完了したら、同期を実行します。

    ```text
    joplin sync
    ```

    ---


## 3. 基本的なJoplin CLIコマンドの使い方 {#3-dot-基本的なjoplin-cliコマンドの使い方}

Joplin CLIでは、さまざまな操作がターミナルから行えます[^fn:1]。以下にいくつかの基本的なコマンドを紹介します。


### ノートブックを切り替える {#ノートブックを切り替える}

現在作業中の(current)ノートブックを切り替えるには以下のコマンドを使います。

```text
joplin use "ノートブック名"
```

`use` はlinuxの `cd` コマンドにあたります。Joplin CLIのコマンドはcurrentノートブック配下のノートが対象となりますので、 `use` コマンドの出番は多いです。ノートブック名、ノートのタイトルにスペースが含まれていなければダブルクォートは不要です。


### ノートの作成 {#ノートの作成}

新しいノートを作成するには、以下のコマンドを使います。

```text
joplin mknote "新しいノートのタイトル"
```

このコマンドの前に `joplin use "ノートブック名"` でcurrentなノートブックを指定しておきます。


### ノートの一覧表示 {#ノートの一覧表示}

ノート一覧を表示するには、次のコマンドを使います。ここでもまず `use` コマンドを発行しておきます。

```text
joplin use "ノートブック名"
joplin ls
```

currentノートブック中のノートを表示します。
`-l` オプションをつけると詳細一覧が表示されます：

```text
$ joplin use Health
$ joplin ls -l
kdqld 04/10/2024 10:41 体重管理プロジェクト
253hd 04/10/2024 10:39 1byone 体重計・体成分計の使い方
yah3k 29/09/2024 11:37 体重管理ダイヤグラム
　：
```

なお、ノートブックの一覧を表示するには `ls /` と入力します。


### ノートの編集 {#ノートの編集}

ノートを編集するには以下を実行します。デフォルトのエディタは `nano` です。

```text
joplin use "ノートブック名"
joplin edit "ノート名"
```

エディタを `Emacs` に変更するには、次のコマンドを実行します。

```text
joplin config editor "emacs"
```

入力した"ノート名"(=hogehoge)がcurrentノートブックに存在しない場合には、

```text
"hogehoge" というノートはありません。作成しますか？ (Y/n)
```

というメッセージが表示され `Y` を入力すると指定されたエディタが起動します。エディタを終了すると「ノートは保存されました。」というメッセージが表示されます。


#### ノートのインポート {#ノートのインポート}

MarkdownファイルをJoplinにインポートするには、次のコマンドを使用します。

```text
joplin import --format md /path/to/file.md "ノートブック名"
```

この例では、"ノートブック名"の中に `file` という名前のノートが作られます。
currentノートブックに


#### ノートのタイトルを変更 {#ノートのタイトルを変更}

```text
joplin set "ノート名" title "新しいノート名"
```

ここで `title` はノートのプロパティ名です。 `joplin help set` でプロパティ名の一覧が表示されます。実際の操作例は次のとおりです。

```text
$ joplin ls -l
4f4f9 09/10/2024 15:59 file

$ joplin set 'file' title 'new note'
$ joplin ls -l
4f4f9 09/10/2024 15:59 new note
$ joplin sync upgrade
```

`loplin sync upgrade` で、同期先を最新バージョンにアップグレードしています。

---


## まとめ {#まとめ}

このチュートリアルでは、Joplin CLIのインストール方法、Dropboxやローカルファイルシステムを同期先に設定する方法、そして基本的なコマンドの使い方を解説しました。

Joplin CLIを導入した目的は、Ubuntu PCで作成したデータやチャートをモバイル端末のJoplinで即時的にモニターできるようにするためでした。Joplin CLIのコマンドはささやかなものですが、十分に所期の目的は達成できました。便利になりました。

---


## Acknowledgement {#acknowledgement}

本記事はChatGPTを参考にさせていただきました。ありがとうございました。


## Footnotes: {#footnotes}

[^fn:1]: : 使用できるコマンド一覧は以下のとおりです（ `joplin help` で表示されます）。
    `attach, batch, cat, config, cp, done, e2ee, edit, export, geoloc, help, import, ls, mkbook, mknote, mktodo, mv, ren, restore, rmbook, rmnote, server, set, status, sync, tag, todo, undone, use, versio`
