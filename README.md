# GitHub Repository Manager

Streamlitベースのギットハブリポジトリ管理アプリケーション

## 🚀 デプロイメント

### 前提条件

1. GitHub Personal Access Token
2. AWS アカウントと適切な権限
3. Docker Hub アカウント（オプション）

### GitHub Secrets設定

以下のシークレットをGitHubリポジトリに設定してください：

- `AWS_ACCESS_KEY_ID`: AWS アクセスキーID
- `AWS_SECRET_ACCESS_KEY`: AWS シークレットアクセスキー
- `DOCKER_USERNAME`: Docker Hubユーザー名
- `DOCKER_PASSWORD`: Docker Hubパスワード

### 初回セットアップ

1. `.github/workflows/setup-lightsail.yml`ワークフローを手動実行
2. `main`ブランチにプッシュしてデプロイ開始

## 🛠️ ローカル開発

```bash
# 依存関係をインストール
pip install -r app/requirements.txt

# アプリケーション実行
streamlit run app/app.py
📁 プロジェクト構造
├── .github/workflows/     # GitHub Actionsワークフロー
├── app/                   # Streamlitアプリケーション
├── scripts/              # セットアップスクリプト
├── config/               # 設定ファイル
└── Dockerfile            # Dockerイメージ設定

## 3. セットアップ手順

### ステップ1: リポジトリ作成
```bash
# 新しいリポジトリを作成
mkdir github-streamlit-app
cd github-streamlit-app
git init
ステップ2: ファイル作成
上記のファイル構造に従って全てのファイルを作成します。

ステップ3: GitHub Secrets設定
GitHubリポジトリの Settings → Secrets and variables → Actions で以下を設定：

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
DOCKER_USERNAME
DOCKER_PASSWORD
ステップ4: 初回セットアップ
リポジトリをGitHubにプッシュ
GitHub Actions タブで「Setup Lightsail Container Service」ワークフローを手動実行
完了後、mainブランチにプッシュしてデプロイ開始
ステップ5: 確認
デプロイ完了後、Lightsailコンソールまたは提供されたURLでアプリケーションにアクセス。

この構成により、コードをプッシュするたびに自動的にLightsailにデプロイされます。