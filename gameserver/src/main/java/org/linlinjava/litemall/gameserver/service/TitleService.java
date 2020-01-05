package org.linlinjava.litemall.gameserver.service;

import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
import org.linlinjava.litemall.gameserver.data.write.M20481_0;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.springframework.stereotype.Service;

@Service
public class TitleService {

    public static void grantTitle(Chara chara, String event, String title) {
        chara.chenghao.put(event, title);
        GameUtil.chenghaoxiaoxi(chara);
        Vo_20481_0 vo_20481_9 = new Vo_20481_0();
        vo_20481_9.msg = String.format("你获得了#R%s#n的称谓。", title);
        vo_20481_9.time = (int)(System.currentTimeMillis() / 1000);
        GameObjectChar.send(new M20481_0(), vo_20481_9);
    }

    public static void grantTitle(int uid, String event, String title) {
        GameObjectChar gameObjectChar = GameObjectCharMng.getGameObjectChar(uid);
        grantTitle(gameObjectChar.chara, event, title);
    }
}
