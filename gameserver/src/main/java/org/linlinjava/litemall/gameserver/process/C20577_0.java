package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.apache.commons.lang3.StringUtils;
import org.linlinjava.litemall.db.domain.Accounts;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.Goods;
import org.linlinjava.litemall.gameserver.domain.House;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.util.HomeUtils;
import org.springframework.stereotype.Service;

@Service
public class C20577_0 implements GameHandler{

    @Override
    public void process(ChannelHandlerContext paramChannelHandlerContext, ByteBuf paramByteBuf) {
        String action = GameReadTool.readString(paramByteBuf);
        String houseName = GameReadTool.readString(paramByteBuf);
        int bedroomLevel = GameReadTool.readByte(paramByteBuf);
        int storeLevel = GameReadTool.readByte(paramByteBuf);
        int lianqsLevel = GameReadTool.readByte(paramByteBuf);
        int xiuliansLevel = GameReadTool.readByte(paramByteBuf);
        Chara chara = GameObjectChar.getGameObjectChar().chara;
        int coin = calcCoinByHouseName(houseName);
        if(StringUtils.equals(action, "upgrade") && StringUtils.isNotBlank(chara.house.getHouseName())){
            return;
        }

        if(StringUtils.equals(action, "modify") && StringUtils.isNotBlank(chara.house.getHouseName())){
            return;
        }

        if(StringUtils.equals(action, "goumai") && StringUtils.isBlank(chara.house.getHouseName())){
            chara.balance -= coin;
            House house = chara.house;
            house.setHouseName(houseName);
            house.setBedroomLevel(bedroomLevel);
            house.setStoreLevel(storeLevel);
            house.setLianqsLevel(lianqsLevel);
            house.setXiuliansLevel(xiuliansLevel);
        }

    }

    @Override
    public int cmd() {
        return 20577;
    }

    private int calcCoinByHouseName(String houseName){
        if(StringUtils.equals(houseName, "小舍")){
            return 10000000;
        }else if(StringUtils.equals(houseName, "雅筑")){
            return 50000000;
        }else {
            return 100000000;
        }
    }

}
