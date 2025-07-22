# Step 1: ベースイメージの選択
# Neutrinoの要件(CUDA 11.8)を満たし、ビルド実績のある公式イメージを選択
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

# 環境変数を設定（apt-getの対話式プロンプトを無効化）
ENV DEBIAN_FRONTEND=noninteractive

# Step 2: 依存関係のインストール
# Neutrinoの実行に必要なツールやコンパイラ(build-essential)をインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
  wget \
  unzip \
  ca-certificates \
  build-essential \
  # build-essential には gcc, g++, make などが含まれる
  && rm -rf /var/lib/apt/lists/*

# Step 3: Python環境のセットアップ
# Jupyter Labや各種ライブラリの実行に必要なPythonをインストール
RUN apt-get update && apt-get install -y \
  python3 \
  python3-pip \
  && rm -rf /var/lib/apt/lists/*

# Step 4: NEUTRINO本体の導入
# 最新版のNEUTRINOをダウンロードし、/opt/ディレクトリに展開
RUN wget https://studio-neutrino.com/downloads/v2.7/NEUTRINO-online-v2.7.0.zip -O /tmp/neutrino.zip && \
  unzip /tmp/neutrino.zip -d /opt/ && \
  rm /tmp/neutrino.zip

# Step 4.1 (オプション): 追加モデルの導入
# 必要に応じて、追加の歌唱モデルをダウンロードする部分。現在は無効化。
# RUN wget https://studio-neutrino.com/wp-content/uploads/NEUTRINO-Model-Kirino-v-2-0-0.zip -O /tmp/model.zip && \
#   unzip /tmp/model.zip -d /opt/NEUTRINO/model/ && \
#   rm /tmp/model.zip

# Step 5: 実行権限の付与
# NEUTRINOの実行スクリプトに実行権限を与える
RUN chmod +x /opt/NEUTRINO/Run.sh

# Step 6: Pythonライブラリのインストール
# ベースイメージのCUDA 11.8に適合するPyTorchを専用リポジトリからインストールし、
# その他のライブラリ(jupyterlab, numpy)を標準リポジトリ(PyPI)からインストールする
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 && \
  pip3 install jupyterlab numpy

# Step 7: 作業ディレクトリと起動コマンドの設定
# コンテナ起動時の作業ディレクトリをNEUTRINOのフォルダに設定
WORKDIR /opt/NEUTRINO
# コンテナ起動時にJupyter Labを起動するコマンドを設定
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root", "--no-browser", "--NotebookApp.token=''"]