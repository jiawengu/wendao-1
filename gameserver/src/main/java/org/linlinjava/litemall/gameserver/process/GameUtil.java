/*      */ package org.linlinjava.litemall.gameserver.process;
/*      */
/*      */

import com.google.common.base.Preconditions;
import org.linlinjava.litemall.db.domain.Map;
import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.db.domain.ZhuangbeiInfo;
import org.linlinjava.litemall.gameserver.data.vo.*;
import org.linlinjava.litemall.gameserver.data.write.*;
import org.linlinjava.litemall.gameserver.domain.*;
import org.linlinjava.litemall.gameserver.game.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/*      */ @org.springframework.stereotype.Service
/*      */ public class GameUtil
        /*      */ {
            private static final String[] TTT_XINGJUN = new String[]{"天玑星君", "天璇星君", "天枢星君", "摇光星君", "开阳星君", "天权星君", "玉衡星君"};
    public static final String[] TONG_TIAN_TA_PET = new String[]{"疆良", "玄武", "朱雀", "东山神灵"};
    /*      */   public static void addshouhu(Chara chara)
    /*      */   {
        /*   30 */     for (int i = 0; i < chara.listshouhu.size(); i++)
            /*      */     {
            /*   32 */       org.linlinjava.litemall.gameserver.domain.ShouHu shouHu = (org.linlinjava.litemall.gameserver.domain.ShouHu)chara.listshouhu.get(i);
            /*   33 */       org.linlinjava.litemall.gameserver.domain.ShouHuShuXing shouHuShuXing = (org.linlinjava.litemall.gameserver.domain.ShouHuShuXing)((org.linlinjava.litemall.gameserver.domain.ShouHu)chara.listshouhu.get(i)).listShouHuShuXing.get(0);
            /*   34 */       java.util.Hashtable<String, int[]> stringHashtable = org.linlinjava.litemall.gameserver.data.game.PetAttributesUtils.helpPet(shouHuShuXing.penetrate, shouHuShuXing.metal, chara.level);
            /*   35 */       int[] attributes = (int[])stringHashtable.get("attribute");
            /*   36 */       int[] polars = (int[])stringHashtable.get("polars");
            /*   37 */       org.linlinjava.litemall.gameserver.data.vo.Vo_45128_0 vo_45128_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45128_0();
            /*   38 */       shouHuShuXing.life = attributes[0];
            /*   39 */       shouHuShuXing.mag_power = attributes[1];
            /*   40 */       shouHuShuXing.phy_power = attributes[2];
            /*   41 */       shouHuShuXing.speed = attributes[3];
            /*   42 */       shouHuShuXing.wood = polars[0];
            /*   43 */       shouHuShuXing.water = polars[1];
            /*   44 */       shouHuShuXing.fire = polars[2];
            /*   45 */       shouHuShuXing.earth = polars[3];
            /*   46 */       shouHuShuXing.resist_metal = polars[4];
            /*   47 */       shouHuShuXing.skill = chara.level;
            /*   48 */       shouHuShuXing.shape = 0;
            /*      */
            /*   50 */       int[] ints = org.linlinjava.litemall.gameserver.data.game.BasicAttributesUtils.calculationHelpAttributes(chara.level, attributes[0], attributes[1], attributes[2], attributes[3], polars[0], polars[1], polars[2], polars[3], polars[4], shouHuShuXing.metal);
            /*   51 */       shouHuShuXing.max_life = ints[0];
            /*   52 */       shouHuShuXing.def = ints[0];
            /*   53 */       shouHuShuXing.accurate = ints[2];
            /*   54 */       shouHuShuXing.mana = ints[3];
            /*   55 */       shouHuShuXing.parry = ints[4];
            /*   56 */       shouHuShuXing.wiz = ints[5];
            /*   57 */       shouHuShuXing.salary = 0;
            /*   58 */       List list = new ArrayList();
            /*   59 */       list.add(shouHu);
            /*   60 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M12016_0(), list);
            /*   61 */       dujineng(2, shouHuShuXing.metal, shouHuShuXing.skill, true, shouHu.id, chara);
            /*      */     }
        /*      */   }
    /*      */
    /*      */
    /*      */
    /*      */   public static void addfabaojingyan(Chara chara1, int jingyan)
    /*      */   {
        /*   69 */     Boolean has = fabaojingyan(chara1, jingyan);
        /*   70 */     if (has.booleanValue()) {
            /*   71 */       org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0 vo_20481_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0();
            /*   72 */       vo_20481_0.msg = ("你的法宝获得了#R" + jingyan + "#n经验");
            /*   73 */       vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
            /*   74 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
            /*      */     }
        /*      */   }
    /*      */
    /*      */
    /*      */   public static Boolean fabaojingyan(Chara chara1, int jingyan)
    /*      */   {
        /*   81 */     Boolean has = Boolean.valueOf(false);
        /*   82 */     for (int i = 0; i < chara1.backpack.size(); i++) {
            /*   83 */       if (((Goods)chara1.backpack.get(i)).pos == 9) {
                /*   84 */         if (((Goods)chara1.backpack.get(i)).goodsInfo.skill >= 24) {
                    /*   85 */           return has;
                    /*      */         }
                /*   87 */         ListVo_65527_0 listVo_65527_0 = a65527(chara1);
                /*   88 */         GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
                /*   89 */         ((Goods)chara1.backpack.get(i)).goodsInfo.pot += jingyan;
                /*   90 */         List<Goods> list = new ArrayList();
                /*   91 */         list.add(chara1.backpack.get(i));
                /*   92 */         GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_INVENTORY(), list);
                /*   93 */         if (((Goods)chara1.backpack.get(i)).goodsInfo.pot >= ((Goods)chara1.backpack.get(i)).goodsInfo.resist_poison) {
                    /*   94 */           ((Goods)chara1.backpack.get(i)).goodsInfo.skill += 1;
                    /*   95 */           ((Goods)chara1.backpack.get(i)).goodsInfo.pot = 0;
                    /*   96 */           jingyan -= ((Goods)chara1.backpack.get(i)).goodsInfo.resist_poison;
                    /*   97 */           ((Goods)chara1.backpack.get(i)).goodsInfo.resist_poison = GameData.that.baseExperienceTreasureService.findOneByAttrib(Integer.valueOf(((Goods)chara1.backpack.get(i)).goodsInfo.skill)).getMaxLevel().intValue();
                    /*      */
                    /*   99 */           fabaojingyan(chara1, jingyan);
                    /*      */         }
                /*  101 */         has = Boolean.valueOf(true);
                /*  102 */         break;
                /*      */       }
            /*      */     }
        /*  105 */     return has;
        /*      */   }
    /*      */
    /*      */   public static Goods beibaowupin(Chara chara, int pos)
    /*      */   {
        /*  110 */     for (int i = 0; i < chara.backpack.size(); i++) {
            /*  111 */       if (((Goods)chara.backpack.get(i)).pos == pos) {
                /*  112 */         return (Goods)chara.backpack.get(i);
                /*      */       }
            /*      */     }
        /*  115 */     return null;
        /*      */   }
    /*      */
    /*      */   public static boolean belongCalendar()
    /*      */   {
        /*  120 */     java.util.Date nowTime = null;
        /*  121 */     java.util.Date beginTime = null;
        /*  122 */     java.util.Date endTime = null;
        /*  123 */     java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("mm");
        /*      */     try {
            /*  125 */       nowTime = df.parse(df.format(new java.util.Date()));
            /*  126 */       beginTime = df.parse("29");
            /*  127 */       endTime = df.parse("40");
            /*      */     } catch (java.text.ParseException e) {
            /*  129 */       e.printStackTrace();
            /*      */     }
        /*      */
        /*  132 */     java.util.Calendar date = java.util.Calendar.getInstance();
        /*  133 */     date.setTime(nowTime);
        /*      */
        /*  135 */     java.util.Calendar begin = java.util.Calendar.getInstance();
        /*  136 */     begin.setTime(beginTime);
        /*      */
        /*  138 */     java.util.Calendar end = java.util.Calendar.getInstance();
        /*  139 */     end.setTime(endTime);
        /*      */
        /*  141 */     if ((date.after(begin)) && (date.before(end))) {
            /*  142 */       return true;
            /*      */     }
        /*  144 */     return false;
        /*      */   }
    /*      */
    /*      */
    /*      */
    /*      */   public static void nextshaxing(Chara chara1, Chara duiyuan, int level, String replace)
    /*      */   {
        /*  151 */     Random random = new Random();
        /*      */
        /*  153 */     if (replace.equals("天星")) {
            /*  154 */       int cash = 1231 * level;
            /*  155 */       duiyuan.cash += cash;
            /*  156 */       int i = Math.abs(duiyuan.level - level) / 5;
            /*  157 */       if (i == 0) {
                /*  158 */         i = 1;
                /*      */       }
            /*  160 */       int jingyan = 2597 * level / i;
            /*  161 */       int i1 = random.nextInt(100);
            /*  162 */       jingyan = (int)(jingyan * (1000 - i1) * 0.001D);
            /*  163 */       if (jingyan < 1) {
                /*  164 */         jingyan = 1;
                /*      */       }
            /*  166 */       jingyan = shuangbei(chara1, jingyan);
            /*  167 */       if (duiyuan.level - level > 29) {
                /*  168 */         jingyan = 1;
                /*      */       }
            /*  170 */       huodejingyan(duiyuan, jingyan);
            /*  171 */       ListVo_65527_0 localListVo_65527_01 = a65527(duiyuan);
            /*      */     }
        /*  173 */     if (replace.equals("地星")) {
            /*  174 */       int i = Math.abs(duiyuan.level - level) / 5;
            /*  175 */       if (i == 0) {
                /*  176 */         i = 1;
                /*      */       }
            /*  178 */       int jingyan = 1298 * level / i;
            /*  179 */       int i1 = random.nextInt(100);
            /*  180 */       jingyan = (int)(jingyan * (1000 - i1) * 0.001D);
            /*  181 */       if (jingyan < 1) {
                /*  182 */         jingyan = 1;
                /*      */       }
            /*  184 */       jingyan = shuangbei(chara1, jingyan);
            /*  185 */       if (duiyuan.level - level > 29) {
                /*  186 */         jingyan = 1;
                /*      */       }
            /*  188 */       huodejingyan(duiyuan, jingyan);
            /*  189 */       ListVo_65527_0 listVo_65527_0 = a65527(duiyuan);
            /*      */
            /*  191 */       int base_dh = (int)(0.29D * duiyuan.level * duiyuan.level * duiyuan.level);
            /*  192 */       int owner_name = 3272 * level / i / (duiyuan.friend > base_dh ? duiyuan.friend / base_dh : 1);
            /*  193 */       adddaohang(duiyuan, owner_name);
            /*  194 */       for (int j = 0; j < duiyuan.pets.size(); j++) {
                /*  195 */         if (((Petbeibao)duiyuan.pets.get(j)).id == duiyuan.chongwuchanzhanId) {
                    /*  196 */           PetShuXing petShuXing = (PetShuXing)((Petbeibao)duiyuan.pets.get(j)).petShuXing.get(0);
                    /*  197 */           int base_pet_dh = (int)(0.29D * petShuXing.skill * petShuXing.skill * petShuXing.skill);
                    /*  198 */           int intimacy = 33 * level / (petShuXing.intimacy > base_pet_dh ? petShuXing.intimacy / base_pet_dh : 1);
                    /*  199 */           petShuXing.intimacy += intimacy;
                    /*  200 */           org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0 vo_20481_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0();
                    /*  201 */           vo_20481_0.msg = ("宠物获得武学#R" + intimacy);
                    /*  202 */           vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
                    /*  203 */           GameObjectCharMng.getGameObjectChar(duiyuan.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    /*      */         }
                /*  205 */         listVo_65527_0 = a65527(duiyuan);
                /*  206 */         GameObjectCharMng.getGameObjectChar(duiyuan.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
                /*      */       }
            /*      */     }
        /*      */   }
    /*      */
    /*      */
    /*      */
    /*      */
    /*      */   public static void shuayeguai(Chara chara1, Chara duiyuan, int level)
    /*      */   {
        /*  216 */     Random random = new Random();
        /*      */
        /*  218 */     int i = Math.abs(duiyuan.level - level) / 5;
        /*  219 */     if (i == 0) {
            /*  220 */       i = 1;
            /*      */     }
        /*  222 */     int jingyan = 20 * level / i;
        /*  223 */     int i1 = random.nextInt(100);
        /*  224 */     jingyan = (int)(jingyan * (1000 - i1) * 0.001D);
        /*  225 */     if (jingyan < 1) {
            /*  226 */       jingyan = 1;
            /*      */     }
        /*      */
        /*  229 */     jingyan = shuangbei(chara1, jingyan);
        /*      */
        /*  231 */     huodejingyan(duiyuan, jingyan);
        /*  232 */     ListVo_65527_0 listVo_65527_0 = a65527(duiyuan);
        /*  233 */     GameObjectCharMng.getGameObjectChar(duiyuan.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
        /*  234 */     i = random.nextInt(1000);
        /*  235 */     if ((i < 5) && (level >= 60)) {
            /*  236 */       weijianding(duiyuan);
            /*      */     }
        /*      */   }
    /*      */
    /*      */
    /*      */
    /*      */
    /*      */   public static void shidaojingyan(Chara chara1, Chara duiyuan, int id)
    /*      */   {
        /*  245 */     Random random = new Random();
        /*      */
        /*      */
        /*  248 */     GameObjectChar.getGameObjectChar().gameMap.send(new org.linlinjava.litemall.gameserver.data.write.M12285_1(), Integer.valueOf(id));
        /*  249 */     duiyuan.shidaodaguaijifen += 2;
        /*      */
        /*      */
        /*  252 */     int base_dh = (int)(0.29D * duiyuan.level * duiyuan.level * duiyuan.level);
        /*  253 */     int owner_name = 3272 * duiyuan.level / (duiyuan.friend > base_dh ? duiyuan.friend / base_dh : 1);
        /*  254 */     adddaohang(duiyuan, owner_name);
        /*      */
        /*      */
        /*  257 */     int jingyan = duiyuan.level * 1281;
        /*  258 */     if (jingyan < 1) {
            /*  259 */       jingyan = 1;
            /*      */     }
        /*  261 */     jingyan = shuangbei(chara1, jingyan);
        /*  262 */     huodejingyan(duiyuan, jingyan);
        /*      */
        /*  264 */     for (int i = 0; i < duiyuan.pets.size(); i++) {
            /*  265 */       if (((Petbeibao)duiyuan.pets.get(i)).id == duiyuan.chongwuchanzhanId) {
                /*  266 */         PetShuXing petShuXing = (PetShuXing)((Petbeibao)duiyuan.pets.get(i)).petShuXing.get(0);
                /*  267 */         int base_pet_dh = (int)(0.29D * petShuXing.skill * petShuXing.skill * petShuXing.skill);
                /*  268 */         int intimacy = 33 * petShuXing.skill / (petShuXing.intimacy > base_pet_dh ? petShuXing.intimacy / base_pet_dh : 1);
                /*  269 */         petShuXing.intimacy += intimacy;
                /*  270 */         org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0 vo_20481_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0();
                /*  271 */         vo_20481_0.msg = ("宠物获得武学#R" + intimacy);
                /*  272 */         vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
                /*  273 */         GameObjectCharMng.getGameObjectChar(duiyuan.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*      */       }
            /*  275 */       ListVo_65527_0 listVo_65527_0 = a65527(duiyuan);
            /*  276 */       GameObjectCharMng.getGameObjectChar(duiyuan.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
            /*      */     }
        /*      */   }
    /*      */
    /*      */   public static void nextxuanshang(Chara chara1, Chara duiyuan)
    /*      */   {
        /*  282 */     Random random = new Random();
        /*      */
        /*  284 */     duiyuan.xuanshangcishu += 1;
        /*      */
        /*  286 */     GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M12285_1(), Integer.valueOf(((org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0)chara1.npcxuanshang.get(0)).id), chara1.id);
        /*      */
        /*      */
        /*  289 */     int base_dh = (int)(0.29D * duiyuan.level * duiyuan.level * duiyuan.level);
        /*  290 */     int owner_name = 878 * duiyuan.level / (duiyuan.friend > base_dh ? duiyuan.friend / base_dh : 1);
        /*  291 */     adddaohang(duiyuan, owner_name);
        /*  292 */     int cash = 18936 * duiyuan.level;
        /*  293 */     duiyuan.cash += cash;
        /*  294 */     for (int i = 0; i < duiyuan.pets.size(); i++) {
            /*  295 */       if (((Petbeibao)duiyuan.pets.get(i)).id == duiyuan.chongwuchanzhanId) {
                /*  296 */         PetShuXing petShuXing = (PetShuXing)((Petbeibao)duiyuan.pets.get(i)).petShuXing.get(0);
                /*  297 */         int base_pet_dh = (int)(0.29D * petShuXing.skill * petShuXing.skill * petShuXing.skill);
                /*  298 */         int intimacy = 29 * petShuXing.skill / (petShuXing.intimacy > base_pet_dh ? petShuXing.intimacy / base_pet_dh : 1);
                /*  299 */         petShuXing.intimacy += intimacy;
                /*  300 */         org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0 vo_20481_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0();
                /*  301 */         vo_20481_0.msg = ("宠物获得武学#R" + intimacy);
                /*  302 */         vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
                /*  303 */         GameObjectCharMng.getGameObjectChar(duiyuan.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*      */       }
            /*  305 */       ListVo_65527_0 listVo_65527_0 = a65527(duiyuan);
            /*  306 */       GameObjectCharMng.getGameObjectChar(duiyuan.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
            /*      */     }
        /*  308 */     GameUtilRenWu.renwukuangkuang("悬赏祍务", "", "", duiyuan);
        /*      */
        /*      */
        /*  311 */     chara1.npcXuanShangName = "领取奖励";
        /*  312 */     chara1.npcxuanshang = new ArrayList();
        /*      */   }
    /*      */
    /*      */
    /*      */   public static boolean duiwudengji(Chara chara, GameObjectChar session)
    /*      */   {
        /*  318 */     boolean hasyes = true;
        /*  319 */     for (int i = 0; i < session.gameTeam.duiwu.size() - 1; i++) {
            /*  320 */       if (Math.abs(((Chara)session.gameTeam.duiwu.get(i)).level - ((Chara)session.gameTeam.duiwu.get(i + 1)).level) > 10) {
                /*  321 */         hasyes = false;
                /*      */       }
            /*      */     }
        /*  324 */     return hasyes;
        /*      */   }
    /*      */
    /*      */   public static int duiwudengjicmp(Chara chara, GameObjectChar session, int nMinLv, int MaxLv) {
        /*  329 */     for (int i = 0; i < session.gameTeam.duiwu.size(); i++) {
            int lv = ((Chara)session.gameTeam.duiwu.get(i)).level;
            /*  330 */       if (lv < nMinLv) {
                return 1;
                /*      */       }
            else if (lv > MaxLv) {
                return 2;
            }
            /*      */     }
        /*  334 */     return 0;
        /*      */   }
    /*      */
    /*      */   public static void adddaohang(Chara chara, int daohangdian)
    /*      */   {
        /*  339 */     chara.owner_name += daohangdian;
        /*  340 */     chara.friend += chara.owner_name / 1440;
        /*  341 */     chara.owner_name %= 1440;
        /*      */
        /*  343 */     org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0 vo_20481_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0();
        /*  344 */     vo_20481_0.msg = ("获得道行#R" + daohangdian);
        /*  345 */     vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
        /*  346 */     GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
        /*      */   }
    /*      */
    /*      */   public static int shuangbei(Chara chara1, int jingyan) {
        /*  350 */     if ((chara1.charashuangbei == 1) && (chara1.enable_double_points > 0)) {
            /*  351 */       jingyan *= 2;
            /*  352 */       chara1.enable_double_points -= 4;
            /*      */     }
        /*  354 */     if (chara1.enable_double_points <= 0) {
            /*  355 */       chara1.enable_double_points = 0;
            /*      */     }
        /*  357 */     return jingyan;
        /*      */   }
    /*      */
    /*      */
    /*      */
    /*      */   public static void nextxiuxing(Chara chara1, Chara duiyuan)
    /*      */   {
        /*  364 */     Random random = new Random();
        /*      */
        /*  366 */     duiyuan.xiuxingcishu += 1;
        /*  367 */     int chubao = chara1.xiuxingcishu - 1;
        /*  368 */     if (duiyuan.xiuxingcishu <= 40) {
            /*  369 */       int use_money_type = (int)(duiyuan.level / 10 * 6815 * (1.0D + 0.2D * chubao));
            /*  370 */       duiyuan.use_money_type += use_money_type;
            /*  371 */       org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0 vo_20481_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0();
            /*  372 */       vo_20481_0.msg = ("获得代金券#R" + use_money_type);
            /*  373 */       vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
            /*  374 */       GameObjectCharMng.getGameObjectChar(duiyuan.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
            /*  375 */       int jingyan = (int)(1281 * duiyuan.level * (1.0D + 0.05D * chubao));
            /*      */
            /*  377 */       jingyan = shuangbei(chara1, jingyan);
            /*  378 */       huodejingyan(duiyuan, jingyan);
            /*  379 */       ListVo_65527_0 listVo_65527_0 = a65527(duiyuan);
            /*  380 */       GameObjectCharMng.getGameObjectChar(duiyuan.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
            /*  381 */       if ((duiyuan.xiuxingcishu == 20) || (duiyuan.xiuxingcishu == 40)) {
                /*  382 */         weijianding(duiyuan);
                /*      */       }
            /*      */     }
        /*      */
        /*      */
        /*  387 */     String[] npces = { "雷神", "花神", "炎神", "山神", "龙神" };
        /*  388 */     int i = random.nextInt(npces.length);
        /*  389 */     chara1.xiuxingNpcname = npces[i];
        /*  390 */     int cishu = chubao + 1;
        /*  391 */     String task_prompt = "";
        /*  392 */     String show_name = "";
        /*  393 */     task_prompt = "拜访#P" + npces[i] + "| M=【修行】请仙人赐教#P";
        /*  394 */     show_name = "【修炼】修行(" + cishu + "/40)";
        /*      */
        /*  396 */     if (chara1.xiuxingcishu > 40) {
            /*  397 */       task_prompt = "";
            /*  398 */       show_name = "";
            /*      */     }
        /*      */
        /*  401 */     GameUtilRenWu.renwukuangkuang("修炼", task_prompt, show_name, chara1);
        /*      */
        /*  403 */     org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0 vo_45063_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0();
        /*  404 */     vo_45063_0.task_name = task_prompt;
        /*  405 */     vo_45063_0.check_point = 147761859;
        /*  406 */     GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45063_0(), vo_45063_0, chara1.id);
        /*      */   }
/*      */   public static void nextzhengzhu(Chara chara1, Chara duiyuan)
/*      */   {
    /*  366 */     duiyuan.xiuxingcishu += 1;
    /*  367 */     int chubao = chara1.xiuxingcishu - 1;
    /*  368 */     if (duiyuan.xiuxingcishu <= 40) {
        /*  369 */       int use_money_type = (int)(duiyuan.level / 10 * 6815 * (1.0D + 0.2D * chubao));
        /*  370 */       duiyuan.use_money_type += use_money_type;
        /*  371 */       org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0 vo_20481_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0();
        /*  372 */       vo_20481_0.msg = ("获得代金券#R" + use_money_type);
        /*  373 */       vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
        /*  374 */       GameObjectCharMng.getGameObjectChar(duiyuan.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
        /*  375 */       int jingyan = (int)(1281 * duiyuan.level * (1.0D + 0.05D * chubao));
        /*      */
        /*  377 */       jingyan = shuangbei(chara1, jingyan);
        /*  378 */       huodejingyan(duiyuan, jingyan);
        /*  379 */       ListVo_65527_0 listVo_65527_0 = a65527(duiyuan);
        /*  380 */       GameObjectCharMng.getGameObjectChar(duiyuan.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
        /*  381 */       if ((duiyuan.xiuxingcishu == 20) || (duiyuan.xiuxingcishu == 40)) {
            /*  382 */         weijianding(duiyuan);
            /*      */       }
        /*      */ }

                   int i = (duiyuan.xiuxingcishu + 9) % 10;
    /*  387 */     String[] npces = {"金光阵主", "风吼阵主", "落魄阵主", "化血阵主", "红水阵主", "寒冰阵主", "烈焰阵主", "地烈阵主", "天阙阵主", "红砂阵主"};
    /*  390 */
                   chara1.xiuxingNpcname = npces[i];
    /*  391 */     String task_prompt = "";
    /*  392 */     String show_name = "";
    /*  393 */     task_prompt = "讨教#P" + npces[i] + "| M=【十绝阵】请仙人赐教#P";
    /*  394 */     show_name = "【十绝阵】讨教(" + (i + 1) + "/10)";
    /*      */
    /*  396 */     if (i == 0 || chara1.xiuxingcishu > 40) {
        /*  397 */       task_prompt = "";
        /*  398 */       show_name = "";
                         chara1.xiuxingNpcname = "";

    /*  458 */           org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0 vo_20481_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0();
    /*  459 */           vo_20481_0.msg = ("请重新找玉泉老人接取十绝阵任务！");
    /*  460 */           vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
    /*  461 */           GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
        /*      */     }
    /*      */
    /*  401 */     GameUtilRenWu.renwukuangkuang("十绝阵", task_prompt, show_name, chara1);
    /*      */
    /*  403 */     org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0 vo_45063_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0();
    /*  404 */     vo_45063_0.task_name = task_prompt;
    /*  405 */     vo_45063_0.check_point = 147761859;
    /*  406 */     GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45063_0(), vo_45063_0, chara1.id);
    /*      */   }

    /*      */   public static void nextshuadao(Chara chara1, Chara duiyuan)
    /*      */   {
        /*  414 */     Random random = new Random();
        /*  415 */     int chubao = (chara1.shuadao - 1) % 10;
        /*      */
        /*  417 */     duiyuan.shuadao += 1;
        /*  418 */     GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M12285_1(), Integer.valueOf(((org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0)chara1.npcshuadao.get(0)).id), chara1.id);
        /*      */
        /*      */
        /*  421 */     if (duiyuan.shuadao <= 400) {
            /*  422 */       double beishu = 1.0D;
            /*  423 */       if (((org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0)chara1.npcshuadao.get(0)).leixing == 3) {
                /*  424 */         beishu = 1.5D;
                /*      */       }
            /*  426 */       if (((org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0)chara1.npcshuadao.get(0)).leixing == 4) {
                /*  427 */         beishu = 3.0D;
                /*      */       }
            /*  429 */       int base_dh = (int)(0.29D * duiyuan.level * duiyuan.level * duiyuan.level);
            /*      */
            /*  431 */       int owner_name = (int)(39 * duiyuan.level * (1.0D + 0.2D * chubao) / (duiyuan.friend > base_dh ? duiyuan.friend / base_dh : 1) * beishu) * 15;
            /*  432 */       if ((duiyuan.ziqihongmeng == 1) && (duiyuan.extra_skill > 0)) {
                /*  433 */         owner_name = (int)(owner_name * 1.5D);
                /*  434 */         chara1.extra_skill -= 4;
                /*  435 */         if (chara1.extra_skill <= 0) {
                    /*  436 */           chara1.extra_skill = 0;
                    /*      */         }
                /*      */       }
            /*  439 */       adddaohang(duiyuan, owner_name);
            /*      */
            /*      */
            /*  442 */       addfabaojingyan(duiyuan, (int)(beishu * chara1.level * 3.0D));
            /*      */
            /*      */
            /*  445 */       for (int i = 0; i < duiyuan.pets.size(); i++) {
                /*  446 */         if (((Petbeibao)duiyuan.pets.get(i)).id == duiyuan.chongwuchanzhanId) {
                    /*  447 */           PetShuXing petShuXing = (PetShuXing)((Petbeibao)duiyuan.pets.get(i)).petShuXing.get(0);
                    /*  448 */           int base_pet_dh = (int)(0.29D * petShuXing.skill * petShuXing.skill * petShuXing.skill) + 1;
                    /*  449 */           int intimacy = (int)(22 * petShuXing.skill * (1.0D + 0.2D * chubao) / (petShuXing.intimacy > base_pet_dh ? petShuXing.intimacy / base_pet_dh : 1) * beishu);
                    /*  450 */           if ((duiyuan.chongfengsan == 1) && (duiyuan.shuadaochongfeng_san > 0)) {
                        /*  451 */             intimacy = (int)(intimacy * 1.5D);
                        /*  452 */             chara1.shuadaochongfeng_san -= 4;
                        /*  453 */             if (chara1.shuadaochongfeng_san <= 0) {
                            /*  454 */               chara1.shuadaochongfeng_san = 0;
                            /*      */             }
                        /*      */           }
                    /*  457 */           petShuXing.intimacy += intimacy;
                    /*  458 */           org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0 vo_20481_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0();
                    /*  459 */           vo_20481_0.msg = ("宠物获得武学#R" + intimacy);
                    /*  460 */           vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
                    /*  461 */           GameObjectCharMng.getGameObjectChar(duiyuan.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    /*      */         }
                /*      */       }
            /*  464 */       int use_money_type = (int)(159 * duiyuan.level * (1.0D + 0.2D * chubao) * beishu);
            /*  465 */       duiyuan.use_money_type += use_money_type;
            /*  466 */       org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0 vo_20481_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0();
            /*  467 */       vo_20481_0.msg = ("获得代金券#R" + use_money_type);
            /*  468 */       vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
            /*  469 */       GameObjectCharMng.getGameObjectChar(duiyuan.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
            /*  470 */       int cash = (int)((int)(673 * duiyuan.level * (1.0D + 0.2D * chubao)) * beishu);
            /*  471 */       duiyuan.cash += cash;
            Vo_20480_0 vo_20480_0 = new Vo_20480_0();
            vo_20480_0.msg = ("你获得了#R" + cash + "#n点" + "潜能");
            vo_20480_0.time = 1562593376;
            GameObjectChar.send(new M20480_0(), vo_20480_0, duiyuan.id);
            /*  472 */       ListVo_65527_0 listVo_65527_0 = a65527(duiyuan);
            /*  473 */       GameObjectCharMng.getGameObjectChar(duiyuan.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
            /*      */     }
        /*      */
        /*      */
        /*  477 */     int cishu = chubao + 1;
        /*  478 */     String task_prompt = "";
        /*  479 */     String show_name = "";
        /*  480 */     if (((org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0)chara1.npcshuadao.get(0)).leixing == 2) {
            /*  481 */       task_prompt = "找#P通灵道人|M=【降妖】降拿妖怪#P领取降妖任务";
            /*  482 */       show_name = "降妖(" + cishu + "/10)";
            /*      */     }
        /*      */
        /*  485 */     if (((org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0)chara1.npcshuadao.get(0)).leixing == 3) {
            /*  486 */       task_prompt = "找#P陆压真人|M=【伏魔】我这就去#P领取任务";
            /*  487 */       show_name = "伏魔(" + cishu + "/10)";
            /*      */     }
        /*      */
        /*      */
        /*  491 */     if (((org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0)chara1.npcshuadao.get(0)).leixing == 4) {
            /*  492 */       task_prompt = "找#P清微真人|M=【伏魔】我这就去#P领取任务";
            /*  493 */       show_name = "飞仙渡劫(" + cishu + "/10)";
            /*      */     }
        /*      */
        /*      */
        /*  497 */     GameUtilRenWu.renwukuangkuang("降妖", task_prompt, show_name, chara1);
        /*      */
        /*  499 */     org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0 vo_45063_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0();
        /*  500 */     vo_45063_0.task_name = task_prompt;
        /*  501 */     vo_45063_0.check_point = 147761859;
        /*  502 */     GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45063_0(), vo_45063_0, chara1.id);
        /*      */   }
    /*      */
    /*      */
    /*      */
    /*      */   public static void chubaorenwu(Chara chara1, Chara duiyuan)
    /*      */   {
        /*  509 */     Random random = new Random();
        /*  510 */     int chubao = (chara1.chubao - 1) % 10;
        /*      */
        /*  512 */     duiyuan.chubao += 1;
        /*  513 */     List<org.linlinjava.litemall.db.domain.RenwuMonster> all = GameData.that.baseRenwuMonsterService.findByType(Integer.valueOf(1));
        /*      */
        /*  515 */     int k = random.nextInt(all.size());
        /*  516 */     org.linlinjava.litemall.db.domain.RenwuMonster renwuMonster = (org.linlinjava.litemall.db.domain.RenwuMonster)all.get(k);
        /*  517 */     String name = renwuMonster.getName() + getRandomJianHan();
        /*  518 */     org.linlinjava.litemall.db.domain.Renwu tasks = GameData.that.baseRenwuService.findOneByCurrentTask(chara1.current_task);
        /*  519 */     org.linlinjava.litemall.db.domain.Map map = GameData.that.baseMapService.findOneByName(renwuMonster.getMapName());
        /*      */
        /*  521 */     GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M12285_1(), Integer.valueOf(((org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0)chara1.npcchubao.get(0)).id), chara1.id);
        /*      */
        /*      */
        /*  524 */     if (duiyuan.chubao < 21) {
            /*  525 */       int base_dh = (int)(0.29D * duiyuan.level * duiyuan.level * duiyuan.level);
            /*      */
            /*  527 */       int owner_name = (int)(39 * duiyuan.level * (1.0D + 0.2D * chubao) / (duiyuan.friend > base_dh ? duiyuan.friend / base_dh : 1));
            /*  528 */       adddaohang(duiyuan, owner_name);
            /*      */
            /*  530 */       for (int i = 0; i < duiyuan.pets.size(); i++) {
                /*  531 */         if (((Petbeibao)duiyuan.pets.get(i)).id == duiyuan.chongwuchanzhanId) {
                    /*  532 */           PetShuXing petShuXing = (PetShuXing)((Petbeibao)duiyuan.pets.get(i)).petShuXing.get(0);
                    /*  533 */           int base_pet_dh = (int)(0.29D * petShuXing.skill * petShuXing.skill * petShuXing.skill);
                    /*  534 */           int intimacy = (int)(13 * petShuXing.skill * (1.0D + 0.2D * chubao) / (petShuXing.intimacy > base_pet_dh ? petShuXing.intimacy / base_pet_dh : 1));
                    /*  535 */           petShuXing.intimacy += intimacy;
                    /*  536 */           org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0 vo_20481_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0();
                    /*  537 */           vo_20481_0.msg = ("宠物获得武学#R" + intimacy);
                    /*  538 */           vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
                    /*  539 */           GameObjectCharMng.getGameObjectChar(duiyuan.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    /*      */         }
                /*      */       }
            /*  542 */       int use_money_type = (int)(159 * duiyuan.level * (1.0D + 0.2D * chubao));
            /*  543 */       duiyuan.use_money_type += use_money_type;
            /*  544 */       org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0 vo_20481_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0();
            /*  545 */       vo_20481_0.msg = ("获得代金券#R" + use_money_type);
            /*  546 */       vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
            /*  547 */       GameObjectCharMng.getGameObjectChar(duiyuan.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
            /*  548 */       int cash = (int)(471 * duiyuan.level * (1.0D + 0.2D * chubao));
            /*  549 */       duiyuan.cash += cash;
            /*  550 */       int jingyan = (int)(546 * duiyuan.level * (1.0D + 0.2D * chubao));
            /*      */
            /*  552 */       jingyan = shuangbei(chara1, jingyan);
            /*  553 */       huodejingyan(duiyuan, jingyan);
            /*  554 */       ListVo_65527_0 listVo_65527_0 = a65527(duiyuan);
            /*  555 */       GameObjectCharMng.getGameObjectChar(duiyuan.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
            /*      */     }
        /*  557 */     chara1.npcchubao = new ArrayList();
        /*      */
        /*  559 */     org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0 vo_65529_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0();
        /*  560 */     vo_65529_0.mapid = map.getMapId().intValue();
        /*  561 */     vo_65529_0.id = getCard(chara1);
        /*  562 */     vo_65529_0.x = renwuMonster.getX().intValue();
        /*  563 */     vo_65529_0.y = renwuMonster.getY().intValue();
        /*  564 */     vo_65529_0.icon = renwuMonster.getIcon().intValue();
        /*  565 */     vo_65529_0.type = 2;
        /*  566 */     vo_65529_0.org_icon = renwuMonster.getIcon().intValue();
        /*  567 */     vo_65529_0.portrait = renwuMonster.getIcon().intValue();
        /*  568 */     vo_65529_0.name = name;
        /*  569 */     vo_65529_0.level = chara1.level;
        /*  570 */     chara1.npcchubao.add(vo_65529_0);
        /*  571 */     if (chara1.chubao == 21) {
            /*  572 */       String task_prompt = "";
            /*  573 */       String show_name = "";
            /*      */
            /*  575 */       GameUtilRenWu.renwukuangkuang("为民除暴", task_prompt, show_name, chara1);
            /*  576 */       return;
            /*      */     }
        /*      */
        /*  579 */     if (chara1.mapid == ((org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0)chara1.npcchubao.get(0)).mapid) {
            /*  580 */       GameObjectChar.sendduiwu(new MSG_APPEAR(), chara1.npcchubao.get(0), chara1.id);
            /*      */     }
        /*      */
        /*  583 */     String task_prompt = "捉拿#P" + name + "|" + renwuMonster.getMapName() + "(" + renwuMonster.getX() + "," + renwuMonster.getY() + ")|M=就是来抓你的|$0#P";
        /*  584 */     int cishu = chubao + 1;
        /*  585 */     String show_name = "为民除暴(" + cishu + "/10)";
        /*      */
        /*  587 */     GameUtilRenWu.renwukuangkuang("为民除暴", task_prompt, show_name, chara1);
        /*  588 */     org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0 vo_45063_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0();
        /*  589 */     vo_45063_0.task_name = task_prompt;
        /*  590 */     vo_45063_0.check_point = 147761859;
        /*  591 */     GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45063_0(), vo_45063_0, chara1.id);
        /*      */   }
    /*      */
    /*      */   public static void chenghaoxiaoxi(Chara chara)
    /*      */   {
        /*  596 */     List<org.linlinjava.litemall.gameserver.data.vo.Vo_62209_0> list = new java.util.LinkedList();
        /*  597 */     org.linlinjava.litemall.gameserver.data.vo.Vo_62209_0 vo_62209_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_62209_0();
        /*  598 */     vo_62209_0.stringformat = "无显示";
        /*  599 */     vo_62209_0.title = "";
        /*  600 */     vo_62209_0.titled_left_time = 0;
        /*  601 */     list.add(vo_62209_0);
        /*  602 */     for (java.util.Map.Entry<String, String> entry : chara.chenghao.entrySet()) {
            /*  603 */       vo_62209_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_62209_0();
            /*  604 */       vo_62209_0.stringformat = ((String)entry.getKey());
            /*  605 */       vo_62209_0.title = ((String)entry.getValue());
            /*  606 */       vo_62209_0.titled_left_time = 0;
            /*  607 */       list.add(vo_62209_0);
            /*      */     }
        /*  609 */     GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M62209_0(), list);
        /*      */   }
    /*      */
    /*      */   public static List zhandouisyoufabao(Chara chara)
    /*      */   {
        /*  614 */     List fabao = new java.util.LinkedList();
        /*  615 */     for (int i = 0; i < chara.backpack.size(); i++) {
            /*  616 */       if (((Goods)chara.backpack.get(i)).pos == 9) {
                /*  617 */         fabao.add(((Goods)chara.backpack.get(i)).goodsInfo.str);
                /*  618 */         fabao.add(Integer.valueOf(((Goods)chara.backpack.get(i)).goodsInfo.skill));
                /*  619 */         fabao.add(Integer.valueOf(((Goods)chara.backpack.get(i)).goodsInfo.shape));
                /*      */       }
            /*      */     }
        /*  622 */     return fabao;
        /*      */   }
    /*      */
    /*      */   public static void shuafabao(Chara chara)
    /*      */   {
        /*  627 */     String[] fb = { "番天印", "定海珠", "混元金斗", "阴阳镜", "九龙神火罩", "卸甲金葫" };
        /*  628 */     Random random = new Random();
        /*  629 */     int i = random.nextInt(5);
        /*  630 */     String fabao = fb[random.nextInt(fb.length)];
        /*  631 */     org.linlinjava.litemall.db.domain.StoreInfo info = GameData.that.baseStoreInfoService.findOneByName(fabao);
        /*  632 */     List<Goods> list = new ArrayList();
        /*  633 */     Goods goods = new Goods();
        /*  634 */     goods.pos = beibaoweizhi(chara);
        /*  635 */     goods.goodsInfo = new GoodsInfo();
        /*  636 */     if (info.getQuality() != null) {
            /*  637 */       goods.goodsInfo.quality = info.getQuality();
            /*      */     }
        /*  639 */     if (info.getSilverCoin() != null) {
            /*  640 */       goods.goodsInfo.silver_coin = info.getSilverCoin().intValue();
            /*      */     }
        /*  642 */     goods.goodsInfo.type = info.getType().intValue();
        /*  643 */     goods.goodsInfo.attrib = 0;
        /*  644 */     goods.goodsInfo.shape = 0;
        /*  645 */     goods.goodsInfo.str = info.getName();
        /*  646 */     goods.goodsInfo.nick = 0;
        /*  647 */     goods.goodsInfo.recognize_recognized = info.getRecognizeRecognized().intValue();
        /*  648 */     goods.goodsInfo.auto_fight = java.util.UUID.randomUUID().toString();
        /*  649 */     goods.goodsInfo.total_score = info.getTotalScore().intValue();
        /*  650 */     goods.goodsInfo.rebuild_level = 50000;
        /*  651 */     goods.goodsInfo.value = info.getValue().intValue();
        /*  652 */     goods.goodsInfo.degree_32 = 1;
        /*  653 */     goods.goodsInfo.owner_id = 1;
        /*  654 */     goods.goodsInfo.pot = 0;
        /*  655 */     goods.goodsInfo.damage_sel_rate = 400976;
        /*  656 */     goods.goodsInfo.diandqk_frozen_round = 3;
        /*      */
        /*  658 */     goods.goodsInfo.skill = 24;
        /*  659 */     goods.goodsInfo.amount = 9;
        /*  660 */     goods.goodsInfo.resist_poison = 1830;
        /*  661 */     goods.goodsInfo.shuadao_ziqihongmeng = (i + 1);
        /*  662 */     chara.backpack.add(goods);
        /*  663 */     GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
        /*  664 */     org.linlinjava.litemall.gameserver.data.vo.Vo_40964_0 vo_40964_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_40964_0();
        /*  665 */     vo_40964_0.type = 1;
        /*  666 */     vo_40964_0.name = fabao;
        /*  667 */     vo_40964_0.param = "20691134";
        /*  668 */     vo_40964_0.rightNow = 0;
        /*  669 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40964_0(), vo_40964_0);
        /*  670 */     org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0 vo_20481_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0();
        /*  671 */     vo_20481_0.msg = ("获得#R" + fabao);
        /*  672 */     vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
        /*  673 */     GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
        /*      */   }
    /*      */
    /*      */   public static void weijianding(Chara chara)
    /*      */   {
        /*  678 */     Random random = new Random();
        /*  679 */     int[] eqType = { 1, 2, 10, 3 };
        /*  680 */     int leixing = eqType[random.nextInt(4)];
        /*  681 */     String zhuangbname = zhuangbname(chara, leixing);
        /*  682 */     List<java.util.Hashtable<String, Integer>> hashtables = equipmentLuckDraw(chara.level, leixing);
        /*  683 */     ZhuangbeiInfo zhuangbeiInfo = GameData.that.baseZhuangbeiInfoService.findOneByStr(zhuangbname);
        /*  684 */     huodezhuangbei(chara, zhuangbeiInfo, 1, 1);
        /*      */   }
    /*      */

    /**
     * 任务奖励
     * @param chara
     */
    /*      */   public static void renwujiangli(Chara chara) {
        /*  688 */     org.linlinjava.litemall.db.domain.Renwu renwu = GameData.that.baseRenwuService.findOneByCurrentTask(chara.current_task);
        /*  689 */     String reward = renwu.getReward();
        /*  690 */     String[] split = reward.split("\\,");
        /*  691 */     for (int i = 0; i < split.length; i++) {
            /*  692 */       String[] jiangli = split[i].split("\\#");
            /*  693 */       huodechoujiang(jiangli, chara);
            /*      */     }
        /*      */   }
    /*      */

    /**
     * 下一个任务
     * @param str
     * @return
     */
    /*      */   public static String nextrenw(String str) {
        /*  698 */     String substring = str.substring(9, str.length());
        /*  699 */     int next = Integer.valueOf(substring).intValue() + 1;
        /*  700 */     String substring1 = str.substring(0, 9);
        /*  701 */     String renwu = substring1 + next;
        /*  702 */     org.linlinjava.litemall.db.domain.Renwu serviceOneByCurrentTask = GameData.that.baseRenwuService.findOneByCurrentTask(renwu);
        /*  703 */     if (renwu.equals("主线—浮生若梦_s23"))
            /*      */     {
            /*      */
            /*  706 */       return "";
            /*      */     }
        /*  708 */     if ((serviceOneByCurrentTask.getNpcName() != null) &&
                /*  709 */       (serviceOneByCurrentTask.getNpcName().equals("跳"))) {
            /*  710 */       return nextrenw(renwu);
            /*      */     }
        /*      */
        /*      */
        /*  714 */     return renwu;
        /*      */   }
    /*      */
    /*      */   public static void removemoney(Chara chara, int monet)
    /*      */   {
        /*  719 */     if (chara.lock_exp == 0) {
            /*  720 */       chara.balance -= monet;
            /*      */     } else {
            /*  722 */       chara.use_money_type -= monet;
            /*      */     }
        /*  724 */     ListVo_65527_0 listVo_65527_0 = a65527(chara);
        /*  725 */     GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
        /*      */   }
    /*      */
    /*      */   public static void addVip(Chara chara) {
        /*  729 */     if (chara.vipTime != 0) {
            /*  730 */       chara.vipTimeShengYu = ((int)(System.currentTimeMillis() / 1000L) - chara.vipTime);
            /*      */     }
        /*      */
        /*  733 */     org.linlinjava.litemall.gameserver.data.vo.Vo_53257_0 vo_53257_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_53257_0();
        /*  734 */     vo_53257_0.vipType = chara.vipType;
        /*  735 */     vo_53257_0.leftTime = (945225798 + chara.vipTimeShengYu);
        /*  736 */     vo_53257_0.curTime = 622080000;
        /*  737 */     vo_53257_0.isGet = chara.isGet;
        /*  738 */     vo_53257_0.tempInsider = 0;
        /*  739 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M53257_0(), vo_53257_0);
        /*      */   }
    /*      */
    /*      */   public static void genchongfei(Chara chara) {
        /*  743 */     for (int i = 0; i < chara.backpack.size(); i++) {
            /*  744 */       if (((Goods)chara.backpack.get(i)).pos == 37) {
                /*  745 */         org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0 vo_65529_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0();
                /*  746 */         vo_65529_0.id = chara.genchong_icon;
                /*  747 */         vo_65529_0.x = chara.x;
                /*  748 */         vo_65529_0.y = chara.y;
                /*  749 */         vo_65529_0.dir = 5;
                /*  750 */         vo_65529_0.icon = chara.genchong_icon;
                /*  751 */         vo_65529_0.type = 32768;
                /*  752 */         vo_65529_0.sub_type = 2;
                /*  753 */         vo_65529_0.owner_id = chara.id;
                /*  754 */         vo_65529_0.name = ((Goods)chara.backpack.get(i)).goodsInfo.str;
                /*  755 */         vo_65529_0.org_icon = chara.genchong_icon;
                /*  756 */         vo_65529_0.portrait = chara.genchong_icon;
                /*  757 */         GameObjectChar.getGameObjectChar().gameMap.send(new MSG_APPEAR(), vo_65529_0);
                /*      */       }
            /*      */     }
        /*      */   }
    /*      */
    /*      */
    /*      */   public static void removerbeibaocangku(Chara chara)
    /*      */   {
        /*  765 */     List<Goods> removergoods = new ArrayList();
        /*  766 */     for (int i = 0; i < chara.backpack.size(); i++) {
            /*  767 */       Goods goods = (Goods)chara.backpack.get(i);
            /*  768 */       if (goods.goodsInfo.owner_id == 0) {
                /*  769 */         removergoods.add(goods);
                /*      */       }
            /*      */     }
        /*      */
        /*  773 */     for (int i = 0; i < removergoods.size(); i++) {
            /*  774 */       List<Goods> listbeibao = new ArrayList();
            /*  775 */       Goods goods2 = new Goods();
            /*  776 */       goods2.goodsBasics = null;
            /*  777 */       goods2.goodsInfo = null;
            /*  778 */       goods2.goodsLanSe = null;
            /*  779 */       goods2.pos = ((Goods)removergoods.get(i)).pos;
            /*  780 */       listbeibao.add(goods2);
            /*  781 */       GameObjectChar.send(new MSG_INVENTORY(), listbeibao);
            /*  782 */       chara.backpack.remove(removergoods.get(i));
            /*      */     }
        /*  784 */     removergoods = new ArrayList();
        /*  785 */     for (int i = 0; i < chara.cangku.size(); i++) {
            /*  786 */       Goods goods = (Goods)chara.cangku.get(i);
            /*  787 */       if (goods.goodsInfo.owner_id == 0) {
                /*  788 */         removergoods.add(goods);
                /*      */       }
            /*      */     }
        /*      */
        /*  792 */     for (int i = 0; i < removergoods.size(); i++) {
            /*  793 */       chara.cangku.remove(removergoods.get(i));
            /*  794 */       org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0 vo_61677_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0();
            /*  795 */       vo_61677_0.list = chara.cangku;
            /*  796 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61677_0(), vo_61677_0);
            /*      */     }
        /*      */   }
    /*      */
    /*      */   public static void addpetjingyan(Petbeibao petbeibao, int jingyan, Chara chara)
    /*      */   {
        /*  802 */     PetShuXing petShuXing = (PetShuXing)petbeibao.petShuXing.get(0);
        /*  803 */     petShuXing.pot += jingyan;
        /*      */     if(petShuXing.pot>=2000000000) {petShuXing.pot=2000000000;}

        /*  805 */     if ((petShuXing.pot >= petShuXing.resist_poison) && (petShuXing.skill < 125)) {
            /*  806 */       petShuXing.pot -= petShuXing.resist_poison;
            /*  807 */       petShuXing.skill += 1;
            /*  808 */       org.linlinjava.litemall.db.domain.Experience oneByMaxLevel = GameData.that.baseExperienceService.findOneByAttrib(Integer.valueOf(petShuXing.skill));
            /*  809 */       petShuXing.resist_poison = (oneByMaxLevel.getMaxLevel().intValue() / 2);
            /*  810 */       org.linlinjava.litemall.gameserver.data.vo.Vo_4323_0 vo_4323_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_4323_0();
            /*  811 */       vo_4323_0.id = petbeibao.id;
            /*  812 */       vo_4323_0.level = 1;
            /*  813 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M4323_0(), vo_4323_0);
            /*  814 */       petShuXing.phy_power += 1;
            /*  815 */       petShuXing.life += 1;
            /*  816 */       petShuXing.speed += 1;
            /*  817 */       petShuXing.mag_power += 1;
            /*  818 */       petShuXing.polar_point += 4;
            /*  819 */       if ((petShuXing.skill < 60) && (petShuXing.skill % 2 != 0)) {
                /*  820 */         petShuXing.stamina += 1;
                /*  821 */       } else if (petShuXing.skill > 60) {
                /*  822 */         petShuXing.stamina += 1;
                /*      */       }
            /*  824 */       if (petShuXing.pot >= petShuXing.resist_poison) {
                /*  825 */         addpetjingyan(petbeibao, 0, chara);
                /*      */       }
            /*  827 */       org.linlinjava.litemall.gameserver.data.game.BasicAttributesUtils.petshuxing(petShuXing);
            /*  828 */       petShuXing.max_life = petShuXing.def;
            /*  829 */       petShuXing.max_mana = petShuXing.dex;
            /*  830 */       if (((PetShuXing)petbeibao.petShuXing.get(0)).suit_light_effect != 0) {
                /*  831 */         for (int i = 0; i < petbeibao.petShuXing.size(); i++) {
                    /*  832 */           if (((PetShuXing)petbeibao.petShuXing.get(i)).no == 23) {
                        /*  833 */             ((PetShuXing)petbeibao.petShuXing.get(i)).accurate = (4 * (((PetShuXing)petbeibao.petShuXing.get(0)).hide_mount - 1) * ((PetShuXing)petbeibao.petShuXing.get(0)).skill);
                        /*  834 */             ((PetShuXing)petbeibao.petShuXing.get(i)).mana = (4 * (((PetShuXing)petbeibao.petShuXing.get(0)).hide_mount - 1) * ((PetShuXing)petbeibao.petShuXing.get(0)).skill);
                        /*  835 */             ((PetShuXing)petbeibao.petShuXing.get(i)).wiz = (3 * (((PetShuXing)petbeibao.petShuXing.get(0)).hide_mount - 1) * ((PetShuXing)petbeibao.petShuXing.get(0)).skill);
                        /*      */           }
                    /*      */         }
                /*      */       }
            /*      */
            /*      */
            /*  841 */       List list = new ArrayList();
            /*  842 */       boolean isfagong = ((PetShuXing)petbeibao.petShuXing.get(0)).rank > ((PetShuXing)petbeibao.petShuXing.get(0)).pet_mag_shape;
            /*  843 */       dujineng(1, ((PetShuXing)petbeibao.petShuXing.get(0)).metal, ((PetShuXing)petbeibao.petShuXing.get(0)).skill, isfagong, petbeibao.id, chara);
            /*  844 */       list.add(petbeibao);
            /*  845 */       GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_UPDATE_PETS(), list);
            /*      */     }
        /*  847 */     List list = new ArrayList();
        /*  848 */     list.add(petbeibao);
        /*  849 */     GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_UPDATE_PETS(), list);
        /*      */   }
    /*      */
    /*      */   public static void huodejingyan(Chara chara, int jingyan)
    /*      */   {
        /*  854 */     jingyan *= 5;
        /*  855 */     addjingyan(chara, jingyan);
        /*  856 */     for (int i = 0; i < chara.pets.size(); i++) {
            /*  857 */       if (((Petbeibao)chara.pets.get(i)).id == chara.chongwuchanzhanId) {
                /*  858 */         ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).shape += 10;
                /*  859 */         org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0 vo_20481_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0();
                /*  860 */         addpetjingyan((Petbeibao)chara.pets.get(i), jingyan, chara);
                /*  861 */         vo_20481_0.msg = ("宠物获得#R" + jingyan / 2 + "#n经验");
                /*  862 */         vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
                /*  863 */         GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*  864 */         break;
                /*      */       }
            /*      */     }
        /*  867 */     org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0 vo_20481_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0();
        /*  868 */     vo_20481_0.msg = ("你获得了#R" + jingyan + "#n经验");
        /*  869 */     vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
        /*  870 */     GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
        /*      */   }
    /*      */
    /*      */
    /*      */   public static void addjingyan(Chara chara, int jingyan)
    /*      */   {
        /*  876 */     chara.pot += jingyan;
        /*  877 */     if ((chara.pot >= chara.resist_poison) && (chara.level < 128)) {
            /*  878 */       chara.pot -= chara.resist_poison;
            /*  879 */       chara.level += 1;
            /*  880 */       org.linlinjava.litemall.db.domain.Experience oneByMaxLevel = GameData.that.baseExperienceService.findOneByAttrib(Integer.valueOf(chara.level));
            /*  881 */       chara.resist_poison = oneByMaxLevel.getMaxLevel().intValue();
            /*  882 */       org.linlinjava.litemall.gameserver.data.vo.Vo_4323_0 vo_4323_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_4323_0();
            /*  883 */       vo_4323_0.id = chara.id;
            /*  884 */       vo_4323_0.level = 1;
            /*  885 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M4323_0(), vo_4323_0);
            /*  886 */       chara.phy_power += 1;
            /*  887 */       chara.life += 1;
            /*  888 */       chara.speed += 1;
            /*  889 */       chara.mag_power += 1;
            /*  890 */       chara.polar_point += 4;
            /*  891 */       if ((chara.level < 60) && (chara.level % 2 != 0)) {
                /*  892 */         chara.stamina += 1;
                /*  893 */       } else if (chara.level > 60) {
                /*  894 */         chara.stamina += 1;
                /*      */       }
            /*  896 */       if (chara.pot >= chara.resist_poison) {
                /*  897 */         addjingyan(chara, 0);
                /*      */       }
            /*  899 */       org.linlinjava.litemall.gameserver.data.game.BasicAttributesUtils.shuxing(chara);
            /*  900 */       chara.max_life = (chara.def + chara.zbAttribute.def);
            /*  901 */       chara.max_mana = (chara.dex + chara.zbAttribute.dex);
            /*  902 */       addshouhu(chara);
            /*      */
            /*  904 */       ListVo_65527_0 listVo_65527_0 = a65527(chara);
            /*  905 */       GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
            /*      */     }
        /*      */   }
    /*      */
    /*      */
    /*      */   public static void cangkuaddwupin(Goods goods, Chara chara)
    /*      */   {
        /*  912 */     boolean has = true;
        /*  913 */     int munber = 10;
        /*  914 */     if ("凝香幻彩#炫影霜星#风寂云清#枯月流魂#冰落残阳#雷极弧光".contains(goods.goodsInfo.str)) {
            /*  915 */       munber = 999;
            /*      */     }
        /*  917 */     for (int i = 0; i < chara.cangku.size(); i++) {
            /*  918 */       Goods goods1 = (Goods)chara.cangku.get(i);
            /*  919 */       java.util.Map<Object, Object> objectMapGoodxin = org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing.GoodsInfo(goods.goodsInfo);
            /*  920 */       java.util.Map<Object, Object> objectMapGoodxin1 = org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing.GoodsLanSe(goods1.goodsLanSe);
            /*      */
            /*  922 */       objectMapGoodxin.remove("auto_fight");
            /*  923 */       objectMapGoodxin.remove("owner_id");
            /*  924 */       java.util.Map<Object, Object> objectMapGoodjold = org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing.GoodsInfo(goods1.goodsInfo);
            /*  925 */       java.util.Map<Object, Object> objectMapGoodjold1 = org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing.GoodsLanSe(goods1.goodsLanSe);
            /*  926 */       objectMapGoodjold.remove("auto_fight");
            /*  927 */       objectMapGoodjold.remove("owner_id");
            /*  928 */       if ((objectMapGoodjold.toString().equals(objectMapGoodxin.toString())) && (objectMapGoodxin1.toString().equals(objectMapGoodjold1.toString())) && (goods1.goodsInfo.degree_32 == 1))
                /*      */       {
                /*  930 */         if (goods1.goodsInfo.owner_id < munber) {
                    /*  931 */           int owner = goods1.goodsInfo.owner_id;
                    /*  932 */           goods1.goodsInfo.owner_id += goods.goodsInfo.owner_id;
                    /*  933 */           if (goods1.goodsInfo.owner_id >= munber) {
                        /*  934 */             goods1.goodsInfo.owner_id = munber;
                        /*  935 */             goods.goodsInfo.owner_id = (goods.goodsInfo.owner_id - munber + owner);
                        /*      */           } else {
                        /*  937 */             org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0 vo_61677_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0();
                        /*  938 */             vo_61677_0.list = chara.cangku;
                        /*  939 */             GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61677_0(), vo_61677_0);
                        /*  940 */             has = false;
                        /*      */           }
                    /*      */         }
                /*      */       }
            /*      */     }
        /*  945 */     if (has) {
            /*  946 */       List list = new ArrayList();
            /*  947 */       if (goods.goodsInfo.owner_id > munber) {
                /*  948 */         int len = goods.goodsInfo.owner_id / munber;
                /*  949 */         int last = goods.goodsInfo.owner_id % munber;
                /*  950 */         for (int i = 0; i < len; i++) {
                    /*  951 */           java.util.Map<Object, Object> objectMapGoodxin = org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing.Goods(goods);
                    /*  952 */           Goods goodsxin = (Goods)org.linlinjava.litemall.db.util.JSONUtils.parseObject(org.linlinjava.litemall.db.util.JSONUtils.toJSONString(objectMapGoodxin), Goods.class);
                    /*  953 */           goodsxin.pos = cangkuweizhi(chara);
                    /*  954 */           goodsxin.goodsInfo.owner_id = munber;
                    /*  955 */           chara.cangku.add(goodsxin);
                    /*  956 */           list = new ArrayList();
                    /*  957 */           list.add(goodsxin);
                    /*  958 */           org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0 vo_61677_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0();
                    /*  959 */           vo_61677_0.list = chara.cangku;
                    /*  960 */           GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61677_0(), vo_61677_0);
                    /*      */         }
                /*  962 */         if (last != 0) {
                    /*  963 */           java.util.Map<Object, Object> objectMapGoodxin = org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing.Goods(goods);
                    /*  964 */           Goods goodsxin = (Goods)org.linlinjava.litemall.db.util.JSONUtils.parseObject(org.linlinjava.litemall.db.util.JSONUtils.toJSONString(objectMapGoodxin), Goods.class);
                    /*  965 */           goodsxin.pos = cangkuweizhi(chara);
                    /*  966 */           goodsxin.goodsInfo.owner_id = last;
                    /*  967 */           chara.cangku.add(goodsxin);
                    /*  968 */           list = new ArrayList();
                    /*  969 */           list.add(goodsxin);
                    /*  970 */           org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0 vo_61677_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0();
                    /*  971 */           vo_61677_0.list = chara.cangku;
                    /*  972 */           GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61677_0(), vo_61677_0);
                    /*      */         }
                /*      */       } else {
                /*  975 */         goods.pos = cangkuweizhi(chara);
                /*  976 */         chara.cangku.add(goods);
                /*  977 */         list = new ArrayList();
                /*  978 */         list.add(goods);
                /*  979 */         org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0 vo_61677_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0();
                /*  980 */         vo_61677_0.list = chara.cangku;
                /*  981 */         GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61677_0(), vo_61677_0);
                /*      */       }
            /*  983 */       org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0 vo_61677_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0();
            /*  984 */       vo_61677_0.list = chara.cangku;
            /*  985 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61677_0(), vo_61677_0);
            /*      */     }
        /*      */   }
    /*      */
    /*      */   public static void addwupin(Goods goods, Chara chara) {
        /*  990 */     boolean has = true;
        /*  991 */     int munber = 10;
        /*  992 */     if ("凝香幻彩#炫影霜星#风寂云清#枯月流魂#冰落残阳#雷极弧光".contains(goods.goodsInfo.str)) {
            /*  993 */       munber = 999;
            /*      */     }
        /*  995 */     int pos = beibaoweizhi(chara);
        /*  996 */     if (pos == 0) {
            /*  997 */       return;
            /*      */     }
        /*  999 */     for (int i = 0; i < chara.backpack.size(); i++) {
            /* 1000 */       Goods goods1 = (Goods)chara.backpack.get(i);
            /* 1001 */       java.util.Map<Object, Object> objectMapGoodxin = org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing.GoodsInfo(goods.goodsInfo);
            /* 1002 */       java.util.Map<Object, Object> objectMapGoodxin1 = org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing.GoodsLanSe(goods.goodsLanSe);
            /* 1003 */       objectMapGoodxin.remove("auto_fight");
            /* 1004 */       objectMapGoodxin.remove("owner_id");
            /* 1005 */       java.util.Map<Object, Object> objectMapGoodjold = org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing.GoodsInfo(goods1.goodsInfo);
            /* 1006 */       java.util.Map<Object, Object> objectMapGoodjold1 = org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing.GoodsLanSe(goods1.goodsLanSe);
            /* 1007 */       objectMapGoodjold.remove("auto_fight");
            /* 1008 */       objectMapGoodjold.remove("owner_id");
            /* 1009 */       if ((objectMapGoodjold.toString().equals(objectMapGoodxin.toString())) && (objectMapGoodxin1.toString().equals(objectMapGoodjold1.toString())) && (goods1.goodsInfo.degree_32 == 1))
                /*      */       {
                /* 1011 */         if (goods1.goodsInfo.owner_id < munber) {
                    /* 1012 */           int owner = goods1.goodsInfo.owner_id;
                    /* 1013 */           goods1.goodsInfo.owner_id += goods.goodsInfo.owner_id;
                    /* 1014 */           if (goods1.goodsInfo.owner_id >= munber) {
                        /* 1015 */             goods1.goodsInfo.owner_id = munber;
                        /* 1016 */             goods.goodsInfo.owner_id = (goods.goodsInfo.owner_id - munber + owner);
                        /*      */           } else {
                        /* 1018 */             GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
                        /* 1019 */             has = false;
                        /*      */           }
                    /*      */         }
                /*      */       }
            /*      */     }
        /* 1024 */     if (has)
            /*      */     {
            /* 1026 */       List list = new ArrayList();
            /* 1027 */       if (goods.goodsInfo.owner_id > munber) {
                /* 1028 */         int len = goods.goodsInfo.owner_id / munber;
                /* 1029 */         int last = goods.goodsInfo.owner_id % munber;
                /* 1030 */         for (int i = 0; i < len; i++) {
                    /* 1031 */           java.util.Map<Object, Object> objectMapGoodxin = org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing.Goods(goods);
                    /* 1032 */           Goods goodsxin = (Goods)org.linlinjava.litemall.db.util.JSONUtils.parseObject(org.linlinjava.litemall.db.util.JSONUtils.toJSONString(objectMapGoodxin), Goods.class);
                    /* 1033 */           goodsxin.pos = beibaoweizhi(chara);
                    /* 1034 */           goodsxin.goodsInfo.owner_id = munber;
                    /* 1035 */           chara.backpack.add(goodsxin);
                    /* 1036 */           list = new ArrayList();
                    /* 1037 */           list.add(goodsxin);
                    /* 1038 */           GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
                    /*      */         }
                /* 1040 */         if (last != 0) {
                    /* 1041 */           java.util.Map<Object, Object> objectMapGoodxin = org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing.Goods(goods);
                    /* 1042 */           Goods goodsxin = (Goods)org.linlinjava.litemall.db.util.JSONUtils.parseObject(org.linlinjava.litemall.db.util.JSONUtils.toJSONString(objectMapGoodxin), Goods.class);
                    /* 1043 */           goodsxin.pos = beibaoweizhi(chara);
                    /* 1044 */           goodsxin.goodsInfo.owner_id = last;
                    /* 1045 */           chara.backpack.add(goodsxin);
                    /* 1046 */           list = new ArrayList();
                    /* 1047 */           list.add(goodsxin);
                    /* 1048 */           GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
                    /*      */         }
                /* 1050 */       } else if (goods.goodsInfo.owner_id != 0) {
                /* 1051 */         goods.pos = beibaoweizhi(chara);
                /* 1052 */         chara.backpack.add(goods);
                /* 1053 */         list = new ArrayList();
                /* 1054 */         list.add(goods);
                /* 1055 */         GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
                /*      */       }
            /* 1057 */       GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
            /*      */     }
        /*      */   }
    /*      */
    /*      */   public static org.linlinjava.litemall.gameserver.data.vo.Vo_49179_0 a49179(List<org.linlinjava.litemall.db.domain.SaleGood> saleGoodList, Chara chara)
    /*      */   {
        /* 1063 */     org.linlinjava.litemall.gameserver.data.vo.Vo_49179_0 vo_49179_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_49179_0();
        /* 1064 */     vo_49179_0.dealNum = 0;
        /* 1065 */     vo_49179_0.sellCash = String.valueOf(chara.jishou_coin);
        /* 1066 */     vo_49179_0.stallTotalNum = 4;
        /* 1067 */     vo_49179_0.record_count_max = 30;
        /* 1068 */     for (int i = 0; i < saleGoodList.size(); i++)
            /*      */     {
            /*      */
            /* 1071 */       org.linlinjava.litemall.db.domain.SaleGood saleGood = (org.linlinjava.litemall.db.domain.SaleGood)saleGoodList.get(i);
            /*      */
            /*      */
            /* 1074 */       org.linlinjava.litemall.gameserver.data.vo.Vo_49179 vo_49179 = new org.linlinjava.litemall.gameserver.data.vo.Vo_49179();
            /*      */
            /* 1076 */       vo_49179.name = saleGood.getName();
            /* 1077 */       if (saleGood.getName().contains("超级黑水晶·")) {
                /* 1078 */         String goods = saleGood.getGoods();
                /* 1079 */         Goods goods1 = (Goods)org.linlinjava.litemall.db.util.JSONUtils.parseObject(goods, Goods.class);
                /* 1080 */         java.util.Map<Object, Object> goodsFenSe1 = org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing.GoodsLanSe(goods1.goodsLanSe);
                /* 1081 */         int value = 0;
                /* 1082 */         for (java.util.Map.Entry<Object, Object> entry : goodsFenSe1.entrySet()) {
                    /* 1083 */           if ((!entry.getKey().equals("groupNo")) && (!entry.getKey().equals("groupType")) && (((Integer)entry.getValue()).intValue() != 0))
                        /*      */           {
                        /*      */
                        /* 1086 */             value = ((Integer)entry.getValue()).intValue();
                        /*      */           }
                    /*      */         }
                /* 1089 */         vo_49179.name = (saleGood.getName() + "|" + value + "|1");
                /*      */       }
            /* 1091 */       vo_49179.id = saleGood.getGoodsId();
            /* 1092 */       vo_49179.price = saleGood.getPrice().intValue();
            /* 1093 */       vo_49179.pos = 2;
            /* 1094 */       vo_49179.status = 2;
            /* 1095 */       vo_49179.startTime = saleGood.getStartTime().intValue();
            /* 1096 */       vo_49179.endTime = saleGood.getEndTime().intValue();
            /* 1097 */       vo_49179.level = 0;
            /* 1098 */       vo_49179.unidentified = 1;
            /* 1099 */       vo_49179.amount = saleGood.getReqLevel().intValue();
            /* 1100 */       vo_49179.req_level = 635;
            /* 1101 */       vo_49179.extra = 125;
            /* 1102 */       vo_49179.item_polar = 0;
            /* 1103 */       vo_49179.cg_price_count = 4;
            /* 1104 */       vo_49179.init_price = saleGood.getPrice().intValue();
            /* 1105 */       vo_49179_0.vo_49179s.add(vo_49179);
            /*      */     }
        /* 1107 */     return vo_49179_0;
        /*      */   }
    /*      */
    /*      */   public static void a49159(Chara chara) {
        /* 1111 */     org.linlinjava.litemall.gameserver.data.vo.Vo_49159_0 vo_49159_3 = new org.linlinjava.litemall.gameserver.data.vo.Vo_49159_0();
        /* 1112 */     int isCanSign = 0;
        /* 1113 */     for (int j = 0; j < chara.shenmiliwu.size(); j++) {
            /* 1114 */       if (!((org.linlinjava.litemall.gameserver.data.vo.Vo_41480_0)chara.shenmiliwu.get(j)).name.equals("")) {
                /* 1115 */         vo_49159_3.leftTime += ((org.linlinjava.litemall.gameserver.data.vo.Vo_41480_0)chara.shenmiliwu.get(j)).time;
                /*      */       }
            /*      */     }
        /* 1118 */     for (int i = 0; i < chara.shenmiliwu.size(); i++) {
            /* 1119 */       if (((org.linlinjava.litemall.gameserver.data.vo.Vo_41480_0)chara.shenmiliwu.get(i)).name.equals("")) {
                /* 1120 */         int times = ((org.linlinjava.litemall.gameserver.data.vo.Vo_41480_0)chara.shenmiliwu.get(i)).time;
                /* 1121 */         vo_49159_3.leftTime = ((int)(times - chara.online_time / 1000L));
                /* 1122 */         vo_49159_3.leftTime = ((int)(vo_49159_3.leftTime - (System.currentTimeMillis() - chara.uptime) / 1000L));
                /* 1123 */         if (vo_49159_3.leftTime > 0) {
                    /*      */           break;
                    /*      */         }
                /* 1126 */         isCanSign++;
                /*      */       }
            /*      */     }
        /*      */
        /*      */
        /* 1131 */     vo_49159_3.times = isCanSign;
        /* 1132 */     vo_49159_3.leftTimes = 8;
        /* 1133 */     vo_49159_3.isCanSign = 0;
        /* 1134 */     vo_49159_3.isCanGetNewPalyerGift = 0;
        /* 1135 */     vo_49159_3.firstChargeState = 2;
        /* 1136 */     vo_49159_3.cumulativeReward = 255;
        /* 1137 */     vo_49159_3.loginGiftState = 2;
        /* 1138 */     vo_49159_3.activeCount = 255;
        /* 1139 */     vo_49159_3.holidayCount = 255;
        /* 1140 */     vo_49159_3.isCanReplenishSign = 255;
        /* 1141 */     vo_49159_3.chargePointFlag = 255;
        /* 1142 */     vo_49159_3.consumePointFlag = 255;
        /* 1143 */     vo_49159_3.isShowHuiGui = 0;
        /* 1144 */     vo_49159_3.canGetZXQYHuoYue = 0;
        /* 1145 */     vo_49159_3.canGetZXQYSevenLogin = 0;
        /* 1146 */     vo_49159_3.isShowZhaohui = 0;
        /* 1147 */     vo_49159_3.activeVIPFlag = 0;
        /* 1148 */     vo_49159_3.rename_discount_time = 0;
        /* 1149 */     vo_49159_3.summerSF2017 = 0;
        /* 1150 */     vo_49159_3.zaohua = 255;
        /* 1151 */     vo_49159_3.welcomeDrawStatue = 255;
        /* 1152 */     vo_49159_3.activeLoginStatue = 255;
        /* 1153 */     vo_49159_3.xundcf = 255;
        /* 1154 */     vo_49159_3.mergeLoginStatus = 255;
        /* 1155 */     vo_49159_3.mergeLoginActiveStatus = 255;
        /* 1156 */     vo_49159_3.reentryAsktaoRecharge = 255;
        /* 1157 */     vo_49159_3.expStoreStatus = 0;
        /* 1158 */     vo_49159_3.isShowXYFL = 255;
        /* 1159 */     vo_49159_3.isShowXFSD = 0;
        /* 1160 */     vo_49159_3.newServeAddNum = 0;
        /* 1161 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M49159_0(), vo_49159_3);
        /*      */   }
    /*      */
    /*      */
    /*      */   public static boolean isNow(java.util.Date date)
    /*      */   {
        /* 1167 */     java.util.Date now = new java.util.Date();
        /* 1168 */     java.text.SimpleDateFormat sf = new java.text.SimpleDateFormat("yyyyMMdd");
        /*      */
        /* 1170 */     String nowDay = sf.format(now);
        /*      */
        /* 1172 */     String day = sf.format(date);
        /*      */
        /* 1174 */     return day.equals(nowDay);
        /*      */   }
    /*      */
    /*      */
    /*      */   public static List<JiNeng> dujineng(int leixing, int pos, int level, boolean isMagic, int id, Chara chara)
    /*      */   {
        /* 1180 */     List<JiNeng> jiNengList = new ArrayList();
        /* 1181 */     List<org.json.JSONObject> nomelSkills = org.linlinjava.litemall.gameserver.data.game.PetAndHelpSkillUtils.getNomelSkills(leixing, pos, level, true);
        /* 1182 */     for (int i = 0; i < nomelSkills.size(); i++) {
            /* 1183 */       JiNeng jiNeng = new JiNeng();
            /* 1184 */       org.json.JSONObject jsonObject = (org.json.JSONObject)nomelSkills.get(i);
            /* 1185 */       jiNeng.id = id;
            /* 1186 */       jiNeng.skill_no = Integer.parseInt((String)jsonObject.get("skillNo"));
            /* 1187 */       org.json.JSONObject jsonObject1 = org.linlinjava.litemall.gameserver.data.game.PetAndHelpSkillUtils.jsonArray(jiNeng.skill_no);
            /* 1188 */       jiNeng.skill_attrib1 = Integer.parseInt((String)jsonObject1.get("skill_attrib"));
            /* 1189 */       jiNeng.skill_attrib = ((Integer)jsonObject.get("skillLevel")).intValue();
            /* 1190 */       jiNeng.skill_level = ((Integer)jsonObject.get("skillLevel")).intValue();
            /* 1191 */       jiNeng.skillRound = jsonObject.optInt("skillRound");
            /* 1192 */       jiNeng.level_improved = 0;
            /* 1193 */       jiNeng.skill_mana_cost = ((Integer)jsonObject.get("skillBlue")).intValue();
            /* 1194 */       jiNeng.skill_nimbus = 42949672;
            /* 1195 */       jiNeng.skill_disabled = 0;
            /* 1196 */       jiNeng.range = ((Integer)jsonObject.get("skillNum")).intValue();
            /* 1197 */       jiNeng.max_range = ((Integer)jsonObject.get("skillNum")).intValue();
            /* 1198 */       jiNengList.add(jiNeng);
            /*      */     }
        /* 1200 */     List<org.linlinjava.litemall.gameserver.data.vo.Vo_32747_0> vo_32747_0List = MSG_UPDATE_SKILLS(jiNengList);
        /* 1201 */     GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_UPDATE_SKILLS(), vo_32747_0List);
        /*      */
        /* 1203 */     return jiNengList;
        /*      */   }
    /*      */
    /*      */
    /*      */   public static int getCard(Chara chara)
    /*      */   {
        /* 1209 */     chara.allId += 1;
        /* 1210 */     return chara.allId;
        /*      */   }
    /*      */
    /*      */   public static int getNo(Chara chara, int no)
    /*      */   {
        /* 1215 */     no = 1;
        /* 1216 */     for (int j = 0; j < chara.pets.size(); j++) {
            /* 1217 */       if (no < ((Petbeibao)chara.pets.get(j)).no) {
                /* 1218 */         no = ((Petbeibao)chara.pets.get(j)).no;
                /*      */       }
            /*      */     }
        /* 1221 */     return no + 1;
        /*      */   }
    /*      */
    /*      */   public static List<org.linlinjava.litemall.gameserver.data.vo.Vo_32747_0> MSG_UPDATE_SKILLS(List<JiNeng> jiNengs) {
        /* 1225 */     List<org.linlinjava.litemall.gameserver.data.vo.Vo_32747_0> vo_32747_0List = new ArrayList();
        /* 1226 */     for (JiNeng jiNeng : jiNengs) {
            /* 1227 */       org.linlinjava.litemall.gameserver.data.vo.Vo_32747_0 vo_32747_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_32747_0();
            /* 1228 */       vo_32747_0.id = jiNeng.id;
            /* 1229 */       vo_32747_0.skill_no = jiNeng.skill_no;
            /* 1230 */       vo_32747_0.skill_attrib = jiNeng.skill_attrib;
            /* 1231 */       vo_32747_0.skill_attrib1 = jiNeng.skill_attrib1;
            /* 1232 */       vo_32747_0.skill_level = jiNeng.skill_level;
            /* 1233 */       vo_32747_0.level_improved = jiNeng.level_improved;
            /* 1234 */       vo_32747_0.skill_mana_cost = jiNeng.skill_mana_cost;
            /* 1235 */       vo_32747_0.skill_nimbus = jiNeng.skill_nimbus;
            /* 1236 */       vo_32747_0.skill_disabled = jiNeng.skill_disabled;
            /* 1237 */       vo_32747_0.range = jiNeng.range;
            /* 1238 */       vo_32747_0.max_range = jiNeng.max_range;
            /* 1239 */       vo_32747_0.count1 = 0;
            /* 1240 */       vo_32747_0.s1 = jiNeng.s1;
            /* 1241 */       vo_32747_0.s2 = jiNeng.s2;
            /* 1242 */       vo_32747_0.isTempSkill = 0;
            /* 1243 */       vo_32747_0List.add(vo_32747_0);
            /*      */     }
        /* 1245 */     return vo_32747_0List;
        /*      */   }
    /*      */
    /*      */   public static List<org.linlinjava.litemall.gameserver.data.vo.Vo_32747_0> MSG_UPDATE_SKILLS(Chara chara) {
        /* 1249 */     List<org.linlinjava.litemall.gameserver.data.vo.Vo_32747_0> vo_32747_0List = new ArrayList();
        /* 1250 */     for (JiNeng jiNeng : chara.jiNengList) {
            /* 1251 */       org.linlinjava.litemall.gameserver.data.vo.Vo_32747_0 vo_32747_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_32747_0();
            /* 1252 */       vo_32747_0.id = chara.id;
            /* 1253 */       vo_32747_0.skill_no = jiNeng.skill_no;
            /* 1254 */       vo_32747_0.skill_attrib = jiNeng.skill_attrib;
            /* 1255 */       vo_32747_0.skill_attrib1 = jiNeng.skill_attrib1;
            /* 1256 */       vo_32747_0.skill_level = jiNeng.skill_level;
            /* 1257 */       vo_32747_0.level_improved = jiNeng.level_improved;
            /* 1258 */       vo_32747_0.skill_mana_cost = jiNeng.skill_mana_cost;
            /* 1259 */       vo_32747_0.skill_nimbus = jiNeng.skill_nimbus;
            /* 1260 */       vo_32747_0.skill_disabled = jiNeng.skill_disabled;
            /* 1261 */       vo_32747_0.range = jiNeng.range;
            /* 1262 */       vo_32747_0.max_range = jiNeng.max_range;
            /* 1263 */       vo_32747_0.count1 = jiNeng.count1;
            /* 1264 */       vo_32747_0.s1 = jiNeng.s1;
            /* 1265 */       vo_32747_0.s2 = jiNeng.s2;
            /* 1266 */       vo_32747_0.isTempSkill = 0;
            /* 1267 */       vo_32747_0List.add(vo_32747_0);
            /*      */     }
        /* 1269 */     return vo_32747_0List;
        /*      */   }
    /*      */
    /*      */   public static List<org.linlinjava.litemall.gameserver.data.vo.Vo_61545_0> a61545(Chara chara)
    /*      */   {
        /* 1274 */     List<org.linlinjava.litemall.gameserver.data.vo.Vo_61545_0> vo_61545_0List = new ArrayList();
        /* 1275 */     org.linlinjava.litemall.gameserver.data.vo.Vo_61545_0 vo_61545_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_61545_0();
        /* 1276 */     vo_61545_0.groupBuf = "6";
        /* 1277 */     vo_61545_0.charBuf = chara.name;
        /* 1278 */     vo_61545_0.blocked = 0;
        /* 1279 */     vo_61545_0.online = 1;
        /* 1280 */     vo_61545_0.server_name1 = "剑影寒光22线";
        /* 1281 */     vo_61545_0.insider_level = 0;
        /* 1282 */     vo_61545_0.user_state = 0;
        /* 1283 */     vo_61545_0.auto_reply = 0;
        /* 1284 */     vo_61545_0.gid = "";
        /* 1285 */     vo_61545_0.placed_amount = 0;
        /* 1286 */     vo_61545_0.tao_effect = chara.waiguan;
        /* 1287 */     vo_61545_0.skill = chara.level;
        /* 1288 */     vo_61545_0.type = chara.waiguan;
        /* 1289 */     vo_61545_0.server_name = "剑影寒光22线";
        /* 1290 */     vo_61545_0.suit_icon = chara.weapon_icon;
        /* 1291 */     vo_61545_0.party_contrib = "";
        /* 1292 */     vo_61545_0.character_harmony = "";
        /* 1293 */     vo_61545_0.evolve_level = 0;
        /* 1294 */     vo_61545_0.nice = "";
        /* 1295 */     vo_61545_0.req_str = "";
        /* 1296 */     vo_61545_0.org_icon = 0;
        /* 1297 */     vo_61545_0.iid_str = chara.uuid;
        /* 1298 */     vo_61545_0.balance = chara.balance;
        /* 1299 */     vo_61545_0.arena_rank = 1;
        /* 1300 */     vo_61545_0List.add(vo_61545_0);
        /*      */
        /* 1302 */     return vo_61545_0List;
        /*      */   }
    /*      */  //MSG_FRIEND_UPDATE_PARTIAL
    /*      */   public static org.linlinjava.litemall.gameserver.data.vo.Vo_24505_0 MSG_FRIEND_UPDATE_PARTIAL(Chara chara) {
        /* 1306 */     org.linlinjava.litemall.gameserver.data.vo.Vo_24505_0 vo_24505_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_24505_0();
        /* 1307 */     vo_24505_0.update_type = 2;
        /* 1308 */     vo_24505_0.groupBuf = "6";
        /* 1309 */     vo_24505_0.charBuf = chara.name;
        /* 1310 */     vo_24505_0.user_state = 0;
        /* 1311 */     vo_24505_0.auto_reply = 0;
        /* 1312 */     vo_24505_0.placed_amount = 0;
        /* 1313 */     vo_24505_0.gid = "";
        /* 1314 */     vo_24505_0.tao_effect = chara.waiguan;
        /* 1315 */     vo_24505_0.skill = chara.level;
        /* 1316 */     vo_24505_0.type = chara.waiguan;
        /* 1317 */     vo_24505_0.server_name = "涅槃重生22";
        /* 1318 */     vo_24505_0.suit_icon = chara.weapon_icon;
        /* 1319 */     vo_24505_0.party_contrib = "";
        /* 1320 */     vo_24505_0.character_harmony = "";
        /* 1321 */     vo_24505_0.evolve_level = 0;
        /* 1322 */     vo_24505_0.nice = "";
        /* 1323 */     vo_24505_0.req_str = "";
        /* 1324 */     vo_24505_0.org_icon = 0;
        /* 1325 */     vo_24505_0.iid_str = chara.uuid;
        /* 1326 */     vo_24505_0.balance = chara.balance;
        /* 1327 */     vo_24505_0.arena_rank = 1;
        /*      */
        /* 1329 */     return vo_24505_0;
        /*      */   }
    /*      */
    /*      */   public static void a20467(Chara chara, int id, String ask_type)
    /*      */   {
        /* 1334 */     org.linlinjava.litemall.gameserver.game.GameTeam gameTeam = new org.linlinjava.litemall.gameserver.game.GameTeam();
        /*      */
        /* 1336 */     if (GameObjectCharMng.getGameObjectChar(id).gameTeam == null) {
            /* 1337 */       GameObjectCharMng.getGameObjectChar(id).creator(gameTeam);
            /*      */     }
        /*      */
        /* 1340 */     GameObjectCharMng.getGameObjectChar(id).gameTeam.liebiao.add(GameObjectChar.getGameObjectChar().gameTeam.duiwu);
        /* 1341 */     org.linlinjava.litemall.gameserver.data.vo.Vo_20467_0 vo_20467_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20467_0();
        /* 1342 */     vo_20467_0.caption = "";
        /* 1343 */     vo_20467_0.content = "";
        /*      */
        /* 1345 */     vo_20467_0.peer_name = chara.name;
        /* 1346 */     vo_20467_0.ask_type = "invite_join";
        /* 1347 */     vo_20467_0.org_icon = chara.waiguan;
        /* 1348 */     vo_20467_0.iid_str = chara.uuid;
        /* 1349 */     vo_20467_0.skill = chara.level;
        /* 1350 */     vo_20467_0.str = chara.name;
        /* 1351 */     vo_20467_0.master = chara.sex;
        /* 1352 */     vo_20467_0.metal = chara.menpai;
        /* 1353 */     vo_20467_0.req_str = "";
        /* 1354 */     vo_20467_0.passive_mode = chara.waiguan;
        /*      */
        /* 1356 */     vo_20467_0.party_contrib = "";
        /* 1357 */     vo_20467_0.teamMembersCount = 1;
        /* 1358 */     vo_20467_0.comeback_flag = 0;
        /* 1359 */     GameObjectCharMng.getGameObjectChar(id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M20467_0(), vo_20467_0);
        /*      */   }
    /*      */
    /*      */   public static org.linlinjava.litemall.gameserver.data.vo.Vo_4121_0 add4121(Chara chara, int memberteam_status) {
        /* 1363 */     org.linlinjava.litemall.gameserver.data.vo.Vo_4121_0 vo_4121_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_4121_0();
        /* 1364 */     vo_4121_0.id = chara.id;
        /* 1365 */     vo_4121_0.gid = chara.uuid;
        /* 1366 */     vo_4121_0.suit_icon = 0;
        /* 1367 */     vo_4121_0.weapon_icon = chara.weapon_icon;
        /* 1368 */     vo_4121_0.org_icon = chara.waiguan;
        /* 1369 */     vo_4121_0.skill = chara.level;
        /* 1370 */     vo_4121_0.str = chara.name;
        /* 1371 */     vo_4121_0.master = chara.sex;
        /* 1372 */     vo_4121_0.metal = chara.menpai;
        /* 1373 */     vo_4121_0.passive_mode = chara.waiguan;
        /* 1374 */     vo_4121_0.req_str = "";
        /* 1375 */     vo_4121_0.durability = 1;
        /* 1376 */     vo_4121_0.party_contrib = chara.chenhao;
        /* 1377 */     vo_4121_0.upgrade_level = 0;
        /* 1378 */     vo_4121_0.memberpos_x = chara.x;
        /* 1379 */     vo_4121_0.memberpos_y = chara.y;
        /* 1380 */     vo_4121_0.membermap_id = chara.mapid;
        /* 1381 */     vo_4121_0.memberteam_status = memberteam_status;
        /* 1382 */     vo_4121_0.membercard_name = "";
        /* 1383 */     vo_4121_0.membercomeback_flag = 0;
        /* 1384 */     vo_4121_0.memberlight_effect_count = 0;
        /* 1385 */     return vo_4121_0;
        /*      */   }
    /*      */
    /*      */   public static void a4121(List<org.linlinjava.litemall.gameserver.data.vo.Vo_4121_0> charaList) {
        /* 1389 */     List<org.linlinjava.litemall.gameserver.data.vo.Vo_4121_0> vo_4121_0List = new ArrayList();
        /*      */
        /* 1391 */     for (org.linlinjava.litemall.gameserver.data.vo.Vo_4121_0 vo41210 : charaList) {
            /* 1392 */       org.linlinjava.litemall.gameserver.data.vo.Vo_4121_0 vo_4121_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_4121_0();
            /* 1393 */       vo_4121_0.id = vo41210.id;
            /* 1394 */       vo_4121_0.gid = vo41210.gid;
            /* 1395 */       vo_4121_0.suit_icon = 0;
            /* 1396 */       vo_4121_0.weapon_icon = vo41210.weapon_icon;
            /* 1397 */       vo_4121_0.org_icon = vo41210.org_icon;
            /* 1398 */       vo_4121_0.skill = vo41210.skill;
            /* 1399 */       vo_4121_0.str = vo41210.str;
            /* 1400 */       vo_4121_0.master = vo41210.master;
            /* 1401 */       vo_4121_0.metal = vo41210.metal;
            /* 1402 */       vo_4121_0.passive_mode = vo41210.passive_mode;
            /* 1403 */       vo_4121_0.req_str = "";
            /* 1404 */       vo_4121_0.durability = 1;
            /* 1405 */       vo_4121_0.party_contrib = vo41210.party_contrib;
            /* 1406 */       vo_4121_0.upgrade_level = 0;
            /* 1407 */       vo_4121_0.memberpos_x = vo41210.memberpos_x;
            /* 1408 */       vo_4121_0.memberpos_y = vo41210.memberpos_y;
            /* 1409 */       vo_4121_0.membermap_id = vo41210.membermap_id;
            /* 1410 */       vo_4121_0.memberteam_status = vo41210.memberteam_status;
            /* 1411 */       vo_4121_0.membercard_name = "";
            /* 1412 */       vo_4121_0.membercomeback_flag = vo41210.membercomeback_flag;
            /* 1413 */       vo_4121_0.memberlight_effect_count = 0;
            /* 1414 */       vo_4121_0List.add(vo_4121_0);
            /*      */     }
        /* 1416 */     for (org.linlinjava.litemall.gameserver.data.vo.Vo_4121_0 vo41210 : charaList) {
            /* 1417 */       GameObjectCharMng.getGameObjectChar(vo41210.id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M4121_0(), vo_4121_0List);
            /*      */     }
        /*      */   }
    /*      */
    /*      */   public static void a4119(List<Chara> charaList)
    /*      */   {
        /* 1423 */     List<org.linlinjava.litemall.gameserver.data.vo.Vo_4119_0> vo_4119_0List = new ArrayList();
        /*      */
        /* 1425 */     for (Chara chara : charaList) {
            /* 1426 */       org.linlinjava.litemall.gameserver.data.vo.Vo_4119_0 vo_4119_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_4119_0();
            /* 1427 */       vo_4119_0.id = chara.id;
            /* 1428 */       vo_4119_0.gid = chara.uuid;
            /* 1429 */       vo_4119_0.suit_icon = 0;
            /* 1430 */       vo_4119_0.weapon_icon = chara.weapon_icon;
            /* 1431 */       vo_4119_0.org_icon = chara.waiguan;
            /* 1432 */       vo_4119_0.skill = chara.level;
            /* 1433 */       vo_4119_0.str = chara.name;
            /* 1434 */       vo_4119_0.master = chara.sex;
            /* 1435 */       vo_4119_0.metal = chara.menpai;
            /* 1436 */       vo_4119_0.passive_mode = chara.waiguan;
            /* 1437 */       vo_4119_0.req_str = "";
            /* 1438 */       vo_4119_0.party_contrib = chara.chenhao;
            /* 1439 */       vo_4119_0.upgrade_level = 0;
            /* 1440 */       vo_4119_0.membercard_name = "";
            /* 1441 */       vo_4119_0.memberlight_effect_count = 0;
            /* 1442 */       vo_4119_0List.add(vo_4119_0);
            /*      */     }
        /* 1444 */     Object list = new ArrayList();
        /* 1445 */     Chara chara1 = (Chara)charaList.get(0);
        /* 1446 */     for (int i = 0; i < chara1.listshouhu.size(); i++) {
            /* 1447 */       if (((org.linlinjava.litemall.gameserver.domain.ShouHuShuXing)((org.linlinjava.litemall.gameserver.domain.ShouHu)chara1.listshouhu.get(i)).listShouHuShuXing.get(0)).nil != 0) {
                /* 1448 */         org.linlinjava.litemall.gameserver.data.vo.Vo_45074_0 vo_45074_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45074_0();
                /* 1449 */         vo_45074_0.guardName = ((org.linlinjava.litemall.gameserver.domain.ShouHuShuXing)((org.linlinjava.litemall.gameserver.domain.ShouHu)chara1.listshouhu.get(i)).listShouHuShuXing.get(0)).str;
                /* 1450 */         vo_45074_0.guardLevel = chara1.level;
                /* 1451 */         vo_45074_0.guardIcon = ((org.linlinjava.litemall.gameserver.domain.ShouHuShuXing)((org.linlinjava.litemall.gameserver.domain.ShouHu)chara1.listshouhu.get(i)).listShouHuShuXing.get(0)).type;
                /* 1452 */         vo_45074_0.guardOrder = ((org.linlinjava.litemall.gameserver.domain.ShouHuShuXing)((org.linlinjava.litemall.gameserver.domain.ShouHu)chara1.listshouhu.get(i)).listShouHuShuXing.get(0)).salary;
                /* 1453 */         vo_45074_0.guardId = ((org.linlinjava.litemall.gameserver.domain.ShouHu)chara1.listshouhu.get(i)).id;
                /* 1454 */         ((List)list).add(vo_45074_0);
                /*      */       }
            /*      */     }
        /* 1457 */     for (Chara chara : charaList) {
            /* 1458 */       GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M45074_0(), list);
            /* 1459 */       GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M4119_0(), vo_4119_0List);
            /*      */     }
        /*      */   }
    /*      */
    /*      */
    /*      */
    /*      */   public static void huodecaifen(Chara chara, org.linlinjava.litemall.db.domain.StoreInfo wupin, int owner_id, int leve, int value, String name, Goods goods, int add_pet_exp)
    /*      */   {
        /* 1467 */     List<Goods> list = new ArrayList();
        /* 1468 */     goods.pos = beibaoweizhi(chara);
        /* 1469 */     goods.goodsInfo = new GoodsInfo();
        /* 1470 */     goods.goodsBasics = new org.linlinjava.litemall.gameserver.domain.GoodsBasics();
        /* 1471 */     goods.goodsDaoju(wupin);
        /* 1472 */     goods.goodsInfo.degree_32 = 0;
        /* 1473 */     goods.goodsInfo.owner_id = owner_id;
        /* 1474 */     goods.goodsInfo.damage_sel_rate = 400976;
        /* 1475 */     goods.goodsInfo.attrib = leve;
        /* 1476 */     goods.goodsInfo.skill = leve;
        /* 1477 */     goods.goodsInfo.total_score = 6;
        /* 1478 */     goods.goodsInfo.damage_sel_rate = 156945;
        /* 1479 */     goods.goodsInfo.auto_fight = java.util.UUID.randomUUID().toString();
        /* 1480 */     goods.goodsInfo.str = (goods.goodsInfo.str + "·" + name);
        /* 1481 */     goods.goodsInfo.value = 8388608;
        /* 1482 */     goods.goodsInfo.damage_sel_rate = 156945;
        /* 1483 */     goods.goodsInfo.rebuild_level = 0;
        /* 1484 */     goods.goodsInfo.recognize_recognized = 274096;
        /* 1485 */     goods.goodsInfo.add_pet_exp = add_pet_exp;
        /* 1486 */     goods.goodsInfo.durability = 8;
        /* 1487 */     chara.backpack.add(goods);
        /* 1488 */     list.add(goods);
        /* 1489 */     GameObjectChar.send(new MSG_INVENTORY(), list);
        /*      */   }
    /*      */
    /*      */   public static void removemunber(Chara chara, String str, int count) {
        /* 1493 */     List<Goods> list1 = new ArrayList();
        /* 1494 */     for (int i = 0; i < chara.backpack.size(); i++) {
            /* 1495 */       Goods goods = (Goods)chara.backpack.get(i);
            /* 1496 */       if (str.equals(goods.goodsInfo.str)) {
                /* 1497 */         if (goods.goodsInfo.owner_id >= count) {
                    /* 1498 */           goods.goodsInfo.owner_id -= count;
                    /* 1499 */           count = 0;
                    /*      */         } else {
                    /* 1501 */           count -= goods.goodsInfo.owner_id;
                    /* 1502 */           goods.goodsInfo.owner_id = 0;
                    /*      */         }
                /* 1504 */         if (goods.goodsInfo.owner_id == 0) {
                    /* 1505 */           list1.add(goods);
                    /*      */         }
                /* 1507 */         List<Goods> list = new ArrayList();
                /* 1508 */         list.add(chara.backpack.get(i));
                /* 1509 */         GameObjectChar.send(new MSG_INVENTORY(), list);
                /* 1510 */         if (count == 0) {
                    /*      */           break;
                    /*      */         }
                /*      */       }
            /*      */     }
        /* 1515 */     for (int i = 0; i < list1.size(); i++) {
            /* 1516 */       chara.backpack.remove(list1.get(i));
            /* 1517 */       GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
            /*      */     }
        /*      */   }
    /*      */
    /*      */   public static void removemunber(Chara chara, Goods goods1, int count) {
        /* 1522 */     List<Goods> list1 = new ArrayList();
        /* 1523 */     for (int i = 0; i < chara.backpack.size(); i++) {
            /* 1524 */       Goods goods = (Goods)chara.backpack.get(i);
            /* 1525 */       if (goods1 == goods) {
                /* 1526 */         if (goods.goodsInfo.owner_id >= count) {
                    /* 1527 */           goods.goodsInfo.owner_id -= count;
                    /* 1528 */           count = 0;
                    /*      */         } else {
                    /* 1530 */           count -= goods.goodsInfo.owner_id;
                    /* 1531 */           goods.goodsInfo.owner_id = 0;
                    /*      */         }
                /* 1533 */         if (goods.goodsInfo.owner_id == 0) {
                    /* 1534 */           list1.add(goods);
                    /*      */         }
                /* 1536 */         List<Goods> list = new ArrayList();
                /* 1537 */         list.add(chara.backpack.get(i));
                /* 1538 */         GameObjectChar.send(new MSG_INVENTORY(), list);
                /* 1539 */         GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
                /* 1540 */         if (count == 0) {
                    /*      */           break;
                    /*      */         }
                /*      */       }
            /*      */     }
        /* 1545 */     for (int i = 0; i < list1.size(); i++) {
            /* 1546 */       chara.backpack.remove(list1.get(i));
            /* 1547 */       GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
            /*      */     }
        /*      */   }
    /*      */
    /*      */   public static void huodedaoju(Chara chara, org.linlinjava.litemall.db.domain.StoreInfo wupin, int owner_id)
    /*      */   {
        /* 1553 */     List<Goods> list = new ArrayList();
        /* 1554 */     Goods goods = new Goods();
        /* 1555 */     goods.pos = beibaoweizhi(chara);
        /* 1556 */     goods.goodsInfo = new GoodsInfo();
        /* 1557 */     goods.goodsDaoju(wupin);
        /* 1558 */     goods.goodsInfo.owner_id = owner_id;
        /* 1559 */     goods.goodsInfo.damage_sel_rate = 400976;
        /* 1560 */     goods.goodsInfo.degree_32 = 1;
        /* 1561 */     addwupin(goods, chara);
        /*      */   }
    /*      */
    /*      */   public static void huodezhuangbei(Chara chara, ZhuangbeiInfo zhuangb, int degree_32, Goods goods) {
        /* 1565 */     goods.pos = beibaoweizhi(chara);
        /* 1566 */     goods.goodsInfo = new GoodsInfo();
        /* 1567 */     goods.goodsBasics = new org.linlinjava.litemall.gameserver.domain.GoodsBasics();
        /* 1568 */     goods.goodsLanSe = new GoodsLanSe();
        /* 1569 */     goods.goodsCreate(zhuangb);
        /* 1570 */     goods.goodsInfo.degree_32 = degree_32;
        /* 1571 */     chara.backpack.add(goods);
        /*      */
        /* 1573 */     GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
        /*      */   }
    /*      */
    /*      */   public static void huodezhuangbei(Chara chara, ZhuangbeiInfo zhuangb, int degree_32, int owner_id, GoodsLanSe goodsLanSe)
    /*      */   {
        /* 1578 */     Goods goods = new Goods();
        /* 1579 */     goods.pos = beibaoweizhi(chara);
        /* 1580 */     goods.goodsInfo = new GoodsInfo();
        /* 1581 */     goods.goodsBasics = new org.linlinjava.litemall.gameserver.domain.GoodsBasics();
        /* 1582 */     goods.goodsLanSe = goodsLanSe;
        /* 1583 */     goods.goodsCreate(zhuangb);
        /* 1584 */     goods.goodsInfo.owner_id = owner_id;
        /* 1585 */     goods.goodsInfo.degree_32 = degree_32;
        /* 1586 */     chara.backpack.add(goods);
        /*      */
        /* 1588 */     GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
        /*      */   }
    /*      */
    /*      */   public static void huodezhuangbeixiangwu(Chara chara, ZhuangbeiInfo zhuangb, int degree_32, int owner_id)
    /*      */   {
        /* 1593 */     Goods goods = new Goods();
        /* 1594 */     goods.pos = beibaoweizhi(chara);
        /* 1595 */     goods.goodsInfo = new GoodsInfo();
        /* 1596 */     goods.goodsBasics = new org.linlinjava.litemall.gameserver.domain.GoodsBasics();
        /* 1597 */     goods.goodsLanSe = new GoodsLanSe();
        /* 1598 */     goods.goodsCreate(zhuangb);
        /* 1599 */     goods.goodsInfo.owner_id = owner_id;
        /* 1600 */     goods.goodsInfo.degree_32 = degree_32;
        /* 1601 */     goods.goodsLanSe.all_resist_polar = 5;
        /* 1602 */     addwupin(goods, chara);
        /* 1603 */     GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
        /* 1604 */     org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0 vo_20481_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0();
        /* 1605 */     vo_20481_0.msg = ("获得#R" + goods.goodsInfo.str + "");
        /* 1606 */     vo_20481_0.time = 1562987118;
        /* 1607 */     GameObjectChar.getGameObjectChar();GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
        /*      */   }
    /*      */
    /*      */   public static void huodezhuangbei(Chara chara, ZhuangbeiInfo zhuangb, int degree_32, int owner_id) {
        /* 1611 */     Goods goods = new Goods();
        /* 1612 */     goods.pos = beibaoweizhi(chara);
        /* 1613 */     goods.goodsInfo = new GoodsInfo();
        /* 1614 */     goods.goodsBasics = new org.linlinjava.litemall.gameserver.domain.GoodsBasics();
        /* 1615 */     goods.goodsLanSe = new GoodsLanSe();
        /* 1616 */     goods.goodsCreate(zhuangb);
        /* 1617 */     goods.goodsInfo.owner_id = owner_id;
        /* 1618 */     goods.goodsInfo.degree_32 = degree_32;
        /* 1619 */     addwupin(goods, chara);
        /* 1620 */     GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
        /* 1621 */     org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0 vo_20481_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0();
        /* 1622 */     vo_20481_0.msg = ("获得#R" + goods.goodsInfo.str + "");
        /* 1623 */     vo_20481_0.time = 1562987118;
        /* 1624 */     GameObjectChar.getGameObjectChar();GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
        /*      */   }
    /*      */
    /*      */   public static void huodezhuangbei(Chara chara, ZhuangbeiInfo zhuangb, int degree_32) {
        /* 1628 */     Goods goods = new Goods();
        /* 1629 */     goods.pos = beibaoweizhi(chara);
        /* 1630 */     goods.goodsInfo = new GoodsInfo();
        /* 1631 */     goods.goodsBasics = new org.linlinjava.litemall.gameserver.domain.GoodsBasics();
        /* 1632 */     goods.goodsLanSe = new GoodsLanSe();
        /* 1633 */     goods.goodsCreate(zhuangb);
        /* 1634 */     goods.goodsInfo.degree_32 = degree_32;
        /* 1635 */     chara.backpack.add(goods);
        /*      */
        /* 1637 */     GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
        /*      */   }
    /*      */
    /*      */   public static int cangkuweizhi(Chara chara) {
        /* 1641 */     java.util.HashMap<Object, Object> map = new java.util.HashMap();
        /* 1642 */     for (int i = 0; i < chara.cangku.size(); i++) {
            /* 1643 */       map.put(Integer.valueOf(((Goods)chara.cangku.get(i)).pos), Integer.valueOf(((Goods)chara.cangku.get(i)).pos));
            /*      */     }
        /*      */
        /* 1646 */     int size = 50;
        /*      */
        /* 1648 */     if ((chara.vipType == 1) || (chara.vipType == 2)) {
            /* 1649 */       size += 25;
            /*      */     }
        /* 1651 */     if (chara.vipType == 3) {
            /* 1652 */       size += 50;
            /*      */     }
        /* 1654 */     int count = 201;
        /* 1655 */     for (int i = 0; i < size; i++) {
            /* 1656 */       if (map.get(Integer.valueOf(count)) == null) {
                /* 1657 */         return count;
                /*      */       }
            /* 1659 */       count++;
            /*      */     }
        /* 1661 */     return 0;
        /*      */   }
    /*      */
    /*      */   public static int beibaoweizhi(Chara chara) {
        /* 1665 */     java.util.HashMap<Object, Object> map = new java.util.HashMap();
        /* 1666 */     for (int i = 0; i < chara.backpack.size(); i++) {
            /* 1667 */       map.put(Integer.valueOf(((Goods)chara.backpack.get(i)).pos), Integer.valueOf(((Goods)chara.backpack.get(i)).pos));
            /*      */     }
        /* 1669 */     int size = 50;
        /* 1670 */     if (chara.zuoqiwaiguan != 0) {
            /* 1671 */       size += 25;
            /*      */     }
        /* 1673 */     if ((chara.vipType == 1) || (chara.vipType == 2)) {
            /* 1674 */       size += 25;
            /*      */     }
        /* 1676 */     if (chara.vipType == 3) {
            /* 1677 */       size += 50;
            /*      */     }
        /* 1679 */     int count = 41;
        /* 1680 */     for (int i = 0; i < size; i++) {
            /* 1681 */       if (map.get(Integer.valueOf(count)) == null) {
                /* 1682 */         return count;
                /*      */       }
            /* 1684 */       count++;
            /*      */     }
        /* 1686 */     return 0;
        /*      */   }
    /*      */
    /*      */
    /*      */   public static void zhuangbeiValue(Chara chara)
    /*      */   {
        /* 1692 */     chara.zbAttribute = new ZbAttribute();
        /* 1693 */     chara.zbAttribute.accurate = 0;
        /* 1694 */     chara.zbAttribute.def = 0;
        /* 1695 */     chara.zbAttribute.dex = 0;
        /* 1696 */     chara.zbAttribute.mana = 0;
        /* 1697 */     chara.zbAttribute.parry = 0;
        /* 1698 */     chara.zbAttribute.wiz = 0;
        /* 1699 */     int taozhuang = 0;
        /* 1700 */     int qianghua = 0;
        /* 1701 */     int dengji1 = 0;
        /* 1702 */     int dengji2 = 0;
        /* 1703 */     int dengji3 = 0;
        /* 1704 */     int dengji4 = 0;
        /*      */
        /*      */
        /* 1707 */     int tao1 = 0;
        /* 1708 */     int tao2 = 0;
        /* 1709 */     int tao3 = 0;
        /* 1710 */     int tao4 = 0;
        /* 1711 */     int color = 20;
        /* 1712 */     java.util.Map.Entry<Object, Object> entry; for (int i = 0; i < chara.backpack.size(); i++) {
            /* 1713 */       if ((((Goods)chara.backpack.get(i)).pos == 1) || (((Goods)chara.backpack.get(i)).pos == 2) || (((Goods)chara.backpack.get(i)).pos == 3) || (((Goods)chara.backpack.get(i)).pos == 10)) {
                /* 1714 */         java.util.Map<Object, Object> map = org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing.GoodsLvSeGongMing(((Goods)chara.backpack.get(i)).goodsLvSeGongMing);
                /* 1715 */         java.util.Iterator<java.util.Map.Entry<Object, Object>> it = map.entrySet().iterator();
                /* 1716 */         while (it.hasNext()) {
                    /* 1717 */           java.util.Map.Entry<Object, Object> next = (java.util.Map.Entry)it.next();
                    /* 1718 */           if (next.getValue().equals(Integer.valueOf(0))) {
                        /* 1719 */             it.remove();
                        /*      */           }
                    /*      */         }
                /*      */
                /* 1723 */         if (map.size() >= 3)
                    /*      */         {
                    /* 1725 */           taozhuang++;
                    /*      */         }
                /* 1727 */         map = org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing.GoodsGaiZaoGongMing(((Goods)chara.backpack.get(i)).goodsGaiZaoGongMing);
                /* 1728 */         it = map.entrySet().iterator();
                /* 1729 */         while (it.hasNext()) {
                    /* 1730 */           entry = (java.util.Map.Entry)it.next();
                    /* 1731 */           if (entry.getValue().equals(Integer.valueOf(0))) {
                        /* 1732 */             it.remove();
                        /*      */           }
                    /*      */         }
                /*      */
                /* 1736 */         if (map.size() >= 3) {
                    /* 1737 */           if (((Goods)chara.backpack.get(i)).goodsInfo.color < color) {
                        /* 1738 */             color = ((Goods)chara.backpack.get(i)).goodsInfo.color;
                        /*      */           }
                    /* 1740 */           qianghua++;
                    /*      */         }
                /* 1742 */         if (((Goods)chara.backpack.get(i)).pos == 1) {
                    /* 1743 */           dengji1 = ((Goods)chara.backpack.get(i)).goodsInfo.attrib;
                    /* 1744 */           tao1 = ((Goods)chara.backpack.get(i)).goodsInfo.suit_enabled;
                    /*      */         }
                /* 1746 */         if (((Goods)chara.backpack.get(i)).pos == 2) {
                    /* 1747 */           dengji2 = ((Goods)chara.backpack.get(i)).goodsInfo.attrib;
                    /* 1748 */           tao2 = ((Goods)chara.backpack.get(i)).goodsInfo.suit_enabled;
                    /*      */         }
                /* 1750 */         if (((Goods)chara.backpack.get(i)).pos == 3) {
                    /* 1751 */           dengji3 = ((Goods)chara.backpack.get(i)).goodsInfo.attrib;
                    /* 1752 */           tao3 = ((Goods)chara.backpack.get(i)).goodsInfo.suit_enabled;
                    /*      */         }
                /* 1754 */         if (((Goods)chara.backpack.get(i)).pos == 10) {
                    /* 1755 */           dengji4 = ((Goods)chara.backpack.get(i)).goodsInfo.attrib;
                    /* 1756 */           tao4 = ((Goods)chara.backpack.get(i)).goodsInfo.suit_enabled;
                    /*      */         }
                /*      */       }
            /*      */     }
        /*      */
        /* 1761 */     if ((taozhuang == 4) && (dengji1 == dengji2) && (dengji2 == dengji3) && (dengji3 == dengji4) && (tao1 == tao2) && (tao2 == tao3) && (tao3 == tao4)) {
            /* 1762 */       int[] suit = org.linlinjava.litemall.gameserver.data.game.SuitEffectUtils.suit(chara.sex - 1, dengji4, chara.menpai, tao1);
            /* 1763 */       chara.suit_icon = suit[0];
            /* 1764 */       chara.suit_light_effect = suit[1];
            /* 1765 */       for (int i = 0; i < chara.backpack.size(); i++) {
                /* 1766 */         if ((((Goods)chara.backpack.get(i)).pos == 1) || (((Goods)chara.backpack.get(i)).pos == 2) || (((Goods)chara.backpack.get(i)).pos == 3) || (((Goods)chara.backpack.get(i)).pos == 10)) {
                    /* 1767 */           ((Goods)chara.backpack.get(i)).goodsInfo.gift = 1;
                    /*      */         }
                /*      */       }
            /*      */     } else {
            /* 1771 */       chara.suit_icon = 0;
            /* 1772 */       chara.suit_light_effect = 0;
            /* 1773 */       for (int i = 0; i < chara.backpack.size(); i++) {
                /* 1774 */         if ((((Goods)chara.backpack.get(i)).pos == 1) || (((Goods)chara.backpack.get(i)).pos == 2) || (((Goods)chara.backpack.get(i)).pos == 3) || (((Goods)chara.backpack.get(i)).pos == 10)) {
                    /* 1775 */           ((Goods)chara.backpack.get(i)).goodsInfo.gift = 0;
                    /*      */         }
                /*      */       }
            /*      */     }
        /* 1779 */     if ((qianghua == 4) && (dengji1 == dengji2) && (dengji2 == dengji3) && (dengji3 == dengji4)) {
            /* 1780 */       for (int i = 0; i < chara.backpack.size(); i++) {
                /* 1781 */         if ((((Goods)chara.backpack.get(i)).pos == 1) || (((Goods)chara.backpack.get(i)).pos == 2) || (((Goods)chara.backpack.get(i)).pos == 3) || (((Goods)chara.backpack.get(i)).pos == 10)) {
                    /* 1782 */           java.util.Map<Object, Object> map = org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing.GoodsGaiZaoGongMing(((Goods)chara.backpack.get(i)).goodsGaiZaoGongMing);
                    /* 1783 */           ((Goods)chara.backpack.get(i)).goodsGaiZaoGongMingChengGong = ((GoodsGaiZaoGongMingChengGong)org.linlinjava.litemall.db.util.JSONUtils.parseObject(org.linlinjava.litemall.db.util.JSONUtils.toJSONString(map), GoodsGaiZaoGongMingChengGong.class));
                    /* 1784 */           ((Goods)chara.backpack.get(i)).goodsGaiZaoGongMingChengGong.groupNo = 29;
                    /* 1785 */           ((Goods)chara.backpack.get(i)).goodsGaiZaoGongMingChengGong.color = color;
                    /*      */         }
                /*      */       }
            /*      */     } else {
            /* 1789 */       for (int i = 0; i < chara.backpack.size(); i++) {
                /* 1790 */         ((Goods)chara.backpack.get(i)).goodsGaiZaoGongMingChengGong = new GoodsGaiZaoGongMingChengGong();
                /*      */       }
            /*      */     }
        /* 1793 */     GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
        /* 1794 */     for (int i = 0; i < chara.backpack.size(); i++) {
            /* 1795 */       Goods good = (Goods)chara.backpack.get(i);
            /* 1796 */       if (good.goodsFenSe != null)
                /*      */       {
                /* 1798 */         java.util.Map<Object, Object> goodsfense = org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing.GoodsFenSe(good.goodsFenSe);
                /* 1799 */         for (java.util.Map.Entry<Object, Object> objectObjectEntry : goodsfense.entrySet()) {
                    /* 1800 */           if ((!objectObjectEntry.getKey().equals("groupNo")) && (!objectObjectEntry.getKey().equals("groupType")))
                        /*      */           {
                        /*      */
                        /* 1803 */             if (((Integer)objectObjectEntry.getValue()).intValue() != 0)
                            /* 1804 */               good.goodsInfo.quality = "粉色";
                        /*      */           }
                    /*      */         }
                /*      */       }
            /* 1808 */       if (good.goodsHuangSe != null) {
                /* 1809 */         java.util.Map<Object, Object> goodshuangse = org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing.GoodsHuangSe(good.goodsHuangSe);
                /* 1810 */         for (java.util.Map.Entry<Object, Object> objectObjectEntry : goodshuangse.entrySet()) {
                    /* 1811 */           if ((!objectObjectEntry.getKey().equals("groupNo")) && (!objectObjectEntry.getKey().equals("groupType")))
                        /*      */           {
                        /*      */
                        /* 1814 */             if (((Integer)objectObjectEntry.getValue()).intValue() != 0) {
                            /* 1815 */               good.goodsInfo.quality = "金色";
                            /*      */             }
                        /*      */           }
                    /*      */         }
                /*      */       }
            /* 1820 */       if (good.goodsLvSe != null) {
                /* 1821 */         java.util.Map<Object, Object> goodslvse = org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing.GoodsLvSe(good.goodsLvSe);
                /* 1822 */         for (java.util.Map.Entry<Object, Object> objectObjectEntry : goodslvse.entrySet()) {
                    /* 1823 */           if ((!objectObjectEntry.getKey().equals("groupNo")) && (!objectObjectEntry.getKey().equals("groupType")))
                        /*      */           {
                        /*      */
                        /* 1826 */             if (((Integer)objectObjectEntry.getValue()).intValue() != 0)
                            /* 1827 */               good.goodsInfo.quality = "绿色";
                        /*      */           }
                    /*      */         }
                /*      */       }
            /* 1831 */       if ((good.pos <= 10) && (good.pos > 0)) {
                /* 1832 */         chara.zbAttribute.accurate += good.goodsBasics.accurate;
                /* 1833 */         chara.zbAttribute.def += good.goodsBasics.def;
                /* 1834 */         chara.zbAttribute.dex += good.goodsBasics.dex;
                /* 1835 */         chara.zbAttribute.mana += good.goodsBasics.mana;
                /* 1836 */         chara.zbAttribute.parry += good.goodsBasics.parry;
                /* 1837 */         chara.zbAttribute.wiz += good.goodsBasics.wiz;
                /*      */
                /* 1839 */         chara.zbAttribute.phy_power = (chara.zbAttribute.phy_power + good.goodsLanSe.phy_power + good.goodsLanSe.all_polar);
                /*      */         //System.out.println(good.goodsLanSe.phy_power+" "+good.goodsLanSe.mag_power+" "+good.goodsFenSe.mag_power+" "+good.goodsHuangSe.mag_power+"  "+good.goodsFenSe.skill_low_cost+"  "+good.goodsLanSe.skill_low_cost+"  "+good.goodsHuangSe.skill_low_cost+"    skill_low_cost |||||");
                /* 1841 */         chara.zbAttribute.mag_power = (chara.zbAttribute.mag_power + good.goodsLanSe.mag_power + good.goodsLanSe.all_polar);
                /*      */
                /* 1843 */         chara.zbAttribute.speed = (chara.zbAttribute.speed + good.goodsLanSe.speed + good.goodsLanSe.all_polar);
                /*      */
                /* 1845 */         chara.zbAttribute.life = (chara.zbAttribute.life + good.goodsLanSe.life + good.goodsLanSe.all_polar);
                /*      */
                /* 1847 */         chara.zbAttribute.skill_low_cost += good.goodsLanSe.skill_low_cost;
                /*      */
                /* 1849 */         chara.zbAttribute.mstunt_rate += good.goodsLanSe.mstunt_rate;
                /*      */
                /* 1851 */         chara.zbAttribute.wood = (chara.zbAttribute.wood + good.goodsLanSe.wood + good.goodsLanSe.all_resist_polar);
                /*      */
                /* 1853 */         chara.zbAttribute.water = (chara.zbAttribute.water + good.goodsLanSe.water + good.goodsLanSe.all_resist_polar);
                /*      */
                /* 1855 */         chara.zbAttribute.fire = (chara.zbAttribute.fire + good.goodsLanSe.fire + good.goodsLanSe.all_resist_polar);
                /*      */
                /* 1857 */         chara.zbAttribute.earth = (chara.zbAttribute.earth + good.goodsLanSe.earth + good.goodsLanSe.all_resist_polar);
                /*      */
                /* 1859 */         chara.zbAttribute.resist_metal = (chara.zbAttribute.resist_metal + good.goodsLanSe.resist_metal + good.goodsLanSe.all_resist_polar);
                /*      */
                /*      */
                /*      */
                /* 1863 */         chara.zbAttribute.damage_sel += good.goodsLanSe.damage_sel;
                /*      */
                /* 1865 */         chara.zbAttribute.stunt_rate += good.goodsLanSe.stunt_rate;
                /*      */
                /* 1867 */         chara.zbAttribute.double_hit_rate += good.goodsLanSe.double_hit_rate;
                /*      */
                /* 1869 */         chara.zbAttribute.release_forgotten += good.goodsLanSe.release_forgotten;
                /*      */
                /* 1871 */         chara.zbAttribute.ignore_all_resist_except += good.goodsLanSe.ignore_all_resist_except;
                /*      */
                /* 1873 */         chara.zbAttribute.stunt += good.goodsLanSe.stunt;
                /*      */
                /* 1875 */         chara.zbAttribute.def += good.goodsLanSe.def;
                /*      */
                /* 1877 */         chara.zbAttribute.dex += good.goodsLanSe.dex;
                /*      */
                /* 1879 */         chara.zbAttribute.wiz += good.goodsLanSe.wiz;
                /*      */
                /* 1881 */         chara.zbAttribute.family += good.goodsLanSe.family;
                /*      */
                /* 1883 */         chara.zbAttribute.life_recover += good.goodsLanSe.life_recover;
                /*      */
                /* 1885 */         chara.zbAttribute.all_skill += good.goodsLanSe.all_skill;
                /*      */
                /* 1887 */         chara.zbAttribute.portrait += good.goodsLanSe.portrait;
                /*      */
                /* 1889 */         chara.zbAttribute.resist_frozen += good.goodsLanSe.resist_frozen;
                /*      */
                /* 1891 */         chara.zbAttribute.resist_sleep += good.goodsLanSe.resist_sleep;
                /*      */
                /* 1893 */         chara.zbAttribute.resist_forgotten += good.goodsLanSe.resist_forgotten;
                /*      */
                /* 1895 */         chara.zbAttribute.resist_confusion += good.goodsLanSe.resist_confusion;
                /*      */
                /* 1897 */         chara.zbAttribute.longevity += good.goodsLanSe.longevity;
                /*      */
                /* 1899 */         chara.zbAttribute.resist_wood += good.goodsLanSe.resist_wood;
                /*      */
                /* 1901 */         chara.zbAttribute.resist_water += good.goodsLanSe.resist_water;
                /*      */
                /* 1903 */         chara.zbAttribute.resist_fire += good.goodsLanSe.resist_fire;
                /*      */
                /* 1905 */         chara.zbAttribute.resist_earth += good.goodsLanSe.resist_earth;
                /*      */
                /* 1907 */         chara.zbAttribute.exp_to_next_level += good.goodsLanSe.exp_to_next_level;
                /*      */
                /* 1909 */         chara.zbAttribute.all_resist_except += good.goodsLanSe.all_resist_except;
                /*      */
                /* 1911 */         chara.zbAttribute.accurate += good.goodsLanSe.accurate +good.goodsLanSe.skill_low_cost;
                /*      */
                /* 1913 */         chara.zbAttribute.mana += good.goodsLanSe.mana+good.goodsLanSe.skill_low_cost;
                /*      */
                /* 1915 */         chara.zbAttribute.parry += good.goodsLanSe.parry;
                /*      */
                /*      */
                /* 1918 */         chara.zbAttribute.ignore_resist_wood += good.goodsLanSe.ignore_resist_wood;
                /*      */
                /* 1920 */         chara.zbAttribute.ignore_resist_water += good.goodsLanSe.ignore_resist_water;
                /*      */
                /* 1922 */         chara.zbAttribute.ignore_resist_fire += good.goodsLanSe.ignore_resist_fire;
                /*      */
                /* 1924 */         chara.zbAttribute.ignore_resist_earth += good.goodsLanSe.ignore_resist_earth;
                /*      */
                /* 1926 */         chara.zbAttribute.ignore_resist_forgotten += good.goodsLanSe.ignore_resist_forgotten;
                /*      */
                /* 1928 */         chara.zbAttribute.ignore_resist_frozen += good.goodsLanSe.ignore_resist_frozen;
                /*      */
                /* 1930 */         chara.zbAttribute.ignore_resist_sleep += good.goodsLanSe.ignore_resist_sleep;
                /*      */
                /* 1932 */         chara.zbAttribute.ignore_resist_confusion += good.goodsLanSe.ignore_resist_confusion;
                /*      */
                /* 1934 */         chara.zbAttribute.super_excluse_metal += good.goodsLanSe.super_excluse_metal;
                /*      */
                /* 1936 */         chara.zbAttribute.ignore_resist_poison += good.goodsLanSe.ignore_resist_poison;
                /*      */
                /*      */
                /*      */
                /* 1940 */         chara.zbAttribute.phy_power = (chara.zbAttribute.phy_power + good.goodsHuangSe.phy_power + good.goodsHuangSe.all_polar);
                /*      */
                /* 1942 */         chara.zbAttribute.mag_power = (chara.zbAttribute.mag_power + good.goodsHuangSe.mag_power + good.goodsHuangSe.all_polar);
                /*      */
                /* 1944 */         chara.zbAttribute.speed = (chara.zbAttribute.speed + good.goodsHuangSe.speed + good.goodsHuangSe.all_polar);
                /*      */
                /* 1946 */         chara.zbAttribute.life = (chara.zbAttribute.life + good.goodsHuangSe.life + good.goodsHuangSe.all_polar);
                /*      */
                /* 1948 */         chara.zbAttribute.skill_low_cost += good.goodsHuangSe.skill_low_cost;
                /*      */
                /* 1950 */         chara.zbAttribute.mstunt_rate += good.goodsHuangSe.mstunt_rate;
                /*      */
                /* 1952 */         chara.zbAttribute.wood = (chara.zbAttribute.wood + good.goodsHuangSe.wood + good.goodsHuangSe.all_resist_polar);
                /*      */
                /* 1954 */         chara.zbAttribute.water = (chara.zbAttribute.water + good.goodsHuangSe.water + good.goodsHuangSe.all_resist_polar);
                /*      */
                /* 1956 */         chara.zbAttribute.fire = (chara.zbAttribute.fire + good.goodsHuangSe.fire + good.goodsHuangSe.all_resist_polar);
                /*      */
                /* 1958 */         chara.zbAttribute.earth = (chara.zbAttribute.earth + good.goodsHuangSe.earth + good.goodsHuangSe.all_resist_polar);
                /*      */
                /* 1960 */         chara.zbAttribute.resist_metal = (chara.zbAttribute.resist_metal + good.goodsHuangSe.resist_metal + good.goodsHuangSe.all_resist_polar);
                /*      */
                /*      */
                /*      */
                /* 1964 */         chara.zbAttribute.damage_sel += good.goodsHuangSe.damage_sel;
                /*      */
                /* 1966 */         chara.zbAttribute.stunt_rate += good.goodsHuangSe.stunt_rate;
                /*      */
                /* 1968 */         chara.zbAttribute.double_hit_rate += good.goodsHuangSe.double_hit_rate;
                /*      */
                /* 1970 */         chara.zbAttribute.release_forgotten += good.goodsHuangSe.release_forgotten;
                /*      */
                /* 1972 */         chara.zbAttribute.ignore_all_resist_except += good.goodsHuangSe.ignore_all_resist_except;
                /*      */
                /* 1974 */         chara.zbAttribute.stunt += good.goodsHuangSe.stunt;
                /*      */
                /* 1976 */         chara.zbAttribute.def += good.goodsHuangSe.def;
                /*      */
                /* 1978 */         chara.zbAttribute.dex += good.goodsHuangSe.dex;
                /*      */
                /* 1980 */         chara.zbAttribute.wiz += good.goodsHuangSe.wiz;
                /*      */
                /* 1982 */         chara.zbAttribute.family += good.goodsHuangSe.family;
                /*      */
                /* 1984 */         chara.zbAttribute.life_recover += good.goodsHuangSe.life_recover;
                /*      */
                /* 1986 */         chara.zbAttribute.all_skill += good.goodsHuangSe.all_skill;
                /*      */
                /* 1988 */         chara.zbAttribute.portrait += good.goodsHuangSe.portrait;
                /*      */
                /* 1990 */         chara.zbAttribute.resist_frozen += good.goodsHuangSe.resist_frozen;
                /*      */
                /* 1992 */         chara.zbAttribute.resist_sleep += good.goodsHuangSe.resist_sleep;
                /*      */
                /* 1994 */         chara.zbAttribute.resist_forgotten += good.goodsHuangSe.resist_forgotten;
                /*      */
                /* 1996 */         chara.zbAttribute.resist_confusion += good.goodsHuangSe.resist_confusion;
                /*      */
                /* 1998 */         chara.zbAttribute.longevity += good.goodsHuangSe.longevity;
                /*      */
                /* 2000 */         chara.zbAttribute.resist_wood += good.goodsHuangSe.resist_wood;
                /*      */
                /* 2002 */         chara.zbAttribute.resist_water += good.goodsHuangSe.resist_water;
                /*      */
                /* 2004 */         chara.zbAttribute.resist_fire += good.goodsHuangSe.resist_fire;
                /*      */
                /* 2006 */         chara.zbAttribute.resist_earth += good.goodsHuangSe.resist_earth;
                /*      */
                /* 2008 */         chara.zbAttribute.exp_to_next_level += good.goodsHuangSe.exp_to_next_level;
                /*      */
                /* 2010 */         chara.zbAttribute.all_resist_except += good.goodsHuangSe.all_resist_except;
                /*      */
                /* 2012 */         chara.zbAttribute.accurate += good.goodsHuangSe.accurate + good.goodsHuangSe.skill_low_cost;
                /*      */
                /* 2014 */         chara.zbAttribute.mana += good.goodsHuangSe.mana+ good.goodsHuangSe.skill_low_cost;
                /*      */
                /* 2016 */         chara.zbAttribute.parry += good.goodsHuangSe.parry;
                /*      */
                /*      */
                /* 2019 */         chara.zbAttribute.ignore_resist_wood += good.goodsHuangSe.ignore_resist_wood;
                /*      */
                /* 2021 */         chara.zbAttribute.ignore_resist_water += good.goodsHuangSe.ignore_resist_water;
                /*      */
                /* 2023 */         chara.zbAttribute.ignore_resist_fire += good.goodsHuangSe.ignore_resist_fire;
                /*      */
                /* 2025 */         chara.zbAttribute.ignore_resist_earth += good.goodsHuangSe.ignore_resist_earth;
                /*      */
                /* 2027 */         chara.zbAttribute.ignore_resist_forgotten += good.goodsHuangSe.ignore_resist_forgotten;
                /*      */
                /* 2029 */         chara.zbAttribute.ignore_resist_frozen += good.goodsHuangSe.ignore_resist_frozen;
                /*      */
                /* 2031 */         chara.zbAttribute.ignore_resist_sleep += good.goodsHuangSe.ignore_resist_sleep;
                /*      */
                /* 2033 */         chara.zbAttribute.ignore_resist_confusion += good.goodsHuangSe.ignore_resist_confusion;
                /*      */
                /* 2035 */         chara.zbAttribute.super_excluse_metal += good.goodsHuangSe.super_excluse_metal;
                /*      */
                /* 2037 */         chara.zbAttribute.ignore_resist_poison += good.goodsHuangSe.ignore_resist_poison;
                /*      */
                /*      */
                /*      */
                /* 2041 */         chara.zbAttribute.phy_power = (chara.zbAttribute.phy_power + good.goodsFenSe.phy_power + good.goodsFenSe.all_polar);
                /*      */
                /* 2043 */         chara.zbAttribute.mag_power = (chara.zbAttribute.mag_power + good.goodsFenSe.mag_power + good.goodsFenSe.all_polar);
                /*      */
                /* 2045 */         chara.zbAttribute.speed = (chara.zbAttribute.speed + good.goodsFenSe.speed + good.goodsFenSe.all_polar);
                /*      */
                /* 2047 */         chara.zbAttribute.life = (chara.zbAttribute.life + good.goodsFenSe.life + good.goodsFenSe.all_polar);
                /*      */
                /* 2049 */         chara.zbAttribute.skill_low_cost += good.goodsFenSe.skill_low_cost;
                /*      */
                /* 2051 */         chara.zbAttribute.mstunt_rate += good.goodsFenSe.mstunt_rate;
                /*      */
                /* 2053 */         chara.zbAttribute.wood = (chara.zbAttribute.wood + good.goodsFenSe.wood + good.goodsFenSe.all_resist_polar);
                /*      */
                /* 2055 */         chara.zbAttribute.water = (chara.zbAttribute.water + good.goodsFenSe.water + good.goodsFenSe.all_resist_polar);
                /*      */
                /* 2057 */         chara.zbAttribute.fire = (chara.zbAttribute.fire + good.goodsFenSe.fire + good.goodsFenSe.all_resist_polar);
                /*      */
                /* 2059 */         chara.zbAttribute.earth = (chara.zbAttribute.earth + good.goodsFenSe.earth + good.goodsFenSe.all_resist_polar);
                /*      */
                /* 2061 */         chara.zbAttribute.resist_metal = (chara.zbAttribute.resist_metal + good.goodsFenSe.resist_metal + good.goodsFenSe.all_resist_polar);
                /*      */
                /*      */
                /*      */
                /* 2065 */         chara.zbAttribute.damage_sel += good.goodsFenSe.damage_sel;
                /*      */
                /* 2067 */         chara.zbAttribute.stunt_rate += good.goodsFenSe.stunt_rate;
                /*      */
                /* 2069 */         chara.zbAttribute.double_hit_rate += good.goodsFenSe.double_hit_rate;
                /*      */
                /* 2071 */         chara.zbAttribute.release_forgotten += good.goodsFenSe.release_forgotten;
                /*      */
                /* 2073 */         chara.zbAttribute.ignore_all_resist_except += good.goodsFenSe.ignore_all_resist_except;
                /*      */
                /* 2075 */         chara.zbAttribute.stunt += good.goodsFenSe.stunt;
                /*      */
                /* 2077 */         chara.zbAttribute.def += good.goodsFenSe.def;
                /*      */
                /* 2079 */         chara.zbAttribute.dex += good.goodsFenSe.dex;
                /*      */
                /* 2081 */         chara.zbAttribute.wiz += good.goodsFenSe.wiz;
                /*      */
                /* 2083 */         chara.zbAttribute.family += good.goodsFenSe.family;
                /*      */
                /* 2085 */         chara.zbAttribute.life_recover += good.goodsFenSe.life_recover;
                /*      */
                /* 2087 */         chara.zbAttribute.all_skill += good.goodsFenSe.all_skill;
                /*      */
                /* 2089 */         chara.zbAttribute.portrait += good.goodsFenSe.portrait;
                /*      */
                /* 2091 */         chara.zbAttribute.resist_frozen += good.goodsFenSe.resist_frozen;
                /*      */
                /* 2093 */         chara.zbAttribute.resist_sleep += good.goodsFenSe.resist_sleep;
                /*      */
                /* 2095 */         chara.zbAttribute.resist_forgotten += good.goodsFenSe.resist_forgotten;
                /*      */
                /* 2097 */         chara.zbAttribute.resist_confusion += good.goodsFenSe.resist_confusion;
                /*      */
                /* 2099 */         chara.zbAttribute.longevity += good.goodsFenSe.longevity;
                /*      */
                /* 2101 */         chara.zbAttribute.resist_wood += good.goodsFenSe.resist_wood;
                /*      */
                /* 2103 */         chara.zbAttribute.resist_water += good.goodsFenSe.resist_water;
                /*      */
                /* 2105 */         chara.zbAttribute.resist_fire += good.goodsFenSe.resist_fire;
                /*      */
                /* 2107 */         chara.zbAttribute.resist_earth += good.goodsFenSe.resist_earth;
                /*      */
                /* 2109 */         chara.zbAttribute.exp_to_next_level += good.goodsFenSe.exp_to_next_level;
                /*      */
                /* 2111 */         chara.zbAttribute.all_resist_except += good.goodsFenSe.all_resist_except;
                /*      */
                /* 2113 */         chara.zbAttribute.accurate += good.goodsFenSe.accurate + good.goodsFenSe.skill_low_cost;
                /*      */
                /* 2115 */         chara.zbAttribute.mana += good.goodsFenSe.mana+ good.goodsFenSe.skill_low_cost;
                /*      */
                /* 2117 */         chara.zbAttribute.parry += good.goodsFenSe.parry;
                /*      */
                /*      */
                /* 2120 */         chara.zbAttribute.ignore_resist_wood += good.goodsFenSe.ignore_resist_wood;
                /*      */
                /* 2122 */         chara.zbAttribute.ignore_resist_water += good.goodsFenSe.ignore_resist_water;
                /*      */
                /* 2124 */         chara.zbAttribute.ignore_resist_fire += good.goodsFenSe.ignore_resist_fire;
                /*      */
                /* 2126 */         chara.zbAttribute.ignore_resist_earth += good.goodsFenSe.ignore_resist_earth;
                /*      */
                /* 2128 */         chara.zbAttribute.ignore_resist_forgotten += good.goodsFenSe.ignore_resist_forgotten;
                /*      */
                /* 2130 */         chara.zbAttribute.ignore_resist_frozen += good.goodsFenSe.ignore_resist_frozen;
                /*      */
                /* 2132 */         chara.zbAttribute.ignore_resist_sleep += good.goodsFenSe.ignore_resist_sleep;
                /*      */
                /* 2134 */         chara.zbAttribute.ignore_resist_confusion += good.goodsFenSe.ignore_resist_confusion;
                /*      */
                /* 2136 */         chara.zbAttribute.super_excluse_metal += good.goodsFenSe.super_excluse_metal;
                /*      */
                /* 2138 */         chara.zbAttribute.ignore_resist_poison += good.goodsFenSe.ignore_resist_poison;
                /*      */
                /*      */
                /*      */
                /* 2142 */         chara.zbAttribute.accurate += good.goodsLvSe.accurate;
                /*      */
                /* 2144 */         chara.zbAttribute.resist_frozen += good.goodsLvSe.resist_frozen;
                /*      */
                /* 2146 */         chara.zbAttribute.resist_sleep += good.goodsLvSe.resist_sleep;
                /*      */
                /* 2148 */         chara.zbAttribute.resist_forgotten += good.goodsLvSe.resist_forgotten;
                /*      */
                /* 2150 */         chara.zbAttribute.resist_confusion += good.goodsLvSe.resist_confusion;
                /*      */
                /* 2152 */         chara.zbAttribute.longevity += good.goodsLvSe.longevity;
                /* 2153 */         chara.zbAttribute.super_excluse_wood += good.goodsLvSe.super_excluse_wood;
                /*      */
                /* 2155 */         chara.zbAttribute.super_excluse_water += good.goodsLvSe.super_excluse_water;
                /*      */
                /* 2157 */         chara.zbAttribute.super_excluse_fire += good.goodsLvSe.super_excluse_fire;
                /*      */
                /* 2159 */         chara.zbAttribute.super_excluse_earth += good.goodsLvSe.super_excluse_earth;
                /*      */
                /* 2161 */         chara.zbAttribute.B_skill_low_cost += good.goodsLvSe.B_skill_low_cost;
                /*      */
                /* 2163 */         chara.zbAttribute.enhanced_wood += good.goodsLvSe.enhanced_wood;
                /*      */
                /* 2165 */         chara.zbAttribute.enhanced_water += good.goodsLvSe.enhanced_water;
                /*      */
                /* 2167 */         chara.zbAttribute.enhanced_fire += good.goodsLvSe.enhanced_fire;
                /*      */
                /* 2169 */         chara.zbAttribute.enhanced_earth += good.goodsLvSe.enhanced_earth;
                /*      */
                /* 2171 */         chara.zbAttribute.mag_dodge += good.goodsLvSe.mag_dodge;
                /*      */
                /* 2173 */         chara.zbAttribute.ignore_mag_dodge += good.goodsLvSe.ignore_mag_dodge;
                /*      */
                /* 2175 */         chara.zbAttribute.jinguang_zhaxian_counter_att_rate += good.goodsLvSe.jinguang_zhaxian_counter_att_rate;
                /*      */
                /* 2177 */         chara.zbAttribute.C_skill_low_cost += good.goodsLvSe.C_skill_low_cost;
                /*      */
                /* 2179 */         chara.zbAttribute.D_skill_low_cost += good.goodsLvSe.D_skill_low_cost;
                /*      */
                /* 2181 */         chara.zbAttribute.super_poison += good.goodsLvSe.super_poison;
                /*      */
                /* 2183 */         chara.zbAttribute.ignore_resist_wood += good.goodsLvSe.ignore_resist_wood;
                /*      */
                /* 2185 */         chara.zbAttribute.ignore_resist_water += good.goodsLvSe.ignore_resist_water;
                /*      */
                /* 2187 */         chara.zbAttribute.ignore_resist_fire += good.goodsLvSe.ignore_resist_fire;
                /*      */
                /* 2189 */         chara.zbAttribute.ignore_resist_earth += good.goodsLvSe.ignore_resist_earth;
                /*      */
                /* 2191 */         chara.zbAttribute.ignore_resist_forgotten += good.goodsLvSe.ignore_resist_forgotten;
                /*      */
                /* 2193 */         chara.zbAttribute.release_forgotten += good.goodsLvSe.release_forgotten;
                /*      */
                /* 2195 */         chara.zbAttribute.ignore_all_resist_except += good.goodsLvSe.ignore_all_resist_except;
                /*      */
                /* 2197 */         chara.zbAttribute.super_confusion += good.goodsLvSe.super_confusion;
                /*      */
                /* 2199 */         chara.zbAttribute.super_sleep += good.goodsLvSe.super_sleep;
                /*      */
                /* 2201 */         chara.zbAttribute.enhanced_metal += good.goodsLvSe.enhanced_metal;
                /*      */
                /* 2203 */         chara.zbAttribute.super_forgotten += good.goodsLvSe.super_forgotten;
                /* 2204 */         chara.zbAttribute.super_frozen += good.goodsLvSe.super_frozen;
                /*      */
                /* 2206 */         chara.zbAttribute.ignore_resist_frozen += good.goodsLvSe.ignore_resist_frozen;
                /*      */
                /* 2208 */         chara.zbAttribute.ignore_resist_sleep += good.goodsLvSe.ignore_resist_sleep;
                /*      */
                /* 2210 */         chara.zbAttribute.ignore_resist_confusion += good.goodsLvSe.ignore_resist_confusion;
                /*      */
                /* 2212 */         chara.zbAttribute.super_excluse_metal += good.goodsLvSe.super_excluse_metal;
                /*      */
                /* 2214 */         chara.zbAttribute.ignore_resist_poison += good.goodsLvSe.ignore_resist_poison;
                /*      */
                /* 2216 */         chara.zbAttribute.tao_ex += good.goodsLvSe.tao_ex;
                /*      */
                /* 2218 */         chara.zbAttribute.release_confusion += good.goodsLvSe.release_confusion;
                /* 2219 */         chara.zbAttribute.release_sleep += good.goodsLvSe.release_sleep;
                /*      */
                /* 2221 */         chara.zbAttribute.release_frozen += good.goodsLvSe.release_frozen;
                /*      */
                /* 2223 */         chara.zbAttribute.release_poison += good.goodsLvSe.release_poison;
                /*      */
                /*      */
                /*      */
                /* 2227 */         chara.zbAttribute.accurate += good.goodsGaiZao.accurate;
                /*      */
                /* 2229 */         chara.zbAttribute.wiz += good.goodsGaiZao.wiz;
                /*      */
                /* 2231 */         chara.zbAttribute.def += good.goodsGaiZao.def;
                /*      */
                /* 2233 */         chara.zbAttribute.mana += good.goodsGaiZao.mana;
                /*      */
                /*      */
                /* 2236 */         chara.zbAttribute.phy_power += good.goodsGaiZao.all_polar;
                /*      */
                /* 2238 */         chara.zbAttribute.mag_power += good.goodsGaiZao.all_polar;
                /*      */
                /* 2240 */         chara.zbAttribute.speed += good.goodsGaiZao.all_polar;
                /*      */
                /* 2242 */         chara.zbAttribute.life += good.goodsGaiZao.all_polar;
                /*      */
                /*      */
                /*      */
                /*      */
                /* 2247 */         chara.zbAttribute.damage_sel += good.goodsGaiZaoGongMingChengGong.damage_sel;
                /*      */
                /* 2249 */         chara.zbAttribute.accurate += good.goodsGaiZaoGongMingChengGong.accurate;
                /*      */
                /* 2251 */         chara.zbAttribute.mana += good.goodsGaiZaoGongMingChengGong.mana;
                /*      */
                /* 2253 */         chara.zbAttribute.def += good.goodsGaiZaoGongMingChengGong.def;
                /*      */
                /* 2255 */         chara.zbAttribute.wiz += good.goodsGaiZaoGongMingChengGong.wiz;
                /*      */
                /* 2257 */         chara.zbAttribute.parry += good.goodsGaiZaoGongMingChengGong.parry;
                /*      */
                /* 2259 */         chara.zbAttribute.phy_power += good.goodsGaiZaoGongMingChengGong.phy_power;
                /*      */
                /* 2261 */         chara.zbAttribute.mag_power += good.goodsGaiZaoGongMingChengGong.mag_power;
                /*      */
                /* 2263 */         chara.zbAttribute.speed += good.goodsGaiZaoGongMingChengGong.speed;
                /*      */
                /* 2265 */         chara.zbAttribute.life += good.goodsGaiZaoGongMingChengGong.life;
                /*      */
                /* 2267 */         chara.zbAttribute.resist_frozen += good.goodsGaiZaoGongMingChengGong.resist_frozen;
                /*      */
                /* 2269 */         chara.zbAttribute.resist_sleep += good.goodsGaiZaoGongMingChengGong.resist_sleep;
                /*      */
                /* 2271 */         chara.zbAttribute.resist_forgotten += good.goodsGaiZaoGongMingChengGong.resist_forgotten;
                /*      */
                /* 2273 */         chara.zbAttribute.resist_confusion += good.goodsGaiZaoGongMingChengGong.resist_confusion;
                /*      */
                /* 2275 */         chara.zbAttribute.longevity += good.goodsGaiZaoGongMingChengGong.longevity;
                /*      */
                /* 2277 */         chara.zbAttribute.resist_wood += good.goodsGaiZaoGongMingChengGong.resist_wood;
                /*      */
                /* 2279 */         chara.zbAttribute.resist_water += good.goodsGaiZaoGongMingChengGong.resist_water;
                /*      */
                /* 2281 */         chara.zbAttribute.resist_fire += good.goodsGaiZaoGongMingChengGong.resist_fire;
                /*      */
                /* 2283 */         chara.zbAttribute.resist_earth += good.goodsGaiZaoGongMingChengGong.resist_earth;
                /*      */
                /* 2285 */         chara.zbAttribute.exp_to_next_level += good.goodsGaiZaoGongMingChengGong.exp_to_next_level;
                /*      */
                /* 2287 */         chara.zbAttribute.mstunt_rate += good.goodsGaiZaoGongMingChengGong.mstunt_rate;
                /*      */
                /* 2289 */         chara.zbAttribute.stunt_rate += good.goodsGaiZaoGongMingChengGong.stunt_rate;
                /*      */
                /* 2291 */         chara.zbAttribute.double_hit_rate += good.goodsGaiZaoGongMingChengGong.double_hit_rate;
                /*      */
                /* 2293 */         chara.zbAttribute.super_excluse_wood += good.goodsGaiZaoGongMingChengGong.super_excluse_wood;
                /*      */
                /* 2295 */         chara.zbAttribute.super_excluse_water += good.goodsGaiZaoGongMingChengGong.super_excluse_water;
                /*      */
                /* 2297 */         chara.zbAttribute.super_excluse_fire += good.goodsGaiZaoGongMingChengGong.super_excluse_fire;
                /*      */
                /* 2299 */         chara.zbAttribute.super_excluse_earth += good.goodsGaiZaoGongMingChengGong.super_excluse_earth;
                /*      */
                /* 2301 */         chara.zbAttribute.B_skill_low_cost += good.goodsGaiZaoGongMingChengGong.B_skill_low_cost;
                /*      */
                /* 2303 */         chara.zbAttribute.life_recover += good.goodsGaiZaoGongMingChengGong.life_recover;
                /*      */
                /* 2305 */         chara.zbAttribute.family += good.goodsGaiZaoGongMingChengGong.family;
                /*      */
                /* 2307 */         chara.zbAttribute.portrait += good.goodsGaiZaoGongMingChengGong.portrait;
                /*      */
                /* 2309 */         chara.zbAttribute.tao_ex += good.goodsGaiZaoGongMingChengGong.tao_ex;
                /*      */
                /* 2311 */         chara.zbAttribute.release_confusion += good.goodsGaiZaoGongMingChengGong.release_confusion;
                /*      */
                /* 2313 */         chara.zbAttribute.release_sleep += good.goodsGaiZaoGongMingChengGong.release_sleep;
                /*      */
                /* 2315 */         chara.zbAttribute.release_frozen += good.goodsGaiZaoGongMingChengGong.release_frozen;
                /*      */
                /* 2317 */         chara.zbAttribute.release_poison += good.goodsGaiZaoGongMingChengGong.release_poison;
                /*      */
                /* 2319 */         chara.zbAttribute.C_skill_low_cost += good.goodsGaiZaoGongMingChengGong.C_skill_low_cost;
                /*      */
                /* 2321 */         chara.zbAttribute.D_skill_low_cost += good.goodsGaiZaoGongMingChengGong.D_skill_low_cost;
                /*      */
                /* 2323 */         chara.zbAttribute.super_poison += good.goodsGaiZaoGongMingChengGong.super_poison;
                /*      */
                /*      */
                /*      */
                /* 2327 */         if (chara.suit_icon != 0)
                    /*      */         {
                    /* 2329 */           chara.zbAttribute.mana += good.goodsLvSeGongMing.mana;
                    /*      */
                    /* 2331 */           chara.zbAttribute.def += good.goodsLvSeGongMing.def;
                    /*      */
                    /* 2333 */           chara.zbAttribute.wiz += good.goodsLvSeGongMing.wiz;
                    /*      */
                    /* 2335 */           chara.zbAttribute.parry += good.goodsLvSeGongMing.parry;
                    /*      */
                    /* 2337 */           chara.zbAttribute.accurate += good.goodsLvSeGongMing.accurate;
                    /*      */         }
                /*      */       }
            /*      */     }
        /*      */
        /*      */
        /* 2343 */     for (int i = 0; i < chara.pets.size(); i++) {
            /* 2344 */       if (((Petbeibao)chara.pets.get(i)).id == chara.zuoqiId) {
                /* 2345 */         for (int j = 0; j < ((Petbeibao)chara.pets.get(i)).petShuXing.size(); j++) {
                    /* 2346 */           if (((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(j)).no == 23) {
                        /* 2347 */             chara.zbAttribute.mana += ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(j)).mana;
                        /* 2348 */             chara.zbAttribute.accurate += ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(j)).accurate;
                        /* 2349 */             chara.zbAttribute.wiz += ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(j)).wiz;
                        /*      */           }
                    /*      */         }
                /*      */       }
            /*      */     }
        /* 2354 */     for (int i = 0; i < chara.jiNengList.size(); i++) {
            /* 2355 */       if (((JiNeng)chara.jiNengList.get(i)).skill_no == 301) {
                /* 2356 */         chara.zbAttribute.def += (int)((chara.zbAttribute.def + chara.def) * 0.01D * ((JiNeng)chara.jiNengList.get(i)).skill_level);
                /*      */       }
            /*      */
            /* 2359 */       if (((JiNeng)chara.jiNengList.get(i)).skill_no == 302) {
                /* 2360 */         chara.zbAttribute.dex += (int)((chara.zbAttribute.dex + chara.dex) * 0.01D * ((JiNeng)chara.jiNengList.get(i)).skill_level);
                /*      */       }
            /*      */     }
        /*      */
        /*      */
        /* 2365 */     for (int i = 0; i < chara.backpack.size(); i++) {
            /* 2366 */       if (((Goods)chara.backpack.get(i)).pos == 9) {
                /* 2367 */         Goods goods = (Goods)chara.backpack.get(i);
                /* 2368 */         if (goods.goodsInfo.shuadao_ziqihongmeng == 4) {
                    /* 2369 */           chara.zbAttribute.parry += (int)((chara.zbAttribute.parry + chara.parry) * 0.015D);
                    /*      */         }
                /* 2371 */         if (goods.goodsInfo.shuadao_ziqihongmeng == 1) {
                    /* 2372 */           chara.zbAttribute.mana += (int)((chara.zbAttribute.mana + chara.mana) * 0.015D);
                    /*      */         }
                /* 2374 */         if (goods.goodsInfo.shuadao_ziqihongmeng == 2) {
                    /* 2375 */           chara.zbAttribute.def += (int)((chara.zbAttribute.def + chara.def) * 0.025D);
                    /* 2376 */           chara.zbAttribute.dex += (int)((chara.zbAttribute.dex + chara.dex) * 0.025D);
                    /*      */         }
                /* 2378 */         if (goods.goodsInfo.shuadao_ziqihongmeng == 3) {
                    /* 2379 */           chara.zbAttribute.wiz += (int)((chara.zbAttribute.wiz + chara.wiz) * 0.03D);
                    /*      */         }
                /* 2381 */         if (goods.goodsInfo.shuadao_ziqihongmeng == 5) {
                    /* 2382 */           chara.zbAttribute.accurate += (int)((chara.zbAttribute.accurate + chara.accurate) * 0.015D);
                    /*      */         }
                /*      */       }
            /*      */     }
        /*      */   }
    /*      */
    /*      */
    /*      */
    /*      */   public static org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0 a16383(Chara chara, String msg, int channel, Chara chara1)
    /*      */   {
        /* 2392 */     org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0 vo_16383_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0();
        /* 2393 */     vo_16383_0.channel = channel;
        /* 2394 */     vo_16383_0.id = chara.id;
        /* 2395 */     vo_16383_0.name = chara.name;
        /* 2396 */     vo_16383_0.msg = msg;
        /* 2397 */     long times = System.currentTimeMillis() / 1000L;
        /* 2398 */     vo_16383_0.time = ((int)times);
        /* 2399 */     vo_16383_0.privilege = 0;
        /* 2400 */     vo_16383_0.server_name = "涅槃重生22";
        /* 2401 */     vo_16383_0.show_extra = 2;
        /* 2402 */     vo_16383_0.compress = 0;
        /* 2403 */     vo_16383_0.orgLength = 65535;
        /* 2404 */     vo_16383_0.cardCount = 0;
        /* 2405 */     vo_16383_0.voiceTime = 0;
        /* 2406 */     vo_16383_0.token = "";
        /* 2407 */     vo_16383_0.checksum = 0;
        /* 2408 */     vo_16383_0.iid_str = chara.uuid;
        /* 2409 */     vo_16383_0.has_break_lv_limit = 0;
        /* 2410 */     vo_16383_0.skill = chara.level;
        /* 2411 */     vo_16383_0.type = chara.waiguan;
        /* 2412 */     vo_16383_0.suit_level = chara1.uuid;
        /* 2413 */     return vo_16383_0;
        /*      */   }
    /*      */
    /*      */   public static org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0 a16383(Chara chara, String msg, int channel) {
        /* 2417 */     org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0 vo_16383_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0();
        /* 2418 */     vo_16383_0.channel = channel;
        /* 2419 */     vo_16383_0.id = chara.id;
        /* 2420 */     vo_16383_0.name = chara.name;
        /* 2421 */     vo_16383_0.msg = msg;
        /* 2422 */     long times = System.currentTimeMillis() / 1000L;
        /* 2423 */     int time = (int)times;
        /* 2424 */     vo_16383_0.time = time;
        /* 2425 */     vo_16383_0.privilege = 0;
        /*      */
        /* 2427 */     vo_16383_0.server_name = "涅槃重生22";
        /* 2428 */     vo_16383_0.show_extra = 0;
        /* 2429 */     vo_16383_0.compress = 0;
        /* 2430 */     vo_16383_0.orgLength = 65535;
        /* 2431 */     vo_16383_0.cardCount = 0;
        /* 2432 */     vo_16383_0.voiceTime = 0;
        /* 2433 */     vo_16383_0.token = "";
        /* 2434 */     vo_16383_0.checksum = 0;
        /* 2435 */     vo_16383_0.iid_str = chara.uuid;
        /* 2436 */     vo_16383_0.has_break_lv_limit = 0;
        /* 2437 */     vo_16383_0.skill = chara.level;
        /* 2438 */     vo_16383_0.type = chara.waiguan;
        /* 2439 */     return vo_16383_0;
        /*      */   }
    /*      */
    /*      */   public static org.linlinjava.litemall.gameserver.data.vo.Vo_45056_0 a45056(Chara chara)
    /*      */   {
        /* 2444 */     org.linlinjava.litemall.gameserver.data.vo.Vo_45056_0 vo_45056_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45056_0();
        /* 2445 */     vo_45056_0.id = chara.id;
        /* 2446 */     vo_45056_0.name = chara.name;
        /* 2447 */     vo_45056_0.portrait = chara.waiguan;
        /* 2448 */     vo_45056_0.pic_no = 0;
        /* 2449 */     vo_45056_0.content = "";
        /* 2450 */     vo_45056_0.isComplete = 1;
        /* 2451 */     vo_45056_0.isInCombat = 0;
        /* 2452 */     vo_45056_0.playTime = 20;
        /* 2453 */     vo_45056_0.task_type = "主线—浮生若梦";
        /* 2454 */     return vo_45056_0;
        /*      */   }
    /*      */
    /*      */   public static String getRandomJianHan()
    /*      */   {
        /* 2459 */     Random random = new Random();
        /* 2460 */     int len = random.nextInt(2) + 3;
        /* 2461 */     String ret = "";
        /* 2462 */     for (int i = 0; i < len; i++) {
            /* 2463 */       String str = null;
            /*      */
            /* 2465 */       int hightPos = 176 + Math.abs(random.nextInt(39));
            /* 2466 */       int lowPos = 161 + Math.abs(random.nextInt(93));
            /* 2467 */       byte[] b = new byte[2];
            /* 2468 */       b[0] = new Integer(hightPos).byteValue();
            /* 2469 */       b[1] = new Integer(lowPos).byteValue();
            /*      */       try {
                /* 2471 */         str = new String(b, "GBK");
                /*      */       } catch (java.io.UnsupportedEncodingException ex) {
                /* 2473 */         ex.printStackTrace();
                /*      */       }
            /* 2475 */       ret = ret + str;
            /*      */     }
        /*      */
        /* 2478 */     return ret;
        /*      */   }
    /*      */
    /**
     * MSG_TASK_PROMPT  任务提示
     */
    /*      */   public static org.linlinjava.litemall.gameserver.data.vo.Vo_61553_0 a61553(org.linlinjava.litemall.db.domain.Renwu tasks, Chara chara)
    /*      */   {
        /* 2483 */     if (tasks == null) {
            /* 2484 */       org.linlinjava.litemall.gameserver.data.vo.Vo_61553_0 vo_61553_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_61553_0();
            /* 2485 */       vo_61553_0.count = 1;
            /* 2486 */       for (int i = 0; i < vo_61553_0.count; i++) {
                /* 2487 */         vo_61553_0.task_type = "";
                /* 2488 */         vo_61553_0.task_desc = "1-9级主线任务，该等级段任务不可组队同步完成。";
                /* 2489 */         vo_61553_0.task_prompt = "";
                /* 2490 */         vo_61553_0.refresh = 0;
                /* 2491 */         vo_61553_0.task_end_time = 1563252508;
                /* 2492 */         vo_61553_0.attrib = 0;
                /* 2493 */         vo_61553_0.reward = "#I经验|人物经验宠物经验#I#I代金券|代金券#I";
                /* 2494 */         vo_61553_0.show_name = "";
                /*      */       }
            /* 2496 */       vo_61553_0.tasktask_extra_para = "";
            /* 2497 */       vo_61553_0.tasktask_state = "1";
            /* 2498 */       return vo_61553_0;
            /*      */     }
        /* 2500 */     if (tasks.getCurrentTask().equals("主线—浮生若梦_s21")) {
            /* 2501 */       String[] str = { "前往#Z五龙山#Z拜师", "前往#Z终南山#Z拜师", "前往#Z凤凰山#Z拜师", "前往#Z乾元山#Z拜师", "前往#Z骷髅山#Z拜师" };
            /* 2502 */       tasks.setTaskPrompt(str[(chara.menpai - 1)]);
            /*      */     }
        /* 2504 */     if (tasks.getCurrentTask().equals("主线—浮生若梦_s22")) {
            /* 2505 */       String[] str = { "向#P云霄童子|E=【主线】慕名而来#P拜师", "向#P碧玉童子|E=【主线】慕名而来#P拜师", "向#P水灵童子|E=【主线】慕名而来#P拜师", "向#P赤霞童子|E=【主线】慕名而来#P拜师", "向#P彩云童子|E=【主线】慕名而来#P拜师" };
            /* 2506 */       tasks.setTaskPrompt(str[(chara.menpai - 1)]);
            /*      */     }
        /*      */
        /* 2509 */     org.linlinjava.litemall.gameserver.data.vo.Vo_61553_0 vo_61553_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_61553_0();
        /* 2510 */     vo_61553_0.count = 1;
        /* 2511 */     for (int i = 0; i < vo_61553_0.count; i++) {
            /* 2512 */       vo_61553_0.task_type = "";
            /* 2513 */       vo_61553_0.task_desc = "1-9级主线任务，该等级段任务不可组队同步完成。";
            /* 2514 */       vo_61553_0.task_prompt = tasks.getTaskPrompt();
            /* 2515 */       vo_61553_0.refresh = 0;
            /* 2516 */       vo_61553_0.task_end_time = 1563252508;
            /* 2517 */       vo_61553_0.attrib = 0;
            /* 2518 */       vo_61553_0.reward = "#I经验|人物经验宠物经验#I#I代金券|代金券#I";
            /* 2519 */       vo_61553_0.show_name = tasks.getShowName();
            /*      */     }
        /* 2521 */     vo_61553_0.tasktask_extra_para = "";
        /* 2522 */     vo_61553_0.tasktask_state = "1";
        /* 2523 */     return vo_61553_0;
        /*      */   }
    /*      */
    /**
     * MSG_MENU_LIST
     */
    /*      */   public static org.linlinjava.litemall.gameserver.data.vo.Vo_8247_0 a8247(org.linlinjava.litemall.db.domain.Npc npc, String content)
    /*      */   {
        /* 2528 */     org.linlinjava.litemall.gameserver.data.vo.Vo_8247_0 vo_8247_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_8247_0();
        /* 2529 */     vo_8247_0.id = npc.getId().intValue();
        /* 2530 */     vo_8247_0.portrait = npc.getIcon().intValue();
        /* 2531 */     vo_8247_0.pic_no = 1;
        /* 2532 */     vo_8247_0.content = content.replace("\\", "");
        /* 2533 */     vo_8247_0.secret_key = "";
        /* 2534 */     vo_8247_0.name = npc.getName();
        /* 2535 */     vo_8247_0.attrib = 0;
        /* 2536 */     return vo_8247_0;
        /*      */   }

    /**
     * 随机通天塔星君名字
     * @return
     */
    public static String randomTTTXingJunName(){
        Random random = new Random();
        return TTT_XINGJUN[random.nextInt(TTT_XINGJUN.length)];
    }
    /**
     * 随机通天塔星君的宠物名字
     * @return
     */
    public static String randomTTTPetName(){
        Random random = new Random();
        return TONG_TIAN_TA_PET[random.nextInt(TONG_TIAN_TA_PET.length)];
    }

    /**
     * 是否是通天塔星君宠物
     * @param petName
     * @return
     */
    public static boolean isTTTPet(String petName){
        for(String name:TONG_TIAN_TA_PET){
            if(name.equals(petName)){
                return true;
            }
        }
        return false;
    }
    /*      */

    /**
     * MSG_APPEAR
     * @param chara
     * @return
     */
    /*      */   public static org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0 MSG_APPEAR(Chara chara) {
        /* 2540 */     org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0 vo_65529_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0();
        /* 2541 */     vo_65529_0.id = chara.id;
        /* 2542 */     vo_65529_0.x = chara.x;
        /* 2543 */     vo_65529_0.y = chara.y;
        /* 2544 */     vo_65529_0.dir = 3;
        /* 2545 */     vo_65529_0.icon = chara.waiguan;
        /*      */
        /* 2547 */     vo_65529_0.weapon_icon = chara.weapon_icon;
        /* 2548 */     vo_65529_0.type = 1;
        /* 2549 */     vo_65529_0.sub_type = 0;
        /* 2550 */     vo_65529_0.owner_id = 0;
        /* 2551 */     vo_65529_0.leader_id = 0;
        /* 2552 */     vo_65529_0.name = chara.name;
        /* 2553 */     vo_65529_0.level = chara.level;
        /* 2554 */     vo_65529_0.title = "";
        /* 2555 */     vo_65529_0.family = "";
        /* 2556 */     vo_65529_0.party = chara.partyName;
        /* 2557 */     vo_65529_0.status = 0;
        /*      */
        /* 2559 */     vo_65529_0.special_icon = chara.special_icon;
        /* 2560 */     vo_65529_0.org_icon = chara.waiguan;
        /* 2561 */     vo_65529_0.suit_icon = chara.suit_icon;
        /* 2562 */     vo_65529_0.suit_light_effect = chara.suit_light_effect;
        /* 2563 */     vo_65529_0.guard_icon = 0;
        /* 2564 */     vo_65529_0.pet_icon = chara.zuoqiwaiguan;
        /* 2565 */     vo_65529_0.shadow_icon = 0;
        /* 2566 */     vo_65529_0.shelter_icon = 0;
        /* 2567 */     vo_65529_0.mount_icon = chara.zuowaiguan;
        /* 2568 */     vo_65529_0.alicename = "";
        /* 2569 */     vo_65529_0.gid = chara.uuid;
        /* 2570 */     vo_65529_0.camp = "";
        /* 2571 */     vo_65529_0.vip_type = chara.vipType;
        /* 2572 */     vo_65529_0.isHide = 0;
        /* 2573 */     vo_65529_0.moveSpeedPercent = chara.yidongsudu;
        /* 2574 */     vo_65529_0.score = 0;
        /* 2575 */     vo_65529_0.opacity = 0;
        /* 2576 */     vo_65529_0.masquerade = 0;
        /* 2577 */     vo_65529_0.upgradestate = 0;
        /* 2578 */     vo_65529_0.upgradetype = 0;
        /* 2579 */     vo_65529_0.obstacle = 0;
        /* 2580 */     if (chara.texiao_icon == 0) {
            /* 2581 */       vo_65529_0.light_effect_count = 0;
            /*      */     } else {
            /* 2583 */       vo_65529_0.light_effect_count = 1;
            /*      */     }
        /* 2585 */     vo_65529_0.effect = chara.texiao_icon;
        /* 2586 */     vo_65529_0.share_mount_icon = 0;
        /* 2587 */     vo_65529_0.share_mount_leader_id = 0;
        /* 2588 */     vo_65529_0.gather_count = 0;
        /* 2589 */     vo_65529_0.gather_name_num = 0;
        /* 2590 */     vo_65529_0.portrait = chara.waiguan;
        /* 2591 */     vo_65529_0.customIcon = "";
        /* 2592 */     return vo_65529_0;
        /*      */   }
    /*      */

    /**
     * MSG_UPDATE_IMPROVEMENT
     * @param chara
     * @return
     */
    /*      */   public static org.linlinjava.litemall.gameserver.data.vo.Vo_65511_0 MSG_UPDATE_IMPROVEMENT(Chara chara) {
        /* 2596 */     zhuangbeiValue(chara);
        /* 2597 */     chara.zbAttribute.id = chara.id;
        /* 2598 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M65511_0(), chara.zbAttribute);
        /*      */
        /* 2600 */     ListVo_65527_0 vo_65527_0 = a65527(chara);
        /* 2601 */     GameObjectChar.send(new MSG_UPDATE(), vo_65527_0);
        /* 2602 */     org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0 vo_61661_0 = MSG_UPDATE_APPEARANCE(chara);
        /* 2603 */     GameObjectChar.send(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
        /*      */
        /* 2605 */     org.linlinjava.litemall.gameserver.data.vo.Vo_65511_0 vo_65511_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_65511_0();
        /* 2616 */     return vo_65511_0;
        /*      */   }
    /*      */  //MSG_UPDATE
    /*      */   public static ListVo_65527_0 a65527(Chara chara)
    /*      */   {
        /* 2621 */     ListVo_65527_0 vo_65527_0 = new ListVo_65527_0();
        /* 2622 */     org.linlinjava.litemall.gameserver.data.game.BasicAttributesUtils.shuxing(chara);
        /* 2623 */     if ((chara.max_mana < chara.dex + chara.zbAttribute.dex) && (chara.have_coin_pwd > 0)) {
            /* 2624 */       int pwd = chara.dex + chara.zbAttribute.def - chara.max_mana;
            /* 2625 */       if (chara.have_coin_pwd < pwd) {
                /* 2626 */         pwd = chara.have_coin_pwd;
                /* 2627 */         chara.have_coin_pwd = 0;
                /*      */       } else {
                /* 2629 */         chara.have_coin_pwd -= pwd;
                /*      */       }
            /* 2631 */       chara.max_mana += pwd;
            /*      */     }
        /* 2633 */     if ((chara.max_life < chara.def + chara.zbAttribute.def) && (chara.extra_mana > 0)) {
            /* 2634 */       int life = chara.def + chara.zbAttribute.def - chara.max_life;
            /* 2635 */       if (chara.extra_mana < life) {
                /* 2636 */         life = chara.extra_mana;
                /* 2637 */         chara.extra_mana = 0;
                /*      */       } else {
                /* 2639 */         chara.extra_mana -= life;
                /*      */       }
            /* 2641 */       chara.max_life += life;
            /*      */     }
        /*      */
        /* 2644 */     vo_65527_0.id = chara.id;
        /* 2645 */     vo_65527_0.vo_65527_0.str = chara.name;
        /* 2646 */     vo_65527_0.vo_65527_0.phy_power = chara.phy_power;
        /* 2647 */     vo_65527_0.vo_65527_0.accurate = chara.accurate;
        /* 2648 */     vo_65527_0.vo_65527_0.life = chara.life;
        /* 2649 */     vo_65527_0.vo_65527_0.max_life = chara.max_life;
        /* 2650 */     vo_65527_0.vo_65527_0.def = chara.def;
        /* 2651 */     vo_65527_0.vo_65527_0.wiz = chara.wiz;
        /* 2652 */     vo_65527_0.vo_65527_0.mag_power = chara.mag_power;
        /* 2653 */     vo_65527_0.vo_65527_0.mana = chara.mana;
        /* 2654 */     vo_65527_0.vo_65527_0.max_mana = chara.max_mana;
        /* 2655 */     vo_65527_0.vo_65527_0.dex = chara.dex;
        /* 2656 */     vo_65527_0.vo_65527_0.speed = chara.speed;
        /* 2657 */     vo_65527_0.vo_65527_0.parry = chara.parry;
        /* 2658 */     vo_65527_0.vo_65527_0.attrib_point = 0;
        /* 2659 */     vo_65527_0.vo_65527_0.metal = chara.menpai;
        /* 2660 */     vo_65527_0.vo_65527_0.wood = chara.wood;
        /* 2661 */     vo_65527_0.vo_65527_0.water = chara.water;
        /* 2662 */     vo_65527_0.vo_65527_0.fire = chara.fire;
        /* 2663 */     vo_65527_0.vo_65527_0.earth = chara.earth;
        /* 2664 */     vo_65527_0.vo_65527_0.resist_metal = chara.resist_metal;
        /* 2665 */     vo_65527_0.vo_65527_0.resist_wood = 0;
        /* 2666 */     vo_65527_0.vo_65527_0.resist_water = 0;
        /* 2667 */     vo_65527_0.vo_65527_0.resist_fire = 0;
        /* 2668 */     vo_65527_0.vo_65527_0.resist_earth = 0;
        /* 2669 */     vo_65527_0.vo_65527_0.exp_to_next_level = 0;
        /* 2670 */     vo_65527_0.vo_65527_0.polar_point = chara.polar_point;
        /* 2671 */     vo_65527_0.vo_65527_0.stamina = chara.stamina;
        /* 2672 */     vo_65527_0.vo_65527_0.max_stamina = 1000;
        /* 2673 */     vo_65527_0.vo_65527_0.tao = 105;
        /* 2674 */     vo_65527_0.vo_65527_0.friend = chara.friend;
        /* 2675 */     vo_65527_0.vo_65527_0.owner_name = chara.owner_name;
        /* 2676 */     vo_65527_0.vo_65527_0.mon_tao_ex = 0;
        /* 2677 */     vo_65527_0.vo_65527_0.last_mon_tao = 0;
        /* 2678 */     vo_65527_0.vo_65527_0.last_mon_tao_ex = 0;
        /* 2679 */     vo_65527_0.vo_65527_0.mon_martial = 0;
        /* 2680 */     vo_65527_0.vo_65527_0.degree = 0;
        /* 2681 */     vo_65527_0.vo_65527_0.exp = 0;
        /* 2682 */     vo_65527_0.vo_65527_0.pot = chara.pot;
        /* 2683 */     vo_65527_0.vo_65527_0.cash = chara.cash;
        /* 2684 */     vo_65527_0.vo_65527_0.balance = chara.balance;
        /* 2685 */     vo_65527_0.vo_65527_0.gender = chara.gender;
        /* 2686 */     vo_65527_0.vo_65527_0.max_balance = 2000000000;
        /* 2687 */     vo_65527_0.vo_65527_0.ignore_resist_metal = 2000000000;
        /* 2688 */     vo_65527_0.vo_65527_0.master = chara.sex;
        /* 2689 */     vo_65527_0.vo_65527_0.level = "";
        /* 2690 */     vo_65527_0.vo_65527_0.skill = chara.level;
        /* 2691 */     vo_65527_0.vo_65527_0.party_contrib = chara.chenhao;
        /* 2692 */     vo_65527_0.vo_65527_0.status_daofa_wubian = "";
        /* 2693 */     vo_65527_0.vo_65527_0.nick = 0;
        /* 2694 */     vo_65527_0.vo_65527_0.family_title = "";
        /* 2695 */     vo_65527_0.vo_65527_0.title = "";
        /* 2696 */     vo_65527_0.vo_65527_0.nice = chara.chenhao;
        /* 2697 */     vo_65527_0.vo_65527_0.reputation = 0;
        /* 2698 */     vo_65527_0.vo_65527_0.couple = 0;
        /* 2699 */     vo_65527_0.vo_65527_0.icon = "";
        /* 2700 */     vo_65527_0.vo_65527_0.type = chara.waiguan;
        /* 2701 */     vo_65527_0.vo_65527_0.resist_poison = chara.resist_poison;
        /*      */
        /* 2703 */     vo_65527_0.vo_65527_0.item_unique = 0;
        /* 2704 */     vo_65527_0.vo_65527_0.passive_mode = chara.waiguan;
        /* 2705 */     vo_65527_0.vo_65527_0.req_str = chara.chenhao;
        /*      */
        /* 2707 */     vo_65527_0.vo_65527_0.locked = 0;
        /* 2708 */     vo_65527_0.vo_65527_0.extra_desc = 0;
        /* 2709 */     vo_65527_0.vo_65527_0.gold_coin = chara.gold_coin;
        /* 2710 */     vo_65527_0.vo_65527_0.extra_life = chara.extra_life;
        /* 2711 */     vo_65527_0.vo_65527_0.extra_mana = chara.extra_mana;
        /* 2712 */     vo_65527_0.vo_65527_0.have_coin_pwd = chara.have_coin_pwd;
        /* 2713 */     vo_65527_0.vo_65527_0.max_req_level = 0;
        /* 2714 */     vo_65527_0.vo_65527_0.use_skill_d = chara.use_skill_d;
        /* 2715 */     vo_65527_0.vo_65527_0.double_points = 100;
        /* 2716 */     vo_65527_0.vo_65527_0.enable_double_points = chara.enable_double_points;
        /*      */
        /* 2718 */     vo_65527_0.vo_65527_0.can_buy_dp_times = chara.charashuangbei;
        /* 2719 */     vo_65527_0.vo_65527_0.enable_shenmu_points = chara.enable_shenmu_points;
        /*      */
        /* 2721 */     vo_65527_0.vo_65527_0.gift_key = chara.shenmoding;
        /*      */
        /* 2723 */     vo_65527_0.vo_65527_0.online = 0;
        /* 2724 */     vo_65527_0.vo_65527_0.voucher = 0;
        /* 2725 */     vo_65527_0.vo_65527_0.party_name = 0;
        /* 2726 */     vo_65527_0.vo_65527_0.use_money_type = chara.use_money_type;
        /* 2727 */     vo_65527_0.vo_65527_0.lock_exp = chara.lock_exp;
        /* 2728 */     vo_65527_0.vo_65527_0.shuadaochongfeng_san = chara.shuadaochongfeng_san;
        /*      */
        /* 2730 */     vo_65527_0.vo_65527_0.equip_identify = 0;
        /* 2731 */     vo_65527_0.vo_65527_0.fetch_nice = chara.fetch_nice;
        /* 2732 */     vo_65527_0.vo_65527_0.reputation = 0;
        /* 2733 */     vo_65527_0.vo_65527_0.recharge = 10;
        /*      */
        /* 2735 */     vo_65527_0.vo_65527_0.shadow_self = chara.shadow_self;
        /* 2736 */     vo_65527_0.vo_65527_0.extra_life_effect = 0;
        /* 2737 */     vo_65527_0.vo_65527_0.desc = 0;
        /* 2738 */     vo_65527_0.vo_65527_0.enchant = 0;
        /* 2739 */     vo_65527_0.vo_65527_0.higest_feixdx = 0;
        /* 2740 */     vo_65527_0.vo_65527_0.ct_datascore = 1559291151;
        /* 2741 */     vo_65527_0.vo_65527_0.marriagemarry_id = "";
        /* 2742 */     vo_65527_0.vo_65527_0.extra_skill = chara.extra_skill;
        /* 2743 */     vo_65527_0.vo_65527_0.chushi_ex = chara.chushi_ex;
        /* 2744 */     vo_65527_0.vo_65527_0.settingrefuse_stranger_level = 35;
        /* 2745 */     vo_65527_0.vo_65527_0.settingauto_reply_msg = "";
        /* 2746 */     vo_65527_0.vo_65527_0.setting_refuse_be_add_level = 0;
        /* 2747 */     vo_65527_0.vo_65527_0.mount_attrib_end_time = 20;
        /* 2748 */     vo_65527_0.vo_65527_0.ct_data_top_rank = 0;
        /* 2749 */     vo_65527_0.vo_65527_0.real_desc = 0;
        /* 2750 */     vo_65527_0.vo_65527_0.bully_kill_num = 0;
        /* 2751 */     vo_65527_0.vo_65527_0.police_kill_num = 0;
        /* 2752 */     vo_65527_0.vo_65527_0.gm_attribsmax_life = 0;
        /* 2753 */     vo_65527_0.vo_65527_0.gm_attribsmax_mana = 0;
        /* 2754 */     vo_65527_0.vo_65527_0.gm_attribsphy_power = 0;
        /* 2755 */     vo_65527_0.vo_65527_0.gm_attribsmag_power = 0;
        /* 2756 */     vo_65527_0.vo_65527_0.gm_attribsdef = 0;
        /* 2757 */     vo_65527_0.vo_65527_0.gm_attribsspeed = 0;
        /* 2758 */     vo_65527_0.vo_65527_0.shuadao_ruyi_point = "";
        /* 2759 */     vo_65527_0.vo_65527_0.upgrade_level = 0;
        /* 2760 */     vo_65527_0.vo_65527_0.upgrade_type = 0;
        /* 2761 */     vo_65527_0.vo_65527_0.upgrade_exp = 0;
        /* 2762 */     vo_65527_0.vo_65527_0.upgrade_exp_to_next_level = 0;
        /* 2763 */     vo_65527_0.vo_65527_0.upgrade_level = 0;
        /* 2764 */     vo_65527_0.vo_65527_0.upgrade_max_polar_extra = 0;
        /* 2765 */     vo_65527_0.vo_65527_0.artifact_upgraded_enabled = 0;
        /* 2766 */     vo_65527_0.vo_65527_0.upgrade_magic = 0;
        /* 2767 */     vo_65527_0.vo_65527_0.upgrade_total = 0;
        /* 2768 */     vo_65527_0.vo_65527_0.house_house_class = "";
        /* 2769 */     vo_65527_0.vo_65527_0.plant_level = 0;
        /* 2770 */     vo_65527_0.vo_65527_0.phy_power_without_intimacy = 0;
        /* 2771 */     vo_65527_0.vo_65527_0.plant_exp = 0;
        /*      */
        /* 2773 */     vo_65527_0.vo_65527_0.marriage_couple_gid = "";
        /* 2774 */     vo_65527_0.vo_65527_0.strengthen_jewelry_num = "";
        /*      */
        /* 2776 */     vo_65527_0.vo_65527_0.dan_data_stage = 0;
        /* 2777 */     vo_65527_0.vo_65527_0.dan_data_exp = 0;
        /* 2778 */     vo_65527_0.vo_65527_0.dan_data_exp_to_next_level = 0;
        /* 2779 */     vo_65527_0.vo_65527_0.dan_data_attrib_point = 0;
        /* 2780 */     vo_65527_0.vo_65527_0.dan_data_polar_point = 0;
        /* 2781 */     vo_65527_0.vo_65527_0.not_check_bw = 0;
        /* 2782 */     vo_65527_0.vo_65527_0.soul_state = 0;
        /* 2783 */     vo_65527_0.vo_65527_0.dan_data_today_exp = 0;
        /* 2784 */     vo_65527_0.vo_65527_0.transform_num = 0;
        /* 2785 */     vo_65527_0.vo_65527_0.fasion_effect_disable = 0;
        /* 2786 */     vo_65527_0.vo_65527_0.marriage_book_id = 1;
        /* 2787 */     vo_65527_0.vo_65527_0.strengthen_level = 0;
        /* 2788 */     vo_65527_0.vo_65527_0.status_diliebo_flag = 0;
        /* 2789 */     vo_65527_0.vo_65527_0.exp_ware_data_lock_time = 0;
        /* 2790 */     vo_65527_0.vo_65527_0.exp_ware_data_exp_ware = 0;
        /* 2791 */     vo_65527_0.vo_65527_0.exp_ware_data_fetch_times = 0;
        /* 2792 */     vo_65527_0.vo_65527_0.exp_ware_data_today_fetch_times = 0;
        /*      */
        /*      */
        /*      */
        /*      */
        /* 2797 */     vo_65527_0.vo_65527_0.free_rename = (chara.autofight_select == 0 ? 0 : 1);
        /* 2798 */     return vo_65527_0;
        /*      */   }
    /*      */

    /**
     * MSG_ENTER_ROOM
     * @param chara
     * @return
     */
    /*      */   public static org.linlinjava.litemall.gameserver.data.vo.Vo_65505_0 a65505(Chara chara) {
        /* 2802 */     org.linlinjava.litemall.gameserver.data.vo.Vo_65505_0 vo_65505_1 = new org.linlinjava.litemall.gameserver.data.vo.Vo_65505_0();
        /* 2803 */     vo_65505_1.map_id = chara.mapid;
        /* 2804 */     vo_65505_1.map_name = chara.mapName;
        /* 2805 */     vo_65505_1.map_show_name = "";
        /* 2806 */     vo_65505_1.x = chara.x;
        /* 2807 */     vo_65505_1.y = chara.y;
        /* 2808 */     vo_65505_1.map_index = 50331648;
        /* 2809 */     vo_65505_1.compact_map_index = 49408;
        /* 2810 */     vo_65505_1.floor_index = 0;
        /* 2811 */     vo_65505_1.wall_index = 0;
        /* 2812 */     vo_65505_1.is_safe_zone = 0;
        /* 2813 */     vo_65505_1.is_task_walk = 0;
        /* 2814 */     vo_65505_1.enter_effect_index = 0;
        /* 2815 */     return vo_65505_1;
        /*      */   }
    /*      */
    /*      */
    /*      */
    /*      */   public static List<org.linlinjava.litemall.gameserver.data.vo.ListVo_65525_0> a65525()
    /*      */   {
        /* 2822 */     List<org.linlinjava.litemall.gameserver.data.vo.ListVo_65525_0> linkedList = new java.util.LinkedList();
        /* 2823 */     org.linlinjava.litemall.gameserver.data.vo.ListVo_65525_0 ObjckListVo_65525_0 = new org.linlinjava.litemall.gameserver.data.vo.ListVo_65525_0();
        /*      */
        /* 2825 */     ObjckListVo_65525_0.pos = 80;
        /* 2826 */     Vo_65525_0 vo_65525_01 = new Vo_65525_0();
        /* 2827 */     vo_65525_01.groupNo = 0;
        /* 2828 */     vo_65525_01.groupType = 1;
        /* 2829 */     vo_65525_01.info.put("value", Integer.valueOf(134));
        /* 2830 */     vo_65525_01.info.put("total_score", Integer.valueOf(10));
        /* 2831 */     vo_65525_01.info.put("type", Integer.valueOf(9065));
        /* 2832 */     vo_65525_01.info.put("rebuild_level", Integer.valueOf(0));
        /* 2833 */     vo_65525_01.info.put("str", "超级神兽丹");
        /* 2834 */     vo_65525_01.info.put("auto_fight", "5D260B43C0B706031C07");
        /* 2835 */     vo_65525_01.info.put("quality", "金色");
        /* 2836 */     vo_65525_01.info.put("damage_sel_rate", Integer.valueOf(400976));
        /* 2837 */     vo_65525_01.info.put("recognize_recognized", Integer.valueOf(2));
        /* 2838 */     vo_65525_01.info.put("owner_id", Integer.valueOf(3));
        /* 2839 */     ObjckListVo_65525_0.listvo_65525_0.add(vo_65525_01);
        /* 2840 */     linkedList.add(ObjckListVo_65525_0);
        /*      */
        /* 2842 */     ObjckListVo_65525_0 = new org.linlinjava.litemall.gameserver.data.vo.ListVo_65525_0();
        /*      */
        /* 2844 */     ObjckListVo_65525_0.pos = 1;
        /* 2845 */     vo_65525_01 = new Vo_65525_0();
        /* 2846 */     vo_65525_01.groupNo = 0;
        /* 2847 */     vo_65525_01.groupType = 1;
        /* 2848 */     vo_65525_01.info.put("owner_id", Integer.valueOf(3));
        /* 2849 */     vo_65525_01.info.put("value", Integer.valueOf(134));
        /* 2850 */     vo_65525_01.info.put("dunwu_times", Integer.valueOf(0));
        /* 2851 */     vo_65525_01.info.put("attrib", Integer.valueOf(1));
        /* 2852 */     vo_65525_01.info.put("gift", Integer.valueOf(0));
        /* 2853 */     vo_65525_01.info.put("total_score", Integer.valueOf(1));
        /* 2854 */     vo_65525_01.info.put("nick", Integer.valueOf(0));
        /* 2855 */     vo_65525_01.info.put("power", Integer.valueOf(0));
        /* 2856 */     vo_65525_01.info.put("wrestlescore", Integer.valueOf(0));
        /* 2857 */     vo_65525_01.info.put("skill", Integer.valueOf(0));
        /* 2858 */     vo_65525_01.info.put("store_exp", Integer.valueOf(0));
        /* 2859 */     vo_65525_01.info.put("metal", Integer.valueOf(0));
        /* 2860 */     vo_65525_01.info.put("amount", Integer.valueOf(1));
        /* 2861 */     vo_65525_01.info.put("type", Integer.valueOf(1134));
        /* 2862 */     vo_65525_01.info.put("rebuild_level", Integer.valueOf(300));
        /* 2863 */     vo_65525_01.info.put("color", Integer.valueOf(0));
        /* 2864 */     vo_65525_01.info.put("str", "乾坤扇");
        /* 2865 */     vo_65525_01.info.put("auto_fight", "5CF0E57A2F7EA403132B");
        /* 2866 */     vo_65525_01.info.put("suit_degree", Integer.valueOf(0));
        /* 2867 */     vo_65525_01.info.put("party_stage_party_name", Integer.valueOf(0));
        /* 2868 */     vo_65525_01.info.put("mailing_item_times", Integer.valueOf(0));
        /* 2869 */     vo_65525_01.info.put("quality", "蓝色");
        /* 2870 */     vo_65525_01.info.put("damage_sel_rate", Integer.valueOf(96784));
        /* 2871 */     vo_65525_01.info.put("recognize_recognized", Integer.valueOf(2));
        /* 2872 */     vo_65525_01.info.put("suit_enabled", Integer.valueOf(0));
        /* 2873 */     vo_65525_01.info.put("degree_32", Integer.valueOf(0));
        /* 2874 */     vo_65525_01.info.put("master", Integer.valueOf(0));
        /* 2875 */     ObjckListVo_65525_0.listvo_65525_0.add(vo_65525_01);
        /* 2876 */     vo_65525_01 = new Vo_65525_0();
        /* 2877 */     vo_65525_01.groupNo = 1;
        /* 2878 */     vo_65525_01.groupType = 2;
        /* 2879 */     vo_65525_01.info.put("mana", Integer.valueOf(37));
        /* 2880 */     vo_65525_01.info.put("accurate", Integer.valueOf(37));
        /* 2881 */     vo_65525_01.info.put("wiz", Integer.valueOf(3));
        /* 2882 */     vo_65525_01.info.put("dex", Integer.valueOf(13));
        /* 2883 */     vo_65525_01.info.put("def", Integer.valueOf(20));
        /* 2884 */     vo_65525_01.info.put("parry", Integer.valueOf(24));
        /* 2885 */     ObjckListVo_65525_0.listvo_65525_0.add(vo_65525_01);
        /* 2886 */     linkedList.add(ObjckListVo_65525_0);
        /* 2887 */     ObjckListVo_65525_0 = new org.linlinjava.litemall.gameserver.data.vo.ListVo_65525_0();
        /* 2888 */     ObjckListVo_65525_0.pos = 2;
        /* 2889 */     vo_65525_01 = new Vo_65525_0();
        /* 2890 */     vo_65525_01.groupNo = 0;
        /* 2891 */     vo_65525_01.groupType = 1;
        /* 2892 */     vo_65525_01.info.put("dunwu_times", Integer.valueOf(0));
        /* 2893 */     vo_65525_01.info.put("attrib", Integer.valueOf(1));
        /* 2894 */     vo_65525_01.info.put("gift", Integer.valueOf(0));
        /* 2895 */     vo_65525_01.info.put("total_score", Integer.valueOf(1));
        /* 2896 */     vo_65525_01.info.put("nick", Integer.valueOf(0));
        /* 2897 */     vo_65525_01.info.put("power", Integer.valueOf(0));
        /* 2898 */     vo_65525_01.info.put("wrestlescore", Integer.valueOf(0));
        /* 2899 */     vo_65525_01.info.put("skill", Integer.valueOf(0));
        /* 2900 */     vo_65525_01.info.put("store_exp", Integer.valueOf(0));
        /* 2901 */     vo_65525_01.info.put("amount", Integer.valueOf(2));
        /* 2902 */     vo_65525_01.info.put("type", Integer.valueOf(1201));
        /* 2903 */     vo_65525_01.info.put("rebuild_level", Integer.valueOf(150));
        /* 2904 */     vo_65525_01.info.put("color", Integer.valueOf(0));
        /* 2905 */     vo_65525_01.info.put("str", "方巾");
        /* 2906 */     vo_65525_01.info.put("auto_fight", "5CF0E57A2F7EA403132B");
        /* 2907 */     vo_65525_01.info.put("suit_degree", Integer.valueOf(0));
        /* 2908 */     vo_65525_01.info.put("party_stage_party_name", Integer.valueOf(0));
        /* 2909 */     vo_65525_01.info.put("mailing_item_times", Integer.valueOf(0));
        /* 2910 */     vo_65525_01.info.put("quality", "蓝色");
        /* 2911 */     vo_65525_01.info.put("damage_sel_rate", Integer.valueOf(96783));
        /* 2912 */     vo_65525_01.info.put("recognize_recognized", Integer.valueOf(2));
        /* 2913 */     vo_65525_01.info.put("suit_enabled", Integer.valueOf(0));
        /* 2914 */     vo_65525_01.info.put("degree_32", Integer.valueOf(0));
        /* 2915 */     vo_65525_01.info.put("master", Integer.valueOf(1));
        /* 2916 */     ObjckListVo_65525_0.listvo_65525_0.add(vo_65525_01);
        /* 2917 */     vo_65525_01 = new Vo_65525_0();
        /* 2918 */     vo_65525_01.groupNo = 1;
        /* 2919 */     vo_65525_01.groupType = 2;
        /* 2920 */     vo_65525_01.info.put("wiz", Integer.valueOf(3));
        /* 2921 */     vo_65525_01.info.put("dex", Integer.valueOf(13));
        /* 2922 */     vo_65525_01.info.put("def", Integer.valueOf(20));
        /* 2923 */     ObjckListVo_65525_0.listvo_65525_0.add(vo_65525_01);
        /* 2924 */     linkedList.add(ObjckListVo_65525_0);
        /* 2925 */     ObjckListVo_65525_0 = new org.linlinjava.litemall.gameserver.data.vo.ListVo_65525_0();
        /* 2926 */     ObjckListVo_65525_0.pos = 3;
        /* 2927 */     vo_65525_01 = new Vo_65525_0();
        /* 2928 */     vo_65525_01.groupNo = 0;
        /* 2929 */     vo_65525_01.groupType = 1;
        /* 2930 */     vo_65525_01.info.put("dunwu_times", Integer.valueOf(0));
        /* 2931 */     vo_65525_01.info.put("attrib", Integer.valueOf(1));
        /* 2932 */     vo_65525_01.info.put("gift", Integer.valueOf(0));
        /* 2933 */     vo_65525_01.info.put("total_score", Integer.valueOf(1));
        /* 2934 */     vo_65525_01.info.put("nick", Integer.valueOf(0));
        /* 2935 */     vo_65525_01.info.put("power", Integer.valueOf(0));
        /* 2936 */     vo_65525_01.info.put("wrestlescore", Integer.valueOf(0));
        /* 2937 */     vo_65525_01.info.put("skill", Integer.valueOf(0));
        /* 2938 */     vo_65525_01.info.put("store_exp", Integer.valueOf(0));
        /* 2939 */     vo_65525_01.info.put("amount", Integer.valueOf(3));
        /* 2940 */     vo_65525_01.info.put("type", Integer.valueOf(1222));
        /* 2941 */     vo_65525_01.info.put("rebuild_level", Integer.valueOf(300));
        /* 2942 */     vo_65525_01.info.put("color", Integer.valueOf(0));
        /* 2943 */     vo_65525_01.info.put("str", "方巾");
        /* 2944 */     vo_65525_01.info.put("auto_fight", "5CF0E50F2F7A9903132B");
        /* 2945 */     vo_65525_01.info.put("suit_degree", Integer.valueOf(0));
        /* 2946 */     vo_65525_01.info.put("party_stage_party_name", Integer.valueOf(0));
        /* 2947 */     vo_65525_01.info.put("mailing_item_times", Integer.valueOf(0));
        /* 2948 */     vo_65525_01.info.put("quality", "蓝色");
        /* 2949 */     vo_65525_01.info.put("damage_sel_rate", Integer.valueOf(96782));
        /* 2950 */     vo_65525_01.info.put("recognize_recognized", Integer.valueOf(2));
        /* 2951 */     vo_65525_01.info.put("suit_enabled", Integer.valueOf(0));
        /* 2952 */     vo_65525_01.info.put("degree_32", Integer.valueOf(0));
        /* 2953 */     vo_65525_01.info.put("master", Integer.valueOf(1));
        /* 2954 */     ObjckListVo_65525_0.listvo_65525_0.add(vo_65525_01);
        /* 2955 */     vo_65525_01 = new Vo_65525_0();
        /* 2956 */     vo_65525_01.groupNo = 1;
        /* 2957 */     vo_65525_01.groupType = 2;
        /* 2958 */     vo_65525_01.info.put("wiz", Integer.valueOf(14));
        /* 2959 */     vo_65525_01.info.put("dex", Integer.valueOf(24));
        /* 2960 */     vo_65525_01.info.put("def", Integer.valueOf(35));
        /* 2961 */     ObjckListVo_65525_0.listvo_65525_0.add(vo_65525_01);
        /* 2962 */     linkedList.add(ObjckListVo_65525_0);
        /* 2963 */     ObjckListVo_65525_0 = new org.linlinjava.litemall.gameserver.data.vo.ListVo_65525_0();
        /* 2964 */     ObjckListVo_65525_0.pos = 45;
        /* 2965 */     vo_65525_01 = new Vo_65525_0();
        /* 2966 */     vo_65525_01.groupNo = 0;
        /* 2967 */     vo_65525_01.groupType = 1;
        /* 2968 */     vo_65525_01.info.put("dunwu_times", Integer.valueOf(0));
        /* 2969 */     vo_65525_01.info.put("attrib", Integer.valueOf(1));
        /* 2970 */     vo_65525_01.info.put("gift", Integer.valueOf(0));
        /* 2971 */     vo_65525_01.info.put("total_score", Integer.valueOf(1));
        /* 2972 */     vo_65525_01.info.put("nick", Integer.valueOf(0));
        /* 2973 */     vo_65525_01.info.put("power", Integer.valueOf(0));
        /* 2974 */     vo_65525_01.info.put("wrestlescore", Integer.valueOf(0));
        /* 2975 */     vo_65525_01.info.put("skill", Integer.valueOf(0));
        /* 2976 */     vo_65525_01.info.put("store_exp", Integer.valueOf(0));
        /* 2977 */     vo_65525_01.info.put("amount", Integer.valueOf(10));
        /* 2978 */     vo_65525_01.info.put("type", Integer.valueOf(1244));
        /* 2979 */     vo_65525_01.info.put("rebuild_level", Integer.valueOf(150));
        /* 2980 */     vo_65525_01.info.put("color", Integer.valueOf(0));
        /* 2981 */     vo_65525_01.info.put("str", "麻鞋");
        /* 2982 */     vo_65525_01.info.put("auto_fight", "5CF0E50F2F7A9903132B");
        /* 2983 */     vo_65525_01.info.put("suit_degree", Integer.valueOf(0));
        /* 2984 */     vo_65525_01.info.put("party_stage_party_name", Integer.valueOf(0));
        /* 2985 */     vo_65525_01.info.put("mailing_item_times", Integer.valueOf(0));
        /* 2986 */     vo_65525_01.info.put("quality", "蓝色");
        /* 2987 */     vo_65525_01.info.put("damage_sel_rate", Integer.valueOf(96781));
        /* 2988 */     vo_65525_01.info.put("recognize_recognized", Integer.valueOf(2));
        /* 2989 */     vo_65525_01.info.put("suit_enabled", Integer.valueOf(0));
        /* 2990 */     vo_65525_01.info.put("degree_32", Integer.valueOf(0));
        /* 2991 */     vo_65525_01.info.put("master", Integer.valueOf(0));
        /* 2992 */     ObjckListVo_65525_0.listvo_65525_0.add(vo_65525_01);
        /* 2993 */     vo_65525_01 = new Vo_65525_0();
        /* 2994 */     vo_65525_01.groupNo = 1;
        /* 2995 */     vo_65525_01.groupType = 2;
        /* 2996 */     vo_65525_01.info.put("wiz", Integer.valueOf(5));
        /* 2997 */     vo_65525_01.info.put("parry", Integer.valueOf(24));
        /* 2998 */     ObjckListVo_65525_0.listvo_65525_0.add(vo_65525_01);
        /* 2999 */     linkedList.add(ObjckListVo_65525_0);
        /* 3000 */     return linkedList;
        /*      */   }
    /*      */
    /*      */   public static org.linlinjava.litemall.gameserver.data.vo.Vo_12285_0 a12285() {
        /* 3004 */     org.linlinjava.litemall.gameserver.data.vo.Vo_12285_0 vo_12285_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_12285_0();
        /* 3005 */     vo_12285_0.id = 16105;
        /* 3006 */     vo_12285_0.type = 4;
        /* 3007 */     return vo_12285_0;
        /*      */   }
    /*      */
    /**
     * MSG_UPDATE_APPEARANCE    更新外观
     */
    /*      */   public static org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0 MSG_UPDATE_APPEARANCE(Chara chara) {
        /* 3011 */     org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0 vo_61661_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0();
        /* 3012 */     vo_61661_0.id = chara.id;
        /* 3013 */     vo_61661_0.x = chara.x;
        /* 3014 */     vo_61661_0.y = chara.y;
        /* 3015 */     vo_61661_0.dir = 7;
        /* 3016 */     vo_61661_0.icon = chara.waiguan;
        /* 3017 */     vo_61661_0.weapon_icon = chara.weapon_icon;
        /* 3018 */     vo_61661_0.type = 1;
        /* 3019 */     vo_61661_0.sub_type = 0;
        /* 3020 */     vo_61661_0.owner_id = 0;
        /* 3021 */     vo_61661_0.leader_id = 0;
        /* 3022 */     vo_61661_0.name = chara.name;
        /* 3023 */     vo_61661_0.level = chara.level;
        /*      */
        /* 3025 */     vo_61661_0.title = chara.chenhao;
        /* 3026 */     vo_61661_0.family = chara.chenhao;
        /* 3027 */     vo_61661_0.partyname = chara.partyName;
        /* 3028 */     vo_61661_0.status = 0;
        /* 3029 */     vo_61661_0.special_icon = chara.special_icon;
        /* 3030 */     vo_61661_0.org_icon = chara.waiguan;
        /* 3031 */     vo_61661_0.suit_icon = chara.suit_icon;
        /* 3032 */     vo_61661_0.suit_light_effect = chara.suit_light_effect;
        /* 3033 */     vo_61661_0.mount_icon = chara.zuowaiguan;
        /* 3034 */     vo_61661_0.guard_icon = 0;
        /* 3035 */     vo_61661_0.pet_icon = chara.zuoqiwaiguan;
        /* 3036 */     vo_61661_0.shadow_icon = 0;
        /* 3037 */     vo_61661_0.shelter_icon = 0;
        /* 3038 */     vo_61661_0.alicename = "";
        /* 3039 */     vo_61661_0.gid = chara.uuid;
        /* 3040 */     vo_61661_0.camp = "";
        /* 3041 */     vo_61661_0.vip_type = 0;
        /* 3042 */     vo_61661_0.isHide = 0;
        /* 3043 */     vo_61661_0.moveSpeedPercent = chara.yidongsudu;
        /* 3044 */     vo_61661_0.score = 0;
        /* 3045 */     vo_61661_0.opacity = 0;
        /* 3046 */     vo_61661_0.masquerade = 0;
        /* 3047 */     vo_61661_0.upgradestate = 0;
        /* 3048 */     vo_61661_0.upgradetype = 0;
        /* 3049 */     vo_61661_0.obstacle = 0;
        /* 3050 */     if (chara.texiao_icon == 0) {
            /* 3051 */       vo_61661_0.light_effect_count = 0;
            /*      */     } else {
            /* 3053 */       vo_61661_0.light_effect_count = 1;
            /*      */     }
        /* 3055 */     vo_61661_0.effect = chara.texiao_icon;
        /* 3056 */     return vo_61661_0;
        /*      */   }
    /*      */
    /*      */   public static org.linlinjava.litemall.gameserver.data.vo.Vo_61589_0 a61589()
    /*      */   {
        /* 3061 */     org.linlinjava.litemall.gameserver.data.vo.Vo_61589_0 vo_61589_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_61589_0();
        /* 3062 */     vo_61589_0.key0 = "autoplay_party_voice";
        /* 3063 */     vo_61589_0.settingkey0 = 1;
        /* 3064 */     vo_61589_0.key1 = "total_switch";
        /* 3065 */     vo_61589_0.settingkey1 = 0;
        /* 3066 */     vo_61589_0.key2 = "push_world_boss";
        /* 3067 */     vo_61589_0.settingkey2 = 0;
        /* 3068 */     vo_61589_0.key3 = "ft_dun_yb";
        /* 3069 */     vo_61589_0.settingkey3 = 1;
        /* 3070 */     vo_61589_0.key4 = "refuse_shock";
        /* 3071 */     vo_61589_0.settingkey4 = 0;
        /* 3072 */     vo_61589_0.key5 = "refuse_be_joint";
        /* 3073 */     vo_61589_0.settingkey5 = 0;
        /* 3074 */     vo_61589_0.key6 = "refuse_rumor_msg";
        /* 3075 */     vo_61589_0.settingkey6 = 0;
        /* 3076 */     vo_61589_0.key7 = "apply_apprentice_mail";
        /* 3077 */     vo_61589_0.settingkey7 = 1;
        /* 3078 */     vo_61589_0.key8 = "refuse_lookon_msg";
        /* 3079 */     vo_61589_0.settingkey8 = 0;
        /* 3080 */     vo_61589_0.key9 = "hide_world_msg";
        /* 3081 */     vo_61589_0.settingkey9 = 0;
        /* 3082 */     vo_61589_0.key10 = "hide_rumor_msg";
        /* 3083 */     vo_61589_0.settingkey10 = 0;
        /* 3084 */     vo_61589_0.key11 = "friend_msg_bubble";
        /* 3085 */     vo_61589_0.settingkey11 = 1;
        /* 3086 */     vo_61589_0.key12 = "hide_team_msg";
        /* 3087 */     vo_61589_0.settingkey12 = 0;
        /* 3088 */     vo_61589_0.key13 = "refuse_all_msg";
        /* 3089 */     vo_61589_0.settingkey13 = 0;
        /* 3090 */     vo_61589_0.key14 = "sight_scope";
        /* 3091 */     vo_61589_0.settingkey14 = 1;
        /* 3092 */     vo_61589_0.key15 = "verify_be_added";
        /* 3093 */     vo_61589_0.settingkey15 = 0;
        /* 3094 */     vo_61589_0.key16 = "hide_party_msg";
        /* 3095 */     vo_61589_0.settingkey16 = 0;
        /* 3096 */     vo_61589_0.key17 = "refuse_stranger_msg";
        /* 3097 */     vo_61589_0.settingkey17 = 1;
        /* 3098 */     vo_61589_0.key18 = "refuse_family_msg";
        /* 3099 */     vo_61589_0.settingkey18 = 0;
        /* 3100 */     vo_61589_0.key19 = "refuse_world_msg";
        /* 3101 */     vo_61589_0.settingkey19 = 0;
        /* 3102 */     vo_61589_0.key20 = "refuse_be_added";
        /* 3103 */     vo_61589_0.settingkey20 = 0;
        /* 3104 */     vo_61589_0.key21 = "refuse_look_equip";
        /* 3105 */     vo_61589_0.settingkey21 = 0;
        /* 3106 */     vo_61589_0.key22 = "ft_lead_team";
        /* 3107 */     vo_61589_0.settingkey22 = 1;
        /* 3108 */     vo_61589_0.key23 = "push_chanchu_yaowang";
        /* 3109 */     vo_61589_0.settingkey23 = 0;
        /* 3110 */     vo_61589_0.key24 = "ft_recruit";
        /* 3111 */     vo_61589_0.settingkey24 = 1;
        /* 3112 */     vo_61589_0.key25 = "visit_house";
        /* 3113 */     vo_61589_0.settingkey25 = 0;
        /* 3114 */     vo_61589_0.key26 = "push_super_boss";
        /* 3115 */     vo_61589_0.settingkey26 = 0;
        /* 3116 */     vo_61589_0.key27 = "ft_inv_team";
        /* 3117 */     vo_61589_0.settingkey27 = 1;
        /* 3118 */     vo_61589_0.key28 = "music_value";
        /* 3119 */     vo_61589_0.settingkey28 = 127;
        /* 3120 */     vo_61589_0.key29 = "auto_reply_msg";
        /* 3121 */     vo_61589_0.settingkey29 = 0;
        /* 3122 */     vo_61589_0.key30 = "refuse_team_msg";
        /* 3123 */     vo_61589_0.settingkey30 = 0;
        /* 3124 */     vo_61589_0.key31 = "refuse_party_image";
        /* 3125 */     vo_61589_0.settingkey31 = 0;
        /* 3126 */     vo_61589_0.key32 = "award_supply_artifact";
        /* 3127 */     vo_61589_0.settingkey32 = 0;
        /* 3128 */     vo_61589_0.key33 = "refuse_wedding_msg";
        /* 3129 */     vo_61589_0.settingkey33 = 0;
        /* 3130 */     vo_61589_0.key34 = "forbidden_play_voice";
        /* 3131 */     vo_61589_0.settingkey34 = 0;
        /* 3132 */     vo_61589_0.key35 = "refuse_request_party";
        /* 3133 */     vo_61589_0.settingkey35 = 0;
        /* 3134 */     vo_61589_0.key36 = "push_shidao_dahui";
        /* 3135 */     vo_61589_0.settingkey36 = 1;
        /* 3136 */     vo_61589_0.key37 = "refuse_fight";
        /* 3137 */     vo_61589_0.settingkey37 = 0;
        /* 3138 */     vo_61589_0.key38 = "ft_req_team";
        /* 3139 */     vo_61589_0.settingkey38 = 1;
        /* 3140 */     vo_61589_0.key39 = "push_haidao_ruqin";
        /* 3141 */     vo_61589_0.settingkey39 = 1;
        /* 3142 */     vo_61589_0.key40 = "music_effect";
        /* 3143 */     vo_61589_0.settingkey40 = 127;
        /* 3144 */     vo_61589_0.key41 = "refuse_exchange";
        /* 3145 */     vo_61589_0.settingkey41 = 0;
        /* 3146 */     vo_61589_0.key42 = "touch_furniture_lock";
        /* 3147 */     vo_61589_0.settingkey42 = 0;
        /* 3148 */     vo_61589_0.key43 = "ft_use_item";
        /* 3149 */     vo_61589_0.settingkey43 = 1;
        /* 3150 */     vo_61589_0.key44 = "refuse_raid_msg";
        /* 3151 */     vo_61589_0.settingkey44 = 0;
        /* 3152 */     vo_61589_0.key45 = "combat_auto_talk";
        /* 3153 */     vo_61589_0.settingkey45 = 0;
        /* 3154 */     vo_61589_0.key46 = "autoplay_team_voice";
        /* 3155 */     vo_61589_0.settingkey46 = 1;
        /* 3156 */     vo_61589_0.key47 = "refuse_party_msg";
        /* 3157 */     vo_61589_0.settingkey47 = 0;
        /* 3158 */     vo_61589_0.key48 = "push_biaoxing_wanli";
        /* 3159 */     vo_61589_0.settingkey48 = 1;
        /* 3160 */     vo_61589_0.key49 = "refuse_tell_msg";
        /* 3161 */     vo_61589_0.settingkey49 = 0;
        /* 3162 */     vo_61589_0.key50 = "hide_system_msg";
        /* 3163 */     vo_61589_0.settingkey50 = 0;
        /* 3164 */     vo_61589_0.key51 = "award_supply_pet";
        /* 3165 */     vo_61589_0.settingkey51 = 0;
        /* 3166 */     vo_61589_0.key52 = "hide_current_msg";
        /* 3167 */     vo_61589_0.settingkey52 = 0;
        /* 3168 */     vo_61589_0.key53 = "refuse_warcraft";
        /* 3169 */     vo_61589_0.settingkey53 = 0;
        /* 3170 */     vo_61589_0.key54 = "push_shuadao_double";
        /* 3171 */     vo_61589_0.settingkey54 = 1;
        /* 3172 */     vo_61589_0.key55 = "refuse_friend_msg";
        /* 3173 */     vo_61589_0.settingkey55 = 0;
        /* 3174 */     vo_61589_0.key56 = "push_week_act";
        /* 3175 */     vo_61589_0.settingkey56 = 0;
        /* 3176 */     vo_61589_0.key57 = "window_mode";
        /* 3177 */     vo_61589_0.settingkey57 = 1;
        /* 3178 */     vo_61589_0.key58 = "ft_change_look";
        /* 3179 */     vo_61589_0.settingkey58 = 1;
        /* 3180 */     vo_61589_0.key59 = "ft_change_team_seq";
        /* 3181 */     vo_61589_0.settingkey59 = 1;
        /* 3182 */     vo_61589_0.key60 = "refuse_cs_msg";
        /* 3183 */     vo_61589_0.settingkey60 = 0;
        /* 3184 */     return vo_61589_0;
        /*      */   }
    /*      */
    /*      */   public static org.linlinjava.litemall.gameserver.data.vo.Vo_65499_0 a65499() {
        /* 3188 */     org.linlinjava.litemall.gameserver.data.vo.Vo_65499_0 vo_65499_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_65499_0();
        /* 3189 */     vo_65499_0.para = "";
        /* 3190 */     vo_65499_0.type = 0;
        /* 3191 */     vo_65499_0.count = 61;
        /*      */
        /* 3193 */     vo_65499_0.name0 = "羽化丹";
        /* 3194 */     vo_65499_0.barcode0 = "R0002019";
        /* 3195 */     vo_65499_0.for_sale0 = 2;
        /* 3196 */     vo_65499_0.show_pos0 = 16;
        /* 3197 */     vo_65499_0.rpos0 = 3;
        /* 3198 */     vo_65499_0.sale_quota0 = 65535;
        /* 3199 */     vo_65499_0.recommend0 = 3;
        /* 3200 */     vo_65499_0.coin0 = 518;
        /* 3201 */     vo_65499_0.discount0 = 100;
        /* 3202 */     vo_65499_0.discountTime0 = 429496729;
        /* 3203 */     vo_65499_0.type0 = 2;
        /* 3204 */     vo_65499_0.quota_limit0 = 65535;
        /* 3205 */     vo_65499_0.must_vip0 = 0;
        /* 3206 */     vo_65499_0.is_gift0 = 0;
        /* 3207 */     vo_65499_0.follow_pet_type0 = 255;
        /*      */
        /* 3209 */     vo_65499_0.name1 = "装备共鸣石";
        /* 3210 */     vo_65499_0.barcode1 = "R0002020";
        /* 3211 */     vo_65499_0.for_sale1 = 2;
        /* 3212 */     vo_65499_0.show_pos1 = 9;
        /* 3213 */     vo_65499_0.rpos1 = 7;
        /* 3214 */     vo_65499_0.sale_quota1 = 65535;
        /* 3215 */     vo_65499_0.recommend1 = 3;
        /* 3216 */     vo_65499_0.coin1 = 328;
        /* 3217 */     vo_65499_0.discount1 = 100;
        /* 3218 */     vo_65499_0.discountTime1 = 429496729;
        /* 3219 */     vo_65499_0.type1 = 2;
        /* 3220 */     vo_65499_0.quota_limit1 = 65535;
        /* 3221 */     vo_65499_0.must_vip1 = 0;
        /* 3222 */     vo_65499_0.is_gift1 = 0;
        /* 3223 */     vo_65499_0.follow_pet_type1 = 255;
        /*      */
        /* 3225 */     vo_65499_0.name2 = "超级晶石";
        /* 3226 */     vo_65499_0.barcode2 = "R0002006";
        /* 3227 */     vo_65499_0.for_sale2 = 2;
        /* 3228 */     vo_65499_0.show_pos2 = 6;
        /* 3229 */     vo_65499_0.rpos2 = 0;
        /* 3230 */     vo_65499_0.sale_quota2 = 65535;
        /* 3231 */     vo_65499_0.recommend2 = 0;
        /* 3232 */     vo_65499_0.coin2 = 108;
        /* 3233 */     vo_65499_0.discount2 = 100;
        /* 3234 */     vo_65499_0.discountTime2 = 429496729;
        /* 3235 */     vo_65499_0.type2 = 2;
        /* 3236 */     vo_65499_0.quota_limit2 = 65535;
        /* 3237 */     vo_65499_0.must_vip2 = 0;
        /* 3238 */     vo_65499_0.is_gift2 = 0;
        /* 3239 */     vo_65499_0.follow_pet_type2 = 255;
        /*      */
        /* 3241 */     vo_65499_0.name3 = "高级驯兽诀";
        /* 3242 */     vo_65499_0.barcode3 = "R0003010";
        /* 3243 */     vo_65499_0.for_sale3 = 2;
        /* 3244 */     vo_65499_0.show_pos3 = 12;
        /* 3245 */     vo_65499_0.rpos3 = 0;
        /* 3246 */     vo_65499_0.sale_quota3 = 65535;
        /* 3247 */     vo_65499_0.recommend3 = 0;
        /* 3248 */     vo_65499_0.coin3 = 800;
        /* 3249 */     vo_65499_0.discount3 = 100;
        /* 3250 */     vo_65499_0.discountTime3 = 429496729;
        /* 3251 */     vo_65499_0.type3 = 3;
        /* 3252 */     vo_65499_0.quota_limit3 = 65535;
        /* 3253 */     vo_65499_0.must_vip3 = 0;
        /* 3254 */     vo_65499_0.is_gift3 = 0;
        /* 3255 */     vo_65499_0.follow_pet_type3 = 255;
        /*      */
        /* 3257 */     vo_65499_0.name4 = "灵物囊";
        /* 3258 */     vo_65499_0.barcode4 = "R0002010";
        /* 3259 */     vo_65499_0.for_sale4 = 1;
        /* 3260 */     vo_65499_0.show_pos4 = 11;
        /* 3261 */     vo_65499_0.rpos4 = 0;
        /* 3262 */     vo_65499_0.sale_quota4 = 65535;
        /* 3263 */     vo_65499_0.recommend4 = 0;
        /* 3264 */     vo_65499_0.coin4 = 398;
        /* 3265 */     vo_65499_0.discount4 = 100;
        /* 3266 */     vo_65499_0.discountTime4 = 429496729;
        /* 3267 */     vo_65499_0.type4 = 2;
        /* 3268 */     vo_65499_0.quota_limit4 = 65535;
        /* 3269 */     vo_65499_0.must_vip4 = 0;
        /* 3270 */     vo_65499_0.is_gift4 = 0;
        /* 3271 */     vo_65499_0.follow_pet_type4 = 255;
        /* 3272 */     vo_65499_0.name5 = "超级灵石";
        /* 3273 */     vo_65499_0.barcode5 = "R0002005";
        /* 3274 */     vo_65499_0.for_sale5 = 2;
        /* 3275 */     vo_65499_0.show_pos5 = 5;
        /* 3276 */     vo_65499_0.rpos5 = 0;
        /* 3277 */     vo_65499_0.sale_quota5 = 65535;
        /* 3278 */     vo_65499_0.recommend5 = 0;
        /* 3279 */     vo_65499_0.coin5 = 398;
        /* 3280 */     vo_65499_0.discount5 = 100;
        /* 3281 */     vo_65499_0.discountTime5 = 429496729;
        /* 3282 */     vo_65499_0.type5 = 2;
        /* 3283 */     vo_65499_0.quota_limit5 = 65535;
        /* 3284 */     vo_65499_0.must_vip5 = 0;
        /* 3285 */     vo_65499_0.is_gift5 = 0;
        /* 3286 */     vo_65499_0.follow_pet_type5 = 255;
        /* 3287 */     vo_65499_0.name6 = "神木鼎";
        /* 3288 */     vo_65499_0.barcode6 = "R0003008";
        /* 3289 */     vo_65499_0.for_sale6 = 1;
        /* 3290 */     vo_65499_0.show_pos6 = 10;
        /* 3291 */     vo_65499_0.rpos6 = 0;
        /* 3292 */     vo_65499_0.sale_quota6 = 65535;
        /* 3293 */     vo_65499_0.recommend6 = 0;
        /* 3294 */     vo_65499_0.coin6 = 328;
        /* 3295 */     vo_65499_0.discount6 = 100;
        /* 3296 */     vo_65499_0.discountTime6 = 429496729;
        /* 3297 */     vo_65499_0.type6 = 3;
        /* 3298 */     vo_65499_0.quota_limit6 = 65535;
        /* 3299 */     vo_65499_0.must_vip6 = 0;
        /* 3300 */     vo_65499_0.is_gift6 = 0;
        /* 3301 */     vo_65499_0.follow_pet_type6 = 255;
        /* 3302 */     vo_65499_0.name7 = "法玲珑";
        /* 3303 */     vo_65499_0.barcode7 = "R0003002";
        /* 3304 */     vo_65499_0.for_sale7 = 2;
        /* 3305 */     vo_65499_0.show_pos7 = 2;
        /* 3306 */     vo_65499_0.rpos7 = 0;
        /* 3307 */     vo_65499_0.sale_quota7 = 65535;
        /* 3308 */     vo_65499_0.recommend7 = 0;
        /* 3309 */     vo_65499_0.coin7 = 618;
        /* 3310 */     vo_65499_0.discount7 = 100;
        /* 3311 */     vo_65499_0.discountTime7 = 429496729;
        /* 3312 */     vo_65499_0.type7 = 3;
        /* 3313 */     vo_65499_0.quota_limit7 = 65535;
        /* 3314 */     vo_65499_0.must_vip7 = 0;
        /* 3315 */     vo_65499_0.is_gift7 = 0;
        /* 3316 */     vo_65499_0.follow_pet_type7 = 255;
        /* 3317 */     vo_65499_0.name8 = "超级粉水晶";
        /* 3318 */     vo_65499_0.barcode8 = "R0002004";
        /* 3319 */     vo_65499_0.for_sale8 = 2;
        /* 3320 */     vo_65499_0.show_pos8 = 4;
        /* 3321 */     vo_65499_0.rpos8 = 0;
        /* 3322 */     vo_65499_0.sale_quota8 = 65535;
        /* 3323 */     vo_65499_0.recommend8 = 0;
        /* 3324 */     vo_65499_0.coin8 = 2800;
        /* 3325 */     vo_65499_0.discount8 = 100;
        /* 3326 */     vo_65499_0.discountTime8 = 429496729;
        /* 3327 */     vo_65499_0.type8 = 2;
        /* 3328 */     vo_65499_0.quota_limit8 = 65535;
        /* 3329 */     vo_65499_0.must_vip8 = 0;
        /* 3330 */     vo_65499_0.is_gift8 = 0;
        /* 3331 */     vo_65499_0.follow_pet_type8 = 255;
        /* 3332 */     vo_65499_0.name9 = "天书";
        /* 3333 */     vo_65499_0.barcode9 = "R0002015";
        /* 3334 */     vo_65499_0.for_sale9 = 1;
        /* 3335 */     vo_65499_0.show_pos9 = 17;
        /* 3336 */     vo_65499_0.rpos9 = 5;
        /* 3337 */     vo_65499_0.sale_quota9 = 65535;
        /* 3338 */     vo_65499_0.recommend9 = 3;
        /* 3339 */     vo_65499_0.coin9 = 318;
        /* 3340 */     vo_65499_0.discount9 = 100;
        /* 3341 */     vo_65499_0.discountTime9 = 429496729;
        /* 3342 */     vo_65499_0.type9 = 2;
        /* 3343 */     vo_65499_0.quota_limit9 = 65535;
        /* 3344 */     vo_65499_0.must_vip9 = 0;
        /* 3345 */     vo_65499_0.is_gift9 = 0;
        /* 3346 */     vo_65499_0.follow_pet_type9 = 255;
        /* 3347 */     vo_65499_0.name10 = "吉祥天·90天";
        /* 3348 */     vo_65499_0.barcode10 = "R0005040";
        /* 3349 */     vo_65499_0.for_sale10 = 1;
        /* 3350 */     vo_65499_0.show_pos10 = 21;
        /* 3351 */     vo_65499_0.rpos10 = 0;
        /* 3352 */     vo_65499_0.sale_quota10 = 65535;
        /* 3353 */     vo_65499_0.recommend10 = 0;
        /* 3354 */     vo_65499_0.coin10 = 6888;
        /* 3355 */     vo_65499_0.discount10 = 100;
        /* 3356 */     vo_65499_0.discountTime10 = 429496729;
        /* 3357 */     vo_65499_0.type10 = 4;
        /* 3358 */     vo_65499_0.quota_limit10 = 65535;
        /* 3359 */     vo_65499_0.must_vip10 = 0;
        /* 3360 */     vo_65499_0.is_gift10 = 0;
        /* 3361 */     vo_65499_0.follow_pet_type10 = 1;
        /* 3362 */     vo_65499_0.name11 = "中级法玲珑";
        /* 3363 */     vo_65499_0.barcode11 = "R0003013";
        /* 3364 */     vo_65499_0.for_sale11 = 2;
        /* 3365 */     vo_65499_0.show_pos11 = 4;
        /* 3366 */     vo_65499_0.rpos11 = 0;
        /* 3367 */     vo_65499_0.sale_quota11 = 65535;
        /* 3368 */     vo_65499_0.recommend11 = 0;
        /* 3369 */     vo_65499_0.coin11 = 1400;
        /* 3370 */     vo_65499_0.discount11 = 100;
        /* 3371 */     vo_65499_0.discountTime11 = 429496729;
        /* 3372 */     vo_65499_0.type11 = 3;
        /* 3373 */     vo_65499_0.quota_limit11 = 65535;
        /* 3374 */     vo_65499_0.must_vip11 = 0;
        /* 3375 */     vo_65499_0.is_gift11 = 0;
        /* 3376 */     vo_65499_0.follow_pet_type11 = 255;
        /* 3377 */     vo_65499_0.name12 = "五行合缘露";
        /* 3378 */     vo_65499_0.barcode12 = "R0005014";
        /* 3379 */     vo_65499_0.for_sale12 = 2;
        /* 3380 */     vo_65499_0.show_pos12 = 6;
        /* 3381 */     vo_65499_0.rpos12 = 0;
        /* 3382 */     vo_65499_0.sale_quota12 = 65535;
        /* 3383 */     vo_65499_0.recommend12 = 0;
        /* 3384 */     vo_65499_0.coin12 = 328;
        /* 3385 */     vo_65499_0.discount12 = 100;
        /* 3386 */     vo_65499_0.discountTime12 = 429496729;
        /* 3387 */     vo_65499_0.type12 = 4;
        /* 3388 */     vo_65499_0.quota_limit12 = 65535;
        /* 3389 */     vo_65499_0.must_vip12 = 0;
        /* 3390 */     vo_65499_0.is_gift12 = 0;
        /* 3391 */     vo_65499_0.follow_pet_type12 = 255;
        /* 3392 */     vo_65499_0.name13 = "点化丹";
        /* 3393 */     vo_65499_0.barcode13 = "R0002014";
        /* 3394 */     vo_65499_0.for_sale13 = 2;
        /* 3395 */     vo_65499_0.show_pos13 = 15;
        /* 3396 */     vo_65499_0.rpos13 = 2;
        /* 3397 */     vo_65499_0.sale_quota13 = 65535;
        /* 3398 */     vo_65499_0.recommend13 = 3;
        /* 3399 */     vo_65499_0.coin13 = 328;
        /* 3400 */     vo_65499_0.discount13 = 100;
        /* 3401 */     vo_65499_0.discountTime13 = 429496729;
        /* 3402 */     vo_65499_0.type13 = 2;
        /* 3403 */     vo_65499_0.quota_limit13 = 65535;
        /* 3404 */     vo_65499_0.must_vip13 = 0;
        /* 3405 */     vo_65499_0.is_gift13 = 0;
        /* 3406 */     vo_65499_0.follow_pet_type13 = 255;
        /* 3407 */     vo_65499_0.name14 = "混沌玉";
        /* 3408 */     vo_65499_0.barcode14 = "R0002008";
        /* 3409 */     vo_65499_0.for_sale14 = 2;
        /* 3410 */     vo_65499_0.show_pos14 = 8;
        /* 3411 */     vo_65499_0.rpos14 = 0;
        /* 3412 */     vo_65499_0.sale_quota14 = 65535;
        /* 3413 */     vo_65499_0.recommend14 = 0;
        /* 3414 */     vo_65499_0.coin14 = 518;
        /* 3415 */     vo_65499_0.discount14 = 100;
        /* 3416 */     vo_65499_0.discountTime14 = 429496729;
        /* 3417 */     vo_65499_0.type14 = 2;
        /* 3418 */     vo_65499_0.quota_limit14 = 65535;
        /* 3419 */     vo_65499_0.must_vip14 = 0;
        /* 3420 */     vo_65499_0.is_gift14 = 0;
        /* 3421 */     vo_65499_0.follow_pet_type14 = 255;
        /* 3422 */     vo_65499_0.name15 = "如意年·30天";
        /* 3423 */     vo_65499_0.barcode15 = "R0005037";
        /* 3424 */     vo_65499_0.for_sale15 = 1;
        /* 3425 */     vo_65499_0.show_pos15 = 18;
        /* 3426 */     vo_65499_0.rpos15 = 0;
        /* 3427 */     vo_65499_0.sale_quota15 = 65535;
        /* 3428 */     vo_65499_0.recommend15 = 0;
        /* 3429 */     vo_65499_0.coin15 = 2888;
        /* 3430 */     vo_65499_0.discount15 = 100;
        /* 3431 */     vo_65499_0.discountTime15 = 429496729;
        /* 3432 */     vo_65499_0.type15 = 4;
        /* 3433 */     vo_65499_0.quota_limit15 = 65535;
        /* 3434 */     vo_65499_0.must_vip15 = 0;
        /* 3435 */     vo_65499_0.is_gift15 = 0;
        /* 3436 */     vo_65499_0.follow_pet_type15 = 1;
        /* 3437 */     vo_65499_0.name16 = "宠物顿悟丹";
        /* 3438 */     vo_65499_0.barcode16 = "R0002018";
        /* 3439 */     vo_65499_0.for_sale16 = 2;
        /* 3440 */     vo_65499_0.show_pos16 = 20;
        /* 3441 */     vo_65499_0.rpos16 = 0;
        /* 3442 */     vo_65499_0.sale_quota16 = 65535;
        /* 3443 */     vo_65499_0.recommend16 = 0;
        /* 3444 */     vo_65499_0.coin16 = 328;
        /* 3445 */     vo_65499_0.discount16 = 100;
        /* 3446 */     vo_65499_0.discountTime16 = 429496729;
        /* 3447 */     vo_65499_0.type16 = 2;
        /* 3448 */     vo_65499_0.quota_limit16 = 65535;
        /* 3449 */     vo_65499_0.must_vip16 = 0;
        /* 3450 */     vo_65499_0.is_gift16 = 0;
        /* 3451 */     vo_65499_0.follow_pet_type16 = 255;
        /* 3452 */     vo_65499_0.name17 = "点红烛·30天";
        /* 3453 */     vo_65499_0.barcode17 = "R0005031";
        /* 3454 */     vo_65499_0.for_sale17 = 1;
        /* 3455 */     vo_65499_0.show_pos17 = 16;
        /* 3456 */     vo_65499_0.rpos17 = 0;
        /* 3457 */     vo_65499_0.sale_quota17 = 65535;
        /* 3458 */     vo_65499_0.recommend17 = 0;
        /* 3459 */     vo_65499_0.coin17 = 2888;
        /* 3460 */     vo_65499_0.discount17 = 100;
        /* 3461 */     vo_65499_0.discountTime17 = 429496729;
        /* 3462 */     vo_65499_0.type17 = 4;
        /* 3463 */     vo_65499_0.quota_limit17 = 65535;
        /* 3464 */     vo_65499_0.must_vip17 = 0;
        /* 3465 */     vo_65499_0.is_gift17 = 0;
        /* 3466 */     vo_65499_0.follow_pet_type17 = 255;
        /* 3467 */     vo_65499_0.name18 = "如意年·90天";
        /* 3468 */     vo_65499_0.barcode18 = "R0005038";
        /* 3469 */     vo_65499_0.for_sale18 = 1;
        /* 3470 */     vo_65499_0.show_pos18 = 19;
        /* 3471 */     vo_65499_0.rpos18 = 11;
        /* 3472 */     vo_65499_0.sale_quota18 = 65535;
        /* 3473 */     vo_65499_0.recommend18 = 3;
        /* 3474 */     vo_65499_0.coin18 = 6888;
        /* 3475 */     vo_65499_0.discount18 = 100;
        /* 3476 */     vo_65499_0.discountTime18 = 429496729;
        /* 3477 */     vo_65499_0.type18 = 4;
        /* 3478 */     vo_65499_0.quota_limit18 = 65535;
        /* 3479 */     vo_65499_0.must_vip18 = 0;
        /* 3480 */     vo_65499_0.is_gift18 = 0;
        /* 3481 */     vo_65499_0.follow_pet_type18 = 1;
        /* 3482 */     vo_65499_0.name19 = "超级藏宝图";
        /* 3483 */     vo_65499_0.barcode19 = "R0004001";
        /* 3484 */     vo_65499_0.for_sale19 = 1;
        /* 3485 */     vo_65499_0.show_pos19 = 1;
        /* 3486 */     vo_65499_0.rpos19 = 5;
        /* 3487 */     vo_65499_0.sale_quota19 = 65535;
        /* 3488 */     vo_65499_0.recommend19 = 3;
        /* 3489 */     vo_65499_0.coin19 = 108;
        /* 3490 */     vo_65499_0.discount19 = 100;
        /* 3491 */     vo_65499_0.discountTime19 = 429496729;
        /* 3492 */     vo_65499_0.type19 = 4;
        /* 3493 */     vo_65499_0.quota_limit19 = 65535;
        /* 3494 */     vo_65499_0.must_vip19 = 0;
        /* 3495 */     vo_65499_0.is_gift19 = 0;
        /* 3496 */     vo_65499_0.follow_pet_type19 = 255;
        /* 3497 */     vo_65499_0.name20 = "紫气鸿蒙";
        /* 3498 */     vo_65499_0.barcode20 = "R0003011";
        /* 3499 */     vo_65499_0.for_sale20 = 2;
        /* 3500 */     vo_65499_0.show_pos20 = 13;
        /* 3501 */     vo_65499_0.rpos20 = 0;
        /* 3502 */     vo_65499_0.sale_quota20 = 65535;
        /* 3503 */     vo_65499_0.recommend20 = 0;
        /* 3504 */     vo_65499_0.coin20 = 418;
        /* 3505 */     vo_65499_0.discount20 = 100;
        /* 3506 */     vo_65499_0.discountTime20 = 429496729;
        /* 3507 */     vo_65499_0.type20 = 3;
        /* 3508 */     vo_65499_0.quota_limit20 = 65535;
        /* 3509 */     vo_65499_0.must_vip20 = 0;
        /* 3510 */     vo_65499_0.is_gift20 = 0;
        /* 3511 */     vo_65499_0.follow_pet_type20 = 255;
        /* 3512 */     vo_65499_0.name21 = "中级血玲珑";
        /* 3513 */     vo_65499_0.barcode21 = "R0003012";
        /* 3514 */     vo_65499_0.for_sale21 = 2;
        /* 3515 */     vo_65499_0.show_pos21 = 3;
        /* 3516 */     vo_65499_0.rpos21 = 0;
        /* 3517 */     vo_65499_0.sale_quota21 = 65535;
        /* 3518 */     vo_65499_0.recommend21 = 0;
        /* 3519 */     vo_65499_0.coin21 = 418;
        /* 3520 */     vo_65499_0.discount21 = 100;
        /* 3521 */     vo_65499_0.discountTime21 = 429496729;
        /* 3522 */     vo_65499_0.type21 = 3;
        /* 3523 */     vo_65499_0.quota_limit21 = 65535;
        /* 3524 */     vo_65499_0.must_vip21 = 0;
        /* 3525 */     vo_65499_0.is_gift21 = 0;
        /* 3526 */     vo_65499_0.follow_pet_type21 = 255;
        /* 3527 */     vo_65499_0.name22 = "仙魔散";
        /* 3528 */     vo_65499_0.barcode22 = "R0005015";
        /* 3529 */     vo_65499_0.for_sale22 = 2;
        /* 3530 */     vo_65499_0.show_pos22 = 7;
        /* 3531 */     vo_65499_0.rpos22 = 0;
        /* 3532 */     vo_65499_0.sale_quota22 = 65535;
        /* 3533 */     vo_65499_0.recommend22 = 0;
        /* 3534 */     vo_65499_0.coin22 = 328;
        /* 3535 */     vo_65499_0.discount22 = 100;
        /* 3536 */     vo_65499_0.discountTime22 = 429496729;
        /* 3537 */     vo_65499_0.type22 = 4;
        /* 3538 */     vo_65499_0.quota_limit22 = 65535;
        /* 3539 */     vo_65499_0.must_vip22 = 0;
        /* 3540 */     vo_65499_0.is_gift22 = 0;
        /* 3541 */     vo_65499_0.follow_pet_type22 = 255;
        /* 3542 */     vo_65499_0.name23 = "引天长歌·30天";
        /* 3543 */     vo_65499_0.barcode23 = "R0005036";
        /* 3544 */     vo_65499_0.for_sale23 = 1;
        /* 3545 */     vo_65499_0.show_pos23 = 24;
        /* 3546 */     vo_65499_0.rpos23 = 0;
        /* 3547 */     vo_65499_0.sale_quota23 = 65535;
        /* 3548 */     vo_65499_0.recommend23 = 0;
        /* 3549 */     vo_65499_0.coin23 = 2888;
        /* 3550 */     vo_65499_0.discount23 = 100;
        /* 3551 */     vo_65499_0.discountTime23 = 429496729;
        /* 3552 */     vo_65499_0.type23 = 4;
        /* 3553 */     vo_65499_0.quota_limit23 = 65535;
        /* 3554 */     vo_65499_0.must_vip23 = 0;
        /* 3555 */     vo_65499_0.is_gift23 = 0;
        /* 3556 */     vo_65499_0.follow_pet_type23 = 255;
        /* 3557 */     vo_65499_0.name24 = "星火昭·30天";
        /* 3558 */     vo_65499_0.barcode24 = "R0005029";
        /* 3559 */     vo_65499_0.for_sale24 = 1;
        /* 3560 */     vo_65499_0.show_pos24 = 14;
        /* 3561 */     vo_65499_0.rpos24 = 0;
        /* 3562 */     vo_65499_0.sale_quota24 = 65535;
        /* 3563 */     vo_65499_0.recommend24 = 0;
        /* 3564 */     vo_65499_0.coin24 = 2888;
        /* 3565 */     vo_65499_0.discount24 = 100;
        /* 3566 */     vo_65499_0.discountTime24 = 429496729;
        /* 3567 */     vo_65499_0.type24 = 4;
        /* 3568 */     vo_65499_0.quota_limit24 = 65535;
        /* 3569 */     vo_65499_0.must_vip24 = 0;
        /* 3570 */     vo_65499_0.is_gift24 = 0;
        /* 3571 */     vo_65499_0.follow_pet_type24 = 255;
        /* 3572 */     vo_65499_0.name25 = "剑魄琴心·永久";
        /* 3573 */     vo_65499_0.barcode25 = "R0005034";
        /* 3574 */     vo_65499_0.for_sale25 = 1;
        /* 3575 */     vo_65499_0.show_pos25 = 23;
        /* 3576 */     vo_65499_0.rpos25 = 9;
        /* 3577 */     vo_65499_0.sale_quota25 = 65535;
        /* 3578 */     vo_65499_0.recommend25 = 3;
        /* 3579 */     vo_65499_0.coin25 = 26888;
        /* 3580 */     vo_65499_0.discount25 = 100;
        /* 3581 */     vo_65499_0.discountTime25 = 429496729;
        /* 3582 */     vo_65499_0.type25 = 4;
        /* 3583 */     vo_65499_0.quota_limit25 = 65535;
        /* 3584 */     vo_65499_0.must_vip25 = 0;
        /* 3585 */     vo_65499_0.is_gift25 = 0;
        /* 3586 */     vo_65499_0.follow_pet_type25 = 255;
        /* 3587 */     vo_65499_0.name26 = "日耀辰辉·永久";
        /* 3588 */     vo_65499_0.barcode26 = "R0005026";
        /* 3589 */     vo_65499_0.for_sale26 = 1;
        /* 3590 */     vo_65499_0.show_pos26 = 11;
        /* 3591 */     vo_65499_0.rpos26 = 0;
        /* 3592 */     vo_65499_0.sale_quota26 = 65535;
        /* 3593 */     vo_65499_0.recommend26 = 0;
        /* 3594 */     vo_65499_0.coin26 = 26888;
        /* 3595 */     vo_65499_0.discount26 = 100;
        /* 3596 */     vo_65499_0.discountTime26 = 429496729;
        /* 3597 */     vo_65499_0.type26 = 4;
        /* 3598 */     vo_65499_0.quota_limit26 = 65535;
        /* 3599 */     vo_65499_0.must_vip26 = 0;
        /* 3600 */     vo_65499_0.is_gift26 = 0;
        /* 3601 */     vo_65499_0.follow_pet_type26 = 255;
        /* 3602 */     vo_65499_0.name27 = "风灵丸";
        /* 3603 */     vo_65499_0.barcode27 = "R0002011";
        /* 3604 */     vo_65499_0.for_sale27 = 2;
        /* 3605 */     vo_65499_0.show_pos27 = 12;
        /* 3606 */     vo_65499_0.rpos27 = 0;
        /* 3607 */     vo_65499_0.sale_quota27 = 65535;
        /* 3608 */     vo_65499_0.recommend27 = 0;
        /* 3609 */     vo_65499_0.coin27 = 328;
        /* 3610 */     vo_65499_0.discount27 = 100;
        /* 3611 */     vo_65499_0.discountTime27 = 429496729;
        /* 3612 */     vo_65499_0.type27 = 2;
        /* 3613 */     vo_65499_0.quota_limit27 = 65535;
        /* 3614 */     vo_65499_0.must_vip27 = 0;
        /* 3615 */     vo_65499_0.is_gift27 = 0;
        /* 3616 */     vo_65499_0.follow_pet_type27 = 255;
        /* 3617 */     vo_65499_0.name28 = "超级仙风散";
        /* 3618 */     vo_65499_0.barcode28 = "R0003007";
        /* 3619 */     vo_65499_0.for_sale28 = 2;
        /* 3620 */     vo_65499_0.show_pos28 = 9;
        /* 3621 */     vo_65499_0.rpos28 = 4;
        /* 3622 */     vo_65499_0.sale_quota28 = 65535;
        /* 3623 */     vo_65499_0.recommend28 = 3;
        /* 3624 */     vo_65499_0.coin28 = 108;
        /* 3625 */     vo_65499_0.discount28 = 100;
        /* 3626 */     vo_65499_0.discountTime28 = 429496729;
        /* 3627 */     vo_65499_0.type28 = 3;
        /* 3628 */     vo_65499_0.quota_limit28 = 65535;
        /* 3629 */     vo_65499_0.must_vip28 = 0;
        /* 3630 */     vo_65499_0.is_gift28 = 0;
        /* 3631 */     vo_65499_0.follow_pet_type28 = 255;
        /* 3632 */     vo_65499_0.name29 = "点红烛·永久";
        /* 3633 */     vo_65499_0.barcode29 = "R0005032";
        /* 3634 */     vo_65499_0.for_sale29 = 1;
        /* 3635 */     vo_65499_0.show_pos29 = 17;
        /* 3636 */     vo_65499_0.rpos29 = 0;
        /* 3637 */     vo_65499_0.sale_quota29 = 65535;
        /* 3638 */     vo_65499_0.recommend29 = 0;
        /* 3639 */     vo_65499_0.coin29 = 26888;
        /* 3640 */     vo_65499_0.discount29 = 100;
        /* 3641 */     vo_65499_0.discountTime29 = 429496729;
        /* 3642 */     vo_65499_0.type29 = 4;
        /* 3643 */     vo_65499_0.quota_limit29 = 65535;
        /* 3644 */     vo_65499_0.must_vip29 = 0;
        /* 3645 */     vo_65499_0.is_gift29 = 0;
        /* 3646 */     vo_65499_0.follow_pet_type29 = 255;
        /* 3647 */     vo_65499_0.name30 = "星垂月涌·永久";
        /* 3648 */     vo_65499_0.barcode30 = "R0005028";
        /* 3649 */     vo_65499_0.for_sale30 = 1;
        /* 3650 */     vo_65499_0.show_pos30 = 13;
        /* 3651 */     vo_65499_0.rpos30 = 0;
        /* 3652 */     vo_65499_0.sale_quota30 = 65535;
        /* 3653 */     vo_65499_0.recommend30 = 0;
        /* 3654 */     vo_65499_0.coin30 = 26888;
        /* 3655 */     vo_65499_0.discount30 = 100;
        /* 3656 */     vo_65499_0.discountTime30 = 429496729;
        /* 3657 */     vo_65499_0.type30 = 4;
        /* 3658 */     vo_65499_0.quota_limit30 = 65535;
        /* 3659 */     vo_65499_0.must_vip30 = 0;
        /* 3660 */     vo_65499_0.is_gift30 = 0;
        /* 3661 */     vo_65499_0.follow_pet_type30 = 255;
        /* 3662 */     vo_65499_0.name31 = "宠风散";
        /* 3663 */     vo_65499_0.barcode31 = "R0003009";
        /* 3664 */     vo_65499_0.for_sale31 = 2;
        /* 3665 */     vo_65499_0.show_pos31 = 11;
        /* 3666 */     vo_65499_0.rpos31 = 0;
        /* 3667 */     vo_65499_0.sale_quota31 = 65535;
        /* 3668 */     vo_65499_0.recommend31 = 0;
        /* 3669 */     vo_65499_0.coin31 = 216;
        /* 3670 */     vo_65499_0.discount31 = 100;
        /* 3671 */     vo_65499_0.discountTime31 = 429496729;
        /* 3672 */     vo_65499_0.type31 = 3;
        /* 3673 */     vo_65499_0.quota_limit31 = 65535;
        /* 3674 */     vo_65499_0.must_vip31 = 0;
        /* 3675 */     vo_65499_0.is_gift31 = 0;
        /* 3676 */     vo_65499_0.follow_pet_type31 = 255;
        /* 3677 */     vo_65499_0.name32 = "星垂月涌·30天";
        /* 3678 */     vo_65499_0.barcode32 = "R0005027";
        /* 3679 */     vo_65499_0.for_sale32 = 1;
        /* 3680 */     vo_65499_0.show_pos32 = 12;
        /* 3681 */     vo_65499_0.rpos32 = 0;
        /* 3682 */     vo_65499_0.sale_quota32 = 65535;
        /* 3683 */     vo_65499_0.recommend32 = 0;
        /* 3684 */     vo_65499_0.coin32 = 2888;
        /* 3685 */     vo_65499_0.discount32 = 100;
        /* 3686 */     vo_65499_0.discountTime32 = 429496729;
        /* 3687 */     vo_65499_0.type32 = 4;
        /* 3688 */     vo_65499_0.quota_limit32 = 65535;
        /* 3689 */     vo_65499_0.must_vip32 = 0;
        /* 3690 */     vo_65499_0.is_gift32 = 0;
        /* 3691 */     vo_65499_0.follow_pet_type32 = 255;
        /* 3692 */     vo_65499_0.name33 = "改头换面卡";
        /* 3693 */     vo_65499_0.barcode33 = "R0004003";
        /* 3694 */     vo_65499_0.for_sale33 = 2;
        /* 3695 */     vo_65499_0.show_pos33 = 3;
        /* 3696 */     vo_65499_0.rpos33 = 0;
        /* 3697 */     vo_65499_0.sale_quota33 = 65535;
        /* 3698 */     vo_65499_0.recommend33 = 0;
        /* 3699 */     vo_65499_0.coin33 = 8800;
        /* 3700 */     vo_65499_0.discount33 = 100;
        /* 3701 */     vo_65499_0.discountTime33 = 429496729;
        /* 3702 */     vo_65499_0.type33 = 4;
        /* 3703 */     vo_65499_0.quota_limit33 = 65535;
        /* 3704 */     vo_65499_0.must_vip33 = 0;
        /* 3705 */     vo_65499_0.is_gift33 = 0;
        /* 3706 */     vo_65499_0.follow_pet_type33 = 255;
        /* 3707 */     vo_65499_0.name34 = "剑魄琴心·30天";
        /* 3708 */     vo_65499_0.barcode34 = "R0005035";
        /* 3709 */     vo_65499_0.for_sale34 = 1;
        /* 3710 */     vo_65499_0.show_pos34 = 22;
        /* 3711 */     vo_65499_0.rpos34 = 0;
        /* 3712 */     vo_65499_0.sale_quota34 = 65535;
        /* 3713 */     vo_65499_0.recommend34 = 0;
        /* 3714 */     vo_65499_0.coin34 = 2888;
        /* 3715 */     vo_65499_0.discount34 = 100;
        /* 3716 */     vo_65499_0.discountTime34 = 429496729;
        /* 3717 */     vo_65499_0.type34 = 4;
        /* 3718 */     vo_65499_0.quota_limit34 = 65535;
        /* 3719 */     vo_65499_0.must_vip34 = 0;
        /* 3720 */     vo_65499_0.is_gift34 = 0;
        /* 3721 */     vo_65499_0.follow_pet_type34 = 255;
        /* 3722 */     vo_65499_0.name35 = "喇叭";
        /* 3723 */     vo_65499_0.barcode35 = "R0005016";
        /* 3724 */     vo_65499_0.for_sale35 = 1;
        /* 3725 */     vo_65499_0.show_pos35 = 8;
        /* 3726 */     vo_65499_0.rpos35 = 0;
        /* 3727 */     vo_65499_0.sale_quota35 = 65535;
        /* 3728 */     vo_65499_0.recommend35 = 0;
        /* 3729 */     vo_65499_0.coin35 = 328;
        /* 3730 */     vo_65499_0.discount35 = 100;
        /* 3731 */     vo_65499_0.discountTime35 = 429496729;
        /* 3732 */     vo_65499_0.type35 = 4;
        /* 3733 */     vo_65499_0.quota_limit35 = 65535;
        /* 3734 */     vo_65499_0.must_vip35 = 1;
        /* 3735 */     vo_65499_0.is_gift35 = 0;
        /* 3736 */     vo_65499_0.follow_pet_type35 = 255;
        /* 3737 */     vo_65499_0.name36 = "聚灵石";
        /* 3738 */     vo_65499_0.barcode36 = "R0002012";
        /* 3739 */     vo_65499_0.for_sale36 = 2;
        /* 3740 */     vo_65499_0.show_pos36 = 13;
        /* 3741 */     vo_65499_0.rpos36 = 0;
        /* 3742 */     vo_65499_0.sale_quota36 = 65535;
        /* 3743 */     vo_65499_0.recommend36 = 0;
        /* 3744 */     vo_65499_0.coin36 = 1000;
        /* 3745 */     vo_65499_0.discount36 = 100;
        /* 3746 */     vo_65499_0.discountTime36 = 429496729;
        /* 3747 */     vo_65499_0.type36 = 2;
        /* 3748 */     vo_65499_0.quota_limit36 = 65535;
        /* 3749 */     vo_65499_0.must_vip36 = 0;
        /* 3750 */     vo_65499_0.is_gift36 = 0;
        /* 3751 */     vo_65499_0.follow_pet_type36 = 255;
        /* 3752 */     vo_65499_0.name37 = "无量心经";
        /* 3753 */     vo_65499_0.barcode37 = "R0003003";
        /* 3754 */     vo_65499_0.for_sale37 = 1;
        /* 3755 */     vo_65499_0.show_pos37 = 5;
        /* 3756 */     vo_65499_0.rpos37 = 0;
        /* 3757 */     vo_65499_0.sale_quota37 = 65535;
        /* 3758 */     vo_65499_0.recommend37 = 0;
        /* 3759 */     vo_65499_0.coin37 = 216;
        /* 3760 */     vo_65499_0.discount37 = 100;
        /* 3761 */     vo_65499_0.discountTime37 = 429496729;
        /* 3762 */     vo_65499_0.type37 = 3;
        /* 3763 */     vo_65499_0.quota_limit37 = 65535;
        /* 3764 */     vo_65499_0.must_vip37 = 0;
        /* 3765 */     vo_65499_0.is_gift37 = 0;
        /* 3766 */     vo_65499_0.follow_pet_type37 = 255;
        /* 3767 */     vo_65499_0.name38 = "宠物强化丹";
        /* 3768 */     vo_65499_0.barcode38 = "R0002013";
        /* 3769 */     vo_65499_0.for_sale38 = 2;
        /* 3770 */     vo_65499_0.show_pos38 = 14;
        /* 3771 */     vo_65499_0.rpos38 = 1;
        /* 3772 */     vo_65499_0.sale_quota38 = 65535;
        /* 3773 */     vo_65499_0.recommend38 = 3;
        /* 3774 */     vo_65499_0.coin38 = 216;
        /* 3775 */     vo_65499_0.discount38 = 100;
        /* 3776 */     vo_65499_0.discountTime38 = 429496729;
        /* 3777 */     vo_65499_0.type38 = 2;
        /* 3778 */     vo_65499_0.quota_limit38 = 65535;
        /* 3779 */     vo_65499_0.must_vip38 = 0;
        /* 3780 */     vo_65499_0.is_gift38 = 0;
        /* 3781 */     vo_65499_0.follow_pet_type38 = 255;
        /* 3782 */     vo_65499_0.name39 = "火眼金睛";
        /* 3783 */     vo_65499_0.barcode39 = "R0003006";
        /* 3784 */     vo_65499_0.for_sale39 = 2;
        /* 3785 */     vo_65499_0.show_pos39 = 8;
        /* 3786 */     vo_65499_0.rpos39 = 0;
        /* 3787 */     vo_65499_0.sale_quota39 = 65535;
        /* 3788 */     vo_65499_0.recommend39 = 0;
        /* 3789 */     vo_65499_0.coin39 = 216;
        /* 3790 */     vo_65499_0.discount39 = 100;
        /* 3791 */     vo_65499_0.discountTime39 = 429496729;
        /* 3792 */     vo_65499_0.type39 = 3;
        /* 3793 */     vo_65499_0.quota_limit39 = 65535;
        /* 3794 */     vo_65499_0.must_vip39 = 0;
        /* 3795 */     vo_65499_0.is_gift39 = 0;
        /* 3796 */     vo_65499_0.follow_pet_type39 = 255;
        /* 3797 */     vo_65499_0.name40 = "超级圣水晶";
        /* 3798 */     vo_65499_0.barcode40 = "R0002003";
        /* 3799 */     vo_65499_0.for_sale40 = 2;
        /* 3800 */     vo_65499_0.show_pos40 = 3;
        /* 3801 */     vo_65499_0.rpos40 = 0;
        /* 3802 */     vo_65499_0.sale_quota40 = 65535;
        /* 3803 */     vo_65499_0.recommend40 = 0;
        /* 3804 */     vo_65499_0.coin40 = 1000;
        /* 3805 */     vo_65499_0.discount40 = 100;
        /* 3806 */     vo_65499_0.discountTime40 = 429496729;
        /* 3807 */     vo_65499_0.type40 = 2;
        /* 3808 */     vo_65499_0.quota_limit40 = 65535;
        /* 3809 */     vo_65499_0.must_vip40 = 0;
        /* 3810 */     vo_65499_0.is_gift40 = 0;
        /* 3811 */     vo_65499_0.follow_pet_type40 = 255;
        /* 3812 */     vo_65499_0.name41 = "血玲珑";
        /* 3813 */     vo_65499_0.barcode41 = "R0003001";
        /* 3814 */     vo_65499_0.for_sale41 = 2;
        /* 3815 */     vo_65499_0.show_pos41 = 1;
        /* 3816 */     vo_65499_0.rpos41 = 0;
        /* 3817 */     vo_65499_0.sale_quota41 = 65535;
        /* 3818 */     vo_65499_0.recommend41 = 0;
        /* 3819 */     vo_65499_0.coin41 = 216;
        /* 3820 */     vo_65499_0.discount41 = 100;
        /* 3821 */     vo_65499_0.discountTime41 = 429496729;
        /* 3822 */     vo_65499_0.type41 = 3;
        /* 3823 */     vo_65499_0.quota_limit41 = 65535;
        /* 3824 */     vo_65499_0.must_vip41 = 0;
        /* 3825 */     vo_65499_0.is_gift41 = 0;
        /* 3826 */     vo_65499_0.follow_pet_type41 = 255;
        /* 3827 */     vo_65499_0.name42 = "星火昭·永久";
        /* 3828 */     vo_65499_0.barcode42 = "R0005030";
        /* 3829 */     vo_65499_0.for_sale42 = 1;
        /* 3830 */     vo_65499_0.show_pos42 = 15;
        /* 3831 */     vo_65499_0.rpos42 = 0;
        /* 3832 */     vo_65499_0.sale_quota42 = 65535;
        /* 3833 */     vo_65499_0.recommend42 = 0;
        /* 3834 */     vo_65499_0.coin42 = 26888;
        /* 3835 */     vo_65499_0.discount42 = 100;
        /* 3836 */     vo_65499_0.discountTime42 = 429496729;
        /* 3837 */     vo_65499_0.type42 = 4;
        /* 3838 */     vo_65499_0.quota_limit42 = 65535;
        /* 3839 */     vo_65499_0.must_vip42 = 0;
        /* 3840 */     vo_65499_0.is_gift42 = 0;
        /* 3841 */     vo_65499_0.follow_pet_type42 = 255;
        /* 3842 */     vo_65499_0.name43 = "吉祥天·30天";
        /* 3843 */     vo_65499_0.barcode43 = "R0005039";
        /* 3844 */     vo_65499_0.for_sale43 = 1;
        /* 3845 */     vo_65499_0.show_pos43 = 20;
        /* 3846 */     vo_65499_0.rpos43 = 0;
        /* 3847 */     vo_65499_0.sale_quota43 = 65535;
        /* 3848 */     vo_65499_0.recommend43 = 0;
        /* 3849 */     vo_65499_0.coin43 = 2888;
        /* 3850 */     vo_65499_0.discount43 = 100;
        /* 3851 */     vo_65499_0.discountTime43 = 429496729;
        /* 3852 */     vo_65499_0.type43 = 4;
        /* 3853 */     vo_65499_0.quota_limit43 = 65535;
        /* 3854 */     vo_65499_0.must_vip43 = 0;
        /* 3855 */     vo_65499_0.is_gift43 = 0;
        /* 3856 */     vo_65499_0.follow_pet_type43 = 1;
        /* 3857 */     vo_65499_0.name44 = "超级黑水晶";
        /* 3858 */     vo_65499_0.barcode44 = "R0002007";
        /* 3859 */     vo_65499_0.for_sale44 = 2;
        /* 3860 */     vo_65499_0.show_pos44 = 7;
        /* 3861 */     vo_65499_0.rpos44 = 0;
        /* 3862 */     vo_65499_0.sale_quota44 = 65535;
        /* 3863 */     vo_65499_0.recommend44 = 0;
        /* 3864 */     vo_65499_0.coin44 = 328;
        /* 3865 */     vo_65499_0.discount44 = 100;
        /* 3866 */     vo_65499_0.discountTime44 = 429496729;
        /* 3867 */     vo_65499_0.type44 = 2;
        /* 3868 */     vo_65499_0.quota_limit44 = 65535;
        /* 3869 */     vo_65499_0.must_vip44 = 0;
        /* 3870 */     vo_65499_0.is_gift44 = 0;
        /* 3871 */     vo_65499_0.follow_pet_type44 = 255;
        /* 3872 */     vo_65499_0.name45 = "黄水晶";
        /* 3873 */     vo_65499_0.barcode45 = "R0002002";
        /* 3874 */     vo_65499_0.for_sale45 = 2;
        /* 3875 */     vo_65499_0.show_pos45 = 2;
        /* 3876 */     vo_65499_0.rpos45 = 0;
        /* 3877 */     vo_65499_0.sale_quota45 = 65535;
        /* 3878 */     vo_65499_0.recommend45 = 0;
        /* 3879 */     vo_65499_0.coin45 = 418;
        /* 3880 */     vo_65499_0.discount45 = 100;
        /* 3881 */     vo_65499_0.discountTime45 = 429496729;
        /* 3882 */     vo_65499_0.type45 = 2;
        /* 3883 */     vo_65499_0.quota_limit45 = 65535;
        /* 3884 */     vo_65499_0.must_vip45 = 0;
        /* 3885 */     vo_65499_0.is_gift45 = 0;
        /* 3886 */     vo_65499_0.follow_pet_type45 = 255;
        /* 3887 */     vo_65499_0.name46 = "日耀辰辉·30天";
        /* 3888 */     vo_65499_0.barcode46 = "R0005025";
        /* 3889 */     vo_65499_0.for_sale46 = 1;
        /* 3890 */     vo_65499_0.show_pos46 = 10;
        /* 3891 */     vo_65499_0.rpos46 = 0;
        /* 3892 */     vo_65499_0.sale_quota46 = 65535;
        /* 3893 */     vo_65499_0.recommend46 = 0;
        /* 3894 */     vo_65499_0.coin46 = 2888;
        /* 3895 */     vo_65499_0.discount46 = 100;
        /* 3896 */     vo_65499_0.discountTime46 = 429496729;
        /* 3897 */     vo_65499_0.type46 = 4;
        /* 3898 */     vo_65499_0.quota_limit46 = 65535;
        /* 3899 */     vo_65499_0.must_vip46 = 0;
        /* 3900 */     vo_65499_0.is_gift46 = 0;
        /* 3901 */     vo_65499_0.follow_pet_type46 = 255;
        /*      */
        /* 3903 */     vo_65499_0.name47 = "超级绿水晶";
        /* 3904 */     vo_65499_0.barcode47 = "R0002001";
        /* 3905 */     vo_65499_0.for_sale47 = 2;
        /* 3906 */     vo_65499_0.show_pos47 = 1;
        /* 3907 */     vo_65499_0.rpos47 = 0;
        /* 3908 */     vo_65499_0.sale_quota47 = 65535;
        /* 3909 */     vo_65499_0.recommend47 = 0;
        /* 3910 */     vo_65499_0.coin47 = 1000;
        /* 3911 */     vo_65499_0.discount47 = 100;
        /* 3912 */     vo_65499_0.discountTime47 = 429496729;
        /* 3913 */     vo_65499_0.type47 = 2;
        /* 3914 */     vo_65499_0.quota_limit47 = 65535;
        /* 3915 */     vo_65499_0.must_vip47 = 0;
        /* 3916 */     vo_65499_0.is_gift47 = 0;
        /* 3917 */     vo_65499_0.follow_pet_type47 = 255;
        /*      */
        /* 3919 */     vo_65499_0.name48 = "情缘盒";
        /* 3920 */     vo_65499_0.barcode48 = "R0004002";
        /* 3921 */     vo_65499_0.for_sale48 = 1;
        /* 3922 */     vo_65499_0.show_pos48 = 2;
        /* 3923 */     vo_65499_0.rpos48 = 0;
        /* 3924 */     vo_65499_0.sale_quota48 = 65535;
        /* 3925 */     vo_65499_0.recommend48 = 0;
        /* 3926 */     vo_65499_0.coin48 = 108;
        /* 3927 */     vo_65499_0.discount48 = 100;
        /* 3928 */     vo_65499_0.discountTime48 = 429496729;
        /* 3929 */     vo_65499_0.type48 = 4;
        /* 3930 */     vo_65499_0.quota_limit48 = 65535;
        /* 3931 */     vo_65499_0.must_vip48 = 0;
        /* 3932 */     vo_65499_0.is_gift48 = 0;
        /* 3933 */     vo_65499_0.follow_pet_type48 = 255;
        /* 3934 */     vo_65499_0.name49 = "引天长歌·永久";
        /* 3935 */     vo_65499_0.barcode49 = "R0005033";
        /* 3936 */     vo_65499_0.for_sale49 = 1;
        /* 3937 */     vo_65499_0.show_pos49 = 25;
        /* 3938 */     vo_65499_0.rpos49 = 0;
        /* 3939 */     vo_65499_0.sale_quota49 = 65535;
        /* 3940 */     vo_65499_0.recommend49 = 0;
        /* 3941 */     vo_65499_0.coin49 = 26888;
        /* 3942 */     vo_65499_0.discount49 = 100;
        /* 3943 */     vo_65499_0.discountTime49 = 429496729;
        /* 3944 */     vo_65499_0.type49 = 4;
        /* 3945 */     vo_65499_0.quota_limit49 = 65535;
        /* 3946 */     vo_65499_0.must_vip49 = 0;
        /* 3947 */     vo_65499_0.is_gift49 = 0;
        /* 3948 */     vo_65499_0.follow_pet_type49 = 255;
        /* 3949 */     vo_65499_0.name50 = "钥匙串";
        /* 3950 */     vo_65499_0.barcode50 = "R0004004";
        /* 3951 */     vo_65499_0.for_sale50 = 1;
        /* 3952 */     vo_65499_0.show_pos50 = 4;
        /* 3953 */     vo_65499_0.rpos50 = 0;
        /* 3954 */     vo_65499_0.sale_quota50 = 65535;
        /* 3955 */     vo_65499_0.recommend50 = 0;
        /* 3956 */     vo_65499_0.coin50 = 108;
        /* 3957 */     vo_65499_0.discount50 = 100;
        /* 3958 */     vo_65499_0.discountTime50 = 429496729;
        /* 3959 */     vo_65499_0.type50 = 4;
        /* 3960 */     vo_65499_0.quota_limit50 = 65535;
        /* 3961 */     vo_65499_0.must_vip50 = 0;
        /* 3962 */     vo_65499_0.is_gift50 = 0;
        /* 3963 */     vo_65499_0.follow_pet_type50 = 255;
        /* 3964 */     vo_65499_0.name51 = "精怪诱饵";
        /* 3965 */     vo_65499_0.barcode51 = "R0002009";
        /* 3966 */     vo_65499_0.for_sale51 = 1;
        /* 3967 */     vo_65499_0.show_pos51 = 10;
        /* 3968 */     vo_65499_0.rpos51 = 6;
        /* 3969 */     vo_65499_0.sale_quota51 = 65535;
        /* 3970 */     vo_65499_0.recommend51 = 3;
        /* 3971 */     vo_65499_0.coin51 = 1000;
        /* 3972 */     vo_65499_0.discount51 = 100;
        /* 3973 */     vo_65499_0.discountTime51 = 429496729;
        /* 3974 */     vo_65499_0.type51 = 2;
        /* 3975 */     vo_65499_0.quota_limit51 = 65535;
        /* 3976 */     vo_65499_0.must_vip51 = 0;
        /* 3977 */     vo_65499_0.is_gift51 = 0;
        /* 3978 */     vo_65499_0.follow_pet_type51 = 255;
        /* 3979 */     vo_65499_0.name52 = "天神护佑";
        /* 3980 */     vo_65499_0.barcode52 = "R0003005";
        /* 3981 */     vo_65499_0.for_sale52 = 2;
        /* 3982 */     vo_65499_0.show_pos52 = 7;
        /* 3983 */     vo_65499_0.rpos52 = 0;
        /* 3984 */     vo_65499_0.sale_quota52 = 65535;
        /* 3985 */     vo_65499_0.recommend52 = 0;
        /* 3986 */     vo_65499_0.coin52 = 518;
        /* 3987 */     vo_65499_0.discount52 = 100;
        /* 3988 */     vo_65499_0.discountTime52 = 429496729;
        /* 3989 */     vo_65499_0.type52 = 3;
        /* 3990 */     vo_65499_0.quota_limit52 = 65535;
        /* 3991 */     vo_65499_0.must_vip52 = 0;
        /* 3992 */     vo_65499_0.is_gift52 = 0;
        /* 3993 */     vo_65499_0.follow_pet_type52 = 255;
        /* 3994 */     vo_65499_0.name53 = "超级神兽丹";
        /* 3995 */     vo_65499_0.barcode53 = "R0002017";
        /* 3996 */     vo_65499_0.for_sale53 = 2;
        /* 3997 */     vo_65499_0.show_pos53 = 19;
        /* 3998 */     vo_65499_0.rpos53 = 0;
        /* 3999 */     vo_65499_0.sale_quota53 = 65535;
        /* 4000 */     vo_65499_0.recommend53 = 0;
        /* 4001 */     vo_65499_0.coin53 = 108;
        /* 4002 */     vo_65499_0.discount53 = 100;
        /* 4003 */     vo_65499_0.discountTime53 = 429496729;
        /* 4004 */     vo_65499_0.type53 = 2;
        /* 4005 */     vo_65499_0.quota_limit53 = 65535;
        /* 4006 */     vo_65499_0.must_vip53 = 0;
        /* 4007 */     vo_65499_0.is_gift53 = 0;
        /* 4008 */     vo_65499_0.follow_pet_type53 = 255;
        /* 4009 */     vo_65499_0.name54 = "超级归元露";
        /* 4010 */     vo_65499_0.barcode54 = "R0002016";
        /* 4011 */     vo_65499_0.for_sale54 = 2;
        /* 4012 */     vo_65499_0.show_pos54 = 18;
        /* 4013 */     vo_65499_0.rpos54 = 0;
        /* 4014 */     vo_65499_0.sale_quota54 = 65535;
        /* 4015 */     vo_65499_0.recommend54 = 0;
        /* 4016 */     vo_65499_0.coin54 = 216;
        /* 4017 */     vo_65499_0.discount54 = 100;
        /* 4018 */     vo_65499_0.discountTime54 = 429496729;
        /* 4019 */     vo_65499_0.type54 = 2;
        /* 4020 */     vo_65499_0.quota_limit54 = 65535;
        /* 4021 */     vo_65499_0.must_vip54 = 0;
        /* 4022 */     vo_65499_0.is_gift54 = 0;
        /* 4023 */     vo_65499_0.follow_pet_type54 = 255;
        /* 4024 */     vo_65499_0.name55 = "急急如律令";
        /* 4025 */     vo_65499_0.barcode55 = "R0003004";
        /* 4026 */     vo_65499_0.for_sale55 = 2;
        /* 4027 */     vo_65499_0.show_pos55 = 6;
        /* 4028 */     vo_65499_0.rpos55 = 0;
        /* 4029 */     vo_65499_0.sale_quota55 = 65535;
        /* 4030 */     vo_65499_0.recommend55 = 0;
        /* 4031 */     vo_65499_0.coin55 = 328;
        /* 4032 */     vo_65499_0.discount55 = 100;
        /* 4033 */     vo_65499_0.discountTime55 = 429496729;
        /* 4034 */     vo_65499_0.type55 = 3;
        /* 4035 */     vo_65499_0.quota_limit55 = 65535;
        /* 4036 */     vo_65499_0.must_vip55 = 0;
        /* 4037 */     vo_65499_0.is_gift55 = 0;
        /* 4038 */     vo_65499_0.follow_pet_type55 = 255;
        /* 4039 */     vo_65499_0.name56 = "易经洗髓丹";
        /* 4040 */     vo_65499_0.barcode56 = "R0005013";
        /* 4041 */     vo_65499_0.for_sale56 = 2;
        /* 4042 */     vo_65499_0.show_pos56 = 5;
        /* 4043 */     vo_65499_0.rpos56 = 0;
        /* 4044 */     vo_65499_0.sale_quota56 = 65535;
        /* 4045 */     vo_65499_0.recommend56 = 0;
        /* 4046 */     vo_65499_0.coin56 = 216;
        /* 4047 */     vo_65499_0.discount56 = 100;
        /* 4048 */     vo_65499_0.discountTime56 = 429496729;
        /* 4049 */     vo_65499_0.type56 = 4;
        /* 4050 */     vo_65499_0.quota_limit56 = 65535;
        /* 4051 */     vo_65499_0.must_vip56 = 0;
        /* 4052 */     vo_65499_0.is_gift56 = 0;
        /* 4053 */     vo_65499_0.follow_pet_type56 = 255;
        /* 4054 */     return vo_65499_0;
        /*      */   }
    /*      */
    /*      */   public static org.linlinjava.litemall.gameserver.data.vo.Vo_53267_0 a53267() {
        /* 4058 */     org.linlinjava.litemall.gameserver.data.vo.Vo_53267_0 vo_53267_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_53267_0();
        /* 4059 */     vo_53267_0.count = 6;
        /* 4060 */     vo_53267_0.barcode0 = "C0000004";
        /* 4061 */     vo_53267_0.sale_quota0 = 1;
        /* 4062 */     vo_53267_0.toMoney0 = 30000000;
        /* 4063 */     vo_53267_0.costCoin0 = 3300;
        /* 4064 */     vo_53267_0.barcode1 = "C0000001";
        /* 4065 */     vo_53267_0.sale_quota1 = 1;
        /* 4066 */     vo_53267_0.toMoney1 = 3000000;
        /* 4067 */     vo_53267_0.costCoin1 = 300;
        /* 4068 */     vo_53267_0.barcode2 = "C0000005";
        /* 4069 */     vo_53267_0.sale_quota2 = 1;
        /* 4070 */     vo_53267_0.toMoney2 = 60000000;
        /* 4071 */     vo_53267_0.costCoin2 = 7200;
        /* 4072 */     vo_53267_0.barcode3 = "C0000006";
        /* 4073 */     vo_53267_0.sale_quota3 = 1;
        /* 4074 */     vo_53267_0.toMoney3 = 100000000;
        /* 4075 */     vo_53267_0.costCoin3 = 12000;
        /* 4076 */     vo_53267_0.barcode4 = "C0000003";
        /* 4077 */     vo_53267_0.sale_quota4 = 1;
        /* 4078 */     vo_53267_0.toMoney4 = 10000000;
        /* 4079 */     vo_53267_0.costCoin4 = 1100;
        /* 4080 */     vo_53267_0.barcode5 = "C0000002";
        /* 4081 */     vo_53267_0.sale_quota5 = 1;
        /* 4082 */     vo_53267_0.toMoney5 = 6000000;
        /* 4083 */     vo_53267_0.costCoin5 = 600;
        /*      */
        /* 4085 */     return vo_53267_0;
        /*      */   }
    /*      */
    /*      */   public static void a49171(Chara chara) {
        /* 4089 */     List<org.linlinjava.litemall.gameserver.data.vo.Vo_49171_0> list = new java.util.LinkedList();
        /*      */
        /* 4091 */     List<String[]> strings = org.linlinjava.litemall.gameserver.data.game.NoviceGiftBagUtils.giftBag(chara.sex, chara.menpai);
        /* 4092 */     for (int i = 0; i < strings.size(); i++) {
            /* 4093 */       org.linlinjava.litemall.gameserver.data.vo.Vo_49171_0 vo_49171_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_49171_0();
            /* 4094 */       vo_49171_0.isGot = chara.xinshoulibao[i];
            /* 4095 */       vo_49171_0.limitLevel = ((i + 1) * 10);
            /* 4096 */       for (int j = 0; j < ((String[])strings.get(i)).length; j++) {
                /* 4097 */         org.linlinjava.litemall.gameserver.data.vo.Vo_49171_0 vo = new org.linlinjava.litemall.gameserver.data.vo.Vo_49171_0();
                /* 4098 */         String s = ((String[])strings.get(i))[j];
                /* 4099 */         String[] split = s.split("\\#");
                /* 4100 */         vo.name = split[0];
                /* 4101 */         if (split[0].equals("代金券")) {
                    /* 4102 */           vo.number = Integer.parseInt(split[1]);
                    /*      */         } else {
                    /* 4104 */           vo.number = 1;
                    /*      */         }
                /* 4106 */         vo.limitLevel = 429496729;
                /* 4107 */         vo_49171_0.vo491710s.add(vo);
                /*      */       }
            /* 4109 */       list.add(vo_49171_0);
            /*      */     }
        /* 4111 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M49171_0(), list);
        /*      */   }
    /*      */
    /*      */   public static void huodechoujiang(String[] strings, Chara chara)
    /*      */   {
        /* 4116 */     if (strings[1].equals("宝宝")) {
            /* 4117 */       org.linlinjava.litemall.db.domain.Pet pet = GameData.that.basePetService.findOneByName(strings[0]);
            /* 4118 */       Petbeibao petbeibao = new Petbeibao();
            /* 4119 */       petbeibao.PetCreate(pet, chara, 0, 2);
            /* 4120 */       List<Petbeibao> list = new ArrayList();
            /* 4121 */       chara.pets.add(petbeibao);
            /* 4122 */       list.add(petbeibao);
            /* 4123 */       GameObjectChar.send(new MSG_UPDATE_PETS(), list);
            /* 4124 */       org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0 vo_8165_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0();
            /* 4125 */       vo_8165_0.msg = ("你获得了#R" + pet.getName() + "#n宠物");
            /* 4126 */       vo_8165_0.active = 0;
            /* 4127 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M8165_0(), vo_8165_0);
            /*      */     }
        /* 4129 */     if (strings[1].equals("经验")) {
            /* 4130 */       huodejingyan(chara, Integer.valueOf(strings[0]).intValue());
            /*      */     }
                        if(strings[1].equals("上古妖王")){
                            Npc npc =
                                    (Npc) GameData.that.baseNpcService.findOneByName(strings[0]);
                            org.linlinjava.litemall.db.domain.Characters characters = GameData.that.baseCharactersService.findById(chara.id);
//                            GameShangGuYaoWang.setYaoWangAllFlat(npc,
//                                    Integer.valueOf(strings[2]));
                            GameShangGuYaoWang.setYaoWangState(npc.getId(),
                                    GameShangGuYaoWang.YAOWANG_STATE.YAOWANG_STATE_OPEN, characters.getAccountId());
                        }
        /* 4132 */     if (strings[1].equals("精怪")) {
            /* 4133 */       int jieshu = stageMounts(strings[0]);
            /* 4134 */       org.linlinjava.litemall.db.domain.Pet pet = GameData.that.basePetService.findOneByName(strings[0]);
            /* 4135 */       Petbeibao petbeibao = new Petbeibao();
            /* 4136 */       petbeibao.PetCreate(pet, chara, 0, 2);
            /* 4137 */       List<Petbeibao> list = new ArrayList();
            /* 4138 */       chara.pets.add(petbeibao);
            /* 4139 */       list.add(petbeibao);
            /* 4140 */       ((PetShuXing)petbeibao.petShuXing.get(0)).enchant_nimbus = 0;
            /* 4141 */       ((PetShuXing)petbeibao.petShuXing.get(0)).max_enchant_nimbus = 0;
            /* 4142 */       ((PetShuXing)petbeibao.petShuXing.get(0)).suit_light_effect = 1;
            /* 4143 */       ((PetShuXing)petbeibao.petShuXing.get(0)).hide_mount = jieshu;
            /* 4144 */       PetShuXing shuXing = new PetShuXing();
            /* 4145 */       shuXing.no = 23;
            /* 4146 */       shuXing.type1 = 2;
            /* 4147 */       shuXing.accurate = (4 * (jieshu - 1));
            /* 4148 */       shuXing.mana = (4 * (jieshu - 1));
            /* 4149 */       shuXing.wiz = (3 * (jieshu - 1));
            /* 4150 */       shuXing.all_polar = 0;
            /* 4151 */       shuXing.upgrade_magic = 0;
            /* 4152 */       shuXing.upgrade_total = 0;
            /* 4153 */       petbeibao.petShuXing.add(shuXing);
            /* 4154 */       GameObjectChar.send(new MSG_UPDATE_PETS(), list);
            /*      */     }
        /* 4156 */     if (strings[1].equals("变异")) {
            /* 4157 */       org.linlinjava.litemall.db.domain.Pet pet = GameData.that.basePetService.findOneByName(strings[0]);
            /* 4158 */       Petbeibao petbeibao = new Petbeibao();
            /* 4159 */       petbeibao.PetCreate(pet, chara, 0, 3);
            /* 4160 */       List<Petbeibao> list = new ArrayList();
            /* 4161 */       chara.pets.add(petbeibao);
            /* 4162 */       list.add(petbeibao);
            /* 4163 */       GameObjectChar.send(new MSG_UPDATE_PETS(), list);
            /*      */     }
        /* 4165 */     if (strings[1].equals("物品")) {
            /* 4166 */       org.linlinjava.litemall.db.domain.StoreInfo info = GameData.that.baseStoreInfoService.findOneByName(strings[0]);
            /* 4167 */       huodedaoju(chara, info, 1);
            /*      */     }
        /* 4169 */     if (strings[1].equals("首饰")) {
            /* 4170 */       ZhuangbeiInfo oneByStr = GameData.that.baseZhuangbeiInfoService.findOneByStr(strings[0]);
            /* 4171 */       huodezhuangbei(chara, oneByStr, 0, 1);
            /* 4172 */       strings[0] = "60级首饰";
            /*      */     }
        /* 4174 */     if (strings[0].equals("代金券")) {
            /* 4175 */       chara.use_money_type += Integer.valueOf(strings[1]).intValue();
            /* 4176 */       ListVo_65527_0 listVo_65527_0 = a65527(chara);
            /* 4177 */       GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
            /*      */     }
        /* 4179 */     if (strings[1].equals("金币")) {
            /* 4180 */       chara.balance += Integer.valueOf(strings[0]).intValue();
            /* 4181 */       ListVo_65527_0 listVo_65527_0 = a65527(chara);
            /* 4182 */       GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
            /*      */     }
        /*      */
        /* 4185 */     if (strings[1].equals("装备"))
            /*      */     {
            /* 4187 */       ZhuangbeiInfo zhuangbeiInfo = GameData.that.baseZhuangbeiInfoService.findOneByStr(strings[0]);
            /* 4188 */       List<java.util.Hashtable<String, Integer>> hashtables = org.linlinjava.litemall.gameserver.data.game.NoviceGiftBagUtils.equipmentGiftBags(zhuangbeiInfo.getAmount().intValue(), zhuangbeiInfo.getAttrib().intValue());
            /* 4189 */       if (hashtables.size() > 0) {
                /* 4190 */         GoodsLanSe gooodsLanSe = new GoodsLanSe();
                /* 4191 */         org.linlinjava.litemall.gameserver.domain.GoodsGaiZao goodsGaiZao = new org.linlinjava.litemall.gameserver.domain.GoodsGaiZao();
                /* 4192 */         GoodsFenSe goodsFenSe = new GoodsFenSe();
                /* 4193 */         GoodsHuangSe goodsHuangSe = new GoodsHuangSe();
                /* 4194 */         int gaizao = 0;
                /* 4195 */         for (java.util.Hashtable<String, Integer> maps : hashtables) {
                    /* 4196 */           if (((Integer)maps.get("groupNo")).intValue() == 2) {
                        /* 4197 */             maps.put("groupType", Integer.valueOf(2));
                        /* 4198 */             gooodsLanSe = (GoodsLanSe)org.linlinjava.litemall.db.util.JSONUtils.parseObject(org.linlinjava.litemall.db.util.JSONUtils.toJSONString(maps), GoodsLanSe.class);
                        /*      */           }
                    /* 4200 */           if (((Integer)maps.get("groupNo")).intValue() == 3) {
                        /* 4201 */             maps.put("groupType", Integer.valueOf(2));
                        /* 4202 */             goodsFenSe = (GoodsFenSe)org.linlinjava.litemall.db.util.JSONUtils.parseObject(org.linlinjava.litemall.db.util.JSONUtils.toJSONString(maps), GoodsFenSe.class);
                        /*      */           }
                    /* 4204 */           if (((Integer)maps.get("groupNo")).intValue() == 4) {
                        /* 4205 */             maps.put("groupType", Integer.valueOf(2));
                        /* 4206 */             goodsHuangSe = (GoodsHuangSe)org.linlinjava.litemall.db.util.JSONUtils.parseObject(org.linlinjava.litemall.db.util.JSONUtils.toJSONString(maps), GoodsHuangSe.class);
                        /*      */           }
                    /* 4208 */           if (((Integer)maps.get("groupNo")).intValue() == 10) {
                        /* 4209 */             gaizao = ((Integer)maps.get("changeNum")).intValue();
                        /* 4210 */             maps.remove("changeNum");
                        /* 4211 */             maps.put("groupType", Integer.valueOf(2));
                        /* 4212 */             goodsGaiZao = (org.linlinjava.litemall.gameserver.domain.GoodsGaiZao)org.linlinjava.litemall.db.util.JSONUtils.parseObject(org.linlinjava.litemall.db.util.JSONUtils.toJSONString(maps), org.linlinjava.litemall.gameserver.domain.GoodsGaiZao.class);
                        /*      */           }
                    /*      */         }
                /* 4215 */         Goods goods = new Goods();
                /* 4216 */         goods.pos = beibaoweizhi(chara);
                /* 4217 */         if (goods.pos == 0) {
                    /* 4218 */           return;
                    /*      */         }
                /* 4220 */         goods.goodsInfo = new GoodsInfo();
                /* 4221 */         goods.goodsBasics = new org.linlinjava.litemall.gameserver.domain.GoodsBasics();
                /* 4222 */         goods.goodsLanSe = gooodsLanSe;
                /* 4223 */         goods.goodsGaiZao = goodsGaiZao;
                /* 4224 */         goods.goodsFenSe = goodsFenSe;
                /* 4225 */         goods.goodsHuangSe = goodsHuangSe;
                /* 4226 */         goods.goodsCreate(zhuangbeiInfo);
                /* 4227 */         goods.goodsInfo.owner_id = 1;
                /* 4228 */         goods.goodsInfo.degree_32 = 0;
                /* 4229 */         goods.goodsInfo.color = gaizao;
                /* 4230 */         chara.backpack.add(goods);
                /* 4231 */         GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
                /*      */       }
            /*      */     }
        /*      */   }
    /*      */
    /*      */   private static int stageMounts(String name)
    /*      */   {
        /* 4238 */     int[] mounts_stage = { 2, 3, 4, 4, 5, 5, 5, 6, 6, 6, 6, 8, 8 };
        /* 4239 */     String[] mounts_name = { "仙阳剑", "凌岩豹", "幻鹿", "赤焰葫芦", "玉豹", "仙葫芦", "无极熊", "岳麓剑", "古鹿", "北极熊", "筋斗云", "太极熊", "墨麒麟" };
        /* 4240 */     for (int i = 0; i < mounts_name.length; i++) {
            /* 4241 */       if (mounts_name[i].equalsIgnoreCase(name)) {
                /* 4242 */         return mounts_stage[i];
                /*      */       }
            /*      */     }
        /* 4245 */     return 0;
        /*      */   }
    /*      */
    /*      */
    /*      */
    /*      */
    /*      */
    /*      */
    /*      */
    /*      */   public static List<java.util.Hashtable<String, Integer>> equipmentLuckDraw(int eq_attrib, int leixing)
    /*      */   {
        /* 4256 */     if (eq_attrib < 70) {
            /* 4257 */       eq_attrib = 70;
            /*      */     } else {
            /* 4259 */       eq_attrib = eq_attrib / 10 * 10;
            /*      */     }
        /* 4261 */     List<java.util.Hashtable<String, Integer>> hashtables = org.linlinjava.litemall.gameserver.data.game.ForgingEquipmentUtils.appraisalEquipment(leixing, eq_attrib, 10);
        /*      */
        /* 4263 */     String[] rareAttributes = { "all_resist_except", "all_resist_polar", "all_polar", "all_skill", "ignore_all_resist_except", "mstunt_rate", "release_forgotten" };
        /* 4264 */     for (java.util.Hashtable<String, Integer> hashtable : hashtables) {
            /* 4265 */       for (String key : rareAttributes) {
                /* 4266 */         if (hashtable.contains(key)) {
                    /* 4267 */           Random random = new Random();
                    /*      */
                    /* 4269 */           String[] replaceAttributes = { "mag_power", "phy_power", "speed", "life" };
                    /* 4270 */           List<java.util.Hashtable<String, Integer>> appraisalList = new ArrayList();
                    /* 4271 */           java.util.Hashtable<String, Integer> key_vlaue_tab = new java.util.Hashtable();
                    /* 4272 */           key_vlaue_tab.put("groupNo", Integer.valueOf(2));
                    /* 4273 */           key_vlaue_tab.put(replaceAttributes[random.nextInt(4)], Integer.valueOf(eq_attrib / 4));
                    /* 4274 */           appraisalList.add(key_vlaue_tab);
                    /* 4275 */           return appraisalList;
                    /*      */         }
                /*      */       }
            /*      */     }
        /*      */
        /* 4280 */     return hashtables;
        /*      */   }
    /*      */
    /*      */   public static String zhuangbname(Chara chara, int leixing) {
        /* 4284 */     int eq_attrib = 0;
        /* 4285 */     if (chara.level < 70) {
            /* 4286 */       eq_attrib = 70;
            /*      */     } else {
            /* 4288 */       eq_attrib = chara.level / 10 * 10;
            /*      */     }
        /* 4290 */     List<ZhuangbeiInfo> byAttrib = GameData.that.baseZhuangbeiInfoService.findByAttrib(Integer.valueOf(eq_attrib));
        /* 4291 */     for (int j = 0; j < byAttrib.size(); j++) {
            /* 4292 */       if ((leixing == 1) &&
                    /* 4293 */         (((ZhuangbeiInfo)byAttrib.get(j)).getMetal().intValue() == chara.menpai) && (((ZhuangbeiInfo)byAttrib.get(j)).getAmount().intValue() == leixing)) {
                /* 4294 */         return ((ZhuangbeiInfo)byAttrib.get(j)).getStr();
                /*      */       }
            /*      */
            /* 4297 */       if (((leixing == 2) || (leixing == 3)) &&
                    /* 4298 */         (((ZhuangbeiInfo)byAttrib.get(j)).getMaster().intValue() == chara.sex) && (((ZhuangbeiInfo)byAttrib.get(j)).getAmount().intValue() == leixing)) {
                /* 4299 */         return ((ZhuangbeiInfo)byAttrib.get(j)).getStr();
                /*      */       }
            /*      */
            /* 4302 */       if ((leixing == 10) &&
                    /* 4303 */         (((ZhuangbeiInfo)byAttrib.get(j)).getAmount().intValue() == leixing)) {
                /* 4304 */         return ((ZhuangbeiInfo)byAttrib.get(j)).getStr();
                /*      */       }
            /*      */     }
        /*      */
        /* 4308 */     return "";
        /*      */   }
    /*      */

    /**
     * MSG_SHUADAO_REFRESH
     * @param chara
     */
    /*      */   public static void a45060(Chara chara) {
        /* 4312 */     org.linlinjava.litemall.gameserver.data.vo.Vo_45060_0 vo_45060_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45060_0();
        /* 4313 */     vo_45060_0.hasBonus = 0;
        /* 4314 */     vo_45060_0.xy_higest = 649;
        /* 4315 */     vo_45060_0.fm_higest = 496;
        /* 4316 */     vo_45060_0.fx_higest = 0;
        /* 4317 */     vo_45060_0.off_line_time = 2276;
        /* 4318 */     vo_45060_0.buy_one = 50;
        /* 4319 */     vo_45060_0.buy_five = 350;
        /* 4320 */     vo_45060_0.buy_time = 0;
        /* 4321 */     vo_45060_0.max_buy_time = 4;
        /* 4322 */     vo_45060_0.offlineStatus = 0;
        /* 4323 */     vo_45060_0.max_turn = 0;
        /* 4324 */     vo_45060_0.lastTaskName = "降妖";
        /* 4325 */     vo_45060_0.max_double = 440;
        /* 4326 */     vo_45060_0.max_jiji = 110;
        /* 4327 */     vo_45060_0.jijiStatus = 0;
        /* 4328 */     vo_45060_0.chongfengsan_time = 0;
        /* 4329 */     vo_45060_0.max_chongfengsan_time = 3;
        /* 4330 */     vo_45060_0.ziqihongmeng_time = 0;
        /* 4331 */     vo_45060_0.max_ziqihongmeng_time = 1;
        /* 4332 */     vo_45060_0.max_chongfengsan = 440;
        /* 4333 */     vo_45060_0.chongfengsan_status = chara.chongfengsan;
        /* 4334 */     vo_45060_0.max_ziqihongmeng = 440;
        /* 4335 */     vo_45060_0.ziqihongmeng_status = chara.ziqihongmeng;
        /* 4336 */     vo_45060_0.hasDaofaBonus = 0;
        /* 4337 */     vo_45060_0.count = 3;
        /* 4338 */     vo_45060_0.taskName = "降妖";
        /* 4339 */     vo_45060_0.taskTime = 9;
        /* 4340 */     vo_45060_0.taskName1 = "伏魔";
        /* 4341 */     vo_45060_0.taskTime1 = 3;
        /* 4342 */     vo_45060_0.taskName2 = "飞仙渡邪";
        /* 4343 */     vo_45060_0.taskTime2 = 1;
        /* 4344 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M45060_0(), vo_45060_0);
        /*      */   }

        public static void a45704(Chara chara){
            Vo_45704_0 vo_45704_0 = new Vo_45704_0();
            vo_45704_0.result = 0;//TODO
            vo_45704_0.xing_name = chara.ttt_xj_name;
            GameObjectChar.send(new MSG_TTT_NEW_XING(), vo_45704_0);
        }

    /**
     * 通天塔-任务面板信息
     * @param chara
     */
    public static void notifyTTTPanelInfo(Chara chara){
            Vo_49155_0 vo_49155_0 = new Vo_49155_0();
            vo_49155_0.curLayer = (short) chara.ttt_layer;
            vo_49155_0.breakLayer = (short) (chara.level);
            byte curType = 0;
            if(chara.ttt_layer<=chara.level){
                curType = 1;
            }else{

            }
        if(chara.ttt_challenge_num>0){
                if(chara.ttt_xj_success){
                    curType = 2;
                }else{
                    curType = (byte) (chara.ttt_layer<=chara.level?1:3);
                }
        }else{
            curType = 1;
        }

            vo_49155_0.curType = curType;
            vo_49155_0.topLayer = chara.level+45;
            vo_49155_0.npc = chara.ttt_xj_name;
            vo_49155_0.challengeCount = 3-chara.ttt_challenge_num;
            vo_49155_0.bonusType = chara.ttt_award_type;
            vo_49155_0.hasNotCompletedSmfj = 1;
            GameObjectChar.send(new MSG_TONGTIANTA_INFO(), vo_49155_0);
        }

    /**
     * MSG_TONGTIANTA_BONUS_DLG 通天塔突破修练奖励界面
     */
    public static void a49157_exp(Chara chara, long bonusValue){
        Vo_49157_0 vo_49157_0 = new Vo_49157_0();
        vo_49157_0.bonusType = chara.ttt_award_type;
        vo_49157_0.dlgType = 1;
        vo_49157_0.bonusValue = bonusValue;
        vo_49157_0.bonusTaoPoint = 0;
        GameObjectChar.send(new M49157_0(), vo_49157_0);
    }

    /**
     * MSG_TONGTIANTA_BONUS_DLG 通天塔突破修练奖励界面
     */
    public static void a49157_tao(Chara chara, long bonusTaoPoint){
        Vo_49157_0 vo_49157_0 = new Vo_49157_0();
        vo_49157_0.bonusType = chara.ttt_award_type;
        vo_49157_0.dlgType = 1;
        vo_49157_0.bonusValue = 0;
        vo_49157_0.bonusTaoPoint = bonusTaoPoint;
        GameObjectChar.send(new M49157_0(), vo_49157_0);
    }

    /**
     * 增加或减少元宝
     * @param chara
     * @param addYuanbao
     */
    public static void addYuanBao(Chara chara, int addYuanbao){
        chara.extra_life += addYuanbao;
        ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
        GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
    }

    /**
     * 增加或减少金币
     * @param chara
     * @param addCoin
     */

    public static void addCoin(Chara chara, int addCoin){
        chara.gold_coin += addCoin;
        ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
        GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
    }

    /**
     * 通知玩家通天塔飞升成功
     * @param chara
     * @param costType  消耗类型  1元宝2金钱
     * @param costCount
     * @param jumpCount
     */
    public static void a45090(Chara chara, byte costType, long costCount, int jumpCount){
        Vo_45090_0 vo_45090_0 = new Vo_45090_0();
        vo_45090_0.costType=costType;
        vo_45090_0.costCount = costCount;
        vo_45090_0.jumpCount = jumpCount;
        GameObjectChar.send(new M45090_0(), vo_45090_0);
    }

    /**
     * 通天塔-挑战下层
     * @param chara
     */
    public static void tttChallengeNextLayer(Chara chara){
        int nextLayer = chara.ttt_layer+1;
        if(nextLayer>=186){//塔顶
            Map map = GameData.that.baseMapService.findOneByName("通天塔顶");
            chara.y = map.getY().intValue();
            chara.x = map.getX().intValue();
            GameLine.getGameMapname(chara.line,map.getName()).join(GameObjectChar.getGameObjectChar());
        }else{
            Map map = GameData.that.baseMapService.findOneByName("通天塔");
            chara.y = map.getY().intValue();
            chara.x = map.getX().intValue();
            GameLine.getGameMapname(chara.line,map.getName()).join(GameObjectChar.getGameObjectChar());
        }
        Preconditions.checkArgument(chara.ttt_xj_success);
        String xingjunName = GameUtil.randomTTTXingJunName();
        chara.onEnterTttLayer(nextLayer, xingjunName);

        GameUtil.notifyTTTPanelInfo(chara);
        GameUtilRenWu.notifyTTTTask(chara);

    }

    public static void openDlg(String dlgName){
        final Vo_9129_0 vo_9129_2 = new Vo_9129_0();
        vo_9129_2.notify = 97;
        vo_9129_2.para = dlgName;
        GameObjectChar.send(new M9129_0(), vo_9129_2);
    }

    /**
     * 根据相性文字转化成int
     * @param polar
     * @return
     */
    public static int getMetal(String polar){
        if (polar.equals("金")) {
            return 1;
        }

        if (polar.equals("木")) {
            return 2;
        }

        if (polar.equals("水")) {
            return 3;
        }

        if (polar.equals("火")) {
            return 4;
        }

        if (polar.equals("土")) {
            return 5;
        }
        return 0;
    }
    /*      */ }

