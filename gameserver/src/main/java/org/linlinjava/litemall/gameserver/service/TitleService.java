package org.linlinjava.litemall.gameserver.service;

import com.google.common.collect.Lists;
import org.linlinjava.litemall.db.domain.vo.base.CharacterTitleVO;
import org.linlinjava.litemall.db.domain.vo.base.TitleVO;
import org.linlinjava.litemall.db.repository.TitleRepository;
import org.linlinjava.litemall.gameserver.domain.CharacterTitleDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class TitleService {
    @Autowired
    private TitleRepository titleRepository;

    private CharacterTitleDTO convert(TitleVO titleVO, CharacterTitleVO characterTitleVO) {
        return CharacterTitleDTO.builder()
                .color(titleVO.getColor())
                .title(titleVO.getTitle())
                .type(titleVO.getType())
                .gender(titleVO.getGender())
                .isOwned(characterTitleVO != null)
                .addTime(characterTitleVO != null ? characterTitleVO.getAddTime() : null)
                .build();
    }


    public List<CharacterTitleDTO> getTitleListByUid(int uid) {
        List<CharacterTitleVO> characterTitleVOList = titleRepository.getTitleListByUid(uid);
        List<TitleVO> titleVOList = titleRepository.getAllTitleTypeList();

        List<CharacterTitleDTO> characterTitleDTOList = Lists.newArrayList();
        for (TitleVO titleVO : titleVOList) {
            boolean flag = false;
            for (CharacterTitleVO characterTitleVO : characterTitleVOList) {
                if (characterTitleVO.getType().equals(titleVO.getType())) {
                    characterTitleDTOList.add(convert(titleVO, characterTitleVO));
                    flag = true;
                    break;
                }
            }
            if (!flag) {
                characterTitleDTOList.add(convert(titleVO, null));
            }
        }
        return characterTitleDTOList;
    }

    public boolean isUserContainTitle(int uid, int titleType) {
        return titleRepository.isUserContainTitle(uid, titleType);
    }

    public List<Integer> getUidListByTitleType(int titleType) {
        return titleRepository.getUidListByTitleType(titleType);
    }

    public boolean grantUserTitle(int uid, int titleType) {
        return titleRepository.grantUserTitle(uid, titleType);
    }

    public boolean reclaimUserTitle(int uid, int titleType) {
        return titleRepository.reclaimUserTitle(uid, titleType);
    }

    public CharacterTitleDTO getTitleInfoByType(int uid, int titleType) {
        TitleVO titleVO = titleRepository.getTitleInfoByType(titleType);
        if (titleVO == null) {
            return null;
        }
        CharacterTitleVO characterTitleVO = titleRepository.getCharacterTitleVO(uid, titleType);
        return convert(titleVO, characterTitleVO);
    }

    public List<CharacterTitleDTO> getTitleByColor(int uid, String color) {
        return getTitleListByUid(uid).stream()
                .filter(characterTitleDTO -> characterTitleDTO.getColor().equals(color))
                .collect(Collectors.toList());
    }

    public List<CharacterTitleDTO> getTitleByGender(int uid, int gender) {
        return getTitleListByUid(uid).stream()
                .filter(characterTitleDTO -> characterTitleDTO.getGender().equals(gender))
                .collect(Collectors.toList());
    }
}
