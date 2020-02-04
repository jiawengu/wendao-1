package org.linlinjava.litemall.gameserver.data.write;

import com.google.common.collect.Maps;
import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.domain.BuildFields;
import org.linlinjava.litemall.gameserver.domain.Rank;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class M61653_0 extends BaseWrite {

    private int type; //排行类型

    private int requestType; //请求类型 1: normal, 2: level
    private int minLevel; //最小等级
    private int maxLevel; //最大等级
    private int cookie; //记录上一次最后次数
    private int count; //返回的数量
    private List<Rank> list; //排行信息



    public M61653_0() {
    }

    public M61653_0(int type, int requestType, int minLevel, int maxLevel, int cookie, int count){
        this.type = type;
        this.requestType = requestType;
        this.minLevel = minLevel;
        this.maxLevel = maxLevel;
        this.cookie = cookie;
        this.count = count;
    }

    protected void writeO(ByteBuf writeBuf, Object object) {
        GameWriteTool.writeShort(writeBuf, type);
        GameWriteTool.writeInt(writeBuf, cookie);
        GameWriteTool.writeShort(writeBuf, count);
        GameWriteTool.writeByte(writeBuf, requestType);
        if(requestType == 2){
            GameWriteTool.writeShort(writeBuf, minLevel);
            GameWriteTool.writeShort(writeBuf, maxLevel);
        }
        List<Rank> list = (List<Rank>) object;
        for (Rank rank : list) {
            Map<Object, Object> map = Maps.newHashMap();
            map.put(BuildFields.IID_STR, rank.getUuid());
            map.put(BuildFields.NAME, rank.getName());
            map.put(BuildFields.LEVEL, rank.getLevel());
            map.put(BuildFields.POLAR, rank.getMenpai());
            map.put(BuildFields.PARTY, "1231654");
            map.put(BuildFields.GID, rank.getUuid());
            map.put(BuildFields.PHY_POWER, rank.getValue());
            map.put(BuildFields.MAG_POWER, rank.getValue());
            map.put(BuildFields.DEF, rank.getValue());
            map.put(BuildFields.SPEED, rank.getValue());
            map.put(BuildFields.TAO, rank.getValue());
            GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
            for (Map.Entry<Object, Object> stringObjectEntry : map.entrySet()) {
                if (BuildFields.data.get(stringObjectEntry.getKey()) != null) {
                    BuildFields buildFields = BuildFields.get((String) stringObjectEntry.getKey());
                    buildFields.key += 1;
                    buildFields.write(writeBuf, stringObjectEntry.getValue());
                }else {
                    System.out.println("---------------------------");
                }
            }
        }
    }

    public int cmd() {
        return 61653;
    }
}
