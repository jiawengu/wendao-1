package org.linlinjava.litemall.db.dao;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import org.linlinjava.litemall.db.domain.Chara_Statue;
import org.linlinjava.litemall.db.domain.Chara_StatueExample;

public interface Chara_StatueMapper {
    long countByExample(Chara_StatueExample example);

    int deleteByExample(Chara_StatueExample example);

    int deleteByPrimaryKey(Integer id);

    int insert(Chara_Statue record);

    int insertSelective(Chara_Statue record);

    List<Chara_Statue> selectByExampleWithBLOBs(Chara_StatueExample example);

    List<Chara_Statue> selectByExample(Chara_StatueExample example);

    Chara_Statue selectByPrimaryKey(Integer id);

    int updateByExampleSelective(@Param("record") Chara_Statue record, @Param("example") Chara_StatueExample example);

    int updateByExampleWithBLOBs(@Param("record") Chara_Statue record, @Param("example") Chara_StatueExample example);

    int updateByExample(@Param("record") Chara_Statue record, @Param("example") Chara_StatueExample example);

    int updateByPrimaryKeySelective(Chara_Statue record);

    int updateByPrimaryKeyWithBLOBs(Chara_Statue record);

    int updateByPrimaryKey(Chara_Statue record);
}