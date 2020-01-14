package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.vo.MSG_PLAY_SCENARIOD_VO;
import org.linlinjava.litemall.gameserver.data.write.MSG_PLAY_SCENARIOD;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.springframework.stereotype.Service;

@Service
public class CMD_OPER_SCENARIOD implements GameHandler {
  public void process(ChannelHandlerContext ctx, ByteBuf buff) {
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
    return 0xb001;
  }
}
