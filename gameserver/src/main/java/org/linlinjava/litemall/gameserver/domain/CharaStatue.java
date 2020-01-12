package org.linlinjava.litemall.gameserver.domain;

import java.util.LinkedList;
import java.util.List;

/**
 * 人物雕像信息
 */
public class CharaStatue {
    public int id;
    public String name;
    public int level;
    public int sex;
    public String partyName;
    public int special_icon;
    public int weapon_icon;
    public int shengming;
    public int mofa;
    public int max_shengming;
    public int max_mofa;
    public int fashang;
    public int parry;
    public int accurate;
    public int fangyu;
    public int suit_icon;
    public int suit_light_effect;
    public int zuoqiwaiguan;
    public int zuowaiguan;
    public int waiguan;
    public int friend;
    public List<JiNeng> jiNengList = new LinkedList();
    public int autofight_skillno;
    public int autofight_select;
    public int autofight_skillaction;
    public int menpai;
    public String chengHao;

    /**
     * 宠物
     */
    public Petbeibao petbeibao;
    /**
     * 宠物技能
     */
    public List<JiNeng> petJiNengList = new LinkedList();

    public void copyFrom(Chara chara) {
        this.id = chara.id;
        this.sex = chara.sex;
        this.name = chara.name;
        this.menpai = chara.menpai;
        this.level = chara.level;
        this.partyName = chara.partyName;
        this.special_icon = chara.special_icon;
        this.weapon_icon = chara.weapon_icon;
        this.shengming = chara.max_life;
        this.mofa = chara.max_mana;
        this.max_shengming = chara.def + chara.zbAttribute.def;
        this.max_mofa = chara.dex + chara.zbAttribute.dex;
        this.fashang = chara.mana + chara.zbAttribute.mana;
        this.parry = chara.parry + chara.zbAttribute.parry;
        this.accurate = chara.accurate + chara.zbAttribute.accurate;
        this.fangyu = chara.wiz + chara.zbAttribute.wiz;
        this.suit_icon = chara.suit_icon;
        this.suit_light_effect = chara.suit_light_effect;
        this.waiguan = chara.waiguan;
        this.friend = chara.friend;
        this.zuoqiwaiguan = chara.zuoqiwaiguan;
        this.jiNengList = chara.jiNengList;
        this.autofight_skillno = chara.autofight_skillno;
        this.autofight_select = chara.autofight_select;
        this.autofight_skillaction = chara.autofight_skillaction;
        this.zuowaiguan = chara.zuowaiguan;
    }

    public void copyChengHao(String chengHao){
        this.chengHao = chengHao;
    }

    public void copyPet(Petbeibao petbeibao){
        this.petbeibao = petbeibao;
    }
    public void copyJiNengList(List<JiNeng> jiNengList){
        this.jiNengList = jiNengList;
    }
    public void copyPetJiNengList(List<JiNeng> jiNengList){
        this.petJiNengList = jiNengList;
    }
}
