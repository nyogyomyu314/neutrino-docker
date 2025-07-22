# Step 1: ベースイメージの選択
# ドキュメント記載のUbuntu 20.04とCUDA 12.3、cuDNNをすべて満たす公式イメージを選択
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

# 環境変数を設定
ENV DEBIAN_FRONTEND=noninteractive

# Step 2: 依存関係のインストール
# ドキュメント記載のgccや、その他必要なツールをインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
  wget \
  unzip \
  ca-certificates \
  build-essential \
  # build-essential には gcc, g++, make が含まれる
  && rm -rf /var/lib/apt/lists/*

# Step 3: Python環境のセットアップ
# Jupyter Labの実行に必要なPythonをインストール
RUN apt-get update && apt-get install -y \
  python3 \
  python3-pip \
  && rm -rf /var/lib/apt/lists/*

# Step 4: NEUTRINO本体とモデルの導入
# ※URLは公式ドキュメントやダウンロードページで最新版を確認してください
RUN wget https://studio-neutrino.com/downloads/v2.7/NEUTRINO-online-v2.7.0.zip -O /tmp/neutrino.zip && \
  unzip /tmp/neutrino.zip -d /opt/ && \
  rm /tmp/neutrino.zip

# RUN wget https://studio-neutrino.com/wp-content/uploads/NEUTRINO-Model-Kirino-v-2-0-0.zip -O /tmp/model.zip && \
#   unzip /tmp/model.zip -d /opt/NEUTRINO/model/ && \
#   rm /tmp/model.zip

# Step 5: 実行権限の付与
# ドキュメント記載の通り、chmodで実行権限を与える
RUN chmod +x /opt/NEUTRINO/Run.sh

# Step 6: Pythonライブラリのインストール
# PyTorchはCUDA 12.1まで公式対応しているため、12.1用のものをインストール
# (PyTorchが12.3に追いついていない場合でも、通常は下位互換性により動作します)
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 && \
  pip3 install jupyterlab numpy

# 作業ディレクトリと起動コマンドの設定
WORKDIR /opt/NEUTRINO
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root", "--no-browser", "--NotebookApp.token=''"]