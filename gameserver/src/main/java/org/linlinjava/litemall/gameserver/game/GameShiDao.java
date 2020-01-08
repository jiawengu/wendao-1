/*    */ package org.linlinjava.litemall.gameserver.game;
/*    */ 
/*    */ import java.util.LinkedList;
/*    */ import java.util.List;
/*    */ import java.util.Random;
/*    */ import org.linlinjava.litemall.db.domain.RenwuMonster;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_APPEAR;

/*    */
/*    */ public class GameShiDao
/*    */ {
/* 11 */   public int shuaXingzhuangtai = 0;
/*    */   
/* 13 */   public static int statzhuangtai = 0;
/* 14 */   public long shuaXingTime = System.currentTimeMillis();
/*    */   
/* 16 */   public static long statTime = System.currentTimeMillis();
/*    */   
/* 18 */   public static long gonggaoTime = System.currentTimeMillis();
/*    */   
/* 20 */   public List<Vo_65529_0> shidaoyuanmo = new LinkedList();
/*    */   
/* 22 */   public List<Vo_65529_0> dengdaishuaXing = new LinkedList();
/*    */   
/*    */   public static void sendyaoyan1(String msg)
/*    */   {
/* 26 */     org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0 vo_16383_5 = new org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0();
/* 27 */     vo_16383_5.channel = 7;
/* 28 */     vo_16383_5.id = 0;
/* 29 */     vo_16383_5.name = "";
/* 30 */     vo_16383_5.msg = msg;
/* 31 */     vo_16383_5.time = ((int)(System.currentTimeMillis() / 1000L));
/* 32 */     vo_16383_5.privilege = 0;
/* 33 */     vo_16383_5.server_name = "";
/* 34 */     vo_16383_5.show_extra = 1;
/* 35 */     vo_16383_5.compress = 0;
/* 36 */     vo_16383_5.orgLength = 65535;
/* 37 */     vo_16383_5.cardCount = 0;
/* 38 */     vo_16383_5.voiceTime = 0;
/* 39 */     vo_16383_5.token = "";
/* 40 */     vo_16383_5.checksum = 0;
/* 41 */     GameObjectCharMng.sendAll(new org.linlinjava.litemall.gameserver.data.write.M16383_0(), vo_16383_5);
/*    */   }
/*    */   
/*    */ 
/*    */   public static void sendYaoYan(GameShiDao gameShiDao, GameMap gameMap)
/*    */   {
/* 47 */     int size = gameMap.sessionList.size() * 5 - gameMap.gameShiDao.shidaoyuanmo.size();
/*    */     
/*    */ 
/* 50 */     for (int i = 0; i < size; i++) {
/* 51 */       Random random = new Random();
/* 52 */       String name = "试道元魔";
/* 53 */       Vo_65529_0 vo_65529_0 = new Vo_65529_0();
/* 54 */       vo_65529_0.id = getCard();
/* 55 */       vo_65529_0.name = name;
/* 56 */       vo_65529_0.type = 2;
/* 57 */       vo_65529_0.leixing = (random.nextInt(5) + 1);
/* 58 */       List<RenwuMonster> renwuMonsters = GameData.that.baseRenwuMonsterService.findByType(Integer.valueOf(9));
/* 59 */       RenwuMonster renwuMonster = (RenwuMonster)renwuMonsters.get(random.nextInt(renwuMonsters.size()));
/* 60 */       org.linlinjava.litemall.db.domain.Map map = GameData.that.baseMapService.findOneByName(renwuMonster.getMapName());
/* 61 */       vo_65529_0.mapid = map.getMapId().intValue();
/* 62 */       vo_65529_0.x = renwuMonster.getX().intValue();
/* 63 */       vo_65529_0.y = renwuMonster.getY().intValue();
/* 64 */       vo_65529_0.dir = 1;
/* 65 */       vo_65529_0.icon = 6049;
/* 66 */       vo_65529_0.org_icon = vo_65529_0.icon;
/* 67 */       vo_65529_0.portrait = vo_65529_0.icon;
/* 68 */       gameShiDao.dengdaishuaXing.add(vo_65529_0);
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */   public static void sendshuaguai(GameShiDao gameShiDao, GameMap gameMap)
/*    */   {
/* 75 */     for (int i = 0; i < gameShiDao.dengdaishuaXing.size(); i++) {
/* 76 */       GameObjectCharMng.sendAllmapname(new MSG_APPEAR(), gameShiDao.dengdaishuaXing.get(i), gameMap.name);
/*    */     }
/* 78 */     gameShiDao.shidaoyuanmo.addAll(gameShiDao.dengdaishuaXing);
/* 79 */     gameShiDao.dengdaishuaXing = new LinkedList();
/*    */   }
/*    */   
/*    */   public static int getCard()
/*    */   {
/* 84 */     Random rand = new Random();
/* 85 */     String cardNnumer = "";
/* 86 */     for (int a = 0; a < 9; a++) {
/* 87 */       cardNnumer = cardNnumer + rand.nextInt(10);
/*    */     }
/* 89 */     return Integer.parseInt(cardNnumer);
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\game\GameShiDao.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */