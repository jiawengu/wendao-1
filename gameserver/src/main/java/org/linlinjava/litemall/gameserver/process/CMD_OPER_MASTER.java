package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_41009_0;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.service.ChallengeLeaderService;
import org.springframework.stereotype.Service;

/**
 * 修改掌门留言
 */
public class CMD_OPER_MASTER implements GameHandler {
    public void process(ChannelHandlerContext ctx, ByteBuf buff) {
        int id = GameReadTool.readInt(buff);
        int param = GameReadTool.readInt(buff);
        String msg = GameReadTool.readString(buff);
        if(param==2){//修改掌门留言
            ChallengeLeaderService.changeMsg(id, msg);
        }
    }

    public int cmd() {
        return 41008;
    }
}
