//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.data.game;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Random;
import java.util.Set;

public class ForgingEquipmentUtils {
    public static final int RESIST_POLAR_J = 1;
    public static final int RESIST_POLAR_M = 2;
    public static final int RESIST_POLAR_S = 3;
    public static final int RESIST_POLAR_H = 4;
    public static final int RESIST_POLAR_T = 5;
    public static final int EQUIPMENT_APPRAISA_NORMAL = 1;
    public static final int EQUIPMENT_APPRAISA_DELICATE = 2;
    public static final int EQUIPMENT_APPRAISA_PINK = 3;
    public static final int EQUIPMENT_APPRAISA_YELLOW = 4;
    public static final int EQUIPMENT_APPRAISA_GREEN = 5;
    public static final int EQUIPMENT_APPRAISA_REMAKE = 6;
    public static final int EQUIPMENT_APPRAISA_REMAKE_FIVE = 7;
    public static final int EQUIPMENT_APPRAISA_RESONANCE = 8;
    public static final int EQUIPMENT_SYNTHESIS_JEWELRY = 9;
    public static final int EQUIPMENT_LUCK_DRAW = 10;

    public ForgingEquipmentUtils() {
    }

    public static int[] appendAttrib(String key, int currentValue, int eq_attrib, int eqType) {
        return appendAttrib(key, currentValue, eq_attrib, 0, eqType);
    }

    private static int[] proportion(int currentProportion, int a, int maxValue, int newValue, int step) {
        int[] new_pro = new int[2];
        if (currentProportion + a >= 100000000 && newValue + step < maxValue) {
            new_pro[0] = newValue + step;
            new_pro[1] = 0;
            return new_pro;
        } else {
            new_pro[0] = newValue;
            new_pro[1] = currentProportion + a;
            return new_pro;
        }
    }

    public static int[] remakeAttrib(int currentColor, int currentProportion, int stoneCount) {
        int[] v_a = new int[2];
        if (currentProportion >= 100000000) {
            ++currentColor;
        }

        if (currentColor >= 12) {
            currentColor = 12;
            v_a[0] = currentColor;
            v_a[1] = 0;
            return v_a;
        } else {
            Random random = new Random();
            int raInt = random.nextInt(100000000);
            int suc = (int)(9.6E7D / Math.pow(2.0D, (double)currentColor));
            if (raInt < suc) {
                ++currentColor;
                currentProportion = 0;
            } else {
                currentProportion += suc;
                if (currentProportion >= 100000000) {
                    ++currentColor;
                    currentProportion = 0;
                }
            }

            v_a[0] = currentColor;
            v_a[1] = currentProportion;
            return v_a;
        }
    }

    public static int[] appendAttrib(String key, int currentValue, int eq_attrib, int currentProportion, int eqType) {
        String chineseName = getEquipmentKeyByName(key, false);
        int maxValue = getMaxValueByChineseName(chineseName, eq_attrib, eqType == 3, false);
        int[] v_a = new int[3];
        if (currentValue >= maxValue) {
            v_a[0] = maxValue;
            v_a[1] = 0;
            v_a[2] = 0;
            return v_a;
        } else {

            short step;
            if (maxValue <= 30) {
                step = 1;
            } else if (maxValue <= 50) {
                step = 2;
            } else if (maxValue <= 100) {
                step = 5;
            } else if (maxValue <= 500) {
                step = 50;
            } else if (maxValue <= 1000) {
                step = 100;
            } else if (maxValue <= 2000) {
                step = 200;
            } else if (maxValue <= 4000) {
                step = 400;
            } else {
                step = 500;
            }

            int[] as = new int[]{11200000, 8200000, 5300000, 1900000, 142222};
            Random random = new Random();
            int v;
            int[] new_value;
            if (maxValue - currentValue <= step) {
                v = random.nextInt(100) != 1 && random.nextInt(100) != 99 ? currentValue : maxValue;
                v_a[0] = v;
                v_a[1] = as[4];
                new_value = proportion(currentProportion, v_a[1], maxValue, v_a[0], step);
                v_a[0] = new_value[0];
                v_a[2] = new_value[1];
                return v_a;
            } else if (maxValue - currentValue <= 2 * step && maxValue - currentValue > step) {
                v = random.nextInt(100) < 10 ? maxValue - step : currentValue;
                v_a[0] = v;
                v_a[1] = as[3];
                new_value = proportion(currentProportion, v_a[1], maxValue, v_a[0], step);
                v_a[0] = new_value[0];
                v_a[2] = new_value[1];
                return v_a;
            } else if (maxValue - currentValue <= 3 * step) {
                v = random.nextInt(100) < 30 ? maxValue - 2 * step : currentValue;
                v_a[0] = v;
                v_a[1] = as[2];
                new_value = proportion(currentProportion, v_a[1], maxValue, v_a[0], step);
                v_a[0] = new_value[0];
                v_a[2] = new_value[1];
                return v_a;
            } else {
                List<Integer> vlist = new ArrayList();
                int count = (maxValue + step - currentValue) / step;

                int length;
                for(length = 0; length < count; ++length) {
                    int value = currentValue + length * step;
                    if (value >= maxValue) {
                        value = maxValue;
                    }

                    vlist.add(value);
                    if (value == maxValue) {
                        break;
                    }
                }

                length = vlist.size() - 1;
                List<Integer> separates = new ArrayList();
                List<Integer> percents = new ArrayList();
                if (length == 2) {
                    separates.add(1);
                    percents.add(97);
                    percents.add(3);
                    v_a[1] = as[4];
                } else if (length == 3) {
                    separates.add(1);
                    separates.add(2);
                    percents.add(78);
                    percents.add(20);
                    percents.add(2);
                    v_a[1] = as[3];
                } else if (length == 4) {
                    separates.add(2);
                    separates.add(3);
                    percents.add(78);
                    percents.add(20);
                    percents.add(2);
                    v_a[1] = as[2];
                } else {
                    separates.add(length / 2);
                    separates.add(length - 3);
                    separates.add(length - 1);
                    percents.add(63);
                    percents.add(30);
                    percents.add(5);
                    percents.add(2);
                    v_a[1] = as[0];
                }

                int number = RateRandomNumber.produceRateRandomNumber(0, length, separates, percents);
                v_a[0] = (Integer)vlist.get(number);
                new_value = proportion(currentProportion, v_a[1], maxValue, v_a[0], step);
                v_a[0] = new_value[0];
                v_a[2] = new_value[1];
                return v_a;
            }
        }
    }

    public static String[] removeAttrib(String[] attribs) {
        return removeAttrib(attribs, false);
    }

