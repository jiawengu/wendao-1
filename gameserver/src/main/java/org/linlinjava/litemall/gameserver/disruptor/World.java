package org.linlinjava.litemall.gameserver.disruptor;

import com.google.common.collect.Maps;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.util.Attribute;
import org.linlinjava.litemall.db.domain.Notice;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.constant.TitleConst;
import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_DISAPPEAR_Chara;
import org.linlinjava.litemall.gameserver.data.write.MSG_MESSAGE_EX;
import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.fight.FightContainer;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.game.*;
import org.linlinjava.litemall.gameserver.netty.NettyServer;
import org.linlinjava.litemall.gameserver.netty.ServerHandler;
import org.linlinjava.litemall.gameserver.process.*;
import org.linlinjava.litemall.gameserver.service.DBService;
import org.linlinjava.litemall.gameserver.service.TitleService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.*;



@Service
public class World {
    private static final Logger logger = LoggerFactory.getLogger(World.class);
    @Autowired
    private GameCore gameCore;
    @Value("${netty.port}")
    private int port;
    @Value("${netty.url}")
    private String url;
    @Autowired
    private DBService dbService;
    @Autowired
    private NettyServer server;
    @Autowired
    private java.util.List<GameHandler> gameHandlers;
    /**
     * 玩家消息处理器
     */
    private HashMap<Integer, GameHandler> gameHandlerHashMap;
    /**
     * 逻辑处理器
     */
    private Map<LogicEventType, LogicHandler> logicHandlers;
    private TriggerSystem triggerSystem = new TriggerSystem();
    private long gonggaotim = System.currentTimeMillis();

    public void initWhenThreadStart() {
        triggerSystem.addTimer(new Timer(1000, Integer.MAX_VALUE, this::onSecondTick) {});
        triggerSystem.addTimer(new Timer(2000, Integer.MAX_VALUE, this::on2SecondTick) {});
        triggerSystem.addTimer(new Timer(5000, Integer.MAX_VALUE, this::on5SecondTick) {});
        triggerSystem.addTimer(new Timer(10000, Integer.MAX_VALUE, this::on10SecondTick) {});

        registerLogicHandler();

        registerCmdHandler();

        java.net.InetSocketAddress address = new java.net.InetSocketAddress(this.url, this.port);
        logger.debug("run .... . ... " + this.url);
        this.server.start(address);

        this.gameCore.init(this.server);
    }

    private void registerCmdHandler(){
        gameHandlerHashMap = Maps.newHashMap();
        for (GameHandler gameHandler : gameHandlers) {
            gameHandlerHashMap.put(gameHandler.cmd(), gameHandler);
        }
    }

    private void registerLogicHandler(){
        EnumMap<LogicEventType, LogicHandler> logicHandlers = new EnumMap<LogicEventType, LogicHandler>(LogicEventType.class);
        {
            logicHandlers.put(LogicEventType.LOGIC_PLAYER_DISCONNECT, this::ON_LOGIC_PLAYER_DISCONNECT);
            logicHandlers.put(LogicEventType.LOGIC_PLAYER_CMD_REQUEST, this::ON_LOGIC_PLAYER_CMD_REQUEST);
            logicHandlers.put(LogicEventType.LOGIC_CLOSE_GAME, this::ON_LOGIC_CLOSE_GAME);
        }
        this.logicHandlers = Collections.unmodifiableMap(logicHandlers);
    }

    private void ON_LOGIC_PLAYER_DISCONNECT(LogicEvent logicEvent){
        int charaId = logicEvent.getIntParam();
        if(!GameObjectCharMng.isCharaCached(charaId)){
            return;
        }
        GameObjectChar gameObjectChar = GameObjectCharMng.getGameObjectChar(charaId);
        GameObjectCharMng.downline(gameObjectChar);
    }
    private void ON_LOGIC_CLOSE_GAME(LogicEvent logicEvent){
        closeServer();
    }
    private void ON_LOGIC_PLAYER_CMD_REQUEST(LogicEvent logicEvent){
        int cmd = logicEvent.getIntParam();
        ByteBuf buff = logicEvent.getByteBuf();
        ChannelHandlerContext context = logicEvent.getContext();

        Attribute<GameObjectChar> attr = context.channel().attr(ServerHandler.akey);
        GameObjectChar session = null;
        if ((attr != null) && (attr.get() != null)) {
            session = attr.get();
            GameObjectChar.GAMEOBJECTCHAR_THREAD_LOCAL.set(session);
        }

        GameHandler gameHandler = gameHandlerHashMap.getOrDefault(cmd, null);
        if (gameHandler != null) {
            try {
                long beginMill = System.currentTimeMillis();
                if(! (gameHandler instanceof CMD_ECHO || gameHandler instanceof CMD_MULTI_MOVE_TO || gameHandler instanceof CMD_HEART_BEAT)){//todo 打印消息
                    logger.info("recive msg!=>"+gameHandler);
                }
                gameHandler.process(context, buff);
                long cost = System.currentTimeMillis()-beginMill;
                if(cost>30){
                    logger.error(gameHandler+",cost==>"+cost);
                }
            } catch (Exception e) {
                logger.error(String.format("Fail to execute cmd: %d, buff: %s", cmd, buff), e);
            }
        } else {
            logger.debug(String.format("Cannot find a match cmd: %d, buff: %s", cmd, buff));
        }
    }

    public void tick() {
        triggerSystem.tickTrigger();
    }

