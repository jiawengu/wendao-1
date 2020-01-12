package org.linlinjava.litemall.gameserver.util;

/**
 */
public interface MsgUtil {
    String TIAO_ZHAN_ZHANG_MEN = "【挑战掌门】与掌门一战";
    String CHA_KAN_ZHANG_MEN = "我要一睹掌门风采";
    String JIN_RU_ZHENG_DAO_DIAN =  "进入证道殿";
    String KAN_KAN_YE_WU_FANG =  "看看也无妨";
    String BU_KAN_LE =  "不看了，看得太多就见怪不怪了";

    String WO_YAO_TIAO_ZHAN_70 =  "我要挑战你（70-79级可挑战）";
    String WO_YAO_TIAO_ZHAN_80 =  "我要挑战你（80-89级可挑战）";
    String WO_YAO_TIAO_ZHAN_90 =  "我要挑战你（90-99级可挑战）";
    String WO_YAO_TIAO_ZHAN_100 =  "我要挑战你（100-109级可挑战）";
    String WO_YAO_TIAO_ZHAN_110 =  "我要挑战你（110-119级可挑战）";
    String WO_YAO_TIAO_ZHAN_120 =  "我要挑战你（120-129级可挑战）";
    String WO_YAO_YI_DU_HU_FA =  "我要一睹护法风采";
    String KONG_PA_SHI_LI_BU_GOU =  "恐怕我实力还不够";
    String WU_XUE_SHANG_QIQN =  "你年岁尚轻，勤学苦练之后再来找我吧！[离开]";
    String DAO_LI_GAO_SHEN =  "道友功力如此高深，此等小事无需劳驾。[离开]";
    String NAN_NV_YOU_BIE =  "你我男女有别，岂可乱了礼数。[离开]";

    String WO_XIANG_SHI_70 =  "我想试一试（70-79级可挑战）";
    String WO_XIANG_SHI_80 =  "我想试一试（80-89级可挑战）";
    String WO_XIANG_SHI_90 =  "我想试一试（90-99级可挑战）";
    String WO_XIANG_SHI_100 =  "我想试一试（100-109级可挑战）";
    String WO_XIANG_SHI_110 =  "我想试一试（110-119级可挑战）";
    String WO_XIANG_SHI_120 =  "我想试一试（120-129级可挑战）";
    String WO_YAO_YI_DU_YING_XIONG =  "我要一睹英雄风采";

    static String getTalk(String content){
        return "["+content+"]";
    }
}
