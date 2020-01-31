package org.linlinjava.litemall.gameserver.data.vo;

import java.util.ArrayList;
import java.util.List;

public class Vo_MSG_SUBMIT_PET {
    public  short type = 0;//类型
    public  short petCount = 0;//个数

    public  List<String> petNameList = new ArrayList<>();
    public  Long petState = 0L;
}
