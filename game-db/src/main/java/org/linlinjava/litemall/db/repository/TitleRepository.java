package org.linlinjava.litemall.db.repository;

import com.google.common.collect.Lists;
import org.linlinjava.litemall.db.dao.CharacterTitleMapper;
import org.linlinjava.litemall.db.domain.CharacterTitle;
import org.linlinjava.litemall.db.domain.example.CharacterTitleExample;
import org.linlinjava.litemall.db.domain.vo.base.TitleVO;
import org.linlinjava.litemall.db.domain.vo.base.CharacterTitleVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.stream.Collectors;

@Repository
public class TitleRepository {
    @Autowired
    private CharacterTitleMapper characterTitleMapper;

    private CharacterTitleVO convert(CharacterTitle characterTitle) {
        return CharacterTitleVO.builder()
                .id(characterTitle.getId())
                .ownerUid(characterTitle.getOwnerUid())
                .type(characterTitle.getType())
                .addTime(LocalDateTime.ofInstant(characterTitle.getAddTime().toInstant(), ZoneId.systemDefault()))
                .deleted(characterTitle.getDeleted())
                .build();
    }

    public List<CharacterTitleVO> getTitleListByUid(int uid) {
        CharacterTitleExample example = new CharacterTitleExample();
        CharacterTitleExample.Criteria criteria = example.createCriteria();
        criteria.andOwnerUidEqualTo(uid);
        return characterTitleMapper.selectByExample(example).stream().map(this::convert).collect(Collectors.toList());
    }

    public boolean isUserContainTitle(int uid, int titleType) {
        return false;
    }

    public List<Integer> getUidListByTitleType(int titleType) {
        return Lists.newArrayList();
    }

    public boolean grantUserTitle(int uid, int titleType) {
        return false;
    }

    public boolean reclaimUserTitle(int uid, int titleType) {
        return false;
    }

    public TitleVO getTitleInfoByType(int type) {
        return null;
    }

    public List<TitleVO> getAllTitleTypeList() {
        return Lists.newArrayList();
    }

    public List<TitleVO> getTitleByColor(int color) {
        return Lists.newArrayList();
    }

    public List<TitleVO> getTitleByGender(int gender) {
        return Lists.newArrayList();
    }
}
