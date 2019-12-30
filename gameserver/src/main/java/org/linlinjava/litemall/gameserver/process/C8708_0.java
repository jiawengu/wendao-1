package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;

import java.util.concurrent.atomic.AtomicInteger;

import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.fight.FightContainer;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * CMD_C_END_ANIMATE    结束动画
 */
@org.springframework.stereotype.Service
public class C8708_0 implements org.linlinjava.litemall.gameserver.GameHandler {
    static boolean b = true;
    private static final Logger log = LoggerFactory.getLogger(C8708_0.class);

    public void process(ChannelHandlerContext ctx, ByteBuf buff) {
        int answer = GameReadTool.readInt(buff);
        int id = GameObjectChar.getGameObjectChar().chara.id;
        FightContainer fightContainer = FightManager.getFightContainer();
        if (fightContainer == null) {
            return;
        }
        if ((fightContainer.state.compareAndSet(3, 1)) || (fightContainer.state.get() == 4)) {
            FightManager.nextRoundOrSendOver(FightManager.getFightContainer());
        }
    }

    public int cmd() {
        return 8708;
    }
}
