//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.service;

import com.github.pagehelper.PageHelper;
import java.time.LocalDateTime;
import java.util.List;

import org.linlinjava.litemall.db.dao.PartyMapper;
import org.linlinjava.litemall.db.domain.Party;
import org.linlinjava.litemall.db.domain.PartyExample;
import org.linlinjava.litemall.db.domain.PartyExample.Criteria;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

@Service
public class PartyService {
    @Autowired
    protected PartyMapper mapper;

    public PartyService() {
    }

    @Cacheable(
            cacheNames = {"Party"},
            key = "#id"
    )
    public Party findById(int id) {
        return this.mapper.selectByPrimaryKey(id);
    }

    @Cacheable(
            cacheNames = {"Party"},
            key = "#id",
            condition = "#result.deleted == 0"
    )
    public Party findByIdContainsDelete(int id) {
        return this.mapper.selectByPrimaryKey(id);
    }

    public void add(Party party) {
        this.mapper.insertSelective(party);
    }

    @CachePut(
            cacheNames = {"Party"},
            key = "#party.id"
    )
    public int updateById(Party party) {
        return this.mapper.updateByPrimaryKeySelective(party);
    }

    @CacheEvict(
            cacheNames = {"Party"},
            key = "#id"
    )
    public void deleteById(int id) {
        this.mapper.deleteByPrimaryKey(id);
    }

    public List<Party> findByName(String name){
        PartyExample example = new PartyExample();
        Criteria criteria = example.createCriteria();
        criteria.andNameEqualTo(name);
        return this.mapper.selectByExample(example);
    }

    public int insert(Party party){
        return this.mapper.insert(party);
    }

    public List<Party> getAll(){
        return this.mapper.selectByExample(new PartyExample());
    }
}
