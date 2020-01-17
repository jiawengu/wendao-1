package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.db.domain.Pet;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing;
import org.linlinjava.litemall.gameserver.data.write.M61677_0;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.Goods;
import org.linlinjava.litemall.gameserver.domain.Petbeibao;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * 保存宠物
 */
@Service
public class CMD_OPERATE_PET_STORE implements GameHandler {

    public static class Vo_61677_1 {
        public String store_type = "choongwu";
        public int npcID = 0;
        public int count = 1;
        public int isGoon = 1;
        public Petbeibao chongwu;
        public int pos;
    }

    public static class M61677_1 extends BaseWrite {

        @Override
        protected void writeO(ByteBuf byteBuf, Object paramObject) {
            Vo_61677_1 vo = (Vo_61677_1)paramObject;

            GameWriteTool.writeString(byteBuf, vo.store_type);
            GameWriteTool.writeInt(byteBuf, vo.npcID);
            GameWriteTool.writeShort(byteBuf, vo.count);
            GameWriteTool.writeByte(byteBuf, vo.isGoon);
            GameWriteTool.writeShort(byteBuf, vo.pos);

            Map<Object, Object> map = UtilObjMapshuxing.Petbeibao(vo.chongwu);

        }

        @Override
        public int cmd() {
            return 61677;
        }
    }

    @Override
    public void process(ChannelHandlerContext paramChannelHandlerContext, ByteBuf paramByteBuf) {
        int type = GameReadTool.readByte(paramByteBuf);
        int pos = GameReadTool.readShort(paramByteBuf);
        int id = GameReadTool.readByte(paramByteBuf);

        Petbeibao chongwu = null;
        Chara chara = GameObjectChar.getGameObjectChar().chara;
        for(Petbeibao p:chara.pets){
            if(p.no == pos){
                chongwu = p;
            }
        }
        if(chongwu != null){
            Vo_61677_1 vo_61677_1 = new Vo_61677_1();
            vo_61677_1.pos = GameUtil.cangkuweizhi(chara);
            vo_61677_1.store_type = "chongwu";
            vo_61677_1.chongwu = chongwu;
            GameObjectChar.send(new M61677_1(), vo_61677_1);
        }
    }

    @Override
    public int cmd() {
        return 32794;
    }
}


