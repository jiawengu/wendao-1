/*     */ package org.linlinjava.litemall.gameserver.data;
/*     */ 
/*     */ import java.util.HashMap;
/*     */ import java.util.Map;
/*     */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.Duiyuan;
/*     */ import org.linlinjava.litemall.gameserver.domain.EquipInformation;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsBasics;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsFenSe;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsGaiZao;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsGaiZaoGongMing;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsGaiZaoGongMingChengGong;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsHuangSe;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsInfo;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsLanSe;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsLvSe;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsLvSeGongMing;
/*     */ import org.linlinjava.litemall.gameserver.domain.JiNeng;
/*     */ import org.linlinjava.litemall.gameserver.domain.LieBiao;
/*     */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*     */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*     */ import org.linlinjava.litemall.gameserver.domain.ShouHu;
/*     */ import org.linlinjava.litemall.gameserver.domain.ShouHuShuXing;
/*     */ import org.linlinjava.litemall.gameserver.domain.ShuXingUtil;
/*     */ import org.linlinjava.litemall.gameserver.domain.ZbAttribute;
/*     */ 
/*     */ public class UtilObjMapshuxing
/*     */ {
/*     */   public static Map<Object, Object> Chara(Object obj)
/*     */   {
/*  32 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/*  33 */     Chara obj1 = (Chara)obj;
/*  34 */     objectObjectHashMap.put("cangku", obj1.cangku);
/*  35 */     objectObjectHashMap.put("shizhuang", obj1.shizhuang);
/*  36 */     objectObjectHashMap.put("texiao", obj1.texiao);
/*  37 */     objectObjectHashMap.put("genchong", obj1.genchong);
/*  38 */     objectObjectHashMap.put("backpack", obj1.backpack);
/*  39 */     objectObjectHashMap.put("zbAttribute", obj1.zbAttribute);
/*  40 */     objectObjectHashMap.put("pets", obj1.pets);
/*  41 */     objectObjectHashMap.put("listshouhu", obj1.listshouhu);
/*  42 */     objectObjectHashMap.put("jiNengList", obj1.jiNengList);
/*  43 */     objectObjectHashMap.put("shenmiliwu", obj1.shenmiliwu);
/*  44 */     objectObjectHashMap.put("id", Integer.valueOf(obj1.id));
/*  45 */     objectObjectHashMap.put("x", Integer.valueOf(obj1.x));
/*  46 */     objectObjectHashMap.put("y", Integer.valueOf(obj1.y));
/*  47 */     objectObjectHashMap.put("mapid", Integer.valueOf(obj1.mapid));
/*  48 */     objectObjectHashMap.put("mapName", obj1.mapName);
/*  49 */     objectObjectHashMap.put("level", Integer.valueOf(obj1.level));
/*  50 */     objectObjectHashMap.put("name", obj1.name);
/*  51 */     objectObjectHashMap.put("chenhao", obj1.chenhao);
/*  52 */     objectObjectHashMap.put("menpai", Integer.valueOf(obj1.menpai));
/*  53 */     objectObjectHashMap.put("tizhi", Integer.valueOf(obj1.tizhi));
/*  54 */     objectObjectHashMap.put("lingli", Integer.valueOf(obj1.lingli));
/*  55 */     objectObjectHashMap.put("exp", Long.valueOf(obj1.exp));
/*  56 */     objectObjectHashMap.put("sex", Integer.valueOf(obj1.sex));
/*  57 */     objectObjectHashMap.put("line", Integer.valueOf(obj1.line));
/*  58 */     objectObjectHashMap.put("uuid", obj1.uuid);
/*  59 */     objectObjectHashMap.put("waiguan", Integer.valueOf(obj1.waiguan));
/*  60 */     objectObjectHashMap.put("current_task", obj1.current_task);
/*  61 */     objectObjectHashMap.put("phy_power", Integer.valueOf(obj1.phy_power));
/*  62 */     objectObjectHashMap.put("life", Integer.valueOf(obj1.life));
/*  63 */     objectObjectHashMap.put("speed", Integer.valueOf(obj1.speed));
/*  64 */     objectObjectHashMap.put("mag_power", Integer.valueOf(obj1.mag_power));
/*  65 */     objectObjectHashMap.put("accurate", Integer.valueOf(obj1.accurate));
/*  66 */     objectObjectHashMap.put("def", Integer.valueOf(obj1.def));
/*  67 */     objectObjectHashMap.put("dex", Integer.valueOf(obj1.dex));
/*  68 */     objectObjectHashMap.put("wiz", Integer.valueOf(obj1.wiz));
/*  69 */     objectObjectHashMap.put("mana", Integer.valueOf(obj1.mana));
/*  70 */     objectObjectHashMap.put("parry", Integer.valueOf(obj1.parry));
/*  71 */     objectObjectHashMap.put("pot", Integer.valueOf(obj1.pot));
/*  72 */     objectObjectHashMap.put("resist_poison", Integer.valueOf(obj1.resist_poison));
/*  73 */     objectObjectHashMap.put("extra_mana", Integer.valueOf(obj1.extra_mana));
/*  74 */     objectObjectHashMap.put("have_coin_pwd", Integer.valueOf(obj1.have_coin_pwd));
/*  75 */     objectObjectHashMap.put("use_skill_d", Integer.valueOf(obj1.use_skill_d));
/*  76 */     objectObjectHashMap.put("resist_metal", Integer.valueOf(obj1.resist_metal));
/*  77 */     objectObjectHashMap.put("wood", Integer.valueOf(obj1.wood));
/*  78 */     objectObjectHashMap.put("water", Integer.valueOf(obj1.water));
/*  79 */     objectObjectHashMap.put("fire", Integer.valueOf(obj1.fire));
/*  80 */     objectObjectHashMap.put("earth", Integer.valueOf(obj1.earth));
/*  81 */     objectObjectHashMap.put("polar_point", Integer.valueOf(obj1.polar_point));
/*  82 */     objectObjectHashMap.put("stamina", Integer.valueOf(obj1.stamina));
/*  83 */     objectObjectHashMap.put("max_life", Integer.valueOf(obj1.max_life));
/*  84 */     objectObjectHashMap.put("max_mana", Integer.valueOf(obj1.max_mana));
/*  85 */     objectObjectHashMap.put("use_money_type", Integer.valueOf(obj1.use_money_type));
/*  86 */     objectObjectHashMap.put("shadow_self", Integer.valueOf(obj1.shadow_self));
/*  87 */     objectObjectHashMap.put("weapon_icon", Integer.valueOf(obj1.weapon_icon));
/*  88 */     objectObjectHashMap.put("gold_coin", Integer.valueOf(obj1.gold_coin));
/*  89 */     objectObjectHashMap.put("extra_life", Integer.valueOf(obj1.extra_life));
/*  90 */     objectObjectHashMap.put("balance", Integer.valueOf(obj1.balance));
/*  91 */     objectObjectHashMap.put("jishou_coin", Integer.valueOf(obj1.jishou_coin));
/*  92 */     objectObjectHashMap.put("lock_exp", Integer.valueOf(obj1.lock_exp));
/*  93 */     objectObjectHashMap.put("chongwuchanzhanId", Integer.valueOf(obj1.chongwuchanzhanId));
/*  94 */     objectObjectHashMap.put("cash", Integer.valueOf(obj1.cash));
/*  95 */     objectObjectHashMap.put("uptime", Long.valueOf(obj1.uptime));
/*  96 */     objectObjectHashMap.put("updatetime", Long.valueOf(obj1.updatetime));
/*  97 */     objectObjectHashMap.put("online_time", Long.valueOf(obj1.online_time));
/*  98 */     objectObjectHashMap.put("signDays", Integer.valueOf(obj1.signDays));
/*  99 */     objectObjectHashMap.put("isCanSgin", Integer.valueOf(obj1.isCanSgin));
/* 100 */     objectObjectHashMap.put("gender", Integer.valueOf(obj1.sex));
/* 101 */     objectObjectHashMap.put("canzhanshouhunumber", Integer.valueOf(obj1.canzhanshouhunumber));
/* 102 */     objectObjectHashMap.put("zuoqiwaiguan", Integer.valueOf(obj1.zuoqiwaiguan));
/* 103 */     objectObjectHashMap.put("zuoqiId", Integer.valueOf(obj1.zuoqiId));
/* 104 */     objectObjectHashMap.put("yidongsudu", Integer.valueOf(obj1.yidongsudu));
/* 105 */     objectObjectHashMap.put("zuowaiguan", Integer.valueOf(obj1.zuowaiguan));
/* 106 */     objectObjectHashMap.put("special_icon", Integer.valueOf(obj1.special_icon));
/* 107 */     objectObjectHashMap.put("texiao_icon", Integer.valueOf(obj1.texiao_icon));
/* 108 */     objectObjectHashMap.put("genchong_icon", Integer.valueOf(obj1.genchong_icon));
/* 109 */     objectObjectHashMap.put("vipType", Integer.valueOf(obj1.vipType));
/* 110 */     objectObjectHashMap.put("isGet", Integer.valueOf(obj1.isGet));
/* 111 */     objectObjectHashMap.put("vipTime", Integer.valueOf(obj1.vipTime));
/* 112 */     objectObjectHashMap.put("vipTimeShengYu", Integer.valueOf(obj1.vipTimeShengYu));
/* 113 */     objectObjectHashMap.put("suit_icon", Integer.valueOf(obj1.suit_icon));
/* 114 */     objectObjectHashMap.put("suit_light_effect", Integer.valueOf(obj1.suit_light_effect));
/* 115 */     objectObjectHashMap.put("wuxingBalance", Integer.valueOf(obj1.wuxingBalance));
/* 116 */     objectObjectHashMap.put("enable_double_points", Integer.valueOf(obj1.enable_double_points));
/* 117 */     objectObjectHashMap.put("enable_shenmu_points", Integer.valueOf(obj1.enable_shenmu_points));
/* 118 */     objectObjectHashMap.put("extra_skill", Integer.valueOf(obj1.extra_skill));
/* 119 */     objectObjectHashMap.put("chushi_ex", Integer.valueOf(obj1.chushi_ex));
/* 120 */     objectObjectHashMap.put("fetch_nice", Integer.valueOf(obj1.fetch_nice));
/* 121 */     objectObjectHashMap.put("shuadaochongfeng_san", Integer.valueOf(obj1.shuadaochongfeng_san));
/* 122 */     objectObjectHashMap.put("xinshoulibao", obj1.xinshoulibao);
/* 123 */     objectObjectHashMap.put("npcshuadao", obj1.npcshuadao);
/* 124 */     objectObjectHashMap.put("shuadao", Integer.valueOf(obj1.shuadao));
/* 125 */     objectObjectHashMap.put("chubao", Integer.valueOf(obj1.chubao));
/* 126 */     objectObjectHashMap.put("npcchubao", obj1.npcchubao);
/* 127 */     objectObjectHashMap.put("baibangmang", Integer.valueOf(obj1.baibangmang));
/* 128 */     objectObjectHashMap.put("shimencishu", Integer.valueOf(obj1.shimencishu));
/* 129 */     objectObjectHashMap.put("npcName", obj1.npcName);
/* 130 */     objectObjectHashMap.put("fabaorenwu", Integer.valueOf(obj1.fabaorenwu));
/* 131 */     objectObjectHashMap.put("xiuxingcishu", Integer.valueOf(obj1.xiuxingcishu));
/* 132 */     objectObjectHashMap.put("xiuxingNpcname", obj1.xiuxingNpcname);
/* 133 */     objectObjectHashMap.put("autofight_select", Integer.valueOf(obj1.autofight_select));
/* 134 */     objectObjectHashMap.put("autofight_skillaction", Integer.valueOf(obj1.autofight_skillaction));
/* 135 */     objectObjectHashMap.put("autofight_skillno", Integer.valueOf(obj1.autofight_skillno));
/* 136 */     objectObjectHashMap.put("friend", Integer.valueOf(obj1.friend));
/* 137 */     objectObjectHashMap.put("owner_name", Integer.valueOf(obj1.owner_name));
/* 138 */     objectObjectHashMap.put("chenghao", obj1.chenghao);
/* 139 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> Duiyuan(Duiyuan obj1)
/*     */   {
/* 145 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 147 */     objectObjectHashMap.put("org_icon", Integer.valueOf(obj1.org_icon));
/* 148 */     objectObjectHashMap.put("iid_str", obj1.iid_str);
/* 149 */     objectObjectHashMap.put("skill", Integer.valueOf(obj1.skill));
/* 150 */     objectObjectHashMap.put("str", obj1.str);
/* 151 */     objectObjectHashMap.put("master", Integer.valueOf(obj1.master));
/* 152 */     objectObjectHashMap.put("metal", Integer.valueOf(obj1.metal));
/* 153 */     objectObjectHashMap.put("req_str", obj1.req_str);
/* 154 */     objectObjectHashMap.put("passive_mode", Integer.valueOf(obj1.passive_mode));
/* 155 */     objectObjectHashMap.put("party_contrib", obj1.party_contrib);
/* 156 */     objectObjectHashMap.put("mapteamMembersCount", Integer.valueOf(obj1.mapteamMembersCount));
/* 157 */     objectObjectHashMap.put("mapcomeback_flag", Integer.valueOf(obj1.mapcomeback_flag));
/* 158 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> EquipInformation(Object obj)
/*     */   {
/* 164 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 165 */     EquipInformation obj1 = (EquipInformation)obj;
/* 166 */     objectObjectHashMap.put("GroupNo", Integer.valueOf(obj1.GroupNo));
/* 167 */     objectObjectHashMap.put("GroupType", Integer.valueOf(obj1.GroupType));
/* 168 */     objectObjectHashMap.put("dunwu_times", Integer.valueOf(obj1.dunwu_times));
/* 169 */     objectObjectHashMap.put("attrib", Integer.valueOf(obj1.attrib));
/* 170 */     objectObjectHashMap.put("gift", Integer.valueOf(obj1.gift));
/* 171 */     objectObjectHashMap.put("total_score", Integer.valueOf(obj1.total_score));
/* 172 */     objectObjectHashMap.put("nick", Integer.valueOf(obj1.nick));
/* 173 */     objectObjectHashMap.put("power", Integer.valueOf(obj1.power));
/* 174 */     objectObjectHashMap.put("wrestle_score", Integer.valueOf(obj1.wrestle_score));
/* 175 */     objectObjectHashMap.put("skill", Integer.valueOf(obj1.skill));
/* 176 */     objectObjectHashMap.put("store_exp", Integer.valueOf(obj1.store_exp));
/* 177 */     objectObjectHashMap.put("metal", Integer.valueOf(obj1.metal));
/* 178 */     objectObjectHashMap.put("amount", Integer.valueOf(obj1.amount));
/* 179 */     objectObjectHashMap.put("type", Integer.valueOf(obj1.type));
/* 180 */     objectObjectHashMap.put("rebuild_level", Integer.valueOf(obj1.rebuild_level));
/* 181 */     objectObjectHashMap.put("color", Integer.valueOf(obj1.color));
/* 182 */     objectObjectHashMap.put("str", obj1.str);
/* 183 */     objectObjectHashMap.put("auto_fight", obj1.auto_fight);
/* 184 */     objectObjectHashMap.put("suit_degree", obj1.suit_degree);
/* 185 */     objectObjectHashMap.put("party_stage_party_name", Integer.valueOf(obj1.party_stage_party_name));
/* 186 */     objectObjectHashMap.put("mailing_item_times", Integer.valueOf(obj1.mailing_item_times));
/* 187 */     objectObjectHashMap.put("quality", obj1.quality);
/* 188 */     objectObjectHashMap.put("damage_sel_rate", Integer.valueOf(obj1.damage_sel_rate));
/* 189 */     objectObjectHashMap.put("recognize_recognized", Integer.valueOf(obj1.recognize_recognized));
/* 190 */     objectObjectHashMap.put("suit_enabled", Integer.valueOf(obj1.suit_enabled));
/* 191 */     objectObjectHashMap.put("degree_32", Integer.valueOf(obj1.degree_32));
/* 192 */     objectObjectHashMap.put("master", Integer.valueOf(obj1.master));
/* 193 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> Goods(Object obj)
/*     */   {
/* 199 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 200 */     Goods obj1 = (Goods)obj;
/* 201 */     objectObjectHashMap.put("pos", Integer.valueOf(obj1.pos));
/* 202 */     objectObjectHashMap.put("goodsInfo", obj1.goodsInfo);
/* 203 */     objectObjectHashMap.put("goodsBasics", obj1.goodsBasics);
/* 204 */     objectObjectHashMap.put("goodsLanSe", obj1.goodsLanSe);
/* 205 */     objectObjectHashMap.put("goodsFenSe", obj1.goodsFenSe);
/* 206 */     objectObjectHashMap.put("goodsHuangSe", obj1.goodsHuangSe);
/* 207 */     objectObjectHashMap.put("goodsLvSe", obj1.goodsLvSe);
/* 208 */     objectObjectHashMap.put("goodsGaiZao", obj1.goodsGaiZao);
/* 209 */     objectObjectHashMap.put("goodsGaiZaoGongMing", obj1.goodsGaiZaoGongMing);
/* 210 */     objectObjectHashMap.put("goodsGaiZaoGongMingChengGong", obj1.goodsGaiZaoGongMingChengGong);
/* 211 */     objectObjectHashMap.put("goodsLvSeGongMing", obj1.goodsLvSeGongMing);
/* 212 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> GoodsBasics(Object obj)
/*     */   {
/* 218 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 219 */     GoodsBasics obj1 = (GoodsBasics)obj;
/* 220 */     objectObjectHashMap.put("groupNo", Integer.valueOf(obj1.groupNo));
/* 221 */     objectObjectHashMap.put("groupType", Integer.valueOf(obj1.groupType));
/* 222 */     objectObjectHashMap.put("mana", Integer.valueOf(obj1.mana));
/* 223 */     objectObjectHashMap.put("accurate", Integer.valueOf(obj1.accurate));
/* 224 */     objectObjectHashMap.put("def", Integer.valueOf(obj1.def));
/* 225 */     objectObjectHashMap.put("dex", Integer.valueOf(obj1.dex));
/* 226 */     objectObjectHashMap.put("wiz", Integer.valueOf(obj1.wiz));
/* 227 */     objectObjectHashMap.put("parry", Integer.valueOf(obj1.parry));
/* 228 */     objectObjectHashMap.put("max_life", Integer.valueOf(obj1.max_life));
/* 229 */     objectObjectHashMap.put("max_mana", Integer.valueOf(obj1.max_mana));
/* 230 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> GoodsFenSe(GoodsFenSe obj1)
/*     */   {
/* 236 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 238 */     objectObjectHashMap.put("groupNo", Integer.valueOf(obj1.groupNo));
/* 239 */     objectObjectHashMap.put("groupType", Integer.valueOf(obj1.groupType));
/* 240 */     objectObjectHashMap.put("phy_power", Integer.valueOf(obj1.phy_power));
/* 241 */     objectObjectHashMap.put("mag_power", Integer.valueOf(obj1.mag_power));
/* 242 */     objectObjectHashMap.put("speed", Integer.valueOf(obj1.speed));
/* 243 */     objectObjectHashMap.put("life", Integer.valueOf(obj1.life));
/* 244 */     objectObjectHashMap.put("mstunt_rate", Integer.valueOf(obj1.mstunt_rate));
/* 245 */     objectObjectHashMap.put("skill_low_cost", Integer.valueOf(obj1.skill_low_cost));
			  objectObjectHashMap.put("parry", Integer.valueOf(obj1.parry));
/* 246 */     objectObjectHashMap.put("all_polar", Integer.valueOf(obj1.all_polar));
/* 247 */     objectObjectHashMap.put("all_resist_polar", Integer.valueOf(obj1.all_resist_polar));
/* 248 */     objectObjectHashMap.put("wood", Integer.valueOf(obj1.wood));
/* 249 */     objectObjectHashMap.put("water", Integer.valueOf(obj1.water));
/* 250 */     objectObjectHashMap.put("fire", Integer.valueOf(obj1.fire));
/* 251 */     objectObjectHashMap.put("earth", Integer.valueOf(obj1.earth));
/* 252 */     objectObjectHashMap.put("resist_metal", Integer.valueOf(obj1.resist_metal));
/* 253 */     objectObjectHashMap.put("damage_sel", Integer.valueOf(obj1.damage_sel));
/* 254 */     objectObjectHashMap.put("stunt_rate", Integer.valueOf(obj1.stunt_rate));
/* 255 */     objectObjectHashMap.put("double_hit_rate", Integer.valueOf(obj1.double_hit_rate));
/* 256 */     objectObjectHashMap.put("release_forgotten", Integer.valueOf(obj1.release_forgotten));
/* 257 */     objectObjectHashMap.put("ignore_all_resist_except", Integer.valueOf(obj1.ignore_all_resist_except));
/* 258 */     objectObjectHashMap.put("stunt", Integer.valueOf(obj1.stunt));
/* 259 */     objectObjectHashMap.put("def", Integer.valueOf(obj1.def));
/* 260 */     objectObjectHashMap.put("dex", Integer.valueOf(obj1.dex));
/* 261 */     objectObjectHashMap.put("wiz", Integer.valueOf(obj1.wiz));
/* 262 */     objectObjectHashMap.put("family", Integer.valueOf(obj1.family));
/* 263 */     objectObjectHashMap.put("life_recover", Integer.valueOf(obj1.life_recover));
/* 264 */     objectObjectHashMap.put("all_skill", Integer.valueOf(obj1.all_skill));
/* 265 */     objectObjectHashMap.put("portrait", Integer.valueOf(obj1.portrait));
/* 266 */     objectObjectHashMap.put("resist_frozen", Integer.valueOf(obj1.resist_frozen));
/* 267 */     objectObjectHashMap.put("resist_sleep", Integer.valueOf(obj1.resist_sleep));
/* 268 */     objectObjectHashMap.put("resist_forgotten", Integer.valueOf(obj1.resist_forgotten));
/* 269 */     objectObjectHashMap.put("resist_confusion", Integer.valueOf(obj1.resist_confusion));
/* 270 */     objectObjectHashMap.put("longevity", Integer.valueOf(obj1.longevity));
/* 271 */     objectObjectHashMap.put("resist_wood", Integer.valueOf(obj1.resist_wood));
/* 272 */     objectObjectHashMap.put("resist_water", Integer.valueOf(obj1.resist_water));
/* 273 */     objectObjectHashMap.put("resist_fire", Integer.valueOf(obj1.resist_fire));
/* 274 */     objectObjectHashMap.put("resist_earth", Integer.valueOf(obj1.resist_earth));
/* 275 */     objectObjectHashMap.put("exp_to_next_level", Integer.valueOf(obj1.exp_to_next_level));
/* 276 */     objectObjectHashMap.put("all_resist_except", Integer.valueOf(obj1.all_resist_except));
/* 277 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> GoodsGaiZao(GoodsGaiZao obj1)
/*     */   {
/* 283 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 285 */     objectObjectHashMap.put("groupNo", Integer.valueOf(obj1.groupNo));
/* 286 */     objectObjectHashMap.put("groupType", Integer.valueOf(obj1.groupType));
/* 287 */     objectObjectHashMap.put("accurate", Integer.valueOf(obj1.accurate));
/* 288 */     objectObjectHashMap.put("all_polar", Integer.valueOf(obj1.all_polar));
/* 289 */     objectObjectHashMap.put("wiz", Integer.valueOf(obj1.wiz));
/* 290 */     objectObjectHashMap.put("def", Integer.valueOf(obj1.def));
/* 291 */     objectObjectHashMap.put("mana", Integer.valueOf(obj1.mana));
/* 292 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> GoodsGaiZaoGongMing(Object obj)
/*     */   {
/* 298 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 299 */     GoodsGaiZaoGongMing obj1 = (GoodsGaiZaoGongMing)obj;
/* 300 */     objectObjectHashMap.put("groupNo", Integer.valueOf(obj1.groupNo));
/* 301 */     objectObjectHashMap.put("groupType", Integer.valueOf(obj1.groupType));
/* 302 */     objectObjectHashMap.put("damage_sel", Integer.valueOf(obj1.damage_sel));
/* 303 */     objectObjectHashMap.put("accurate", Integer.valueOf(obj1.accurate));
/* 304 */     objectObjectHashMap.put("mana", Integer.valueOf(obj1.mana));
/* 305 */     objectObjectHashMap.put("def", Integer.valueOf(obj1.def));
/* 306 */     objectObjectHashMap.put("wiz", Integer.valueOf(obj1.wiz));
/* 307 */     objectObjectHashMap.put("parry", Integer.valueOf(obj1.parry));
/* 308 */     objectObjectHashMap.put("phy_power", Integer.valueOf(obj1.phy_power));
/* 309 */     objectObjectHashMap.put("mag_power", Integer.valueOf(obj1.mag_power));
/* 310 */     objectObjectHashMap.put("speed", Integer.valueOf(obj1.speed));
/* 311 */     objectObjectHashMap.put("life", Integer.valueOf(obj1.life));
/* 312 */     objectObjectHashMap.put("resist_frozen", Integer.valueOf(obj1.resist_frozen));
/* 313 */     objectObjectHashMap.put("resist_sleep", Integer.valueOf(obj1.resist_sleep));
/* 314 */     objectObjectHashMap.put("resist_forgotten", Integer.valueOf(obj1.resist_forgotten));
/* 315 */     objectObjectHashMap.put("resist_confusion", Integer.valueOf(obj1.resist_confusion));
/* 316 */     objectObjectHashMap.put("longevity", Integer.valueOf(obj1.longevity));
/* 317 */     objectObjectHashMap.put("resist_wood", Integer.valueOf(obj1.resist_wood));
/* 318 */     objectObjectHashMap.put("resist_water", Integer.valueOf(obj1.resist_water));
/* 319 */     objectObjectHashMap.put("resist_fire", Integer.valueOf(obj1.resist_fire));
/* 320 */     objectObjectHashMap.put("resist_earth", Integer.valueOf(obj1.resist_earth));
/* 321 */     objectObjectHashMap.put("exp_to_next_level", Integer.valueOf(obj1.exp_to_next_level));
/* 322 */     objectObjectHashMap.put("mstunt_rate", Integer.valueOf(obj1.mstunt_rate));
/* 323 */     objectObjectHashMap.put("stunt_rate", Integer.valueOf(obj1.stunt_rate));
/* 324 */     objectObjectHashMap.put("double_hit_rate", Integer.valueOf(obj1.double_hit_rate));
/* 325 */     objectObjectHashMap.put("super_excluse_wood", Integer.valueOf(obj1.super_excluse_wood));
/* 326 */     objectObjectHashMap.put("super_excluse_water", Integer.valueOf(obj1.super_excluse_water));
/* 327 */     objectObjectHashMap.put("super_excluse_fire", Integer.valueOf(obj1.super_excluse_fire));
/* 328 */     objectObjectHashMap.put("super_excluse_earth", Integer.valueOf(obj1.super_excluse_earth));
/* 329 */     objectObjectHashMap.put("B_skill_low_cost", Integer.valueOf(obj1.B_skill_low_cost));
/* 330 */     objectObjectHashMap.put("life_recover", Integer.valueOf(obj1.life_recover));
/* 331 */     objectObjectHashMap.put("family", Integer.valueOf(obj1.family));
/* 332 */     objectObjectHashMap.put("portrait", Integer.valueOf(obj1.portrait));
/* 333 */     objectObjectHashMap.put("tao_ex", Integer.valueOf(obj1.tao_ex));
/* 334 */     objectObjectHashMap.put("release_confusion", Integer.valueOf(obj1.release_confusion));
/* 335 */     objectObjectHashMap.put("release_sleep", Integer.valueOf(obj1.release_sleep));
/* 336 */     objectObjectHashMap.put("release_frozen", Integer.valueOf(obj1.release_frozen));
/* 337 */     objectObjectHashMap.put("release_poison", Integer.valueOf(obj1.release_poison));
/* 338 */     objectObjectHashMap.put("C_skill_low_cost", Integer.valueOf(obj1.C_skill_low_cost));
/* 339 */     objectObjectHashMap.put("D_skill_low_cost", Integer.valueOf(obj1.D_skill_low_cost));
/* 340 */     objectObjectHashMap.put("super_poison", Integer.valueOf(obj1.super_poison));
/* 341 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> GoodsGaiZaoGongMingChengGong(GoodsGaiZaoGongMingChengGong obj1)
/*     */   {
/* 347 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 349 */     objectObjectHashMap.put("groupNo", Integer.valueOf(obj1.groupNo));
/* 350 */     objectObjectHashMap.put("groupType", Integer.valueOf(obj1.groupType));
/* 351 */     objectObjectHashMap.put("color", Integer.valueOf(obj1.color));
/* 352 */     objectObjectHashMap.put("damage_sel", Integer.valueOf(obj1.damage_sel));
/* 353 */     objectObjectHashMap.put("accurate", Integer.valueOf(obj1.accurate));
/* 354 */     objectObjectHashMap.put("mana", Integer.valueOf(obj1.mana));
/* 355 */     objectObjectHashMap.put("def", Integer.valueOf(obj1.def));
/* 356 */     objectObjectHashMap.put("wiz", Integer.valueOf(obj1.wiz));
/* 357 */     objectObjectHashMap.put("parry", Integer.valueOf(obj1.parry));
/* 358 */     objectObjectHashMap.put("phy_power", Integer.valueOf(obj1.phy_power));
/* 359 */     objectObjectHashMap.put("mag_power", Integer.valueOf(obj1.mag_power));
/* 360 */     objectObjectHashMap.put("speed", Integer.valueOf(obj1.speed));
/* 361 */     objectObjectHashMap.put("life", Integer.valueOf(obj1.life));
/* 362 */     objectObjectHashMap.put("resist_frozen", Integer.valueOf(obj1.resist_frozen));
/* 363 */     objectObjectHashMap.put("resist_sleep", Integer.valueOf(obj1.resist_sleep));
/* 364 */     objectObjectHashMap.put("resist_forgotten", Integer.valueOf(obj1.resist_forgotten));
/* 365 */     objectObjectHashMap.put("resist_confusion", Integer.valueOf(obj1.resist_confusion));
/* 366 */     objectObjectHashMap.put("longevity", Integer.valueOf(obj1.longevity));
/* 367 */     objectObjectHashMap.put("resist_wood", Integer.valueOf(obj1.resist_wood));
/* 368 */     objectObjectHashMap.put("resist_water", Integer.valueOf(obj1.resist_water));
/* 369 */     objectObjectHashMap.put("resist_fire", Integer.valueOf(obj1.resist_fire));
/* 370 */     objectObjectHashMap.put("resist_earth", Integer.valueOf(obj1.resist_earth));
/* 371 */     objectObjectHashMap.put("exp_to_next_level", Integer.valueOf(obj1.exp_to_next_level));
/* 372 */     objectObjectHashMap.put("mstunt_rate", Integer.valueOf(obj1.mstunt_rate));
/* 373 */     objectObjectHashMap.put("stunt_rate", Integer.valueOf(obj1.stunt_rate));
/* 374 */     objectObjectHashMap.put("double_hit_rate", Integer.valueOf(obj1.double_hit_rate));
/* 375 */     objectObjectHashMap.put("super_excluse_wood", Integer.valueOf(obj1.super_excluse_wood));
/* 376 */     objectObjectHashMap.put("super_excluse_water", Integer.valueOf(obj1.super_excluse_water));
/* 377 */     objectObjectHashMap.put("super_excluse_fire", Integer.valueOf(obj1.super_excluse_fire));
/* 378 */     objectObjectHashMap.put("super_excluse_earth", Integer.valueOf(obj1.super_excluse_earth));
/* 379 */     objectObjectHashMap.put("B_skill_low_cost", Integer.valueOf(obj1.B_skill_low_cost));
/* 380 */     objectObjectHashMap.put("life_recover", Integer.valueOf(obj1.life_recover));
/* 381 */     objectObjectHashMap.put("family", Integer.valueOf(obj1.family));
/* 382 */     objectObjectHashMap.put("portrait", Integer.valueOf(obj1.portrait));
/* 383 */     objectObjectHashMap.put("tao_ex", Integer.valueOf(obj1.tao_ex));
/* 384 */     objectObjectHashMap.put("release_confusion", Integer.valueOf(obj1.release_confusion));
/* 385 */     objectObjectHashMap.put("release_sleep", Integer.valueOf(obj1.release_sleep));
/* 386 */     objectObjectHashMap.put("release_frozen", Integer.valueOf(obj1.release_frozen));
/* 387 */     objectObjectHashMap.put("release_poison", Integer.valueOf(obj1.release_poison));
/* 388 */     objectObjectHashMap.put("C_skill_low_cost", Integer.valueOf(obj1.C_skill_low_cost));
/* 389 */     objectObjectHashMap.put("D_skill_low_cost", Integer.valueOf(obj1.D_skill_low_cost));
/* 390 */     objectObjectHashMap.put("super_poison", Integer.valueOf(obj1.super_poison));
/* 391 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> GoodsHuangSe(GoodsHuangSe obj1)
/*     */   {
/* 397 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 399 */     objectObjectHashMap.put("groupNo", Integer.valueOf(obj1.groupNo));
/* 400 */     objectObjectHashMap.put("groupType", Integer.valueOf(obj1.groupType));
/* 401 */     objectObjectHashMap.put("phy_power", Integer.valueOf(obj1.phy_power));
/* 402 */     objectObjectHashMap.put("mag_power", Integer.valueOf(obj1.mag_power));
/* 403 */     objectObjectHashMap.put("speed", Integer.valueOf(obj1.speed));
/* 404 */     objectObjectHashMap.put("life", Integer.valueOf(obj1.life));
/* 405 */     objectObjectHashMap.put("mstunt_rate", Integer.valueOf(obj1.mstunt_rate));
			  objectObjectHashMap.put("parry", Integer.valueOf(obj1.parry));
			  objectObjectHashMap.put("mana", Integer.valueOf(obj1.mana));
/* 406 */     objectObjectHashMap.put("skill_low_cost", Integer.valueOf(obj1.skill_low_cost));
/* 407 */     objectObjectHashMap.put("all_polar", Integer.valueOf(obj1.all_polar));
/* 408 */     objectObjectHashMap.put("all_resist_polar", Integer.valueOf(obj1.all_resist_polar));
/* 409 */     objectObjectHashMap.put("wood", Integer.valueOf(obj1.wood));
/* 410 */     objectObjectHashMap.put("water", Integer.valueOf(obj1.water));
/* 411 */     objectObjectHashMap.put("fire", Integer.valueOf(obj1.fire));
/* 412 */     objectObjectHashMap.put("earth", Integer.valueOf(obj1.earth));
/* 413 */     objectObjectHashMap.put("resist_metal", Integer.valueOf(obj1.resist_metal));
/* 414 */     objectObjectHashMap.put("damage_sel", Integer.valueOf(obj1.damage_sel));
/* 415 */     objectObjectHashMap.put("stunt_rate", Integer.valueOf(obj1.stunt_rate));
/* 416 */     objectObjectHashMap.put("double_hit_rate", Integer.valueOf(obj1.double_hit_rate));
/* 417 */     objectObjectHashMap.put("release_forgotten", Integer.valueOf(obj1.release_forgotten));
/* 418 */     objectObjectHashMap.put("ignore_all_resist_except", Integer.valueOf(obj1.ignore_all_resist_except));
/* 419 */     objectObjectHashMap.put("stunt", Integer.valueOf(obj1.stunt));
/* 420 */     objectObjectHashMap.put("def", Integer.valueOf(obj1.def));
/* 421 */     objectObjectHashMap.put("dex", Integer.valueOf(obj1.dex));
/* 422 */     objectObjectHashMap.put("wiz", Integer.valueOf(obj1.wiz));
/* 423 */     objectObjectHashMap.put("family", Integer.valueOf(obj1.family));
/* 424 */     objectObjectHashMap.put("life_recover", Integer.valueOf(obj1.life_recover));
/* 425 */     objectObjectHashMap.put("all_skill", Integer.valueOf(obj1.all_skill));
/* 426 */     objectObjectHashMap.put("portrait", Integer.valueOf(obj1.portrait));
/* 427 */     objectObjectHashMap.put("resist_frozen", Integer.valueOf(obj1.resist_frozen));
/* 428 */     objectObjectHashMap.put("resist_sleep", Integer.valueOf(obj1.resist_sleep));
/* 429 */     objectObjectHashMap.put("resist_forgotten", Integer.valueOf(obj1.resist_forgotten));
/* 430 */     objectObjectHashMap.put("resist_confusion", Integer.valueOf(obj1.resist_confusion));
/* 431 */     objectObjectHashMap.put("longevity", Integer.valueOf(obj1.longevity));
/* 432 */     objectObjectHashMap.put("resist_wood", Integer.valueOf(obj1.resist_wood));
/* 433 */     objectObjectHashMap.put("resist_water", Integer.valueOf(obj1.resist_water));
/* 434 */     objectObjectHashMap.put("resist_fire", Integer.valueOf(obj1.resist_fire));
/* 435 */     objectObjectHashMap.put("resist_earth", Integer.valueOf(obj1.resist_earth));
/* 436 */     objectObjectHashMap.put("exp_to_next_level", Integer.valueOf(obj1.exp_to_next_level));
/* 437 */     objectObjectHashMap.put("all_resist_except", Integer.valueOf(obj1.all_resist_except));
/* 438 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> GoodsInfo(GoodsInfo obj1)
/*     */   {
/* 444 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 446 */     objectObjectHashMap.put("groupNo", Integer.valueOf(obj1.groupNo));
/* 447 */     objectObjectHashMap.put("groupType", Integer.valueOf(obj1.groupType));
/* 448 */     objectObjectHashMap.put("value", Integer.valueOf(obj1.value));
/* 449 */     objectObjectHashMap.put("total_score", Integer.valueOf(obj1.total_score));
/* 450 */     objectObjectHashMap.put("type", Integer.valueOf(obj1.type));
/* 451 */     objectObjectHashMap.put("rebuild_level", Integer.valueOf(obj1.rebuild_level));
/* 452 */     objectObjectHashMap.put("str", obj1.str);
/* 453 */     objectObjectHashMap.put("auto_fight", obj1.auto_fight);
			  objectObjectHashMap.put("parry", Integer.valueOf(obj1.parry));
/* 454 */     objectObjectHashMap.put("quality", obj1.quality);
/* 455 */     objectObjectHashMap.put("damage_sel_rate", Integer.valueOf(obj1.damage_sel_rate));
/* 456 */     objectObjectHashMap.put("recognize_recognized", Integer.valueOf(obj1.recognize_recognized));
/* 457 */     objectObjectHashMap.put("owner_id", Integer.valueOf(obj1.owner_id));
/* 458 */     objectObjectHashMap.put("dunwu_times", Integer.valueOf(obj1.dunwu_times));
/* 459 */     objectObjectHashMap.put("attrib", Integer.valueOf(obj1.attrib));
/* 460 */     objectObjectHashMap.put("gift", Integer.valueOf(obj1.gift));
/* 461 */     objectObjectHashMap.put("nick", Integer.valueOf(obj1.nick));
/* 462 */     objectObjectHashMap.put("power", Integer.valueOf(obj1.power));
/* 463 */     objectObjectHashMap.put("wrestlescore", Integer.valueOf(obj1.wrestlescore));
/* 464 */     objectObjectHashMap.put("skill", Integer.valueOf(obj1.skill));
/* 465 */     objectObjectHashMap.put("store_exp", Integer.valueOf(obj1.store_exp));
/* 466 */     objectObjectHashMap.put("metal", Integer.valueOf(obj1.metal));
/* 467 */     objectObjectHashMap.put("amount", Integer.valueOf(obj1.amount));
/* 468 */     objectObjectHashMap.put("color", Integer.valueOf(obj1.color));
/* 469 */     objectObjectHashMap.put("suit_degree", Integer.valueOf(obj1.suit_degree));
/* 470 */     objectObjectHashMap.put("party_stage_party_name", Integer.valueOf(obj1.party_stage_party_name));
/* 471 */     objectObjectHashMap.put("mailing_item_times", Integer.valueOf(obj1.mailing_item_times));
/* 472 */     objectObjectHashMap.put("suit_enabled", Integer.valueOf(obj1.suit_enabled));
/* 473 */     objectObjectHashMap.put("degree_32", Integer.valueOf(obj1.degree_32));
/* 474 */     objectObjectHashMap.put("master", Integer.valueOf(obj1.master));
/* 475 */     objectObjectHashMap.put("transform_cool_ti", Integer.valueOf(obj1.transform_cool_ti));
/* 476 */     objectObjectHashMap.put("silver_coin", Integer.valueOf(obj1.silver_coin));
/* 477 */     objectObjectHashMap.put("diandqk_frozen_round", Integer.valueOf(obj1.diandqk_frozen_round));
/* 478 */     objectObjectHashMap.put("shuadao_ziqihongmeng", Integer.valueOf(obj1.shuadao_ziqihongmeng));
/* 479 */     objectObjectHashMap.put("durability", Integer.valueOf(obj1.durability));
/* 480 */     objectObjectHashMap.put("add_pet_exp", Integer.valueOf(obj1.add_pet_exp));
/* 481 */     objectObjectHashMap.put("alias", obj1.alias);
/* 482 */     objectObjectHashMap.put("food_num", Integer.valueOf(obj1.food_num));
/* 483 */     objectObjectHashMap.put("merge_rate", Integer.valueOf(obj1.merge_rate));
/* 484 */     objectObjectHashMap.put("fasion_type", Integer.valueOf(obj1.fasion_type));
/* 485 */     objectObjectHashMap.put("pet_upgraded", Integer.valueOf(obj1.pet_upgraded));
/* 486 */     objectObjectHashMap.put("couple", Integer.valueOf(obj1.couple));
/* 487 */     objectObjectHashMap.put("shape", Integer.valueOf(obj1.shape));
/* 488 */     objectObjectHashMap.put("pot", Integer.valueOf(obj1.pot));
/* 489 */     objectObjectHashMap.put("resist_poison", Integer.valueOf(obj1.resist_poison));
/* 490 */     objectObjectHashMap.put("phy_rebuild_level", obj1.phy_rebuild_level);
/* 491 */     objectObjectHashMap.put("max_durability", Integer.valueOf(obj1.max_durability));
/* 492 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> GoodsLanSe(GoodsLanSe obj1)
/*     */   {
/* 498 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 500 */     objectObjectHashMap.put("groupNo", Integer.valueOf(obj1.groupNo));
/* 501 */     objectObjectHashMap.put("groupType", Integer.valueOf(obj1.groupType));
/* 502 */     objectObjectHashMap.put("phy_power", Integer.valueOf(obj1.phy_power));
/* 503 */     objectObjectHashMap.put("mag_power", Integer.valueOf(obj1.mag_power));
/* 504 */     objectObjectHashMap.put("speed", Integer.valueOf(obj1.speed));
/* 505 */     objectObjectHashMap.put("life", Integer.valueOf(obj1.life));
/* 506 */     objectObjectHashMap.put("skill_low_cost", Integer.valueOf(obj1.skill_low_cost));
/* 507 */     objectObjectHashMap.put("mstunt_rate", Integer.valueOf(obj1.mstunt_rate));
/* 508 */     objectObjectHashMap.put("all_polar", Integer.valueOf(obj1.all_polar));
/* 509 */     objectObjectHashMap.put("all_resist_polar", Integer.valueOf(obj1.all_resist_polar));
/* 510 */     objectObjectHashMap.put("wood", Integer.valueOf(obj1.wood));
/* 511 */     objectObjectHashMap.put("water", Integer.valueOf(obj1.water));
/* 512 */     objectObjectHashMap.put("fire", Integer.valueOf(obj1.fire));
/* 513 */     objectObjectHashMap.put("earth", Integer.valueOf(obj1.earth));
/* 514 */     objectObjectHashMap.put("resist_metal", Integer.valueOf(obj1.resist_metal));
/* 515 */     objectObjectHashMap.put("damage_sel", Integer.valueOf(obj1.damage_sel));
/* 516 */     objectObjectHashMap.put("stunt_rate", Integer.valueOf(obj1.stunt_rate));
/* 517 */     objectObjectHashMap.put("double_hit_rate", Integer.valueOf(obj1.double_hit_rate));
/* 518 */     objectObjectHashMap.put("release_forgotten", Integer.valueOf(obj1.release_forgotten));
/* 519 */     objectObjectHashMap.put("ignore_all_resist_except", Integer.valueOf(obj1.ignore_all_resist_except));
/* 520 */     objectObjectHashMap.put("stunt", Integer.valueOf(obj1.stunt));
/* 521 */     objectObjectHashMap.put("def", Integer.valueOf(obj1.def));
/* 522 */     objectObjectHashMap.put("dex", Integer.valueOf(obj1.dex));
/* 523 */     objectObjectHashMap.put("wiz", Integer.valueOf(obj1.wiz));
/* 524 */     objectObjectHashMap.put("family", Integer.valueOf(obj1.family));
/* 525 */     objectObjectHashMap.put("life_recover", Integer.valueOf(obj1.life_recover));
/* 526 */     objectObjectHashMap.put("all_skill", Integer.valueOf(obj1.all_skill));
/* 527 */     objectObjectHashMap.put("portrait", Integer.valueOf(obj1.portrait));
/* 528 */     objectObjectHashMap.put("resist_frozen", Integer.valueOf(obj1.resist_frozen));
/* 529 */     objectObjectHashMap.put("resist_sleep", Integer.valueOf(obj1.resist_sleep));
/* 530 */     objectObjectHashMap.put("resist_forgotten", Integer.valueOf(obj1.resist_forgotten));
/* 531 */     objectObjectHashMap.put("resist_confusion", Integer.valueOf(obj1.resist_confusion));
/* 532 */     objectObjectHashMap.put("longevity", Integer.valueOf(obj1.longevity));
/* 533 */     objectObjectHashMap.put("resist_wood", Integer.valueOf(obj1.resist_wood));
/* 534 */     objectObjectHashMap.put("resist_water", Integer.valueOf(obj1.resist_water));
/* 535 */     objectObjectHashMap.put("resist_fire", Integer.valueOf(obj1.resist_fire));
/* 536 */     objectObjectHashMap.put("resist_earth", Integer.valueOf(obj1.resist_earth));
/* 537 */     objectObjectHashMap.put("exp_to_next_level", Integer.valueOf(obj1.exp_to_next_level));
/* 538 */     objectObjectHashMap.put("all_resist_except", Integer.valueOf(obj1.all_resist_except));
/* 539 */     objectObjectHashMap.put("accurate", Integer.valueOf(obj1.accurate));
/* 540 */     objectObjectHashMap.put("mana", Integer.valueOf(obj1.mana));
/* 541 */     objectObjectHashMap.put("parry", Integer.valueOf(obj1.parry));
/* 542 */     objectObjectHashMap.put("ignore_resist_wood", Integer.valueOf(obj1.ignore_resist_wood));
/* 543 */     objectObjectHashMap.put("ignore_resist_water", Integer.valueOf(obj1.ignore_resist_water));
/* 544 */     objectObjectHashMap.put("ignore_resist_fire", Integer.valueOf(obj1.ignore_resist_fire));
/* 545 */     objectObjectHashMap.put("ignore_resist_earth", Integer.valueOf(obj1.ignore_resist_earth));
/* 546 */     objectObjectHashMap.put("ignore_resist_forgotten", Integer.valueOf(obj1.ignore_resist_forgotten));
/* 547 */     objectObjectHashMap.put("ignore_resist_frozen", Integer.valueOf(obj1.ignore_resist_frozen));
/* 548 */     objectObjectHashMap.put("ignore_resist_sleep", Integer.valueOf(obj1.ignore_resist_sleep));
/* 549 */     objectObjectHashMap.put("ignore_resist_confusion", Integer.valueOf(obj1.ignore_resist_confusion));
/* 550 */     objectObjectHashMap.put("super_excluse_metal", Integer.valueOf(obj1.super_excluse_metal));
/* 551 */     objectObjectHashMap.put("ignore_resist_poison", Integer.valueOf(obj1.ignore_resist_poison));
/* 552 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> GoodsLvSe(Object obj)
/*     */   {
/* 558 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 559 */     GoodsLvSe obj1 = (GoodsLvSe)obj;
/* 560 */     objectObjectHashMap.put("groupNo", Integer.valueOf(obj1.groupNo));
/* 561 */     objectObjectHashMap.put("groupType", Integer.valueOf(obj1.groupType));
/* 562 */     objectObjectHashMap.put("accurate", Integer.valueOf(obj1.accurate));
/* 563 */     objectObjectHashMap.put("resist_frozen", Integer.valueOf(obj1.resist_frozen));
/* 564 */     objectObjectHashMap.put("resist_sleep", Integer.valueOf(obj1.resist_sleep));
/* 565 */     objectObjectHashMap.put("resist_forgotten", Integer.valueOf(obj1.resist_forgotten));
/* 566 */     objectObjectHashMap.put("resist_confusion", Integer.valueOf(obj1.resist_confusion));
/* 567 */     objectObjectHashMap.put("longevity", Integer.valueOf(obj1.longevity));
/* 568 */     objectObjectHashMap.put("super_excluse_wood", Integer.valueOf(obj1.super_excluse_wood));
/* 569 */     objectObjectHashMap.put("super_excluse_water", Integer.valueOf(obj1.super_excluse_water));
/* 570 */     objectObjectHashMap.put("super_excluse_fire", Integer.valueOf(obj1.super_excluse_fire));
/* 571 */     objectObjectHashMap.put("super_excluse_earth", Integer.valueOf(obj1.super_excluse_earth));
/* 572 */     objectObjectHashMap.put("B_skill_low_cost", Integer.valueOf(obj1.B_skill_low_cost));
/* 573 */     objectObjectHashMap.put("enhanced_wood", Integer.valueOf(obj1.enhanced_wood));
/* 574 */     objectObjectHashMap.put("enhanced_water", Integer.valueOf(obj1.enhanced_water));
/* 575 */     objectObjectHashMap.put("enhanced_fire", Integer.valueOf(obj1.enhanced_fire));
/* 576 */     objectObjectHashMap.put("enhanced_earth", Integer.valueOf(obj1.enhanced_earth));
/* 577 */     objectObjectHashMap.put("mag_dodge", Integer.valueOf(obj1.mag_dodge));
/* 578 */     objectObjectHashMap.put("ignore_mag_dodge", Integer.valueOf(obj1.ignore_mag_dodge));
/* 579 */     objectObjectHashMap.put("jinguang_zhaxian_counter_att_rate", Integer.valueOf(obj1.jinguang_zhaxian_counter_att_rate));
/* 580 */     objectObjectHashMap.put("C_skill_low_cost", Integer.valueOf(obj1.C_skill_low_cost));
/* 581 */     objectObjectHashMap.put("D_skill_low_cost", Integer.valueOf(obj1.D_skill_low_cost));
/* 582 */     objectObjectHashMap.put("super_poison", Integer.valueOf(obj1.super_poison));
/* 583 */     objectObjectHashMap.put("ignore_resist_wood", Integer.valueOf(obj1.ignore_resist_wood));
/* 584 */     objectObjectHashMap.put("ignore_resist_water", Integer.valueOf(obj1.ignore_resist_water));
/* 585 */     objectObjectHashMap.put("ignore_resist_fire", Integer.valueOf(obj1.ignore_resist_fire));
/* 586 */     objectObjectHashMap.put("ignore_resist_earth", Integer.valueOf(obj1.ignore_resist_earth));
/* 587 */     objectObjectHashMap.put("ignore_resist_forgotten", Integer.valueOf(obj1.ignore_resist_forgotten));
/* 588 */     objectObjectHashMap.put("release_forgotten", Integer.valueOf(obj1.release_forgotten));
/* 589 */     objectObjectHashMap.put("ignore_all_resist_except", Integer.valueOf(obj1.ignore_all_resist_except));
/* 590 */     objectObjectHashMap.put("super_confusion", Integer.valueOf(obj1.super_confusion));
/* 591 */     objectObjectHashMap.put("super_sleep", Integer.valueOf(obj1.super_sleep));
/* 592 */     objectObjectHashMap.put("enhanced_metal", Integer.valueOf(obj1.enhanced_metal));
/* 593 */     objectObjectHashMap.put("super_forgotten", Integer.valueOf(obj1.super_forgotten));
/* 594 */     objectObjectHashMap.put("super_frozen", Integer.valueOf(obj1.super_frozen));
/* 595 */     objectObjectHashMap.put("ignore_resist_frozen", Integer.valueOf(obj1.ignore_resist_frozen));
/* 596 */     objectObjectHashMap.put("ignore_resist_sleep", Integer.valueOf(obj1.ignore_resist_sleep));
/* 597 */     objectObjectHashMap.put("ignore_resist_confusion", Integer.valueOf(obj1.ignore_resist_confusion));
/* 598 */     objectObjectHashMap.put("super_excluse_metal", Integer.valueOf(obj1.super_excluse_metal));
/* 599 */     objectObjectHashMap.put("ignore_resist_poison", Integer.valueOf(obj1.ignore_resist_poison));
/* 600 */     objectObjectHashMap.put("tao_ex", Integer.valueOf(obj1.tao_ex));
/* 601 */     objectObjectHashMap.put("release_confusion", Integer.valueOf(obj1.release_confusion));
/* 602 */     objectObjectHashMap.put("release_sleep", Integer.valueOf(obj1.release_sleep));
/* 603 */     objectObjectHashMap.put("release_frozen", Integer.valueOf(obj1.release_frozen));
/* 604 */     objectObjectHashMap.put("release_poison", Integer.valueOf(obj1.release_poison));
/* 605 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> GoodsLvSeGongMing(GoodsLvSeGongMing obj1)
/*     */   {
/* 611 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 613 */     objectObjectHashMap.put("groupNo", Integer.valueOf(obj1.groupNo));
/* 614 */     objectObjectHashMap.put("groupType", Integer.valueOf(obj1.groupType));
/* 615 */     objectObjectHashMap.put("mana", Integer.valueOf(obj1.mana));
/* 616 */     objectObjectHashMap.put("def", Integer.valueOf(obj1.def));
/* 617 */     objectObjectHashMap.put("wiz", Integer.valueOf(obj1.wiz));
/* 618 */     objectObjectHashMap.put("parry", Integer.valueOf(obj1.parry));
/* 619 */     objectObjectHashMap.put("accurate", Integer.valueOf(obj1.accurate));
/* 620 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> JiNeng(Object obj)
/*     */   {
/* 626 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 627 */     JiNeng obj1 = (JiNeng)obj;
/* 628 */     objectObjectHashMap.put("id", Integer.valueOf(obj1.id));
/* 629 */     objectObjectHashMap.put("skill_no", Integer.valueOf(obj1.skill_no));
/* 630 */     objectObjectHashMap.put("skill_attrib", Integer.valueOf(obj1.skill_attrib));
/* 631 */     objectObjectHashMap.put("skill_attrib1", Integer.valueOf(obj1.skill_attrib1));
/* 632 */     objectObjectHashMap.put("skill_level", Integer.valueOf(obj1.skill_level));
/* 633 */     objectObjectHashMap.put("level_improved", Integer.valueOf(obj1.level_improved));
/* 634 */     objectObjectHashMap.put("skill_mana_cost", Integer.valueOf(obj1.skill_mana_cost));
/* 635 */     objectObjectHashMap.put("skill_nimbus", Integer.valueOf(obj1.skill_nimbus));
/* 636 */     objectObjectHashMap.put("skill_disabled", Integer.valueOf(obj1.skill_disabled));
/* 637 */     objectObjectHashMap.put("range", Integer.valueOf(obj1.range));
/* 638 */     objectObjectHashMap.put("max_range", Integer.valueOf(obj1.max_range));
/* 639 */     objectObjectHashMap.put("count1", Integer.valueOf(obj1.count1));
/* 640 */     objectObjectHashMap.put("s1", obj1.s1);
/* 641 */     objectObjectHashMap.put("s2", Integer.valueOf(obj1.s2));
/* 642 */     objectObjectHashMap.put("isTempSkill", Integer.valueOf(obj1.isTempSkill));
/* 643 */     objectObjectHashMap.put("skillRound", Integer.valueOf(obj1.skillRound));
/* 644 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> LieBiao(Object obj)
/*     */   {
/* 650 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 651 */     LieBiao obj1 = (LieBiao)obj;
/* 652 */     objectObjectHashMap.put("ask_type", obj1.ask_type);
/* 653 */     objectObjectHashMap.put("peer_name", obj1.peer_name);
/* 654 */     objectObjectHashMap.put("duiyuanList", obj1.duiyuanList);
/* 655 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> Petbeibao(Object obj)
/*     */   {
/* 661 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 662 */     Petbeibao obj1 = (Petbeibao)obj;
/* 663 */     objectObjectHashMap.put("no", Integer.valueOf(obj1.no));
/* 664 */     objectObjectHashMap.put("id", Integer.valueOf(obj1.id));
/* 665 */     objectObjectHashMap.put("petShuXing", obj1.petShuXing);
/* 666 */     objectObjectHashMap.put("tianshu", obj1.tianshu);
/* 667 */     objectObjectHashMap.put("autofight_select", Integer.valueOf(obj1.autofight_select));
/* 668 */     objectObjectHashMap.put("autofight_skillaction", Integer.valueOf(obj1.autofight_skillaction));
/* 669 */     objectObjectHashMap.put("autofight_skillno", Integer.valueOf(obj1.autofight_skillno));
/* 670 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> PetShuXing(PetShuXing obj1)
/*     */   {
/* 676 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
///* 678 */     objectObjectHashMap.put("no", Integer.valueOf(obj1.no));
///* 679 */     objectObjectHashMap.put("type1", Integer.valueOf(obj1.type1));
/* 680 */     objectObjectHashMap.put("name", obj1.name);
/* 681 */     objectObjectHashMap.put("life", Integer.valueOf(obj1.life));
/* 682 */     objectObjectHashMap.put("max_life", Integer.valueOf(obj1.max_life));
/* 683 */     objectObjectHashMap.put("mana", Integer.valueOf(obj1.mana));
/* 684 */     objectObjectHashMap.put("max_mana", Integer.valueOf(obj1.max_mana));
/* 685 */     objectObjectHashMap.put("level", Integer.valueOf(obj1.level));
/* 686 */     objectObjectHashMap.put("penetrate", Integer.valueOf(obj1.penetrate));
/* 687 */     objectObjectHashMap.put("rank", Integer.valueOf(obj1.rank));
/* 688 */     objectObjectHashMap.put("polar", Integer.valueOf(obj1.polar));
/* 689 */     objectObjectHashMap.put("polar_point", Integer.valueOf(obj1.polar_point));
/* 690 */     objectObjectHashMap.put("icon", Integer.valueOf(obj1.icon));
/* 691 */     objectObjectHashMap.put("type", Integer.valueOf(obj1.type));
/* 692 */     objectObjectHashMap.put("str", Integer.valueOf(obj1.str));
/* 693 */     objectObjectHashMap.put("wiz", Integer.valueOf(obj1.wiz));
/* 694 */     objectObjectHashMap.put("con", Integer.valueOf(obj1.con));
/* 695 */     objectObjectHashMap.put("dex", Integer.valueOf(obj1.dex));
/* 696 */     objectObjectHashMap.put("phy_power", Integer.valueOf(obj1.phy_power));
/* 697 */     objectObjectHashMap.put("mag_power", Integer.valueOf(obj1.mag_power));
/* 698 */     objectObjectHashMap.put("speed", Integer.valueOf(obj1.speed));
/* 699 */     objectObjectHashMap.put("def", Integer.valueOf(obj1.def));
/* 700 */     objectObjectHashMap.put("intimacy", Integer.valueOf(obj1.intimacy));
/* 701 */     objectObjectHashMap.put("exp", Integer.valueOf(obj1.exp));
/* 702 */     objectObjectHashMap.put("resist_point", Integer.valueOf(obj1.resist_point));
/* 703 */     objectObjectHashMap.put("resist_metal", Integer.valueOf(obj1.resist_metal));
/* 704 */     objectObjectHashMap.put("resist_wood", Integer.valueOf(obj1.resist_wood));
/* 705 */     objectObjectHashMap.put("resist_water", Integer.valueOf(obj1.resist_water));
/* 706 */     objectObjectHashMap.put("resist_fire", Integer.valueOf(obj1.resist_fire));
/* 707 */     objectObjectHashMap.put("resist_earth", Integer.valueOf(obj1.resist_earth));
/* 708 */     objectObjectHashMap.put("resist_poison", Integer.valueOf(obj1.resist_poison));
/* 709 */     objectObjectHashMap.put("resist_frozen", Integer.valueOf(obj1.resist_frozen));
/* 710 */     objectObjectHashMap.put("resist_sleep", Integer.valueOf(obj1.resist_sleep));
/* 711 */     objectObjectHashMap.put("resist_forgotten", Integer.valueOf(obj1.resist_forgotten));
/* 712 */     objectObjectHashMap.put("resist_confusion", Integer.valueOf(obj1.resist_confusion));
/* 713 */     objectObjectHashMap.put("longevity", Integer.valueOf(obj1.longevity));
/* 714 */     objectObjectHashMap.put("shape", Integer.valueOf(obj1.shape));
/* 715 */     objectObjectHashMap.put("martial", Integer.valueOf(obj1.martial));
/* 716 */     objectObjectHashMap.put("mon_martial", Integer.valueOf(obj1.mon_martial));
/* 717 */     objectObjectHashMap.put("last_mon_martial", Integer.valueOf(obj1.last_mon_martial));
/* 718 */     objectObjectHashMap.put("loyalty", Integer.valueOf(obj1.loyalty));
/* 719 */     objectObjectHashMap.put("exp_to_next_level", Integer.valueOf(obj1.exp_to_next_level));
/* 720 */     objectObjectHashMap.put("portrait", Integer.valueOf(obj1.portrait));
/* 721 */     objectObjectHashMap.put("pet_life_shape", Integer.valueOf(obj1.pet_life_shape));
/* 722 */     objectObjectHashMap.put("pet_mana_shape", Integer.valueOf(obj1.pet_mana_shape));
/* 723 */     objectObjectHashMap.put("pet_speed_shape", Integer.valueOf(obj1.pet_speed_shape));
/* 724 */     objectObjectHashMap.put("pet_phy_shape", Integer.valueOf(obj1.pet_phy_shape));
/* 725 */     objectObjectHashMap.put("pet_mag_shape", Integer.valueOf(obj1.pet_mag_shape));
/* 726 */     objectObjectHashMap.put("locked", Integer.valueOf(obj1.locked));
/* 727 */     objectObjectHashMap.put("recognize_recognized", Integer.valueOf(obj1.recognize_recognized));
/* 728 */     objectObjectHashMap.put("pet_upgraded", Integer.valueOf(obj1.pet_upgraded));
/* 729 */     objectObjectHashMap.put("extra_life", Integer.valueOf(obj1.extra_life));
/* 730 */     objectObjectHashMap.put("extra_mana", Integer.valueOf(obj1.extra_mana));
/* 731 */     objectObjectHashMap.put("phy_rebuild_level", Integer.valueOf(obj1.phy_rebuild_level));
/* 732 */     objectObjectHashMap.put("mag_rebuild_level", Integer.valueOf(obj1.mag_rebuild_level));
/* 733 */     objectObjectHashMap.put("mount_type", Integer.valueOf(obj1.mount_type));
/* 734 */     objectObjectHashMap.put("phy_rebuild_rate", Integer.valueOf(obj1.phy_rebuild_rate));
/* 735 */     objectObjectHashMap.put("mag_rebuild_rate", Integer.valueOf(obj1.mag_rebuild_rate));
/* 736 */     objectObjectHashMap.put("phy_rebuild_add", Integer.valueOf(obj1.phy_rebuild_add));
/* 737 */     objectObjectHashMap.put("mag_rebuild_add", Integer.valueOf(obj1.mag_rebuild_add));
/* 738 */     objectObjectHashMap.put("pet_life_shape_temp", Integer.valueOf(obj1.pet_life_shape_temp));
/* 739 */     objectObjectHashMap.put("pet_mana_shape_temp", Integer.valueOf(obj1.pet_mana_shape_temp));
/* 740 */     objectObjectHashMap.put("pet_speed_shape_temp", Integer.valueOf(obj1.pet_speed_shape_temp));
/* 741 */     objectObjectHashMap.put("pet_phy_shape_temp", Integer.valueOf(obj1.pet_phy_shape_temp));
/* 742 */     objectObjectHashMap.put("pet_mag_shape_temp", Integer.valueOf(obj1.pet_mag_shape_temp));
/* 743 */     objectObjectHashMap.put("life_add_temp", Integer.valueOf(obj1.life_add_temp));
/* 744 */     objectObjectHashMap.put("mana_add_temp", Integer.valueOf(obj1.mana_add_temp));
/* 745 */     objectObjectHashMap.put("speed_add_temp", Integer.valueOf(obj1.speed_add_temp));
/* 746 */     objectObjectHashMap.put("phy_power_add_temp", Integer.valueOf(obj1.phy_power_add_temp));
/* 747 */     objectObjectHashMap.put("mag_power_add_temp", Integer.valueOf(obj1.mag_power_add_temp));
/* 748 */     objectObjectHashMap.put("lock_exp", Integer.valueOf(obj1.lock_exp));
/* 749 */     objectObjectHashMap.put("gift", Integer.valueOf(obj1.gift));
/* 750 */     objectObjectHashMap.put("req_level", Integer.valueOf(obj1.req_level));
/* 751 */     objectObjectHashMap.put("enchant", Integer.valueOf(obj1.enchant));
/* 752 */     objectObjectHashMap.put("enchant_nimbus", Integer.valueOf(obj1.enchant_nimbus));
/* 753 */     objectObjectHashMap.put("max_enchant_nimbus", Integer.valueOf(obj1.max_enchant_nimbus));
/* 754 */     objectObjectHashMap.put("eclosion", Integer.valueOf(obj1.eclosion));
/* 755 */     objectObjectHashMap.put("eclosion_nimbus", Integer.valueOf(obj1.eclosion_nimbus));
/* 756 */     objectObjectHashMap.put("max_eclosion_nimbus", Integer.valueOf(obj1.max_eclosion_nimbus));
/* 757 */     objectObjectHashMap.put("eclosion_stage", Integer.valueOf(obj1.eclosion_stage));
/* 758 */     objectObjectHashMap.put("evolve", obj1.evolve);
/* 759 */     objectObjectHashMap.put("life_effect", Integer.valueOf(obj1.life_effect));
/* 760 */     objectObjectHashMap.put("mana_effect", Integer.valueOf(obj1.mana_effect));
/* 761 */     objectObjectHashMap.put("speed_effect", Integer.valueOf(obj1.speed_effect));
/* 762 */     objectObjectHashMap.put("phy_effect", Integer.valueOf(obj1.phy_effect));
/* 763 */     objectObjectHashMap.put("mag_effect", Integer.valueOf(obj1.mag_effect));
/* 764 */     objectObjectHashMap.put("extra_life_effect", Integer.valueOf(obj1.extra_life_effect));
/* 765 */     objectObjectHashMap.put("extra_mana_effect", Integer.valueOf(obj1.extra_mana_effect));
/* 766 */     objectObjectHashMap.put("extra_mag_effect", Integer.valueOf(obj1.extra_mag_effect));
/* 767 */     objectObjectHashMap.put("extra_phy_effect", Integer.valueOf(obj1.extra_phy_effect));
/* 768 */     objectObjectHashMap.put("extra_speed_effect", Integer.valueOf(obj1.extra_speed_effect));
/* 769 */     objectObjectHashMap.put("morph_life_times", Integer.valueOf(obj1.morph_life_times));
/* 770 */     objectObjectHashMap.put("morph_mana_times", Integer.valueOf(obj1.morph_mana_times));
/* 771 */     objectObjectHashMap.put("morph_speed_times", Integer.valueOf(obj1.morph_speed_times));
/* 772 */     objectObjectHashMap.put("morph_phy_times", Integer.valueOf(obj1.morph_phy_times));
/* 773 */     objectObjectHashMap.put("morph_mag_times", Integer.valueOf(obj1.morph_mag_times));
/* 774 */     objectObjectHashMap.put("morph_life_stat", Integer.valueOf(obj1.morph_life_stat));
/* 775 */     objectObjectHashMap.put("morph_mana_stat", Integer.valueOf(obj1.morph_mana_stat));
/* 776 */     objectObjectHashMap.put("morph_speed_stat", Integer.valueOf(obj1.morph_speed_stat));
/* 777 */     objectObjectHashMap.put("morph_phy_stat", Integer.valueOf(obj1.morph_phy_stat));
/* 778 */     objectObjectHashMap.put("morph_mag_stat", Integer.valueOf(obj1.morph_mag_stat));
/* 779 */     objectObjectHashMap.put("mount_attrib_end_time", Integer.valueOf(obj1.mount_attrib_end_time));
/* 780 */     objectObjectHashMap.put("mount_attribmove_speed", Integer.valueOf(obj1.mount_attribmove_speed));
/* 781 */     objectObjectHashMap.put("capacity_level", Integer.valueOf(obj1.capacity_level));
/* 782 */     objectObjectHashMap.put("merge_rate", Integer.valueOf(obj1.merge_rate));
/* 783 */     objectObjectHashMap.put("hide_mount", Integer.valueOf(obj1.hide_mount));
/* 784 */     objectObjectHashMap.put("deadline", Integer.valueOf(obj1.deadline));
/* 785 */     objectObjectHashMap.put("dunwu_times", Integer.valueOf(obj1.dunwu_times));
/* 786 */     objectObjectHashMap.put("dunwu_rate", Integer.valueOf(obj1.dunwu_rate));
/* 787 */     objectObjectHashMap.put("pet_anger", Integer.valueOf(obj1.pet_anger));
/* 788 */     objectObjectHashMap.put("gm_attribsmax_mana", Integer.valueOf(obj1.gm_attribsmax_mana));
/* 789 */     objectObjectHashMap.put("gm_attribsphy_power", Integer.valueOf(obj1.gm_attribsphy_power));
/* 790 */     objectObjectHashMap.put("gm_attribsmag_power", Integer.valueOf(obj1.gm_attribsmag_power));
/* 791 */     objectObjectHashMap.put("gm_attribsdef", Integer.valueOf(obj1.gm_attribsdef));
/* 792 */     objectObjectHashMap.put("gm_attribsspeed", Integer.valueOf(obj1.gm_attribsspeed));
/* 793 */     objectObjectHashMap.put("marriage_couple_gid", Integer.valueOf(obj1.marriage_couple_gid));
/* 794 */     objectObjectHashMap.put("has_upgraded", Integer.valueOf(obj1.has_upgraded));
/* 795 */     objectObjectHashMap.put("phy_power_without_intimacy", Integer.valueOf(obj1.phy_power_without_intimacy));
/* 796 */     objectObjectHashMap.put("mag_power_without_intimacy", Integer.valueOf(obj1.mag_power_without_intimacy));
/* 797 */     objectObjectHashMap.put("def_without_intimacy", Integer.valueOf(obj1.def_without_intimacy));
/* 798 */     objectObjectHashMap.put("origin_intimacy", Integer.valueOf(obj1.origin_intimacy));
/* 799 */     objectObjectHashMap.put("dye_icon", Integer.valueOf(obj1.dye_icon));
/* 800 */     objectObjectHashMap.put("fasion_id", Integer.valueOf(obj1.fasion_id));
/* 801 */     objectObjectHashMap.put("iid_str", obj1.iid_str);
/* 802 */     objectObjectHashMap.put("raw_name", obj1.raw_name);
/* 803 */     objectObjectHashMap.put("all_attrib", Integer.valueOf(obj1.all_attrib));
/* 804 */     objectObjectHashMap.put("upgrade_immortal", Integer.valueOf(obj1.upgrade_immortal));
/* 805 */     objectObjectHashMap.put("upgrade_magic", Integer.valueOf(obj1.upgrade_magic));
/* 806 */     objectObjectHashMap.put("nimbus", Integer.valueOf(obj1.nimbus));
/* 807 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> ShouHu(Object obj)
/*     */   {
/* 813 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 814 */     ShouHu obj1 = (ShouHu)obj;
/* 815 */     objectObjectHashMap.put("id", Integer.valueOf(obj1.id));
/* 816 */     objectObjectHashMap.put("listShouHuShuXing", obj1.listShouHuShuXing);
/* 817 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> ShouHuShuXing(ShouHuShuXing obj1)
/*     */   {
/* 823 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 825 */     objectObjectHashMap.put("no", Integer.valueOf(obj1.no));
/* 826 */     objectObjectHashMap.put("type1", Integer.valueOf(obj1.type1));
/* 827 */     objectObjectHashMap.put("str", obj1.str);
/* 828 */     objectObjectHashMap.put("wood", Integer.valueOf(obj1.wood));
/* 829 */     objectObjectHashMap.put("water", Integer.valueOf(obj1.water));
/* 830 */     objectObjectHashMap.put("fire", Integer.valueOf(obj1.fire));
/* 831 */     objectObjectHashMap.put("earth", Integer.valueOf(obj1.earth));
/* 832 */     objectObjectHashMap.put("resist_metal", Integer.valueOf(obj1.resist_metal));
/* 833 */     objectObjectHashMap.put("skill", Integer.valueOf(obj1.skill));
/* 834 */     objectObjectHashMap.put("type", Integer.valueOf(obj1.type));
/* 835 */     objectObjectHashMap.put("shape", Integer.valueOf(obj1.shape));
/* 836 */     objectObjectHashMap.put("nil", Integer.valueOf(obj1.nil));
/* 837 */     objectObjectHashMap.put("penetrate", Integer.valueOf(obj1.penetrate));
/* 838 */     objectObjectHashMap.put("metal", Integer.valueOf(obj1.metal));
/* 839 */     objectObjectHashMap.put("max_degree", Integer.valueOf(obj1.max_degree));
/* 840 */     objectObjectHashMap.put("color", Integer.valueOf(obj1.color));
/* 841 */     objectObjectHashMap.put("exp", Integer.valueOf(obj1.exp));
/* 842 */     objectObjectHashMap.put("store_exp", Integer.valueOf(obj1.store_exp));
/* 843 */     objectObjectHashMap.put("salary", Integer.valueOf(obj1.salary));
/* 844 */     objectObjectHashMap.put("mag_power", Integer.valueOf(obj1.mag_power));
/* 845 */     objectObjectHashMap.put("mana", Integer.valueOf(obj1.mana));
/* 846 */     objectObjectHashMap.put("phy_power", Integer.valueOf(obj1.phy_power));
/* 847 */     objectObjectHashMap.put("accurate", Integer.valueOf(obj1.accurate));
/* 848 */     objectObjectHashMap.put("suit_polar", obj1.suit_polar);
/* 849 */     objectObjectHashMap.put("life", Integer.valueOf(obj1.life));
/* 850 */     objectObjectHashMap.put("parry", Integer.valueOf(obj1.parry));
/* 851 */     objectObjectHashMap.put("def", Integer.valueOf(obj1.def));
/* 852 */     objectObjectHashMap.put("wiz", Integer.valueOf(obj1.wiz));
/* 853 */     objectObjectHashMap.put("max_life", Integer.valueOf(obj1.max_life));
/* 854 */     objectObjectHashMap.put("speed", Integer.valueOf(obj1.speed));
/* 855 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> ShuXingUtil(Object obj)
/*     */   {
/* 861 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 862 */     ShuXingUtil obj1 = (ShuXingUtil)obj;
/* 863 */     return objectObjectHashMap;
/*     */   }
/*     */   
/*     */ 
/*     */   public static Map<Object, Object> ZbAttribute(ZbAttribute obj1)
/*     */   {
/* 869 */     HashMap<Object, Object> objectObjectHashMap = new HashMap();
/* 871 */     objectObjectHashMap.put("id", Integer.valueOf(obj1.id));
/* 872 */     objectObjectHashMap.put("phy_power", Integer.valueOf(obj1.phy_power));
/* 873 */     objectObjectHashMap.put("mag_power", Integer.valueOf(obj1.mag_power));
/* 874 */     objectObjectHashMap.put("speed", Integer.valueOf(obj1.speed));
/* 875 */     objectObjectHashMap.put("life", Integer.valueOf(obj1.life));
/* 876 */     objectObjectHashMap.put("skill_low_cost", Integer.valueOf(obj1.skill_low_cost));
/* 877 */     objectObjectHashMap.put("mstunt_rate", Integer.valueOf(obj1.mstunt_rate));
/* 878 */     objectObjectHashMap.put("wood", Integer.valueOf(obj1.wood));
/* 879 */     objectObjectHashMap.put("water", Integer.valueOf(obj1.water));
/* 880 */     objectObjectHashMap.put("fire", Integer.valueOf(obj1.fire));
/* 881 */     objectObjectHashMap.put("earth", Integer.valueOf(obj1.earth));
/* 882 */     objectObjectHashMap.put("resist_metal", Integer.valueOf(obj1.resist_metal));
/* 883 */     objectObjectHashMap.put("damage_sel", Integer.valueOf(obj1.damage_sel));
/* 884 */     objectObjectHashMap.put("stunt_rate", Integer.valueOf(obj1.stunt_rate));
/* 885 */     objectObjectHashMap.put("double_hit_rate", Integer.valueOf(obj1.double_hit_rate));
/* 886 */     objectObjectHashMap.put("release_forgotten", Integer.valueOf(obj1.release_forgotten));
/* 887 */     objectObjectHashMap.put("ignore_all_resist_except", Integer.valueOf(obj1.ignore_all_resist_except));
/* 888 */     objectObjectHashMap.put("stunt", Integer.valueOf(obj1.stunt));
/* 889 */     objectObjectHashMap.put("def", Integer.valueOf(obj1.def));
/* 890 */     objectObjectHashMap.put("dex", Integer.valueOf(obj1.dex));
/* 891 */     objectObjectHashMap.put("wiz", Integer.valueOf(obj1.wiz));
/* 892 */     objectObjectHashMap.put("family", Integer.valueOf(obj1.family));
/* 893 */     objectObjectHashMap.put("life_recover", Integer.valueOf(obj1.life_recover));
/* 894 */     objectObjectHashMap.put("all_skill", Integer.valueOf(obj1.all_skill));
/* 895 */     objectObjectHashMap.put("portrait", Integer.valueOf(obj1.portrait));
/* 896 */     objectObjectHashMap.put("resist_frozen", Integer.valueOf(obj1.resist_frozen));
/* 897 */     objectObjectHashMap.put("resist_sleep", Integer.valueOf(obj1.resist_sleep));
/* 898 */     objectObjectHashMap.put("resist_forgotten", Integer.valueOf(obj1.resist_forgotten));
/* 899 */     objectObjectHashMap.put("resist_confusion", Integer.valueOf(obj1.resist_confusion));
/* 900 */     objectObjectHashMap.put("longevity", Integer.valueOf(obj1.longevity));
/* 901 */     objectObjectHashMap.put("resist_wood", Integer.valueOf(obj1.resist_wood));
/* 902 */     objectObjectHashMap.put("resist_water", Integer.valueOf(obj1.resist_water));
/* 903 */     objectObjectHashMap.put("resist_fire", Integer.valueOf(obj1.resist_fire));
/* 904 */     objectObjectHashMap.put("resist_earth", Integer.valueOf(obj1.resist_earth));
/* 905 */     objectObjectHashMap.put("exp_to_next_level", Integer.valueOf(obj1.exp_to_next_level));
/* 906 */     objectObjectHashMap.put("all_resist_except", Integer.valueOf(obj1.all_resist_except));
/* 907 */     objectObjectHashMap.put("accurate", Integer.valueOf(obj1.accurate));
/* 908 */     objectObjectHashMap.put("mana", Integer.valueOf(obj1.mana));
/* 909 */     objectObjectHashMap.put("parry", Integer.valueOf(obj1.parry));
/* 910 */     objectObjectHashMap.put("super_excluse_wood", Integer.valueOf(obj1.super_excluse_wood));
/* 911 */     objectObjectHashMap.put("super_excluse_water", Integer.valueOf(obj1.super_excluse_water));
/* 912 */     objectObjectHashMap.put("super_excluse_fire", Integer.valueOf(obj1.super_excluse_fire));
/* 913 */     objectObjectHashMap.put("super_excluse_earth", Integer.valueOf(obj1.super_excluse_earth));
/* 914 */     objectObjectHashMap.put("B_skill_low_cost", Integer.valueOf(obj1.B_skill_low_cost));
/* 915 */     objectObjectHashMap.put("enhanced_wood", Integer.valueOf(obj1.enhanced_wood));
/* 916 */     objectObjectHashMap.put("enhanced_water", Integer.valueOf(obj1.enhanced_water));
/* 917 */     objectObjectHashMap.put("enhanced_fire", Integer.valueOf(obj1.enhanced_fire));
/* 918 */     objectObjectHashMap.put("enhanced_earth", Integer.valueOf(obj1.enhanced_earth));
/* 919 */     objectObjectHashMap.put("mag_dodge", Integer.valueOf(obj1.mag_dodge));
/* 920 */     objectObjectHashMap.put("ignore_mag_dodge", Integer.valueOf(obj1.ignore_mag_dodge));
/* 921 */     objectObjectHashMap.put("jinguang_zhaxian_counter_att_rate", Integer.valueOf(obj1.jinguang_zhaxian_counter_att_rate));
/* 922 */     objectObjectHashMap.put("C_skill_low_cost", Integer.valueOf(obj1.C_skill_low_cost));
/* 923 */     objectObjectHashMap.put("D_skill_low_cost", Integer.valueOf(obj1.D_skill_low_cost));
/* 924 */     objectObjectHashMap.put("super_poison", Integer.valueOf(obj1.super_poison));
/* 925 */     objectObjectHashMap.put("ignore_resist_wood", Integer.valueOf(obj1.ignore_resist_wood));
/* 926 */     objectObjectHashMap.put("ignore_resist_water", Integer.valueOf(obj1.ignore_resist_water));
/* 927 */     objectObjectHashMap.put("ignore_resist_fire", Integer.valueOf(obj1.ignore_resist_fire));
/* 928 */     objectObjectHashMap.put("ignore_resist_earth", Integer.valueOf(obj1.ignore_resist_earth));
/* 929 */     objectObjectHashMap.put("ignore_resist_forgotten", Integer.valueOf(obj1.ignore_resist_forgotten));
/* 930 */     objectObjectHashMap.put("super_confusion", Integer.valueOf(obj1.super_confusion));
/* 931 */     objectObjectHashMap.put("super_sleep", Integer.valueOf(obj1.super_sleep));
/* 932 */     objectObjectHashMap.put("enhanced_metal", Integer.valueOf(obj1.enhanced_metal));
/* 933 */     objectObjectHashMap.put("super_forgotten", Integer.valueOf(obj1.super_forgotten));
/* 934 */     objectObjectHashMap.put("super_frozen", Integer.valueOf(obj1.super_frozen));
/* 935 */     objectObjectHashMap.put("ignore_resist_frozen", Integer.valueOf(obj1.ignore_resist_frozen));
/* 936 */     objectObjectHashMap.put("ignore_resist_sleep", Integer.valueOf(obj1.ignore_resist_sleep));
/* 937 */     objectObjectHashMap.put("ignore_resist_confusion", Integer.valueOf(obj1.ignore_resist_confusion));
/* 938 */     objectObjectHashMap.put("super_excluse_metal", Integer.valueOf(obj1.super_excluse_metal));
/* 939 */     objectObjectHashMap.put("ignore_resist_poison", Integer.valueOf(obj1.ignore_resist_poison));
/* 940 */     objectObjectHashMap.put("tao_ex", Integer.valueOf(obj1.tao_ex));
/* 941 */     objectObjectHashMap.put("release_confusion", Integer.valueOf(obj1.release_confusion));
/* 942 */     objectObjectHashMap.put("release_sleep", Integer.valueOf(obj1.release_sleep));
/* 943 */     objectObjectHashMap.put("release_frozen", Integer.valueOf(obj1.release_frozen));
/* 944 */     objectObjectHashMap.put("release_poison", Integer.valueOf(obj1.release_poison));
/* 945 */     return objectObjectHashMap;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\UtilObjMapshuxing.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */