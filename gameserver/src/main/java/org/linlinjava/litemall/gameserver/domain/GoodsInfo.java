package org.linlinjava.litemall.gameserver.domain;


public class GoodsInfo {
    public int groupNo = 0;
    /**
     * local FIELDS_BASIC      = 1 -- 物品基础属性值
     * local FIELDS_VALUE      = 2 -- 物品加成属性值
     * local FIELDS_SCALE      = 3 -- 物品加成百分比
     */
    public int groupType = 1;
    public int value;
    public int total_score;
    public int type;
    public int rebuild_level;
    public int parry;
    /**
     * 名字
     */
    public String str = "";
    public String auto_fight = "";
    public String quality = "";

    public int damage_sel_rate;

    public int recognize_recognized;

    public int owner_id;

    public int dunwu_times;
    public int attrib;
    public int gift;
    public int nick;
    public int power;
    public int wrestlescore;
    /**
     * 等级
     */
    public int skill;
    public int store_exp;
    public int metal;
    public int amount;
    public int color;
    public int suit_degree;
    public int party_stage_party_name;
    public int mailing_item_times;
    public int suit_enabled;
    public int degree_32;
    public int master;
    public int transform_cool_ti;
    public int silver_coin;
    public int diandqk_frozen_round;
    public int shuadao_ziqihongmeng;
    public int durability;
    public int add_pet_exp;
    public String alias = "";

    public int food_num;

    public int merge_rate;

    public int fasion_type;

    public int pet_upgraded;

    public int couple;
    /**
     * 亲密度
     */
    public int shape;

    public int pot;

    public int resist_poison;
    public String phy_rebuild_level = "";
    public int max_durability;
}


