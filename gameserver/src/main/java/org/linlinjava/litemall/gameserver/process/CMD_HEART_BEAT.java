package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;

import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.vo.BAXIAN_LEFT_TIME_VO;
import org.linlinjava.litemall.gameserver.data.vo.Vo_4275_0;
import org.linlinjava.litemall.gameserver.data.write.M4275_0;
import org.linlinjava.litemall.gameserver.data.write.M_MSG_BAXIAN_LEFT_TIMES;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class CMD_HEART_BEAT implements GameHandler {
    @Autowired
    private M_MSG_BAXIAN_LEFT_TIMES m_msg_baxian_left_times;

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

        BAXIAN_LEFT_TIME_VO baxian_left_time_vo = new BAXIAN_LEFT_TIME_VO();
        baxian_left_time_vo.left_time = 7;
        GameObjectChar.send(m_msg_baxian_left_times, baxian_left_time_vo);
    }

    public int cmd() {
        return 4274;
    }
}
