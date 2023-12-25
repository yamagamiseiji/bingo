+++
title = "Deploy Test for GA4"
author = ["YAMAGAMI"]
date = 2023-12-24T00:00:00+09:00
tags = ["test"]
categories = ["comp"]
draft = false
+++

## Deplay Test for GA4. {#deplay-test-for-ga4-dot}

1.  config.toml に次の行を追記
    ```nil
    google_Analytics = "G-XXXXXXXX"
    ```
2.  ./layout/partial/head.html に次の行を確認
    ```nil
    {{ template "_internal/google_analytics.html" }}}
    ```

3.  Save the changes
4.  Deploy to Netlify
