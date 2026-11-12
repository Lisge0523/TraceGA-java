# PARITY —— 差分用例清单

规则：**同一个请求，打原版和 Java 版，响应体必须逐字节一致**（忽略时间戳类字段）。

## 怎么跑

```bash
# 原版（NestJS）
cd TraceGA/packages/trace-server && pnpm start:dev      # :3100

# Java 版
cd java-server && SERVER_PORT=3000 mvn spring-boot:run  # :3000

# 对比
bash scripts/parity.sh POST /api/auth/login '{"email":"a@b.c","password":"123456"}'
```

## 用例

| # | 方法 | 路径 | 场景 | 结果 |
|---|---|---|---|---|
| 1 | POST | /api/auth/register | 正常注册 | ⬜ |
| 2 | POST | /api/auth/register | 邮箱重复 → 409 | ⬜ |
| 3 | POST | /api/auth/login | 正常登录 | ⬜ |
| 4 | POST | /api/auth/login | 密码错误 → 401 | ⬜ |
| 5 | POST | /api/auth/login | 失败 5 次锁定 → 429 | ⬜ |
| 6 | GET | /api/auth/profile | 带 token | ⬜ |
| 7 | GET | /api/auth/profile | 无 token → 401 | ⬜ |
| 8 | POST | /api/track | 单条上报 | ⬜ |
| 9 | POST | /api/track/batch | 批量上报（含去重） | ⬜ |
| 10 | GET | /api/analytics/overview | 概览 | ⬜ |
| 11 | GET | /api/analytics/event-trend | 趋势（注意时区） | ⬜ |
| 12 | GET | /api/event | 列表分页 | ⬜ |
| 13 | POST | /api/event | 创建（校验失败 → 400） | ⬜ |
| 14 | GET | /api/alarm | 告警列表 | ⬜ |
| 15 | POST | /api/ai/nl-query/stream | SSE 流式（比事件序列） | ⬜ |

## 记录格式

每个用例第一次跑通时，把原版响应贴进 `docs/fixtures/<编号>-<名称>.json`，CI 里可以离线比对。