    public static String[] removeAttrib(String[] attribs, boolean useChaos) {
        String[] strings = new String[2];
        int length = attribs.length;
        if (length == 0) {
            return null;
        } else {
            Random random = new Random();
            if (!useChaos && random.nextInt(10) <= 3) {
                return null;
            } else {
                int r = random.nextInt(length);
                String name = getEquipmentKeyByName(attribs[r], false);
                if (name.contentEquals("伤害_最低伤害")) {
                    name = "伤害";
                }

                strings[0] = String.valueOf(r);
                strings[1] = name;
                return strings;
            }
        }
    }

    public static List<Hashtable<String, Integer>> appraisalEquipment(int eqType, int eq_attrib, int appraisalType) {
        return appraisalEquipment(eqType, eq_attrib, appraisalType, (HashSet)null, 0, 0);
    }

    public static List<Hashtable<String, Integer>> appraisalALLEquipment(int eqType, int dst_eq_attrib, Hashtable<String, Integer> hashtable) {
        List<Hashtable<String, Integer>> hashtableList = new ArrayList();
        if (null == hashtable) {
            hashtable = new Hashtable();
        }

        if (appraisalEquipment(eqType)) {
            hashtableList = appraisalEquipment(eqType, dst_eq_attrib, hashtable);
            if (!hashtable.isEmpty() && dst_eq_attrib >= 90) {
                Set<String> keys = hashtable.keySet();
                Iterator var5 = keys.iterator();

                while(var5.hasNext()) {
                    String key = (String)var5.next();
                    String chineseName = getEquipmentKeyByName(key, false);
                    int current_max = getMaxValueByChineseName(chineseName, dst_eq_attrib - 10, false, false);
                    int dst_max = getMaxValueByChineseName(chineseName, dst_eq_attrib, false, false);
                    int dst_value = (Integer)hashtable.get(key) * dst_max / current_max;
                    hashtable.put(key, dst_value);
                }
            }

            ((Hashtable)((List)hashtableList).get(0)).putAll(hashtable);
        }

        return (List)hashtableList;
    }

    public static boolean appraisalEquipment(int dst_eq_attrib) {
        Hashtable<Integer, Integer> hashtable = new Hashtable();
        hashtable.put(35, 0);
        hashtable.put(50, 1);
        hashtable.put(60, 2);
        hashtable.put(70, 3);
        hashtable.put(80, 4);
        hashtable.put(90, 5);
        hashtable.put(100, 6);
        hashtable.put(110, 7);
        hashtable.put(120, 8);
        if (hashtable.contains(dst_eq_attrib)) {
            if (dst_eq_attrib <= 70) {
                return true;
            }

            if (dst_eq_attrib >= 70 && dst_eq_attrib <= 100) {
                Random random = new Random();
                return random.nextInt(100) < 30 - 8 * (dst_eq_attrib / 10 - 7);
            }

            if (dst_eq_attrib >= 110) {
                return true;
            }
        }

        return false;
    }

    public static List<Hashtable<String, Integer>> appraisalEquipment(int eqType, int eq_attrib, Hashtable<String, Integer> hashtable) {
        HashSet<String> only = new HashSet();
        if (null != hashtable && !hashtable.isEmpty()) {
            only.addAll(hashtable.keySet());
        }

        return appraisalEquipment(eqType, eq_attrib, 9, only, 0, 0);
    }

    public static List<Hashtable<String, Integer>> appraisalGreenEquipment(int eqType, int eq_attrib, int polar) {
        return appraisalEquipment(eqType, eq_attrib, 5, (HashSet)null, polar, 0);
    }

    public static List<Hashtable<String, Integer>> appraisalRemakeEquipment(int eqType, int eq_attrib, int currentColor) {
        List<Hashtable<String, Integer>> hashtableList = new ArrayList();
        if (currentColor < 5) {
            hashtableList.addAll(appraisalEquipment(eqType, eq_attrib, 6, (HashSet)null, 0, currentColor));
        } else {
            List<Hashtable<String, Integer>> list = appraisalEquipment(eqType, eq_attrib, 6, (HashSet)null, 0, currentColor);
            if (!list.isEmpty()) {
                Hashtable<String, Integer> hashtable = (Hashtable)list.get(0);
                if (null != hashtable) {
                    List<Hashtable<String, Integer>> listf = appraisalEquipment(eqType, eq_attrib, 7, (HashSet)null, 0, currentColor);
                    if (!list.isEmpty()) {
                        Hashtable<String, Integer> hashtablef = (Hashtable)listf.get(0);
                        if (((Integer)hashtablef.get("groupNo")).equals(hashtable.get("groupNo"))) {
                            hashtable.putAll(hashtablef);
                            hashtableList.add(hashtable);
                        }
                    }
                }
            }
        }

        return hashtableList;
    }

    public static List<Hashtable<String, Integer>> appraisalRemakeEquipment(String resonance, int eqType, int eq_attrib, int currentColor) {
        List<Hashtable<String, Integer>> hashtableList = new ArrayList();
        if (null != resonance && resonance.length() != 0) {
            Hashtable<String, Integer> key_vlaue_tab = new Hashtable();
            key_vlaue_tab.put("groupNo", 27);
            key_vlaue_tab.put(resonance, getMaxValueByChineseName(resonance, eq_attrib, eqType == 3, true) * 2 / 12 * currentColor);
            hashtableList.add(key_vlaue_tab);
        }

        List<Hashtable<String, Integer>> hashtableList2 = appraisalRemakeEquipment(eqType, eq_attrib, currentColor);
        hashtableList.addAll(hashtableList2);
        return hashtableList;
    }

    public static List<Hashtable<String, Integer>> resonanceEquipMent(int eq_attrib, int currentColor, int stone, boolean addOrChange) {
        List<Hashtable<String, Integer>> hashtableList = new ArrayList();
        Random random = new Random();
        if (addOrChange || stone >= 3 || random.nextBoolean()) {
            hashtableList.addAll(appraisalEquipment(0, eq_attrib, 8, (HashSet)null, 0, currentColor));
        }

        return hashtableList;
    }

    public static List<Hashtable<String, Integer>> appraisalEquipment(int eqType, int eq_attrib, int appraisalType, int polar) {
        return appraisalEquipment(eqType, eq_attrib, appraisalType, (HashSet)null, polar, 0);
    }

    public static List<Hashtable<String, Integer>> appraisalEquipment(int eqType, int eq_attrib, int appraisalType, HashSet<String> repeatAttributes) {
        return (List)(3 == appraisalType ? appraisalEquipment(eqType, eq_attrib, appraisalType, repeatAttributes, 0, 0) : new ArrayList());
    }

    public static List<Hashtable<String, Integer>> appraisalYellowEquipment(int eqType, int eq_attrib, int appraisalType, HashSet<String> repeatAttributes, int stone) {
        if (4 == appraisalType) {
            Random random = new Random();
            int r = random.nextInt(100);
            if (r < 90 || stone >= 6) {
                return appraisalEquipment(eqType, eq_attrib, appraisalType, repeatAttributes, 0, 0);
            }
        }

        return new ArrayList();
    }

