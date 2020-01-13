package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.vo.MSG_PLAY_SCENARIOD_VO;
import org.linlinjava.litemall.gameserver.data.write.MSG_PLAY_SCENARIOD;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.springframework.stereotype.Service;

@Service
public class C45057_0 implements GameHandler {
  public void process(ChannelHandlerContext ctx, ByteBuf buff) {
    int id = GameReadTool.readInt(buff);

    int type = GameReadTool.readShort(buff);

    String para = GameReadTool.readString(buff);

    GameObjectChar session = GameObjectChar.getGameObjectChar();

    System.out.println(String.format("id:%s, type:%s, para:%s", id, type, para));

    Chara chara = GameObjectChar.getGameObjectChar().chara;

    if (chara.currentJuBens != null) {
        GameUtil.playNextNpcDialogueJuBen();
        return ;
    }
    //这里的ID代表最后一个剧本的ID
    MSG_PLAY_SCENARIOD_VO MSGPLAYSCENARIODVO = GameUtil.a45056(chara);
    GameObjectChar.send(new MSG_PLAY_SCENARIOD(), MSGPLAYSCENARIODVO);

  }

  public int cmd() {
    return 45057;
  }
}

/*
 * Location:
 * C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\
 * gameserver\process\C45057_0.class Java compiler version: 8 (52.0) JD-Core
 * Version: 0.7.1
 */