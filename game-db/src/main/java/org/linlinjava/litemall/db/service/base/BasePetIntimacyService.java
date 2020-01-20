//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.service.base;

import org.linlinjava.litemall.db.dao.T_Pet_INTIMACYMapper;
import org.linlinjava.litemall.db.domain.T_Pet_INTIMACY;
import org.linlinjava.litemall.db.domain.T_Pet_INTIMACYExample;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class BasePetIntimacyService {
    private static Map<String, List<T_Pet_INTIMACY>> cache = new HashMap<>();
    @Autowired
    protected T_Pet_INTIMACYMapper mapper;

    public BasePetIntimacyService() {
    }


    public void init(){
        for(T_Pet_INTIMACY t_pet_intimacy:findAll()){
            String[] petNames = t_pet_intimacy.getName().split(",");
            for(String petName : petNames){
                List<T_Pet_INTIMACY> list = cache.get(petName);
                if(null==list){
                    list = new ArrayList<>();
                    cache.put(petName, list);
                }
                list.add(t_pet_intimacy);
            }
        }
    }

    public static T_Pet_INTIMACY getT_Pet_INTIMACY(String petName, int intimacy){
        if(null==petName){
            return null;
        }
        List<T_Pet_INTIMACY> list = cache.get(petName);
        if(null == list){
            list = cache.get("默认");
            if(null == list){
                return null;
            }
        }
        for(T_Pet_INTIMACY t_Pet_INTIMACY:list){
            if(intimacy>t_Pet_INTIMACY.getIntimacyBegin()&&intimacy<=t_Pet_INTIMACY.getIntimacyEnd()){
                return t_Pet_INTIMACY;
            }
        }
        return null;
    }

    public List<T_Pet_INTIMACY> findAll() {
        T_Pet_INTIMACYExample example = new T_Pet_INTIMACYExample();
        T_Pet_INTIMACYExample.Criteria criteria = example.createCriteria();
        return this.mapper.selectByExample(example);
    }

}