    private static List<Hashtable<String, Integer>> appraisalEquipment(int eqType, int eq_attrib, int appraisalType, HashSet<String> repeatAttributes, int polar, int color) {
        List<Hashtable<String, Integer>> appraisalList = new ArrayList();
        List blueList;
        Hashtable key_vlaue_tab;
        Iterator iterator;
        String repKey;
        if (10 == appraisalType) {
            key_vlaue_tab = baseBlueSuit(eqType, eq_attrib);
            blueList = randomAttribute((String[])key_vlaue_tab.get(eqType), (new Random()).nextInt(5) < 4 ? 1 : 2);
            key_vlaue_tab = new Hashtable();
            key_vlaue_tab.put("groupNo", 2);
            iterator = blueList.iterator();

            while(iterator.hasNext()) {
                repKey = (String)iterator.next();
                key_vlaue_tab.put(getEquipmentKeyByName(repKey), getMaxValueByChineseName(repKey, eq_attrib, eqType == 3, false));
            }

            appraisalList.add(key_vlaue_tab);
        } else if (1 == appraisalType) {
            key_vlaue_tab = baseBlueSuit(eqType, eq_attrib);
            blueList = randomAttribute((String[])key_vlaue_tab.get(eqType), (new Random()).nextInt(3) + 1);
            key_vlaue_tab = new Hashtable();
            key_vlaue_tab.put("groupNo", 2);
            iterator = blueList.iterator();

            while(iterator.hasNext()) {
                repKey = (String)iterator.next();
                key_vlaue_tab.put(getEquipmentKeyByName(repKey), getValueByChineseName(repKey, eq_attrib, eqType == 3, false));
            }

            appraisalList.add(key_vlaue_tab);
        } else {
            String name;
            List greenAttribute;
            if (2 == appraisalType) {
                Random random = new Random();
                key_vlaue_tab = baseBlueSuit(eqType, eq_attrib);
                greenAttribute = randomAttribute((String[])key_vlaue_tab.get(eqType), random.nextInt(2) + 2);
                key_vlaue_tab = new Hashtable();
                Iterator var25 = greenAttribute.iterator();

                while(var25.hasNext()) {
                    name = (String)var25.next();
                    key_vlaue_tab.put("groupNo", 2);
                    key_vlaue_tab.put(getEquipmentKeyByName(name), getValueByChineseName(name, eq_attrib, eqType == 3, false));
                }

                appraisalList.add(key_vlaue_tab);
                Hashtable<Integer, String[]> pink_hashtable = pinkSuit(eqType, eq_attrib);
                List<String> pinkList = randomAttribute((String[])pink_hashtable.get(eqType), 2);
                if (pinkList.size() == 2) {
                    Hashtable<String, Integer> key_vlaue_pTab = new Hashtable();
                    key_vlaue_pTab.put("groupNo", 3);
                    key_vlaue_pTab.put(getEquipmentKeyByName((String)pinkList.get(0)), getValueByChineseName((String)pinkList.get(0), eq_attrib, eqType == 3, false));
                    appraisalList.add(key_vlaue_pTab);
                    if (random.nextInt(10) <= 7) {
                        Hashtable<String, Integer> key_vlaue_yTab = new Hashtable();
                        key_vlaue_yTab.put("groupNo", 4);
                        key_vlaue_yTab.put(getEquipmentKeyByName((String)pinkList.get(1)), getValueByChineseName((String)pinkList.get(1), eq_attrib, eqType == 3, false));
                        appraisalList.add(key_vlaue_yTab);
                    }
                }
            } else {
                String[] attributes;
                ArrayList resultList;
                String[] arrayLeave;
                List pinkList;
                Hashtable key_vlaue_pTab;
                if (3 != appraisalType && 4 != appraisalType) {
                    if (9 == appraisalType) {
                        key_vlaue_tab = baseBlueSuit(eqType, eq_attrib);
                        attributes = (String[])key_vlaue_tab.get(eqType);
                        resultList = new ArrayList(attributes.length);
                        Collections.addAll(resultList, attributes);
                        if (null != repeatAttributes && !repeatAttributes.isEmpty()) {
                            iterator = repeatAttributes.iterator();

                            while(iterator.hasNext()) {
                                repKey = (String)iterator.next();
                                name = getEquipmentKeyByName(repKey, false);
                                if (resultList.contains(name)) {
                                    resultList.remove(name);
                                }
                            }
                        }

                        arrayLeave = (String[])resultList.toArray(new String[resultList.size()]);
                        pinkList = randomAttribute(arrayLeave, 1);
                        key_vlaue_pTab = new Hashtable();
                        key_vlaue_pTab.put("groupNo", 2);
                        key_vlaue_pTab.put(getEquipmentKeyByName((String)pinkList.get(0)), getValueByChineseName((String)pinkList.get(0), eq_attrib, eqType == 3, false));
                        appraisalList.add(key_vlaue_pTab);
                    } else if (5 == appraisalType) {
                        key_vlaue_tab = randomGreenSuit(polar);
                        attributes = (String[])key_vlaue_tab.get(eqType);
                        greenAttribute = randomAttribute(attributes, 1);
                        key_vlaue_tab = new Hashtable();
                        key_vlaue_tab.put("groupNo", 12);
                        key_vlaue_tab.put(getEquipmentKeyByName((String)greenAttribute.get(0)), getValueByChineseName((String)greenAttribute.get(0), eq_attrib, eqType == 3, true));
                        appraisalList.add(key_vlaue_tab);
                        repKey = getEquipmentKeyByName(baseGreenSuit(polar));
                        key_vlaue_pTab = new Hashtable();
                        key_vlaue_pTab.put("groupNo", 8);
                        key_vlaue_pTab.put(repKey, getValueByChineseName(baseGreenSuit(polar), eq_attrib, eqType == 3, true));
                        appraisalList.add(key_vlaue_pTab);
                    } else if (6 == appraisalType) {
                        String keyName1 = "防御";
                        String keyName2 = "防御";
                        if (eqType == 1) {
                            keyName1 = "物伤";
                            keyName2 = "法伤";
                        }

                        key_vlaue_tab = new Hashtable();
                        key_vlaue_tab.put("groupNo", 10);
                        key_vlaue_tab.put(getEquipmentKeyByName(keyName1), getMaxValueByChineseName(keyName1, eq_attrib, eqType == 3, true) * 2 / 12 * color);
                        key_vlaue_tab.put(getEquipmentKeyByName(keyName2), getMaxValueByChineseName(keyName2, eq_attrib, eqType == 3, true) * 2 / 12 * color);
                        appraisalList.add(key_vlaue_tab);
                    } else if (7 == appraisalType) {
                        key_vlaue_tab = new Hashtable();
                        key_vlaue_tab.put("groupNo", 10);
                        if ((eqType == 2 || eqType == 10 || eqType == 3) && eq_attrib >= 100) {
                            key_vlaue_tab.put(getEquipmentKeyByName("气血"), getMaxValueByChineseName("气血", eq_attrib, eqType == 3, true) * 2 / 12 * color);
                        } else if (eqType == 1) {
                            key_vlaue_tab.put(getEquipmentKeyByName("所有属性"), getMaxValueByChineseName("所有属性", eq_attrib, eqType == 3, true) * 2 / 12 * color);
                        }

                        appraisalList.add(key_vlaue_tab);
                    } else if (8 == appraisalType) {
                  greenAttribute = randomAttribute(resonanceBlueSuit(), 1);
                        key_vlaue_tab = new Hashtable();
                        key_vlaue_tab.put("groupNo", 27);
                        key_vlaue_tab.put(getEquipmentKeyByName((String)greenAttribute.get(0)), getMaxValueByChineseName((String)greenAttribute.get(0), eq_attrib, eqType == 3, true) * 2 / 12 * color);
                        appraisalList.add(key_vlaue_tab);
                    }
                } else {
                    key_vlaue_tab = pinkSuit(eqType, eq_attrib);
                    attributes = (String[])key_vlaue_tab.get(eqType);
                    resultList = new ArrayList(attributes.length);
                    Collections.addAll(resultList, attributes);
                    if (null != repeatAttributes && !repeatAttributes.isEmpty()) {
                        iterator = repeatAttributes.iterator();

                        while(iterator.hasNext()) {
                            repKey = (String)iterator.next();
                            name = getEquipmentKeyByName(repKey, false);
                            if (resultList.contains(name)) {
                                resultList.remove(name);
                            }
                        }
                    }

                    arrayLeave = (String[])resultList.toArray(new String[resultList.size()]);
                    pinkList = randomAttribute(arrayLeave, 1);
                    key_vlaue_pTab = new Hashtable();
                    key_vlaue_pTab.put("groupNo", 3 == appraisalType ? 3 : 4);
                    key_vlaue_pTab.put(getEquipmentKeyByName((String)pinkList.get(0)), getValueByChineseName((String)pinkList.get(0), eq_attrib, eqType == 3, false));
                    appraisalList.add(key_vlaue_pTab);
                }
            }
        }

        return appraisalList;
    }

