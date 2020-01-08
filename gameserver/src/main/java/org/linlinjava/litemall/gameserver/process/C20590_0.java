/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.db.domain.Characters;
/*    */
/*    */ import org.linlinjava.litemall.db.util.JSONUtils;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_24505_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_53569_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61545_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M16383_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M24505_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M53569_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M61545_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.game.GameData;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ 
/*    */ @Service
/*    */ public class C20590_0
/*    */   implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 32 */     int flag = GameReadTool.readShort(buff);
/*    */     
/* 34 */     String name = GameReadTool.readString(buff);
/*    */     
/* 36 */     int compress = GameReadTool.readShort(buff);
/*    */     
/* 38 */     int orgLength = GameReadTool.readShort(buff);
/*    */     
/* 40 */     String msg = GameReadTool.readString2(buff);
/*    */     
/* 42 */     int cardCount = GameReadTool.readShort(buff);
/*    */     
/* 44 */     int voiceTime = GameReadTool.readInt(buff);
/*    */     
/* 46 */     String token = GameReadTool.readString2(buff);
/*    */     
/* 48 */     String receive_gid = GameReadTool.readString(buff);
/*    */     
/*    */ 
/* 51 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/* 52 */     Characters characters = GameData.that.characterService.findOneByName(name);
/* 53 */     String data = characters.getData();
/* 54 */     Chara chara1 = (Chara)JSONUtils.parseObject(data, Chara.class);
/* 55 */     Vo_24505_0 vo_24505_0 = GameUtil.MSG_FRIEND_UPDATE_PARTIAL(chara1);
/* 56 */     GameObjectChar.send(new M24505_0(), vo_24505_0);
/* 57 */     List<Vo_61545_0> vo_61545_0List = GameUtil.a61545(chara1);
/* 58 */     GameObjectChar.send(new M61545_0(), vo_61545_0List);
/* 59 */     Vo_16383_0 vo_16383_0 = GameUtil.a16383(chara, msg, 9, chara1);
/* 60 */     GameObjectChar.getGameObjectChar();GameObjectChar.send(new M16383_0(), vo_16383_0);
/* 61 */     if (GameObjectCharMng.getGameObjectChar(chara1.id) != null) {
/* 62 */       vo_16383_0 = GameUtil.a16383(chara, msg, 9);
/* 63 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M16383_0(), vo_16383_0);
/* 64 */       Vo_53569_0 vo_53569_0 = new Vo_53569_0();
/* 65 */       vo_53569_0.gid = receive_gid;
/* 66 */       vo_53569_0.online = 1;
/* 67 */       GameObjectChar.getGameObjectChar();GameObjectChar.send(new M53569_0(), vo_53569_0);
/*    */     } else {
/* 69 */       Vo_53569_0 vo_53569_0 = new Vo_53569_0();
/* 70 */       vo_53569_0.gid = receive_gid;
/* 71 */       vo_53569_0.online = 0;
/* 72 */       GameObjectChar.getGameObjectChar();GameObjectChar.send(new M53569_0(), vo_53569_0);
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 79 */     return 20590;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C20590_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */