package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.springframework.stereotype.Service;

/**
 * 开启七杀 提交血精
 */
@Service
public class CMD_SUBMIT_XUEJING_ITEM implements GameHandler {

    @Override
    public void process(ChannelHandlerContext paramChannelHandlerContext, ByteBuf paramByteBuf) {
        String data = GameReadTool.readString(paramByteBuf);
        System.out.println(String.format("CMD_SUBMIT_XUEJING_ITEM: %s", data));
    }

    @Override
    public int cmd() {
        return 20518;
    }
}
