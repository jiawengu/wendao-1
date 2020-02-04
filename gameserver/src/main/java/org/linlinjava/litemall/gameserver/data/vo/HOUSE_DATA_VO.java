package org.linlinjava.litemall.gameserver.data.vo;

import lombok.Data;

@Data
public class HOUSE_DATA_VO {

    private String houseId;
    private int houseType;
    private String housePrefix;
    private int comfort;
    private int cleanliness;
    private int cleanCosttime;
    private int storeType;

}
