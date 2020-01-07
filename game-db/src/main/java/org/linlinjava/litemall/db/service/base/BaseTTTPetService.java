//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.service.base;

import com.github.pagehelper.PageHelper;
import org.linlinjava.litemall.db.dao.TTTPetMapper;
import org.linlinjava.litemall.db.domain.TTTPet;
import org.linlinjava.litemall.db.domain.TTTPetExample;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
public class BaseTTTPetService {
    @Autowired
    protected TTTPetMapper mapper;

    public BaseTTTPetService() {
    }


    public List<TTTPet> findByName(String name) {
        TTTPetExample example = new TTTPetExample();
        TTTPetExample.Criteria criteria = example.createCriteria();
        criteria.andDeletedEqualTo(false).andNameEqualTo(name);
        return this.mapper.selectByExample(example);
    }

    public TTTPet findOneByName(String name) {
        List<TTTPet> list = findByName(name);
        if(list.isEmpty()){
            return null;
        }
        return list.get(0);
    }

    public List<TTTPet> findAll(int page, int size, String sort, String order) {
        TTTPetExample example = new TTTPetExample();
        TTTPetExample.Criteria criteria = example.createCriteria();
        criteria.andDeletedEqualTo(false);
        if (!StringUtils.isEmpty(sort) && !StringUtils.isEmpty(order)) {
            example.setOrderByClause(sort + " " + order);
        }

        PageHelper.startPage(page, size);
        return this.mapper.selectByExample(example);
    }

    public List<TTTPet> findAll() {
        TTTPetExample example = new TTTPetExample();
        TTTPetExample.Criteria criteria = example.createCriteria();
        criteria.andDeletedEqualTo(false);
        return this.mapper.selectByExample(example);
    }
}
