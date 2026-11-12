package com.tracega.common;

/**
 * 响应体契约 —— 与 NestJS 版<b>逐字段</b>对齐，这是移植第一个要踩的坑。
 *
 * <p>原版成功响应（{@code common/interceptors/transform.interceptor.ts}）：
 * <pre>{"code":200,"message":"success","data": ...}</pre>
 * 原版异常响应（{@code common/filters/http-exception.filter.ts}）：
 * <pre>{"code":401,"data":null,"msg":"用户名或密码错误"}</pre>
 *
 * <p>注意两者字段名不同：一个是 {@code message}，另一个是 {@code msg}。
 * 不要"统一"成一种 —— 前端按字段名取错误文案，改了就静默失效。
 */
public final class ApiResponses {

    private ApiResponses() {
    }

    /** 成功：{@code {code, message, data}}。 */
    public record Ok<T>(int code, String message, T data) {

        public static <T> Ok<T> of(T data) {
            return new Ok<>(200, "success", data);
        }
    }

    /** 失败：{@code {code, data:null, msg}}，data 恒为 null 但必须保留字段。 */
    public record Err(int code, Object data, String msg) {

        public static Err of(int code, String msg) {
            return new Err(code, null, msg);
        }
    }
}
