package org.linlinjava.litemall.gameserver.fight;

/**
 * 战斗属性
 */
public class FightAttribute {
    private final float[] attributeArray = new float[FightAttribtueType.values().length];

    public float getAttribute(FightAttribtueType type){
        return attributeArray[index(type)];
    }
    public void setAttribute(FightAttribtueType type, float newValue){
        attributeArray[index(type)] = newValue;
    }
    public void reduceAttribute(FightAttribtueType type, float reduceValue){
        attributeArray[index(type)] -= reduceValue;
    }
    public void addAttribute(FightAttribtueType type, float addValue){
        attributeArray[index(type)] += addValue;
    }

    /**
     * 增加百分比
     * @param type
     * @param addPer
     */
    public void addPerAttribute(FightAttribtueType type, float addPer){
        attributeArray[index(type)] *= (1+addPer);
    }
    private int index(FightAttribtueType type){
        return type.ordinal();
    }
}