    private static List<String> randomAttribute(String[] pinkAttributes, int count) {
        int length = pinkAttributes.length;
        Random random = new Random();
        ArrayList list = new ArrayList();

        while(list.size() < count) {
            int i = random.nextInt(length);
            if (!list.contains(i)) {
                list.add(i);
            }
        }

        List<String> attributes = new ArrayList();
        Iterator var7 = list.iterator();

        while(var7.hasNext()) {
            Integer index = (Integer)var7.next();
            attributes.add(pinkAttributes[index]);
        }

        return attributes;
    }

    public static Hashtable<Integer, String[]> baseBlueSuit(int eqType, int eq_attrib) {
        String[] pinkAttribute_1 = new String[]{"力量", "灵力", "敏捷", "体质", "伤害_最低伤害", "所有技能上升", "所有相性", "金相性", "木相性", "水相性", "火相性", "土相性", "物理必杀率", "物理连击率", "反击率", "忽视所有抗异常", "忽视所有抗性"};
        String[] pinkAttribute_2 = new String[]{"力量", "灵力", "敏捷", "体质", "所有属性", "物理连击次数", "气血", "法力", "防御", "反震度", "反击次数"};
        String[] pinkAttribute_10 = new String[]{"力量", "灵力", "敏捷", "体质", "所有属性", "物理连击次数", "防御", "反震度", "反击次数"};
        String[] pinkAttribute_3 = new String[]{"力量", "灵力", "敏捷", "体质", "所有属性", "气血", "法力", "防御", "反震率", "反震度", "反击次数", "反击率", "抗中毒", "抗冰冻", "抗昏睡", "抗遗忘", "抗混乱", "金抗性", "木抗性", "水抗性", "火抗性", "土抗性", "所有抗异常", "所有抗性"};
        String[] pinkAttribute_4 = new String[]{"力量", "灵力", "敏捷", "体质", "所有相性", "抗中毒", "抗冰冻", "抗昏睡", "抗遗忘", "抗混乱", "所有抗异常", "所有技能上升"};
        String[] pinkAttribute_5 = new String[]{"力量", "灵力", "敏捷", "体质", "所有相性", "抗中毒", "抗冰冻", "抗昏睡", "抗遗忘", "抗混乱", "所有抗异常", "所有技能上升"};
        String[] pinkAttribute_6 = new String[]{"力量", "灵力", "敏捷", "体质", "所有相性", "所有技能上升", "忽视目标抗中毒", "忽视目标抗冰冻", "忽视目标抗昏睡", "忽视目标抗混乱", "忽视目标抗遗忘", "忽视目标抗金", "忽视目标抗木", "忽视目标抗水", "忽视目标抗火", "忽视目标抗土", "忽视所有抗异常"};
        Hashtable<Integer, String[]> hashtable = new Hashtable();
        hashtable.put(1, pinkAttribute_1);
        hashtable.put(2, pinkAttribute_2);
        hashtable.put(10, pinkAttribute_10);
        hashtable.put(3, pinkAttribute_3);
        hashtable.put(4, pinkAttribute_4);
        hashtable.put(5, pinkAttribute_5);
        hashtable.put(6, pinkAttribute_6);
        return hashtable;
    }

    public void remakeBlueSuit(int eqType, int color, int eq_attrib) {
        if (eqType == 1) {
            if (color == 1) {
                getEquipmentKeyByName("物伤");
            } else if (color == 5) {
                getEquipmentKeyByName("所有属性");
            }
        } else if (color == 1) {
            getEquipmentKeyByName("防御");
        } else if (color == 5 && eq_attrib >= 100) {
            getEquipmentKeyByName("气血");
        }

    }

    public static String[] resonanceBlueSuit() {
        String[] resonanceAttribute = new String[]{"物理必杀率", "物伤", "法伤", "法伤", "气血", "防御", "速度", "物伤", "力量", "灵力", "敏捷", "体质", "抗中毒", "抗冰冻", "抗昏睡", "抗遗忘", "抗混乱", "金抗性", "木抗性", "水抗性", "火抗性", "土抗性", "所有技能上升", "物理连击率", "反击率", "物理必杀率", "强力克金", "强力克木", "强力克水", "强力克火", "强力克土", "反击次数", "反震度", "反震率", "几率解除混乱状态", "几率解除昏睡状态", "几率解除冰冻状态", "几率解除中毒状态", "几率解除遗忘状态", "法攻技能消耗降低", "障碍技能消耗降低", "辅助技能消耗降低"};
        return resonanceAttribute;
    }

