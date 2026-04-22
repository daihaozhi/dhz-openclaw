# dhz-openclaw

在远程 Ubuntu 主机上部署 `Qwen/Qwen3-4B`（`sglang` 推理服务），并提供给 OpenClaw 使用。

## 1. 场景说明

- 你的电脑（当前 Windows）只负责开发/上传脚本。
- 模型推理服务运行在你通过 SSH 连接的远程 Ubuntu 主机。
- OpenClaw 可以和推理服务在同一台远程机器，也可以在另一台机器，只要网络可达。

## 2. 仓库内容

- `scripts/remote/install_sglang.sh`：在远程 Ubuntu 安装 `sglang` 与依赖（Python venv）。
- `scripts/remote/start_sglang_qwen3.sh`：启动 `Qwen/Qwen3-4B` 的 OpenAI 兼容服务。
- `scripts/remote/check_sglang_openai.sh`：用 `curl` 快速验证接口是否可用。
- `config/openclaw.remote.env.example`：OpenClaw 对接该服务的环境变量模板。

## 3. 上传项目到远程 Ubuntu

在 Windows PowerShell 执行（把 `<user>` 和 `<host>` 换成你的 SSH 信息）：

```bash
scp -r d:\dhz-openclaw <user>@<host>:~/dhz-openclaw
```

然后 SSH 登录：

```bash
ssh <user>@<host>
cd ~/dhz-openclaw
```

## 4. 在远程 Ubuntu 安装与启动

### 4.1 安装（只需首次）

```bash
bash scripts/remote/install_sglang.sh
```

### 4.2 激活环境

```bash
source ~/venvs/sglang-qwen3/bin/activate
```

### 4.3 启动服务

```bash
bash scripts/remote/start_sglang_qwen3.sh
```

可选参数（按需）：

```bash
MODEL_PATH=Qwen/Qwen3-4B \
PORT=30000 \
TP_SIZE=1 \
MEM_FRACTION_STATIC=0.85 \
bash scripts/remote/start_sglang_qwen3.sh
```

说明：

- `TP_SIZE` 默认会自动取 GPU 数量；单卡时通常设 `1`。
- 服务默认监听 `0.0.0.0:30000`，OpenAI 兼容路径是 `/v1`。

## 5. 验证服务

在远程 Ubuntu 另开一个终端：

```bash
cd ~/dhz-openclaw
bash scripts/remote/check_sglang_openai.sh
```

若返回 JSON 且有 `choices` 字段，说明服务正常。

## 6. 对接 OpenClaw

把 `config/openclaw.remote.env.example` 拷贝为你的实际环境文件（例如 `.env`），并改成真实 IP：

```bash
OPENAI_BASE_URL=http://<REMOTE_UBUNTU_IP>:30000/v1
OPENAI_API_KEY=EMPTY
OPENAI_MODEL=Qwen/Qwen3-4B
```

你可以按 OpenClaw 实际读取的变量名保留其中一组（例如 `OPENAI_BASE_URL` 或 `OPENAI_API_BASE`）。

## 7. 常见问题

- 首次启动慢：模型需要下载，属于正常现象。
- 显存不足：先把 `TP_SIZE=1`，并降低 `MEM_FRACTION_STATIC`（如 `0.7`）。
- 外部无法访问：检查云主机安全组、防火墙、以及服务监听地址是否为 `0.0.0.0`。
- 连接超时：确认 OpenClaw 所在机器能访问 `http://<REMOTE_UBUNTU_IP>:30000/v1`。
