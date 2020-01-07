package org.linlinjava.litemall.db.dao;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import org.linlinjava.litemall.db.domain.TTTPet;
import org.linlinjava.litemall.db.domain.TTTPetExample;

public interface TTTPetMapper {
    long countByExample(TTTPetExample example);

    int deleteByExample(TTTPetExample example);

    int deleteByPrimaryKey(Integer id);

    int insert(TTTPet record);

    int insertSelective(TTTPet record);

    List<TTTPet> selectByExample(TTTPetExample example);

    TTTPet selectByPrimaryKey(Integer id);

    int updateByExampleSelective(@Param("record") TTTPet record, @Param("example") TTTPetExample example);

    int updateByExample(@Param("record") TTTPet record, @Param("example") TTTPetExample example);

    int updateByPrimaryKeySelective(TTTPet record);

    int updateByPrimaryKey(TTTPet record);
}