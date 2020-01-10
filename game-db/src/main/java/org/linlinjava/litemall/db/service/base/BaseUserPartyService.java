package org.linlinjava.litemall.db.service.base;

import org.linlinjava.litemall.db.dao.UserPartyMapper;
import org.linlinjava.litemall.db.domain.Party;
import org.linlinjava.litemall.db.domain.UserParty;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

@Service
public class BaseUserPartyService {
    @Autowired
    protected UserPartyMapper mapper;

    @Cacheable(
            cacheNames = {"UserParty"},
            key = "#id"
    )
    public UserParty findById(int id) {
        return this.mapper.selectByPrimaryKey(id);
    }

    @Cacheable(
            cacheNames = {"UserParty"},
            key = "#id",
            condition = "#result.deleted == 0"
    )
    public UserParty findByIdContainsDelete(int id) {
        return this.mapper.selectByPrimaryKey(id);
    }

    public void add(UserParty item) {
        this.mapper.insertSelective(item);
    }

    @CachePut(
            cacheNames = {"UserParty"},
            key = "#UserParty.id"
    )
    public int updateById(UserParty item) {
        return this.mapper.updateByPrimaryKeySelective(item);
    }

    @CacheEvict(
            cacheNames = {"UserParty"},
            key = "#id"
    )
    public void deleteById(int id) {
        this.mapper.deleteByPrimaryKey(id);
    }

    public int insert(UserParty item){
        return this.mapper.insert(item);
    }
}
