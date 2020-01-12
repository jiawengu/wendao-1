package org.linlinjava.litemall.gameserver.util;

/**
 * @Author: Liujinyong
 * @Date: 2020/1/9 20:47
 */
public interface MsgUtil {
    String TIAO_ZHAN_ZHANG_MEN = "【挑战掌门】与掌门一战";
    String CHA_KAN_ZHANG_MEN = "我要一睹掌门风采";
    String JIN_RU_ZHENG_DAO_DIAN =  "进入证道殿";
    String KAN_KAN_YE_WU_FANG =  "看看也无妨";
    String BU_KAN_LE =  "不看了，看得太多就见怪不怪了";

    static String getTalk(String content){
        return "["+content+"]";
    }
}
