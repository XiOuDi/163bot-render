# 网易云音乐 Telegram Bot - Render 专用部署版

基于 [163music](https://github.com/XiOuDi/163music) v8.1 版本，专为 Render 平台部署优化。

## ✨ 功能特性

### 🎵 音乐播放
- **/play 关键词** - 搜索并播放歌曲
- **内联搜索** - 在任意聊天输入 `@XiOuDi163_bot 歌曲名` 搜索音乐
- **/playlist 歌单ID/链接** - 播放网易云歌单（仅限私聊）
- **歌单排队** - 用户已有歌单播放时，新歌单加入排队
- **歌单分批** - 超过1000首的歌单分批播放
- **5秒去重** - 5秒内不能向同一用户发送相同歌曲

### 📦 缓存优化
- **file_id 缓存** - 已发送的音频自动缓存，下次秒发
- **标题校验** - 自动检测并清理标题错误的缓存
- **闲时缓存** - 每天0点和12点自动更新闲时缓存歌单
- **漫游缓存** - 管理员可缓存指定网易云账号的所有歌单
- **手动缓存** - 管理员可手动缓存热歌榜或指定歌单

### 🔧 管理员功能
- **/admin** - 查看管理员面板
- **/toggleplaylist** - 开关歌单播放功能
- **/playliststop** - 查看/停止正在播放歌单的用户
- **/setcookie** - 设置网易云 Cookie
- **/refreshcookie** - 手动刷新 Cookie
- **/setquality** - 设置音质（standard/higher）
- **/cachetop** - 预热热歌榜前100首缓存
- **/cacheplaylist 歌单ID** - 缓存指定歌单
- **/cacheuser 用户ID** - 缓存指定账号的漫游歌曲
- **/broadcast 消息** - 向所有用户广播消息
- **/ban /unban** - 封禁/解封用户

### 💾 数据库配置
- 使用 Upstash Redis 作为数据库
- 支持从 Database 加载配置（BOT_TOKEN、ADMIN_ID、Cookie 等）
- Render 只需设置 2 个环境变量

### 🎨 其他特性
- ID3 标签嵌入（标题、艺术家、专辑、封面）
- 群组搜索分页显示（每页5条）
- 话题群组自动回复到对应话题
- 群组中 bot 发送音频带播放按钮
- 丰富的日志输出

## 🚀 Render 部署方法

### 1. 准备工作

#### 创建 Upstash Redis 数据库
1. 访问 [upstash.com](https://upstash.com) 注册账号
2. 创建 Redis 数据库
3. 在 Details 页面获取：
   - **REST URL**：例如 `https://xxx.upstash.io`
   - **REST Token**：例如 `xxxxxxxxxxxx`

#### 创建 Telegram Bot
1. 在 Telegram 中搜索 [@BotFather](https://t.me/BotFather)
2. 发送 `/newbot` 创建机器人
3. 获取 **Bot Token**

#### 获取网易云 Cookie
1. 浏览器登录 [网易云音乐](https://music.163.com)
2. F12 打开开发者工具
3. 在 Application → Cookies 中找到 `MUSIC_U`
4. 复制其值（很长的十六进制字符串）

### 2. 部署到 Render

#### 方式一：一键部署（推荐）

点击下方按钮一键部署：

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/XiOuDi/163bot-render)

#### 方式二：手动部署

1. Fork 本仓库到你的 GitHub
2. 登录 [Render](https://render.com)
3. 点击 **New +** → **Web Service**
4. 选择你 Fork 的仓库
5. 配置如下：

| 配置项 | 值 |
|--------|-----|
| Name | 任意名称（如 163music-bot） |
| Region | 选择离你近的区域 |
| Branch | main |
| Runtime | Docker |
| Instance Type | Free（免费）或 Starter |

### 3. 配置环境变量

在 Render 服务的 **Environment** 页面添加以下环境变量：

#### 必须配置（2个）

| 变量名 | 值 | 说明 |
|--------|-----|------|
| `UPSTASH_REDIS_REST_URL` | `https://xxx.upstash.io` | Upstash REST URL |
| `UPSTASH_REDIS_REST_TOKEN` | `xxxxxxxxxxxx` | Upstash REST Token |

#### 可选配置（从 Database 加载，也可在此设置默认值）

| 变量名 | 值 | 说明 |
|--------|-----|------|
| `BOT_TOKEN` | `123456:ABC-DEF...` | Telegram Bot Token |
| `ADMIN_ID` | `123456789` | 管理员 Telegram 数字 ID |
| `NETEASE_COOKIE` | `MUSIC_U 的值` | 网易云 Cookie |

> **注意**：如果配置了 Database 中的值，会优先使用 Database 中的配置。

### 4. 初始化 Database 配置

部署完成后，需要将配置写入 Upstash Database。可以通过以下方式：

#### 方式一：使用脚本（推荐）

运行以下 Python 脚本，将配置写入 Upstash：

```python
import requests

UPSTASH_URL = "https://xxx.upstash.io"  # 你的 Upstash REST URL
UPSTASH_TOKEN = "xxxxxxxxxxxx"  # 你的 Upstash REST Token
headers = {"Authorization": f"Bearer {UPSTASH_TOKEN}", "Content-Type": "application/json"}

config = {
    "bot:token": "你的Bot Token",
    "bot:admin_id": "你的管理员ID",
    "bot:cookie": "你的网易云MUSIC_U",
    "bot:quality": "standard",
}

for key, value in config.items():
    resp = requests.post(UPSTASH_URL, json=["SET", key, value], headers=headers)
    print(f"{key}: {resp.json().get('result')}")
```

#### 方式二：通过 Bot 命令设置

1. 先在 Render 环境变量中设置 `BOT_TOKEN` 和 `ADMIN_ID`
2. 部署完成后，在 Telegram 中给 Bot 发送 `/setcookie 你的MUSIC_U`
3. Bot 会自动将 Cookie 保存到 Database

### 5. 设置 Webhook

部署完成后，Render 会给你一个服务 URL（如 `https://163music-bot.onrender.com`）。

Bot 会自动设置 Webhook，无需手动操作。如果需要手动设置：

```
https://api.telegram.org/bot<你的Token>/setWebhook?url=https://你的服务URL/webhook
```

### 6. 完成！

在 Telegram 中给 Bot 发送 `/start`，如果收到欢迎消息，说明部署成功！

## 📋 命令列表

### 用户命令
| 命令 | 说明 |
|------|------|
| `/start` | 开始使用 |
| `/help` | 帮助信息 |
| `/play 关键词` | 搜索并播放歌曲 |
| `/music 关键词` | 提示命令已更改为 /play |
| `/playlist 歌单ID/链接` | 播放歌单（仅限私聊） |

### 管理员命令
| 命令 | 说明 |
|------|------|
| `/admin` | 管理员面板 |
| `/stats` | 查看统计 |
| `/toggleplaylist` | 开关歌单播放 |
| `/playliststop` | 停止用户歌单播放 |
| `/setcookie 值` | 设置 Cookie |
| `/refreshcookie` | 刷新 Cookie |
| `/setquality standard/higher` | 设置音质 |
| `/cachetop` | 缓存热歌榜 |
| `/cacheplaylist 歌单ID` | 缓存歌单 |
| `/cacheuser 用户ID` | 缓存漫游歌曲 |
| `/broadcast 消息` | 广播消息 |
| `/ban 用户ID` | 封禁用户 |
| `/unban 用户ID` | 解封用户 |

## 🔧 技术架构

### 文件结构
```
├── bot_v6.2.py          # 主程序
├── config.py            # 配置文件
├── database.py          # Upstash 数据库封装
├── downloader.py        # 优化下载模块
├── netease_api.py       # 网易云 API 封装
├── requirements.txt     # Python 依赖
├── Dockerfile           # Docker 配置
├── render.yaml          # Render 配置
└── README.md            # 说明文档
```

### 代理策略（Render 专用版）
| 场景 | 方式 |
|------|------|
| 歌单播放 | Render 下载（带 ID3 标签） |
| 普通播放 /play | Render 下载（带 ID3 标签） |
| 缓存任务 | Render 下载（带 ID3 标签） |
| 内联搜索 | Render 代理端点 |

### Database 存储的配置
| Key | 说明 |
|-----|------|
| `bot:token` | Telegram Bot Token |
| `bot:admin_id` | 主管理员 ID |
| `bot:cookie` | 网易云 Cookie |
| `bot:quality` | 音质设置 |
| `bot:welcome` | 欢迎语 |
| `bot:playlist_enabled` | 歌单播放开关 |
| `cache:file_id:*` | 音频 file_id 缓存 |
| `playlist:*` | 歌单播放状态 |

## ❓ 常见问题

### Q: Bot 没有响应？
A: 检查 Render 日志，确认服务启动成功。检查 Webhook 是否设置正确。

### Q: 播放歌曲失败？
A: 检查网易云 Cookie 是否过期，使用 `/refreshcookie` 刷新或 `/setcookie` 重新设置。

### Q: 如何获取我的 Telegram 数字 ID？
A: 在 Telegram 中搜索 [@userinfobot](https://t.me/userinfobot)，发送任意消息即可获取。

### Q: Render 免费版会休眠吗？
A: 是的，15分钟无请求会休眠。可以使用 [UptimeRobot](https://uptimerobot.com) 定时访问服务 URL 保持唤醒。

### Q: 如何更新 Bot？
A: 更新代码后推送到 GitHub，Render 会自动重新部署。

## 📄 许可证

MIT License

## 🤝 致谢

- [NeteaseCloudMusicApi](https://github.com/Binaryify/NeteaseCloudMusicApi) - 网易云音乐 API
- [python-telegram-bot](https://github.com/python-telegram-bot/python-telegram-bot) - Telegram Bot 框架
- [Upstash](https://upstash.com) - Redis 数据库服务
- [Render](https://render.com) - 云部署平台

## 🔗 相关链接

- 原仓库：https://github.com/XiOuDi/163music
- Render 部署文档：https://render.com/docs
- Upstash 文档：https://docs.upstash.com
