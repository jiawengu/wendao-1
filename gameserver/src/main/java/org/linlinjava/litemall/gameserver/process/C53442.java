package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_4275_0;
import org.linlinjava.litemall.gameserver.data.write.M53443;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.linlinjava.litemall.gameserver.data.write.M53363_0;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;


@Service
public class C53442 implements GameHandler {

    public void process(ChannelHandlerContext ctx, ByteBuf buff)
    {
        System.out.println(buff.toString());
        String para1 = GameReadTool.readString(buff);  //爪子
        String para2 = GameReadTool.readString(buff);
        String para3 = GameReadTool.readString(buff);
        String para4 = GameReadTool.readString(buff);
        String para5 = GameReadTool.readString(buff);
        String para6 = GameReadTool.readString(buff);
        String para7 = GameReadTool.readString(buff);
        String para8 = GameReadTool.readString(buff);
        String para9 = GameReadTool.readString(buff);

        Object vo_4275_0 = new Vo_4275_0();
        ByteBuf write = new M53443().write(vo_4275_0);
        ctx.writeAndFlush(write);
    }


    public int cmd() {
        return 53442;
    }
}