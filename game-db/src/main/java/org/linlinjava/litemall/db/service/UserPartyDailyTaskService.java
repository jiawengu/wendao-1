package org.linlinjava.litemall.db.service;

import org.linlinjava.litemall.db.dao.UserPartyDailyTaskMapper;
import org.linlinjava.litemall.db.domain.Party;
import org.linlinjava.litemall.db.domain.PartyExample;
import org.linlinjava.litemall.db.domain.UserPartyDailyTask;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserPartyDailyTaskService {
    @Autowired
    public UserPartyDailyTaskMapper mapper;

    @Cacheable(
            cacheNames = {"UserPartyDailyTask"},
            key = "#id"
    )
    public UserPartyDailyTask findById(int id) {
        return this.mapper.selectByPrimaryKey(id);
    }

    @CachePut(
            cacheNames = {"UserPartyDailyTask"},
            key = "#id"
    )
    public int updateById(UserPartyDailyTask item) {
        return this.mapper.updateByPrimaryKey(item);
    }

    @CacheEvict(
            cacheNames = {"UserPartyDailyTask"},
            key = "#id"
    )
    public void deleteById(int id) {
        this.mapper.deleteByPrimaryKey(id);
    }

    public int insert(UserPartyDailyTask item){
        return this.mapper.insert(item);
    }
}
