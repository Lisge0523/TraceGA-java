package com.tracega;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * TraceGA 服务端的 Java 重写版本。
 *
 * <p>移植自 <a href="https://github.com/1zrj/TraceGA">1zrj/TraceGA</a> 的 NestJS 实现，
 * 基准提交 {@code 3db7ee2}。原始实现由 10 位贡献者共同完成，本仓库仅作个人学习与求职展示，
 * 未获得商用授权。来源与授权说明见 README。
 *
 * <p>Mapper 接口请用 {@code @Mapper} 显式标注，本项目不做包扫描。
 */
@SpringBootApplication
public class TracegaApplication {

    public static void main(String[] args) {
        SpringApplication.run(TracegaApplication.class, args);
    }
}
