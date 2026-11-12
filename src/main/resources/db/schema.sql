-- TraceGA 表结构（MySQL 8.0）
-- 来源：TraceGA/packages/trace-server/prisma/schema.prisma（基准提交 3db7ee2）
-- 说明：原项目用 `prisma db push` 建表，没有 migrations 目录，所以这里按 schema.prisma 手写出等价 DDL。
-- 与原版的差异：无（表名、列名、类型、默认值、索引名逐一对照）。
--
-- 用法：
--   mysql -uroot -p -e "CREATE DATABASE IF NOT EXISTS tracega_java DEFAULT CHARSET utf8mb4"
--   mysql -uroot -p tracega_java -e "source E:/TraceGA/java-server/src/main/resources/db/schema.sql"

SET NAMES utf8mb4;

-- ---------------------------------------------------------------- user
CREATE TABLE IF NOT EXISTS `user` (
  `id`            BIGINT       NOT NULL AUTO_INCREMENT,
  `username`      VARCHAR(64)  NOT NULL,
  `password_hash` VARCHAR(128) NULL,
  `name`          VARCHAR(64)  NOT NULL,
  `phone`         VARCHAR(32)  NULL,
  `avatar`        VARCHAR(255) NULL,
  `email`         VARCHAR(128) NULL,
  `role`          VARCHAR(32)  NULL DEFAULT 'admin',
  `status`        TINYINT      NULL DEFAULT 1,
  `last_login_at` DATETIME(0)  NULL,
  `created_at`    DATETIME(0)  NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    DATETIME(0)  NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `phone` (`phone`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------- project
CREATE TABLE IF NOT EXISTS `project` (
  `id`           BIGINT       NOT NULL AUTO_INCREMENT,
  `project_id`   VARCHAR(64)  NOT NULL,
  `project_name` VARCHAR(128) NOT NULL,
  `owner`        VARCHAR(64)  NULL,
  `created_at`   DATETIME(0)  NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------- event_definition
CREATE TABLE IF NOT EXISTS `event_definition` (
  `id`           BIGINT       NOT NULL AUTO_INCREMENT,
  `project_id`   VARCHAR(64)  NOT NULL,
  `event_name`   VARCHAR(128) NOT NULL,
  `event_type`   VARCHAR(64)  NULL,
  `event_desc`   VARCHAR(255) NULL,
  `param_schema` JSON         NULL,
  `status`       TINYINT      NULL DEFAULT 1,
  `created_at`   DATETIME(0)  NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`   DATETIME(0)  NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------- event_log
CREATE TABLE IF NOT EXISTS `event_log` (
  `id`            BIGINT       NOT NULL AUTO_INCREMENT,
  `project_id`    VARCHAR(64)  NOT NULL,
  `event_name`    VARCHAR(128) NOT NULL,
  `event_type`    VARCHAR(64)  NULL,
  `occurred_at`   DATETIME(0)  NULL,
  `uid`           VARCHAR(128) NULL,
  `session_id`    VARCHAR(128) NULL,
  `page_url`      VARCHAR(512) NULL,
  `event_params`  JSON         NULL,
  `common_params` JSON         NULL,
  `user_agent`    TEXT         NULL,
  `ip`            VARCHAR(64)  NULL,
  `created_at`    DATETIME(0)  NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_event_page_url` (`page_url`),
  KEY `idx_event_project_name_time` (`project_id`, `event_name`, `created_at`),
  KEY `idx_event_project_name_uid_time` (`project_id`, `event_name`, `uid`, `created_at`),
  KEY `idx_event_project_occurred_at` (`project_id`, `occurred_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------- event_daily_stat
CREATE TABLE IF NOT EXISTS `event_daily_stat` (
  `id`         BIGINT       NOT NULL AUTO_INCREMENT,
  `stat_date`  DATE         NOT NULL,
  `project_id` VARCHAR(64)  NOT NULL,
  `event_name` VARCHAR(128) NOT NULL,
  `pv`         BIGINT       NULL DEFAULT 0,
  `uv`         BIGINT       NULL DEFAULT 0,
  `created_at` DATETIME(0)  NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_daily_project_event_date` (`project_id`, `event_name`, `stat_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------- alarm
CREATE TABLE IF NOT EXISTS `alarm` (
  `id`          BIGINT        NOT NULL AUTO_INCREMENT,
  `project_id`  VARCHAR(64)   NOT NULL,
  `event_name`  VARCHAR(128)  NOT NULL,
  `threshold`   DECIMAL(10,2) NULL,
  `operator`    VARCHAR(16)   NULL,
  `notify_type` VARCHAR(32)   NULL,
  `status`      TINYINT       NULL DEFAULT 1,
  `created_at`  DATETIME(0)   NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  DATETIME(0)   NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
