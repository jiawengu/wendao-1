package org.linlinjava.litemall.gameserver.game;

import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.db.domain.NpcDialogueFrame;
import org.linlinjava.litemall.db.domain.RenwuMonster;
import org.linlinjava.litemall.db.domain.T_FightObject;
import org.linlinjava.litemall.gameserver.data.vo.MSG_MENU_LIST_VO;
import org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_APPEAR;
import org.linlinjava.litemall.gameserver.data.write.MSG_DISAPPEAR_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_MENU_CLOSED;
import org.linlinjava.litemall.gameserver.data.write.MSG_MENU_LIST;
import org.linlinjava.litemall.gameserver.data.xls_config.DugenoCfg;
import org.linlinjava.litemall.gameserver.data.xls_config.DugenoItem;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.linlinjava.litemall.gameserver.process.GameUtilRenWu;

import java.util.LinkedList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

// 通用副本
public class GameHouse {
    public String name = "";
}
