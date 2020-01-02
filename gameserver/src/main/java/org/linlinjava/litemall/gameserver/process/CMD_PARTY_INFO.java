/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M65527_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M_MSG_PARTY_INFO;
import org.linlinjava.litemall.gameserver.data.write.M_MSG_PARTY_LIST_EX;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.domain.GameParty;
import org.linlinjava.litemall.gameserver.game.GameCore;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class CMD_PARTY_INFO implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
                int partyId = GameObjectChar.getGameObjectChar().chara.partyId;
                System.out.println("CMD_PARTY_INFO:" + partyId);
                if(partyId > 0){
                    GameParty party = GameCore.that.partyMgr.get(partyId);
                    GameObjectChar.send(new M_MSG_PARTY_INFO(), party);
                }
/*    */   }
/*    */   public int cmd()
/*    */   {
/* 26 */     return 0x00B2;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C178_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */