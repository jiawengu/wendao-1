//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.job;

import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import org.linlinjava.litemall.db.domain.Notice;
import org.linlinjava.litemall.db.util.JSONUtils;
import org.linlinjava.litemall.gameserver.data.constant.TitleConst;
import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
import org.linlinjava.litemall.gameserver.data.write.M12285_1;
import org.linlinjava.litemall.gameserver.data.write.M16383_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.fight.FightContainer;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.game.*;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.linlinjava.litemall.gameserver.process.GameUtilRenWu;
import org.linlinjava.litemall.gameserver.service.TitleService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class SaveCharaTimes {
    private long gonggaotim = System.currentTimeMillis();
    private static final Logger log = LoggerFactory.getLogger(SaveCharaTimes.class);

    public SaveCharaTimes() {
    }

    @Scheduled(
            fixedDelay = 5000L
    )
    public void resetCompileTimes() {
        List<GameObjectChar> all = GameObjectCharMng.getAll();
        Iterator var2 = all.iterator();

        while(var2.hasNext()) {
            GameObjectChar gameSession = (GameObjectChar)var2.next();
            String data = gameSession.characters.getData();
            if(data != null) {
                Chara chara111 = JSONUtils.parseObject(data, Chara.class);
                if (chara111.level > gameSession.chara.level) {
                    log.error("人物等级{old}", chara111.name, chara111.level);
                    log.error("人物等级{new}", gameSession.chara.name, gameSession.chara.name);
                    log.error("人物队伍信息", gameSession.gameTeam.toString());
                    throw new RuntimeException("角色等级回档！！！");
                }
            }
            gameSession.characters.setData(JSONUtils.toJSONString(gameSession.chara));
            GameData.that.baseCharactersService.updateById(gameSession.characters);
        }

    }

//    @Scheduled(
//            fixedDelay = 10000L
//    )
//    public void onlines() {
//        log.error("online  : " + GameObjectCharMng.getAll().size());
//    }

    @Scheduled(
            fixedDelay = 2000L
    )
    public void autofight() {
        List<FightContainer> listFight = FightManager.listFight;
        long time = System.currentTimeMillis();
        Iterator var4 = listFight.iterator();

        while(var4.hasNext()) {
            FightContainer fightContainer = (FightContainer)var4.next();
            if (fightContainer.state.intValue() == 1 && fightContainer.roundTime + 1000L < time) {
                FightManager.doAutoSkill(fightContainer);
            }

            if (fightContainer.state.intValue() == 1 && fightContainer.roundTime + 24000L < time) {
                FightManager.doTimeupSkill(fightContainer);
            }
        }

    }

    @Scheduled(
            fixedRate = 2000L
    )
    public void autofightshuaguai() {
        long time = System.currentTimeMillis();
        if (GameLine.gameShuaGuai.shuaXing.size() < 8 && GameLine.gameShuaGuai.shuaXingTime + 180000L < time && GameLine.gameShuaGuai.shuaXingzhuangtai == 0) {
            GameShuaGuai.sendYaoYan(GameLine.gameShuaGuai);
            GameLine.gameShuaGuai.shuaXingTime = System.currentTimeMillis();
            GameLine.gameShuaGuai.shuaXingzhuangtai = 1;
        }

        if (GameShuaGuai.dengdaishuaXing.size() > 0 && GameLine.gameShuaGuai.shuaXingTime + 180000L < time && GameLine.gameShuaGuai.shuaXingzhuangtai == 1) {
            GameShuaGuai.sendshuaguai(GameLine.gameShuaGuai);
            GameLine.gameShuaGuai.shuaXingTime = System.currentTimeMillis();
            GameLine.gameShuaGuai.shuaXingzhuangtai = 2;
        }

        if (GameLine.gameShuaGuai.shuaXingzhuangtai == 2 && GameLine.gameShuaGuai.shuaXingTime + 180000L < time) {
            GameLine.gameShuaGuai.shuaXingzhuangtai = 0;
            GameLine.gameShuaGuai.shuaXingTime = System.currentTimeMillis();

            for(int i = 0; i < GameLine.gameShuaGuai.shuaXing.size(); ++i) {
                ((Vo_65529_0)GameLine.gameShuaGuai.shuaXing.get(i)).wanjiaid = 0;
            }
        }

    }

    @Scheduled(
            fixedRate = 10000L
    )
    public void autofightshidao() {
        String[] shidaolevel = new String[]{"试道场(60-79)", "试道场(80-89)", "试道场(90-99)", "试道场(100-109)", "试道场(110-119)", "试道场(120-129)"};
        long time = System.currentTimeMillis();
        Date date = new Date();
        String xingqi = GameUtilRenWu.dateToWeekday(date);
        String msg = "";
        int i;
        GameMap gameMap;
        if (xingqi.equals("周日") && GameUtilRenWu.belongCalendarshidao() && GameShiDao.statzhuangtai == 0) {
            msg = "试道即将开启，请找试道申请员；";
            GameShiDao.sendyaoyan1(msg);
            GameShiDao.statTime = System.currentTimeMillis();

            for(i = 0; i < shidaolevel.length; ++i) {
                gameMap = GameLine.getGameMap(1, shidaolevel[i]);
                if (gameMap.gameShiDao.shuaXingzhuangtai == 0) {
                    gameMap.gameShiDao.shuaXingTime = System.currentTimeMillis();
                }
            }

            GameShiDao.statzhuangtai = 1;
            GameShiDao.statTime = System.currentTimeMillis();
            msg = "试道即将开启，请找试道申请员；";
            GameShiDao.sendyaoyan1(msg);
        }

        if (GameShiDao.statzhuangtai == 1 && GameShiDao.statTime + 600000L < time) {
            msg = "试道大会已经开始";
            GameShiDao.sendyaoyan1(msg);

            for(i = 0; i < shidaolevel.length; ++i) {
                gameMap = GameLine.getGameMap(1, shidaolevel[i]);
                GameShiDao.sendYaoYan(gameMap.gameShiDao, gameMap);
                GameShiDao.sendshuaguai(gameMap.gameShiDao, gameMap);
                gameMap.gameShiDao.shuaXingTime = System.currentTimeMillis();
            }

            GameShiDao.statzhuangtai = 2;
            GameShiDao.statTime = System.currentTimeMillis();
        }

        if (GameShiDao.statzhuangtai == 2) {
            for(i = 0; i < shidaolevel.length; ++i) {
                gameMap = GameLine.getGameMap(1, shidaolevel[i]);
                if (gameMap.gameShiDao.shuaXingTime + 180000L < time) {
                    GameShiDao.sendYaoYan(gameMap.gameShiDao, gameMap);
                    GameShiDao.sendshuaguai(gameMap.gameShiDao, gameMap);
                    gameMap.gameShiDao.shuaXingTime = System.currentTimeMillis();
                }
            }
        }

        if (GameShiDao.statzhuangtai == 2 && GameShiDao.statTime + 1800000L < time) {
            GameShiDao.statzhuangtai = 3;
            GameShiDao.statTime = System.currentTimeMillis();

            for(i = 0; i < shidaolevel.length; ++i) {
                gameMap = GameLine.getGameMapname(1, shidaolevel[i]);

                for(int j = 0; j < gameMap.gameShiDao.shidaoyuanmo.size(); ++j) {
                    gameMap.send(new M12285_1(), ((Vo_65529_0)gameMap.gameShiDao.shidaoyuanmo.get(j)).id);
                }

                List<Chara> charas = new ArrayList();

                int j;
                Chara chara;
                for(j = 0; j < gameMap.sessionList.size(); ++j) {
                    chara = ((GameObjectChar)gameMap.sessionList.get(j)).chara;
                    chara.balance -= chara.level * 10000;
                    ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
                    GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    vo_20481_0.msg = "由于你在挑战元魔过程中取得了优异的成绩,因此获得了系统送出的" + chara.level * 10000 + "文钱的奖励。";
                    vo_20481_0.time = (int)(System.currentTimeMillis() / 1000L);
                    GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    if (chara.shidaodaguaijifen >= 10) {
                        vo_20481_0 = new Vo_20481_0();
                        vo_20481_0.msg = "由于你所在队伍的挑战元魔的积分充足,现在进入参加试道大会的巅峰对决阶段。";
                        vo_20481_0.time = (int)(System.currentTimeMillis() / 1000L);
                        GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    }
                }

                for(j = 0; j < charas.size(); ++j) {
                    GameUtilRenWu.shidaohuicheng((Chara)charas.get(j));
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    vo_20481_0.msg = "由于你所在队伍的挑战元魔的积分不足,无法参加试道大会的巅峰对\n决阶段。";
                    vo_20481_0.time = (int)(System.currentTimeMillis() / 1000L);
                    GameObjectCharMng.getGameObjectChar(((Chara)charas.get(j)).id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                }

                for(j = 0; j < gameMap.sessionList.size(); ++j) {
                    chara = ((GameObjectChar)gameMap.sessionList.get(j)).chara;
                    if (chara.shidaodaguaijifen > 30) {
                        chara.shidaodaguaijifen = 30;
                    }

                    chara.shidaocishu = chara.shidaodaguaijifen / 10;
                    chara.shidaodaguaijifen = 100;
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    vo_20481_0.msg = "当前积分" + chara.shidaodaguaijifen;
                    vo_20481_0.time = (int)(System.currentTimeMillis() / 1000L);
                    GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                }
            }

            GameShiDao.gonggaoTime = System.currentTimeMillis();
        }

        List gameSessions;
        String mas;
        int size;

        if (GameShiDao.statzhuangtai == 3 && GameShiDao.statTime + 9000000L < time) {
            GameShiDao.statzhuangtai = 0;

            for(i = 0; i < shidaolevel.length; ++i) {
                gameMap = GameLine.getGameMapname(1, shidaolevel[i]);
                gameSessions = insertionSort(gameMap.sessionList);
                mas = "";
                size = 0;
                List<Chara> charas = new ArrayList();

                for(int k = 0; k < gameSessions.size(); ++k) {
                    charas.add(((GameObjectChar)gameSessions.get(k)).chara);
                    if (!mas.equals(((Chara)((GameObjectChar)gameSessions.get(k)).gameTeam.duiwu.get(0)).name + ((Chara)((GameObjectChar)gameSessions.get(k)).gameTeam.duiwu.get(0)).shidaodaguaijifen)) {
                        mas = ((Chara)((GameObjectChar)gameSessions.get(k)).gameTeam.duiwu.get(0)).name + ((Chara)((GameObjectChar)gameSessions.get(k)).gameTeam.duiwu.get(0)).shidaodaguaijifen;
                        ++size;
                        Vo_20481_0 vo_20481_9;
                        ListVo_65527_0 listVo_65527_0;
                        if (size == 1) {
                            for(Chara chara : ((GameObjectChar) gameSessions.get(k)).gameTeam.duiwu) {
                                TitleService.grantTitle(GameObjectCharMng.getGameObjectChar(chara.id), TitleConst.TITLE_EVENT_WANGZHE, TitleConst.TITLE_WANGZHE);
                                chara.extra_life += 200000;
                                vo_20481_9 = new Vo_20481_0();
                                vo_20481_9.msg = "你获得了200000元宝的称谓。";
                                vo_20481_9.time = (int)(System.currentTimeMillis() / 1000L);
                                GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_9);
                                listVo_65527_0 = GameUtil.a65527(chara);
                                GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
                            }
                        }

                        if (size == 2) {
                            for(Chara chara : ((GameObjectChar) gameSessions.get(k)).gameTeam.duiwu) {
                                TitleService.grantTitle(GameObjectCharMng.getGameObjectChar(chara.id), TitleConst.TITLE_EVENT_YONGZHE, TitleConst.TITLE_YONGZHE);
                                chara.extra_life += 100000;
                                vo_20481_9 = new Vo_20481_0();
                                vo_20481_9.msg = "你获得了100000元宝的称谓。";
                                vo_20481_9.time = (int)(System.currentTimeMillis() / 1000L);
                                GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_9);
                                listVo_65527_0 = GameUtil.a65527(chara);
                                GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
                            }
                        }

                        if (size == 3) {
                            for(Chara chara : ((GameObjectChar) gameSessions.get(k)).gameTeam.duiwu) {
                                TitleService.grantTitle(GameObjectCharMng.getGameObjectChar(chara.id), TitleConst.TITLE_EVENT_YONGZHE, TitleConst.TITLE_YONGZHE);
                                chara.extra_life += 50000;
                                vo_20481_9 = new Vo_20481_0();
                                vo_20481_9.msg = "你获得了50000元宝的称谓。";
                                vo_20481_9.time = (int)(System.currentTimeMillis() / 1000L);
                                GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_9);
                                listVo_65527_0 = GameUtil.a65527(chara);
                                GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
                            }
                        }
                    }
                }

                for(int k = 0; k < charas.size(); ++k) {
                    GameUtilRenWu.shidaohuicheng((Chara)charas.get(k));
                }
            }
        }

        if (GameShiDao.statzhuangtai == 3 && GameShiDao.gonggaoTime + 30000L < time) {
            GameShiDao.gonggaoTime = System.currentTimeMillis();


            for(i = 0; i < shidaolevel.length; ++i) {
                gameMap = GameLine.getGameMapname(1, shidaolevel[i]);
                gameSessions = insertionSort(gameMap.sessionList);
                mas = "";
                size = 0;

                for(int j = 0; j < gameSessions.size(); ++j) {
                    String str = "";

                    for(int k = 0; k < ((GameObjectChar)gameSessions.get(j)).gameTeam.duiwu.size(); ++k) {
                        str = ((Chara)((GameObjectChar)gameSessions.get(j)).gameTeam.duiwu.get(0)).name + "的队伍积分" + ((Chara)((GameObjectChar)gameSessions.get(j)).gameTeam.duiwu.get(0)).shidaodaguaijifen + "           ";
                        if (mas.contains(str) && mas.equals("")) {
                            str = "";
                            break;
                        }
                    }

                    if (!str.equals("")) {
                        ++size;
                    }

                    if (size < 3) {
                        mas = mas + str;
                    }
                }

                Vo_16383_0 vo_16383_0 = new Vo_16383_0();
                vo_16383_0.channel = 19;
                vo_16383_0.id = 0;
                vo_16383_0.name = "";
                vo_16383_0.msg = "#Y" + mas;
                long times = System.currentTimeMillis() / 1000L;
                vo_16383_0.time = (int)times;
                vo_16383_0.privilege = 0;
                vo_16383_0.server_name = "涅槃重生22";
                vo_16383_0.show_extra = 2;
                vo_16383_0.compress = 0;
                vo_16383_0.orgLength = 65535;
                vo_16383_0.cardCount = 0;
                vo_16383_0.voiceTime = 0;
                vo_16383_0.token = "";
                vo_16383_0.checksum = 0;
                vo_16383_0.iid_str = "";
                vo_16383_0.has_break_lv_limit = 0;
                vo_16383_0.skill = 1;
                vo_16383_0.type = 1;
                gameMap.send(new M16383_0(), vo_16383_0);
            }

            for(i = 0; i < shidaolevel.length; ++i) {
                gameMap = GameLine.getGameMapname(1, shidaolevel[i]);
                gameSessions = insertionSort(gameMap.sessionList);
                mas = "";
                size = 0;

                for(int j = 0; j < gameSessions.size(); ++j) {
                    if (!mas.equals(((Chara)((GameObjectChar)gameSessions.get(j)).gameTeam.duiwu.get(0)).name + ((Chara)((GameObjectChar)gameSessions.get(j)).gameTeam.duiwu.get(0)).shidaodaguaijifen)) {
                        mas = ((Chara)((GameObjectChar)gameSessions.get(j)).gameTeam.duiwu.get(0)).name + ((Chara)((GameObjectChar)gameSessions.get(j)).gameTeam.duiwu.get(0)).shidaodaguaijifen;
                        ++size;
                    }
                }

                if (size == 1) {
                    int j = 0;
                    if (j < gameSessions.size()) {
                        for(Chara chara : ((GameObjectChar) gameSessions.get(j)).gameTeam.duiwu) {
                            TitleService.grantTitle(GameObjectCharMng.getGameObjectChar(chara.id), TitleConst.TITLE_EVENT_WANGZHE, TitleConst.TITLE_WANGZHE);
                            chara.extra_life += 200000;
                            Vo_20481_0 vo_20481_9 = new Vo_20481_0();
                            vo_20481_9.msg = "你获得了200000元宝的称谓。";
                            vo_20481_9.time = (int)(System.currentTimeMillis() / 1000L);
                            GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_9);
                            ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
                            GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
                            GameUtilRenWu.shidaohuicheng(chara);
                        }
                    }
                }
            }
        }

    }

    @Scheduled(
            fixedRate = 10000L
    )
    public void autofightgonggao() {
        long time = System.currentTimeMillis();
        List<Notice> all = GameData.that.baseNoticeService.findAll();

        for(int i = 0; i < all.size(); ++i) {
            if (this.gonggaotim + (long)(((Notice)all.get(i)).getTime() * '\uea60') < time) {
                Vo_16383_0 vo_16383_0 = new Vo_16383_0();
                vo_16383_0.channel = 19;
                vo_16383_0.id = 0;
                vo_16383_0.name = "";
                vo_16383_0.msg = ((Notice)all.get(i)).getMessage();
                long times = System.currentTimeMillis() / 1000L;
                vo_16383_0.time = (int)times;
                vo_16383_0.privilege = 0;
                vo_16383_0.server_name = "涅槃重生22";
                vo_16383_0.show_extra = 2;
                vo_16383_0.compress = 0;
                vo_16383_0.orgLength = 65535;
                vo_16383_0.cardCount = 0;
                vo_16383_0.voiceTime = 0;
                vo_16383_0.token = "";
                vo_16383_0.checksum = 0;
                vo_16383_0.iid_str = "";
                vo_16383_0.has_break_lv_limit = 0;
                vo_16383_0.skill = 1;
                vo_16383_0.type = 1;
                GameObjectCharMng.sendAll(new M16383_0(), vo_16383_0);
                this.gonggaotim = System.currentTimeMillis();
            }
        }

    }

    public static List<GameObjectChar> insertionSort(List<GameObjectChar> sessionList) {
        for(int i = 0; i < sessionList.size() - 1; ++i) {
            for(int j = i + 1; j > 0 && ((GameObjectChar)sessionList.get(j - 1)).chara.shidaodaguaijifen < ((GameObjectChar)sessionList.get(j)).chara.shidaodaguaijifen; --j) {
                GameObjectChar temp = (GameObjectChar)sessionList.get(j);
                sessionList.set(j, sessionList.get(j - 1));
                sessionList.set(j - 1, temp);
            }
        }

        return sessionList;
    }

    @Scheduled(
            fixedRate = 2000L
    )
    public void autofightromve() {
        List<GameObjectChar> sessionList = GameObjectCharMng.getGameObjectCharList();
        long time = System.currentTimeMillis();

        for(int i = 0; i < sessionList.size(); ++i) {
            try {
                if (((GameObjectChar)sessionList.get(i)).gameMap.id == 38004 && ((GameObjectChar)sessionList.get(i)).gameTeam == null) {
                    GameUtilRenWu.shidaohuicheng(((GameObjectChar)sessionList.get(i)).chara);
                }

                if (((GameObjectChar)sessionList.get(i)).heartEcho != 0L && ((GameObjectChar)sessionList.get(i)).heartEcho + 180000L < time) {
                    ((GameObjectChar)sessionList.get(i)).offline();
                    sessionList.remove(sessionList.get(i));
                }
            } catch (Exception var6) {
                log.error("", var6);
            }
        }

    }

    @Scheduled(
            fixedRate =  10000L
    )
    public void autoCheckPartyMgrSave(){
        if(GameCore.that != null && GameCore.that.partyMgr != null){
            GameCore.that.partyMgr.checkDirty();
        }
    }
}
