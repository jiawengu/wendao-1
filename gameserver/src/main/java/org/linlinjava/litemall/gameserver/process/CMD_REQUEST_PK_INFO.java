package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.PKMgr;

@org.springframework.stereotype.Service
public class CMD_REQUEST_PK_INFO  implements GameHandler {
    @Override
    public void process(ChannelHandlerContext paramChannelHandlerContext, ByteBuf paramByteBuf) {
        String typeStr = GameReadTool.readString(paramByteBuf);
        String para1 = GameReadTool.readString(paramByteBuf);
        String para2 = GameReadTool.readString(paramByteBuf);

        System.out.println("CMD_REQUEST_PK_INFO typeStr="+typeStr+",para1="+para1+",para2="+para2);

        Chara chara = GameObjectChar.getGameObjectChar().chara;
        if (typeStr.equals("search_pk"))
        {
            PKMgr.getSearch(chara, para2, para1);
        }else {
            PKMgr.getRecordByType(chara, typeStr);
        }
    }

    @Override
    public int cmd() {
        return 0xB0AA;
    }
}
