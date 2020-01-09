package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.vo.*;
import org.linlinjava.litemall.gameserver.data.write.M_MSG_DIALOG;
import org.linlinjava.litemall.gameserver.data.write.M_MSG_REQUEST_LIST;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.GameParty;
import org.linlinjava.litemall.gameserver.domain.PartyRequest;
import org.linlinjava.litemall.gameserver.game.GameCore;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class CMD_PARTY_REQUEST_LIST implements GameHandler {
    @Override
    public void process(ChannelHandlerContext ctx, ByteBuf buf) {
        Chara chara = GameObjectChar.getGameObjectChar().chara;
        if(chara.partyId == 0){ return; }
        GameParty party = GameCore.that.partyMgr.get(chara.partyId);
        if(party == null){ return; }
        List<PartyRequest> list = party.getRequestList();
        Vo_MSG_DIALOG vo = new Vo_MSG_DIALOG();
        vo.ask_type = "party";
        vo.list = new ArrayList<>();
        list.forEach(req->{
            Vo_MSG_DIALOG_item item = new Vo_MSG_DIALOG_item();
            item.bf_list.add(Vo_BuildField.stringc(1, "xx")); //name
            item.bf_list.add(Vo_BuildField.int32(31, 1)); //level
            item.bf_list.add(Vo_BuildField.int32(44, 1)); //polar
            item.bf_list.add(Vo_BuildField.int32(20, 1)); //tao
            item.bf_list.add(Vo_BuildField.int32(29, 1)); //gender
            vo.list.add(item);
        });
        GameObjectChar.send(new M_MSG_DIALOG(), vo);
    }

    @Override
    public int cmd() {
        return 0x10B0;
    }

}
