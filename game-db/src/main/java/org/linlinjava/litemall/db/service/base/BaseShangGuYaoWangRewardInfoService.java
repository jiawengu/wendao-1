//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.service.base;

import org.linlinjava.litemall.db.dao.ShangGuYaoWangInfoMapper;
import org.linlinjava.litemall.db.dao.ShangGuYaoWangRewardInfoMapper;
import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.db.domain.ShangGuYaoWangInfo;
import org.linlinjava.litemall.db.domain.ShangGuYaoWangRewardInfo;
import org.linlinjava.litemall.db.domain.example.ShangGuYaoWangInfoExample;
import org.linlinjava.litemall.db.domain.example.ShangGuYaoWangRewardInfoExample;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CachePut;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.Date;

@Service
public class BaseShangGuYaoWangRewardInfoService {
    @Autowired
    protected ShangGuYaoWangRewardInfoMapper mapper;

    public BaseShangGuYaoWangRewardInfoService() {
    }


    public void add(ShangGuYaoWangRewardInfo info) {

        Date date = new Date();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        info.setDate(sdf.format(date));

        SimpleDateFormat formatter= new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        info.setDateTime(formatter.format(date));
        this.mapper.insertSelective(info);
    }

    public  long count(int account_id, String  date){
        ShangGuYaoWangRewardInfoExample example = new ShangGuYaoWangRewardInfoExample();
        ShangGuYaoWangRewardInfoExample.Criteria criteria = example.createCriteria();
        criteria.andAccountIdEqualTo(account_id).andDateEqualTo(date);
        return this.mapper.countByExample(example);
    }

}
