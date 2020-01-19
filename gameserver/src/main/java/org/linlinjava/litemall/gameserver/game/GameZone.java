package org.linlinjava.litemall.gameserver.game;

import org.linlinjava.litemall.gameserver.data.xls_config.DugenoItem;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.process.GameUtilRenWu;

public class GameZone extends GameMap {
    // 场景id
    public String uid = "";
    // 场景销毁时间
    private long endTime = -1;
    // 副本逻辑对象
    public GameDugeon gameDugeon = null;

    public GameZone() {
        super();
        super.map_type = 1;
    }

    @Override
    public void joinduiyuan(GameObjectChar gameObjectChar, Chara charaduizhang) {
        super.joinduiyuan(gameObjectChar, charaduizhang);

        if(gameDugeon != null) {
            gameDugeon.onJoinMap(gameObjectChar.chara);
        }
    }

    @Override
    public void leave(GameObjectChar gameObjectChar) {
        if(gameDugeon != null) {
            DugenoItem cfg = gameDugeon.getDugenoItemCfg();
            GameUtilRenWu.renwukuangkuang(cfg.task_type, "", "", gameObjectChar.chara);
        }

        super.leave(gameObjectChar);
        if(!super.sessionList.isEmpty())
        {
            return;
        }

        GameLine.deleteZoneGameMap(gameObjectChar.chara.line, this.uid);
    }

    public GameDugeon initGameDugeon(String dugeon_name){
        gameDugeon = new GameDugeon();
        gameDugeon.name = dugeon_name;
        super.map_type = 2;
        return  gameDugeon;
    }

    // 设置生命周期单位s todo
    public void setLifeTime(int lifeTime)
    {
        this.endTime = lifeTime + System.currentTimeMillis();
    }
}
