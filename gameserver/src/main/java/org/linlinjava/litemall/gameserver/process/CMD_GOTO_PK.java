package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.db.domain.Characters;
import org.linlinjava.litemall.db.domain.Map;
import org.linlinjava.litemall.db.util.JSONUtils;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_DIALOG_OK;
import org.linlinjava.litemall.gameserver.data.write.MSG_TASK_PROMPT;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.springframework.stereotype.Service;

@Service
public class CMD_GOTO_PK implements GameHandler {
    private void sendErr(String err){
        Vo_8165_0 vo_8165_0 = new Vo_8165_0();
        vo_8165_0.msg = err;
        vo_8165_0.active = 0;
        GameObjectChar.send(new MSG_DIALOG_OK(), vo_8165_0);
    }
    @Override
    public void process(ChannelHandlerContext paramChannelHandlerContext, ByteBuf paramByteBuf) {

        String para1 = GameReadTool.readString(paramByteBuf);
        System.out.println("CMD_GOTO_PK ,para1="+para1);
        if (para1.equals("")) return;
        Characters characters = GameData.that.characterService.finOnByGiD(para1);
        Chara chara1 = (Chara) JSONUtils.parseObject(characters.getData(), Chara.class);

        GameObjectChar gameObjectChar= GameObjectCharMng.getGameObjectChar(chara1.id);
        if(!gameObjectChar.isOnline()){
            this.sendErr("对方不在线！");
            return;
        }

        Map  tempMap = GameData.that.baseMapService.findOneByMapId(chara1.mapid);
        org.linlinjava.litemall.gameserver.data.vo.Vo_61553_0 vo_61553_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_61553_0();
        vo_61553_0.count = 1;
        vo_61553_0.task_type = "pk";
        vo_61553_0.task_desc = "在游戏中pk";
        vo_61553_0.task_prompt = ("#前往#Z" + tempMap.getName() + "|" + tempMap.getName() + "(" + tempMap.getX() + "," + tempMap.getY() + ")#Z pk");
        vo_61553_0.refresh = 1;
        vo_61553_0.task_end_time = 1567909190;
        vo_61553_0.attrib = 1;
        vo_61553_0.reward = "#I道行|道行#I#I潜能|潜能#I#I金钱|金钱#I#I物品|召唤令·十二生肖#I#I宠物|十二生肖=F#I";
        vo_61553_0.show_name = "pk";
        vo_61553_0.tasktask_extra_para = "";
        vo_61553_0.tasktask_state = "1";
        GameObjectChar.getGameObjectChar();GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_0);


        Vo_45063_0 vo_45063_0 = new Vo_45063_0();
        vo_45063_0.task_name = ("#前往#Z" + tempMap.getName() + "|" + tempMap.getName() + "(" + tempMap.getX() + "," + tempMap.getY() + ")#Zpk");
        vo_45063_0.check_point = 147761859;
        GameObjectChar.getGameObjectChar();GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M45063_0(), vo_45063_0);

    }

    @Override
    public int cmd() {
        return 0xB0AC;
    }
}
