package org.linlinjava.litemall.gameserver.job;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.google.common.collect.Lists;
import lombok.extern.slf4j.Slf4j;
import org.linlinjava.litemall.db.domain.Characters;
import org.linlinjava.litemall.db.service.CharacterService;
import org.linlinjava.litemall.db.util.JSONUtils;
import org.linlinjava.litemall.db.util.RedisUtils;
import org.linlinjava.litemall.gameserver.data.game.RankUtils;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.Rank;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Component
@Slf4j
public class RankJob {

    private final static String RANK_PREFIX = "rank_type:";


    private RedisUtils redisUtils;





    /**
     * 生成排行榜
     */
    @Scheduled(cron = "00 00 00/12 * * ?")
    public void generateRank() throws JsonProcessingException {
        CharacterService characterService = GameData.that.characterService;
        RedisUtils redisUtils = GameData.that.redisUtils;
        List<Characters> list = characterService.findAll();
        List<Chara> charaList = Lists.newArrayList();
        list.stream().forEach(characters -> {
            try {
                Chara chara = JSONUtils.parseObject(characters.getData(), Chara.class);
                charaList.add(chara);
            }catch (Exception e){
                log.error("Convert Chara Exception, exception = {}", e.getMessage());
            }
        });

        // 人物-等级排行 101
        List<Chara> levelCharaList = charaList.stream().sorted(Comparator.comparing(Chara::getLevel).reversed()).collect(Collectors.toList());
        List<Rank> levelCharaRankList = convertCharaRank(levelCharaList, 101, 0, 0);
        redisUtils.set(RANK_PREFIX + 101, levelCharaRankList);

        // 人物-道行排行 102 [RANK_TYPE.CHAR_TAO] = { "45-79", "80-89", "90-99", "100-109", "110-119", "120-129" },
        List<Chara> taoCharaList = charaList.stream().sorted(Comparator.comparing(Chara::getOwner_name).reversed()).collect(Collectors.toList());

        List<Chara> taoCharaList45_79 = taoCharaList.stream().filter(chara -> chara.getLevel() >= 45 && chara.getLevel()  <= 79).collect(Collectors.toList());
        List<Rank> taoCharaRankList45_79 = convertCharaRank(taoCharaList45_79, 102, 45, 79);
        redisUtils.set(RANK_PREFIX + 102 + ":" + 45 + "-" + 79, taoCharaRankList45_79);

        List<Chara> taoCharaList80_89 = taoCharaList.stream().filter(chara -> chara.getLevel() >= 80 && chara.getLevel()  <= 89).collect(Collectors.toList());
        List<Rank> taoCharaRankList80_89 = convertCharaRank(taoCharaList80_89, 102, 80, 89);
        redisUtils.set(RANK_PREFIX + 102 + ":" + 80 + "-" + 89, taoCharaRankList80_89);

        List<Chara> taoCharaList90_99 = taoCharaList.stream().filter(chara -> chara.getLevel() >= 90 && chara.getLevel()  <= 99).collect(Collectors.toList());
        List<Rank> taoCharaRankList90_99 = convertCharaRank(taoCharaList90_99, 102, 90, 99);
        redisUtils.set(RANK_PREFIX + 102 + ":" + 90 + "-" + 99, taoCharaRankList90_99);

        List<Chara> taoCharaList100_109 = taoCharaList.stream().filter(chara -> chara.getLevel() >= 100 && chara.getLevel()  <= 109).collect(Collectors.toList());
        List<Rank> taoCharaRankList100_109 = convertCharaRank(taoCharaList100_109, 102, 100, 109);
        redisUtils.set(RANK_PREFIX + 102 + ":" + 100 + "-" + 109, taoCharaRankList100_109);

        List<Chara> taoCharaList110_119 = taoCharaList.stream().filter(chara -> chara.getLevel() >= 110 && chara.getLevel()  <= 119).collect(Collectors.toList());
        List<Rank> taoCharaRankList110_119 = convertCharaRank(taoCharaList110_119, 102, 110, 119);
        redisUtils.set(RANK_PREFIX + 102 + ":" + 110 + "-" + 119, taoCharaRankList110_119);

        List<Chara> taoCharaList120_129 = taoCharaList.stream().filter(chara -> chara.getLevel() >= 120 && chara.getLevel()  <= 129).collect(Collectors.toList());
        List<Rank> taoCharaRankList120_129 = convertCharaRank(taoCharaList120_129, 102, 120, 129);
        redisUtils.set(RANK_PREFIX + 102 + ":" + 120 + "-" + 129, taoCharaRankList120_129);


        // 人物-物伤排行 103
        List<Chara> phyCharaList = charaList.stream().sorted(Comparator.comparing(Chara::getPhy_power).reversed()).collect(Collectors.toList());
        List<Rank> phyCharaRankList = convertCharaRank(phyCharaList, 103, 0, 0);
        redisUtils.set(RANK_PREFIX + 103, phyCharaRankList);

        // 人物-法伤排行 104
        List<Chara> magCharaList = charaList.stream().sorted(Comparator.comparing(Chara::getMag_power).reversed()).collect(Collectors.toList());
        List<Rank> magCharaRankList = convertCharaRank(magCharaList, 104, 0, 0);
        redisUtils.set(RANK_PREFIX + 104, magCharaRankList);

        // 人物-速度排行 105
        List<Chara> speedCharaList = charaList.stream().sorted(Comparator.comparing(Chara::getSpeed).reversed()).collect(Collectors.toList());
        List<Rank> speedCharaRankList = convertCharaRank(speedCharaList, 105, 0, 0);
        redisUtils.set(RANK_PREFIX + 105, speedCharaRankList);

        // 人物-速度排行 106
        List<Chara> defCharaList = charaList.stream().sorted(Comparator.comparing(Chara::getDef).reversed()).collect(Collectors.toList());
        List<Rank> defCharaRankList = convertCharaRank(defCharaList, 106, 0, 0);
        redisUtils.set(RANK_PREFIX + 106, defCharaRankList);

    }

    /**
     * 人物排行
     * @param list
     * @param type
     */
    private List<Rank> convertCharaRank(List<Chara> list, int type, int minLevel, int maxLevel){
        List<Rank> rankList = Lists.newLinkedList();
        int sortIdx = 0;
        for (Chara chara : list) {
            sortIdx ++;
            Rank rank = new Rank();
            rank.setUuid(chara.uuid);
            rank.setName(chara.name);
            rank.setLevel(chara.level);
            rank.setMenpai(chara.menpai);
            rank.setSortIdx(sortIdx);
            if(minLevel == 0 || maxLevel == 0){
                rank.setType(String.valueOf(type));
            }else{
                rank.setType(type + ":" + minLevel + "-" + maxLevel);
            }
            rank.setValue(RankUtils.getRankValue(chara, type));
            rank.setCreateTime(new Date());
            rankList.add(rank);
        }
        return rankList;
    }

}
