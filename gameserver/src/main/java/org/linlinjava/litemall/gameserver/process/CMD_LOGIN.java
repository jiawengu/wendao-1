/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import io.netty.util.Attribute;
/*    */
import org.linlinjava.litemall.db.domain.Accounts;
/*    */ import org.linlinjava.litemall.db.domain.Characters;
/*    */
/*    */
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.ListVo_61537_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M61537_0;
/*    */ import org.linlinjava.litemall.gameserver.game.GameData;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.linlinjava.litemall.gameserver.netty.ServerHandler;
/*    */ import org.slf4j.Logger;
/*    */ import org.slf4j.LoggerFactory;
/*    */ import org.springframework.stereotype.Service;
/*    */

/**
 * CMD_LOGIN
 */
/*    */ @Service
/*    */ public class CMD_LOGIN implements GameHandler
/*    */ {
/* 25 */   private static final Logger logger = LoggerFactory.getLogger(CMD_LOGIN.class);
/*    */   
/*    */ 
/*    */ 
/*    */ 
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {


/* 32 */     String account = GameReadTool.readString(buff);
           /* JSONObject jo = new JSONObject(account);
            String o = (String) jo.get("account");*/
            String user = account.substring(6);
/* 34 */     int auth_key = GameReadTool.readInt(buff);
/*    */     
/* 36 */     int seed = GameReadTool.readInt(buff);
/*    */     
/* 38 */     int emulator = GameReadTool.readByte(buff);
/*    */     
/* 40 */     int sight_scope = GameReadTool.readByte(buff);
/*    */     
/* 42 */     String version = GameReadTool.readString(buff);
/*    */     
/* 44 */     String clientid = GameReadTool.readString(buff);
/*    */     
/* 46 */     int netStatus = GameReadTool.readShort(buff);
/*    */     
/* 48 */     int adult = GameReadTool.readByte(buff);
/*    */     
/* 50 */     String signature = GameReadTool.readString(buff);
/*    */
/* 52 */     String clientname = GameReadTool.readString(buff);
/*    */
/* 54 */     int redfinger = GameReadTool.readByte(buff);
/*    */     
/* 57 */     Accounts accounts = GameData.that.baseAccountsService.findOneByToken(user);
/* 58 */     java.util.List<Characters> charactersList = GameData.that.characterService.findByAccountId(accounts.getId());
/* 59 */     ListVo_61537_0 listvo_61537_0 = CMD_CREATE_NEW_CHAR.listjiaose(charactersList);
/*    */
/*    */ 
/* 62 */     ByteBuf write = new M61537_0().write(listvo_61537_0);
/* 63 */     ctx.writeAndFlush(write);
/*    */     
/*    */ 
/* 66 */     GameObjectChar gameSession = new GameObjectChar(accounts.getId().intValue(), ctx);
/* 67 */     Attribute<GameObjectChar> attr = ctx.channel().attr(ServerHandler.akey);
/* 68 */     attr.set(gameSession);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 73 */     return 12290;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\CMD_LOGIN.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */