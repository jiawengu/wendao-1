package org.linlinjava.litemall.gameserver.service;

import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

/**
 */
@Service
public class DBService {
    @Async
    public void save(GameObjectChar gameObjectChar) {
        GameObjectCharMng.save(gameObjectChar);
    }
}
