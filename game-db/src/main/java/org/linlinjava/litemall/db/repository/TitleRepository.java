package org.linlinjava.litemall.db.repository;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.google.common.collect.Lists;
import org.apache.commons.io.FileUtils;
import org.linlinjava.litemall.db.dao.CharacterTitleMapper;
import org.linlinjava.litemall.db.domain.CharacterTitle;
import org.linlinjava.litemall.db.domain.example.CharacterTitleExample;
import org.linlinjava.litemall.db.domain.vo.base.TitleVO;
import org.linlinjava.litemall.db.domain.vo.base.CharacterTitleVO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.util.ResourceUtils;

import javax.annotation.PostConstruct;
import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Repository
public class TitleRepository {
    private final Logger logger = LoggerFactory.getLogger(TitleRepository.class);

    @Autowired
    private CharacterTitleMapper characterTitleMapper;

    private List<TitleVO> titleVOList;

    @PostConstruct
    private void init() {
        try {
            File jsonFile = ResourceUtils.getFile("classpath:data/title.json");
            String json = FileUtils.readFileToString(jsonFile, "UTF-8");
            titleVOList = JSON.parseObject(json, List.class);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

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

        return characterTitleMapper.selectByExample(example)
                .stream()
                .map(this::convert)
                .collect(Collectors.toList());
    }

    public CharacterTitleVO getCharacterTitleVO(int uid, int titleType) {
        CharacterTitleExample example = new CharacterTitleExample();
        CharacterTitleExample.Criteria criteria = example.createCriteria();
        criteria.andOwnerUidEqualTo(uid);
        criteria.andTypeEqualTo(titleType);

        return characterTitleMapper.selectByExample(example).stream().map(this::convert).findAny().get();
    }

    public boolean isUserContainTitle(int uid, int titleType) {
        CharacterTitleExample example = new CharacterTitleExample();
        CharacterTitleExample.Criteria criteria = example.createCriteria();
        criteria.andOwnerUidEqualTo(uid);
        criteria.andTypeEqualTo(titleType);

        return characterTitleMapper.countByExample(example) != 0;
    }

    public List<Integer> getUidListByTitleType(int titleType) {
        CharacterTitleExample example = new CharacterTitleExample();
        CharacterTitleExample.Criteria criteria = example.createCriteria();
        criteria.andTypeEqualTo(titleType);

        return characterTitleMapper.selectByExample(example)
                .stream()
                .map(CharacterTitle::getOwnerUid)
                .collect(Collectors.toList());
    }

    public boolean grantUserTitle(int uid, int titleType) {
        CharacterTitleExample example = new CharacterTitleExample();
        CharacterTitleExample.Criteria criteria = example.createCriteria();
        criteria.andOwnerUidEqualTo(uid);
        criteria.andTypeEqualTo(titleType);

        List<CharacterTitle> characterTitleList = characterTitleMapper.selectByExample(example);
        if (characterTitleList.size() != 0) {
            CharacterTitle characterTitle = characterTitleList.get(0);
            characterTitle.setDeleted(false);
            characterTitleMapper.updateByPrimaryKey(characterTitle);
        } else {
            CharacterTitle characterTitle = new CharacterTitle();
            characterTitle.setDeleted(false);
            characterTitle.setOwnerUid(uid);
            characterTitle.setType(titleType);
            characterTitle.setAddTime(new Date());
            characterTitleMapper.insert(characterTitle);
        }

        return false;
    }

    public boolean reclaimUserTitle(int uid, int titleType) {
        CharacterTitleExample example = new CharacterTitleExample();
        CharacterTitleExample.Criteria criteria = example.createCriteria();
        criteria.andOwnerUidEqualTo(uid);
        criteria.andTypeEqualTo(titleType);

        List<CharacterTitle> characterTitleList = characterTitleMapper.selectByExample(example);
        if (characterTitleList.size() != 0) {
            CharacterTitle characterTitle = characterTitleList.get(0);
            characterTitle.setDeleted(true);
            characterTitleMapper.updateByPrimaryKey(characterTitle);
            return true;
        }
        return false;
    }

    public TitleVO getTitleInfoByType(int titleType) {
        return titleVOList.stream()
                .filter(titleVO -> titleVO.getType().equals(titleType)).findAny().get();
    }

    public List<TitleVO> getAllTitleTypeList() {
        return titleVOList;
    }

    public List<TitleVO> getTitleByColor(String color) {
        return titleVOList.stream()
                .filter(titleVO -> titleVO.getColor().equals(color)).collect(Collectors.toList());
    }

    public List<TitleVO> getTitleByGender(int gender) {
        return titleVOList.stream()
                .filter(titleVO -> titleVO.getGender().equals(gender)).collect(Collectors.toList());
    }
}
