/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.db.domain.SaleGood;
/*    */
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_49179_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M49179_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.game.GameData;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C33054_0
/*    */   implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 26 */     String goods_gid = GameReadTool.readString(buff);
/*    */     
/* 28 */     int price = GameReadTool.readInt(buff);
/*    */     
/* 30 */     SaleGood saleGood = GameData.that.saleGoodService.findOneByGoodsId(goods_gid);
/* 31 */     saleGood.setPrice(Integer.valueOf(price));
/* 32 */     GameData.that.saleGoodService.updateById(saleGood);
/* 33 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*    */     
/* 35 */     chara.balance -= 20000;
/* 36 */     ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/*    */     
/* 38 */     Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/* 39 */     vo_20481_0.msg = "改价成功";
/* 40 */     vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
/* 41 */     GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/* 42 */     List<SaleGood> saleGoodList = GameData.that.saleGoodService.findByOwnerUuid(chara.uuid);
/* 43 */     Vo_49179_0 vo_49179_0 = GameUtil.a49179(saleGoodList, chara);
/* 44 */     GameObjectChar.send(new M49179_0(), vo_49179_0);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 49 */     return 33054;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C33054_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */