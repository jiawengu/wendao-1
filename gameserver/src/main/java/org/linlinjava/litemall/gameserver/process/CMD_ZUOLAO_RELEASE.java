package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_RELEASE_SUCC;
import org.linlinjava.litemall.gameserver.data.write.MSG_DIALOG_OK;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
import org.linlinjava.litemall.gameserver.data.write.M_MSG_RELEASE_SUCC;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.PKMgr;

@org.springframework.stereotype.Service
public class CMD_ZUOLAO_RELEASE implements GameHandler {
    private void sendErr(String err){
        Vo_8165_0 vo_8165_0 = new Vo_8165_0();
        vo_8165_0.msg = err;
        vo_8165_0.active = 0;
        GameObjectChar.send(new MSG_DIALOG_OK(), vo_8165_0);
    }

    @Override
    public void process(ChannelHandlerContext paramChannelHandlerContext, ByteBuf paramByteBuf) {

        String gid = GameReadTool.readString(paramByteBuf);
        String name = GameReadTool.readString(paramByteBuf);

        System.out.println("CMD_ZUOLAO_RELEASE ,gid="+gid+",para2="+name);

        Chara chara = GameObjectChar.getGameObjectChar().chara;

        if(chara.balance < 1){
            this.sendErr("金币不足！");
            return;
        }

        if(!PKMgr.onZuoLaoRelease(chara, gid, name)){
            this.sendErr("保释失败！");
            return;
        }

        chara.balance -= 1;
        ListVo_65527_0 vo_65527_0 = GameUtil.MSG_UPDATE(chara);
        GameObjectChar.send(new MSG_UPDATE(), vo_65527_0);

        Vo_MSG_RELEASE_SUCC vo = new Vo_MSG_RELEASE_SUCC();
        vo.gid = gid;
        GameObjectChar.send(new M_MSG_RELEASE_SUCC(), vo);
    }

    @Override
    public int cmd() {
        return 0xB0AF;
    }
}
