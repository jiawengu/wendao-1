/*     */ package org.linlinjava.litemall.gameserver.domain;
/*     */ 
/*     */ import java.io.Serializable;
/*     */ import java.util.HashMap;
/*     */ import java.util.LinkedList;
/*     */ import java.util.List;
/*     */ import java.util.Map;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ public class Chara
/*     */   implements Serializable
/*     */ {
/*     */   public int allId;
/*  20 */   public List<Goods> cangku = new LinkedList();
/*     */   
/*  22 */   public List<Goods> shizhuang = new LinkedList();
/*  23 */   public List<Goods> texiao = new LinkedList();
/*  24 */   public List<Goods> genchong = new LinkedList();
/*     */   
/*  26 */   public List<Goods> backpack = new LinkedList();
/*     */   
/*     */ 
/*  29 */   public ZbAttribute zbAttribute = new ZbAttribute();
/*  30 */   public List<Petbeibao> pets = new LinkedList();
/*  31 */   public List<ShouHu> listshouhu = new LinkedList();
/*  32 */   public List<JiNeng> jiNengList = new LinkedList();
/*     */   
/*     */ 
/*  35 */   public List<Vo_41480_0> shenmiliwu = new LinkedList();
/*     */   public int chongzhijifen;
/*     */   public int id;
/*     */   public int x;
/*     */   public int y;
/*     */   public int mapid;
/*     */   
/*     */   public Chara() {}
/*     */   
/*  44 */   public void waiguan() { if ((this.menpai == 1) && (this.sex == 1)) {
/*  45 */       this.waiguan = 6001;
/*     */     }
/*  47 */     if ((this.menpai == 2) && (this.sex == 1)) {
/*  48 */       this.waiguan = 7002;
/*     */     }
/*  50 */     if ((this.menpai == 3) && (this.sex == 1)) {
/*  51 */       this.waiguan = 7003;
/*     */     }
/*  53 */     if ((this.menpai == 4) && (this.sex == 1)) {
/*  54 */       this.waiguan = 6004;
/*     */     }
/*  56 */     if ((this.menpai == 5) && (this.sex == 1)) {
/*  57 */       this.waiguan = 6005;
/*     */     }
/*  59 */     if ((this.menpai == 1) && (this.sex == 2)) {
/*  60 */       this.waiguan = 7001;
/*     */     }
/*  62 */     if ((this.menpai == 2) && (this.sex == 2)) {
/*  63 */       this.waiguan = 6002;
/*     */     }
/*  65 */     if ((this.menpai == 3) && (this.sex == 2)) {
/*  66 */       this.waiguan = 6003;
/*     */     }
/*  68 */     if ((this.menpai == 4) && (this.sex == 2)) {
/*  69 */       this.waiguan = 7004;
/*     */     }
/*  71 */     if ((this.menpai == 5) && (this.sex == 2)) {
/*  72 */       this.waiguan = 7005;
/*     */     }
/*     */   }
/*     */   
/*     */ 
/*     */   public Chara(String name, int sex, int menpai, String uuid)
/*     */   {
/*  79 */     Vo_41480_0 vo_41480_0 = new Vo_41480_0();
/*  80 */     vo_41480_0.index = 1;
/*  81 */     vo_41480_0.time = 300;
/*  82 */     this.shenmiliwu.add(vo_41480_0);
/*  83 */     vo_41480_0 = new Vo_41480_0();
/*  84 */     vo_41480_0.index = 2;
/*  85 */     vo_41480_0.time = 900;
/*  86 */     this.shenmiliwu.add(vo_41480_0);
/*  87 */     vo_41480_0 = new Vo_41480_0();
/*  88 */     vo_41480_0.index = 3;
/*  89 */     vo_41480_0.time = 1800;
/*  90 */     this.shenmiliwu.add(vo_41480_0);
/*  91 */     vo_41480_0 = new Vo_41480_0();
/*  92 */     vo_41480_0.index = 4;
/*  93 */     vo_41480_0.time = 3000;
/*  94 */     this.shenmiliwu.add(vo_41480_0);
/*  95 */     vo_41480_0 = new Vo_41480_0();
/*  96 */     vo_41480_0.index = 5;
/*  97 */     vo_41480_0.time = 4800;
/*  98 */     this.shenmiliwu.add(vo_41480_0);
/*  99 */     vo_41480_0 = new Vo_41480_0();
/* 100 */     vo_41480_0.index = 6;
/* 101 */     vo_41480_0.time = 7200;
/* 102 */     this.shenmiliwu.add(vo_41480_0);
/* 103 */     vo_41480_0 = new Vo_41480_0();
/* 104 */     vo_41480_0.index = 7;
/* 105 */     vo_41480_0.time = 10200;
/* 106 */     this.shenmiliwu.add(vo_41480_0);
/* 107 */     vo_41480_0 = new Vo_41480_0();
/* 108 */     vo_41480_0.index = 8;
/* 109 */     vo_41480_0.time = 13800;
/* 110 */     this.shenmiliwu.add(vo_41480_0);
/*     */     
/*     */ 
/* 113 */     this.name = name;
/* 114 */     this.menpai = menpai;
/* 115 */     this.level = 1;
/* 116 */     this.mapid = 1000;
/* 117 */     this.mapName = "揽仙镇";
/* 118 */     this.chenhao = "";
/* 119 */     this.exp = 0L;
/* 120 */     this.uuid = uuid;
/* 121 */     this.sex = sex;
/*     */     
/* 123 */     this.line = 1;
/* 124 */     waiguan();
/* 125 */     this.current_task = "主线—浮生若梦_s1";
/* 126 */     this.x = 22;
/* 127 */     this.y = 108;
/*     */     
/*     */ 
/* 130 */     this.phy_power = 1;
/* 131 */     this.speed = 1;
/* 132 */     this.life = 1;
/* 133 */     this.mag_power = 1;
/* 134 */     this.accurate = 45;
/* 135 */     this.def = 105;
/* 136 */     this.wiz = 45;
/* 137 */     this.mana = 45;
/* 138 */     this.dex = 84;
/* 139 */     this.parry = 50;
/* 140 */     this.pot = 0;
/* 141 */     this.resist_poison = 517;
/*     */     
/* 143 */     this.use_skill_d = 300;
/*     */     
/*     */ 
/* 146 */     this.max_life = 159;
/*     */     
/* 148 */     this.resist_metal = 0;
/* 149 */     this.wood = 0;
/* 150 */     this.water = 0;
/* 151 */     this.fire = 0;
/* 152 */     this.earth = 0;
/* 153 */     this.polar_point = 0;
/* 154 */     this.stamina = 0;
/*     */     
/*     */ 
/* 157 */     this.extra_mana = 1000000;
/* 158 */     this.have_coin_pwd = 1000000;
/*     */     
/*     */ 
/* 161 */     this.use_money_type = 0;
/*     */     
/*     */ 
/* 164 */     this.gold_coin = 0;  //默认银元宝
/*     */     
/*     */ 
/* 167 */     this.extra_life = 100000;  // 默认元宝
/*     */     
/*     */ 
/* 170 */     this.balance = 10000000;
/*     */     
/* 172 */     this.lock_exp = 0;
/*     */     
/* 174 */     this.cash = 200000000;
/*     */     
/* 176 */     this.chubao = 1;
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */ 
/*     */   public String mapName;
/*     */   
/*     */ 
/*     */ 
/*     */   public int level;
/*     */   
/*     */ 
/*     */ 
/*     */   public String name;
/*     */   
/*     */ 
/*     */ 
/*     */   public String chenhao;
/*     */   
/*     */ 
/*     */   public int menpai;
/*     */   
/*     */ 
/* 200 */   public int tizhi = 1;
/*     */   
/* 202 */   public int lingli = 1;
/*     */   
/*     */ 
/*     */   public long exp;
/*     */   
/*     */   public int sex;
/*     */   
/*     */   public int line;
/*     */   
/*     */   public String uuid;
/*     */   
/*     */   public int waiguan;
/*     */   
/*     */   public String current_task;
/*     */   
/*     */   public int phy_power;
/*     */   
/*     */   public int life;
/*     */   
/*     */   public int speed;
/*     */   
/*     */   public int mag_power;
/*     */   
/*     */   public int accurate;
/*     */   
/*     */   public int def;
/*     */   
/*     */   public int dex;
/*     */   
/*     */   public int wiz;
/*     */   
/*     */   public int mana;
/*     */   
/*     */   public int parry;
/*     */   
/*     */   public int pot;
/*     */   
/*     */   public int resist_poison;
/*     */   
/*     */   public int extra_mana;
/*     */   
/*     */   public int have_coin_pwd;
/*     */   
/*     */   public int use_skill_d;
/*     */   
/*     */   public int resist_metal;
/*     */   
/*     */   public int wood;
/*     */   
/*     */   public int water;
/*     */   
/*     */   public int fire;
/*     */   
/*     */   public int earth;
/*     */   
/*     */   public int polar_point;
/*     */   
/*     */   public int stamina;
/*     */   
/*     */   public int max_life;
/*     */   
/*     */   public int max_mana;
/*     */   
/*     */   public int use_money_type;
/*     */   
/* 267 */   public int shadow_self = 100;  // 默认抽奖
/*     */   
/*     */ 
/*     */   public int weapon_icon;
/*     */   
/*     */ 
/*     */   public int gold_coin;
/*     */   
/*     */ 
/*     */   public int extra_life;
/*     */   
/*     */ 
/*     */   public int balance;
/*     */   
/*     */ 
/*     */   public int jishou_coin;
/*     */   
/*     */ 
/*     */   public int lock_exp;
/*     */   
/*     */ 
/*     */   public int chongwuchanzhanId;
/*     */   
/*     */ 
/*     */   public int cash;
/*     */   
/*     */ 
/*     */   public long uptime;
/*     */   
/*     */ 
/*     */   public long updatetime;
/*     */   
/*     */ 
/*     */   public long online_time;
/*     */   
/*     */ 
/* 303 */   public int signDays = 0;
/*     */   
/* 305 */   public int isCanSgin = 1;
/*     */   
/*     */ 
/*     */   public int gender;
/*     */   
/* 310 */   public int canzhanshouhunumber = 0;
/*     */   
/*     */ 
/* 313 */   public int zuoqiwaiguan = 0;
/*     */   
/* 315 */   public int zuoqiId = 0;
/*     */   
/* 317 */   public int yidongsudu = 0;
/*     */   
/* 319 */   public int zuowaiguan = 0;
/*     */   
/*     */ 
/* 322 */   public int special_icon = 0;
/*     */   
/*     */ 
/* 325 */   public int texiao_icon = 0;
/*     */   
/* 327 */   public int genchong_icon = 0;
/*     */   
/*     */ 
/*     */   public int vipType;
/*     */   
/*     */ 
/*     */   public int isGet;
/*     */   
/*     */ 
/*     */   public int vipTime;
/*     */   
/*     */   public int vipTimeShengYu;
/*     */   
/*     */   public int suit_icon;
/*     */   
/*     */   public int suit_light_effect;
/*     */   
/*     */   public int wuxingBalance;
/*     */   
/*     */   public int enable_double_points;
/*     */   
/*     */   public int enable_shenmu_points;
/*     */   
/*     */   public int extra_skill;
/*     */   
/*     */   public int chushi_ex;
/*     */   
/*     */   public int fetch_nice;
/*     */   
/*     */   public int shuadaochongfeng_san;
/*     */   
/* 358 */   public int[] xinshoulibao = { 0, 0, 0, 0, 0, 0, 0, 0 };
/*     */   
/*     */ 
/*     */ 
/*     */ 
/* 363 */   public List<Vo_65529_0> npcshuadao = new LinkedList();
/*     */   
/* 365 */   public int shuadao = 1;
/*     */   
/*     */   public int chubao;
/*     */   
/* 369 */   public List<Vo_65529_0> npcchubao = new LinkedList();
/*     */   
/* 371 */   public int baibangmang = 0;
/*     */   
/* 373 */   public int shimencishu = 1;
/*     */   
/* 375 */   public String npcName = "";
/*     */   
/* 377 */   public int fabaorenwu = 0;
/*     */   
/* 379 */   public int xiuxingcishu = 1;
/*     */   
/* 381 */   public String xiuxingNpcname = "";
/*     */   
/* 383 */   public int xuanshangcishu = 0;
/*     */   
/* 385 */   public List<Vo_65529_0> npcxuanshang = new LinkedList();
/*     */   
/* 387 */   public String npcXuanShangName = "";
/*     */   
/*     */ 
/*     */ 
/* 391 */   public Vo_65529_0 changbaotu = new Vo_65529_0();
/*     */   
/*     */ 
/*     */ 
/* 395 */   public int autofight_select = 0;
/* 396 */   public int autofight_skillaction = 2;
/* 397 */   public int autofight_skillno = 2;
/*     */   
/*     */ 
/*     */   public int friend;
/*     */   
/*     */ 
/*     */   public int owner_name;
/*     */   
/* 405 */   public Map<String, String> chenghao = new HashMap();
/*     */   
/*     */ 
/* 408 */   public int qumoxiang = 0;
/*     */   
/* 410 */   public int charashuangbei = 0;
/*     */   
/* 412 */   public int shenmoding = 0;
/*     */   
/* 414 */   public int ziqihongmeng = 0;
/*     */   
/* 416 */   public int chongfengsan = 0;
/*     */   
/*     */ 
/*     */ 
/* 420 */   public int shidaodaguaijifen = 0;
/*     */   
/* 422 */   public int shidaocishu = 0;

            public int partyId = 0;
            public String partyName = "";
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\domain\Chara.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */