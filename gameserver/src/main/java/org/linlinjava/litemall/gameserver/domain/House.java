package org.linlinjava.litemall.gameserver.domain;

import lombok.Data;

import java.util.LinkedList;
import java.util.List;

@Data
public class House {

    private String houseName; //居所名称

    private String houseId; //居所ID

    private int houseType; //居所类型

    private int bedroomLevel; //卧室等级

    private int storeLevel; //储物室等级

    private int lianqsLevel; //炼器室等级

    private int xiuliansLevel; //修炼室等级

    public List<Goods> homeStore; //居所储物室


    public House(){}

}
