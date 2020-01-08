/*     */ package org.linlinjava.litemall.gameserver.game;
/*     */ 
/*     */ import java.util.ArrayList;
/*     */ import java.util.List;
/*     */ import java.util.Random;
/*     */ import org.linlinjava.litemall.db.domain.RenwuMonster;
/*     */ import org.linlinjava.litemall.db.domain.ZhuangbeiInfo;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_APPEAR;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ 
/*     */ public class GameShuaGuai
/*     */ {
/*  14 */   public int shuaXingzhuangtai = 0;
/*  15 */   public long shuaXingTime = System.currentTimeMillis();
/*  16 */   public List<Vo_65529_0> shuaXing = new java.util.LinkedList();
/*  17 */   public static final List<Integer> list = new ArrayList(java.util.Arrays.asList(new Integer[] { Integer.valueOf(1111111111), Integer.valueOf(222222222), Integer.valueOf(333333333), Integer.valueOf(444444444), Integer.valueOf(555555555), Integer.valueOf(66666666), Integer.valueOf(777777777), Integer.valueOf(888888888) }));
/*  18 */   public static List<Vo_65529_0> dengdaishuaXing = new java.util.LinkedList();
/*     */   
/*     */   public static void sendshuaguai(GameShuaGuai gameShuaGuai)
/*     */   {
/*  22 */     for (int i = 0; i < dengdaishuaXing.size(); i++) {
/*  23 */       GameObjectCharMng.sendAllmap(new MSG_APPEAR(), dengdaishuaXing.get(i), ((Vo_65529_0)dengdaishuaXing.get(i)).mapid);
/*  24 */       List<GameObjectChar> sessionList = GameObjectCharMng.getGameObjectCharList();
/*  25 */       for (int j = 0; j < sessionList.size(); j++) {
/*  26 */         if (((GameObjectChar)sessionList.get(j)).gameMap.id == ((Vo_65529_0)dengdaishuaXing.get(i)).mapid) {
/*  27 */           List<GameObjectChar> sessionList1 = ((GameObjectChar)sessionList.get(j)).gameMap.getSessionList();
/*  28 */           if (sessionList1.size() > 0) {
/*  29 */             Random random = new Random();
/*  30 */             GameObjectChar gameSession = (GameObjectChar)sessionList1.get(random.nextInt(sessionList1.size()));
/*  31 */             String xuanzhongname = "";
/*  32 */             if ((gameSession.gameTeam != null) && (gameSession.gameTeam.duiwu != null)) {
/*  33 */               ((Vo_65529_0)dengdaishuaXing.get(i)).wanjiaid = ((Chara)gameSession.gameTeam.duiwu.get(0)).id;
/*  34 */               gameSession = GameObjectCharMng.getGameObjectChar(((Chara)gameSession.gameTeam.duiwu.get(0)).id);
/*     */             } else {
/*  36 */               ((Vo_65529_0)dengdaishuaXing.get(i)).wanjiaid = gameSession.chara.id;
/*     */             }
/*  38 */             gameShuaGuai.shuaXingzhuangtai = 2;
/*  39 */             gameShuaGuai.shuaXingTime = System.currentTimeMillis();
/*  40 */             String msg = "#R恭喜#n#Y" + xuanzhongname + "#n，我乃#R" + ((Vo_65529_0)dengdaishuaXing.get(i)).name + "（" + ((Vo_65529_0)dengdaishuaXing.get(i)).level + "级）#n。遵天命，今特邀你在#Z轩辕坟三层|轩辕坟三层(42,45)::" + ((Vo_65529_0)dengdaishuaXing.get(i)).name + "|1线|$0#Z处挑战。我只等你3分钟，请速来挑战。如果你挑战成功，将会获得丰厚的奖励。";
/*  41 */             Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/*  42 */             vo_20480_0.msg = msg;
/*  43 */             vo_20480_0.time = ((int)(System.currentTimeMillis() / 1000L));
/*  44 */             GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M20480_0(), vo_20480_0, gameSession.chara.id);
/*     */             
/*     */ 
/*  47 */             org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0 vo_8165_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0();
/*  48 */             vo_8165_0.msg = ("#R恭喜#n，你队伍已被#Y" + ((Vo_65529_0)dengdaishuaXing.get(i)).name + "#n选中，请速前往挑战。");
/*  49 */             vo_8165_0.active = 0;
/*  50 */             GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M8165_0(), vo_8165_0, gameSession.chara.id);
/*     */             
/*     */ 
/*  53 */             String msglost = "染项很遗憾，" + ((Vo_65529_0)dengdaishuaXing.get(i)).name + "(" + ((Vo_65529_0)dengdaishuaXing.get(i)).level + "级)已邀请到玩家进行挑战,不过您的幸运值有了大幅增加,下次会优先挑选您的,诚请各位道友下一时段前往挑战。";
/*  54 */             vo_20480_0 = new Vo_20480_0();
/*  55 */             vo_20480_0.msg = msglost;
/*  56 */             vo_20480_0.time = ((int)(System.currentTimeMillis() / 1000L));
/*  57 */             gameSession.gameMap.sendNoMeduiwu(new org.linlinjava.litemall.gameserver.data.write.M20480_0(), vo_20480_0, gameSession);
/*     */             
/*  59 */             org.linlinjava.litemall.gameserver.data.vo.Vo_40961_0 vo_40961_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_40961_0();
/*  60 */             vo_40961_0.count = 1;
/*  61 */             vo_40961_0.id = gameSession.characters.getGid();
/*  62 */             vo_40961_0.type = 0;
/*  63 */             vo_40961_0.sender = "";
/*  64 */             vo_40961_0.title = ("挑战" + ((Vo_65529_0)dengdaishuaXing.get(i)).name);
/*  65 */             vo_40961_0.msg = msg;
/*  66 */             vo_40961_0.attachment = "";
/*  67 */             vo_40961_0.create_time = ((int)(System.currentTimeMillis() / 1000L));
/*  68 */             vo_40961_0.expired_time = ((int)(System.currentTimeMillis() / 1000L) + 1000000);
/*  69 */             vo_40961_0.status = 0;
/*  70 */             gameSession.gameMap.sendNoMeyoujian(new org.linlinjava.litemall.gameserver.data.write.M40961_0(), vo_40961_0, gameSession);
/*  71 */             break;
/*     */           }
/*     */         }
/*     */       }
/*     */     }
/*     */     
/*  77 */     gameShuaGuai.shuaXing.addAll(dengdaishuaXing);
/*  78 */     dengdaishuaXing = new java.util.LinkedList();
/*     */   }
/*     */   
/*     */   public static void sendYaoYan(GameShuaGuai gameShuaGuai)
/*     */   {
/*  83 */     List<Integer> lists = new ArrayList(java.util.Arrays.asList(new Integer[] { Integer.valueOf(1111111111), Integer.valueOf(222222222), Integer.valueOf(333333333), Integer.valueOf(444444444), Integer.valueOf(555555555), Integer.valueOf(66666666), Integer.valueOf(777777777), Integer.valueOf(888888888) }));
/*  84 */     gameShuaGuai.shuaXingzhuangtai = 1;
/*  85 */     gameShuaGuai.shuaXingTime = System.currentTimeMillis();
/*  86 */     List list = new ArrayList();
/*  87 */     for (int i = 0; i < gameShuaGuai.shuaXing.size(); i++) {
/*  88 */       list.add(Integer.valueOf(((Vo_65529_0)gameShuaGuai.shuaXing.get(i)).id));
/*     */     }
/*     */     
/*  91 */     lists.removeAll(list);
/*     */     
/*  93 */     for (int i = 0; i < lists.size(); i++) {
/*  94 */       Random random = new Random();
/*  95 */       String name = getName();
/*  96 */       int level = chenchenglevel(((Integer)lists.get(i)).intValue());
/*  97 */       Vo_65529_0 vo_65529_0 = new Vo_65529_0();
/*  98 */       vo_65529_0.id = ((Integer)lists.get(i)).intValue();
/*  99 */       vo_65529_0.name = name;
/* 100 */       vo_65529_0.level = level;
/* 101 */       vo_65529_0.type = 2;
/* 102 */       vo_65529_0.leixing = (random.nextInt(5) + 1);
/* 103 */       List<RenwuMonster> renwuMonsters = GameData.that.baseRenwuMonsterService.findByType(Integer.valueOf(7));//杀星
/* 104 */       RenwuMonster renwuMonster = (RenwuMonster)renwuMonsters.get(random.nextInt(renwuMonsters.size()));
/* 105 */       org.linlinjava.litemall.db.domain.Map map = GameData.that.baseMapService.findOneByName(renwuMonster.getMapName());
/* 106 */       vo_65529_0.mapid = map.getMapId().intValue();
/* 107 */       vo_65529_0.x = renwuMonster.getX().intValue();
/* 108 */       vo_65529_0.y = renwuMonster.getY().intValue();
/* 109 */       List<ZhuangbeiInfo> infoList = GameData.that.baseZhuangbeiInfoService.findByAttrib(Integer.valueOf(level / 10 * 10));
/* 110 */       for (ZhuangbeiInfo zhuangbeiInfo : infoList) {
/* 111 */         if ((zhuangbeiInfo.getAmount().intValue() == 1) && (zhuangbeiInfo.getMetal().intValue() == vo_65529_0.leixing)) {
/* 112 */           vo_65529_0.weapon_icon = zhuangbeiInfo.getType().intValue();
/*     */         }
/*     */       }
/* 115 */       vo_65529_0.dir = 1;
/* 116 */       int sex = random.nextInt(1) + 1;
/* 117 */       vo_65529_0.icon = waiguan(vo_65529_0.leixing, sex);
/* 118 */       int[] suit = org.linlinjava.litemall.gameserver.data.game.SuitEffectUtils.suit(sex - 1, level, vo_65529_0.leixing, random.nextInt(5) + 1);
/* 119 */       vo_65529_0.org_icon = vo_65529_0.icon;
/* 120 */       vo_65529_0.suit_icon = suit[0];
/* 121 */       vo_65529_0.suit_light_effect = suit[1];
/* 122 */       vo_65529_0.portrait = vo_65529_0.icon;
/* 123 */       dengdaishuaXing.add(vo_65529_0);
/*     */       
/*     */ 
/* 126 */       org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0 vo_16383_5 = new org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0();
/* 127 */       vo_16383_5.channel = 6;
/* 128 */       vo_16383_5.id = 0;
/* 129 */       vo_16383_5.name = "";
/* 130 */       vo_16383_5.msg = ("听闻#Y" + name + "#n#R（" + level + "级）#n将在#R三分钟后#n下凡云游到#Z" + renwuMonster.getMapName() + "|14线#Z，期间星君将挑选幸运的道友进行指点，各位道友快去该地图等候吧！");
/* 131 */       vo_16383_5.time = ((int)(System.currentTimeMillis() / 1000L));
/* 132 */       vo_16383_5.privilege = 0;
/* 133 */       vo_16383_5.server_name = "3周年14线";
/* 134 */       vo_16383_5.show_extra = 1;
/* 135 */       vo_16383_5.compress = 0;
/* 136 */       vo_16383_5.orgLength = 65535;
/* 137 */       vo_16383_5.cardCount = 0;
/* 138 */       vo_16383_5.voiceTime = 0;
/* 139 */       vo_16383_5.token = "";
/* 140 */       vo_16383_5.checksum = 0;
/* 141 */       GameObjectCharMng.sendAll(new org.linlinjava.litemall.gameserver.data.write.M16383_0(), vo_16383_5);
/*     */     }
/*     */   }
/*     */   
/*     */   public static String getName()
/*     */   {
/* 147 */     Random seriesRandom = new Random();
/* 148 */     String[] dx = { "地魁星", "地煞星", "地勇星", "地杰星", "地雄星", "地威星", "地英星", "地奇星", "地猛星", "地文星", "地正星", "地辟星", "地阖星", "地强星", "地暗星", "地辅星", "地会星", "地佐星", "地佑星", "地灵星", "地兽星", "地微星", "地慧星", "地暴星", "地默星", "地猖星", "地狂星", "地飞星", "地走星", "地巧星", "地明星", "地进星", "地退星", "地满星", "地遂星", "地周星", "地隐星", "地异星", "地理星", "地俊星", "地乐星", "地捷星", "地速星", "地镇星", "地羁星", "地魔星", "地妖星", "地幽星", "地伏星", "地僻星", "地空星", "地孤星", "地全星", "地短星", "地角星", "地囚星", "地藏星", "地平星", "地损星", "地奴星", "地察星", "地恶星", "地魂星", "地数星", "地阴星", "地刑星", "地壮星", "地劣星", "地健星", "地贼星", "地戚星", "地狗星" };
/*     */     
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/* 155 */     String[] tx = { "天猛星", "天威星", "天英星", "天贵星", "天富星", "天满星", "天孤星", "天伤星", "天立星", "天捷星", "天暗星", "天祐星", "天空星", "天速星", "天异星", "天杀星", "天微星", "天究星", "天退星", "天寿星", "天剑星", "天平星", "天罪星", "天损星" };
/*     */     
/*     */ 
/* 158 */     if (seriesRandom.nextBoolean()) {
/* 159 */       return dx[seriesRandom.nextInt(dx.length)];
/*     */     }
/* 161 */     return tx[seriesRandom.nextInt(tx.length)];
/*     */   }
/*     */   
/*     */   public static int chenchenglevel(int id)
/*     */   {
/* 166 */     int[] level = { 50, 60, 70, 80, 90, 100, 110, 120 };
/* 167 */     int dengji = 0;
/* 168 */     for (int i = 0; i < list.size(); i++) {
/* 169 */       if (id == ((Integer)list.get(i)).intValue()) {
/* 170 */         dengji = level[i];
/*     */       }
/*     */     }
/* 173 */     Random random = new Random();
/* 174 */     return dengji + random.nextInt(10);
/*     */   }
/*     */   
/*     */   public static int waiguan(int menpai, int sex)
/*     */   {
/* 179 */     int waiguan = 0;
/* 180 */     if ((menpai == 1) && (sex == 1)) {
/* 181 */       waiguan = 6001;
/*     */     }
/* 183 */     if ((menpai == 2) && (sex == 1)) {
/* 184 */       waiguan = 7002;
/*     */     }
/* 186 */     if ((menpai == 3) && (sex == 1)) {
/* 187 */       waiguan = 7003;
/*     */     }
/* 189 */     if ((menpai == 4) && (sex == 1)) {
/* 190 */       waiguan = 6004;
/*     */     }
/* 192 */     if ((menpai == 5) && (sex == 1)) {
/* 193 */       waiguan = 6005;
/*     */     }
/* 195 */     if ((menpai == 1) && (sex == 2)) {
/* 196 */       waiguan = 7001;
/*     */     }
/* 198 */     if ((menpai == 2) && (sex == 2)) {
/* 199 */       waiguan = 6002;
/*     */     }
/* 201 */     if ((menpai == 3) && (sex == 2)) {
/* 202 */       waiguan = 6003;
/*     */     }
/* 204 */     if ((menpai == 4) && (sex == 2)) {
/* 205 */       waiguan = 7004;
/*     */     }
/* 207 */     if ((menpai == 5) && (sex == 2)) {
/* 208 */       waiguan = 7005;
/*     */     }
/* 210 */     return waiguan;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\game\GameShuaGuai.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */