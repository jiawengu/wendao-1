package org.linlinjava.litemall.gameserver.process;

import com.alibaba.druid.sql.visitor.functions.Char;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.data.vo.HOUSE_DATA_VO;
import org.linlinjava.litemall.gameserver.data.vo.Vo_9129_0;
import org.linlinjava.litemall.gameserver.data.write.M8405;
import org.linlinjava.litemall.gameserver.data.write.MSG_GENERAL_NOTIFY;
import org.linlinjava.litemall.gameserver.data.write.MSG_HOUSE_DATA;
import org.linlinjava.litemall.gameserver.data.xls_config.DugenoCfg;
import org.linlinjava.litemall.gameserver.data.xls_config.DugenoItem;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.House;
import org.linlinjava.litemall.gameserver.game.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Service;

@Service
public class CMD_HOUSE_GO_HOME implements org.linlinjava.litemall.gameserver.GameHandler{

    @Override
    public void process(ChannelHandlerContext paramChannelHandlerContext, ByteBuf paramByteBuf) {
        Chara chara = GameObjectChar.getGameObjectChar().chara;
        String houseName = chara.house.getHouseName();
        String mapName = houseName + "-房屋";
        org.linlinjava.litemall.db.domain.Map map = GameData.that.baseMapService.findOneByName(mapName);
        chara.y = map.getY().intValue();
        chara.x = map.getX().intValue();
        GameZone gameZone = GameLine.createGameZone(15, map.getMapId());
        gameZone.isHouseZone = true;
        //通知换线
        GameObjectChar.send(new M8405(), GameObjectChar.getGameObjectChar().chara.name);
        gameZone.joinHouse(GameObjectCharMng.getGameObjectChar(chara.id));

        //通知House_Data
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
        return 20586;
    }
}