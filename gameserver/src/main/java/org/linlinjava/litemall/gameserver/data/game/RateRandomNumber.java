//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.data.game;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Random;

public class RateRandomNumber {
    public RateRandomNumber() {
    }

    public static int produceRandomNumber(int min, int max) {
        Random random = new Random();
        return random.nextInt(max - min + 1) + min;
    }

    public static int produceRateRandomNumber(int min, int max, List<Integer> separates, List<Integer> percents) {
        if (min > max) {
            throw new IllegalArgumentException("min值必须小于max值");
        } else if (separates != null && percents != null && separates.size() != 0) {
            if (separates.size() + 1 != percents.size()) {
                throw new IllegalArgumentException("分割数字的个数加1必须等于百分比个数");
            } else {
                int totalPercent = 0;

                Iterator var5;
                Integer p;
                for(var5 = percents.iterator(); var5.hasNext(); totalPercent += p) {
                    p = (Integer)var5.next();
                    if (p < 0 || p > 100) {
                        throw new IllegalArgumentException("百分比必须在[0,100]之间");
                    }
                }

                if (totalPercent != 100) {
                    throw new IllegalArgumentException("百分比之和必须为100");
                } else {
                    var5 = separates.iterator();

                    double s;
                    do {
                        if (!var5.hasNext()) {
                            int rangeCount = separates.size() + 1;
                            List<RateRandomNumber.Range> ranges = new ArrayList();
                            int scopeMax = 0;

                            int r;
                            for(r = 0; r < rangeCount; ++r) {
                                RateRandomNumber.Range range = new RateRandomNumber.Range();
                                range.min = r == 0 ? min : (Integer)separates.get(r - 1);
                                range.max = r == rangeCount - 1 ? max : (Integer)separates.get(r);
                                range.percent = (Integer)percents.get(r);
                                range.percentScopeMin = scopeMax + 1;
                                range.percentScopeMax = range.percentScopeMin + (range.percent - 1);
                                scopeMax = range.percentScopeMax;
                                ranges.add(range);
                            }

                            r = min;
                            Random random = new Random();
                            int randomInt = random.nextInt(100) + 1;

                            for(int i = 0; i < ranges.size(); ++i) {
                                RateRandomNumber.Range range = (RateRandomNumber.Range)ranges.get(i);
                                if (range.percentScopeMin <= randomInt && randomInt <= range.percentScopeMax) {
                                    r = produceRandomNumber(range.min, range.max);
                                    break;
                                }
                            }

                            return r;
                        }

                        s = (double)(Integer)var5.next();
                    } while(s > (double)min && s < (double)max);

                    throw new IllegalArgumentException("分割数值必须在(min,max)之间");
                }
            }
        } else {
            return produceRandomNumber(min, max);
        }
    }

    public static void main(String[] args) {
        List<Integer> separates = new ArrayList();
        separates.add(6);
        separates.add(7);
        List<Integer> percents = new ArrayList();
        percents.add(1);
        percents.add(98);
        percents.add(1);

        for(int i = 0; i < 100; ++i) {
            int number = produceRateRandomNumber(5, 20, separates, percents);
            System.out.println(number);
        }

    }

    public static class Range {
        public int min;
        public int max;
        public int percent;
        public int percentScopeMin;
        public int percentScopeMax;

        public Range() {
        }
    }
}
