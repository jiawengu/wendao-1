package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.vo.Vo_41106_0;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.springframework.stereotype.Service;



/**
 * CMD_REQUEST_CONSUME_SCORE_GOODS  -- 请求消费积分商品信息
 */
@Service
public class CMD_REQUEST_CONSUME_SCORE_GOODS implements GameHandler {
    public void process(ChannelHandlerContext ctx, ByteBuf buff) {
//        Vo_41106_0 vo_41106_0 = new Vo_41106_0();
//        vo_41106_0.month = 7;
//        vo_41106_0.startTime = 1561928400;
//        vo_41106_0.endTime = 1564606799;
//        vo_41106_0.count = 4;
//        vo_41106_0.item_name0 = "刷道卷轴";
//        vo_41106_0.item_amount0 = 5;
//        vo_41106_0.item_gift0 = 1;
//        vo_41106_0.item_icon0 = "";
//        vo_41106_0.item_name1 = "随机变身卡";
//        vo_41106_0.item_amount1 = 4;
//        vo_41106_0.item_gift1 = 0;
//        vo_41106_0.item_icon1 = "BigRewardIcon0028.png";
//        vo_41106_0.item_name2 = "急急如律令";
//        vo_41106_0.item_amount2 = 1;
//        vo_41106_0.item_gift2 = 1;
//        vo_41106_0.item_icon2 = "";
//        vo_41106_0.item_name3 = "风灵丸";
//        vo_41106_0.item_amount3 = 1;
//        vo_41106_0.item_gift3 = 1;
//        vo_41106_0.item_icon3 = "";
    }


    public int cmd() {
        return 41111;
    }
}


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C41111_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */