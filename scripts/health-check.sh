#!/bin/bash

SERVICE_NAME="\${1:-github-streamlit-app}"
REGION="\${2:-ap-northeast-1}"

echo "🏥 Performing health check for \$SERVICE_NAME..."

# サービスURLを取得
SERVICE_URL=\$(aws lightsail get-container-services \
    --service-name "\$SERVICE_NAME" \
    --region "\$REGION" \
    --query 'containerServices[0].url' \
    --output text)

if [ "\$SERVICE_URL" = "null" ] || [ -z "\$SERVICE_URL" ]; then
    echo "❌ Could not retrieve service URL"
    exit 1
fi

echo "🌐 Service URL: \$SERVICE_URL"

# ヘルスチェック実行
echo "Checking application health..."

for i in {1..5}; do
    if curl -f -s --max-time 30 "\$SERVICE_URL/_stcore/health" > /dev/null; then
        echo "✅ Health check passed!"
        echo "🌐 Application is healthy at: \$SERVICE_URL"
        exit 0
    else
        echo "⏳ Health check attempt \$i/5 failed, retrying in 10 seconds..."
        sleep 10
    fi
done

echo "❌ Health check failed after 5 attempts"
echo "Please check the service manually: \$SERVICE_URL"
exit 1