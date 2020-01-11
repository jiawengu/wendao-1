package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;

import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_4275_0;
import org.linlinjava.litemall.gameserver.data.write.M4275_0;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.springframework.stereotype.Service;

@Service
public class CMD_HEART_BEAT implements GameHandler {

    public void process(ChannelHandlerContext ctx, ByteBuf buff) {
        int peer_time = GameReadTool.readInt(buff);
        Vo_4275_0 vo_4275_0 = new Vo_4275_0();
        vo_4275_0.a = (peer_time + 10000 + org.linlinjava.litemall.gameserver.fight.FightManager.RANDOM.nextInt(500));

        GameObjectChar session = GameObjectChar.getGameObjectChar();

        long time = System.currentTimeMillis();
        if (time - session.heartEcho < 3000L) {
            ctx.disconnect();
        }
        session.heartEcho = System.currentTimeMillis();

        ByteBuf write = new M4275_0().write(vo_4275_0);
        ctx.writeAndFlush(write);
    }

    public int cmd() {
        return 4274;
    }
}
