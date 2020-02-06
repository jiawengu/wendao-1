//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.service.base;

import com.github.pagehelper.PageHelper;
import org.linlinjava.litemall.db.dao.PKRecordMapper;
import org.linlinjava.litemall.db.domain.PKRecord;
import org.linlinjava.litemall.db.domain.example.PKRecordExample;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;

@Service
public class BasePKRecordService {
    @Autowired
    protected PKRecordMapper mapper;

    public BasePKRecordService() {
    }

    @Cacheable(
            cacheNames = {"Npc"},
            key = "#id"
    )
    public PKRecord findById(int id) {
        return this.mapper.selectByPrimaryKey(id);
    }
//
//    @Cacheable(
//            cacheNames = {"PKRecord"},
//            key = "#id"
//    )
//    public PKRecord findByIdEx(int id) {
//        return this.mapper.selectByPrimaryKeyWithLogicalDelete(id, true);
//    }
//
//    @Cacheable(
//            cacheNames = {"PKRecord"},
//            key = "#id",
//            condition = "#result.deleted == 0"
//    )
//    public PKRecord findByIdContainsDelete(int id) {
//        return this.mapper.selectByPrimaryKey(id);
//    }

    public int add(PKRecord record) {
        Date date = new Date();
        SimpleDateFormat formatter= new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        record.setAddTime(formatter.format(date));
        record.setUpdateTime(formatter.format(date));
        return  this.mapper.insertSelective(record);
    }

    @CachePut(
            cacheNames = {"PKRecord"},
            key = "#PKRecord.id"
    )
    public int updateById(PKRecord record) {
        Date date = new Date();
        SimpleDateFormat formatter= new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        record.setUpdateTime(formatter.format(date));
        return this.mapper.updateByPrimaryKeySelective(record);
    }

//    @CacheEvict(
//            cacheNames = {"Npc"},
//            key = "#id"
//    )
//    public void deleteById(int id) {
//        this.mapper.logicalDeleteByPrimaryKey(id);
//    }
//
    public List<PKRecord> findByPKCharaIDAndBePKChardID(Integer pk_chara_id,Integer be_pk_chara_id) {
        PKRecordExample example = new PKRecordExample();
        PKRecordExample.Criteria criteria = example.createCriteria();
        criteria.andPkCharaIdEqualTo(pk_chara_id).andBePkCharaIdEqualTo(be_pk_chara_id);
        return this.mapper.selectByExample(example);
    }

    public PKRecord findOneByPKCharaIDAndBePKChardID(Integer pk_chara_id,Integer be_pk_chara_id) {
        PKRecordExample example = new PKRecordExample();
        PKRecordExample.Criteria criteria = example.createCriteria();
        criteria.andPkCharaIdEqualTo(pk_chara_id).andBePkCharaIdEqualTo(be_pk_chara_id);
        return this.mapper.selectOneByExample(example);
    }

    public List<PKRecord> findByPKCharaID(Integer pk_chara_id) {
        PKRecordExample example = new PKRecordExample();
        PKRecordExample.Criteria criteria = example.createCriteria();
        criteria.andPkCharaIdEqualTo(pk_chara_id);
        return this.mapper.selectByExample(example);
    }

    public List<PKRecord> findByBePKCharaID(Integer be_pk_chara_id) {
        PKRecordExample example = new PKRecordExample();
        PKRecordExample.Criteria criteria = example.createCriteria();
        criteria.andBePkCharaIdEqualTo(be_pk_chara_id);
        return this.mapper.selectByExample(example);
    }

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
//    public PKRecord findOneByNameEx(String name) {
//        PKRecord example = new NpcExample();
//        Criteria criteria = example.createCriteria();
//        criteria.andDeletedEqualTo(true).andNameEqualTo(name);
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
//    public Npc findOneById(Integer npcID) {
//        NpcExample example = new NpcExample();
//        Criteria criteria = example.createCriteria();
//        criteria.andDeletedEqualTo(true).andIdNotEqualTo(npcID);
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
//    public List<PKRecord> findAll() {
//        PKRecordExample example = new PKRecordExample();
//        Criteria criteria = example.createCriteria();
//        criteria.andDeletedEqualTo(false);
//        return this.mapper.selectByExample(example);
//    }
}
