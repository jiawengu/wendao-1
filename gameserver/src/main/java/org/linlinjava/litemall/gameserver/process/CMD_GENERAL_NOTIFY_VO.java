package org.linlinjava.litemall.gameserver.process;

import lombok.Builder;
import lombok.Data;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;

@Data
@Builder
class CMD_GENERAL_NOTIFY_VO {
    private int type;

    private String parameter1;

    private String parameter2;

    private GameObjectChar gameObjectChar;
}