    public static Hashtable<Integer, String[]> pinkSuit(int eqType, int eq_attrib) {
        String[] pinkAttribute_1 = new String[]{"力量", "灵力", "敏捷", "体质", "伤害_最低伤害", "所有技能上升", "所有相性", "金相性", "木相性", "水相性", "火相性", "土相性", "物理必杀率", "物理连击率", "反击率", "忽视所有抗异常", "忽视所有抗性"};
        String[] pinkAttribute_2 = new String[]{"力量", "灵力", "敏捷", "体质", "所有属性", "物理连击次数", "气血", "法力", "防御", "反震度", "反击次数"};
        String[] pinkAttribute_10 = new String[]{"力量", "灵力", "敏捷", "体质", "所有属性", "物理连击次数", "防御", "反震度", "反击次数", "速度"};
        String[] pinkAttribute_3 = new String[]{"力量", "灵力", "敏捷", "体质", "所有属性", "气血", "法力", "防御", "反震率", "反震度", "反击次数", "反击率", "抗中毒", "抗冰冻", "抗昏睡", "抗遗忘", "抗混乱", "金抗性", "木抗性", "水抗性", "火抗性", "土抗性", "所有抗异常", "所有抗性"};
        Hashtable<Integer, String[]> hashtable = new Hashtable();
        hashtable.put(1, pinkAttribute_1);
        hashtable.put(2, pinkAttribute_2);
        hashtable.put(10, pinkAttribute_10);
        hashtable.put(3, pinkAttribute_3);
        return hashtable;
    }

    public static String baseGreenSuit(int resist_polar) {
        String[] baseAttribute = new String[]{"法伤", "气血", "防御", "速度", "物伤"};
        return baseAttribute[resist_polar - 1];
    }

    public static Hashtable<Integer, String[]> randomGreenSuit(int resist_polar) {
        String[] strList = new String[]{"强金法伤害", "强木法伤害", "强水法伤害", "强火法伤害", "强土法伤害"};
        String[] strList2 = new String[]{"强力遗忘", "强力中毒", "强力冰冻", "强力昏睡", "强力混乱"};
        String[] strList3 = new String[]{"忽视目标抗中毒", "忽视目标抗冰冻", "忽视目标抗昏睡", "忽视目标抗混乱", "忽视目标抗遗忘"};
        String[] strList4 = new String[]{"忽视目标抗金", "忽视目标抗木", "忽视目标抗水", "忽视目标抗火", "忽视目标抗土"};
        String[] randomAttribute = new String[]{"强力克金", "强力克木", "强力克水", "强力克火", "强力克土", strList[resist_polar - 1], "强物理伤害", strList2[resist_polar - 1], strList4[resist_polar - 1], "几率解除混乱状态", "几率解除昏睡状态", "几率解除冰冻状态", "几率解除中毒状态", "几率解除遗忘状态", "忽视所有抗异常", "忽视所有抗性", strList3[resist_polar - 1]};
        String[] randomAttributeNoEq = new String[]{"抗中毒", "抗冰冻", "抗昏睡", "抗遗忘", "抗混乱", "几率解除混乱状态", "几率解除昏睡状态", "几率解除冰冻状态", "几率解除中毒状态", "几率解除遗忘状态"};
        String[] randomAttributeNoH = new String[]{"法攻技能消耗降低", "障碍技能消耗降低", "辅助技能消耗降低"};
        String[] randomAttributeNoEq2 = new String[]{"几率躲避攻击", "法攻技能消耗降低", "障碍技能消耗降低", "辅助技能消耗降低"};
        Hashtable<Integer, String[]> hashtable = new Hashtable();
        hashtable.put(1, randomAttribute);
        hashtable.put(2, randomAttributeNoH);
        hashtable.put(10, randomAttributeNoEq2);
        hashtable.put(3, randomAttributeNoEq);
        return hashtable;
    }

    public static String getEquipmentKeyByName(String chineseName) {
        return getEquipmentKeyByName(chineseName, true);
    }

