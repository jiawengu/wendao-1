package org.linlinjava.litemall.gameserver.process;

import com.google.common.base.Preconditions;
import org.linlinjava.litemall.db.domain.Map;
import org.linlinjava.litemall.db.domain.*;
import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_61553_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
import org.linlinjava.litemall.gameserver.data.write.*;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.Goods;
import org.linlinjava.litemall.gameserver.domain.PetShuXing;
import org.linlinjava.litemall.gameserver.domain.Petbeibao;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameLine;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;

import java.text.SimpleDateFormat;
import java.util.*;

/**
 * CMD_SELECT_MENU_ITEM
 *
 * @param <main>
 */
@org.springframework.stereotype.Service
public class CMD_SELECT_MENU_ITEM<main> implements org.linlinjava.litemall.gameserver.GameHandler {
    public int[] coins = {18000, 90000, 360000, 750000, 1284000, 1800000, 2844000, 3900000, 9000000, 14400000, 25500000};
    public int[] jiage = {6, 30, 100, 200, 328, 500, 648, 1000, 2000, 3000, 5000};


    public void process(io.netty.channel.ChannelHandlerContext ctx, io.netty.buffer.ByteBuf buff) {

        int id = org.linlinjava.litemall.gameserver.data.GameReadTool.readInt(buff);


        String menu_item = org.linlinjava.litemall.gameserver.data.GameReadTool.readString(buff);


        String para = org.linlinjava.litemall.gameserver.data.GameReadTool.readString(buff);


        Chara chara1 = GameObjectChar.getGameObjectChar().chara;


        String name;

        if (id == 992) {

            org.linlinjava.litemall.db.domain.Characters characters = GameData.that.baseCharactersService.findById(chara1.id);

            Accounts accounts = GameData.that.baseAccountsService.findById(characters.getAccountId().intValue());

            if (menu_item.equals("1000积分")) {

                if ((accounts.getChongzhijifen() != null) || (accounts.getChongzhijifen().intValue() < 1000)) {

                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = "积分不足";

                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                    GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);

                    return;

                }

                accounts.setChongzhijifen(Integer.valueOf(accounts.getChongzhijifen().intValue() - 1000));

                String[] mounts_name = {"岳麓剑", "古鹿", "北极熊", "筋斗云"};

                Random random = new Random();

                String s = mounts_name[random.nextInt(mounts_name.length)];

                int jieshu = 6;

                org.linlinjava.litemall.db.domain.Pet pet = GameData.that.basePetService.findOneByName(s);

                Petbeibao petbeibao = new Petbeibao();

                petbeibao.PetCreate(pet, chara1, 0, 2);

                List<Petbeibao> list = new ArrayList();

                chara1.pets.add(petbeibao);

                list.add(petbeibao);

                ((PetShuXing) petbeibao.petShuXing.get(0)).enchant_nimbus = 0;

                ((PetShuXing) petbeibao.petShuXing.get(0)).max_enchant_nimbus = 0;

                ((PetShuXing) petbeibao.petShuXing.get(0)).suit_light_effect = 1;

                ((PetShuXing) petbeibao.petShuXing.get(0)).hide_mount = jieshu;

                PetShuXing shuXing = new PetShuXing();

                shuXing.no = 23;

                shuXing.type1 = 2;

                shuXing.accurate = (4 * (jieshu - 1));

                shuXing.mana = (4 * (jieshu - 1));

                shuXing.wiz = (3 * (jieshu - 1));

                shuXing.all_polar = 0;

                shuXing.upgrade_magic = 0;

                shuXing.upgrade_total = 0;

                petbeibao.petShuXing.add(shuXing);

                GameObjectChar.send(new MSG_UPDATE_PETS(), list);

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = ("恭喜获得#R" + s);

                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);

                ZhuangbeiInfo oneByStr = GameData.that.baseZhuangbeiInfoService.findOneByStr("七龙珠");

                GameUtil.huodezhuangbeixiangwu(chara1, oneByStr, 0, 1);

            }

            if (menu_item.equals("3000积分")) {

                if ((accounts.getChongzhijifen() != null) || (accounts.getChongzhijifen().intValue() < 3000)) {

                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = "积分不足";

                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                    GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);

                    return;

                }

                accounts.setChongzhijifen(Integer.valueOf(accounts.getChongzhijifen().intValue() - 3000));

                String[] mounts_name = {"九尾狐", "白矖", "疆良", "玄武", "朱雀", "东山神灵"};

                Random random = new Random();

                String s = mounts_name[random.nextInt(mounts_name.length)];

                org.linlinjava.litemall.db.domain.Pet pet = GameData.that.basePetService.findOneByName(s);

                Petbeibao petbeibao = new Petbeibao();

                petbeibao.PetCreate(pet, chara1, 0, 4);

                List<Petbeibao> list = new ArrayList();

                chara1.pets.add(petbeibao);

                list.add(petbeibao);

                GameObjectChar.send(new MSG_UPDATE_PETS(), list);

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = ("恭喜获得#R" + s);

                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);

                ZhuangbeiInfo oneByStr = GameData.that.baseZhuangbeiInfoService.findOneByStr("天机锁链");

                GameUtil.huodezhuangbeixiangwu(chara1, oneByStr, 0, 1);

            }

            if (menu_item.equals("5000积分")) {

                if ((accounts.getChongzhijifen() != null) || (accounts.getChongzhijifen().intValue() < 5000)) {

                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = "积分不足";

                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                    GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);

                    return;

                }

                accounts.setChongzhijifen(Integer.valueOf(accounts.getChongzhijifen().intValue() - 5000));

                String[] mounts_name = {"墨麒麟", "太极熊"};

                Random random = new Random();

                name = mounts_name[random.nextInt(mounts_name.length)];

                int jieshu = 8;

                org.linlinjava.litemall.db.domain.Pet pet = GameData.that.basePetService.findOneByName(name);

                Petbeibao petbeibao = new Petbeibao();

                petbeibao.PetCreate(pet, chara1, 0, 2);

                List<Petbeibao> list = new ArrayList();

                chara1.pets.add(petbeibao);

                list.add(petbeibao);

                ((PetShuXing) petbeibao.petShuXing.get(0)).enchant_nimbus = 0;

                ((PetShuXing) petbeibao.petShuXing.get(0)).max_enchant_nimbus = 0;

                ((PetShuXing) petbeibao.petShuXing.get(0)).suit_light_effect = 1;

                ((PetShuXing) petbeibao.petShuXing.get(0)).hide_mount = jieshu;

                PetShuXing shuXing = new PetShuXing();

                shuXing.no = 23;

                shuXing.type1 = 2;

                shuXing.accurate = (4 * (jieshu - 1));

                shuXing.mana = (4 * (jieshu - 1));

                shuXing.wiz = (3 * (jieshu - 1));

                shuXing.all_polar = 0;

                shuXing.upgrade_magic = 0;

                shuXing.upgrade_total = 0;

                petbeibao.petShuXing.add(shuXing);

                GameObjectChar.send(new MSG_UPDATE_PETS(), list);

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = ("恭喜获得#R" + name);

                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);

                ZhuangbeiInfo oneByStr = GameData.that.baseZhuangbeiInfoService.findOneByStr("闭月双环");

                GameUtil.huodezhuangbeixiangwu(chara1, oneByStr, 0, 1);

            }

            GameData.that.baseAccountsService.updateById(accounts);

        }


        if ((id == 1151) &&
                (menu_item.equals("赠送元宝"))) {

            org.linlinjava.litemall.db.domain.Characters characters = GameData.that.characterService.findById(chara1.id);

            Accounts accounts = GameData.that.baseAccountsService.findById(characters.getAccountId().intValue());

            List<org.linlinjava.litemall.db.domain.Charge> chargeList = GameData.that.baseChargeService.findByAccountname(accounts.getName());

            if (chargeList == null) {

                return;

            }

            int yuanbao = 0;

            for (org.linlinjava.litemall.db.domain.Charge charge : chargeList) {

                if (charge.getState().intValue() == 0) {

                    yuanbao += charge.getCoin().intValue();

                    charge.setState(Integer.valueOf(1));

                    for (int i = 0; i < this.coins.length; i++) {

                        if (charge.getCoin().intValue() == this.coins[i]) {

                            charge.setMoney(Integer.valueOf(this.jiage[i]));

                            break;

                        }

                    }

                    charge.setCode(accounts.getCode());

                    GameData.that.baseChargeService.updateById(charge);

                }

            }
            if (yuanbao > 0) {

                if (chara1.extra_life < 0) {

                    chara1.extra_life = 0;

                }

                chara1.extra_life += yuanbao;

                if (chara1.extra_life > 999999999) {

                    chara1.extra_life = 999999999;

                }

                int jifen = 0;

                jifen = yuanbao / 3000;


                chara1.shadow_self += jifen;

                chara1.chongzhijifen += jifen;

                ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara1);

                GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_UPDATE(), listVo_65527_0);

                accounts.setChongzhiyuanbao(Integer.valueOf(0));

                GameData.that.baseAccountsService.updateById(accounts);

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = "领取元宝成功";

                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);

            } else {

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = "暂无可领取的元宝";

                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);

            }

        }


        if ((id == 1170) &&
                (menu_item.equals("离开战场"))) {

            GameUtilRenWu.shidaohuicheng(chara1);

        }


        if (menu_item.equals("开始战斗")) {

            List<String> list = new ArrayList();

            for (int j = 0; j < 10; j++) {

                list.add("试道元魔");

            }

            org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list);

            GameObjectChar.getGameObjectChar().gameMap.send(new org.linlinjava.litemall.gameserver.data.write.M12285_1(), Integer.valueOf(id));

            for (int i = 0; i < GameObjectChar.getGameObjectChar().gameMap.gameShiDao.shidaoyuanmo.size(); i++) {

                if (id == ((Vo_65529_0) GameObjectChar.getGameObjectChar().gameMap.gameShiDao.shidaoyuanmo.get(i)).id) {

                    GameObjectChar.getGameObjectChar().gameMap.gameShiDao.shidaoyuanmo.remove(GameObjectChar.getGameObjectChar().gameMap.gameShiDao.shidaoyuanmo.get(i));

                }

            }

        }


        /**
         * 进入通天塔
         */
        if (id == 960 && (menu_item.equals("通天塔"))) {
            if(chara1.level<50){
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                vo_20481_0.msg = "角色等级不足50级！";
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                return;
            }
            Map map = GameData.that.baseMapService.findOneByName("通天塔");
            chara1.y = map.getY().intValue();
            chara1.x = map.getX().intValue();
            GameLine.getGameMapname(chara1.line, map.getName()).join(GameObjectChar.getGameObjectChar());

//            Vo_49177_0 vo_49177_0 = new Vo_49177_0();
//            vo_49177_0.isPK = 3;
//            vo_49177_0.stageId = 3;
//            vo_49177_0.monsterPoint = 10;
//            vo_49177_0.pkValue = 2;
//            vo_49177_0.totalScore = 45;
//            vo_49177_0.startTime = 1567343400;
//            vo_49177_0.stage1_duration_time = 1800;
//            vo_49177_0.stage2_duration_time = 6600;
//            vo_49177_0.rank = 0;
//            GameObjectChar.send(new M49177_0(), vo_49177_0);

            GameUtilRenWu.notifyTTTTask(chara1);
            return;
        }

        if (menu_item.equals("挑战星君")) {
            FightManager.goFightTTT(chara1);
            return;
        }

        if(id == 1207){//北斗神将
            if("离开".equals(menu_item)){
                GameUtilRenWu.huicheng(chara1);
            }else if("挑战下层".equals(menu_item)){
                GameUtil.tttChallengeNextLayer(chara1);
            }else if("飞升".equals(menu_item)){
                GameObjectChar.send(new MSG_OPEN_FEISHENG_DLG(), null);
            }else if("重新挑战".equals(menu_item)){
                FightManager.goFight(chara1, Arrays.asList(chara1.ttt_xj_name));
            }else if("更换奖励类型".equals(menu_item)){
                Preconditions.checkArgument(chara1.ttt_challenge_num==0);
                String xingjunName = GameUtil.randomTTTXingJunName();
                chara1.onEnterTttLayer(chara1.ttt_layer, xingjunName);

                GameUtil.notifyTTTPanelInfo(chara1);
                GameUtilRenWu.notifyTTTTask(chara1);
            }else if("传送出塔".equals(menu_item)){
                GameUtilRenWu.huicheng(chara1);
            }
        }

        if ((id == 962) && (menu_item.equals("世道进入"))) {
            String shidaoname = GameUtilRenWu.shidaolevel(chara1);
            org.linlinjava.litemall.db.domain.Map map = GameData.that.baseMapService.findOneByName(shidaoname);
            if (map == null) {
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                if (shidaoname == "不在活动时间内") vo_20481_0.msg = shidaoname;
                else vo_20481_0.msg = "不符合条件";
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                return;
            }
            chara1.y = map.getY().intValue();
            chara1.x = map.getX().intValue();
            org.linlinjava.litemall.gameserver.game.GameLine.getGameMapname(chara1.line, map.getName()).join(GameObjectChar.getGameObjectChar());
            org.linlinjava.litemall.gameserver.data.vo.Vo_49177_0 vo_49177_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_49177_0();
            vo_49177_0.isPK = 3;
            vo_49177_0.stageId = 3;
            vo_49177_0.monsterPoint = 10;
            vo_49177_0.pkValue = 2;
            vo_49177_0.totalScore = 45;
            vo_49177_0.startTime = 1567343400;
            vo_49177_0.stage1_duration_time = 1800;
            vo_49177_0.stage2_duration_time = 6600;
            vo_49177_0.rank = 0;
            GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M49177_0(), vo_49177_0);
        }

        if ((id == 928) &&
                /*  265 */       (menu_item.equals("法宝亲密丹"))) {
            /*  266 */
            Boolean has = Boolean.valueOf(false);
            /*  267 */
            for (int i = 0; i < chara1.backpack.size(); i++) {
                /*  268 */
                if ((((Goods) chara1.backpack.get(i)).pos == 9) &&
                        /*  269 */           (chara1.extra_life > 500)) {
                    /*  270 */
                    chara1.extra_life -= 500;
                    /*  271 */
                    ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara1);
                    /*  272 */
                    GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
                    /*  273 */
                    ((Goods) chara1.backpack.get(i)).goodsInfo.shape += 1000;
                    /*  274 */
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    /*  275 */
                    vo_20481_0.msg = ("你的法宝#Y" + ((Goods) chara1.backpack.get(i)).goodsInfo.str + "#n获得了#R1000#n亲密");
                    /*  276 */
                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                    /*  277 */
                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    /*  278 */
                    has = Boolean.valueOf(true);
                    /*      */
                }
                /*      */
            }
            /*      */
            /*  282 */
            if (!has.booleanValue()) {
                /*  283 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  284 */
                vo_20481_0.msg = "你身上没有法宝！";
                /*  285 */
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                /*  286 */
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*      */
            }
            /*      */
        }


        if (id == 829 && menu_item.equals("挑战掌门")) {
            String strArr[] = new String[]{"金系掌门", "木系掌门", "水系掌门", "火系掌门", "土系掌门"};
            List<String> list = new ArrayList();
            list.add(strArr[(chara1.menpai + 4) % 5]);
            // todo

            org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list);
        }
        ShangGuYaoWangInfo info =
                GameData.that.BaseShangGuYaoWangInfoService.findByNpcID(id,
                        true);
        if (menu_item.equals("挑战") && null != info){
            if (GameObjectChar.getGameObjectChar().gameTeam == null){
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                vo_20481_0.msg = "人数不足3人！";
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new M20481_0(), vo_20481_0);
                return;
            }

            List<Chara> duiwu = GameObjectChar.getGameObjectChar().gameTeam.duiwu;

            if (duiwu.size() < 3) {
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                vo_20481_0.msg = "人数不足3人！";
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new M20481_0(), vo_20481_0);
                return;

            }
            for (int i = 0; i < duiwu.size(); i++) {
                Chara tempChara = duiwu.get(i);
                org.linlinjava.litemall.db.domain.Characters characters = GameData.that.baseCharactersService.findById(tempChara.id);

            SimpleDateFormat sdf= new SimpleDateFormat("yyyy-MM-dd");
            Date date = new Date();

                long count =
                        GameData.that.BaseShangGuYaoWangRewardInfoService.count(characters.getAccountId(), sdf.format(date));
                if (count > 5) {

                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = tempChara.name + "已经获取5次奖励了";

                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new M20481_0(), vo_20481_0);
                    return;
                }
            }

            org.linlinjava.litemall.db.domain.Npc npc =
                    GameData.that.baseNpcService.findById(id);

            List<String> list = new ArrayList();
            list.add(npc.getName());

            Random RANDOM = new Random();
