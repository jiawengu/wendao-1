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
import java.util.List;

@Service
public class BasePetIntimacyService {
    private static List<T_Pet_INTIMACY> cache = new ArrayList<>();
    @Autowired
    protected T_Pet_INTIMACYMapper mapper;

    public BasePetIntimacyService() {
    }


    public void init(){
        cache.addAll(findAll());
    }

    public static T_Pet_INTIMACY getT_Pet_INTIMACY(String petName, int intimacy){
        if(null==petName){
            return null;
        }
        for(T_Pet_INTIMACY t_Pet_INTIMACY:cache){
            if(petName.endsWith(t_Pet_INTIMACY.getName())&&intimacy>=t_Pet_INTIMACY.getIntimacyBegin()&&intimacy<=t_Pet_INTIMACY.getIntimacyEnd()){
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
