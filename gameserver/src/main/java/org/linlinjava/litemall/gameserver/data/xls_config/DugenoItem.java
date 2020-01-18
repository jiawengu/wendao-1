package org.linlinjava.litemall.gameserver.data.xls_config;

import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

public class DugenoItem {
    public int id;
    public String name;
    public String map_name;
    public String enterjuben_liststr;
    public String[] enterjuben_list;
    public String fightwinjuben_liststr;
    public List<String[]> fightwinjuben_list;
    public String monster_liststr;
    public List<Integer> monster_list;
    public String pet_liststr;
    public List<List<Integer>> pet_list;
    public String taskinfo_liststr;
    public List<String> taskinfo_list;
    public int max_step;
    public String next_dugeno;
    public int back_map;
    public int back_x;
    public int back_y;
    public String task_type;
    public String task_prompt;

    public void init(){
        initMonsterList();
        initPetList();
        initTaskinfoList();
        initJubenList();
    }

    // 解释怪物列表
    private void initMonsterList()
    {
        String[] split_list = monster_liststr.split(";");
        this.monster_list = new LinkedList();
        for (String str : split_list) {
            try {
                Integer b = Integer.valueOf(str);
                this.monster_list.add(b);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }
    }

    // 解释战斗怪物列表
    private void initPetList(){
        this.pet_list = new LinkedList();
        if(pet_liststr.equals("")) return;
        String[] split_list = pet_liststr.split(";");
        for (String str : split_list) {
            List<Integer> list = new LinkedList();
            if(!str.equals("")) {
                String[] split_list1 = str.split("\\|");
                for (String s : split_list1) {
                    String[] split_list2 = s.split(":");
                    try {
                        Integer id = Integer.valueOf(split_list2[0]);
                        Integer num = Integer.valueOf(split_list2[1]);
                        for (int i = 0; i < num; i++) {
                            list.add(id);
                        }

                    } catch (NumberFormatException e) {
                        e.printStackTrace();
                    }
                }
            }
            this.pet_list.add(list);
        }
    }

    private void initTaskinfoList() {
        this.taskinfo_list  = Arrays.asList(taskinfo_liststr.split(";"));
    }

    private void initJubenList() {
        this.enterjuben_list = new String[0];
        if(!enterjuben_liststr.equals("")) this.enterjuben_list  = enterjuben_liststr.split(",");

        this.fightwinjuben_list = new LinkedList();
        if(fightwinjuben_liststr.equals("")) return;
        String[] split_list = fightwinjuben_liststr.split(";");
        for (String str : split_list) {
            String[] s = new String[0];
            if(!str.equals(""))  s = str.split(",");
            this.fightwinjuben_list.add(s);
        }
    }
}
