/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41505_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_4197_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M61677_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M8165_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_INVENTORY;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_APPEARANCE;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*    */
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class C41501_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 22 */     int pos = org.linlinjava.litemall.gameserver.data.GameReadTool.readShort(buff);
/*    */     
/* 24 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/* 25 */     for (int i = 0; i < chara.backpack.size(); i++) {
/* 26 */       if (((Goods)chara.backpack.get(i)).pos == pos) {
/* 27 */         List<Goods> listbeibao = new java.util.ArrayList();
/* 28 */         Goods goods2 = new Goods();
/* 29 */         goods2.goodsBasics = null;
/* 30 */         goods2.goodsInfo = null;
/* 31 */         goods2.goodsLanSe = null;
/* 32 */         goods2.pos = ((Goods)chara.backpack.get(i)).pos;
/* 33 */         listbeibao.add(goods2);
/* 34 */         GameObjectChar.send(new MSG_INVENTORY(), listbeibao);
/* 35 */         chara.backpack.remove(chara.backpack.get(i));
/*    */       }
/*    */     }
/* 38 */     if (pos == 31) {
/* 39 */       chara.special_icon = 0;
/*    */     }
/* 41 */     if (pos == 32) {
/* 42 */       chara.texiao_icon = 0;
/*    */     }
/* 44 */     if (pos == 37) {
/* 45 */       Vo_4197_0 vo_4197_0 = new Vo_4197_0();
/* 46 */       vo_4197_0.id = 0;
/* 47 */       GameObjectChar.getGameObjectChar().gameMap.send(new org.linlinjava.litemall.gameserver.data.write.M4197_0(), vo_4197_0);
/* 48 */       GameObjectChar.getGameObjectChar().gameMap.send(new org.linlinjava.litemall.gameserver.data.write.M12285_1(), Integer.valueOf(chara.genchong_icon));
/* 49 */       chara.genchong_icon = 0;
/*    */     }
/*    */     
/* 52 */     Vo_61677_0 vo_61677_0 = new Vo_61677_0();
/* 53 */     vo_61677_0.store_type = "follow_pet_store";
/* 54 */     vo_61677_0.npcID = 0;
/* 55 */     vo_61677_0.list = chara.genchong;
/* 56 */     vo_61677_0.count = chara.genchong.size();
/* 57 */     GameObjectChar.send(new M61677_0(), vo_61677_0);
/*    */     
/* 59 */     vo_61677_0 = new Vo_61677_0();
/* 60 */     vo_61677_0.store_type = "fasion_store";
/* 61 */     vo_61677_0.npcID = 0;
/* 62 */     vo_61677_0.list = chara.shizhuang;
/* 63 */     vo_61677_0.count = chara.shizhuang.size();
/* 64 */     GameObjectChar.send(new M61677_0(), vo_61677_0);
/*    */     
/*    */ 
/* 67 */     vo_61677_0 = new Vo_61677_0();
/* 68 */     vo_61677_0.store_type = "effect_store";
/* 69 */     vo_61677_0.npcID = 0;
/* 70 */     vo_61677_0.list = chara.texiao;
/* 71 */     vo_61677_0.count = chara.texiao.size();
/* 72 */     GameObjectChar.send(new M61677_0(), vo_61677_0);
/*    */     
/* 74 */     org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0 vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE(chara);
/* 75 */     GameObjectChar.getGameObjectChar().gameMap.send(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/*    */     
/*    */ 
/* 78 */     Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/* 79 */     vo_8165_0.msg = "卸下成功！";
/* 80 */     vo_8165_0.active = 0;
/* 81 */     GameObjectChar.send(new M8165_0(), vo_8165_0);
/* 82 */     Vo_41505_0 vo_41505_0 = new Vo_41505_0();
/* 83 */     vo_41505_0.type = "unequip_fasion";
/* 84 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M41505_0(), vo_41505_0);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 89 */     return 41501;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C41501_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */