//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.data.game;

import java.util.Hashtable;
import java.util.Random;

public class PetAttributesUtils {
    public PetAttributesUtils() {
    }

    /**
     * new int[]{def_all, dex_all, accurate_all, mana_all, parry_all, wiz_all}
     * @param isMagic
     * @param attrib
     * @param constitution
     * @param mag_power
     * @param phy_power
     * @param speed
     * @param qx_append
     * @param fl_append
     * @param sd_append
     * @param wg_append
     * @param fg_append
     * @return
     */
    public static int[] petAttributes(boolean isMagic, int attrib, int constitution, int mag_power, int phy_power, int speed, int qx_append, int fl_append, int sd_append, int wg_append, int fg_append) {
        int parry_all = (int)(0.06D * (double)sd_append * (double)speed + 50.0D);
        int accurate_all = (int)((double)wg_append * 0.3D * (double)phy_power + (double)(16 * attrib) + 50.0D);
        int mana_all = (int)((double)(fg_append * mag_power) * 0.55D + (double)(15 * attrib) + 70.0D);
        int def_all = (int)((double)qx_append * 0.81D * (double)constitution + 3.237D * (double)(attrib * attrib));
        int dex_all = (int)((double)fl_append * 0.38D * (double)mag_power + (double)(70 * attrib));
        int wiz_all = (int)((double)qx_append * 0.0835D * (double)constitution + 0.77D * (double)(attrib * attrib));
        int[] attributes = new int[]{def_all, dex_all, accurate_all, mana_all, parry_all, wiz_all};
        return attributes;
    }

    public static int[] emergencePet(int quality, int use_attrib, int currentStep, int currentReiki, int pill, int equipmentMoney, int UnidentifiedMoney, int[] appends) {
        int[] reikis = new int[]{24000, 25756, 27575, 29395, 31056, 32655, 34203, 35719, 37200, 38653, 40083, 41490, 42879, 44251, 45606, 46947, 48275, 49591, 50895, 52188, 53471, 54744, 56008, 57272, 58536, 59800};
        int maxReiki = 0;
        if (quality == 1) {
            if (use_attrib >= 130) {
                maxReiki = (use_attrib - 125) / 5 * 1264 + '\ue998';
            } else {
                maxReiki = reikis[use_attrib / 5];
            }

            if (currentStep != 1) {
                if (currentStep == 2) {
                    maxReiki = maxReiki / 2 * 3;
                } else if (currentStep == 3) {
                    maxReiki = maxReiki / 2 * 5;
                }
            }
        } else if (quality == 3) {
            maxReiki = 300000;
        } else if (quality == 2) {
            maxReiki = 140000;
            if (currentStep != 1) {
                if (currentStep == 2) {
                    maxReiki = maxReiki / 2 * 3;
                } else if (currentStep == 3) {
                    maxReiki = maxReiki / 2 * 5;
                }
            }
        } else if (quality == 4) {
            maxReiki = 280000;
            if (currentStep != 1) {  // 一阶段默认
                if (currentStep == 2) {  //第二阶段
                    maxReiki = maxReiki / 2 * 3; //420000
                } else if (currentStep == 3) {  //第三姐阶段
                    maxReiki = maxReiki / 2 * 5; //700000
                }
            }
        }

        int[] result = new int[7];
        int newReiki = (int)((double)(currentReiki + pill * 3000 + equipmentMoney / 5000) + (double)UnidentifiedMoney / 714.2857142857143D);

        if ((double)newReiki >= (double)maxReiki /** 0.95D*/) {
            result[0] = 1;
            result[1] = maxReiki;
        } else if ((double)newReiki > (double)maxReiki * 0.7D && (new Random()).nextInt(10) < 2) {
            result[0] = 1;
            result[1] = maxReiki;
        } else {
            result[1] = newReiki;
        }


        if (quality == 1) {
            result[2] = (int)(0.5D * (double)Math.abs(appends[0]));
            result[3] = (int)(0.2D * (double)Math.abs(appends[1]));
            result[4] = (int)(0.2D * (double)Math.abs(appends[2]));
            result[5] = (int)(0.2D * (double)Math.abs(appends[3]));
            result[6] = (int)(0.3D * (double)Math.abs(appends[4]));
        } else if (quality == 2) {
            result[2] = (int)(0.6D * (double)Math.abs(appends[0]));
            result[3] = (int)(0.25D * (double)Math.abs(appends[1]));
            result[4] = (int)(0.4D * (double)Math.abs(appends[2]));
            result[5] = (int)(0.5D * (double)Math.abs(appends[3]));
            result[6] = (int)(0.4D * (double)Math.abs(appends[4]));
        } else if (quality == 3) {
            result[2] = (int)(0.8D * (double)Math.abs(appends[0]));
            result[3] = (int)(0.4D * (double)Math.abs(appends[1]));
            result[4] = (int)(0.5D * (double)Math.abs(appends[2]));
            result[5] = (int)(0.7D * (double)Math.abs(appends[3]));
            result[6] = (int)(0.45D * (double)Math.abs(appends[4]));
        }else if (quality == 4) {
            result[2] = (int)(1.0D * (double)Math.abs(appends[0]));
            result[3] = (int)(0.8D * (double)Math.abs(appends[1]));
            result[4] = (int)(0.6D * (double)Math.abs(appends[2]));
            result[5] = (int)(0.9D * (double)Math.abs(appends[3]));
            result[6] = (int)(0.7D * (double)Math.abs(appends[4]));
        }

        return result;
    }

    public static int[] dotPet(int quality, int use_attrib, int currentReiki, int pill, int equipmentMoney, int UnidentifiedMoney, int[] appends) {
        int[] result = new int[7];
        int maxReiki = 0;
        if (quality == 1) {
            maxReiki = use_attrib * use_attrib * 30;
        } else if (quality == 2) {
            maxReiki = 400000;
        } else if (quality == 3) {
            maxReiki = 400000;
        } else if (quality == 4) {
            maxReiki = 400000;
        }

        int newReiki = currentReiki + pill * 6000 + equipmentMoney / 1000 + UnidentifiedMoney / 142;
        double proportion;
        if (newReiki >= maxReiki) {
            result[0] = 1;
            result[1] = maxReiki;
            proportion = 1.0D;
        } else {
            result[1] = newReiki;
            proportion = 1.0D * (double)newReiki / (double)maxReiki;
        }

        result[2] = (int)(proportion * 0.3D * (double)Math.abs(appends[0]));
        result[3] = (int)(proportion * 0.3D * (double)Math.abs(appends[1]));
        result[4] = (int)(proportion * 0.3D * (double)Math.abs(appends[2]));
        result[5] = (int)(proportion * 0.3D * (double)Math.abs(appends[3]));
        result[6] = (int)(proportion * 0.3D * (double)Math.abs(appends[4]));
        return result;
    }

    public static int[] upgradePet(boolean isMagic, int maxAttrib, int currentUpgrade, int currentProgress) {
        int[] result = new int[3];
        Random random = new Random();
        int raInt = random.nextInt(10000);
        int[] probability = new int[]{6450, 1000, 214, 133, 90, 65, 45, 35, 21, 15, 8, 5, 3};
        if (currentUpgrade >= 12) {
            result[0] = currentUpgrade;
            return result;
        } else {
            if (raInt <= probability[currentUpgrade]) {
                result[0] = currentUpgrade + 1;
                result[2] = 0;
            } else if (currentProgress + probability[currentUpgrade] >= 10000) {
                result[0] = currentUpgrade + 1;
                result[2] = 0;
            } else {
                result[2] = currentProgress + probability[currentUpgrade];
            }

            if (isMagic) {
                result[1] = (int)((double)maxAttrib / 12.5D);
            } else {
                result[1] = (int)((double)maxAttrib / 12.5D);
            }

            return result;
        }
    }

    public static Hashtable<String, int[]> helpPet(int type, int polar, int attriba) {
        int[] base_polars = new int[]{6, 6, 6, 6, 6};
        int[] j = new int[]{1, 3, 4, 2, 5};
        int[] m = new int[]{4, 1, 2, 3, 5};
        int[] s = new int[]{2, 3, 1, 4, 5};
        int[] h = new int[]{4, 3, 5, 1, 2};
        int[] t = new int[]{4, 2, 3, 5, 1};
        Hashtable<Integer, int[]> hashtable = new Hashtable();
        hashtable.put(1, j);
        hashtable.put(2, m);
        hashtable.put(3, s);
        hashtable.put(4, h);
        hashtable.put(5, t);
        int count_xx;
        if (attriba <= 60) {
            count_xx = attriba / 2 + 2;
        } else if (attriba < 81) {
            count_xx = (int)((double)(attriba - 60) * 1.45D + 32.0D);
        } else {
            count_xx = attriba - 19;
            if (count_xx > 97) {
                count_xx = 97;
            }
        }

        int[] xx = (int[])hashtable.get(polar);

        for(int i = 0; i < xx.length; ++i) {
            if (xx[i] == 1) {
                if (count_xx >= 33) {
                    base_polars[i] += 33;
                } else {
                    base_polars[i] += count_xx;
                }
            }

            if (xx[i] == 2 && count_xx >= 33) {
                if (count_xx - 33 >= 32) {
                    base_polars[i] += 32;
                } else {
                    base_polars[i] = base_polars[i] + count_xx - 33;
                }
            }

            if (xx[i] == 3 && count_xx >= 65) {
                if (count_xx - 65 >= 32) {
                    base_polars[i] += 32;
                } else {
                    base_polars[i] = base_polars[i] + count_xx - 65;
                }
            }

            if (type == 2) {
                int var10002 = base_polars[i]++;
            } else if (type == 3) {
                base_polars[i] += 2;
            }
        }

        int[] base_ss = new int[]{16, 40, 12, 29};
        Hashtable<Integer, int[]> hashtabless125 = new Hashtable();
        hashtabless125.put(1, new int[]{197, 480, 158, 354});
        hashtabless125.put(2, new int[]{443, 158, 158, 511});
        hashtabless125.put(3, new int[]{255, 427, 140, 235});
        hashtabless125.put(4, new int[]{175, 140, 252, 533});
        hashtabless125.put(5, new int[]{235, 140, 490, 175});
        int[] base_ss125;
        if (attriba <= 13) {
            base_ss = new int[]{16, 40, 12, 29};
        } else if (attriba >= 125) {
            base_ss = (int[])hashtabless125.get(polar);
        } else {
            base_ss125 = (int[])hashtabless125.get(polar);

            for(int i = 0; i < 4; ++i) {
                base_ss[i] += (base_ss125[i] - base_ss[i]) / 112 * (attriba - base_ss[i]);
            }
        }

        base_ss125 = new int[]{9, 26, 8, 19};
        int[] ms = new int[]{36, 13, 8, 46};
        int[] ss = new int[]{38, 67, 29, 35};
        int[] hs = new int[]{22, 67, 29, 35};
        int[] ts = new int[]{29, 18, 11, 22};
        Hashtable<Integer, int[]> hashtablessadd = new Hashtable();
        hashtablessadd.put(1, base_ss125);
        hashtablessadd.put(2, ms);
        hashtablessadd.put(3, ss);
        hashtablessadd.put(4, hs);
        hashtablessadd.put(5, ts);
        int[] addss = (int[])hashtablessadd.get(polar);
        int i;
        if (type == 2) {
            for(i = 0; i < 4; ++i) {
                base_ss[i] += addss[i];
            }
        } else {
            for(i = 0; i < 4; ++i) {
                base_ss[i] = (int)((double)base_ss[i] + (double)addss[i] * 1.5D);
            }
        }

        Hashtable<String, int[]> hp = new Hashtable();
        hp.put("attribute", base_ss);
        hp.put("polars", base_polars);
        return hp;
    }
}
