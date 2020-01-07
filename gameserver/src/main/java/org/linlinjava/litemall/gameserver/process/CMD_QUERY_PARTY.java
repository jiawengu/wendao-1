package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.write.M_MSG_PARTY_INFO;
import org.linlinjava.litemall.gameserver.domain.GameParty;
import org.linlinjava.litemall.gameserver.game.GameCore;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.PartyMgr;
import org.springframework.stereotype.Service;

@Service
public class CMD_QUERY_PARTY implements GameHandler {
    @Override
    public void process(ChannelHandlerContext ctx, ByteBuf buf) {
        String name = GameReadTool.readString(buf);
        String id = GameReadTool.readString(buf);
        String type = GameReadTool.readString(buf);
        int partyId = PartyMgr.parseStrId(id);
        System.out.print("CMD_QUERY_PARTY:" + name + ":" + partyId + ":" + type);

        GameParty party = GameCore.that.partyMgr.get(partyId);
        if(party == null){
            return;
        }
        GameObjectChar.send(new M_MSG_PARTY_INFO(), party);
    }

    @Override
    public int cmd() {
        return 0xA012;
    }
}
