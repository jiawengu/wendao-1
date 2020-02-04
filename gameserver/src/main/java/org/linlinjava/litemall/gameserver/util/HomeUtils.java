package org.linlinjava.litemall.gameserver.util;

import org.apache.commons.lang3.ArrayUtils;

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
}
