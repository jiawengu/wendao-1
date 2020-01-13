package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.service.HeroPubService;
import org.linlinjava.litemall.gameserver.service.ZhengDaoDianService;
import org.springframework.stereotype.Service;

/**
 * 修改英雄会留言
 */
@Service
public class CMD_HERO_SET_SIGNATURE implements GameHandler {
    public void process(ChannelHandlerContext ctx, ByteBuf buff) {
        int id = GameReadTool.readInt(buff);
        String msg = GameReadTool.readString(buff);
        HeroPubService.changeNotice(id, msg);
    }

    public int cmd() {
        return 20690;
    }
}
