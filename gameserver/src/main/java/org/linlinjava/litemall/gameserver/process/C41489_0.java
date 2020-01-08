/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41488_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41505_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M41488_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M41505_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_APPEARANCE;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_TITLE;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C41489_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 24 */     int fasion_label = GameReadTool.readByte(buff);
/* 25 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*    */     
/* 27 */     Vo_61661_0 vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE(chara);
/* 28 */     GameObjectChar.getGameObjectChar().gameMap.send(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/*    */     
/* 30 */     Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/* 31 */     vo_61671_0.id = chara.id;
/* 32 */     vo_61671_0.count = 0;
/* 33 */     GameObjectChar.send(new MSG_TITLE(), vo_61671_0);
/*    */     
/*    */ 
/*    */ 
/* 37 */     Vo_41488_0 vo_41488_0 = new Vo_41488_0();
/* 38 */     vo_41488_0.flag = 1;
/* 39 */     vo_41488_0.label = 0;
/* 40 */     vo_41488_0.para = "CustomDressDlg";
/* 41 */     vo_41488_0.count2 = 20;
/* 42 */     vo_41488_0.name0 = "点红烛·永久";
/* 43 */     vo_41488_0.goods_price0 = 26888;
/* 44 */     vo_41488_0.name1 = "日耀辰辉·永久";
/* 45 */     vo_41488_0.goods_price1 = 26888;
/* 46 */     vo_41488_0.name2 = "星垂月涌·永久";
/* 47 */     vo_41488_0.goods_price2 = 26888;
/* 48 */     vo_41488_0.name3 = "剑魄琴心·永久";
/* 49 */     vo_41488_0.goods_price3 = 26888;
/* 50 */     vo_41488_0.name4 = "引天长歌·永久";
/* 51 */     vo_41488_0.goods_price4 = 26888;
/* 52 */     vo_41488_0.name5 = "如意年·永久";
/* 53 */     vo_41488_0.goods_price5 = 26888;
/* 54 */     vo_41488_0.name6 = "星火昭·永久";
/* 55 */     vo_41488_0.goods_price6 = 26888;
/* 56 */     vo_41488_0.name7 = "吉祥天·永久";
/* 57 */     vo_41488_0.goods_price7 = 26888;
/* 58 */     vo_41488_0.name8 = "汉宫秋·永久";
/* 59 */     vo_41488_0.goods_price8 = 36888;
/* 60 */     vo_41488_0.name9 = "凤鸣空·永久";
/* 61 */     vo_41488_0.goods_price9 = 36888;
/* 62 */     vo_41488_0.name10 = "水光衫·永久";
/* 63 */     vo_41488_0.goods_price10 = 36888;
/* 64 */     vo_41488_0.name11 = "月孤影·永久";
/* 65 */     vo_41488_0.goods_price11 = 36888;
/* 66 */     vo_41488_0.name12 = "狐灵娇·永久";
/* 67 */     vo_41488_0.goods_price12 = 36888;
/* 68 */     vo_41488_0.name13 = "晓色红妆·永久";
/* 69 */     vo_41488_0.goods_price13 = 36888;
/* 70 */     vo_41488_0.name14 = "千秋梦·永久";
/* 71 */     vo_41488_0.goods_price14 = 36888;
/* 72 */     vo_41488_0.name15 = "龙吟水·永久";
/* 73 */     vo_41488_0.goods_price15 = 36888;
/* 74 */     vo_41488_0.name16 = "峥岚衣·永久";
/* 75 */     vo_41488_0.goods_price16 = 36888;
/* 76 */     vo_41488_0.name17 = "狐灵逸·永久";
/* 77 */     vo_41488_0.goods_price17 = 36888;
/* 78 */     vo_41488_0.name18 = "云暮风华·永久";
/* 79 */     vo_41488_0.goods_price18 = 36888;
/* 80 */     vo_41488_0.name19 = "星寒魄·永久";
/* 81 */     vo_41488_0.goods_price19 = 36888;
/* 82 */     GameObjectChar.send(new M41488_0(), vo_41488_0);
/* 83 */     Vo_41505_0 vo_41505_0 = new Vo_41505_0();
/* 84 */     vo_41505_0.type = "swicth_label";
/* 85 */     GameObjectChar.send(new M41505_0(), vo_41505_0);
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 92 */     return 41489;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C41489_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */