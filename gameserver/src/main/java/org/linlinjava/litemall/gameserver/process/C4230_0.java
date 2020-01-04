/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */
/*    */ import org.linlinjava.litemall.db.domain.StoreInfo;
/*    */
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_12269_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_40964_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M12269_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*    */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*    */ import org.linlinjava.litemall.gameserver.game.GameData;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C4230_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 25 */     int id = GameReadTool.readInt(buff);
/*    */     
/* 27 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*    */     
/* 29 */     int owner_id = 1;
/* 30 */     for (int i = 0; i < chara.pets.size(); i++) {
/* 31 */       if (((Petbeibao)chara.pets.get(i)).id == id)
/*    */       {
/* 33 */         if (((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).skill >= 50) {
/* 34 */           owner_id = 10;
/*    */         }
/* 36 */         if (((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).penetrate == 1) {
/* 37 */           owner_id = 0;
/*    */         }
/* 39 */         chara.pets.remove(chara.pets.get(i));
/* 40 */         break;
/*    */       }
/*    */     }
/*    */     
/* 44 */     if (owner_id > 0) {
/* 45 */       Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/* 46 */       vo_20481_0.msg = ("获得了#R" + owner_id + "#n颗宠物经验丹。");
/* 47 */       vo_20481_0.time = 1562987118;
/* 48 */       GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*    */       
/*    */ 
/* 51 */       Vo_40964_0 vo_40964_0 = new Vo_40964_0();
/* 52 */       vo_40964_0.type = 1;
/* 53 */       vo_40964_0.name = "宠物经验丹";
/* 54 */       vo_40964_0.param = "1";
/* 55 */       vo_40964_0.rightNow = 0;
/* 56 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40964_0(), vo_40964_0);
/*    */       
/* 58 */       StoreInfo storeInfo = GameData.that.baseStoreInfoService.findOneByName("宠物经验丹");
/* 59 */       GameUtil.huodedaoju(chara, storeInfo, owner_id);
/*    */     }
/* 61 */     Vo_12269_0 vo_12269_0 = new Vo_12269_0();
/* 62 */     vo_12269_0.id = id;
/* 63 */     vo_12269_0.owner_id = 96780;
/* 64 */     GameObjectChar.send(new M12269_0(), vo_12269_0);
/*    */   }
/*    */   
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 70 */     return 4230;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C4230_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */