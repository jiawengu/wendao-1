DROP TABLE IF EXISTS `character_title`;
CREATE TABLE `character_title` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` int(11) NOT NULL COMMENT '类型',
  `owner_uid` int(11) DEFAULT NULL,
  `add_time` datetime DEFAULT NULL COMMENT '获得时间',
  `deleted` tinyint(1) DEFAULT '0' COMMENT '逻辑删除',
  UNIQUE INDEX `type_index` (`type`),
  UNIQUE INDEX `uid_index` (owner_uid),
  UNIQUE INDEX `unique`(`type`, owner_uid),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;