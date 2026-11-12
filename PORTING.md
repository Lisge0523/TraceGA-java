# PORTING —— 模块迁移对照表

基准：`Lisge0523/TraceGA@3db7ee2`，`packages/trace-server/src`（89 个 .ts，40 个 HTTP 接口）。

## 0. 表结构（已完成 ✅）

原项目用 `prisma db push` 建库，**没有 migrations 目录**，所以 `prisma migrate diff` 那条路走不通（引擎会报 EPERM / 需要联网）。
这里改为按 `prisma/schema.prisma` 手写等价 DDL，已落到 `src/main/resources/db/schema.sql`：

- 6 张表：`user`、`project`、`event_definition`、`event_log`、`event_daily_stat`、`alarm`
- 外键：**无**（原 schema 里没有定义任何 relation）
- 索引：`event_log` 4 个、`event_daily_stat` 1 个、`project.project_id` 唯一、`user` 的 `username/phone/email` 唯一
- 已实测导入本地 MySQL 8 并核对过索引清单

本地库：`tracega_java`（与 Node 版的 `tracega` 分开，便于两个服务同时跑做差分）。


## 1. 模块对照

| NestJS 模块 | 文件数 | Java 包 | 接口数 | 状态 |
|---|---|---|---|---|
| `modules/auth` | 7 | `modules/auth` | 4 | ⬜ |
| `modules/event` | 8 | `modules/event` | 5 | ⬜ |
| `modules/track` | 15 | `modules/track` | 2 | ⬜ |
| `modules/analytics` | — | `modules/analytics` | 7 | ⬜ |
| `modules/analysis` | 6 | `modules/analysis` | 3 | ⬜ |
| `modules/alarm` | 6 | `modules/alarm` | 2 | ⬜ |
| `modules/error` | 11 | `modules/error` | 7 | ⬜ |
| `modules/ai` | 19 | `modules/ai` | 10 | ⬜ |
| `common` | — | `common` | — | 🟡 响应体/异常已完成 |

## 2. 小厂版范围（15–20 接口）

auth 4 + event 5 + track 2 + analytics 3~4 + alarm 2 + ai（NL 查询 + 1 个 SSE）。

**砍掉**：sourcemap VLQ、全量差分、压测、Flyway、springdoc 全量注解。

## 3. 已知的坑（按踩到的顺序）

1. **响应体字段名不一致**：成功用 `message`，异常用 `msg`。已用 `ApiResponses.Ok/Err` 两个 record 固化。
2. **BIGINT 序列化**：原版 `main.ts` 里 `BigInt.prototype.toJSON` 把 BigInt 转字符串。Java 的 `Long` 默认输出数字，超过 2^53 前端会精度丢失。→ 统一用 `@JsonSerialize(using = ToStringSerializer.class)` 或全局配置。
3. **时区**：MySQL 连接串带 `serverTimezone=Asia/Shanghai`，Jackson 也设了，两边必须一致，否则趋势图差 8 小时。
4. **`JSON_EXTRACT` 动态路径**：原版 error 模块用字符串拼 SQL。Java 侧必须改成参数化 + 白名单校验路径（这是可以主动讲的安全改进）。
5. **异常 → 状态码**：Nest 的 `HttpException` 语义是 code 即 HTTP 状态码，`@RestControllerAdvice` 要显式设置 `ResponseEntity.status(...)`，否则全是 200。

## 4. 每完成一个模块的验收

- [ ] 接口能通（curl 返回 200）
- [ ] 响应体与 `docs/PARITY.md` 里记录的原版响应逐字段一致
- [ ] 至少 1 个单测（正常 + 异常）
- [ ] 打开 `/swagger-ui.html` 能看到这个模块的接口
