package org.linlinjava.litemall.db.dao;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import org.linlinjava.litemall.db.domain.CharacterTitle;
import org.linlinjava.litemall.db.domain.example.CharacterTitleExample;

public interface CharacterTitleMapper {
    long countByExample(CharacterTitleExample example);

    int deleteByExample(CharacterTitleExample example);

    int deleteByPrimaryKey(Integer id);

    int insert(CharacterTitle record);

    int insertSelective(CharacterTitle record);

    List<CharacterTitle> selectByExample(CharacterTitleExample example);

    CharacterTitle selectByPrimaryKey(Integer id);

    int updateByExampleSelective(@Param("record") CharacterTitle record, @Param("example") CharacterTitleExample example);

    int updateByExample(@Param("record") CharacterTitle record, @Param("example") CharacterTitleExample example);

    int updateByPrimaryKeySelective(CharacterTitle record);

    int updateByPrimaryKey(CharacterTitle record);
}