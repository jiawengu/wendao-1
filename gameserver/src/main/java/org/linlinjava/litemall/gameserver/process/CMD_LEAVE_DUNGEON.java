package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;

// 离开副本
@org.springframework.stereotype.Service
public class CMD_LEAVE_DUNGEON implements org.linlinjava.litemall.gameserver.GameHandler {
    @Override
    public void process(ChannelHandlerContext paramChannelHandlerContext, ByteBuf paramByteBuf) {
        Chara chara = GameObjectChar.getGameObjectChar().chara;
        GameUtilRenWu.huicheng(chara);
    }

    @Override
    public int cmd() {
        return 24578;
    }
}