//            ShangGuYaoWangInfo  info =
//                    GameData.that.BaseShangGuYaoWangInfoService.findByNpcID(npc.getId());
            String []  xiaoGuai = info.getXiaoGuai().split(",");


            for(int i = 0; i < 9; ++i) {
                list.add(xiaoGuai[RANDOM.nextInt(xiaoGuai.length)]);
            }

            org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list);
        }

        if ((org.linlinjava.litemall.gameserver.game.GameShuaGuai.list.contains(Integer.valueOf(id))) && (menu_item.equals("我是来向你挑战的"))) {
            /*  292 */
            for (int i = 0; i < org.linlinjava.litemall.gameserver.game.GameLine.gameShuaGuai.shuaXing.size(); i++) {
                /*  293 */
                if (id == ((Vo_65529_0) org.linlinjava.litemall.gameserver.game.GameLine.gameShuaGuai.shuaXing.get(i)).id) {
                    /*  294 */
                    List<String> list = new ArrayList();
                    /*  295 */
                    list.add(((Vo_65529_0) org.linlinjava.litemall.gameserver.game.GameLine.gameShuaGuai.shuaXing.get(i)).name);
                    /*  296 */
                    for (int j = 0; j < 9; j++) {
                        /*  297 */
                        list.add("星");
                        /*      */
                    }
                    /*  299 */
                    org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list, (Vo_65529_0) org.linlinjava.litemall.gameserver.game.GameLine.gameShuaGuai.shuaXing.get(i));
                    /*      */
                }
                /*      */
            }
            /*      */
        }
        /*      */
        /*      */
        /*      */
        /*  306 */
        for (int i = 0; i < chara1.npcxuanshang.size(); i++) {
            /*  307 */
            if ((((Vo_65529_0) chara1.npcxuanshang.get(i)).id == id) &&
                    /*  308 */         (menu_item.equals("追拿通缉犯"))) {
                /*  309 */
                List<String> list = new ArrayList();
                /*  310 */
                for (int j = 0; j < 5; j++) {
                    /*  311 */
                    list.add("仙界叛逆");
                    /*      */
                }
                /*  313 */
                org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list);
                /*      */
            }
            /*      */
        }
        /*      */
        /*      */
        /*      */
        /*  319 */
        if (id == 1195)
            /*      */ {
            /*  321 */
            if ((menu_item.equals("我想领取悬赏经验")) && (chara1.npcXuanShangName.equals("领取奖励"))) {
                /*  322 */
                chara1.npcXuanShangName = "";
                /*  323 */
                int jingyan = 7975 * chara1.level;
                /*  324 */
                GameUtil.huodejingyan(chara1, jingyan);
                /*      */
            }
            /*      */
            /*  327 */
            if ((menu_item.equals("我想领取悬赏道行")) && (chara1.npcXuanShangName.equals("领取奖励"))) {
                /*  328 */
                int base_pet_dh = (int) (0.29D * chara1.level * chara1.level * chara1.level);
                /*  329 */
                chara1.npcXuanShangName = "";
                /*      */
                /*  331 */
                int owner_name = 2634 * chara1.level / (chara1.friend > base_pet_dh ? chara1.friend / base_pet_dh : 1);
                /*  332 */
                GameUtil.adddaohang(chara1, owner_name);
                /*  333 */
                for (int i = 0; i < chara1.pets.size(); i++) {
                    /*  334 */
                    if (((Petbeibao) chara1.pets.get(i)).id == chara1.chongwuchanzhanId) {
                        /*  335 */
                        PetShuXing petShuXing = (PetShuXing) ((Petbeibao) chara1.pets.get(i)).petShuXing.get(0);
                        /*  336 */
                        base_pet_dh = (int) (0.29D * petShuXing.skill * petShuXing.skill * petShuXing.skill);
                        /*  337 */
                        int intimacy = 878 * petShuXing.skill / (petShuXing.intimacy > base_pet_dh ? petShuXing.intimacy / base_pet_dh : 1);
                        /*  338 */
                        petShuXing.intimacy += intimacy;
                        /*  339 */
                        Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                        /*  340 */
                        vo_20481_0.msg = ("宠物获得武学#R" + intimacy);
                        /*  341 */
                        vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                        /*  342 */
                        GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                        /*      */
                    }
                    /*      */
                }
                /*  345 */
                ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara1);
                /*  346 */
                GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
                /*      */
            }
            /*  348 */
            if (menu_item.equals("领取悬赏任务")) {
                /*  349 */
                boolean b = GameUtil.belongCalendar();
                /*  350 */
                if (!b) {
                    /*  351 */
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    /*  352 */
                    vo_20481_0.msg = "不在任务时间段";
                    /*  353 */
                    vo_20481_0.time = 1562987118;
                    /*  354 */
                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    /*  355 */
                    return;
                    /*      */
                }
                /*      */
                /*  358 */
                if (chara1.npcXuanShangName.equals("领取奖励")) {
                    /*  359 */
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    /*  360 */
                    vo_20481_0.msg = "请先领取奖励";
                    /*  361 */
                    vo_20481_0.time = 1562987118;
                    /*  362 */
                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    /*  363 */
                    return;
                    /*      */
                }
                /*  365 */
                if (chara1.xuanshangcishu >= 2) {
                    /*  366 */
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    /*  367 */
                    vo_20481_0.msg = "今天已经做完了";
                    /*  368 */
                    vo_20481_0.time = 1562987118;
                    /*  369 */
                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    /*  370 */
                    return;
                    /*      */
                }
                /*  372 */
                if (chara1.xuanshangcishu < 2) {
                    /*  373 */
                    List<RenwuMonster> all = GameData.that.baseRenwuMonsterService.findByType(Integer.valueOf(5));
                    /*  374 */
                    Random random = new Random();
                    /*  375 */
                    int i = random.nextInt(all.size());
                    /*  376 */
                    RenwuMonster renwuMonster = (RenwuMonster) all.get(i);
                    /*  377 */
                    org.linlinjava.litemall.db.domain.Map map = GameData.that.baseMapService.findOneByName(renwuMonster.getMapName());
                    /*  378 */
                    chara1.npcxuanshang = new ArrayList();
                    /*  379 */
                    chara1.npcXuanShangName = renwuMonster.getName();
                    /*  380 */
                    Vo_65529_0 vo_65529_0 = new Vo_65529_0();
                    /*  381 */
                    vo_65529_0.mapid = map.getMapId().intValue();
                    /*  382 */
                    vo_65529_0.id = GameUtil.getCard(chara1);
                    /*  383 */
                    vo_65529_0.x = renwuMonster.getX().intValue();
                    /*  384 */
                    vo_65529_0.y = renwuMonster.getY().intValue();
                    /*  385 */
                    vo_65529_0.icon = renwuMonster.getIcon().intValue();
                    /*  386 */
                    vo_65529_0.type = 2;
                    /*  387 */
                    vo_65529_0.org_icon = renwuMonster.getIcon().intValue();
                    /*  388 */
                    vo_65529_0.portrait = renwuMonster.getIcon().intValue();
                    /*  389 */
                    vo_65529_0.name = (chara1.name + "的仙界叛逆");
                    /*  390 */
                    vo_65529_0.level = chara1.level;
                    /*  391 */
                    vo_65529_0.leixing = 4;
                    /*  392 */
                    chara1.npcxuanshang.add(vo_65529_0);
                    /*      */
                    /*  394 */
                    String task_type = "悬赏祍务";
                    /*  395 */
                    String task_prompt = "捉拿逃窜的#P仙界叛逆|" + renwuMonster.getMapName() + "(" + renwuMonster.getX() + "," + renwuMonster.getY() + ")|M=追拿通缉犯|$0#P（建议组队）";
                    /*      */
                    /*  397 */
                    String show_name = "悬赏祍务";
                    /*  398 */
                    GameUtilRenWu.renwukuangkuang(task_type, task_prompt, show_name, chara1);
                    /*      */
                }
                /*      */
            }
            /*      */
        }
        /*      */
        if ((id == 1184) &&
                /*  404 */       (menu_item.equals("十绝阵_s0"))) {
            /*  405 */
            if (GameObjectChar.getGameObjectChar().gameTeam == null) {
                /*  406 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  407 */
                vo_20481_0.msg = "人数不足3人！";
                /*  408 */
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                /*  409 */
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*  410 */
                return;
                /*      */
            }
            /*  412 */
            List<Chara> duiwu = GameObjectChar.getGameObjectChar().gameTeam.duiwu;
            /*  413 */
            if (duiwu.size() < 3) {
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                vo_20481_0.msg = "人数不足3人！";
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                return;

            }
            /*  420 */
            for (int i = 0; i < duiwu.size(); i++) {
                /*  421 */
                if (((Chara) duiwu.get(i)).xiuxingcishu > 40) {
                    /*  422 */
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    /*  423 */
                    vo_20481_0.msg = (((Chara) duiwu.get(i)).name + "已完成任务");
                    /*  424 */
                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                    /*  425 */
                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    /*  426 */
                    return;
                    /*      */
                }
                /*      */
            }
            /*  429 */
            String[] npces = {"金光阵主", "风吼阵主", "落魄阵主", "化血阵主", "红水阵主", "寒冰阵主", "烈焰阵主", "地烈阵主", "天阙阵主", "红砂阵主"};
            /*  431 */
            int i = (chara1.xiuxingcishu + 9) % 10;
            /*  432 */
            chara1.xiuxingNpcname = npces[i];
            /*  433 */
            Vo_61553_0 vo_61553_10 = new Vo_61553_0();
            /*  434 */
            vo_61553_10.count = 1;
            /*  435 */
            vo_61553_10.task_type = "十绝阵";
            /*  436 */
            vo_61553_10.task_desc = "天法道、道法自然，此乃道义根本。十位上古仙神演自然玄机，终成十绝之阵。";
            /*  437 */
            vo_61553_10.task_prompt = ("拜访#P" + npces[i] + "|M=【十绝阵】请仙人赐教#P");
            /*  438 */
            vo_61553_10.refresh = 0;
            /*  439 */
            vo_61553_10.task_end_time = 1567932239;
            /*  440 */
            vo_61553_10.attrib = 0;
            /*  441 */
            vo_61553_10.reward = "#I经验|人物经验宠物经验#I#I金钱|金钱#I";
            /*  442 */
            vo_61553_10.show_name = ("【十绝阵】修行(" + ((chara1.xiuxingcishu + 9) % 10 + 1) + "/10)");
            /*  443 */
            vo_61553_10.tasktask_extra_para = "";
            /*  444 */
            vo_61553_10.tasktask_state = "1";
            /*  445 */
            GameObjectChar.sendduiwu(new MSG_TASK_PROMPT(), vo_61553_10, chara1.id);

            /*  403 */
            org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0 vo_45063_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0();
            /*  404 */
            vo_45063_0.task_name = vo_61553_10.task_prompt;
            /*  405 */
            vo_45063_0.check_point = 147761859;
            /*  406 */
            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45063_0(), vo_45063_0, chara1.id);
            /*      */
        }
        if (menu_item.equals("十绝阵_s1")) {
            /*  451 */
            org.linlinjava.litemall.db.domain.Npc npc = GameData.that.baseNpcService.findOneByName(chara1.xiuxingNpcname);
            /*  452 */
            if (npc == null) {
                /*  453 */
                return;
                /*      */
            }
            /*  455 */
            if (npc.getId().intValue() == id) {
                /*  456 */
                Random random = new Random();
                /*  457 */
                List<String> list = new ArrayList();
                /*  458 */
                list.add(chara1.xiuxingNpcname);
                /*  459 */
                for (int j = 0; j < 9; j++) {
                    /*  460 */
                    int i1 = random.nextInt(6);
                    /*  461 */
                    if (i1 == 0) {
                        /*  462 */
                        list.add("兑灵");
                        /*      */
                    }
                    /*  464 */
                    if (i1 == 1) {
                        /*  465 */
                        list.add("艮灵");
                        /*      */
                    }
                    /*  467 */
                    if (i1 == 2) {
                        /*  468 */
                        list.add("坎灵");
                        /*      */
                    }
                    /*  470 */
                    if (i1 == 3) {
                        /*  471 */
                        list.add("离灵");
                        /*      */
                    }
                    /*  473 */
                    if (i1 == 4) {
                        /*  474 */
                        list.add("狂灵");
                        /*      */
                    }
                    /*  476 */
                    if (i1 == 5) {
                        /*  477 */
                        list.add("疯灵");
                        /*      */
                    }
                    /*      */
                }
                /*  480 */
                org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list);
                /*      */
            }
            /*      */
        }
        /*  403 */
        if ((id == 1174) &&
                /*  404 */       (menu_item.equals("修行_s0"))) {
            /*  405 */
            if (GameObjectChar.getGameObjectChar().gameTeam == null) {
                /*  406 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  407 */
                vo_20481_0.msg = "人数不足3人！";
                /*  408 */
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                /*  409 */
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*  410 */
                return;
                /*      */
            }
            /*  412 */
            List<Chara> duiwu = GameObjectChar.getGameObjectChar().gameTeam.duiwu;
            /*  413 */
            if (duiwu.size() < 3) {
                /*  414 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  415 */
                vo_20481_0.msg = "人数不足3人！";
                /*  416 */
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                /*  417 */
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*  418 */
                return;
                /*      */
            }
            /*  420 */
            for (int i = 0; i < duiwu.size(); i++) {
                /*  421 */
                if (((Chara) duiwu.get(i)).xiuxingcishu > 40) {
                    /*  422 */
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    /*  423 */
                    vo_20481_0.msg = (((Chara) duiwu.get(i)).name + "已完成任务");
                    /*  424 */
                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                    /*  425 */
                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    /*  426 */
                    return;
                    /*      */
                }
                /*      */
            }
            /*  429 */
            String[] npces = {"雷神", "花神", "炎神", "山神", "龙神"};
            /*  430 */
            Random random = new Random();
            /*  431 */
            int i = random.nextInt(npces.length);
            /*  432 */
            chara1.xiuxingNpcname = npces[i];
            /*  433 */
            Vo_61553_0 vo_61553_10 = new Vo_61553_0();
            /*  434 */
            vo_61553_10.count = 1;
            /*  435 */
            vo_61553_10.task_type = "修炼";
            /*  436 */
            vo_61553_10.task_desc = "接受门派师尊交办的一些事情，完成后会获得嘉奖。";
            /*  437 */
            vo_61553_10.task_prompt = ("拜访#P" + npces[i] + "|M=【修行】请仙人赐教#P");
            /*  438 */
            vo_61553_10.refresh = 0;
            /*  439 */
            vo_61553_10.task_end_time = 1567932239;
            /*  440 */
            vo_61553_10.attrib = 0;
            /*  441 */
            vo_61553_10.reward = "#I经验|人物经验宠物经验#I#I金钱|金钱#I";
            /*  442 */
            vo_61553_10.show_name = ("【修炼】修行(" + chara1.xiuxingcishu + "/10)");
            /*  443 */
            vo_61553_10.tasktask_extra_para = "";
            /*  444 */
            vo_61553_10.tasktask_state = "1";
            /*  445 */
            GameObjectChar.sendduiwu(new MSG_TASK_PROMPT(), vo_61553_10, chara1.id);
            /*      */
        }
        /*      */
        /*      */
        /*      */
        /*  450 */
        if (menu_item.equals("修行_s1")) {
            /*  451 */
            org.linlinjava.litemall.db.domain.Npc npc = GameData.that.baseNpcService.findOneByName(chara1.xiuxingNpcname);
            /*  452 */
            if (npc == null) {
                /*  453 */
                return;
                /*      */
            }
            /*  455 */
            if (npc.getId().intValue() == id) {
                /*  456 */
                Random random = new Random();
                /*  457 */
                List<String> list = new ArrayList();
                /*  458 */
                list.add(chara1.xiuxingNpcname);
                /*  459 */
                for (int j = 0; j < 4; j++) {
                    /*  460 */
                    int i1 = random.nextInt(6);
                    /*  461 */
                    if (i1 == 0) {
                        /*  462 */
                        list.add("兑灵");
                        /*      */
                    }
                    /*  464 */
                    if (i1 == 1) {
                        /*  465 */
                        list.add("艮灵");
                        /*      */
                    }
                    /*  467 */
                    if (i1 == 2) {
                        /*  468 */
                        list.add("坎灵");
                        /*      */
                    }
                    /*  470 */
                    if (i1 == 3) {
                        /*  471 */
                        list.add("离灵");
                        /*      */
                    }
                    /*  473 */
                    if (i1 == 4) {
                        /*  474 */
                        list.add("狂灵");
                        /*      */
                    }
                    /*  476 */
                    if (i1 == 5) {
                        /*  477 */
                        list.add("疯灵");
                        /*      */
                    }
                    /*      */
                }
                /*  480 */
                org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list);
                /*      */
            }
            /*      */
        }
        if ((id == 1185) &&
                /*  484 */       (menu_item.equals("飞仙渡邪_dispatch"))) {
            /*  485 */
            if (GameObjectChar.getGameObjectChar().gameTeam == null) {
                /*  486 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  491 */
                vo_20481_0.msg = "人数不足3人！";
                /*  492 */
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                /*  493 */
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                return;
                /*      */
            }
            /*  488 */
            List<Chara> duiwu = GameObjectChar.getGameObjectChar().gameTeam.duiwu;
            /*  489 */
            if (duiwu.size() < 3) {
                /*  490 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  491 */
                vo_20481_0.msg = "人数不足3人！";
                /*  492 */
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                /*  493 */
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*  494 */
                return;
                /*      */
            }
            /*  496 */
            /*  503 */
            if (!GameUtil.duiwudengji(chara1, GameObjectChar.getGameObjectChar())) {
                /*  504 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  505 */
                vo_20481_0.msg = "人物等级相差10级，不能接任务！";
                /*  506 */
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                /*  507 */
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*  508 */
                return;
                /*      */
            }
            /*      */
            /*      */
            /*  512 */
            List<RenwuMonster> all = GameData.that.baseRenwuMonsterService.findByType(Integer.valueOf(4));
            /*  513 */
            Random random = new Random();
            /*  514 */
            int i = random.nextInt(all.size());
            /*  515 */
            RenwuMonster renwuMonster = (RenwuMonster) all.get(i);
            /*  516 */
            String s = renwuMonster.getName() + "的" + GameUtil.getRandomJianHan();
            /*  517 */
            org.linlinjava.litemall.db.domain.Map map = GameData.that.baseMapService.findOneByName(renwuMonster.getMapName());
            /*  518 */
            if (map == null) {
                /*  519 */
                System.out.println(renwuMonster.getMapName());
                /*  520 */
                return;
                /*      */
            }
            /*  522 */
            chara1.npcshuadao = new ArrayList();
            /*  523 */
            Vo_65529_0 vo_65529_0 = new Vo_65529_0();
            /*  524 */
            vo_65529_0.mapid = map.getMapId().intValue();
            /*  525 */
            vo_65529_0.id = GameUtil.getCard(chara1);
            /*  526 */
            vo_65529_0.x = renwuMonster.getX().intValue();
            /*  527 */
            vo_65529_0.y = renwuMonster.getY().intValue();
            /*  528 */
            vo_65529_0.icon = renwuMonster.getIcon().intValue();
            /*  529 */
            vo_65529_0.type = 2;
            /*  530 */
            vo_65529_0.org_icon = renwuMonster.getIcon().intValue();
            /*  531 */
            vo_65529_0.portrait = renwuMonster.getIcon().intValue();
            /*  532 */
            vo_65529_0.name = s;
            /*  533 */
            vo_65529_0.level = chara1.level;
            /*  534 */
            vo_65529_0.leixing = 4;
            /*  535 */
            chara1.npcshuadao.add(vo_65529_0);
            /*      */
            /*      */
            /*  538 */
            Vo_61553_0 vo_61553_0 = new Vo_61553_0();
            /*  539 */
            vo_61553_0.count = 1;
            /*  540 */
            vo_61553_0.task_type = "飞仙渡邪";
            /*  541 */
            vo_61553_0.task_desc = "";
            /*  542 */
            vo_61553_0.task_prompt = ("渡邪#P" + s + "|" + renwuMonster.getMapName() + "(" + renwuMonster.getX() + "," + renwuMonster.getY() + ")|M=今天我要为民除害|$0#P");
            /*  543 */
            vo_61553_0.refresh = 1;
            /*  544 */
            vo_61553_0.task_end_time = 1567909190;
            /*  545 */
            vo_61553_0.attrib = 1;
            /*  546 */
            vo_61553_0.reward = "#I经验|人物经验宠物经验#I#I道行|道行#I#I潜能|潜能#I#I武学|武学#I#I金钱|金钱#I";
            /*  547 */
            int cishu = chara1.shuadao % 10;
            /*  548 */
            if (cishu == 0) {
                /*  549 */
                cishu = 10;
                /*      */
            }
            /*  551 */
            vo_61553_0.show_name = ("飞仙渡邪(" + cishu + "/10)");
            /*  552 */
            vo_61553_0.tasktask_extra_para = "";
            /*  553 */
            vo_61553_0.tasktask_state = "1";
            /*  554 */
            GameObjectChar.sendduiwu(new MSG_TASK_PROMPT(), vo_61553_0, chara1.id);
            /*      */
            /*  556 */
            org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0 vo_45063_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0();
            /*  557 */
            vo_45063_0.task_name = vo_61553_0.task_prompt;
            /*  558 */
            vo_45063_0.check_point = 147761859;
            /*  559 */
            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45063_0(), vo_45063_0, chara1.id);
            /*      */
            /*  561 */
            org.linlinjava.litemall.gameserver.data.vo.Vo_45092_0 vo_45092_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45092_0();
            /*  562 */
            vo_45092_0.task_name = "飞仙渡邪";
            /*  563 */
            vo_45092_0.check_point = 40;
            /*  564 */
            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45092_0(), vo_45092_0, chara1.id);
            /*      */
            /*  566 */
            org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0 vo_8165_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0();
            /*  567 */
            vo_8165_0.msg = ("现有#Y" + s + "#n在#R" + renwuMonster.getMapName() + "#n附近出没，速去将其渡邪！");
            /*  568 */
            vo_8165_0.active = 0;
            /*  569 */
            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M8165_0(), vo_8165_0, chara1.id);
            /*      */
            /*      */
            /*  572 */
            if (chara1.mapid == ((Vo_65529_0) chara1.npcshuadao.get(0)).mapid) {
                /*  573 */
                GameObjectChar.sendduiwu(new MSG_APPEAR(), chara1.npcshuadao.get(0), chara1.id);
                /*      */
            }
            /*      */
        }
        /*  483 */
        if ((id == 866) &&
                /*  484 */       (menu_item.equals("领取任务"))) {
            /*  485 */
            if (GameObjectChar.getGameObjectChar().gameTeam == null) {
                /*  486 */
                return;
                /*      */
            }
            /*  488 */
            List<Chara> duiwu = GameObjectChar.getGameObjectChar().gameTeam.duiwu;
            /*  489 */
            if (duiwu.size() < 3) {
                /*  490 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  491 */
                vo_20481_0.msg = "人数不足3人！";
                /*  492 */
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                /*  493 */
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*  494 */
                return;
                /*      */
            }
            /*  496 */
            int ret = GameUtil.duiwudengjicmp(chara1, GameObjectChar.getGameObjectChar(), 80, 119);
            if (ret != 0) {
                /*  497 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  498 */
                if (ret == 1) {
                    vo_20481_0.msg = "小于80级不可以领取任务！";
                } else {
                    vo_20481_0.msg = "道友道行深厚，已无需在此处降妖，请去更高级的地方！";
                }
                /*  499 */
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                /*  500 */
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*  501 */
                return;
                /*      */
            }
            /*  503 */
            if (!GameUtil.duiwudengji(chara1, GameObjectChar.getGameObjectChar())) {
                /*  504 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  505 */
                vo_20481_0.msg = "人物等级相差10级，不能接任务！";
                /*  506 */
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                /*  507 */
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*  508 */
                return;
                /*      */
            }
            /*      */
            /*      */
            /*  512 */
            List<RenwuMonster> all = GameData.that.baseRenwuMonsterService.findByType(Integer.valueOf(3));
            /*  513 */
            Random random = new Random();
            /*  514 */
            int i = random.nextInt(all.size());
            /*  515 */
            RenwuMonster renwuMonster = (RenwuMonster) all.get(i);
            /*  516 */
            String s = renwuMonster.getName() + "的" + GameUtil.getRandomJianHan();
            /*  517 */
            org.linlinjava.litemall.db.domain.Map map = GameData.that.baseMapService.findOneByName(renwuMonster.getMapName());
            /*  518 */
            if (map == null) {
                /*  519 */
                System.out.println(renwuMonster.getMapName());
                /*  520 */
                return;
                /*      */
            }
            /*  522 */
            chara1.npcshuadao = new ArrayList();
            /*  523 */
            Vo_65529_0 vo_65529_0 = new Vo_65529_0();
            /*  524 */
            vo_65529_0.mapid = map.getMapId().intValue();
            /*  525 */
            vo_65529_0.id = GameUtil.getCard(chara1);
            /*  526 */
            vo_65529_0.x = renwuMonster.getX().intValue();
            /*  527 */
            vo_65529_0.y = renwuMonster.getY().intValue();
            /*  528 */
            vo_65529_0.icon = renwuMonster.getIcon().intValue();
            /*  529 */
            vo_65529_0.type = 2;
            /*  530 */
            vo_65529_0.org_icon = renwuMonster.getIcon().intValue();
            /*  531 */
            vo_65529_0.portrait = renwuMonster.getIcon().intValue();
            /*  532 */
            vo_65529_0.name = s;
            /*  533 */
            vo_65529_0.level = chara1.level;
            /*  534 */
            vo_65529_0.leixing = 3;
            /*  535 */
            chara1.npcshuadao.add(vo_65529_0);
            /*      */
            /*      */
            /*  538 */
            Vo_61553_0 vo_61553_0 = new Vo_61553_0();
            /*  539 */
            vo_61553_0.count = 1;
            /*  540 */
            vo_61553_0.task_type = "降妖";
            /*  541 */
            vo_61553_0.task_desc = "";
            /*  542 */
            vo_61553_0.task_prompt = ("降伏#P" + s + "|" + renwuMonster.getMapName() + "(" + renwuMonster.getX() + "," + renwuMonster.getY() + ")|M=今天我要为民除害|$0#P");
            /*  543 */
            vo_61553_0.refresh = 1;
            /*  544 */
            vo_61553_0.task_end_time = 1567909190;
            /*  545 */
            vo_61553_0.attrib = 1;
            /*  546 */
            vo_61553_0.reward = "#I经验|人物经验宠物经验#I#I道行|道行#I#I潜能|潜能#I#I武学|武学#I#I金钱|金钱#I";
            /*  547 */
            int cishu = chara1.shuadao % 10;
            /*  548 */
            if (cishu == 0) {
                /*  549 */
                cishu = 10;
                /*      */
            }
            /*  551 */
            vo_61553_0.show_name = ("附魔(" + cishu + "/10)");
            /*  552 */
            vo_61553_0.tasktask_extra_para = "";
            /*  553 */
            vo_61553_0.tasktask_state = "1";
            /*  554 */
            GameObjectChar.sendduiwu(new MSG_TASK_PROMPT(), vo_61553_0, chara1.id);
            /*      */
            /*  556 */
            org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0 vo_45063_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0();
            /*  557 */
            vo_45063_0.task_name = vo_61553_0.task_prompt;
            /*  558 */
            vo_45063_0.check_point = 147761859;
            /*  559 */
            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45063_0(), vo_45063_0, chara1.id);
            /*      */
            /*  561 */
            org.linlinjava.litemall.gameserver.data.vo.Vo_45092_0 vo_45092_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45092_0();
            /*  562 */
            vo_45092_0.task_name = "附魔";
            /*  563 */
            vo_45092_0.check_point = 40;
            /*  564 */
            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45092_0(), vo_45092_0, chara1.id);
            /*      */
            /*  566 */
            org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0 vo_8165_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0();
            /*  567 */
            vo_8165_0.msg = ("现有#Y" + s + "#n在#R" + renwuMonster.getMapName() + "#n附近出没，速去将其降伏！");
            /*  568 */
            vo_8165_0.active = 0;
            /*  569 */
            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M8165_0(), vo_8165_0, chara1.id);
            /*      */
            /*      */
            /*  572 */
            if (chara1.mapid == ((Vo_65529_0) chara1.npcshuadao.get(0)).mapid) {
                /*  573 */
                GameObjectChar.sendduiwu(new MSG_APPEAR(), chara1.npcshuadao.get(0), chara1.id);
                /*      */
            }
            /*      */
        }
        /*      */
        /*      */
        /*  578 */
        if ((id == 957) &&
                /*  579 */       (menu_item.equals("dispatch_xiangy"))) {
            /*  580 */
            if (GameObjectChar.getGameObjectChar().gameTeam == null) {
                /*  581 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  582 */
                vo_20481_0.msg = "人数不足3人！";
                /*  583 */
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                /*  584 */
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*  585 */
                return;
                /*      */
            }
            /*  587 */
            List<Chara> duiwu = GameObjectChar.getGameObjectChar().gameTeam.duiwu;
            /*  588 */
            if (duiwu.size() < 3) {
                /*  589 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  590 */
                vo_20481_0.msg = "人数不足3人！";
                /*  591 */
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                /*  592 */
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*  593 */
                return;
                /*      */
            }

            int ret = GameUtil.duiwudengjicmp(chara1, GameObjectChar.getGameObjectChar(), 45, 79);
            if (ret != 0) {
                /*  497 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  498 */
                if (ret == 1) {
                    vo_20481_0.msg = "小于45级不可以领取任务！";
                } else {
                    vo_20481_0.msg = "道友道行深厚，已无需在此处降妖，请去更高级的地方！";
                }
                /*  499 */
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                /*  500 */
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*  501 */
                return;
                /*      */
            }

            /*  595 */
            if (!GameUtil.duiwudengji(chara1, GameObjectChar.getGameObjectChar())) {
                /*  596 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  597 */
                vo_20481_0.msg = "人物等级相差10级，不能接任务！";
                /*  598 */
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                /*  599 */
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*      */
            }
            /*  601 */
            List<RenwuMonster> all = GameData.that.baseRenwuMonsterService.findByType(Integer.valueOf(2));
            /*  602 */
            Random random = new Random();
            /*  603 */
            int i = random.nextInt(all.size());
            /*  604 */
            RenwuMonster renwuMonster = (RenwuMonster) all.get(i);
            /*  605 */
            String s = GameUtil.getRandomJianHan() + "的" + renwuMonster.getName();
            /*  606 */
            org.linlinjava.litemall.db.domain.Renwu tasks = GameData.that.baseRenwuService.findOneByCurrentTask(chara1.current_task);
            /*  607 */
            org.linlinjava.litemall.db.domain.Map map = GameData.that.baseMapService.findOneByName(renwuMonster.getMapName());
            /*  608 */
            if (map == null) {
                /*  609 */
                System.out.println(renwuMonster.getMapName());
                /*  610 */
                return;
                /*      */
            }
            /*  612 */
            chara1.npcshuadao = new ArrayList();
            /*  613 */
            Vo_65529_0 vo_65529_0 = new Vo_65529_0();
            /*  614 */
            vo_65529_0.mapid = map.getMapId().intValue();
            /*  615 */
            vo_65529_0.id = GameUtil.getCard(chara1);
            /*  616 */
            vo_65529_0.x = renwuMonster.getX().intValue();
            /*  617 */
            vo_65529_0.y = renwuMonster.getY().intValue();
            /*  618 */
            vo_65529_0.icon = renwuMonster.getIcon().intValue();
            /*  619 */
            vo_65529_0.type = 2;
            /*  620 */
            vo_65529_0.org_icon = renwuMonster.getIcon().intValue();
            /*  621 */
            vo_65529_0.portrait = renwuMonster.getIcon().intValue();
            /*  622 */
            vo_65529_0.name = s;
            /*  623 */
            vo_65529_0.level = chara1.level;
            /*  624 */
            vo_65529_0.leixing = 2;
            /*  625 */
            chara1.npcshuadao.add(vo_65529_0);
            /*      */
            /*      */
            /*  628 */
            Vo_61553_0 vo_61553_0 = new Vo_61553_0();
            /*  629 */
            vo_61553_0.count = 1;
            /*  630 */
            vo_61553_0.task_type = "降妖";
            /*  631 */
            vo_61553_0.task_desc = "";
            /*  632 */
            vo_61553_0.task_prompt = ("降妖#P" + s + "|" + renwuMonster.getMapName() + "(" + renwuMonster.getX() + "," + renwuMonster.getY() + ")|M=今天我要为民除害|$0#P");
            /*  633 */
            vo_61553_0.refresh = 1;
            /*  634 */
            vo_61553_0.task_end_time = 1567909190;
            /*  635 */
            vo_61553_0.attrib = 1;
            /*  636 */
            vo_61553_0.reward = "#I经验|人物经验宠物经验#I#I道行|道行#I#I潜能|潜能#I#I武学|武学#I#I金钱|金钱#I";
            /*  637 */
            int cishu = chara1.shuadao % 10;
            /*  638 */
            if (cishu == 0) {
                /*  639 */
                cishu = 10;
                /*      */
            }
            /*  641 */
            vo_61553_0.show_name = ("降妖(" + cishu + "/10)");
            /*  642 */
            vo_61553_0.tasktask_extra_para = "";
            /*  643 */
            vo_61553_0.tasktask_state = "1";
            /*  644 */
            GameObjectChar.sendduiwu(new MSG_TASK_PROMPT(), vo_61553_0, chara1.id);
            /*      */
            /*      */
            /*      */
            /*  648 */
            org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0 vo_45063_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0();
            /*  649 */
            vo_45063_0.task_name = vo_61553_0.task_prompt;
            /*  650 */
            vo_45063_0.check_point = 147761859;
            /*  651 */
            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45063_0(), vo_45063_0, chara1.id);
            /*      */
            /*      */
            /*  654 */
            org.linlinjava.litemall.gameserver.data.vo.Vo_45092_0 vo_45092_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45092_0();
            /*  655 */
            vo_45092_0.task_name = "降妖";
            /*  656 */
            vo_45092_0.check_point = 40;
            /*  657 */
            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45092_0(), vo_45092_0, chara1.id);
            /*      */
            /*  659 */
            org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0 vo_8165_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0();
            /*  660 */
            vo_8165_0.msg = ("现有#Y" + s + "#n在#R" + renwuMonster.getMapName() + "#n附近出没，速去将其降伏！");
            /*  661 */
            vo_8165_0.active = 0;
            /*  662 */
            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M8165_0(), vo_8165_0, chara1.id);
            /*      */
            /*  664 */
            if (chara1.mapid == ((Vo_65529_0) chara1.npcshuadao.get(0)).mapid) {
                /*  665 */
                GameObjectChar.sendduiwu(new MSG_APPEAR(), chara1.npcshuadao.get(0), chara1.id);
                /*      */
            }
            /*      */
        }
        /*      */
        /*      */
        /*  670 */
        if ((id == 928) &&
                /*  671 */       (menu_item.equals("【领取法宝】提交#R蟠螭结、雪魂丝链#n"))) {
            /*  672 */
            boolean banlijie = false;
            /*  673 */
            boolean xuehunsilian = false;
            /*  674 */
            for (int i = 0; i < chara1.backpack.size(); i++) {
                /*  675 */
                if (((Goods) chara1.backpack.get(i)).goodsInfo.str.equals("蟠螭结")) {
                    /*  676 */
                    banlijie = true;
                    /*      */
                }
                /*  678 */
                if (((Goods) chara1.backpack.get(i)).goodsInfo.str.equals("雪魂丝链")) {
                    /*  679 */
                    xuehunsilian = true;
                    /*      */
                }
                /*      */
            }
            /*  682 */
            if ((banlijie) && (xuehunsilian)) {
                /*  683 */
                GameUtil.shuafabao(chara1);
                /*  684 */
                GameUtil.removemunber(chara1, "蟠螭结", 1);
                /*  685 */
                GameUtil.removemunber(chara1, "雪魂丝链", 1);
                /*  686 */
                Vo_61553_0 vo_61553_10 = new Vo_61553_0();
                /*  687 */
                vo_61553_10.count = 1;
                /*  688 */
                vo_61553_10.task_type = "法宝任务";
                /*  689 */
                vo_61553_10.task_desc = "";
                /*  690 */
                vo_61553_10.task_prompt = "";
                /*  691 */
                vo_61553_10.refresh = 0;
                /*  692 */
                vo_61553_10.task_end_time = 1567932239;
                /*  693 */
                vo_61553_10.attrib = 0;
                /*  694 */
                vo_61553_10.reward = "";
                /*  695 */
                vo_61553_10.show_name = "法宝任务";
                /*  696 */
                vo_61553_10.tasktask_extra_para = "";
                /*  697 */
                vo_61553_10.tasktask_state = "1";
                /*  698 */
                GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_10);
                /*  699 */
                chara1.fabaorenwu += 1;
                /*      */
            } else {
                /*  701 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  702 */
                vo_20481_0.msg = "首饰不足！";
                /*  703 */
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                /*  704 */
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*      */
            }
            /*      */
        }
        /*      */
        /*      */
        /*  709 */
        if ((id == 976) &&
                /*  710 */       (menu_item.equals("【法宝任务】我对法宝感兴趣"))) {
            /*  711 */
            if (chara1.fabaorenwu != 0) {
                /*  712 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  713 */
                vo_20481_0.msg = "今天已经领取任务了！";
                /*  714 */
                vo_20481_0.time = 1562987118;
                /*  715 */
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*      */
            } else {
                /*  717 */
                Vo_61553_0 vo_61553_10 = new Vo_61553_0();
                /*  718 */
                vo_61553_10.count = 1;
                /*  719 */
                vo_61553_10.task_type = "法宝任务";
                /*  720 */
                vo_61553_10.task_desc = "为获得强大的法宝而接受重重考验的任务。";
                /*  721 */
                vo_61553_10.task_prompt = "找#P龙王#P求取法宝";
                /*  722 */
                vo_61553_10.refresh = 0;
                /*  723 */
                vo_61553_10.task_end_time = 1567932239;
                /*  724 */
                vo_61553_10.attrib = 0;
                /*  725 */
                vo_61553_10.reward = "#I法宝|随机法宝=F$1$6#I";
                /*  726 */
                vo_61553_10.show_name = "法宝任务";
                /*  727 */
                vo_61553_10.tasktask_extra_para = "";
                /*  728 */
                vo_61553_10.tasktask_state = "0";
                /*  729 */
                GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_10);
                /*  730 */
                chara1.fabaorenwu += 1;
                /*  731 */
                return;
                /*      */
            }
            /*      */
        }
        /*      */
        /*      */
        /*      */
        /*      */
        /*  738 */
        if (menu_item.equals("sm-002_s1")) {
            /*  739 */
            String[] npces = {"李总兵", "杨镖头", "董老头", "五行竞猜使", "逍遥仙", "陆压真人", "无名武器店老板", "清微真人", "龙王", "杜卜思", "屠娇娇", "管神工", "天机老人"};
            /*  740 */
            Random random = new Random();
            /*  741 */
            int i = random.nextInt(npces.length);
            /*  742 */
            chara1.shimencishu += 1;
            /*      */
            /*  744 */
            if (chara1.shimencishu > 10) {
                /*  745 */
                chara1.npcName = "";
                /*  746 */
                Vo_61553_0 vo_61553_10 = new Vo_61553_0();
                /*  747 */
                vo_61553_10.count = 1;
                /*  748 */
                vo_61553_10.task_type = "sm-002";
                /*  749 */
                vo_61553_10.task_desc = "";
                /*  750 */
                vo_61553_10.task_prompt = "";
                /*  751 */
                vo_61553_10.refresh = 0;
                /*  752 */
                vo_61553_10.task_end_time = 1567932239;
                /*  753 */
                vo_61553_10.attrib = 0;
                /*  754 */
                vo_61553_10.reward = "#I经验|人物经验宠物经验#I#I金钱|金钱#I";
                /*  755 */
                vo_61553_10.show_name = "";
                /*  756 */
                vo_61553_10.tasktask_extra_para = "";
                /*  757 */
                vo_61553_10.tasktask_state = "1";
                /*  758 */
                GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_10);
                /*  759 */
                return;
                /*      */
            }
            /*  761 */
            chara1.npcName = npces[i];
            /*  762 */
            Vo_61553_0 vo_61553_10 = new Vo_61553_0();
            /*  763 */
            vo_61553_10.count = 1;
            /*  764 */
            vo_61553_10.task_type = "sm-002";
            /*  765 */
            vo_61553_10.task_desc = "接受门派师尊交办的一些事情，完成后会获得嘉奖。";
            /*  766 */
            vo_61553_10.task_prompt = ("拜访#P" + npces[i] + "|M=【师门】入世#P");
            /*  767 */
            vo_61553_10.refresh = 0;
            /*  768 */
            vo_61553_10.task_end_time = 1567932239;
            /*  769 */
            vo_61553_10.attrib = 0;
            /*  770 */
            vo_61553_10.reward = "#I经验|人物经验宠物经验#I#I金钱|金钱#I";
            /*  771 */
            vo_61553_10.show_name = ("师门—入世(" + chara1.shimencishu + "/10)");
            /*  772 */
            vo_61553_10.tasktask_extra_para = "";
            /*  773 */
            vo_61553_10.tasktask_state = "1";
            /*  774 */
            GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_10);
            /*  775 */
            GameUtil.huodejingyan(chara1, (int) (1420 * chara1.level * (1.0D + 0.1D * chara1.shimencishu)));
            /*  776 */
            chara1.use_money_type += (int) (chara1.level / 10 * 4374 * (1.0D + 0.1D * chara1.shimencishu));
            /*  777 */
            ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara1);
            /*  778 */
            GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
            /*      */
        }
        /*      */
        /*  781 */
        if ((id == 831) || (id == 1068) || (id == 1019) || (id == 1107) || (id == 943)) {
            /*  782 */
            int[] menpai = {831, 1068, 1019, 1107, 943};
            /*  783 */
            if (menpai[(chara1.menpai - 1)] != id) {
                /*  784 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  785 */
                vo_20481_0.msg = "来错门派了！";
                /*  786 */
                vo_20481_0.time = 1562987118;
                /*  787 */
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*  788 */
                return;
                /*      */
            }
            /*      */
            /*  791 */
            String[] npces = {"李总兵", "杨镖头", "董老头", "五行竞猜使", "逍遥仙", "陆压真人", "无名武器店老板", "清微真人", "龙王", "杜卜思", "屠娇娇", "管神工", "天机老人"};
            /*  792 */
            Random random = new Random();
            /*  793 */
            int i = random.nextInt(npces.length);
            /*  794 */
            if (menu_item.equals("师门任务_s0")) {
                /*  795 */
                if (chara1.shimencishu > 10) {
                    /*  796 */
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    /*  797 */
                    vo_20481_0.msg = "今天已完成任务";
                    /*  798 */
                    vo_20481_0.time = 1562987118;
                    /*  799 */
                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    /*  800 */
                    return;
                    /*      */
                }
                /*  802 */
                if (!chara1.npcName.equals("")) {
                    /*  803 */
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    /*  804 */
                    vo_20481_0.msg = "请完成当前任务";
                    /*  805 */
                    vo_20481_0.time = 1562987118;
                    /*  806 */
                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    /*  807 */
                    return;
                    /*      */
                }
                /*  809 */
                chara1.npcName = npces[i];
                /*  810 */
                Vo_61553_0 vo_61553_10 = new Vo_61553_0();
                /*  811 */
                vo_61553_10.count = 1;
                /*  812 */
                vo_61553_10.task_type = "sm-002";
                /*  813 */
                vo_61553_10.task_desc = "接受门派师尊交办的一些事情，完成后会获得嘉奖。";
                /*  814 */
                vo_61553_10.task_prompt = ("拜访#P" + npces[i] + "|M=【师门】入世#P");
                /*  815 */
                vo_61553_10.refresh = 0;
                /*  816 */
                vo_61553_10.task_end_time = 1567932239;
                /*  817 */
                vo_61553_10.attrib = 0;
                /*  818 */
                vo_61553_10.reward = "#I经验|人物经验宠物经验#I#I金钱|金钱#I";
                /*  819 */
                vo_61553_10.show_name = ("师门—入世(" + chara1.shimencishu + "/10)");
                /*  820 */
                vo_61553_10.tasktask_extra_para = "";
                /*  821 */
                vo_61553_10.tasktask_state = "1";
                /*  822 */
                GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_10);
                /*      */
            }
            /*      */
        }
        /*      */
        /*      */
        /*      */
        /*  828 */
        if (id == 958) {
            /*  829 */
            if (menu_item.equals("助人为乐_s0"))
                /*      */ {
                /*  831 */
                if ((chara1.baibangmang >= 1) || (chara1.level < 40)) {
                    /*  832 */
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    /*  833 */
                    vo_20481_0.msg = "你今天已经帮了我大忙了，还是先休息休息吧。";
                    /*  834 */
                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                    /*  835 */
                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    /*  836 */
                    return;
                    /*      */
                }
                /*      */
                /*  839 */
                org.linlinjava.litemall.gameserver.data.vo.Vo_8247_0 vo_8247_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_8247_0();
                /*  840 */
                vo_8247_0.id = id;
                /*  841 */
                vo_8247_0.portrait = 6010;
                /*  842 */
                vo_8247_0.pic_no = 1;
                /*  843 */
                vo_8247_0.content = "天墉城里的百姓有了麻烦事都爱找我帮忙，忙不过来啊，你能来帮帮忙吗？[【助人】捐助穷人领取经验奖励/助人为乐_sa][【助人】捐助穷人领取道行奖励/助人为乐_sb][【助人】捐助穷人领取潜能奖励/助人为乐_sc][离开/离开]".replace("\\", "");
                /*  844 */
                vo_8247_0.secret_key = "";
                /*  845 */
                vo_8247_0.name = "白邦芒";
                /*  846 */
                vo_8247_0.attrib = 0;
                /*  847 */
                GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M8247_0(), vo_8247_0);
                /*  848 */
                return;
                /*      */
            }
            /*  850 */
            if (menu_item.equals("助人为乐_sa"))
                /*      */ {
                /*      */
                /*  853 */
                if ((chara1.use_money_type < chara1.level / 10 * 25) && (chara1.balance < chara1.level / 10 * 25)) {
                    /*  854 */
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    /*  855 */
                    vo_20481_0.msg = "金币不够，代金券不够，无法领取奖励";
                    /*  856 */
                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                    /*  857 */
                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    /*  858 */
                    return;
                    /*      */
                }
                /*  860 */
                if (chara1.use_money_type < chara1.level / 10 * 25) {
                    /*  861 */
                    chara1.balance -= chara1.level / 10 * 25;
                    /*      */
                } else {
                    /*  863 */
                    chara1.use_money_type -= chara1.level / 10 * 25;
                    /*      */
                }
                /*  865 */
                GameUtil.huodejingyan(chara1, 15689 * chara1.level);
                /*  866 */
                GameUtil.weijianding(chara1);
                /*      */
                /*  868 */
                ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara1);
                /*  869 */
                GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
                /*      */
                /*  871 */
                chara1.baibangmang = 1;
                /*  872 */
                return;
                /*      */
            }
            /*      */
            /*  875 */
            if (menu_item.equals("助人为乐_sb")) {
                /*  876 */
                if ((chara1.use_money_type < chara1.level / 10 * 25) && (chara1.balance < chara1.level / 10 * 25)) {
                    /*  877 */
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    /*  878 */
                    vo_20481_0.msg = "金币不够，代金券不够，无法领取奖励";
                    /*  879 */
                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                    /*  880 */
                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    /*  881 */
                    return;
                    /*      */
                }
                /*  883 */
                if (chara1.use_money_type < chara1.level / 10 * 25) {
                    /*  884 */
                    chara1.balance -= chara1.level / 10 * 25;
                    /*      */
                } else {
                    /*  886 */
                    chara1.use_money_type -= chara1.level / 10 * 25;
                    /*      */
                }
                /*  888 */
                int base_dh = (int) (0.29D * chara1.level * chara1.level * chara1.level);
                /*      */
                /*  890 */
                int owner_name = 3392 * chara1.level / (chara1.friend > base_dh ? chara1.friend / base_dh : 1);
                /*  891 */
                GameUtil.adddaohang(chara1, owner_name);
                /*  892 */
                for (int i = 0; i < chara1.pets.size(); i++) {
                    /*  893 */
                    if (((Petbeibao) chara1.pets.get(i)).id == chara1.chongwuchanzhanId) {
                        /*  894 */
                        ((PetShuXing) ((Petbeibao) chara1.pets.get(i)).petShuXing.get(0)).intimacy += 76 * ((PetShuXing) ((Petbeibao) chara1.pets.get(i)).petShuXing.get(0)).skill;
                        /*  895 */
                        List<Petbeibao> list = new ArrayList();
                        /*  896 */
                        list.add(chara1.pets.get(i));
                        /*  897 */
                        GameObjectChar.send(new MSG_UPDATE_PETS(), list);
                        /*  898 */
                        break;
                        /*      */
                    }
                    /*      */
                }
                /*  901 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  902 */
                vo_20481_0.msg = ("获得道行#R" + 3392 * chara1.level / 1440 + "天");
                /*  903 */
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                /*  904 */
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*  905 */
                ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara1);
                /*  906 */
                GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
                /*      */
                /*  908 */
                GameUtil.weijianding(chara1);
                /*      */
                /*  910 */
                chara1.baibangmang = 1;
                /*      */
            }
            /*  912 */
            if (menu_item.equals("助人为乐_sc"))
                /*      */ {
                /*      */
                /*  915 */
                if ((chara1.use_money_type < chara1.level / 10 * 25) && (chara1.balance < chara1.level / 10 * 25)) {
                    /*  916 */
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    /*  917 */
                    vo_20481_0.msg = "金币不够，代金券不够，无法领取奖励";
                    /*  918 */
                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                    /*  919 */
                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    /*  920 */
                    return;
                    /*      */
                }
                /*  922 */
                if (chara1.use_money_type < chara1.level / 10 * 25) {
                    /*  923 */
                    chara1.balance -= chara1.level / 10 * 25;
                    /*      */
                } else {
                    /*  925 */
                    chara1.use_money_type -= chara1.level / 10 * 25;
                    /*      */
                }
                /*      */
                /*  928 */
                chara1.cash += 3392 * chara1.level;
                /*      */
                /*  930 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  931 */
                vo_20481_0.msg = ("获得潜能#R" + 3392 * chara1.level);
                /*      */
                /*  933 */
                vo_20481_0.time = 1562987118;
                /*  934 */
                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*      */
                /*  936 */
                ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara1);
                /*  937 */
                GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
                /*      */
                /*  939 */
                GameUtil.weijianding(chara1);
                /*      */
                /*  941 */
                chara1.baibangmang = 1;
                /*      */
            }
            /*  943 */
            return;
            /*      */
        }
        /*      */
        /*      */
        /*  947 */
        for (int i = 0; i < chara1.npcchubao.size(); i++) {
            /*  948 */
            if ((((Vo_65529_0) chara1.npcchubao.get(i)).id == id) &&
                    /*  949 */         (menu_item.equals("就是来抓你的"))) {
                /*  950 */
                Random random = new Random();
                /*  951 */
                List<String> list = new ArrayList();
                /*  952 */
                list.add(((Vo_65529_0) chara1.npcchubao.get(0)).name);
                /*  953 */
                for (int j = 0; j < random.nextInt(3) + 6; j++) {
                    /*  954 */
                    int i1 = random.nextInt(2);
                    /*  955 */
                    if (i1 == 1) {
                        /*  956 */
                        list.add("帮凶");
                        /*      */
                    } else {
                        /*  958 */
                        list.add("喽啰");
                        /*      */
                    }
                    /*      */
                }
                /*  961 */
                org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list);
                /*      */
            }
            /*      */
        }
        /*      */
        /*      */
        /*  966 */
        for (int i = 0; i < chara1.npcshuadao.size(); i++) {
            /*  967 */
            if ((((Vo_65529_0) chara1.npcshuadao.get(i)).id == id) &&
                    /*  968 */         (menu_item.equals("今天我要为民除害"))) {
                /*  969 */
                Random random = new Random();
                /*  970 */
                List<String> list = new ArrayList();
                /*  971 */
                if (((Vo_65529_0) chara1.npcshuadao.get(0)).leixing == 2) {
                    /*  972 */
                    list.add(((Vo_65529_0) chara1.npcshuadao.get(0)).name);
                    /*  973 */
                    for (int j = 0; j < random.nextInt(3) + 6; j++) {
                        /*  974 */
                        int i1 = random.nextInt(4);
                        /*  975 */
                        if (i1 == 0) {
                            /*  976 */
                            list.add("疯魑");
                            /*      */
                        }
                        /*  978 */
                        if (i1 == 1) {
                            /*  979 */
                            list.add("狂魍");
                            /*      */
                        }
                        /*  981 */
                        if (i1 == 2) {
                            /*  982 */
                            list.add("黄怪");
                            /*      */
                        }
                        /*  984 */
                        if (i1 == 3) {
                            /*  985 */
                            list.add("蓝精");
                            /*      */
                        }
                        /*      */
                    }
                    /*  988 */
                    org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list);
                    /*      */
                }
                /*  990 */
                if ((((Vo_65529_0) chara1.npcshuadao.get(0)).leixing == 3) || (((Vo_65529_0) chara1.npcshuadao.get(0)).leixing == 4)) {
                    /*  991 */
                    list.add(((Vo_65529_0) chara1.npcshuadao.get(0)).name);
                    /*  992 */
                    list.add(((Vo_65529_0) chara1.npcshuadao.get(0)).name);
                    /*  993 */
                    list.add(((Vo_65529_0) chara1.npcshuadao.get(0)).name);
                    /*  994 */
                    for (int j = 0; j < random.nextInt(3) + 4; j++) {
                        /*  995 */
                        int i1 = random.nextInt(6);
                        /*  996 */
                        if (i1 == 0) {
                            /*  997 */
                            list.add("兑灵");
                            /*      */
                        }
                        /*  999 */
                        if (i1 == 1) {
                            /* 1000 */
                            list.add("艮灵");
                            /*      */
                        }
                        /* 1002 */
                        if (i1 == 2) {
                            /* 1003 */
                            list.add("坎灵");
                            /*      */
                        }
                        /* 1005 */
                        if (i1 == 3) {
                            /* 1006 */
                            list.add("离灵");
                            /*      */
                        }
                        /* 1008 */
                        if (i1 == 4) {
                            /* 1009 */
                            list.add("狂灵");
                            /*      */
                        }
                        /* 1011 */
                        if (i1 == 5) {
                            /* 1012 */
                            list.add("疯灵");
                            /*      */
                        }
                        /*      */
                    }
                    /* 1015 */
                    org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list);
                    /*      */
                }
                /*      */
            }
            /*      */
        }
        /*      */
        /*      */
        /*      */
        /*      */
        /* 1023 */
        if ((id == 956) &&
                /* 1024 */       (menu_item.equals("dispatch_chubao"))) {
            /* 1025 */
            if (chara1.chubao > 20) {
                /* 1026 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /* 1027 */
                vo_20481_0.msg = "你今天已经完成了";
                /* 1028 */
                vo_20481_0.time = 1562987118;
                /* 1029 */
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /* 1030 */
                return;
                /*      */
            }
            /*      */
            /* 1033 */
            List<RenwuMonster> all = GameData.that.baseRenwuMonsterService.findByType(Integer.valueOf(1));
            /* 1034 */
            Random random = new Random();
            /* 1035 */
            int i = random.nextInt(all.size());
            /* 1036 */
            RenwuMonster renwuMonster = (RenwuMonster) all.get(i);
            /* 1037 */
            String s = renwuMonster.getName() + GameUtil.getRandomJianHan();
            /* 1038 */
            org.linlinjava.litemall.db.domain.Renwu tasks = GameData.that.baseRenwuService.findOneByCurrentTask(chara1.current_task);
            /* 1039 */
            org.linlinjava.litemall.db.domain.Map map = GameData.that.baseMapService.findOneByName(renwuMonster.getMapName());
            /* 1040 */
            chara1.npcchubao = new ArrayList();
            /* 1041 */
            Vo_65529_0 vo_65529_0 = new Vo_65529_0();
            /* 1042 */
            vo_65529_0.mapid = map.getMapId().intValue();
            /* 1043 */
            vo_65529_0.id = GameUtil.getCard(chara1);
            /* 1044 */
            vo_65529_0.x = renwuMonster.getX().intValue();
            /* 1045 */
            vo_65529_0.y = renwuMonster.getY().intValue();
            /* 1046 */
            vo_65529_0.icon = renwuMonster.getIcon().intValue();
            /* 1047 */
            vo_65529_0.type = 2;
            /* 1048 */
            vo_65529_0.org_icon = renwuMonster.getIcon().intValue();
            /* 1049 */
            vo_65529_0.portrait = renwuMonster.getIcon().intValue();
            /* 1050 */
            vo_65529_0.name = s;
            /* 1051 */
            vo_65529_0.level = chara1.level;
            /* 1052 */
            vo_65529_0.leixing = 1;
            /* 1053 */
            chara1.npcchubao.add(vo_65529_0);
            /*      */
            /*      */
            /* 1056 */
            Vo_61553_0 vo_61553_0 = new Vo_61553_0();
            /* 1057 */
            vo_61553_0.count = 1;
            /* 1058 */
            vo_61553_0.task_type = "为民除暴";
            /* 1059 */
            vo_61553_0.task_desc = ("当前第" + chara1.chubao % 10 + "轮任务：前往#R" + renwuMonster.getMapName() + "#n附近捉拿#Y#P" + s + "|" + renwuMonster.getMapName() + "(" + renwuMonster.getX() + "," + renwuMonster.getY() + ")|M=就是来抓你的|$0#P#n等人。领取任务15分钟后未完成将会失败，当前剩余#R15分钟#n。（本任务队员离队、暂离、换线、下线或转移队长时会消失，任务轮次不会清除，每天只可获得20次奖励");
            /* 1060 */
            vo_61553_0.task_prompt = ("捉拿#P" + s + "|" + renwuMonster.getMapName() + "(" + renwuMonster.getX() + "," + renwuMonster.getY() + ")|M=就是来抓你的|$0#P");
            /* 1061 */
            vo_61553_0.refresh = 1;
            /* 1062 */
            vo_61553_0.task_end_time = ((int) (System.currentTimeMillis() / 1000L));
            /* 1063 */
            vo_61553_0.attrib = 1;
            /* 1064 */
            vo_61553_0.reward = "#I经验|人物经验宠物经验#I#I道行|道行#I#I潜能|潜能#I#I武学|武学#I#I金钱|金钱#I";
            /* 1065 */
            int cishu = chara1.chubao % 10;
            /* 1066 */
            if (cishu == 0) {
                /* 1067 */
                cishu = 10;
                /*      */
            }
            /* 1069 */
            vo_61553_0.show_name = ("为民除暴(" + cishu + "/10)");
            /* 1070 */
            vo_61553_0.tasktask_extra_para = "";
            /* 1071 */
            vo_61553_0.tasktask_state = "1";
            /* 1072 */
            GameObjectChar.sendduiwu(new MSG_TASK_PROMPT(), vo_61553_0, chara1.id);
            /*      */
            /* 1074 */
            org.linlinjava.litemall.gameserver.data.vo.Vo_45092_0 vo_45092_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45092_0();
            /* 1075 */
            vo_45092_0.task_name = "为民除暴";
            /* 1076 */
            vo_45092_0.check_point = 40;
            /* 1077 */
            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45092_0(), vo_45092_0, chara1.id);
            /*      */
        }
        /*      */
        /*      */
        /* 1081 */
        if ((id == 985) &&
                /* 1082 */       (menu_item.equals("五行生肖乐"))) {
            /* 1083 */
            org.linlinjava.litemall.gameserver.data.vo.Vo_40995_0 vo_40995_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_40995_0();
            /* 1084 */
            vo_40995_0.flag = 0;
            /* 1085 */
            vo_40995_0.money = 0;
            /* 1086 */
            vo_40995_0.surlus = String.valueOf(chara1.wuxingBalance);
            /* 1087 */
            vo_40995_0.overflow = "0";
            /* 1088 */
            vo_40995_0.amount = 1000;
            /* 1089 */
            vo_40995_0.choice = 32;
            /* 1090 */
            vo_40995_0.prize = 41;
            /* 1091 */
            vo_40995_0.leftCount = 77;
            /* 1092 */
            GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40995_0(), vo_40995_0);
            /*      */
        }
        /*      */
        /*      */
        /*      */
        /*      */
        /* 1098 */
        if (id == 973) {
            /* 1099 */
            if (menu_item.equals("我要兑换变异宠物")) {
                /* 1100 */
                org.linlinjava.litemall.gameserver.data.vo.Vo_53249_0 vo_53249_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_53249_0();
                /* 1101 */
                vo_53249_0.type = 1;
                /* 1102 */
                vo_53249_0.count = 12;
                /* 1103 */
                vo_53249_0.name0 = "伶俐鼠";
                /* 1104 */
                vo_53249_0.price0 = 100;
                /* 1105 */
                vo_53249_0.name1 = "笨笨牛";
                /* 1106 */
                vo_53249_0.price1 = 100;
                /* 1107 */
                vo_53249_0.name2 = "威威虎";
                /* 1108 */
                vo_53249_0.price2 = 100;
                /* 1109 */
                vo_53249_0.name3 = "跳跳兔";
                /* 1110 */
                vo_53249_0.price3 = 100;
                /* 1111 */
                vo_53249_0.name4 = "酷酷龙";
                /* 1112 */
                vo_53249_0.price4 = 100;
                /* 1113 */
                vo_53249_0.name5 = "花花蛇";
                /* 1114 */
                vo_53249_0.price5 = 100;
                /* 1115 */
                vo_53249_0.name6 = "溜溜马";
                /* 1116 */
                vo_53249_0.price6 = 100;
                /* 1117 */
                vo_53249_0.name7 = "咩咩羊";
                /* 1118 */
                vo_53249_0.price7 = 100;
                /* 1119 */
                vo_53249_0.name8 = "帅帅猴";
                /* 1120 */
                vo_53249_0.price8 = 100;
                /* 1121 */
                vo_53249_0.name9 = "蛋蛋鸡";
                /* 1122 */
                vo_53249_0.price9 = 100;
                /* 1123 */
                vo_53249_0.name10 = "乖乖狗";
                /* 1124 */
                vo_53249_0.price10 = 100;
                /* 1125 */
                vo_53249_0.name11 = "招财猪";
                /* 1126 */
                vo_53249_0.price11 = 100;
                /* 1127 */
                GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M53249_0(), vo_53249_0);
                /*      */
            }
            /* 1129 */
            if (menu_item.equals("我要兑换神兽宠物")) {
                /* 1130 */
                org.linlinjava.litemall.gameserver.data.vo.Vo_53249_1 vo_53249_1 = new org.linlinjava.litemall.gameserver.data.vo.Vo_53249_1();
                /* 1131 */
                vo_53249_1.type = 2;
                /* 1132 */
                vo_53249_1.count = 6;
                /* 1133 */
                vo_53249_1.name0 = "疆良";
                /* 1134 */
                vo_53249_1.price0 = 100;
                /* 1135 */
                vo_53249_1.name1 = "东山神灵";
                /* 1136 */
                vo_53249_1.price1 = 100;
                /* 1137 */
                vo_53249_1.name2 = "玄武";
                /* 1138 */
                vo_53249_1.price2 = 100;
                /* 1139 */
                vo_53249_1.name3 = "朱雀";
                /* 1140 */
                vo_53249_1.price3 = 100;
                /* 1141 */
                vo_53249_1.name4 = "九尾狐";
                /* 1142 */
                vo_53249_1.price4 = 100;
                /* 1143 */
                vo_53249_1.name5 = "白矖";
                /* 1144 */
                vo_53249_1.price5 = 100;
                /* 1145 */
                GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M53249_1(), vo_53249_1);
                /*      */
            }
            /*      */
        }
        /*      */
        /*      */
        /*      */
        /* 1151 */
        if ((id == 1180) &&
                /* 1152 */       (menu_item.equals("召唤精怪"))) {
            /* 1153 */
            org.linlinjava.litemall.gameserver.data.vo.Vo_9129_0 vo_9129_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_9129_0();
            /* 1154 */
            vo_9129_0.notify = 97;
            /* 1155 */
            vo_9129_0.para = "PetCallDlg";
            /* 1156 */
            GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M9129_0(), vo_9129_0);
            /*      */
        }
        /*      */
        /* 1159 */
        if ((id == 1180) &&
                /* 1160 */       (menu_item.equals("驯化精怪"))) {
            /* 1161 */
            org.linlinjava.litemall.gameserver.data.vo.Vo_41041_0 vo_41041_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_41041_0();
            /* 1162 */
            vo_41041_0.type = 2;
            /* 1163 */
            vo_41041_0.limitNum = 0;
            /* 1164 */
            vo_41041_0.count = 0;
            /* 1165 */
            GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M41041_0(), vo_41041_0);
            /* 1166 */
            GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M4155_0(), Integer.valueOf(0));
            /*      */
        }
        /*      */
        /*      */
        /*      */
        /*      */
        /* 1172 */
        if (id == 978) {
            /* 1173 */
            if (menu_item.equals("清理背包")) {
                /* 1174 */
                List<Goods> listbeibao = new ArrayList();
                /* 1175 */
                for (int i = 0; i < chara1.backpack.size(); i++) {
                    /* 1176 */
                    if (((Goods) chara1.backpack.get(i)).pos > 10) {
                        /* 1177 */
                        List<Goods> listbeibao1 = new ArrayList();
                        /* 1178 */
                        Goods goods2 = new Goods();
                        /* 1179 */
                        goods2.goodsBasics = null;
                        /* 1180 */
                        goods2.goodsInfo = null;
                        /* 1181 */
                        goods2.goodsLanSe = null;
                        /* 1182 */
                        goods2.pos = ((Goods) chara1.backpack.get(i)).pos;
                        /* 1183 */
                        listbeibao.add(chara1.backpack.get(i));
                        /* 1184 */
                        listbeibao1.add(goods2);
                        /* 1185 */
                        GameObjectChar.send(new MSG_INVENTORY(), listbeibao1);
                        /*      */
                    }
                    /*      */
                }
                /*      */
                /* 1189 */
                for (int i = 0; i < listbeibao.size(); i++) {
                    /* 1190 */
                    chara1.backpack.remove(listbeibao.get(i));
                    /*      */
                }
                /* 1192 */
            } else if (!menu_item.equals("离开")) {
                /* 1193 */
                int petId = Integer.parseInt(menu_item);
                /* 1194 */
                for (int i = 0; i < chara1.pets.size(); i++) {
                    /* 1195 */
                    if (petId == ((Petbeibao) chara1.pets.get(i)).id) {
                        /* 1196 */
                        chara1.pets.remove(chara1.pets.get(i));
                        /* 1197 */
                        org.linlinjava.litemall.gameserver.data.vo.Vo_12269_0 vo_12269_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_12269_0();
                        /* 1198 */
                        vo_12269_0.id = petId;
                        /* 1199 */
                        vo_12269_0.owner_id = 96780;
                        /* 1200 */
                        GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M12269_0(), vo_12269_0);
                        /*      */
                    }
                    /*      */
                }
                /*      */
            }
            /*      */
        }
        /*      */
        /*      */
        /*      */
        /*      */
        /*      */
        /* 1210 */
        if (menu_item.equals("我要购买野生宠物")) {
            /* 1211 */
            List<org.linlinjava.litemall.db.domain.CreepsStore> creepsStoreList = GameData.that.baseCreepsStoreService.findAll();
            /* 1212 */
            GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40967_0(), creepsStoreList);
            /*      */
        }
        /*      */
        /*      */
        /* 1216 */
        if (menu_item.equals("买卖")) {
            /* 1217 */
            List<org.linlinjava.litemall.db.domain.MedicineShop> medicineShopList = GameData.that.baseMedicineShopService.findAll();
            /* 1218 */
            GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M65503_0(), medicineShopList);
            /*      */
        }
        /*      */
        /* 1221 */
        if (menu_item.equals("我要做买卖")) {
            /* 1222 */
            List<org.linlinjava.litemall.db.domain.GroceriesShop> groceriesShopList = GameData.that.baseGroceriesShopService.findAll();
            /* 1223 */
            GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M65503_0(), groceriesShopList);
            /*      */
        }
        /*      */
        /*      */
        /* 1227 */
        Chara chara = GameObjectChar.getGameObjectChar().chara;
        /* 1228 */
        org.linlinjava.litemall.db.domain.Npc npc = GameData.that.baseNpcService.findById(id);
        /* 1229 */
        if (npc == null) {
            /* 1230 */
            return;
            /*      */
        }
        /*      */
        /* 1233 */
        List<org.linlinjava.litemall.db.domain.NpcDialogueFrame> npcDialogueFrameList = GameData.that.baseNpcDialogueFrameService.findByName(npc.getName());
        /*      */
        /* 1235 */
        GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M4155_0(), Integer.valueOf(id));
        /*      */
        /* 1237 */
        if (!menu_item.equals("离开")) {
            /* 1238 */
            if (chara.current_task.equals(menu_item))
                /*      */ {
                /* 1240 */
                if (chara.current_task.equals("主线—浮生若梦_s1")) {
                    /* 1241 */
                    geizhuangb(chara);
                    /*      */
                }
                /*      */
                /* 1244 */
                GameUtil.renwujiangli(chara);
                /* 1245 */
                if (chara.current_task.equals("主线—浮生若梦_s22")) {
                    /* 1246 */
                    String[] chenghao = {"五龙山云霄洞第一代弟子", "终南山玉柱洞第一代弟子", "凤凰山斗阙宫第一代弟子", "乾元山金光洞第一代弟子", "骷髅山白骨洞第一代弟子"};
                    /* 1247 */
                    String chenhao = chenghao[(chara.menpai - 1)];
                    /* 1248 */
                    chara.chenghao.put("拜师任务", chenhao);
                    /* 1249 */
                    GameUtil.chenghaoxiaoxi(chara);
                    /*      */
                    /* 1251 */
                    Vo_20481_0 vo_20481_9 = new Vo_20481_0();
                    /* 1252 */
                    vo_20481_9.msg = ("你获得了#R" + chenhao + "#n的称谓。");
                    /* 1253 */
                    vo_20481_9.time = 1567221761;
                    /* 1254 */
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_9);
                    /* 1255 */
                    List<RenwuMonster> all = GameData.that.baseRenwuMonsterService.findByType(Integer.valueOf(1));
                    /* 1256 */
                    Random random = new Random();
                    /* 1257 */
                    int i = random.nextInt(all.size());
                    /* 1258 */
                    RenwuMonster renwuMonster = (RenwuMonster) all.get(i);
                    /* 1259 */
                    String s = renwuMonster.getName() + GameUtil.getRandomJianHan();
                    /* 1260 */
                    Vo_61553_0 vo_61553_0 = new Vo_61553_0();
                    /* 1261 */
                    vo_61553_0.count = 1;
                    /* 1262 */
                    vo_61553_0.task_type = "为民除暴";
                    /* 1263 */
                    vo_61553_0.task_desc = "为民除暴";
                    /* 1264 */
                    vo_61553_0.task_prompt = "去#P李总兵|E=【除暴】除暴安良|$0#P那里看看";
                    /* 1265 */
                    vo_61553_0.refresh = 1;
                    /* 1266 */
                    vo_61553_0.task_end_time = 1567909190;
                    /* 1267 */
                    vo_61553_0.attrib = 1;
                    /* 1268 */
                    vo_61553_0.reward = "#I经验|人物经验宠物经验#I#I道行|道行#I#I潜能|潜能#I#I武学|武学#I#I金钱|金钱#I";
                    /* 1269 */
                    vo_61553_0.show_name = "为民除暴";
                    /* 1270 */
                    vo_61553_0.tasktask_extra_para = "";
                    /* 1271 */
                    vo_61553_0.tasktask_state = "1";
                    /* 1272 */
                    GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_0);
                    /*      */
                }
                /* 1274 */
                chara.current_task = GameUtil.nextrenw(menu_item);
                /* 1275 */
                org.linlinjava.litemall.db.domain.Renwu tasks = GameData.that.baseRenwuService.findOneByCurrentTask(chara.current_task);
                /* 1276 */
                Vo_61553_0 vo_61553_0 = GameUtil.a61553(tasks, chara);
                /* 1277 */
                GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_0);
                /*      */
            }
            /*      */
            /*      */
            /*      */
            /* 1282 */
            ListVo_65527_0 vo_65527_0 = GameUtil.a65527(chara);
            /* 1283 */
            GameObjectChar.send(new MSG_UPDATE(), vo_65527_0);
            /* 1284 */
            GameUtil.MSG_UPDATE_IMPROVEMENT(chara);
            /*      */
        }
        /* 1286 */
        org.linlinjava.litemall.gameserver.data.vo.Vo_45056_0 vo_45056_0 = GameUtil.a45056(chara);
        /* 1287 */
        GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M45056_0(), vo_45056_0);
        /*      */
        /* 1289 */
        ListVo_65527_0 vo_65527_0 = GameUtil.a65527(chara);
        /* 1290 */
        GameObjectChar.send(new MSG_UPDATE(), vo_65527_0);
        /*      */
    }

    /*      */
    /*      */
    /*      */
    /*      */
    /*      */
    /*      */
    public int cmd()
    /*      */ {
        /* 1299 */
        return 12344;
        /*      */
    }

    /*      */
    /*      */
    public void geizhuangb(Chara chara) {
        /* 1303 */
        ZhuangbeiInfo zhuangb = new ZhuangbeiInfo();
        /* 1304 */
        List<ZhuangbeiInfo> byAttrib = GameData.that.baseZhuangbeiInfoService.findByAttrib(Integer.valueOf(1));
        /* 1305 */
        for (int i = 0; i < byAttrib.size(); i++) {
            /* 1306 */
            if ((((ZhuangbeiInfo) byAttrib.get(i)).getMetal().intValue() == chara.menpai) && (((ZhuangbeiInfo) byAttrib.get(i)).getAmount().intValue() == 1)) {
                /* 1307 */
                zhuangb = (ZhuangbeiInfo) byAttrib.get(i);
                /* 1308 */
                GameUtil.huodezhuangbei(chara, zhuangb, 0);
                /* 1309 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /* 1310 */
                vo_20481_0.msg = ("你获得了1把#R" + zhuangb.getStr() + "#n。");
                /* 1311 */
                vo_20481_0.time = 1562987118;
                /* 1312 */
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*      */
                /* 1314 */
                org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0 vo_20480_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0();
                /* 1315 */
                vo_20480_0.msg = "你获得了#R260#n点经验。";
                /* 1316 */
                vo_20480_0.time = 1562593376;
                /* 1317 */
                GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M20480_0(), vo_20480_0);
                /* 1318 */
                org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0 vo_8165_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0();
                /* 1319 */
                vo_8165_0.msg = ("你获得了#R260#n经验、1把#R" + zhuangb.getStr() + "#n。");
                /* 1320 */
                vo_8165_0.active = 0;
                /* 1321 */
                GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M8165_0(), vo_8165_0);
                /* 1322 */
                org.linlinjava.litemall.gameserver.data.vo.Vo_40964_0 vo_40964_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_40964_0();
                /* 1323 */
                vo_40964_0.type = 1;
                /* 1324 */
                vo_40964_0.name = zhuangb.getStr().toString();
                /* 1325 */
                vo_40964_0.param = "98107";
                /* 1326 */
                vo_40964_0.rightNow = 1;
                /* 1327 */
                GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40964_0(), vo_40964_0);
                /*      */
                /* 1329 */
                org.linlinjava.litemall.gameserver.data.vo.Vo_40965_0 vo_40965_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_40965_0();
                /* 1330 */
                vo_40965_0.guideId = 19;
                /* 1331 */
                GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40965_0(), vo_40965_0);
                /*      */
            }
            /*      */
        }
        /*      */
    }
    /*      */
}


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C12344_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */