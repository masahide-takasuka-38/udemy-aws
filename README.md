# 在庫管理最適化アプリケーション

線形計画法を使用して在庫管理の最適化問題を解決するStreamlitベースのWebアプリケーションです。

## 機能

- 月ごとの需要に基づいた最適な発注計画の計算
- 在庫保管コスト、欠品コスト、段取りコストを考慮した総コストの最小化
- 結果の可視化（表とグラフ）

## ファイル構成

```
.
├── app.py                    # メインアプリケーション
├── requirements.txt          # Python依存関係
├── Dockerfile               # Dockerイメージ定義
├── .github/
│   └── workflows/
│       └── deploy.yml       # GitHub Actionsワークフロー
├── .gitignore              # Git除外ファイル
└── README.md               # このファイル
```

## デプロイ設定

GitHub ActionsとAWS Lightsailを使用した自動デプロイ。

### 前提条件

1. AWS アカウントの作成
2. AWS CLIの設定
3. IAMユーザーの作成と権限設定

### セットアップ手順

#### 1. IAMユーザーの作成と権限設定

AWS Management Consoleで以下の手順を実行：

1. IAM → ユーザー → 「ユーザーを作成」
2. ユーザー名: `github-actions-lightsail`
3. 「次へ」→「ポリシーを直接アタッチ」
4. 以下のポリシーをアタッチ：
   - `AmazonLightsailFullAccess`

5. カスタムポリシーを作成（オプション - より制限的な権限の場合）：
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "lightsail:CreateContainerService",
                "lightsail:CreateContainerServiceDeployment",
                "lightsail:GetContainerServices",
                "lightsail:GetContainerServiceDeployments",
                "lightsail:GetContainerImages",
                "lightsail:UpdateContainerService",
                "lightsail:PushContainerImage",
                "lightsail:RegisterContainerImage",
                "lightsail:TagResource"
            ],
            "Resource": "*"
        }
    ]
}
```

6. 「ユーザーを作成」をクリック
7. 作成したユーザーを選択 → 「セキュリティ認証情報」タブ
8. 「アクセスキーを作成」→ 「Command Line Interface (CLI)」を選択
9. アクセスキーIDとシークレットアクセスキーを保存

#### 2. AWS CLIでの確認（ローカル環境）

```bash
# AWS CLIの設定
aws configure
# - AWS Access Key ID: 上記で取得したアクセスキーID
# - AWS Secret Access Key: 上記で取得したシークレットアクセスキー
# - Default region name: ap-northeast-1
# - Default output format: json

# Lightsailサービスの利用可能確認
aws lightsail get-container-services --region ap-northeast-1
```

### GitHub Secretsの設定

1. リポジトリの Settings → Secrets and variables → Actions
2. 「New repository secret」をクリックして以下を追加：
   - `AWS_ACCESS_KEY_ID`: IAMユーザーのアクセスキーID
   - `AWS_SECRET_ACCESS_KEY`: IAMユーザーのシークレットアクセスキー

## デプロイ

mainブランチにプッシュすると自動デプロイ：

```bash
git add .
git commit -m "Deploy to AWS Lightsail"
git push origin main
```

初回デプロイには10-15分程度かかることがあります。

## アプリケーションの仕様

- **サービス名**: inventory-optimization-app
- **リージョン**: ap-northeast-1（東京）
- **コンテナサイズ**: nano（512MB RAM, 0.25 vCPU）
- **スケール**: 1
- **認証**: 不要（パブリックアクセス可能）
- **ポート**: 8501

### コンテナサイズの変更

`deploy.yml`の`CONTAINER_POWER`を変更することで、コンテナのサイズを調整できます：

- `nano`: 512MB RAM, 0.25 vCPU（最小、月額$7）
- `micro`: 1GB RAM, 0.5 vCPU（月額$10）
- `small`: 2GB RAM, 1 vCPU（月額$25）
- `medium`: 4GB RAM, 2 vCPU（月額$50）
- `large`: 8GB RAM, 4 vCPU（月額$100）
- `xlarge`: 16GB RAM, 8 vCPU（月額$200）

## トラブルシューティング

### デプロイメントの状態確認

```bash
# コンテナサービスの状態確認
aws lightsail get-container-services \
  --service-name inventory-optimization-app \
  --region ap-northeast-1

# デプロイメントの履歴確認
aws lightsail get-container-service-deployments \
  --service-name inventory-optimization-app \
  --region ap-northeast-1

# コンテナログの確認
aws lightsail get-container-log \
  --service-name inventory-optimization-app \
  --container-name app \
  --region ap-northeast-1
```

### 手動デプロイ（緊急時）

```bash
# Dockerイメージのビルド
docker build -t inventory-optimization-app:latest .

# Lightsailへのプッシュ
aws lightsail push-container-image \
  --service-name inventory-optimization-app \
  --label app-manual \
  --image inventory-optimization-app:latest \
  --region ap-northeast-1
```

### よくある問題と解決策

1. **デプロイが失敗する**
   - IAMユーザーの権限を確認
   - GitHub Secretsが正しく設定されているか確認
   - Dockerfileのビルドエラーをローカルで確認

2. **アプリケーションがアクセスできない**
   - コンテナサービスのステータスがACTIVEか確認
   - ヘルスチェックが成功しているか確認

3. **コストを抑えたい**
   - 開発時は`nano`サイズを使用
   - 不要になったら`disable`コマンドでサービスを無効化

## クリーンアップ

リソースを削除してコストを停止：

```bash
# コンテナサービスの削除
aws lightsail delete-container-service \
  --service-name inventory-optimization-app \
  --region ap-northeast-1

# IAMユーザーの削除（AWSコンソールから）
# IAM → ユーザー → github-actions-lightsail → 削除
```

## 料金の目安

- **nano（最小構成）**: 約$7/月
- **データ転送**: 最初の1TB無料、以降$0.12/GB
- **コンテナイメージストレージ**: 最初の50GB無料

## 参考リンク

- [AWS Lightsail Container Services](https://aws.amazon.com/jp/lightsail/features/containers/)
- [Lightsail 料金](https://aws.amazon.com/jp/lightsail/pricing/)
- [Lightsail CLI リファレンス](https://docs.aws.amazon.com/cli/latest/reference/lightsail/)
