//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.service.base;

import org.linlinjava.litemall.db.dao.LaoFangMapper;
import org.linlinjava.litemall.db.dao.PKRecordMapper;
import org.linlinjava.litemall.db.domain.LaoFang;
import org.linlinjava.litemall.db.domain.PKRecord;
import org.linlinjava.litemall.db.domain.example.LaoFangExample;
import org.linlinjava.litemall.db.domain.example.PKRecordExample;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@Service
public class BaseLaoFangService {
    @Autowired
    protected LaoFangMapper mapper;

    public BaseLaoFangService() {
    }

//    @Cacheable(
//            cacheNames = {"Npc"},
//            key = "#id"
//    )
//    public PKRecord findById(int id) {
//        return this.mapper.selectByPrimaryKeyWithLogicalDelete(id, false);
//    }
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

    public void add(LaoFang laoFang) {
        Date date = new Date();
        SimpleDateFormat formatter= new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        laoFang.setAddTime(formatter.format(date));
        laoFang.setUpdateTime(formatter.format(date));
        laoFang.setItime(0);
        laoFang.setDeleted(false);
        this.mapper.insert(laoFang);
    }

    public List<LaoFang> findAllLessThanTime() {
        LaoFangExample example = new LaoFangExample();
        LaoFangExample.Criteria criteria = example.createCriteria();
        criteria.andDeletedEqualTo(false).andItimeLessThan((int) (System.currentTimeMillis()/1000)+2 - 24*60*60);
        return this.mapper.selectByExample(example);
    }

    public List<LaoFang> findAllGreaterThanTime() {
        LaoFangExample example = new LaoFangExample();
        LaoFangExample.Criteria criteria = example.createCriteria();
        criteria.andDeletedEqualTo(false).andItimeGreaterThanOrEqualTo((int) (System.currentTimeMillis()/1000)+2 - 24*60*60);
        return this.mapper.selectByExample(example);
    }

    public List<LaoFang> findAll() {
        LaoFangExample example = new LaoFangExample();
        LaoFangExample.Criteria criteria = example.createCriteria();
        criteria.andDeletedEqualTo(false);
        return this.mapper.selectByExample(example);
    }

    @CacheEvict(
            cacheNames = {"LaoFang"},
            key = "#id"
    )
    public void deleteById(int id) {
        this.mapper.deleteByPrimaryKey(id);
    }

    @CachePut(
            cacheNames = {"LaoFang"},
            key = "#LaoFang.id"
    )
    public int updateById(LaoFang laoFang) {
        Date date = new Date();
        SimpleDateFormat formatter= new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        laoFang.setUpdateTime(formatter.format(date));
        //laoFang.setItime(0);
        //laoFang.setItime((int) (System.currentTimeMillis()/1000));
        return this.mapper.updateByPrimaryKeySelective(laoFang);
    }


    public LaoFang findOneByCharaID(Integer chara_id) {
        LaoFangExample example = new LaoFangExample();
        LaoFangExample.Criteria criteria = example.createCriteria();
        criteria.andDeletedEqualTo(false).andCharaIdEqualTo(chara_id);
        return this.mapper.selectOneByExample(example);
    }


//    @CacheEvict(
//            cacheNames = {"Npc"},
//            key = "#id"
//    )
//    public void deleteById(int id) {
//        this.mapper.logicalDeleteByPrimaryKey(id);
//    }
//
//    public List<PKRecord> findByPKCharaID(Integer pk_chara_id) {
//        PKRecordExample example = new PKRecordExample();
//        PKRecordExample.Criteria criteria = example.createCriteria();
//        criteria.andPkCharaIdEqualTo(pk_chara_id);
//        return this.mapper.selectByExample(example);
//    }
//
//    public List<PKRecord> findByBePKCharaID(Integer be_pk_chara_id) {
//        PKRecordExample example = new PKRecordExample();
//        PKRecordExample.Criteria criteria = example.createCriteria();
//        criteria.andBePkCharaIdEqualTo(be_pk_chara_id);
//        return this.mapper.selectByExample(example);
//    }

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


}
