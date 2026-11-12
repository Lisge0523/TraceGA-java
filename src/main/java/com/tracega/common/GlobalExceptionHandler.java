package com.tracega.common;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * 全局异常 → 响应体映射，对齐原版 {@code common/filters/http-exception.filter.ts}。
 *
 * <p>规则：异常 → HTTP 状态码 → 响应体里的 {@code code} 与状态码一致，{@code data} 恒为 null。
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(BizException.class)
    public ResponseEntity<ApiResponses.Err> handleBiz(BizException e) {
        return ResponseEntity.status(e.getStatus())
                .body(ApiResponses.Err.of(e.getStatus().value(), e.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponses.Err> handleValidation(MethodArgumentNotValidException e) {
        String msg = e.getBindingResult().getFieldErrors().stream()
                .findFirst()
                .map(f -> f.getField() + " " + f.getDefaultMessage())
                .orElse("参数校验失败");
        return ResponseEntity.badRequest().body(ApiResponses.Err.of(400, msg));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponses.Err> handleOther(Exception e) {
        log.error("unhandled exception", e);
        String msg = e.getMessage() == null ? "服务器内部错误" : e.getMessage();
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponses.Err.of(500, msg));
    }
}
