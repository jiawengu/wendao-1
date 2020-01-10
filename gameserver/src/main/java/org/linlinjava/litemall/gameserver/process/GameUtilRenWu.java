/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import java.text.ParseException;
/*     */ import java.text.SimpleDateFormat;
/*     */ import java.util.Calendar;
/*     */ import java.util.Date;
/*     */
/*     */ import java.util.List;
import java.util.Random;
/*     */ import org.linlinjava.litemall.db.domain.Map;
/*     */ import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.db.domain.Pet;
import org.linlinjava.litemall.db.domain.ShangGuYaoWangInfo;
import org.linlinjava.litemall.gameserver.data.vo.Vo_61553_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_APPEAR;
import org.linlinjava.litemall.gameserver.data.write.MSG_TASK_PROMPT;
/*     */
import org.linlinjava.litemall.gameserver.data.write.MSG_TITLE;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_APPEARANCE;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
/*     */

/*     */
/*     */ public class GameUtilRenWu
/*     */ {
/*     */   public static void renwukuangkuang(String task_type, String task_prompt, String show_name, Chara chara1)
/*     */   {
/*  27 */     Vo_61553_0 vo_61553_0 = new Vo_61553_0();
/*  28 */     vo_61553_0.count = 1;
/*  29 */     vo_61553_0.task_type = task_type;
/*  30 */     vo_61553_0.task_desc = "";
/*  31 */     vo_61553_0.task_prompt = task_prompt;
/*  32 */     vo_61553_0.refresh = 1;
/*  33 */     vo_61553_0.task_end_time = 1567909190;
/*  34 */     vo_61553_0.attrib = 1;
/*  35 */     vo_61553_0.reward = "#I经验|人物经验宠物经验#I#I道行|道行#I#I潜能|潜能#I#I武学|武学#I#I金钱|金钱#I";
/*  36 */     vo_61553_0.show_name = show_name;
/*  37 */     vo_61553_0.tasktask_extra_para = "";
/*  38 */     vo_61553_0.tasktask_state = "1";
/*  39 */     GameObjectChar.sendduiwu(new MSG_TASK_PROMPT(), vo_61553_0, chara1.id);
/*     */   }
/*     */   
/*     */   public static String shidaolevel(Chara chara) {
/*  43 */     if (!belongCalendarshidao()) {
/*  44 */       return "不在活动时间内";
/*     */     }
/*  46 */     GameObjectChar session = GameObjectCharMng.getGameObjectChar(chara.id);
/*  47 */     String[] shidaolevel = { "试道场(60-79)", "试道场(80-89)", "试道场(90-99)", "试道场(100-109)", "试道场(110-119)", "试道场(120-129)" };
/*  48 */     String mapname = "";
/*  49 */     if ((session.gameTeam != null) && (session.gameTeam.duiwu != null))
/*     */     {
/*  51 */       if (session.gameTeam.duiwu.size() < 3) {
/*  52 */         return mapname;
/*     */       }
/*  54 */       for (int i = 0; i < session.gameTeam.duiwu.size(); i++) {
/*  55 */         if (((Chara)session.gameTeam.duiwu.get(i)).level < 60)
/*  56 */           return mapname;
/*  57 */         if ((((Chara)session.gameTeam.duiwu.get(i)).level >= 60) && (((Chara)session.gameTeam.duiwu.get(i)).level < 80)) {
/*  58 */           if (mapname.equals("")) {
/*  59 */             mapname = shidaolevel[0];
/*     */           }
/*  61 */           else if (!mapname.equals(shidaolevel[0])) {
/*  62 */             return "";
/*     */           }
/*     */         }
/*  65 */         else if ((((Chara)session.gameTeam.duiwu.get(i)).level >= 80) && (((Chara)session.gameTeam.duiwu.get(i)).level < 90)) {
/*  66 */           if (mapname.equals("")) {
/*  67 */             mapname = shidaolevel[1];
/*     */           }
/*  69 */           else if (!mapname.equals(shidaolevel[1])) {
/*  70 */             return "";
/*     */           }
/*     */         }
/*  73 */         else if ((((Chara)session.gameTeam.duiwu.get(i)).level >= 90) && (((Chara)session.gameTeam.duiwu.get(i)).level < 100)) {
/*  74 */           if (mapname.equals("")) {
/*  75 */             mapname = shidaolevel[2];
/*     */           }
/*  77 */           else if (!mapname.equals(shidaolevel[2])) {
/*  78 */             return "";
/*     */           }
/*     */         }
/*  81 */         else if ((((Chara)session.gameTeam.duiwu.get(i)).level >= 100) && (((Chara)session.gameTeam.duiwu.get(i)).level < 110)) {
/*  82 */           if (mapname.equals("")) {
/*  83 */             mapname = shidaolevel[3];
/*     */           }
/*  85 */           else if (!mapname.equals(shidaolevel[3])) {
/*  86 */             return "";
/*     */           }
/*     */         }
/*  89 */         else if ((((Chara)session.gameTeam.duiwu.get(i)).level >= 110) && (((Chara)session.gameTeam.duiwu.get(i)).level < 120)) {
/*  90 */           if (mapname.equals("")) {
/*  91 */             mapname = shidaolevel[4];
/*     */           }
/*  93 */           else if (!mapname.equals(shidaolevel[4])) {
/*  94 */             return "";
/*     */           }
/*     */         }
/*  97 */         else if ((((Chara)session.gameTeam.duiwu.get(i)).level >= 120) && (((Chara)session.gameTeam.duiwu.get(i)).level < 130)) {
/*  98 */           if (mapname.equals("")) {
/*  99 */             mapname = shidaolevel[5];
/*     */           }
/* 101 */           else if (!mapname.equals(shidaolevel[5])) {
/* 102 */             return "";
/*     */           }
/*     */         }
/*     */       }
/*     */     }
/*     */     else {
/* 108 */       return mapname;
/*     */     }
/*     */     
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/* 115 */     return mapname;
/*     */   }
/*     */   
/*     */ 
/*     */   public static void feiditu(int mapid, Chara chara)
/*     */   {
/* 121 */     if ((GameObjectCharMng.getGameObjectChar(chara.id).gameTeam != null) && (GameObjectCharMng.getGameObjectChar(chara.id).gameTeam.duiwu.size() > 0))
/*     */     {
/* 123 */       for (int i = 0; i < GameObjectCharMng.getGameObjectChar(chara.id).gameTeam.duiwu.size(); i++) {
/* 124 */         if (((Chara)GameObjectCharMng.getGameObjectChar(chara.id).gameTeam.duiwu.get(i)).id != chara.id) {
/* 125 */           Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/* 126 */           vo_61671_0.id = ((Chara)GameObjectCharMng.getGameObjectChar(chara.id).gameTeam.duiwu.get(i)).id;
/* 127 */           vo_61671_0.count = 2;
/* 128 */           vo_61671_0.list.add(Integer.valueOf(2));
/* 129 */           vo_61671_0.list.add(Integer.valueOf(5));
/* 130 */           GameObjectCharMng.getGameObjectChar(chara.id).gameMap.send(new MSG_TITLE(), vo_61671_0);
/* 131 */           vo_61671_0 = new Vo_61671_0();
/* 132 */           vo_61671_0.id = chara.id;
/* 133 */           vo_61671_0.count = 2;
/* 134 */           vo_61671_0.list.add(Integer.valueOf(2));
/* 135 */           vo_61671_0.list.add(Integer.valueOf(3));
/* 136 */           GameObjectCharMng.getGameObjectChar(chara.id).gameMap.send(new MSG_TITLE(), vo_61671_0);
/*     */         }
/*     */       }
/*     */     }
/*     */     
/*     */ 
/*     */ 
/* 143 */     for (int i = 0; i < chara.npcchubao.size(); i++) {
/* 144 */       if (mapid == ((Vo_65529_0)chara.npcchubao.get(i)).mapid) {
/* 145 */         GameObjectChar.sendduiwu(new MSG_APPEAR(), chara.npcchubao.get(i), chara.id);
/*     */       }
/*     */     }
/*     */     
/* 149 */     for (int i = 0; i < chara.npcshuadao.size(); i++) {
/* 150 */       if (mapid == ((Vo_65529_0)chara.npcshuadao.get(i)).mapid) {
/* 151 */         GameObjectChar.sendduiwu(new MSG_APPEAR(), chara.npcshuadao.get(i), chara.id);
/*     */       }
/*     */     }
/*     */     
/* 155 */     for (int i = 0; i < chara.npcxuanshang.size(); i++) {
/* 156 */       if (mapid == ((Vo_65529_0)chara.npcxuanshang.get(i)).mapid) {
/* 157 */         GameObjectChar.sendduiwu(new MSG_APPEAR(), chara.npcxuanshang.get(i), chara.id);
/*     */       }
/*     */     }
/*     */     
/*     */ 
/*     */ 
/*     */ 
/* 164 */     org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0 vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE(chara);
/* 165 */     GameObjectCharMng.getGameObjectChar(chara.id).gameMap.send(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/* 166 */     if ((GameObjectCharMng.getGameObjectChar(chara.id).gameTeam != null) && (GameObjectCharMng.getGameObjectChar(chara.id).gameTeam.duiwu.size() > 0) && 
/* 167 */       (((Chara)GameObjectCharMng.getGameObjectChar(chara.id).gameTeam.duiwu.get(0)).id == chara.id)) {
/* 168 */       Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/* 169 */       vo_61671_0.id = chara.id;
/* 170 */       vo_61671_0.count = 2;
/* 171 */       vo_61671_0.list.add(Integer.valueOf(2));
/* 172 */       vo_61671_0.list.add(Integer.valueOf(3));
/* 173 */       GameObjectCharMng.getGameObjectChar(chara.id).gameMap.send(new MSG_TITLE(), vo_61671_0);
/*     */     }
/*     */     
/*     */ 
/* 177 */     GameUtil.genchongfei(chara);
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */   public static String[] luckFindDraw()
/*     */   {
/* 188 */     String nameType = "";
/* 189 */     String[] yiDing = { "帅帅猴#变异", "蛋蛋鸡#变异", "乖乖狗#变异", "招财猪#变异", "岳麓剑#精怪", "筋斗云#精怪" };
//              String[] shangGuYaoWang = { "上古妖王1#上古妖王#50", "上古妖王2#上古妖王#52",
//                      "上古妖王3#上古妖王#54", "上古妖王4#上古妖王#56", "上古妖王5#上古妖王#58",
//                      "上古妖王6#上古妖王#60", "上古妖王7#上古妖王#62","上古妖王8#上古妖王#64",
//                      "上古妖王9#上古妖王#66", "上古妖王10#上古妖王#68", "上古妖王11#上古妖王#70",
//                      "上古妖王12#上古妖王#72", "上古妖王13#上古妖王#74", "上古妖王14#上古妖王#76", "上古妖王15#上古妖王#78",
//                      "上古妖王16#上古妖王#80", "上古妖王17#上古妖王#82", "上古妖王18#上古妖王#84", "上古妖王92#上古妖王#86",
//                      "上古妖王20#上古妖王#88"};
/* 190 */     String[] erDing = { "召唤令·十二生肖#物品" };
/* 191 */     String[] siDing = { "60级首饰#首饰" };
/* 192 */     Random random = new Random();
/* 193 */     int r = random.nextInt(1000) + 1;
/* 194 */     if (r <= 3) {
/* 195 */       nameType = yiDing[random.nextInt(yiDing.length)];
/* 196 */     } else if (r < 20) {
/* 197 */       nameType = erDing[random.nextInt(erDing.length)];
/*     */     }
/* 199 */     else if (r < 50) {
        /* 200 */
                nameType = siDing[random.nextInt(siDing.length)];
    }         else if (r < 100){
                List<ShangGuYaoWangInfo> infos =
                        GameData.that.BaseShangGuYaoWangInfoService.findAllCloseState();
                ShangGuYaoWangInfo info =
                        infos.get(random.nextInt(infos.size()));
                Npc npc = GameData.that.baseNpcService.findById(info.getNpcid());
                //nameType =
                //shangGuYaoWang[random.nextInt(shangGuYaoWang.length)];
                    nameType = npc.getName();// shangGuYaoWang[0];
/*     */     } else {
/* 202 */       int money = 1000000 + random.nextInt(300000);
/* 203 */       nameType = String.format("%d#金币", new Object[] { Integer.valueOf(money) });
/*     */     }
/*     */     
/*     */ 
/* 207 */     return nameType.split("#");
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */ 
/*     */   public static String dateToWeekday(Date changeDate)
/*     */   {
/* 215 */     String[] weekdays = { "周日", "周一", "周二", "周三", "周四", "周五", "周六" };
/* 216 */     if (changeDate == null) {}
/*     */     
/*     */ 
/* 219 */     Calendar cal = Calendar.getInstance();
/* 220 */     cal.setTime(changeDate);
/* 221 */     int numOfWeek = cal.get(7) - 1;
/* 222 */     return weekdays[numOfWeek];
/*     */   }
/*     */   
/*     */   public static int dayForWeek(String pTime) throws Throwable
/*     */   {
/* 227 */     SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
/*     */     
/* 229 */     Date tmpDate = format.parse(pTime);
/*     */     
/* 231 */     Calendar cal = new java.util.GregorianCalendar();
/*     */     
/* 233 */     cal.set(tmpDate.getYear(), tmpDate.getMonth(), tmpDate.getDay());
/*     */     
/* 235 */     return cal.get(7);
/*     */   }
/*     */   
/*     */ 
/*     */   public static void huicheng(Chara chara)
/*     */   {
/* 241 */     Map map = GameData.that.baseMapService.findOneByName("天墉城");
/* 242 */     chara.y = map.getY().intValue();
/* 243 */     chara.x = map.getX().intValue();
/* 244 */     org.linlinjava.litemall.gameserver.game.GameLine.getGameMapname(chara.line, map.getName()).join(GameObjectCharMng.getGameObjectChar(chara.id));
/*     */   }
/*     */   
/*     */   public static void shidaohuicheng(Chara chara)
/*     */   {
/* 249 */     chara.shidaodaguaijifen = 0;
/* 250 */     huicheng(chara);
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */   public static boolean isShangGuYaoWang(Chara chara){
                if(0 == chara.changbaotu.icon) return  false;
                List<Pet> monsterList = GameData.that.basePetService.findByZoon(GameObjectChar.getGameObjectChar().chara.mapName);
                if(0 == monsterList.size()) return  false;
                Pet pet = null;
                for (int i = 0; i < monsterList.size(); i++) {
                    Pet tempPet = monsterList.get(i);
                    if (tempPet.getName().contains("上古妖王")){
                        pet = tempPet;
                        break;
                    }
                }
                if (null == pet) return  false;

                return  true;
            }
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */   public static boolean belongCalendarshidao()
/*     */   {
/* 262 */     Date nowTime = null;
/* 263 */     Date beginTime = null;
/* 264 */     Date endTime = null;
/* 265 */     SimpleDateFormat df = new SimpleDateFormat("HH:mm");
/*     */     try
/*     */     {
/* 268 */       nowTime = df.parse(df.format(new Date()));
/* 269 */       beginTime = df.parse("20:49");
/* 270 */       endTime = df.parse("23:30");
/*     */     } catch (ParseException e) {
/* 272 */       e.printStackTrace();
/*     */     }
/*     */     
/* 275 */     Calendar date = Calendar.getInstance();
/* 276 */     date.setTime(nowTime);
/*     */     
/* 278 */     Calendar begin = Calendar.getInstance();
/* 279 */     begin.setTime(beginTime);
/*     */     
/* 281 */     Calendar end = Calendar.getInstance();
/* 282 */     end.setTime(endTime);
/*     */     
/* 284 */     if ((date.after(begin)) && (date.before(end))) {
/* 285 */       return true;
/*     */     }
/* 287 */     return false;
/*     */   }

    /**
     * 通知通天塔任务
     */
    public static void notifyTTTTask(Chara chara){
        if(chara.ttt_layer==0){
            return;
        }
        Vo_61553_0 vo_61553_0 = new Vo_61553_0();
        vo_61553_0.count = 1;
        vo_61553_0.task_type = "通天塔";
        vo_61553_0.task_desc = "通天塔";
        vo_61553_0.task_prompt = "挑战#P"+chara.ttt_xj_name+"#P";
        vo_61553_0.refresh = 1;
        vo_61553_0.task_end_time = 1567909190;
        vo_61553_0.attrib = 1;
        vo_61553_0.reward = "#I经验|人物经验宠物经验#I#I道行|道行#I#I潜能|潜能#I#I武学|武学#I#I金钱|金钱#I";
        vo_61553_0.show_name = "通天塔";
        vo_61553_0.tasktask_extra_para = "";
        vo_61553_0.tasktask_state = "1";
        GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_0);
    }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\GameUtilRenWu.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */