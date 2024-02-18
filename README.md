達成したタスクを見返すことで勉強等のモチベーションアップを目的とした、タスク管理ツールです。

# URL
https://lookback-calendar.com/ <br >
画面中部の「LOGIN AS A GUEST」ボタンから、メールアドレスとパスワードを入力せずにログインできます。

# 使用技術
- Next.js
- MUI
- Ruby 3.1.2
- Ruby on Rails 7.0.8
- MySQL 8.0.32
- Nginx
- Puma
- AWS
  - VPC
  - Fargate
  - RDS
  - Route53
- Docker/Docker-compose
- Github Actions
- RSpec
- Jest

# AWS構成図
<img width="995" alt="" src="https://github.com/alicend/Rails_LookBack/assets/86368377/d9bef69e-fde5-49cb-b9d1-3f781d26dffc">

## Github Actions CI/CD
- Githubへのpush時に、「Rspec」「Jest」「Rubocop」「Eslint」が自動で実行されます。
- mainブランチへのpushでは、上記の４つが成功した場合、AWS Fargateへの自動デプロイが実行されます。

# 機能一覧
- ユーザー登録、ログイン機能(devise)
- 投稿機能
  - 画像投稿(refile)
  - 位置情報検索機能(geocoder)
- いいね機能(Ajax)
  - ランキング機能
- コメント機能(Ajax)
- フォロー機能(Ajax)
- ページネーション機能(kaminari)
  - 無限スクロール(Ajax)
- 検索機能(ransack)