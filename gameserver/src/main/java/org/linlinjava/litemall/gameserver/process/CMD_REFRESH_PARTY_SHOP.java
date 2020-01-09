package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_REFRESH_PARTY_SHOP;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_REFRESH_PARTY_SHOP_item;
import org.linlinjava.litemall.gameserver.data.write.M_MSG_REFRESH_PARTY_SHOP;
import org.linlinjava.litemall.gameserver.data.xls_config.PartyShopCfg;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.XLSConfigMgr;
import org.springframework.stereotype.Service;

import java.util.ArrayList;

@Service
public class CMD_REFRESH_PARTY_SHOP implements GameHandler {
    @Override
    public void process(ChannelHandlerContext ctx, ByteBuf buf) {
        String type = GameReadTool.readString(buf);
        System.out.println("type:" + type);

        Vo_MSG_REFRESH_PARTY_SHOP vo = new Vo_MSG_REFRESH_PARTY_SHOP();
        vo.list = new ArrayList<>();
        vo.costWing = 99;

        PartyShopCfg cfg = (PartyShopCfg)XLSConfigMgr.getCfg("party_shop");
        cfg.forEach(item->{
            Vo_MSG_REFRESH_PARTY_SHOP_item shop = new Vo_MSG_REFRESH_PARTY_SHOP_item();
            shop.cost = item.cost;
            shop.name = item.name;
            shop.num = item.daily_limit;
            vo.list.add(shop);
        });
        GameObjectChar.send(new M_MSG_REFRESH_PARTY_SHOP(), vo);
    }

    @Override
    public int cmd() {
        return 0x8016;
    }
}
