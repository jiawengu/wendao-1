package org.linlinjava.litemall.gameserver.service;

import org.linlinjava.litemall.gameserver.domain.Chara;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 * 跨天事件
 */
@Service
public class DayBreakService {
    private static final Logger logger = LoggerFactory.getLogger(DayBreakService.class);
    private static final Map<String, Handler> handlerMap = new HashMap<>();
    private static final long ONE_DAY_MILL = 24*3600*1000;
    static {
        registerHandler(new clock0Handler());
        registerHandler(new clock5Handler());
    }

    private static void registerHandler(Handler handler){
        assert !handlerMap.containsKey(handler.getKey());
        handlerMap.put(handler.getKey(), handler);
    }

    private static abstract class Handler{
        public abstract String getKey();
        public abstract void onDayBreak(Chara chara);
        public abstract long getTodayDayBreakMillTime();
    }

    public static void checkDayBreak(Chara chara){
        for(Iterator<Map.Entry<String, Long>> iter = chara.dayBreakTimeMap.entrySet().iterator();iter.hasNext();){
            Map.Entry<String, Long> entry = iter.next();
            String key = entry.getKey();
            Long lastClearTime = entry.getValue();

            if(null == lastClearTime){
                lastClearTime = 0L;
            }
            Handler handler = handlerMap.get(key);
            if(null == handler){
                logger.error("canot found handler!"+entry.getKey());
            }

            final long curMill = System.currentTimeMillis();
            final long todayDayBreak = handler.getTodayDayBreakMillTime();

            long shouldDayBreakTime = 0L;
            if(curMill<todayDayBreak){//今天还没到点
                shouldDayBreakTime = todayDayBreak-ONE_DAY_MILL;
            }else{//今天已经过点了
                shouldDayBreakTime = todayDayBreak;
            }

            if(lastClearTime<(shouldDayBreakTime)){
                chara.dayBreakTimeMap.put(key, shouldDayBreakTime);
                handler.onDayBreak(chara);
            }
        }
    }
    public static long getTodayHourMillTime(byte hour) {
        Calendar calendar = Calendar.getInstance();

        calendar.setTimeInMillis(System.currentTimeMillis());
        calendar.set(Calendar.HOUR_OF_DAY, hour);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        return calendar.getTimeInMillis();
    }
    /**
     * 凌晨0点
     */
    private static class clock0Handler extends Handler{

        @Override
        public String getKey() {
            return "clock0";
        }

        @Override
        public void onDayBreak(Chara chara) {
            logger.info(getClass()+"==>"+chara.name);
        }

        @Override
        public long getTodayDayBreakMillTime() {
            return getTodayHourMillTime((byte) 0);
        }
    }
    /**
     * 凌晨5点
     */
    private static class clock5Handler extends Handler{

        @Override
        public String getKey() {
            return "clock5";
        }

        @Override
        public void onDayBreak(Chara chara) {
            logger.info(getClass()+"==>"+chara.name);
            //通天塔
            chara.onTTTDayBreak();

            //挑战掌门
            chara.leaderTodayFailNum = 0;
        }

        @Override
        public long getTodayDayBreakMillTime() {
            return getTodayHourMillTime((byte) 5);
        }
    }



}
