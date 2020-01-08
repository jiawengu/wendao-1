/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_PARTY_MEMBERS;
import org.linlinjava.litemall.gameserver.data.write.M_MSG_PARTY_INFO;
import org.linlinjava.litemall.gameserver.data.write.M_MSG_PARTY_MEMBERS;
import org.linlinjava.litemall.gameserver.domain.GameParty;
import org.linlinjava.litemall.gameserver.game.GameCore;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.springframework.stereotype.Service;

/*    */
/*    */
/*    */
/*    */
/*    */
/*    */
/*    */
/*    */ 
/*    */ @Service
/*    */ public class CMD_PARTY_INFO implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
                int partyId = GameObjectChar.getGameObjectChar().chara.partyId;
                if(partyId > 0){
                    GameParty party = GameCore.that.partyMgr.get(partyId);
                    GameObjectChar.send(new M_MSG_PARTY_INFO(), party);

                    Vo_MSG_PARTY_MEMBERS vo = new Vo_MSG_PARTY_MEMBERS();
                    vo.members = party.listMembers();
                    vo.page = 1;
                    GameObjectChar.send(new M_MSG_PARTY_MEMBERS(party), vo);
                }
/*    */   }
/*    */   public int cmd()
/*    */   {
/* 26 */     return 0x00B2;
/*    */   }
/*    */ }
