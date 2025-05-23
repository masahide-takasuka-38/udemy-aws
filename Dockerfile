FROM python:3.9-slim

# �K�v�ȃV�X�e���p�b�P�[�W���C���X�g�[��
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# ��ƃf�B���N�g����ݒ�
WORKDIR /app

# Python�̈ˑ��֌W���C���X�g�[��
COPY requirements.txt .
RUN pip install -r requirements.txt

# �A�v���P�[�V�����t�@�C�����R�s�[
COPY . .

# �|�[�g�����J
EXPOSE 8501

# Streamlit�A�v�����N��
CMD ["streamlit", "run", "app.py", "--server.address", "0.0.0.0"]