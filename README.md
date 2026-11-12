# TraceGA-java

TraceGA 事件分析平台服务端的 **Java / Spring Boot 重写实现**。原项目是 TypeScript + NestJS 写的，
本仓库把服务端逐模块迁移到 Java，并用**差分测试**证明迁移前后行为一致。

> 这是一个"迁移"项目，不是"新项目"。它的价值在于：同一套接口、同一个数据库、同一个前端，
> 换一种语言重新实现，并且能证明换完之后前端一行都不用改。

## 来源与授权

- 原始项目：[1zrj/TraceGA](https://github.com/1zrj/TraceGA)（团队项目，10 位贡献者）
- 我的 fork 与原始贡献：[Lisge0523/TraceGA](https://github.com/Lisge0523/TraceGA)
- 移植基准：`Lisge0523/TraceGA@3db7ee2`（`packages/trace-server/src` 共 89 个文件、40 个 HTTP 接口）
- 原项目未附带开源许可证。本仓库**仅作个人学习与求职展示**，未获商用授权，也不代表原作者观点。
- 本仓库的 Java 代码由我独立编写；接口契约、数据库结构、业务规则均来自上述原项目。

## 技术栈

| 层 | 选型 | 说明 |
|---|---|---|
| 运行时 | JDK 21 | record、switch 模式匹配 |
| 框架 | Spring Boot 3.3 | Web MVC（**不用 WebFlux**：原版是同步 controller + 手写 SSE） |
| 持久层 | MyBatis 3 + MySQL 8 | 与原项目同一套表结构；聚合查询用 XML 手写，便于 EXPLAIN |
| 鉴权 | jjwt | 兼容原版手写 HS256 token |
| AI | RestClient + SseEmitter | 对应原版 `glm-client` + 手写 SSE |
| 文档 | springdoc-openapi | 原版没有 Swagger，这里补上 |

## 快速开始

前置：JDK 21、MySQL 8、Maven 3.9+（没有 Maven 可以 `winget install Apache.Maven`，或直接用 IDEA 自带的）。

```bash
# 1. 建库并导入表结构（schema 来自原项目 prisma/schema.prisma）
mysql -uroot -p -e "CREATE DATABASE IF NOT EXISTS tracega DEFAULT CHARSET utf8mb4"
mysql -uroot -p tracega < src/main/resources/db/schema.sql   # 见下方「待办」

# 2. 配置连接（默认连 127.0.0.1:3306/tracega，root 空密码）
export DB_USER=root
export DB_PASSWORD=你的密码

# 3. 启动，端口 3000 —— 与原 NestJS 服务一致，前端无需改动
mvn spring-boot:run

# 4. 验证
curl http://127.0.0.1:3000/actuator/health
```

## 进度

| 里程碑 | 范围 | 状态 |
|---|---|---|
| M0 | 骨架、响应体契约、全局异常 | ✅ |
| M1 | auth（注册/登录/登出/资料） | ⬜ |
| M2 | event + track（事件上报、批量上报） | ⬜ |
| M3 | analytics（概览/趋势/Top） | ⬜ |
| M4 | alarm + analysis | ⬜ |
| M5 | error（聚合查询 + sourcemap） | ⬜ |
| M6 | ai（NL 查询 + SSE 流式） | ⬜ |

进度以 `docs/PORTING.md` 的清单为准。

## 契约验证

迁移正确性不靠"看起来一样"，靠对比：

```bash
# 同一个请求，分别打原版(3100)和 Java 版(3000)，diff 响应体
bash scripts/parity.sh POST /api/auth/login '{"email":"a@b.c","password":"123456"}'
```

用例清单见 `docs/PARITY.md`。

## 目录结构

```
src/main/java/com/tracega/
├── common/        # 响应体、异常、拦截器、工具
├── config/        # 配置类
└── modules/       # 按业务模块分包：auth / event / track / analytics / alarm / analysis / error / ai
src/main/resources/
├── application.yml
├── mapper/        # MyBatis XML
└── prompts/       # AI 提示词模板
```

## 联系

刘双根 · [GitHub](https://github.com/Lisge0523) · 178446164@qq.com
