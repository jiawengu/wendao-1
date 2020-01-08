//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.util;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationConfig;
import com.fasterxml.jackson.databind.SerializationFeature;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class JSONUtils {
    private static Logger log = LoggerFactory.getLogger(JSONUtils.class);
    private static final ThreadLocal<ObjectMapper> objectMapper = new ThreadLocal<ObjectMapper>() {
        @Override
        protected ObjectMapper initialValue() {
            ObjectMapper objectMapper = new ObjectMapper();
            objectMapper.configure(SerializationFeature.FAIL_ON_EMPTY_BEANS, false);
            objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
            return objectMapper;
        }
    };

    public JSONUtils() {
    }

    public static String toJSONString(Object data) {
        String str = null;

        try {
            str = objectMapper.get().writeValueAsString(data);
        } catch (Exception var3) {
            log.error("data: " + data, var3);
        }

        return str;
    }

    public static <T> T parseObject(String jsonData, Class<T> beanType) {
        try {
            T t = objectMapper.get().readValue(jsonData, beanType);
            return t;
        } catch (Exception var3) {
            log.error("data: " + jsonData, var3);
            return null;
        }
    }
}
