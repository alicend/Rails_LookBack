# アプリケーション概要
達成したタスクを見返すことで作業のモチベーションアップを目的とした、タスク管理ツールです。

# URL
https://lookback-calendar.com/ <br >
画面中部の「LOGIN AS A GUEST」ボタンから、メールアドレスとパスワードを入力せずにログインできます。

# 使用技術
- Next.js 12.3.4
- TypeScript 5.0.4
- MUI 5.13.6
- react-big-calendar 1.8.1
- Tailwind CSS 3.3.2
- Redux Toolkit
- Zod 3.21.4
- Eslint 9.0.0
- Prettier 3.0.3
- axios 1.4.0
- Jest 29.7.0
- Ruby 3.1.2
- Ruby on Rails（APIモード） 7.0.8
- MySQL 8.0.32
- Nginx
- Puma
- AWS
  - VPC
  - ECS Fargate
  - ECR
  - RDS
  - ALB
  - Route53
- Docker/Docker-compose
- Github Actions
- RSpec

## Github Actions
- Githubへのpush時に、「Rspec」「Jest」「Rubocop」「Eslint」が自動で実行されます。
- mainブランチへのpush時に、上記の４つが成功した場合はECS Fargateへの自動デプロイが実行されます。

# AWS構成図
<img width="995" alt="" src="https://github.com/alicend/Rails_LookBack/assets/86368377/d9bef69e-fde5-49cb-b9d1-3f781d26dffc">

# 機能一覧
- ユーザー登録、ログイン機能、ログアウト機能
- タスク一覧機能（タスクボード）
- タスク一覧機能（カレンダー）
- タスク詳細表示機能（タスクボード）
- タスク詳細表示機能（カレンダー）
- タスク作成、更新、削除機能
- カテゴリー作成、更新、削除機能
- グループ機能
- 招待機能
- レスポンシブ対応
