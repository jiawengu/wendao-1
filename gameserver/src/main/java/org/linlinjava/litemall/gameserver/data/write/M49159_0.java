/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_49159_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M49159_0 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     Vo_49159_0 object1 = (Vo_49159_0)object;
/* 14 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.leftTime));
/*    */     
/* 16 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.times));
/*    */     
/* 18 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.leftTimes));
/*    */     
/* 20 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isCanSign));
/*    */     
/* 22 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isCanGetNewPalyerGift));
/*    */     
/* 24 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.firstChargeState));
/*    */     
/* 26 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.cumulativeReward));
/*    */     
/* 28 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.loginGiftState));
/*    */     
/* 30 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.activeCount));
/*    */     
/* 32 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.holidayCount));
/*    */     
/* 34 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isCanReplenishSign));
/*    */     
/* 36 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.chargePointFlag));
/*    */     
/* 38 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.consumePointFlag));
/*    */     
/* 40 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isShowHuiGui));
/*    */     
/* 42 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.canGetZXQYHuoYue));
/*    */     
/* 44 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.canGetZXQYSevenLogin));
/*    */     
/* 46 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isShowZhaohui));
/*    */     
/* 48 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.activeVIPFlag));
/*    */     
/* 50 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.rename_discount_time));
/*    */     
/* 52 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.summerSF2017));
/*    */     
/* 54 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.zaohua));
/*    */     
/* 56 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.welcomeDrawStatue));
/*    */     
/* 58 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.activeLoginStatue));
/*    */     
/* 60 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.xundcf));
/*    */     
/* 62 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.mergeLoginStatus));
/*    */     
/* 64 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.mergeLoginActiveStatus));
/*    */     
/* 66 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.reentryAsktaoRecharge));
/*    */     
/* 68 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.expStoreStatus));
/*    */     
/* 70 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isShowXYFL));
/*    */     
/* 72 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isShowXFSD));
/*    */     
/* 74 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.newServeAddNum));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 79 */     return 49159;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M49159_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */