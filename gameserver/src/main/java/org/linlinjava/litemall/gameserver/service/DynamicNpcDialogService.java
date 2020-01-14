package org.linlinjava.litemall.gameserver.service;

import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.gameserver.data.vo.MSG_MENU_LIST_VO;
import org.linlinjava.litemall.gameserver.data.write.MSG_MENU_LIST;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.springframework.stereotype.Service;

@Service
public class DynamicNpcDialogService {
    public MSG_MENU_LIST_VO getDynamicNpcDialog(GameObjectChar gameObjectChar, int npcId) {
        return null;
    }

    /**
     * 弹出 NPC 操作对话框
     * @param npc Npc
     * @param content 对话内容
     */
    public static void sendNpcDlg(Npc npc, String content){
        MSG_MENU_LIST_VO menu_list_vo = new MSG_MENU_LIST_VO();
        menu_list_vo.id = npc.getId();
        menu_list_vo.portrait = npc.getIcon();
        menu_list_vo.pic_no = 1;
        menu_list_vo.content = content;
        menu_list_vo.secret_key = "";
        menu_list_vo.name = npc.getName();
        menu_list_vo.attrib = 0;
        GameObjectChar.send(new MSG_MENU_LIST(), menu_list_vo);
    }
}
