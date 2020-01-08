package org.linlinjava.litemall.db.dao;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import org.linlinjava.litemall.db.domain.T_FightObject;
import org.linlinjava.litemall.db.domain.T_FightObjectExample;

public interface T_FightObjectMapper {
    long countByExample(T_FightObjectExample example);

    int deleteByExample(T_FightObjectExample example);

    int deleteByPrimaryKey(Integer id);

    int insert(T_FightObject record);

    int insertSelective(T_FightObject record);

    List<T_FightObject> selectByExample(T_FightObjectExample example);

    T_FightObject selectByPrimaryKey(Integer id);

    int updateByExampleSelective(@Param("record") T_FightObject record, @Param("example") T_FightObjectExample example);

    int updateByExample(@Param("record") T_FightObject record, @Param("example") T_FightObjectExample example);

    int updateByPrimaryKeySelective(T_FightObject record);

    int updateByPrimaryKey(T_FightObject record);
}