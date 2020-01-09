package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_PARTY_MEMBERS;
import org.linlinjava.litemall.gameserver.data.write.M_MSG_PARTY_MEMBERS;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.GameParty;
import org.linlinjava.litemall.gameserver.domain.PartyMember;
import org.linlinjava.litemall.gameserver.game.GameCore;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.springframework.stereotype.Service;

@Service
public class CMD_PARTY_MEMBERS implements GameHandler {
    @Override
    public void process(ChannelHandlerContext ctx, ByteBuf buf) {
        int page = GameReadTool.readShort(buf);
        String charaName = GameReadTool.readString(buf);
        String partyIdStr = GameReadTool.readString(buf);
        int partyId = 0;

        Chara chara = GameObjectChar.getGameObjectChar().chara;
        GameParty party = null;
        if(page > 0){
            if(chara.partyId > 0){
                partyId = chara.partyId;
            }
        }else{
            if(partyIdStr != "") {
                partyId = Integer.valueOf(partyIdStr);;
            }
        }

        if(partyId > 0){
            party = GameCore.that.partyMgr.get(chara.partyId);;
        }
        if(party == null){ return; }
        if(page > 0){
            Vo_MSG_PARTY_MEMBERS vo = new Vo_MSG_PARTY_MEMBERS();
            vo.members = party.listMembers();
            GameObjectChar.send(new M_MSG_PARTY_MEMBERS(party), vo);
        }else{
            if(charaName != ""){
                PartyMember m = party.getMemberByName(charaName);
                if(m == null){ return; }
            }
        }
    }

    @Override
    public int cmd() {
        return 0x20B8;
    }
}
