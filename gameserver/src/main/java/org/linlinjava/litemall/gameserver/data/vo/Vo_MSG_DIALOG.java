package org.linlinjava.litemall.gameserver.data.vo;

import java.util.ArrayList;
import java.util.List;

public class Vo_MSG_DIALOG  {
    public String caption = "";
    public String content = "";
    public String peer_name = "";
    public String ask_type = "";
    public int flag = 0;
    public List<Vo_MSG_DIALOG_item> list = new ArrayList<>();
}
