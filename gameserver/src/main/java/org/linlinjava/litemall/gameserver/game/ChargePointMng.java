package org.linlinjava.litemall.gameserver.game;

import io.netty.buffer.ByteBuf;
import org.apache.commons.lang3.time.DateUtils;
import org.linlinjava.litemall.core.util.DateTimeUtil;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.springframework.stereotype.Component;

import java.text.ParseException;
import java.util.LinkedList;
import java.util.List;

/**
 * 充值积分兑换管理
 */
@Component
public class ChargePointMng {
    /**默认的日期格式*/
    public static final String DEFAULT_TIME_FORMAT = "yyyy/MM/dd HH:mm:ss";
    /**活动开始时间*/
    public int startTime;
    /**活动结束时间*/
    public int endTime;
    /**兑换截止时间*/
    public int deadline;
    public List<ExchangeItem> items;
    /**活动开始时间*/
    public static class ExchangeItem {
        /**物品位置从 0 开水*/
        public int no;
        /**物品名称*/
        public String rewardStr;
        /**购买单个的积分*/
        public int point;
        /**剩余数量*/
        public int num;

        public ExchangeItem(){}
        public ExchangeItem(int no, String rewardStr, int point, int num){
            this.no = no;
            this.rewardStr = rewardStr;
            this.point = point;
            this.num = num;
        }
    }

    public static class MSG_RECHARGE_SCORE_GOODS_LIST_VO {
        public int startTime;
        public int endTime;
        public int deadline;
        /**拥有的积分*/
        public int ownPoint;
        /**累计的积分*/
        public int totalPoint;
        public int count;
        public List<ExchangeItem> items;
    }
    public static class MSG_RECHARGE_SCORE_GOODS_LIST extends BaseWrite<MSG_RECHARGE_SCORE_GOODS_LIST_VO> {
        @Override
        protected void writeO(ByteBuf buff, MSG_RECHARGE_SCORE_GOODS_LIST_VO vo) {
            GameWriteTool.writeInt(buff, vo.startTime);
            GameWriteTool.writeInt(buff, vo.endTime);
            GameWriteTool.writeInt(buff, vo.deadline);
            GameWriteTool.writeShort(buff, vo.ownPoint);
            GameWriteTool.writeShort(buff, vo.totalPoint);
            GameWriteTool.writeInt(buff, vo.count);
            for(ExchangeItem item: vo.items){
                GameWriteTool.writeInt(buff, item.no);
                GameWriteTool.writeString(buff, item.rewardStr);
                GameWriteTool.writeShort(buff, item.point);
                GameWriteTool.writeShort(buff, item.num);
            }
        }
        @Override
        public int cmd() {
            return 53447;
        }
    }

    public ChargePointMng(){
        try {
            load();
        } catch (Exception e){}
    }

    /**发送该玩家的充值积分兑换数据*/
    public void sendChargePointGoods(Chara chara){
        MSG_RECHARGE_SCORE_GOODS_LIST_VO vo = new MSG_RECHARGE_SCORE_GOODS_LIST_VO();
        vo.startTime = startTime;
        vo.endTime = endTime;
        vo.deadline = deadline;
        vo.ownPoint = chara.integral;
        vo.totalPoint = chara.totalIntegral;
        vo.items = items;
        vo.count = items.size();
        GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_RECHARGE_SCORE_GOODS_LIST(), vo);
    }

    public void load() throws ParseException {
        startTime = (int)(DateUtils.parseDate("2020/02/01 00:00:00", DEFAULT_TIME_FORMAT).getTime() / 1000);
        endTime = startTime + 3 * 60 * 60;
        deadline = endTime + 7 * 24 * 60 * 60;
        items = new LinkedList<ExchangeItem>();
        String[] rs = new String[]{"#I宠物|墨麒麟(精怪)$1$0#I"};
        for(int i = 0, l = rs.length; i < l; i++){
            items.add(new ExchangeItem(i, rs[i], 1, 100));
        }
    }
}