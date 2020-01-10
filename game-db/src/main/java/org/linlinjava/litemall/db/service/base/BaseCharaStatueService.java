//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.service.base;

import org.linlinjava.litemall.db.dao.Chara_StatueMapper;
import org.linlinjava.litemall.db.domain.*;
import org.linlinjava.litemall.db.domain.example.DaySignPrizeExample;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CachePut;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;

@Service
public class BaseCharaStatueService {
    @Autowired
    protected Chara_StatueMapper mapper;

    public BaseCharaStatueService() {
    }

    public List<Chara_Statue> findAll(String serverId) {
        Chara_StatueExample example = new Chara_StatueExample();
        Chara_StatueExample.Criteria criteria = example.createCriteria();
        criteria.andDeletedEqualTo(false);
        criteria.andServeridEqualTo(serverId);
        return this.mapper.selectByExampleWithBLOBs(example);
    }

    public Chara_Statue findByName(String serverId, String npcName) {
        Chara_StatueExample example = new Chara_StatueExample();
        Chara_StatueExample.Criteria criteria = example.createCriteria();
        criteria.andDeletedEqualTo(false).andServeridEqualTo(serverId).andNpcNameEqualTo(npcName);
        List<Chara_Statue> list = this.mapper.selectByExample(example);
        assert list.size()<=1;
        if(list.isEmpty()){
            return null;
        }else{
            return list.get(0);
        }
    }

    public void insert(Chara_Statue chara_statue) {
        chara_statue.setAddTime(new Date());
        chara_statue.setUpdateTime(new Date());
        this.mapper.insertSelective(chara_statue);
    }

    @CachePut(
            cacheNames = {"CharaStatue"},
            key = "#chara_Statue.id"
    )
    public int updateById(Chara_Statue chara_statue) {
        chara_statue.setUpdateTime(new Date());
        return this.mapper.updateByPrimaryKeySelective(chara_statue);
    }
}