    public static String getEquipmentKeyByName(String chineseName, boolean isName) {
        Hashtable<String, String> hashtable = new Hashtable();
        hashtable.put("法伤", "mana");
        hashtable.put("气血", "def");
        hashtable.put("防御", "wiz");
        hashtable.put("速度", "parry");
        hashtable.put("物伤", "accurate");
        hashtable.put("法力", "dex");
        hashtable.put("抗中毒", "resist_frozen");
        hashtable.put("抗冰冻", "resist_sleep");
        hashtable.put("抗昏睡", "resist_forgotten");
        hashtable.put("抗遗忘", "resist_confusion");
        hashtable.put("抗混乱", "longevity");
        hashtable.put("金抗性", "resist_wood");
        hashtable.put("木抗性", "resist_water");
        hashtable.put("水抗性", "resist_fire");
        hashtable.put("火抗性", "resist_earth");
        hashtable.put("土抗性", "exp_to_next_level");
        hashtable.put("强力克金", "super_excluse_wood");
        hashtable.put("强力克木", "super_excluse_water");
        hashtable.put("强力克水", "super_excluse_fire");
        hashtable.put("强力克火", "super_excluse_earth");
        hashtable.put("强力克土", "B_skill_low_cost");
        hashtable.put("强金法伤害", "enhanced_wood");
        hashtable.put("强木法伤害", "enhanced_water");
        hashtable.put("强水法伤害", "enhanced_fire");
        hashtable.put("强火法伤害", "enhanced_earth");
        hashtable.put("强土法伤害", "mag_dodge");
        hashtable.put("强物理伤害", "ignore_mag_dodge");
        hashtable.put("几率躲避攻击", "jinguang_zhaxian_counter_att_rate");
        hashtable.put("法攻技能消耗降低", "C_skill_low_cost");
        hashtable.put("障碍技能消耗降低", "D_skill_low_cost");
        hashtable.put("辅助技能消耗降低", "super_poison");
        hashtable.put("忽视目标抗金", "ignore_resist_wood");
        hashtable.put("忽视目标抗木", "ignore_resist_water");
        hashtable.put("忽视目标抗水", "ignore_resist_fire");
        hashtable.put("忽视目标抗火", "ignore_resist_earth");
        hashtable.put("忽视目标抗土", "ignore_resist_forgotten");
        hashtable.put("伤害_最低伤害", "skill_low_cost");//power
        hashtable.put("金相性", "wood");
        hashtable.put("木相性", "water");
        hashtable.put("水相性", "fire");
        hashtable.put("火相性", "earth");
        hashtable.put("土相性", "resist_metal");
        hashtable.put("灵力", "mag_power");
        hashtable.put("力量", "phy_power");
        hashtable.put("敏捷", "speed");
        hashtable.put("体质", "life");
        hashtable.put("忽视所有抗性", "ignore_all_resist_except");
        hashtable.put("所有技能上升", "mstunt_rate");
        hashtable.put("忽视所有抗异常", "release_forgotten");
        hashtable.put("物理必杀率", "damage_sel");
        hashtable.put("物理连击率", "stunt_rate");
        hashtable.put("反击率", "double_hit_rate");
        hashtable.put("物理连击次数", "stunt");
        hashtable.put("反击次数", "life_recover");
        hashtable.put("反震率", "portrait");
        hashtable.put("反震度", "family");
        hashtable.put("所有抗性", "all_resist_except");
        hashtable.put("所有相性", "all_resist_polar");
        hashtable.put("所有属性", "all_polar");
        hashtable.put("所有抗异常", "all_skill");
        hashtable.put("几率解除混乱状态", "tao_ex");
        hashtable.put("几率解除昏睡状态", "release_confusion");
        hashtable.put("几率解除冰冻状态", "release_sleep");
        hashtable.put("几率解除中毒状态", "release_frozen");
        hashtable.put("几率解除遗忘状态", "release_poison");
        hashtable.put("忽视目标抗中毒", "ignore_resist_frozen");
        hashtable.put("忽视目标抗冰冻", "ignore_resist_sleep");
        hashtable.put("忽视目标抗昏睡", "ignore_resist_confusion");
        hashtable.put("忽视目标抗混乱", "super_excluse_metal");
        hashtable.put("忽视目标抗遗忘", "ignore_resist_poison");
        hashtable.put("强力遗忘", "super_confusion");
        hashtable.put("强力中毒", "super_sleep");
        hashtable.put("强力冰冻", "enhanced_metal");
        hashtable.put("强力昏睡", "super_forgotten");
        hashtable.put("强力混乱", "super_frozen");
        if (isName) {
            return !hashtable.containsKey(chineseName) ? chineseName + "中文 No Find" : (String)hashtable.get(chineseName);
        } else if (!hashtable.containsValue(chineseName)) {
            return chineseName + "英文 No Find";
        } else {
            String key = null;
            Iterator var4 = hashtable.keySet().iterator();

            while(var4.hasNext()) {
                String getKey = (String)var4.next();
                if (((String)hashtable.get(getKey)).equals(chineseName)) {
                    key = getKey;
                }
            }

            return key;
        }
    }

    private static boolean contains(String[] values, String name) {
        List<String> resultList = new ArrayList(values.length);
        Collections.addAll(resultList, values);
        return resultList.contains(name);
    }

    public static int peekValue(int skill) {
        if (skill < 10) {
            return skill / 2;
        } else if (skill < 50) {
            return (int)((double)skill / 2.4D);
        } else {
            Random random = new Random();
            int skillCount;
            int r;
            if (skill < 100) {
                skillCount = skill / 10;
                r = random.nextInt(skillCount);
                if (r < skillCount / 2) {
                    r = skillCount / 2;
                }

                return r * 10 + random.nextInt(9);
            } else if (skill <= 1000) {
                skillCount = skill / 100;
                r = random.nextInt(skillCount);
                if (r < skillCount / 2) {
                    r = skillCount / 2;
                }

                return r * 100 + random.nextInt(9) * 10;
            } else {
                skillCount = skill / 100;
                r = random.nextInt(skillCount);
                if (r < skillCount / 2) {
                    r = skillCount / 2;
                }

                return r * 100 + random.nextInt(9) * 10;
            }
        }
    }

