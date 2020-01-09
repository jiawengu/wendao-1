package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.springframework.stereotype.Service;

@Service
public class CMD_GET_PARTY_CHANNEL_DENY_LIST implements GameHandler {
    @Override
    public void process(ChannelHandlerContext ctx, ByteBuf buf) {

    }

    @Override
    public int cmd() {
        return 0x2E3C;
    }
}
