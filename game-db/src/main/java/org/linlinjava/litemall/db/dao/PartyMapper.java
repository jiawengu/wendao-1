package org.linlinjava.litemall.db.dao;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import org.linlinjava.litemall.db.domain.Party;
import org.linlinjava.litemall.db.domain.PartyExample;

public interface PartyMapper {
    long countByExample(PartyExample example);

    int deleteByExample(PartyExample example);

    int deleteByPrimaryKey(Integer id);

    int insert(Party record);

    int insertSelective(Party record);

    List<Party> selectByExample(PartyExample example);

    Party selectByPrimaryKey(Integer id);

    int updateByExampleSelective(@Param("record") Party record, @Param("example") PartyExample example);

    int updateByExample(@Param("record") Party record, @Param("example") PartyExample example);

    int updateByPrimaryKeySelective(Party record);

    int updateByPrimaryKey(Party record);
}