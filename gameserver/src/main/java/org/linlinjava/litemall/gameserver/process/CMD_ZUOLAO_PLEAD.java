package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_DIALOG_OK;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;

@org.springframework.stereotype.Service
public class CMD_ZUOLAO_PLEAD implements GameHandler {
    @Override
    public void process(ChannelHandlerContext paramChannelHandlerContext, ByteBuf paramByteBuf) {

        String gid = GameReadTool.readString(paramByteBuf);
        String name = GameReadTool.readString(paramByteBuf);

        System.out.println("CMD_ZUOLAO_PLEAD ,gid="+gid+",para2="+name);

        Chara chara = GameObjectChar.getGameObjectChar().chara;

        Vo_8165_0 vo_8165_0 = new Vo_8165_0();
        vo_8165_0.msg = "暂未开放";
        vo_8165_0.active = 0;
        GameObjectChar.send(new MSG_DIALOG_OK(), vo_8165_0);
    }

    @Override
    public int cmd() {
        return 0xB0AE;
    }
}
