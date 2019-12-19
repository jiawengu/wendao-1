package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.springframework.stereotype.Service;

@Service
public class C32780 implements GameHandler {

    @Override
    public void process(ChannelHandlerContext paramChannelHandlerContext, ByteBuf paramByteBuf) {

        System.out.println("点击创建帮派");
        System.out.println("创建帮派");
    }

    @Override
    public int cmd() {
        return 32780;
    }
}
