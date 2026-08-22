FROM python:3.10-slim

WORKDIR /app

# 安装依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制代码
COPY bot.py config.py database.py netease_api.py ./

# 暴露端口（Koyeb 会通过 $PORT 环境变量指定）
EXPOSE 8080

# 启动命令
CMD ["python", "bot.py"]
