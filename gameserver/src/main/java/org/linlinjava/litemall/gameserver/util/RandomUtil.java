package org.linlinjava.litemall.gameserver.util;

import java.util.concurrent.ThreadLocalRandom;

/**
 */
public class RandomUtil {
    /**
     * 随机百分比概率是否成功
     * @param rate 百分比
     * @return
     */
    public static boolean checkSuccess(float rate){
        double randomNum = ThreadLocalRandom.current().nextInt(10000);
        randomNum = randomNum + 1;
        return rate * 10000 >= randomNum;
    }
}
