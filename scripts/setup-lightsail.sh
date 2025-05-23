#!/bin/bash

set -e

# 設定
SERVICE_NAME="\${1:-github-streamlit-app}"
POWER="\${2:-small}"
SCALE="\${3:-1}"
REGION="\${4:-ap-northeast-1}"

echo "🚀 Setting up Lightsail Container Service..."
echo "Service Name: \$SERVICE_NAME"
echo "Power: \$POWER"
echo "Scale: \$SCALE"
echo "Region: \$REGION"
echo "---"

# サービスが既に存在するかチェック
if aws lightsail get-container-services --service-name "\$SERVICE_NAME" --region "\$REGION" >/dev/null 2>&1; then
    echo "⚠️  Service '\$SERVICE_NAME' already exists!"
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! \$REPLY =~ ^[Yy]\$ ]]; then
        exit 1
    fi
fi

# サービスを作成
echo "Creating container service..."
aws lightsail create-container-service \
    --service-name "\$SERVICE_NAME" \
    --power "\$POWER" \
    --scale "\$SCALE" \
    --region "\$REGION"

echo "✅ Container service creation initiated!"
echo "⏳ Waiting for service to be ready..."

# サービスが準備完了するまで待機
for i in {1..20}; do
    sleep 30
    
    SERVICE_STATE=\$(aws lightsail get-container-services \
        --service-name "\$SERVICE_NAME" \
        --region "\$REGION" \
        --query 'containerServices[0].state' \
        --output text 2>/dev/null || echo "PENDING")
    
    echo "[\$i/20] Service state: \$SERVICE_STATE"
    
    if [ "\$SERVICE_STATE" = "READY" ]; then
        echo "🎉 Service is ready!"
        break
    elif [ "\$SERVICE_STATE" = "FAILED" ]; then
        echo "❌ Service creation failed!"
        exit 1
    fi
    
    if [ \$i -eq 20 ]; then
        echo "⏰ Timeout waiting for service to be ready"
        exit 1
    fi
done

echo ""
echo "📊 Service Information:"
aws lightsail get-container-services \
    --service-name "\$SERVICE_NAME" \
    --region "\$REGION"

echo ""
echo "✅ Setup completed successfully!"
echo "You can now deploy your application using GitHub Actions."