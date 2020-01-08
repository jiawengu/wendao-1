/*
Navicat MySQL Data Transfer

Source Server         : mySql
Source Server Version : 50528
Source Host           : localhost:3306
Source Database       : gserver

Target Server Type    : MYSQL
Target Server Version : 50528
File Encoding         : 65001

Date: 2020-01-08 20:19:01
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for shang_gu_yao_wang_reward_info
-- ----------------------------
DROP TABLE IF EXISTS `shang_gu_yao_wang_reward_info`;
CREATE TABLE `shang_gu_yao_wang_reward_info` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(11) unsigned zerofill NOT NULL DEFAULT '00000000000',
  `characters_id` int(11) unsigned zerofill NOT NULL DEFAULT '00000000000',
  `reward` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `date_time` varchar(24) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `date` varchar(15) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `yao_wang_id` int(11) unsigned zerofill NOT NULL DEFAULT '00000000000',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
-- Records of shang_gu_yao_wang_reward_info
-- ----------------------------
INSERT INTO `shang_gu_yao_wang_reward_info` VALUES ('1', '00000006128', '00000010049', '经验#500道行#500亮银靴枯月流魂', '2020-01-07 22:36:53', '2020-01-07', '00000001312');
INSERT INTO `shang_gu_yao_wang_reward_info` VALUES ('2', '00000006128', '00000010049', '经验#500道行#500寒风枪凝香幻彩', '2020-01-07 22:41:37', '2020-01-07', '00000001312');
INSERT INTO `shang_gu_yao_wang_reward_info` VALUES ('3', '00000006128', '00000010049', '经验#500道行#500凤尾钗炫影霜星', '2020-01-07 23:06:46', '2020-01-07', '00000001312');
INSERT INTO `shang_gu_yao_wang_reward_info` VALUES ('4', '00000006128', '00000010049', '经验#500道行#500亮银靴冰落残阳', '2020-01-07 23:16:41', '2020-01-07', '00000001312');
INSERT INTO `shang_gu_yao_wang_reward_info` VALUES ('5', '00000006128', '00000010049', '经验#500道行#500水合袍冰落残阳', '2020-01-07 23:28:29', '2020-01-07', '00000001312');
INSERT INTO `shang_gu_yao_wang_reward_info` VALUES ('6', '00000006128', '00000010049', '经验#500道行#500幻彩项链风寂云清', '2020-01-08 00:01:47', '2020-01-08', '00000001312');
INSERT INTO `shang_gu_yao_wang_reward_info` VALUES ('7', '00000006128', '00000010049', '经验#500道行#500水合袍风寂云清', '2020-01-08 00:35:22', '2020-01-08', '00000001312');