    private static int getValueByChineseName(String name, int eq_attrib, boolean isClothes, boolean green) {
        int skill;
        if ("伤害_最低伤害".contentEquals(name)) {
            skill = maxSkill_Low_Cost(eq_attrib);
            return peekValue(skill);
        } else if ("物伤#气血#法力#速度#法伤#防御".contains(name)) {
            skill = getMaxValueGiven(name, eq_attrib, isClothes, green);
            return peekValue(skill);
        } else if ("所有属性".contentEquals(name)) {
            return getProbabilityValue(1, eq_attrib / 5);
        } else {
            String[] valuel_t = new String[]{"力量", "灵力", "敏捷", "体质"};
            if (contains(valuel_t, name)) {
                return maxSpeed(eq_attrib) <= 2 ? maxSpeed(eq_attrib) : getProbabilityValue(maxSpeed(eq_attrib) / 2, maxSpeed(eq_attrib));
            } else {
                String[] value10_30 = new String[]{"几率躲避攻击", "忽视目标抗金", "忽视目标抗木", "忽视目标抗水", "忽视目标抗火", "忽视目标抗土", "物理必杀率", "物理连击率", "反击率", "反震率", "反震度", "忽视目标抗中毒", "忽视目标抗冰冻", "忽视目标抗昏睡", "忽视目标抗混乱", "忽视目标抗遗忘", "强力遗忘", "强力中毒", "强力冰冻", "强力昏睡", "强力混乱"};
                if (contains(value10_30, name)) {
                    return getProbabilityValue(10, 30);
                } else {
                    String[] value5_20 = new String[]{"抗中毒", "抗冰冻", "抗昏睡", "抗遗忘", "抗混乱", "强力克金", "强力克木", "强力克水", "强力克火", "强力克土", "忽视所有抗异常"};
                    if (contains(value5_20, name)) {
                        return getProbabilityValue(5, 20);
                    } else {
                        String[] value5_15 = new String[]{"金抗性", "木抗性", "水抗性", "火抗性", "土抗性", "所有抗异常", "几率解除混乱状态", "几率解除昏睡状态", "几率解除冰冻状态", "几率解除中毒状态", "几率解除遗忘状态"};
                        if (contains(value5_15, name)) {
                            return getProbabilityValue(5, 15);
                        } else {
                            String[] value3_10 = new String[]{"强金法伤害", "强木法伤害", "强水法伤害", "强火法伤害", "强土法伤害", "强物理伤害", "法攻技能消耗降低", "障碍技能消耗降低", "辅助技能消耗降低", "忽视所有抗性", "所有抗性", "反击次数"};
                            if (contains(value3_10, name)) {
                                return getProbabilityValue(3, 10);
                            } else {
                                String[] value1_5 = new String[]{"所有相性", "金相性", "木相性", "水相性", "火相性", "土相性"};
                                if (contains(value1_5, name)) {
                                    return getProbabilityValue(1, 5);
                                } else {
                                    String[] value1_10 = new String[]{"所有技能上升"};
                                    if (contains(value1_10, name)) {
                                        return getProbabilityValue(2, 10);
                                    } else {
                                        String[] value1_12 = new String[]{"物理连击次数"};
                                        return contains(value1_12, name) ? getProbabilityValue(2, 12) : 100;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public static int getMaxValueGiven(String name, int eq_attrib, boolean clothes, boolean green) {
        String[] bv = new String[]{"速度", "气血", "法力", "防御"};
        String[] gv = new String[]{"物伤", "气血", "速度", "法伤", "防御"};
        int point = 0;
        int i;
        if (green) {
            for(i = 0; i < gv.length; ++i) {
                if (gv[i].contentEquals(name)) {
                    point = i + 4;
                    break;
                }
            }
        } else {
            for(i = 0; i < bv.length; ++i) {
                if (bv[i].contentEquals(name)) {
                    point = i;
                    break;
                }
            }
        }

        int[] bgv_yf;
        int[] bgv;
        if (eq_attrib < 20) {
            bgv = new int[]{13, 45, 80, 15, 49, 211, 8, 28, 45};
            bgv_yf = new int[]{0, 85, 140, 30, 0, 0, 0, 0, 0};
            if (clothes) {
                bgv[1] = bgv_yf[1];
                bgv[2] = bgv_yf[2];
                bgv[3] = bgv_yf[3];
            }

            return bgv[point];
        } else if (eq_attrib >= 20 && eq_attrib < 30) {
            bgv = new int[]{26, 110, 180, 35, 113, 478, 16, 63, 102};
            bgv_yf = new int[]{0, 190, 320, 65, 0, 0, 0, 0, 0};
            if (clothes) {
                bgv[1] = bgv_yf[1];
                bgv[2] = bgv_yf[2];
                bgv[3] = bgv_yf[3];
            }

            return bgv[point];
        } else if (eq_attrib >= 30 && eq_attrib < 40) {
            bgv = new int[]{40, 190, 300, 55, 191, 806, 24, 107, 173};
            bgv_yf = new int[]{0, 320, 500, 110, 0, 0, 0, 0, 0};
            if (clothes) {
                bgv[1] = bgv_yf[1];
                bgv[2] = bgv_yf[2];
                bgv[3] = bgv_yf[3];
            }

            return bgv[point];
        } else if (eq_attrib >= 40 && eq_attrib < 50) {
            bgv = new int[]{50, 280, 460, 85, 191, 806, 24, 107, 173};
            bgv_yf = new int[]{0, 480, 800, 170, 0, 0, 0, 0, 0};
            if (clothes) {
                bgv[1] = bgv_yf[1];
                bgv[2] = bgv_yf[2];
                bgv[3] = bgv_yf[3];
            }

            return bgv[point];
        } else if (eq_attrib >= 50 && eq_attrib < 60) {
            bgv = new int[]{65, 380, 600, 120, 389, 1642, 41, 218, 354};
            bgv_yf = new int[]{0, 650, 1100, 240, 0, 0, 0, 0, 0};
            if (clothes) {
                bgv[1] = bgv_yf[1];
                bgv[2] = bgv_yf[2];
                bgv[3] = bgv_yf[3];
            }

            return bgv[point];
        } else if (eq_attrib >= 60 && eq_attrib < 70) {
            bgv = new int[]{80, 500, 800, 150, 509, 2149, 49, 286, 464};
            bgv_yf = new int[]{0, 850, 1400, 300, 0, 0, 0, 0, 0};
            if (clothes) {
                bgv[1] = bgv_yf[1];
                bgv[2] = bgv_yf[2];
                bgv[3] = bgv_yf[3];
            }

            return bgv[point];
        } else if (eq_attrib >= 70 && eq_attrib < 80) {
            bgv = new int[]{90, 600, 1000, 190, 644, 2717, 57, 362, 586};
            bgv_yf = new int[]{0, 1100, 1800, 380, 0, 0, 0, 0, 0};
            if (clothes) {
                bgv[1] = bgv_yf[1];
                bgv[2] = bgv_yf[2];
                bgv[3] = bgv_yf[3];
            }

            return bgv[point];
        } else if (eq_attrib >= 80 && eq_attrib < 90) {
            bgv = new int[]{100, 750, 1200, 240, 792, 3345, 65, 446, 722};
            bgv_yf = new int[]{0, 1300, 2200, 480, 0, 0, 0, 0, 0};
            if (clothes) {
                bgv[1] = bgv_yf[1];
                bgv[2] = bgv_yf[2];
                bgv[3] = bgv_yf[3];
            }

            return bgv[point];
        } else if (eq_attrib >= 90 && eq_attrib < 100) {
            bgv = new int[]{120, 950, 1500, 280, 956, 4033, 73, 537, 871};
            bgv_yf = new int[]{0, 1600, 2600, 550, 0, 0, 0, 0, 0};
            if (clothes) {
                bgv[1] = bgv_yf[1];
                bgv[2] = bgv_yf[2];
                bgv[3] = bgv_yf[3];
            }

            return bgv[point];
        } else if (eq_attrib >= 100 && eq_attrib < 110) {
            bgv = new int[]{130, 1300, 4400, 440, 1133, 4781, 82, 637, 1032};
            bgv_yf = new int[]{0, 2400, 7500, 850, 0, 0, 0, 0, 0};
            if (clothes) {
                bgv[1] = bgv_yf[1];
                bgv[2] = bgv_yf[2];
                bgv[3] = bgv_yf[3];
            }

            return bgv[point];
        } else if (eq_attrib >= 110 && eq_attrib < 120) {
            bgv = new int[]{140, 1600, 5000, 500, 1324, 5589, 90, 745, 1207};
            bgv_yf = new int[]{0, 2800, 9000, 1000, 0, 0, 0, 0, 0};
            if (clothes) {
                bgv[1] = bgv_yf[1];
                bgv[2] = bgv_yf[2];
                bgv[3] = bgv_yf[3];
            }

            return bgv[point];
        } else if (eq_attrib >= 120 && eq_attrib < 130) {
            bgv = new int[]{160, 1800, 5500, 550, 1530, 6457, 98, 861, 1395};
            bgv_yf = new int[]{0, 3200, 10000, 1100, 0, 0, 0, 0, 0};
            if (clothes) {
                bgv[1] = bgv_yf[1];
                bgv[2] = bgv_yf[2];
                bgv[3] = bgv_yf[3];
            }

            return bgv[point];
        } else if (eq_attrib >= 130) {
            bgv = new int[]{170, 2000, 6500, 650, 1750, 7386, 106, 984, 1595};
            bgv_yf = new int[]{0, 3600, 11000, 1300, 0, 0, 0, 0, 0};
            if (clothes) {
                bgv[1] = bgv_yf[1];
                bgv[2] = bgv_yf[2];
                bgv[3] = bgv_yf[3];
            }

            return bgv[point];
        } else {
            return 100;
        }
    }

    public static int getMaxValueByChineseName(String name, int eq_attrib, boolean isClothes) {
        return getMaxValueByChineseName(name, eq_attrib, isClothes, false);
    }

    public static int getMaxValueByChineseName(String name, int eq_attrib, boolean isClothes, boolean green) {
        if ("伤害_最低伤害".contentEquals(name)) {
            return maxSkill_Low_Cost(eq_attrib);
        } else if ("物伤#气血#法力#速度#法伤#防御".contains(name)) {
            return getMaxValueGiven(name, eq_attrib, isClothes, green);
        } else if ("所有属性".contentEquals(name)) {
            return eq_attrib / 5;
        } else {
            String[] valuel_t = new String[]{"力量", "灵力", "敏捷", "体质"};
            if (contains(valuel_t, name)) {
                return maxSpeed(eq_attrib);
            } else {
                String[] value10_30 = new String[]{"几率躲避攻击", "忽视目标抗金", "忽视目标抗木", "忽视目标抗水", "忽视目标抗火", "忽视目标抗土", "物理必杀率", "物理连击率", "反击率", "反震率", "反震度", "忽视目标抗中毒", "忽视目标抗冰冻", "忽视目标抗昏睡", "忽视目标抗混乱", "忽视目标抗遗忘", "强力遗忘", "强力中毒", "强力冰冻", "强力昏睡", "强力混乱"};
                if (contains(value10_30, name)) {
                    return 30;
                } else {
                    String[] value5_20 = new String[]{"抗中毒", "抗冰冻", "抗昏睡", "抗遗忘", "抗混乱", "强力克金", "强力克木", "强力克水", "强力克火", "强力克土", "忽视所有抗异常"};
                    if (contains(value5_20, name)) {
                        return 20;
                    } else {
                        String[] value5_15 = new String[]{"金抗性", "木抗性", "水抗性", "火抗性", "土抗性", "所有抗异常", "几率解除混乱状态", "几率解除昏睡状态", "几率解除冰冻状态", "几率解除中毒状态", "几率解除遗忘状态"};
                        if (contains(value5_15, name)) {
                            return 15;
                        } else {
                            String[] value3_10 = new String[]{"强金法伤害", "强木法伤害", "强水法伤害", "强火法伤害", "强土法伤害", "强物理伤害", "法攻技能消耗降低", "障碍技能消耗降低", "辅助技能消耗降低", "忽视所有抗性", "所有抗性", "反击次数"};
                            if (contains(value3_10, name)) {
                                return 10;
                            } else {
                                String[] value1_5 = new String[]{"所有相性", "金相性", "木相性", "水相性", "火相性", "土相性", "所有属性"};
                                if (contains(value1_5, name)) {
                                    return 5;
                                } else {
                                    String[] value1_10 = new String[]{"所有技能上升"};
                                    if (contains(value1_10, name)) {
                                        return 10;
                                    } else {
                                        String[] value1_12 = new String[]{"物理连击次数"};
                                        return contains(value1_12, name) ? 12 : 100;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public static int getProbabilityValue(int min, int max) {
        List<Integer> separates = new ArrayList();
        separates.add((max + min) / 2);
        separates.add(max - 1);
        List<Integer> percents = new ArrayList();
        percents.add(30);
        percents.add(68);
        percents.add(2);
        int number = RateRandomNumber.produceRateRandomNumber(min, max, separates, percents);
        return number;
    }

    public static int maxSkill_Low_Cost(int eq_attrib) {
        int[] maxValues = new int[]{37, 100, 240, 400, 600, 850, 1100, 1400, 1700, 2000, 2400, 2800, 3200};
        if (eq_attrib / 10 < 7) {
            return maxValues[eq_attrib / 10];
        } else {
            int leave = eq_attrib % 10 / 3;
            return maxValues[eq_attrib / 10] + leave * 100;
        }
    }

    public static int maxSpeed(int eq_attrib) {
        return eq_attrib / 4;
    }

    public static int maxDex(int eq_attrib) {
        return 100;
    }

    public static int maxDefWiz(int eq_attrib) {
        return 100;
    }

    public Hashtable<String, String> demonStoneSynthesis(int type) {
        int skill = type % 10;
        Hashtable<String, String> hashtable = new Hashtable();
        int silver_coin = 3000 + skill * 1000;
        int def = skill * skill * 100;
        int parry = skill * 32;
        int wiz = skill * skill * 30;
        int accurate = skill * skill * 66;
        int dex = skill * skill * 66;
        int[] manas = new int[]{0, 43, 174, 392, 696, 1089, 1568, 2134, 2787, 3528};
        if (skill > 9) {
            skill = 9;
        }

        int mana = manas[skill];
        hashtable.put("silver_coin", String.valueOf(silver_coin));
        hashtable.put("skill", String.valueOf(skill));
        hashtable.put("", String.valueOf(skill));
        int swType = type / 10;
        switch(swType) {
            case 10:
                hashtable.put("def", String.valueOf(def));
                hashtable.put("str", "凝香幻彩");
            case 11:
            case 13:
            case 15:
            case 17:
            case 19:
            default:
                break;
            case 12:
                hashtable.put("parry", String.valueOf(parry));
                hashtable.put("str", "炫影霜星");
                break;
            case 14:
                hashtable.put("wiz", String.valueOf(wiz));
                hashtable.put("str", "风寂云清");
                break;
            case 16:
                hashtable.put("accurate", String.valueOf(accurate));
                hashtable.put("str", "枯月流魂");
                break;
            case 18:
                hashtable.put("mana", String.valueOf(mana));
                hashtable.put("str", "雷极弧光");
                break;
            case 20:
                hashtable.put("dex", String.valueOf(dex));
                hashtable.put("str", "冰落残阳");
        }

        return hashtable;
    }

    public static int demonStoneValue(int type) {
        int skill = type % 10;
        int silver_coin = 3000 + skill * 1000;
        int def = skill * skill * 100;
        int parry = skill * 32;
        int wiz = skill * skill * 30;
        int accurate = skill * skill * 66;
        int dex = skill * skill * 66;
        int[] manas = new int[]{0, 43, 174, 392, 696, 1089, 1568, 2134, 2787, 3528};
        if (skill > 9) {
            skill = 9;
        }

        int mana = manas[skill];
        int swType = type / 10;
        switch(swType) {
            case 10:
                return def;
            case 11:
            case 13:
            case 15:
            case 17:
            case 19:
            default:
                return 100;
            case 12:
                return parry;
            case 14:
                return wiz;
            case 16:
                return accurate;
            case 18:
                return mana;
            case 20:
                return dex;
        }
    }
}
