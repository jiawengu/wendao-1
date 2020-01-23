/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.ListVo_61537_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61537_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_EXISTED_CHAR_LIST extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 15 */     ListVo_61537_0 vo_61537_0 = (ListVo_61537_0)object;
/* 16 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(vo_61537_0.severState));//severState
/* 17 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(vo_61537_0.count));//count
/*    */     
/* 19 */     for (Vo_61537_0 vo : vo_61537_0.vo_61537_0) {
/* 20 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(17));//size
/* 21 */       BuildFields.get("left_time_to_delete").write(writeBuf, Integer.valueOf(vo.left_time_to_delete));//left_time_to_delete
/* 22 */       BuildFields.get("trading_sell_buy_type").write(writeBuf, Integer.valueOf(vo.trading_sell_buy_type));
/* 23 */       BuildFields.get("trading_state").write(writeBuf, vo.trading_state);
/* 24 */       BuildFields.get("portrait").write(writeBuf, Integer.valueOf(vo.portrait));//portrait 肖像
/* 25 */       BuildFields.get("trading_left_time").write(writeBuf, Integer.valueOf(vo.trading_left_time));
/* 26 */       BuildFields.get("trading_buyout_price").write(writeBuf, vo.trading_buyout_price);
/* 27 */       BuildFields.get("trading_price").write(writeBuf, Integer.valueOf(vo.trading_price));
/* 28 */       BuildFields.get("level").write(writeBuf, Integer.valueOf(vo.level));//level
/* 29 */       BuildFields.get("polar").write(writeBuf, Integer.valueOf(vo.polar));
/* 30 */       BuildFields.get("icon").write(writeBuf, Integer.valueOf(vo.icon));
/* 31 */       BuildFields.get("trading_cg_price_ti").write(writeBuf, Integer.valueOf(vo.trading_cg_price_ti));
/* 32 */       BuildFields.get("name").write(writeBuf, vo.name);//name
/* 33 */       BuildFields.get("gid").write(writeBuf, vo.gid);
/* 34 */       BuildFields.get("dan_data/state").write(writeBuf, Integer.valueOf(vo.dan_datastate));
/* 35 */       BuildFields.get("char_online_state").write(writeBuf, Integer.valueOf(vo.char_online_state));
/* 36 */       BuildFields.get("trading_org_price").write(writeBuf, Integer.valueOf(vo.trading_org_price));
/* 37 */       BuildFields.get("trading_appointee_name").write(writeBuf, Integer.valueOf(vo.trading_appointee_name));
/* 38 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(vo.last_login_time));//last_login_time
/*    */     }
/* 40 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(vo_61537_0.openServerTime));//openServerTime
/*    */     
/* 42 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(vo_61537_0.account_online));//0:不在线，1：在线，2托管中
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 47 */     return 61537;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M61537_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */