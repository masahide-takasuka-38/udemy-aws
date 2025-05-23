FROM python:3.9-slim

# 必要なシステムパッケージをインストール
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリを設定
WORKDIR /app

# Pythonの依存関係をインストール
COPY requirements.txt .
RUN pip install -r requirements.txt

# アプリケーションファイルをコピー
COPY . .

# ポートを公開
EXPOSE 8501

# Streamlitアプリを起動
CMD ["streamlit", "run", "app.py", "--server.address", "0.0.0.0"]