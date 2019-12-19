//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.data.game;

import java.util.Hashtable;

public class ConsumeMoneyUtils {
    public ConsumeMoneyUtils() {
    }

    private int[] appraisalMoney(int eqType, int eq_attrib) {
        int[] min_max = new int[]{0, 0};
        if (eq_attrib <= 40) {
            return min_max;
        } else {
            if (eq_attrib > 120) {
                eq_attrib = 120;
            }

            int[] moneys;
            if (eqType == 1 || eqType == 3) {
                moneys = new int[]{50000, 100000, 150000, 250000, 300000, 35000, 500000, 750000};
                min_max[0] = moneys[eq_attrib / 10 - 5];
                min_max[1] = min_max[0] * 5;
            }

            if (eqType == 10 || eqType == 2) {
                moneys = new int[]{35000, 50000, 75000, 100000, 200000, 300000, 400000, 500000};
                min_max[0] = moneys[eq_attrib / 10 - 5];
                min_max[1] = min_max[0] * 5;
            }

            return min_max;
        }
    }

    public static int appraisalMoney(int dst_eq_attrib) {
        Hashtable<Integer, Integer> hashtable = new Hashtable();
        hashtable.put(35, 0);
        hashtable.put(50, 25000);
        hashtable.put(60, 30000);
        hashtable.put(70, 35000);
        hashtable.put(80, 480000);
        hashtable.put(90, 540000);
        hashtable.put(100, 600000);
        hashtable.put(110, 1100000);
        hashtable.put(120, 1200000);
        return (Integer)hashtable.get(dst_eq_attrib);
    }

    public static int createMoney(int eq_attrib) {
        return eq_attrib < 70 ? 0 : (eq_attrib / 10 - 7) * 10000 + 75000;
    }

    public static int removeMoney(int eq_attrib) {
        return eq_attrib < 70 ? 0 : (eq_attrib / 10 - 7) * 700 + 5200;
    }

    public static int pinkMoney(int eq_attrib) {
        if (eq_attrib < 70) {
            return 0;
        } else if (eq_attrib > 120) {
            return 235400;
        } else {
            int[] moneys = new int[]{83400, 107400, 134600, 165000, 198600, 235400};
            return moneys[eq_attrib / 10 - 7];
        }
    }

    public static int remakeMoney(int eq_attrib) {
        if (eq_attrib < 70) {
            return 0;
        } else if (eq_attrib > 120) {
            return 235400;
        } else {
            int[] moneys = new int[]{83400, 107400, 134600, 165000, 198600, 235400};
            return moneys[eq_attrib / 10 - 7];
        }
    }

    public static int yellowMoney(int eq_attrib) {
        if (eq_attrib < 70) {
            return 0;
        } else if (eq_attrib > 120) {
            return 353100;
        } else {
            int[] moneys = new int[]{125100, 161100, 201900, 247500, 297900, 353100};
            return moneys[eq_attrib / 10 - 7];
        }
    }

    public static int appendEqMoney(int eq_attrib) {
        if (eq_attrib < 70) {
            return 0;
        } else if (eq_attrib > 120) {
            return 353100;
        } else {
            int[] moneys = new int[]{125100, 161100, 201900, 247500, 297900, 353100};
            return moneys[eq_attrib / 10 - 7];
        }
    }
}
