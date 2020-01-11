package org.linlinjava.litemall.gameserver.domain;

import java.io.Serializable;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.linlinjava.litemall.gameserver.data.vo.Vo_41480_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
import org.linlinjava.litemall.gameserver.domain.SubSystem.Baxian;

public class Chara implements Serializable {
    public int allId;
    public List<Goods> cangku = new LinkedList();

    public List<Goods> shizhuang = new LinkedList();
    public List<Goods> texiao = new LinkedList();
    public List<Goods> genchong = new LinkedList();

    public List<Goods> backpack = new LinkedList();


    public ZbAttribute zbAttribute = new ZbAttribute();
    public List<Petbeibao> pets = new LinkedList();
    public List<ShouHu> listshouhu = new LinkedList();
    public List<JiNeng> jiNengList = new LinkedList();


    public List<Vo_41480_0> shenmiliwu = new LinkedList();
    public int chongzhijifen;
    public int id;
    public int x;
    public int y;
    public int mapid;

    public Chara() {
    }

    public void waiguan() {
        if ((this.menpai == 1) && (this.sex == 1)) {
            this.waiguan = 6001;
        }
        if ((this.menpai == 2) && (this.sex == 1)) {
            this.waiguan = 7002;
        }
        if ((this.menpai == 3) && (this.sex == 1)) {
            this.waiguan = 7003;
        }
        if ((this.menpai == 4) && (this.sex == 1)) {
            this.waiguan = 6004;
        }
        if ((this.menpai == 5) && (this.sex == 1)) {
            this.waiguan = 6005;
        }
        if ((this.menpai == 1) && (this.sex == 2)) {
            this.waiguan = 7001;
        }
        if ((this.menpai == 2) && (this.sex == 2)) {
            this.waiguan = 6002;
        }
        if ((this.menpai == 3) && (this.sex == 2)) {
            this.waiguan = 6003;
        }
        if ((this.menpai == 4) && (this.sex == 2)) {
            this.waiguan = 7004;
        }
        if ((this.menpai == 5) && (this.sex == 2)) {
            this.waiguan = 7005;
        }
    }


    public Chara(String name, int sex, int menpai, String uuid) {
        Vo_41480_0 vo_41480_0 = new Vo_41480_0();
        vo_41480_0.index = 1;
        vo_41480_0.time = 300;
        this.shenmiliwu.add(vo_41480_0);
        vo_41480_0 = new Vo_41480_0();
        vo_41480_0.index = 2;
        vo_41480_0.time = 900;
        this.shenmiliwu.add(vo_41480_0);
        vo_41480_0 = new Vo_41480_0();
        vo_41480_0.index = 3;
        vo_41480_0.time = 1800;
        this.shenmiliwu.add(vo_41480_0);
        vo_41480_0 = new Vo_41480_0();
        vo_41480_0.index = 4;
        vo_41480_0.time = 3000;
        this.shenmiliwu.add(vo_41480_0);
        vo_41480_0 = new Vo_41480_0();
        vo_41480_0.index = 5;
        vo_41480_0.time = 4800;
        this.shenmiliwu.add(vo_41480_0);
        vo_41480_0 = new Vo_41480_0();
        vo_41480_0.index = 6;
        vo_41480_0.time = 7200;
        this.shenmiliwu.add(vo_41480_0);
        vo_41480_0 = new Vo_41480_0();
        vo_41480_0.index = 7;
        vo_41480_0.time = 10200;
        this.shenmiliwu.add(vo_41480_0);
        vo_41480_0 = new Vo_41480_0();
        vo_41480_0.index = 8;
        vo_41480_0.time = 13800;
        this.shenmiliwu.add(vo_41480_0);


        this.name = name;
        this.menpai = menpai;
        this.level = 1;
        this.mapid = 1000;
        this.mapName = "揽仙镇";
        this.chenhao = "";
        this.exp = 0L;
        this.uuid = uuid;
        this.sex = sex;

        this.line = 1;
        waiguan();
        this.current_task = "主线—浮生若梦_s1";
        this.x = 22;
        this.y = 108;


        this.phy_power = 1;
        this.speed = 1;
        this.life = 1;
        this.mag_power = 1;
        this.accurate = 45;
        this.def = 105;
        this.wiz = 45;
        this.mana = 45;
        this.dex = 84;
        this.parry = 50;
        this.pot = 0;
        this.resist_poison = 517;

        this.use_skill_d = 300;


        this.max_life = 159;

        this.resist_metal = 0;
        this.wood = 0;
        this.water = 0;
        this.fire = 0;
        this.earth = 0;
        this.polar_point = 0;
        this.stamina = 0;


        this.extra_mana = 1000000;
        this.have_coin_pwd = 1000000;


        this.use_money_type = 0;


        this.gold_coin = 0;  //默认银元宝


        this.extra_life = 100000;  // 默认元宝


        this.balance = 10000000;

        this.lock_exp = 0;

        this.cash = 200000000;

        this.chubao = 1;
    }


