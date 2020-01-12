/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.ArrayList;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M20480_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_PETS;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M8165_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*    */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C41040_2 implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 25 */     int petNum = GameReadTool.readByte(buff);
/*    */     
/* 27 */     int pet = GameReadTool.readInt(buff);
/*    */     
/* 29 */     int itemNum = GameReadTool.readByte(buff);
/*    */     
/* 31 */     int itemList1 = GameReadTool.readInt(buff);
/*    */     
/* 33 */     int itemList2 = GameReadTool.readInt(buff);
/*    */     
/* 35 */     int itemList3 = GameReadTool.readInt(buff);
/*    */     
/* 37 */     int itemList4 = GameReadTool.readInt(buff);
/*    */     
/* 39 */     int itemList5 = GameReadTool.readInt(buff);
/* 40 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/* 41 */     GameUtil.removemunber(chara, "控心玉", 1);
/* 42 */     GameUtil.removemunber(chara, "定鞍石", 1);
/* 43 */     GameUtil.removemunber(chara, "驱力刺", 1);
/* 44 */     GameUtil.removemunber(chara, "困灵砂", 1);
/* 45 */     GameUtil.removemunber(chara, "拘首环", 1);
/*    */     
/* 47 */     for (int i = 0; i < chara.pets.size(); i++) {
/* 48 */       if (pet == ((Petbeibao)chara.pets.get(i)).id) {
/* 49 */         PetShuXing petShuXing = new PetShuXing();
/* 50 */         ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).suit_light_effect = 2;
/* 51 */         for (int j = 0; j < ((Petbeibao)chara.pets.get(i)).petShuXing.size(); j++) {
/* 52 */           if (((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(j)).no == 23) {
/* 53 */             ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(j)).upgrade_magic = ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).hide_mount;
/* 54 */             ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(j)).upgrade_total = ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).hide_mount;
/* 55 */             ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(j)).all_polar = ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).hide_mount;
/*    */           }
/*    */         }
/* 58 */         ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).capacity_level = (5 * ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).hide_mount);
/* 59 */         ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).mount_attribmove_speed = 2067321385;
/*    */         
/* 61 */         List list = new ArrayList();
/* 62 */         list.add(chara.pets.get(i));
/* 63 */         GameObjectChar.send(new MSG_UPDATE_PETS(), list);
/* 64 */         Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/* 65 */         vo_8165_0.msg = ("恭喜你将#R" + ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).str + "#n驯化为御灵了，并增加了#R30#n天风灵丸时间。");
/* 66 */         vo_8165_0.active = 0;
/* 67 */         GameObjectChar.send(new M8165_0(), vo_8165_0);
/* 68 */         Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/* 69 */         vo_20480_0.msg = ("恭喜你花费#R拘首环#n、#R困灵砂#n、#R驱力刺#n、#R定鞍石#n、#R控心玉#n各1个将#R" + ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).str + "#n驯化为御灵了，并增加了#R30#n天风灵丸时间。");
/* 70 */         vo_20480_0.time = ((int)(System.currentTimeMillis() / 1000L));
/* 71 */         GameObjectChar.send(new M20480_0(), vo_20480_0);
/*    */       }
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 82 */     return 41040;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C41040_2.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */