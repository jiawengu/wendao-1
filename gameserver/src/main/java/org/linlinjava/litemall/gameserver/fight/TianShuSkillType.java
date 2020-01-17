package org.linlinjava.litemall.gameserver.fight;

import java.util.HashMap;
import java.util.Map;

/**
 * 天书技能类型
 */
public enum TianShuSkillType {
    XIU_LUO("修罗术", 7041){
        @Override
        public FightTianshuSkill createSkill() {
            return new XiuluoshuSkill();
        }
    },
    XIANG_MO_ZHAN("降魔斩", 7036){
        @Override
        public FightTianshuSkill createSkill() {
            return new XiangMoZhanSkill();
        }
    },
    NU_JI("怒击", 7039){
        @Override
        public FightTianshuSkill createSkill() {
            return new NujiSkill();
        }
    },
    LIE_YAN("烈炎", 7034){
        @Override
        public FightTianshuSkill createSkill() {
            return new LieYanSkill();
        }
    },
    XIAN_FENG("仙风", 8050){
        @Override
        public FightTianshuSkill createSkill() {
            return new XianFengSkill();
        }
    },
    PO_TIAN("破天", 7040){
        @Override
        public FightTianshuSkill createSkill() {
            return new PoTianSkill();
        }
    },
    KUANG_BAO("狂暴", 7037){
        @Override
        public FightTianshuSkill createSkill() {
            return new KuangBaoSkill();
        }
    },
    JING_LEI("惊雷", 7031){
        @Override
        public FightTianshuSkill createSkill() {
            return new JingLeiSkill();
        }
    },
    SUI_SHI("碎石", 7035){
        @Override
        public FightTianshuSkill createSkill() {
            return new SuiShiSkill();
        }
    },
    FAN_JI("反击", 8049){
        @Override
        public FightTianshuSkill createSkill() {
            return new FanjiSkill();
        }
    },
    QING_MU("青木", 7032){
        @Override
        public FightTianshuSkill createSkill() {
            return new QingMuSkill();
        }
    },
    JIN_ZHONG("尽忠", 8240){
        @Override
        public FightTianshuSkill createSkill() {
            return new JinZhongSkill();
        }
    },
    HAN_BING("寒冰", 7033){
        @Override
        public FightTianshuSkill createSkill() {
            return new HanBingSkill();
        }
    },
    YUN_TI("云体", 8051){
        @Override
        public FightTianshuSkill createSkill() {
            return new YunTiSkill();
        }
    },
    MO_YIN("魔引", 7038){
        @Override
        public FightTianshuSkill createSkill() {
            return new MoYinSkill();
        }
    }
    ;
    private String name;
    private int id;

    TianShuSkillType(String name, int id) {
        this.name = name;
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public int getId() {
        return id;
    }

    public abstract FightTianshuSkill createSkill();

    private final static Map<String, TianShuSkillType> nameMap = new HashMap<>();
    static {
        for(TianShuSkillType tianShuSkillType:TianShuSkillType.values()){
            nameMap.put(tianShuSkillType.name, tianShuSkillType);
        }
    }

    public static TianShuSkillType getType(String skillName){
        return nameMap.get(skillName);
    }

}
