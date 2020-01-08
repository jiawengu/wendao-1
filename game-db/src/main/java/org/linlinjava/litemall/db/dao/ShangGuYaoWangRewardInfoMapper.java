package org.linlinjava.litemall.db.dao;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import org.linlinjava.litemall.db.domain.ShangGuYaoWangRewardInfo;
import org.linlinjava.litemall.db.domain.example.ShangGuYaoWangRewardInfoExample;

public interface ShangGuYaoWangRewardInfoMapper {
    long countByExample(ShangGuYaoWangRewardInfoExample example);

    int deleteByExample(ShangGuYaoWangRewardInfoExample example);

    int deleteByPrimaryKey(Integer id);

    int insert(ShangGuYaoWangRewardInfo record);

    int insertSelective(ShangGuYaoWangRewardInfo record);

    List<ShangGuYaoWangRewardInfo> selectByExample(ShangGuYaoWangRewardInfoExample example);

    ShangGuYaoWangRewardInfo selectByPrimaryKey(Integer id);

    int updateByExampleSelective(@Param("record") ShangGuYaoWangRewardInfo record, @Param("example") ShangGuYaoWangRewardInfoExample example);

    int updateByExample(@Param("record") ShangGuYaoWangRewardInfo record, @Param("example") ShangGuYaoWangRewardInfoExample example);

    int updateByPrimaryKeySelective(ShangGuYaoWangRewardInfo record);

    int updateByPrimaryKey(ShangGuYaoWangRewardInfo record);
}