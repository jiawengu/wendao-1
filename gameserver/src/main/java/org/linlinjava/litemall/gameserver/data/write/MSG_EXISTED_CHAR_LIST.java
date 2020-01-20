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
/* 16 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(vo_61537_0.severState));
/* 17 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(vo_61537_0.count));
/*    */     
/* 19 */     for (Vo_61537_0 vo : vo_61537_0.vo_61537_0) {
/* 20 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(17));
/* 21 */       BuildFields.get("extra_desc").write(writeBuf, Integer.valueOf(vo.extra_desc));
/* 22 */       BuildFields.get("trading_sell_buy_type").write(writeBuf, Integer.valueOf(vo.trading_sell_buy_type));
/* 23 */       BuildFields.get("trading_state").write(writeBuf, vo.trading_state);
/* 24 */       BuildFields.get("passive_mode").write(writeBuf, Integer.valueOf(vo.passive_mode));
/* 25 */       BuildFields.get("trading_left_time").write(writeBuf, Integer.valueOf(vo.trading_left_time));
/* 26 */       BuildFields.get("trading_buyout_price").write(writeBuf, vo.trading_buyout_price);
/* 27 */       BuildFields.get("trading_price").write(writeBuf, Integer.valueOf(vo.trading_price));
/* 28 */       BuildFields.get("skill").write(writeBuf, Integer.valueOf(vo.skill));
/* 29 */       BuildFields.get("metal").write(writeBuf, Integer.valueOf(vo.metal));
/* 30 */       BuildFields.get("type").write(writeBuf, Integer.valueOf(vo.type));
/* 31 */       BuildFields.get("trading_cg_price_ti").write(writeBuf, Integer.valueOf(vo.trading_cg_price_ti));
/* 32 */       BuildFields.get("str").write(writeBuf, vo.str);
/* 33 */       BuildFields.get("iid_str").write(writeBuf, vo.iid_str);
/* 34 */       BuildFields.get("dan_data/state").write(writeBuf, Integer.valueOf(vo.dan_datastate));
/* 35 */       BuildFields.get("char_online_state").write(writeBuf, Integer.valueOf(vo.char_online_state));
/* 36 */       BuildFields.get("trading_org_price").write(writeBuf, Integer.valueOf(vo.trading_org_price));
/* 37 */       BuildFields.get("trading_appointee_name").write(writeBuf, Integer.valueOf(vo.trading_appointee_name));
/* 38 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(vo.last_login_time));
/*    */     }
/* 40 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(vo_61537_0.openServerTime));
/*    */     
/* 42 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(vo_61537_0.account_online));
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