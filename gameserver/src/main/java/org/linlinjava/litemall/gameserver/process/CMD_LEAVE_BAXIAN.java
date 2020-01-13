package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.springframework.stereotype.Component;

@Component
public class CMD_LEAVE_BAXIAN implements GameHandler {

    public void process(ChannelHandlerContext ctx, ByteBuf buff) {
    }

    public int cmd() {
        return 0x6000;
    }
}
