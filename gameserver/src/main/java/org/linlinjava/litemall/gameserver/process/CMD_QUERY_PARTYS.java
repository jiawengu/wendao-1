package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_PARTY_LIST_EX;
import org.linlinjava.litemall.gameserver.data.write.M_MSG_PARTY_LIST_EX;
import org.linlinjava.litemall.gameserver.game.GameCore;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.PartyMgr;
import org.springframework.stereotype.Service;

@Service
public class CMD_QUERY_PARTYS implements GameHandler {
    @Override
    public void process(ChannelHandlerContext ctx, ByteBuf buf) {
        String type = GameReadTool.readString(buf);
        String para = GameReadTool.readString(buf);
        System.out.println(type + ":" + para);
        PartyMgr partyMgr = GameCore.that.partyMgr;
        Vo_MSG_PARTY_LIST_EX vo = new Vo_MSG_PARTY_LIST_EX();
        vo.parts = partyMgr.getAll();
        vo.type = type;
        GameObjectChar.send(new M_MSG_PARTY_LIST_EX(), vo);
    }

    @Override
    public int cmd() {
        return 0x800E;
    }
}
