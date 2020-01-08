//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.service.base;

import org.linlinjava.litemall.db.dao.ShangGuYaoWangInfoMapper;
import org.linlinjava.litemall.db.domain.ShangGuYaoWangInfo;
import org.linlinjava.litemall.db.domain.example.ShangGuYaoWangInfoExample;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CachePut;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class BaseShangGuYaoWangInfoService {
    @Autowired
    protected ShangGuYaoWangInfoMapper mapper;

    public BaseShangGuYaoWangInfoService() {
    }

//    @Cacheable(
//            cacheNames = {"ShangGuYaoWangInfoMapper"},
//            key = "#id"
//    )
//    public ShangGuYaoWangInfoMapper findById(int id) {
//        return this.mapper.selectByPrimaryKeyWithLogicalDelete(id, false);
//    }
//
//    @Cacheable(
//            cacheNames = {"ShangGuYaoWangInfoMapper"},
//            key = "#id",
//            condition = "#result.deleted == 0"
//    )
//    public ShangGuYaoWangInfoMapper findByIdContainsDelete(int id) {
//        return this.mapper.selectByPrimaryKey(id);
//    }
//
//    public void add(ShangGuYaoWangInfoMapper yaoWangInfo) {
//        npc.setAddTime(LocalDateTime.now());
//        npc.setUpdateTime(LocalDateTime.now());
//        this.mapper.insertSelective(npc);
//    }

    @CachePut(
            cacheNames = {"ShangGuYaoWangInfo"},
            key = "#ShangGuYaoWangInfo.id"
    )
    public int updateById(ShangGuYaoWangInfo info) {
        return this.mapper.updateByPrimaryKeySelective(info);
    }

//    @CacheEvict(
//            cacheNames = {"Npc"},
//            key = "#id"
//    )
//    public void deleteById(int id) {
//        this.mapper.logicalDeleteByPrimaryKey(id);
//    }

    public ShangGuYaoWangInfo findByNpcID(Integer NpcID) {
        ShangGuYaoWangInfoExample example = new ShangGuYaoWangInfoExample();
        ShangGuYaoWangInfoExample.Criteria criteria = example.createCriteria();
        criteria.andNpcidEqualTo(NpcID);
        return this.mapper.selectOneByExample(example);
    }

    public ShangGuYaoWangInfo findByNpcID(Integer NpcID, boolean state) {
        ShangGuYaoWangInfoExample example = new ShangGuYaoWangInfoExample();
        ShangGuYaoWangInfoExample.Criteria criteria = example.createCriteria();
        criteria.andNpcidEqualTo(NpcID).andStateEqualTo(state);
        return this.mapper.selectOneByExample(example);
    }

    public List<ShangGuYaoWangInfo> findAllCloseState(){
        ShangGuYaoWangInfoExample example = new ShangGuYaoWangInfoExample();
        ShangGuYaoWangInfoExample.Criteria criteria = example.createCriteria();
        criteria.andStateEqualTo(false);
        return this.mapper.selectByExample(example);
    }

//    public List<Npc> findByX(Integer x) {
//        NpcExample example = new NpcExample();
//        Criteria criteria = example.createCriteria();
//        criteria.andDeletedEqualTo(false).andXEqualTo(x);
//        return this.mapper.selectByExample(example);
//    }
//
//    public List<Npc> findByY(Integer y) {
//        NpcExample example = new NpcExample();
//        Criteria criteria = example.createCriteria();
//        criteria.andDeletedEqualTo(false).andYEqualTo(y);
//        return this.mapper.selectByExample(example);
//    }
//
//    public List<Npc> findByName(String name) {
//        NpcExample example = new NpcExample();
//        Criteria criteria = example.createCriteria();
//        criteria.andDeletedEqualTo(false).andNameEqualTo(name);
//        return this.mapper.selectByExample(example);
//    }
//
//    public List<Npc> findByMapId(Integer mapId) {
//        NpcExample example = new NpcExample();
//        Criteria criteria = example.createCriteria();
//        criteria.andDeletedEqualTo(false).andMapIdEqualTo(mapId);
//        return this.mapper.selectByExample(example);
//    }
//
//    public Npc findOneByIcon(Integer icon) {
//        NpcExample example = new NpcExample();
//        Criteria criteria = example.createCriteria();
//        criteria.andDeletedEqualTo(false).andIconEqualTo(icon);
//        return this.mapper.selectOneByExample(example);
//    }
//
//    public Npc findOneByX(Integer x) {
//        NpcExample example = new NpcExample();
//        Criteria criteria = example.createCriteria();
//        criteria.andDeletedEqualTo(false).andXEqualTo(x);
//        return this.mapper.selectOneByExample(example);
//    }
//
//    public Npc findOneByY(Integer y) {
//        NpcExample example = new NpcExample();
//        Criteria criteria = example.createCriteria();
//        criteria.andDeletedEqualTo(false).andYEqualTo(y);
//        return this.mapper.selectOneByExample(example);
//    }
//
//    public Npc findOneByName(String name) {
//        NpcExample example = new NpcExample();
//        Criteria criteria = example.createCriteria();
//        criteria.andDeletedEqualTo(false).andNameEqualTo(name);
//        return this.mapper.selectOneByExample(example);
//    }
//
//    public Npc findOneByMapId(Integer mapId) {
//        NpcExample example = new NpcExample();
//        Criteria criteria = example.createCriteria();
//        criteria.andDeletedEqualTo(false).andMapIdEqualTo(mapId);
//        return this.mapper.selectOneByExample(example);
//    }
//
//    public List<Npc> findAll(int page, int size, String sort, String order) {
//        NpcExample example = new NpcExample();
//        Criteria criteria = example.createCriteria();
//        criteria.andDeletedEqualTo(false);
//        if (!StringUtils.isEmpty(sort) && !StringUtils.isEmpty(order)) {
//            example.setOrderByClause(sort + " " + order);
//        }
//
//        PageHelper.startPage(page, size);
//        return this.mapper.selectByExample(example);
//    }
//
//    public List<Npc> findAll() {
//        NpcExample example = new NpcExample();
//        Criteria criteria = example.createCriteria();
//        criteria.andDeletedEqualTo(false);
//        return this.mapper.selectByExample(example);
//    }
}