    /**
     * 每秒执行
     */
    private final void onSecondTick(Timer timer){
        try {

        }catch (Exception e){
            logger.error("", e);
        }
    }
    /**
     * 每2秒执行
     */
    private final void on2SecondTick(Timer timer){
        try {
            autofight();
        }catch (Exception e){
            logger.error("", e);
        }
        try {
            autofightshuaguai();
        }catch (Exception e){
            logger.error("", e);
        }
        try {
            autofightromve();
        }catch (Exception e){
            logger.error("", e);
        }
    }
    private final void on5SecondTick(Timer timer){
        try {
            autoCheckPartyMgrSave();
        }catch (Exception e){
            logger.error("", e);
        }
        try {
            GameObjectCharMng.getGameObjectCharMap().forEach(item->{
                try {
                    if(item.logic!=null){
                        item.logic.cacheSave();
                    }
                }catch (Exception e) {
                    e.printStackTrace();
                }
            });
        }catch (Exception e){
            logger.error("", e);
        }
        try {
            Collection<GameObjectChar> all = GameObjectCharMng.getGameObjectCharMap();
            Iterator var2 = all.iterator();

            while(var2.hasNext()) {
                GameObjectChar gameSession = (GameObjectChar)var2.next();
                dbService.save(gameSession);
            }
        }catch (Exception e){
            logger.error("", e);
        }
    }
    public void autoCheckPartyMgrSave(){
        if(GameCore.that != null && GameCore.that.partyMgr != null){
            GameCore.that.partyMgr.checkDirty();
        }
    }
    /**
     * 每10秒执行
     */
    private final void on10SecondTick(Timer timer){
        try {
            autofightshidao();

            PKMgr.checkLaoFang();
        }catch (Exception e){
            logger.error("", e);
        }
        try {
            autofightgonggao();
        }catch (Exception e){
            logger.error("", e);
        }
    }

    public void onLogicEvent(LogicEvent event) {
        LogicHandler logicHandler = logicHandlers.get(event.getLogicEventType());
        logicHandler.handler(event);
    }

    private void autofight() {
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


    private void autofightshuaguai() {
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
                GameObjectCharMng.sendAll(new MSG_MESSAGE_EX(), vo_16383_0);
                this.gonggaotim = System.currentTimeMillis();
            }
        }

    }
    public void autofightromve() {
        Collection<GameObjectChar> sessionList = GameObjectCharMng.getGameObjectCharMap();
        long time = System.currentTimeMillis();

        sessionList.forEach(obj->{
            try {
                GameObjectChar gameObjectChar = obj;
                if (gameObjectChar.heartEcho != 0L && gameObjectChar.heartEcho + 180000L < time) {
                    GameObjectCharMng.downline(gameObjectChar);
                }

                if (gameObjectChar.gameMap!=null && (obj.gameMap.id == 38004 || obj.gameMap.isDugeno()) && obj.gameTeam == null) {
                    GameUtilRenWu.shidaohuicheng(obj.chara);
                }
            } catch (Exception var6) {
                logger.error("", var6);
            }
        });

    }
    private void autofightshidao() {
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
                    gameMap.send(new MSG_DISAPPEAR_Chara(), ((Vo_65529_0)gameMap.gameShiDao.shidaoyuanmo.get(j)).id);
                }

                List<Chara> charas = new ArrayList();

                int j;
                Chara chara;
                for(j = 0; j < gameMap.sessionList.size(); ++j) {
                    chara = ((GameObjectChar)gameMap.sessionList.get(j)).chara;
                    chara.balance -= chara.level * 10000;
                    ListVo_65527_0 listVo_65527_0 = GameUtil.MSG_UPDATE(chara);
                    GameObjectCharMng.sendOne(chara.id, new MSG_UPDATE(), listVo_65527_0);
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    vo_20481_0.msg = "由于你在挑战元魔过程中取得了优异的成绩,因此获得了系统送出的" + chara.level * 10000 + "文钱的奖励。";
                    vo_20481_0.time = (int)(System.currentTimeMillis() / 1000L);
                    GameObjectCharMng.sendOne(chara.id, new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    if (chara.shidaodaguaijifen >= 10) {
                        vo_20481_0 = new Vo_20481_0();
                        vo_20481_0.msg = "由于你所在队伍的挑战元魔的积分充足,现在进入参加试道大会的巅峰对决阶段。";
                        vo_20481_0.time = (int)(System.currentTimeMillis() / 1000L);
                        GameObjectCharMng.sendOne(chara.id, new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    }
                }

                for(j = 0; j < charas.size(); ++j) {
                    GameUtilRenWu.shidaohuicheng((Chara)charas.get(j));
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    vo_20481_0.msg = "由于你所在队伍的挑战元魔的积分不足,无法参加试道大会的巅峰对\n决阶段。";
                    vo_20481_0.time = (int)(System.currentTimeMillis() / 1000L);
                    GameObjectCharMng.sendOne(charas.get(j).id, new MSG_NOTIFY_MISC_EX(), vo_20481_0);
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
                    GameObjectCharMng.sendOne(chara.id, new MSG_NOTIFY_MISC_EX(), vo_20481_0);
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
                                listVo_65527_0 = GameUtil.MSG_UPDATE(chara);
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
                                listVo_65527_0 = GameUtil.MSG_UPDATE(chara);
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
                                listVo_65527_0 = GameUtil.MSG_UPDATE(chara);
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
                gameMap.send(new MSG_MESSAGE_EX(), vo_16383_0);
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
                            ListVo_65527_0 listVo_65527_0 = GameUtil.MSG_UPDATE(chara);
                            GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
                            GameUtilRenWu.shidaohuicheng(chara);
                        }
                    }
                }
            }
        }

    }

    public void closeServer(){
        logger.error("==>begin close server!");
        GameObjectCharMng.closeServer();
        logger.error("==>close server success!");
        System.exit(0);
    }



}
