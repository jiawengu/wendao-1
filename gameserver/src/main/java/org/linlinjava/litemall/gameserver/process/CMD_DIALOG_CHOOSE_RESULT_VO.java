package org.linlinjava.litemall.gameserver.process;

import lombok.Builder;
import lombok.Data;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;

@Data
@Builder
class CMD_DIALOG_CHOOSE_RESULT_VO {
    private int npcId;

    private String menuItem;

    private String para;

    private GameObjectChar gameObjectChar;

    public String toString() {
        return String.format("npcId: %d, menuItem: %s, para: %s", npcId, menuItem, para);
    }
}