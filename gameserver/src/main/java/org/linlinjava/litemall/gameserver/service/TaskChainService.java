package org.linlinjava.litemall.gameserver.service;

import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.db.task.TaskChainRepository;
import org.linlinjava.litemall.db.task.TaskVO;
import org.linlinjava.litemall.gameserver.data.vo.Vo_45157_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_65505_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
import org.linlinjava.litemall.gameserver.data.write.*;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameMap;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Iterator;
import java.util.List;

@Service
public class TaskChainService {
    @Autowired
    private TaskChainRepository taskChainRepository;

    @Autowired
    private GameMap gameMap;

    public void setPlayerTask(GameObjectChar gameObjectChar, Integer chainId, Integer taskId) {
        Chara chara = gameObjectChar.chara;
        TaskVO taskVO = taskChainRepository.getNextTask(chainId, taskId);
        if (chara.mapid != taskVO.getMapId()) {
            chara.mapid = taskVO.getMapId();
            chara.mapName = taskVO.getMapName();
            chara.x = taskVO.getNpcX();
            chara.y = taskVO.getNpcY();


            List<Npc> npcList = GameData.that.baseNpcService.findByMapId(taskVO.getMapId());
            Vo_45157_0 vo_45157_0 = new Vo_45157_0();
            vo_45157_0.id = chara.id;
            vo_45157_0.mapId = chara.mapid;
            gameObjectChar.sendOne(new M45157_0(), vo_45157_0);
            Vo_65505_0 vo_65505_1 = GameUtil.a65505(chara);
            gameObjectChar.sendOne(new M65505_0(), vo_65505_1);
            Iterator var6 = npcList.iterator();

            while(var6.hasNext()) {
                Npc npc = (Npc)var6.next();
                gameObjectChar.sendOne(new M65529_npc(), npc);
            }

            Vo_65529_0 vo_65529_0 = GameUtil.a65529(chara);
            GameUtil.genchongfei(chara);
            gameObjectChar.sendOne(new M65529_0(), vo_65529_0);
            Vo_61671_0 vo_61671_0 = new Vo_61671_0();
            vo_61671_0.id = chara.mapid;
            vo_61671_0.count = 0;
            gameObjectChar.sendOne(new M61671_0(), vo_61671_0);
        }
    }
}
