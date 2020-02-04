package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.vo.HOUSE_DATA_VO;
import org.linlinjava.litemall.gameserver.data.write.MSG_HOUSE_DATA;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.House;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.springframework.stereotype.Service;

@Service
public class CMD_REQUEST_HOUSE_DATA implements GameHandler {
    @Override
    public void process(ChannelHandlerContext paramChannelHandlerContext, ByteBuf paramByteBuf) {
        Chara chara = GameObjectChar.getGameObjectChar().chara;
        String dlg = GameReadTool.readString(paramByteBuf);
        House house = chara.house;
        HOUSE_DATA_VO houseDataVo = new HOUSE_DATA_VO();
        if(house.getHouseType() == 0){
            house.setHouseType(1);
        }
        houseDataVo.setHouseType(house.getHouseType());
        houseDataVo.setHouseId("aaaaaaaaaaa");
        houseDataVo.setStoreType(house.getStoreLevel());
        GameObjectChar.send(new MSG_HOUSE_DATA(), houseDataVo);
    }

    @Override
    public int cmd() {
        return 20596;
    }
}
