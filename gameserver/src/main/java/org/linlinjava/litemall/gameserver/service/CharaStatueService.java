package org.linlinjava.litemall.gameserver.service;

import org.linlinjava.litemall.db.domain.Chara_Statue;
import org.linlinjava.litemall.db.util.JSONUtils;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.CharaStatue;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * 人物雕像管理器
 */
@Service
public class CharaStatueService {
    private static final Logger log = LoggerFactory.getLogger(FightManager.class);

    private static String serverId;
    /**
     * key:npc名字
     */
    private static final Map<String, CharaStatue> cacheMap = new HashMap<>();

    public static final void init(String serverId){
        CharaStatueService.serverId = serverId;
        for(Chara_Statue chara_statue:GameData.that.baseCharaStatueService.findAll(serverId)){
            cacheMap.put(chara_statue.getNpcName(), JSONUtils.parseObject(chara_statue.getData(), CharaStatue.class));
        }
    }

    /**
     * 保存人物雕像
     * @param npcName
     */
    public static void saveCharaStature(Chara chara, String npcName, CharaStatue charaStatue){
        cacheMap.put(npcName, charaStatue);//放缓存

        Chara_Statue chara_statue = GameData.that.baseCharaStatueService.findByName(serverId, npcName);
        if(null == chara_statue){
            chara_statue = new Chara_Statue();
            chara_statue.setNpcName(npcName);
            chara_statue.setServerid(serverId);
            chara_statue.setData(JSONUtils.toJSONString(charaStatue));
            GameData.that.baseCharaStatueService.insert(chara_statue);
            log.info("插入一条新雕像！"+npcName+",玩家："+chara.name);
        }else{
            chara_statue.setData(JSONUtils.toJSONString(charaStatue));
            GameData.that.baseCharaStatueService.updateById(chara_statue);
            log.info("更新一条新雕像！"+npcName+",玩家："+chara.name);
        }
    }

    public static CharaStatue getCharStaure(String npcName){
        return cacheMap.get(npcName);
    }

}
