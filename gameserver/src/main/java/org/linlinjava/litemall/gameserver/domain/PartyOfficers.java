package org.linlinjava.litemall.gameserver.domain;


import java.util.ArrayList;
import java.util.HashMap;

public class PartyOfficers extends HashMap<String, PartyOfficers.Office> {
    public static class Office {
        public int id = 0;
        public String name = "";
        public Office(){}
        public Office(int id, String name){
            this.id = id;
            this.name = name;
        }
    }
}
