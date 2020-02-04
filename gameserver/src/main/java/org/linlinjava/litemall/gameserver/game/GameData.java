//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.game;

import javax.annotation.PostConstruct;

import org.linlinjava.litemall.db.service.PartyService;
import org.linlinjava.litemall.db.service.UserPartyDailyTaskService;
import org.linlinjava.litemall.db.service.CharacterService;
import org.linlinjava.litemall.db.service.SaleGoodService;
import org.linlinjava.litemall.db.service.base.*;
import org.linlinjava.litemall.db.util.RedisUtils;
import org.linlinjava.litemall.gameserver.data.xls_config.outdoorboss.OutdoorBossCfg;
import org.linlinjava.litemall.gameserver.data.xls_config.pirate.PirateCfg;
import org.linlinjava.litemall.gameserver.data.xls_config.superboss.SuperBossCfg;
import org.linlinjava.litemall.gameserver.job.RankJob;
import org.linlinjava.litemall.gameserver.service.BaseUserPartyShopService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

@Service
public class GameData {
    public static GameData that;
    @Qualifier("baseCharactersService")
    @Autowired
    public BaseCharactersService baseCharactersService;
    @Qualifier("baseCharaStatueService")
    @Autowired
    public BaseCharaStatueService baseCharaStatueService;
    @Qualifier("characterService")
    @Autowired
    public CharacterService characterService;
    @Autowired
    public BasePetService basePetService;
    @Autowired
    public BaseFightObjectService baseFightObjectService;
    @Autowired
    public BaseExperienceService baseExperienceService;
    @Autowired
    public BaseStoreInfoService baseStoreInfoService;
    @Autowired
    public BaseZhuangbeiInfoService baseZhuangbeiInfoService;
    @Autowired
    public BaseChoujiangService baseChoujiangService;
    @Autowired
    public BaseShowTasksService baseShowTasksService;
    @Autowired
    public BasePetHelpTypeService basePetHelpTypeService;
    @Autowired
    public BaseDaySignPrizeService baseDaySignPrizeService;
    @Qualifier("baseSaleGoodService")
    @Autowired
    public BaseSaleGoodService baseSaleGoodService;
    @Qualifier("saleGoodService")
    @Autowired
    public SaleGoodService saleGoodService;
    @Autowired
    public BaseNpcService baseNpcService;
    @Autowired
    public BaseShangGuYaoWangInfoService BaseShangGuYaoWangInfoService;
    @Autowired
    public BaseShangGuYaoWangRewardInfoService BaseShangGuYaoWangRewardInfoService;
    @Autowired
    public BaseMapService baseMapService;
    @Autowired
    public BaseAccountsService baseAccountsService;
    @Autowired
    public BaseNpcPointService baseNpcPointService;
    @Autowired
    public BaseNpcDialogueService baseNpcDialogueService;
    @Autowired
    public BaseNpcDialogueFrameService baseNpcDialogueFrameService;
    @Autowired
    public BaseCreepsStoreService baseCreepsStoreService;
    @Autowired
    public BaseGroceriesShopService baseGroceriesShopService;
    @Autowired
    public BaseMedicineShopService baseMedicineShopService;
    @Autowired
    public BaseSaleClassifyGoodService baseSaleClassifyGoodService;
    @Autowired
    public BaseStoreGoodsService baseStoreGoodsService;
    @Autowired
    public BaseShuxingduiyingService baseShuxingduiyingService;
    @Autowired
    public BasePackModificationService basePackModificationService;
    @Autowired
    public BaseSkillMonsterService baseSkillMonsterService;
    @Autowired
    public BaseRenwuService baseRenwuService;
    @Autowired
    public BaseRenwuMonsterService baseRenwuMonsterService;
    @Autowired
    public BaseExperienceTreasureService baseExperienceTreasureService;
    @Autowired
    public BaseNoticeService baseNoticeService;
    @Autowired
    public BaseChargeService baseChargeService;
    @Autowired
    public PartyService basePartyService;
    @Autowired
    public BaseUserPartyService baseUserPartyService;


    @Autowired
    public UserPartyDailyTaskService userPartyDailyTaskService;
    @Autowired
    public BaseUserPartyShopService baseUserPartyShopService;
    @Autowired
    public RedisUtils redisUtils;
    @Autowired
    public RankJob rankJob;


    @Autowired
    public SuperBossMng superBossMng;
    @Autowired
    public SuperBossCfg superBossCfg;
    @Autowired
    public OutdoorBossCfg outdoorBossCfg;
    @Autowired
    public OutdoorBossMng outdoorBossMng;
    @Autowired
    public PirateMng pirateMng;
    @Autowired
    public PirateCfg pirateCfg;

    public GameData() {
    }

    @PostConstruct
    public void initAfter() {
        that = this;
    }
}
