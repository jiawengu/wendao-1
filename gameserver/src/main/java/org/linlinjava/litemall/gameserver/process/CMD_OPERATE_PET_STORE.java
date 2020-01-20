package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.db.domain.Pet;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing;
import org.linlinjava.litemall.gameserver.data.vo.*;
import org.linlinjava.litemall.gameserver.data.write.M61677_0;
import org.linlinjava.litemall.gameserver.data.write.M61677_1;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_PETS;
import org.linlinjava.litemall.gameserver.domain.*;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * 保存宠物
 */
@Service
public class CMD_OPERATE_PET_STORE implements GameHandler {

    @Override
    public void process(ChannelHandlerContext paramChannelHandlerContext, ByteBuf paramByteBuf) {
        int type = GameReadTool.readByte(paramByteBuf);
        int pos = GameReadTool.readShort(paramByteBuf);
        int id = GameReadTool.readByte(paramByteBuf);

        Petbeibao chongwu = null;
        Chara chara = GameObjectChar.getGameObjectChar().chara;
        if(type == 1){
            for(Petbeibao p:chara.pets){
                if(p.no == pos){
                    chongwu = p;
                }
            }
            if(chongwu != null){
                chara.pets.remove(chongwu);
                chara.chongwucangku.add(chongwu);
                chongwu.no = GameUtil.getChongwuCangkuNextWeizhi(chara);
            }
        }
        else if(type == 2){
            for(Petbeibao p:chara.chongwucangku){
                if(p.no == pos){
                    chongwu = p;
                }
            }
            if(chongwu != null){
                chara.chongwucangku.remove(chongwu);
                chara.pets.add(chongwu);
                chongwu.no = GameUtil.getNo(chara, 1);
            }
        }

        Vo_61677_1 vo_61677_1 = new Vo_61677_1();
        vo_61677_1.store_type = "chongwu";
        vo_61677_1.list = chara.chongwucangku;
        GameObjectChar.send(new M61677_1(), vo_61677_1);
        GameObjectChar.send(new MSG_UPDATE_PETS(), chara.pets);
    }

    @Override
    public int cmd() {
        return 32794;
    }

}


