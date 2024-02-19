達成したタスクを見返すことで勉強等のモチベーションアップを目的とした、タスク管理ツールです。

# URL
https://lookback-calendar.com/ <br >
画面中部の「LOGIN AS A GUEST」ボタンから、メールアドレスとパスワードを入力せずにログインできます。

# 使用技術
- Next.js
- TypeScript
- MUI
- Ruby 3.1.2
- Ruby on Rails（APIモード） 7.0.8
- MySQL 8.0.32
- Nginx
- Puma
- AWS
  - VPC
  - ECS Fargate
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
- mainブランチへのpush時に、上記の４つが成功した場合はAWS Fargateへの自動デプロイが実行されます。

# 機能一覧
- ユーザー登録、ログイン機能、ログアウト機能
- タスク一覧機能
- 完了タスク一覧機能（カレンダー）
- タスク作成、更新、削除機能
- カテゴリー作成、更新、削除機能
- 招待機能
- レスポンス対応