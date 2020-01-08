package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.db.domain.NpcDialogue;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_45056_0;
import org.linlinjava.litemall.gameserver.data.write.M45056_0;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.springframework.stereotype.Service;

import static org.linlinjava.litemall.gameserver.game.GameData.that;

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
    org.linlinjava.litemall.gameserver.data.vo.Vo_45056_0 vo_45056_0 = GameUtil.a45056(chara);
    GameObjectChar.send(new M45056_0(), vo_45056_0);

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