package org.linlinjava.litemall.core.util;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * 日期格式化工具类
 */
public class DateTimeUtil {

    /**默认的日期格式*/
    public static final String DEFAULT_TIME_FORMAT = "yyyy年MM月dd日 HH:mm:ss";

    /**
     * 格式 yyyy年MM月dd日 HH:mm:ss
     *
     * @param dateTime
     * @return
     */
    public static String getDateTimeDisplayString(LocalDateTime dateTime) {
        return getDateTimeFormatterString(dateTime, DEFAULT_TIME_FORMAT);
    }

    public static String getDateTimeFormatterString(LocalDateTime time, String format){
        DateTimeFormatter dtf2 = DateTimeFormatter.ofPattern(format);
        String strDate2 = dtf2.format(time);
        return strDate2;
    }

    public static LocalDateTime getFormatDate(String dateStr, String format){
        DateTimeFormatter dtf2 = DateTimeFormatter.ofPattern(format);
        return LocalDateTime.parse(dateStr, dtf2);
    }

    public static LocalDateTime getDefaultFormatDate(String dateStr){
        return getFormatDate(dateStr, DEFAULT_TIME_FORMAT);
    }

}
