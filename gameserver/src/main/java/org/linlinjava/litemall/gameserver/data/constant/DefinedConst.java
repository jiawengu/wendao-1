package org.linlinjava.litemall.gameserver.data.constant;

public class DefinedConst {
    public enum  SUBMIT_PET_TYPE  {
        SUBMIT_PET_TYPE_NORMAL (1),
        SUBMIT_PET_TYPE_FEISHENG (2),
        SUBMIT_PET_TYPE_FEED (3),  // 饲养宠物的提交
        SUBMIT_PET_TYPE_INNER_ALLCHEMY ( 4), // 内丹修炼宠物提交
        SUBMIT_PET_TYPE_BUYBACK  (100),
        ;  // 销毁宠物的提交(目前只有客户端配置了该常量)

        int value;
        SUBMIT_PET_TYPE(int tag){
             value  = tag;
         }

        public int getValue() {
            return value;
        }

        public void setValue(int value) {
            this.value = value;
        }
    }
    //精怪类型
    public enum  MOUNT_TYPE
    {
        MOUNT_TYPE_NORMAL,
        MOUNT_TYPE_JINGGUAI,           // 坐骑-精怪
        MOUNT_TYPE_YULING,           // 坐骑-御灵
    }

    public  enum  PET_RANK{
        PET_RANK_NORMAL,
        PET_RANK_WILD               , // 野生
        PET_RANK_BABY               , // 宝宝
        PET_RANK_ELITE              , // 变异
        PET_RANK_EPIC               , // 神兽
        PET_RANK_GUARD              , // 守护
    }
}
