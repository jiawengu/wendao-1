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
}
