package org.linlinjava.litemall.db.dao;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.db.domain.ShangGuYaoWangInfo;
import org.linlinjava.litemall.db.domain.example.NpcExample;
import org.linlinjava.litemall.db.domain.example.ShangGuYaoWangInfoExample;

public interface ShangGuYaoWangInfoMapper {
    long countByExample(ShangGuYaoWangInfoExample example);

    int deleteByExample(ShangGuYaoWangInfoExample example);

    int deleteByPrimaryKey(Integer id);

    int insert(ShangGuYaoWangInfo record);

    int insertSelective(ShangGuYaoWangInfo record);

    ShangGuYaoWangInfo selectOneByExample(ShangGuYaoWangInfoExample example);

    List<ShangGuYaoWangInfo> selectByExample(ShangGuYaoWangInfoExample example);

    ShangGuYaoWangInfo selectByPrimaryKey(Integer id);

    int updateByExampleSelective(@Param("record") ShangGuYaoWangInfo record, @Param("example") ShangGuYaoWangInfoExample example);

    int updateByExample(@Param("record") ShangGuYaoWangInfo record, @Param("example") ShangGuYaoWangInfoExample example);

    int updateByPrimaryKeySelective(ShangGuYaoWangInfo record);

    int updateByPrimaryKey(ShangGuYaoWangInfo record);
}