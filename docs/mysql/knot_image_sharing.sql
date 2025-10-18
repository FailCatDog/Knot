/*
 Navicat Premium Dump SQL

 Source Server         : 阿里云mysql
 Source Server Type    : MySQL
 Source Server Version : 80043 (8.0.43-0ubuntu0.22.04.2)
 Source Host           : 8.138.115.164:3306
 Source Schema         : knot_image_sharing

 Target Server Type    : MySQL
 Target Server Version : 80043 (8.0.43-0ubuntu0.22.04.2)
 File Encoding         : 65001

 Date: 18/10/2025 17:32:07
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for favorites
-- ----------------------------
DROP TABLE IF EXISTS `favorites`;
CREATE TABLE `favorites`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '收藏记录ID',
  `user_id` bigint NOT NULL COMMENT '收藏用户ID',
  `post_id` bigint NOT NULL COMMENT '被收藏的帖子ID',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_post`(`user_id` ASC, `post_id` ASC) USING BTREE,
  INDEX `idx_post_id`(`post_id` ASC) USING BTREE COMMENT '按帖子查询收藏列表',
  INDEX `idx_user_create`(`user_id` ASC, `create_time` DESC) USING BTREE COMMENT '按用户查询点赞历史',
  CONSTRAINT `favorites_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `favorites_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '收藏记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for follows
-- ----------------------------
DROP TABLE IF EXISTS `follows`;
CREATE TABLE `follows`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '物理ID（自增主键）',
  `follower_id` bigint NOT NULL COMMENT '关注者ID（A关注B，A是follower）',
  `followee_id` bigint NOT NULL COMMENT '被关注者ID（A关注B，B是followee）',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '关注时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_follower_followee`(`follower_id` ASC, `followee_id` ASC) USING BTREE,
  INDEX `idx_follower_create`(`follower_id` ASC, `create_time` DESC) USING BTREE COMMENT '查询\"我关注的人\"列表',
  INDEX `idx_followee_create`(`followee_id` ASC, `create_time` DESC) USING BTREE COMMENT '查询\"关注我的人\"列表',
  CONSTRAINT `fk_follows_followee` FOREIGN KEY (`followee_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_follows_follower` FOREIGN KEY (`follower_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '关注关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for image_tags
-- ----------------------------
DROP TABLE IF EXISTS `image_tags`;
CREATE TABLE `image_tags`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '物理ID（自增主键）',
  `image_id` bigint NOT NULL COMMENT '图片ID',
  `tag_id` bigint NOT NULL COMMENT '标签ID',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_image_tag`(`image_id` ASC, `tag_id` ASC) USING BTREE,
  INDEX `tag_id`(`tag_id` ASC) USING BTREE,
  CONSTRAINT `image_tags_ibfk_1` FOREIGN KEY (`image_id`) REFERENCES `images` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `image_tags_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '图片标签关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for images
-- ----------------------------
DROP TABLE IF EXISTS `images`;
CREATE TABLE `images`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '物理ID（自增主键）',
  `image_id` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '业务逻辑ID（例：IMG_2025Q4_ABC123）',
  `post_id` bigint NOT NULL COMMENT '所属帖子ID',
  `display_order` int NOT NULL DEFAULT 0 COMMENT '显示顺序（0-8）',
  `user_id` bigint NOT NULL COMMENT '上传用户ID',
  `file_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '原图URL',
  `thumbnail_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '缩略图URL',
  `file_size` bigint NOT NULL COMMENT '文件大小（字节）',
  `width` int NULL DEFAULT NULL COMMENT '图片宽度',
  `height` int NULL DEFAULT NULL COMMENT '图片高度',
  `mime_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'MIME类型（image/jpeg, image/png, image/webp）',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `image_id`(`image_id` ASC) USING BTREE,
  INDEX `idx_image_id`(`image_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE,
  INDEX `idx_post_id`(`post_id` ASC) USING BTREE,
  INDEX `idx_post_order`(`post_id` ASC, `display_order` ASC) USING BTREE,
  CONSTRAINT `images_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `images_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 142 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '图片信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for likes
-- ----------------------------
DROP TABLE IF EXISTS `likes`;
CREATE TABLE `likes`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '点赞记录ID',
  `user_id` bigint NOT NULL COMMENT '点赞用户ID',
  `post_id` bigint NOT NULL COMMENT '被点赞的帖子ID',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_post`(`user_id` ASC, `post_id` ASC) USING BTREE,
  INDEX `idx_post_id`(`post_id` ASC) USING BTREE COMMENT '按帖子查询点赞列表',
  INDEX `idx_user_create`(`user_id` ASC, `create_time` DESC) USING BTREE COMMENT '按用户查询点赞历史',
  CONSTRAINT `likes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `likes_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '点赞记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for post_tags
-- ----------------------------
DROP TABLE IF EXISTS `post_tags`;
CREATE TABLE `post_tags`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '物理ID（自增主键）',
  `post_id` bigint NOT NULL COMMENT '帖子ID',
  `tag_id` bigint NOT NULL COMMENT '标签ID',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_post_tag`(`post_id` ASC, `tag_id` ASC) USING BTREE,
  INDEX `idx_post_id`(`post_id` ASC) USING BTREE,
  INDEX `idx_tag_id`(`tag_id` ASC) USING BTREE,
  CONSTRAINT `post_tags_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `post_tags_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 85 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '帖子标签关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for posts
-- ----------------------------
DROP TABLE IF EXISTS `posts`;
CREATE TABLE `posts`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '物理ID（自增主键）',
  `post_id` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '业务逻辑ID（例：POST_2025Q4_ABC123）',
  `user_id` bigint NOT NULL COMMENT '发布用户ID',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '帖子标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '帖子配文',
  `image_count` int NOT NULL DEFAULT 0 COMMENT '图片数量',
  `like_count` int NOT NULL DEFAULT 0 COMMENT '点赞数',
  `favorite_count` int NOT NULL DEFAULT 0 COMMENT '收藏数',
  `view_count` int NOT NULL DEFAULT 0 COMMENT '浏览数',
  `status` enum('PENDING','APPROVED','REJECTED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'APPROVED' COMMENT '审核状态',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `post_id`(`post_id` ASC) USING BTREE,
  INDEX `idx_post_id`(`post_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` DESC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_user_create`(`user_id` ASC, `create_time` DESC) USING BTREE,
  CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 86 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '帖子表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for tags
-- ----------------------------
DROP TABLE IF EXISTS `tags`;
CREATE TABLE `tags`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '物理ID（自增主键）',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标签名称',
  `use_count` int NOT NULL DEFAULT 0 COMMENT '使用次数',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 32 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '标签表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '物理ID（自增主键）',
  `user_id` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '逻辑ID（业务生成，例：USR_2025Q1_01H8S2）',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '加密密码（存储 password_hash）',
  `salt` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码盐值',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '真实姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '手机号',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮箱',
  `role` enum('user','admin') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'user' COMMENT '用户角色',
  `status` enum('active','inactive','banned') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active' COMMENT '账户状态',
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像URL',
  `bio` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '个人简介',
  `gender` enum('male','female','other','prefer_not_to_say') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '性别',
  `location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '所在地',
  `device_count` smallint NOT NULL DEFAULT 0 COMMENT '绑定设备数',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `following_count` int NOT NULL DEFAULT 0 COMMENT '关注数（我关注的人数，冗余字段）',
  `follower_count` int NOT NULL DEFAULT 0 COMMENT '粉丝数（关注我的人数，冗余字段）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `user_id`(`user_id` ASC) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `phone`(`phone` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_username`(`username` ASC) USING BTREE,
  INDEX `idx_phone`(`phone` ASC) USING BTREE,
  INDEX `idx_email`(`email` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_role`(`role` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE,
  INDEX `idx_users_composite`(`username` ASC, `status` ASC) USING BTREE,
  INDEX `idx_users_phone_status`(`phone` ASC, `status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 34 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户信息表' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
