package org.linlinjava.litemall.core.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * 日期格式化工具类
 */
public class DateTimeUtil {

    /**
     * 格式 yyyy年MM月dd日 HH:mm:ss
     *
     * @param dateTime
     * @return
     */
    public static String getDateTimeDisplayString(LocalDateTime dateTime) {
        return getDateTimeFormatterString(dateTime, "yyyy年MM月dd日 HH:mm:ss");
    }

    public static String getDateTimeFormatterString(LocalDateTime time, String format){
        DateTimeFormatter dtf2 = DateTimeFormatter.ofPattern(format);
        String strDate2 = dtf2.format(time);
        return strDate2;
    }
}
