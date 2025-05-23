FROM python:3.9-slim

WORKDIR /app

# 依存関係をインストール
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# アプリケーションファイルをコピー
COPY app.py .

# Streamlitの設定
RUN mkdir -p /root/.streamlit
RUN echo '[server]\nheadless = true\nport = 8501\naddress = "0.0.0.0"\n' > /root/.streamlit/config.toml

EXPOSE 8501

CMD ["streamlit", "run", "app.py"]
