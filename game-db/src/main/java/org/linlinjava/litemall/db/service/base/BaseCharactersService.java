//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.service.base;

import com.github.pagehelper.PageHelper;
import java.time.LocalDateTime;
import java.util.Calendar;
import java.util.List;
import org.linlinjava.litemall.db.dao.CharactersMapper;
import org.linlinjava.litemall.db.domain.Characters;
import org.linlinjava.litemall.db.domain.example.CharactersExample;
import org.linlinjava.litemall.db.domain.example.CharactersExample.Criteria;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class BaseCharactersService {
    @Autowired
    protected CharactersMapper mapper;

    public BaseCharactersService() {
    }

    @Cacheable(
            cacheNames = {"Characters"},
            key = "#id"
    )
    public Characters findById(int id) {
        return this.mapper.selectByPrimaryKeyWithLogicalDelete(id, false);
    }

    @Cacheable(
            cacheNames = {"Characters"},
            key = "#id",
            condition = "#result.deleted == 0"
    )
    public Characters findByIdContainsDelete(int id) {
        return this.mapper.selectByPrimaryKey(id);
    }

    public void add(Characters characters) {
        characters.setAddTime(LocalDateTime.now());
        characters.setUpdateTime(LocalDateTime.now());
        this.mapper.insertSelective(characters);
    }

    @CachePut(
            cacheNames = {"Characters"},
            key = "#characters.id"
    )
    public int updateById(Characters characters) {
        characters.setUpdateTime(LocalDateTime.now());
        return this.mapper.updateByPrimaryKeySelective(characters);
    }

    /**
     * 修改玩家名字
     * @param characters
     * @param name
     */
    public void updateName(Characters characters, String name){
        characters.setName(name);
        mapper.updateByName(characters);
    }

    @CacheEvict(
            cacheNames = {"Characters"},
            key = "#id"
    )
    public void deleteById(int id) {
        this.mapper.logicalDeleteByPrimaryKey(id);
    }

    public List<Characters> findByAccountId(Integer accountId) {
        CharactersExample example = new CharactersExample();
        Criteria criteria = example.createCriteria();
        criteria.andDeletedEqualTo(false).andAccountIdEqualTo(accountId);
        return this.mapper.selectByExampleWithBLOBs(example);
    }

    public Characters findOneByName(String name) {
        CharactersExample example = new CharactersExample();
        Criteria criteria = example.createCriteria();
        criteria.andDeletedEqualTo(false).andNameEqualTo(name);
        return this.mapper.selectOneByExampleWithBLOBs(example);
    }

    public Characters findOneByAccountIdAndName(int accountId, String charName) {
        CharactersExample example = new CharactersExample();
        Criteria criteria = example.createCriteria();
        criteria.andDeletedEqualTo(false).andAccountIdEqualTo(accountId).andNameEqualTo(charName);
        return this.mapper.selectOneByExampleWithBLOBs(example);
    }

    public Characters finOnByGiD(String gid) {
        CharactersExample example = new CharactersExample();
        Criteria criteria = example.createCriteria();
        criteria.andDeletedEqualTo(false).andGidEqualTo(gid);
        return this.mapper.selectOneByExampleWithBLOBs(example);
    }

    public List<Characters> findAll() {
        CharactersExample example = new CharactersExample();
        Criteria criteria = example.createCriteria();
        criteria.andDeletedEqualTo(false);
        return this.mapper.selectByExampleWithBLOBs(example);
    }


}
