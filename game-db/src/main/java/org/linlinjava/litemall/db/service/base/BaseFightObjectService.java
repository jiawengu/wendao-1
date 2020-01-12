//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.service.base;

import com.github.pagehelper.PageHelper;
import org.linlinjava.litemall.db.dao.T_FightObjectMapper;
import org.linlinjava.litemall.db.domain.T_FightObject;
import org.linlinjava.litemall.db.domain.T_FightObjectExample;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
public class BaseFightObjectService {
    @Autowired
    protected T_FightObjectMapper mapper;

    public BaseFightObjectService() {
    }


    public List<T_FightObject> findByName(String name) {
        T_FightObjectExample example = new T_FightObjectExample();
        T_FightObjectExample.Criteria criteria = example.createCriteria();
        criteria.andDeletedEqualTo(false).andNameEqualTo(name);
        return this.mapper.selectByExample(example);
    }

    public T_FightObject findOneByName(String name) {
        List<T_FightObject> list = findByName(name);
        if(list.isEmpty()){
            return null;
        }
        return list.get(0);
    }

    public List<T_FightObject> findAll(int page, int size, String sort, String order) {
        T_FightObjectExample example = new T_FightObjectExample();
        T_FightObjectExample.Criteria criteria = example.createCriteria();
        criteria.andDeletedEqualTo(false);
        if (!StringUtils.isEmpty(sort) && !StringUtils.isEmpty(order)) {
            example.setOrderByClause(sort + " " + order);
        }

        PageHelper.startPage(page, size);
        return this.mapper.selectByExample(example);
    }

    public List<T_FightObject> findAll() {
        T_FightObjectExample example = new T_FightObjectExample();
        T_FightObjectExample.Criteria criteria = example.createCriteria();
        criteria.andDeletedEqualTo(false);
        return this.mapper.selectByExample(example);
    }
}
