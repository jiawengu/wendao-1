package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.vo.*;
import org.linlinjava.litemall.gameserver.data.write.*;
import org.linlinjava.litemall.gameserver.domain.*;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.springframework.stereotype.Service;

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
                chongwu.no = GameUtil.getChongwuCangkuNextWeizhi(chara);
                chara.chongwucangku.add(chongwu);

                Vo_61677_1 vo_61677_1 = new Vo_61677_1();
                vo_61677_1.store_type = "chongwu";
                vo_61677_1.list = chara.chongwucangku;
                GameObjectChar.send(new M61677_1(), vo_61677_1);

                //删除宠物背包的前端数据
                Vo_12269_0 vo_12269_0 = new Vo_12269_0();
                vo_12269_0.id = chongwu.id;
                vo_12269_0.owner_id = 96780;
                GameObjectChar.send(new MSG_SET_OWNER(), vo_12269_0);
            }
        }
        else if(type == 2){
            for(Petbeibao p:chara.chongwucangku){
                if(p.no == pos){
                    chongwu = p;
                }
            }
            if(chongwu != null){
                //删除宠物仓库的前端数据
                GameObjectChar.send(new M61677_1(), pos);
                chara.chongwucangku.remove(chongwu);
                chongwu.no = GameUtil.getNo(chara, 1);
                chara.pets.add(chongwu);
                GameObjectChar.send(new MSG_UPDATE_PETS(), chara.pets);
            }
        }


    }

    @Override
    public int cmd() {
        return 32794;
    }

}


