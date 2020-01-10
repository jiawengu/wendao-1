package org.linlinjava.litemall.gameserver.service;

import org.linlinjava.litemall.db.service.CharacterService;
import org.linlinjava.litemall.db.util.RedisUtils;
import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class TitleService {
    private static final Logger logger = LoggerFactory.getLogger(TitleService.class);

    @Autowired
    private RedisUtils redisUtils;

    @Autowired
    private CharacterService characterService;

    /**
     * 授予玩家称谓
     * @param gameObjectChar GameObjectChar
     * @param event 称谓来源
     * @param title 称谓内容
     */
    public static void grantTitle(GameObjectChar gameObjectChar, String event, String title) {
        if (gameObjectChar.chara.chenghao.containsKey(event)) {
            return;
        }
        gameObjectChar.chara.chenghao.put(event, title);
        GameObjectCharMng.save(gameObjectChar);
        GameUtil.chenghaoxiaoxi(gameObjectChar.chara);
        Vo_20481_0 vo_20481_9 = new Vo_20481_0();
        vo_20481_9.msg = String.format("你获得了#R%s#n的称谓。", title);
        vo_20481_9.time = (int)(System.currentTimeMillis() / 1000);
        GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_9);
    }

    private String generateRedisKey(String event, String title) {
        return String.format("%s,%s", event, title);
    }

    /**
     * 获取称谓当前的拥有者
     * @param event 称谓来源
     * @param title 称谓内容
     * @return 称谓当前的拥有者的uid，如果没有人则返回null
     */
    private Integer getCurrentUidOfTitle(String event, String title) {
        return Integer.valueOf(redisUtils.get(this.generateRedisKey(event, title)));
    }

    /**
     * 设置可被抢夺的称谓的信息
     * @param uid uid
     * @param event 称谓来源
     * @param title 称谓内容
     */
    private void setRobableTitle(int uid, String event, String title) {
        try {
            redisUtils.set(generateRedisKey(event, title), uid, -1);
        } catch (Exception e) {
            logger.error(String.format("Fail to setRobableTitle %d %s %s", uid, event, title), e);
        }
    }

    /**
     * 抢夺当前称谓
     * @param gameObjectChar GameObjectChar
     * @param event 称谓来源
     * @param title 称谓内容
     */
    public void robTitle(GameObjectChar gameObjectChar, String event, String title) {
        Integer currentUid = getCurrentUidOfTitle(event, title);
        reclaimUserTitle(currentUid, event);
        grantTitle(gameObjectChar, event, title);
        setRobableTitle(gameObjectChar.chara.id, event, title);
    }

    /**
     * 撤销用户称谓
     * @param uid uid
     * @param event 称谓来源
     */
    private void reclaimUserTitle(Integer uid, String event) {
        if (uid == null) {
            return;
        }
        GameObjectChar gameObjectChar = GameObjectCharMng.getGameObjectChar(uid);
        Chara chara = gameObjectChar.chara;
        chara.chenghao.remove(event);
        GameObjectCharMng.save(gameObjectChar);
    }
    /**
     * 撤销用户称谓
     * @param uid uid
     * @param event 称谓来源
     */
    public static void removeUserTitle(Integer uid, String event) {
        if (uid == null) {
            return;
        }
        GameObjectChar gameObjectChar = GameObjectCharMng.getGameObjectChar(uid);
        Chara chara = gameObjectChar.chara;
        chara.chenghao.remove(event);
        GameObjectCharMng.save(gameObjectChar);
    }
}
