package com.tracega.common;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 契约测试：把响应体的<b>字节级形状</b>钉死。
 * 这几个断言看着像废话，但它们是"对齐原版"的第一道防线 —— 字段名、字段顺序、null 字段。
 */
class ApiResponsesTest {

    private final ObjectMapper mapper = new ObjectMapper();

    record Payload(long id, String name) {
    }

    @Test
    void successShapeMatchesNest() throws Exception {
        String json = mapper.writeValueAsString(ApiResponses.Ok.of(new Payload(1L, "a")));
        assertThat(json).isEqualTo("{\"code\":200,\"message\":\"success\",\"data\":{\"id\":1,\"name\":\"a\"}}");
    }

    @Test
    void errorShapeMatchesNest() throws Exception {
        String json = mapper.writeValueAsString(ApiResponses.Err.of(401, "未登录"));
        assertThat(json).isEqualTo("{\"code\":401,\"data\":null,\"msg\":\"未登录\"}");
    }

    @Test
    void errorKeepsNullDataField() throws Exception {
        // 前端靠 data === null 判断失败分支，字段被省略会静默走错分支
        String json = mapper.writeValueAsString(ApiResponses.Err.of(500, "boom"));
        assertThat(json).contains("\"data\":null");
    }
}
