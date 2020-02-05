package org.linlinjava.litemall.gameserver.util;

import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;

import java.util.Arrays;

public class HomeUtils {

    private final static int[] HOUSE_MAP_ID_LIST = {28100, 28101, 28102, 28200, 28201, 28202, 28300, 28301, 28302};

    public static int getStoreSpaceByStoreLevel(int storeLevel){
        int storeSpace = 0;
        switch (storeLevel){
            case 1:
                storeSpace = 10;
                break;
            case 2:
                storeSpace = 25;
                break;
            case 3:
                storeSpace = 50;
                break;
            default:
                storeSpace = 0;
                break;
        }
        return storeSpace;
    }

    public static boolean isHouseMap(int mapId){
        return ArrayUtils.contains(HOUSE_MAP_ID_LIST, mapId);
    }

    public static String getNameByType(int type){
        String name = "";
        switch (type){
            case 1:
                name = "小舍";
                break;
            case 2:
                name = "雅筑";
                break;
            case 3:
                name = "豪宅";
                break;
            default:
                break;
        }
        return name;
    }

    public static int getTypeByName(String name){
        if(StringUtils.equals(name, "小舍")){
            return 1;
        }else if (StringUtils.equals(name, "雅筑")){
            return 2;
        }else if (StringUtils.equals(name, "豪宅")){
            return 3;
        }
        return 1;
    }

}