    public String mapName;


    public int level;


    public String name;


    public String chenhao;


    public int menpai;


    public int tizhi = 1;

    public int lingli = 1;


    public long exp;

    public int sex;

    public int line;

    public String uuid;

    public int waiguan;

    public String current_task;

    public int phy_power;

    public int life;

    public int speed;

    public int mag_power;

    public int accurate;

    public int def;

    public int dex;

    public int wiz;

    public int mana;

    public int parry;

    public int pot;

    public int resist_poison;

    public int extra_mana;

    public int have_coin_pwd;

    public int use_skill_d;

    public int resist_metal;

    public int wood;

    public int water;

    public int fire;

    public int earth;

    public int polar_point;

    public int stamina;

    public int max_life;

    public int max_mana;

    public int use_money_type;

    public int shadow_self = 100;  // 默认抽奖


    public int weapon_icon;


    public int gold_coin;


    public int extra_life;


    public int balance;


    public int jishou_coin;


    public int lock_exp;


    public int chongwuchanzhanId;


    public int cash;


    public long uptime;


    public long updatetime;


    public long online_time;


    public int signDays = 0;

    public int isCanSgin = 1;


    public int gender;

    public int canzhanshouhunumber = 0;


    public int zuoqiwaiguan = 0;

    public int zuoqiId = 0;

    public int yidongsudu = 0;

    public int zuowaiguan = 0;


    public int special_icon = 0;


    public int texiao_icon = 0;

    public int genchong_icon = 0;


    public int vipType;


    public int isGet;


    public int vipTime;

    public int vipTimeShengYu;

    public int suit_icon;

    public int suit_light_effect;

    public int wuxingBalance;

    public int enable_double_points;

    public int enable_shenmu_points;

    public int extra_skill;

    public int chushi_ex;

    public int fetch_nice;

    public int shuadaochongfeng_san;

    public int[] xinshoulibao = {0, 0, 0, 0, 0, 0, 0, 0};


    public List<Vo_65529_0> npcshuadao = new LinkedList();

    public int shuadao = 1;

    public int chubao;

    public List<Vo_65529_0> npcchubao = new LinkedList();

    public int baibangmang = 0;

    public int shimencishu = 1;

    public String npcName = "";

    public int fabaorenwu = 0;

    public int xiuxingcishu = 1;

    public String xiuxingNpcname = "";

    public int xuanshangcishu = 0;

    public List<Vo_65529_0> npcxuanshang = new LinkedList();

    public String npcXuanShangName = "";


    public Vo_65529_0 changbaotu = new Vo_65529_0();


    public int autofight_select = 0;
    public int autofight_skillaction = 2;
    public int autofight_skillno = 2;


    public int friend;


    public int owner_name;

    public Map<String, String> chenghao = new HashMap();


    public int qumoxiang = 0;

    public int charashuangbei = 0;

    public int shenmoding = 0;

    public int ziqihongmeng = 0;

    public int chongfengsan = 0;


    public int shidaodaguaijifen = 0;

    public int shidaocishu = 0;

    public int partyId = 0;
    public String partyName = "";

    public Baxian baxian = Baxian.builder()
            .currentLevel(1)
            .currentMaxLevel(1)
            .resetTimeLeft(7)
            .timesLeft(700)
            .status(0)
            .build();
}
