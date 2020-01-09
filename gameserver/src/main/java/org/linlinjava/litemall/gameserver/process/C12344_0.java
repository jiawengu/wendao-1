package org.linlinjava.litemall.gameserver.process;

import org.linlinjava.litemall.core.util.JSONUtils;
import org.linlinjava.litemall.db.domain.Accounts;
import org.linlinjava.litemall.db.domain.NpcDialogue;
import org.linlinjava.litemall.db.domain.RenwuMonster;
import org.linlinjava.litemall.db.domain.ZhuangbeiInfo;
import org.linlinjava.litemall.gameserver.data.vo.*;
import org.linlinjava.litemall.gameserver.data.write.*;
import org.linlinjava.litemall.db.domain.*;
import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_61553_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
import org.linlinjava.litemall.gameserver.data.write.M20481_0;
import org.linlinjava.litemall.gameserver.data.write.M61553_0;
import org.linlinjava.litemall.gameserver.data.write.M65527_0;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.Goods;
import org.linlinjava.litemall.gameserver.domain.PetShuXing;
import org.linlinjava.litemall.gameserver.domain.Petbeibao;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.linlinjava.litemall.gameserver.game.GameShangGuYaoWang;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Random;

@org.springframework.stereotype.Service
public class C12344_0<main> implements org.linlinjava.litemall.gameserver.GameHandler {
    public int[] coins = { 18000, 90000, 360000, 750000, 1284000, 1800000, 2844000, 3900000, 9000000, 14400000,
            25500000 };
    public int[] jiage = { 6, 30, 100, 200, 328, 500, 648, 1000, 2000, 3000, 5000 };

    public void process(io.netty.channel.ChannelHandlerContext ctx, io.netty.buffer.ByteBuf buff) {

        int id = org.linlinjava.litemall.gameserver.data.GameReadTool.readInt(buff);

        String menu_item = org.linlinjava.litemall.gameserver.data.GameReadTool.readString(buff);

        String para = org.linlinjava.litemall.gameserver.data.GameReadTool.readString(buff);

        Chara chara1 = GameObjectChar.getGameObjectChar().chara;

        System.out.println(String.format("点击按钮:menu_item[%s];id[%s]", menu_item, id));

        String name;

        if (id == 992) {

            org.linlinjava.litemall.db.domain.Characters characters = GameData.that.baseCharactersService
                    .findById(chara1.id);

            Accounts accounts = GameData.that.baseAccountsService.findById(characters.getAccountId().intValue());

            if (menu_item.equals("1000积分")) {

                if ((accounts.getChongzhijifen() != null) || (accounts.getChongzhijifen().intValue() < 1000)) {

                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = "积分不足";

                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                    GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M20481_0(), vo_20481_0);

                    return;

                }

                accounts.setChongzhijifen(Integer.valueOf(accounts.getChongzhijifen().intValue() - 1000));

                String[] mounts_name = { "岳麓剑", "古鹿", "北极熊", "筋斗云" };

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

                GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M65507_0(), list);

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = ("恭喜获得#R" + s);

                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M20481_0(), vo_20481_0);

                ZhuangbeiInfo oneByStr = GameData.that.baseZhuangbeiInfoService.findOneByStr("七龙珠");

                GameUtil.huodezhuangbeixiangwu(chara1, oneByStr, 0, 1);

            }

            if (menu_item.equals("3000积分")) {

                if ((accounts.getChongzhijifen() != null) || (accounts.getChongzhijifen().intValue() < 3000)) {

                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = "积分不足";

                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                    GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M20481_0(), vo_20481_0);

                    return;

                }

                accounts.setChongzhijifen(Integer.valueOf(accounts.getChongzhijifen().intValue() - 3000));

                String[] mounts_name = { "九尾狐", "白矖", "疆良", "玄武", "朱雀", "东山神灵" };

                Random random = new Random();

                String s = mounts_name[random.nextInt(mounts_name.length)];

                org.linlinjava.litemall.db.domain.Pet pet = GameData.that.basePetService.findOneByName(s);

                Petbeibao petbeibao = new Petbeibao();

                petbeibao.PetCreate(pet, chara1, 0, 4);

                List<Petbeibao> list = new ArrayList();

                chara1.pets.add(petbeibao);

                list.add(petbeibao);

                GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M65507_0(), list);

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = ("恭喜获得#R" + s);

                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M20481_0(), vo_20481_0);

                ZhuangbeiInfo oneByStr = GameData.that.baseZhuangbeiInfoService.findOneByStr("天机锁链");

                GameUtil.huodezhuangbeixiangwu(chara1, oneByStr, 0, 1);

            }

            if (menu_item.equals("5000积分")) {

                if ((accounts.getChongzhijifen() != null) || (accounts.getChongzhijifen().intValue() < 5000)) {

                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = "积分不足";

                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                    GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M20481_0(), vo_20481_0);

                    return;

                }

                accounts.setChongzhijifen(Integer.valueOf(accounts.getChongzhijifen().intValue() - 5000));

                String[] mounts_name = { "墨麒麟", "太极熊" };

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

                GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M65507_0(), list);

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = ("恭喜获得#R" + name);

                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M20481_0(), vo_20481_0);

                ZhuangbeiInfo oneByStr = GameData.that.baseZhuangbeiInfoService.findOneByStr("闭月双环");

                GameUtil.huodezhuangbeixiangwu(chara1, oneByStr, 0, 1);

            }

            GameData.that.baseAccountsService.updateById(accounts);

        }

        if ((id == 1151) && (menu_item.equals("赠送元宝"))) {

            org.linlinjava.litemall.db.domain.Characters characters = GameData.that.characterService
                    .findById(chara1.id);

            Accounts accounts = GameData.that.baseAccountsService.findById(characters.getAccountId().intValue());

            List<org.linlinjava.litemall.db.domain.Charge> chargeList = GameData.that.baseChargeService
                    .findByAccountname(accounts.getName());

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

                GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M65527_0(), listVo_65527_0);

                accounts.setChongzhiyuanbao(Integer.valueOf(0));

                GameData.that.baseAccountsService.updateById(accounts);

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = "领取元宝成功";

                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M20481_0(), vo_20481_0);

            } else {

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = "暂无可领取的元宝";

                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M20481_0(), vo_20481_0);

            }

        }

        if ((id == 1170) && (menu_item.equals("离开战场"))) {

            GameUtilRenWu.shidaohuicheng(chara1);

        }

        if (menu_item.equals("开始战斗")) {

            List<String> list = new ArrayList();

            for (int j = 0; j < 10; j++) {

                list.add("试道元魔");

            }

            org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list);

            GameObjectChar.getGameObjectChar().gameMap
                    .send(new org.linlinjava.litemall.gameserver.data.write.M12285_1(), Integer.valueOf(id));

            for (int i = 0; i < GameObjectChar.getGameObjectChar().gameMap.gameShiDao.shidaoyuanmo.size(); i++) {

                if (id == ((Vo_65529_0) GameObjectChar.getGameObjectChar().gameMap.gameShiDao.shidaoyuanmo.get(i)).id) {

                    GameObjectChar.getGameObjectChar().gameMap.gameShiDao.shidaoyuanmo
                            .remove(GameObjectChar.getGameObjectChar().gameMap.gameShiDao.shidaoyuanmo.get(i));

                }

            }

        }

        /**
         * 进入通天塔
         */
        if (id == 960 && (menu_item.equals("通天塔"))) {
            System.out.println(menu_item);
            org.linlinjava.litemall.db.domain.Map map = GameData.that.baseMapService.findOneByName(menu_item);
            chara1.y = map.getY().intValue();
            chara1.x = map.getX().intValue();
            org.linlinjava.litemall.gameserver.game.GameLine.getGameMapname(chara1.line, map.getName())
                    .join(GameObjectChar.getGameObjectChar());
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
            return;
        }

        if ((id == 962) && (menu_item.equals("世道进入"))) {
            String shidaoname = GameUtilRenWu.shidaolevel(chara1);
            org.linlinjava.litemall.db.domain.Map map = GameData.that.baseMapService.findOneByName(shidaoname);
            if (map == null) {
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                if (shidaoname == "不在活动时间内")
                    vo_20481_0.msg = shidaoname;
                else
                    vo_20481_0.msg = "不符合条件";
                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                GameObjectChar.send(new M20481_0(), vo_20481_0);
                return;
            }
            chara1.y = map.getY().intValue();
            chara1.x = map.getX().intValue();
            org.linlinjava.litemall.gameserver.game.GameLine.getGameMapname(chara1.line, map.getName())
                    .join(GameObjectChar.getGameObjectChar());
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

        if ((id == 928) && (menu_item.equals("法宝亲密丹"))) {

            Boolean has = Boolean.valueOf(false);

            for (int i = 0; i < chara1.backpack.size(); i++) {

                if ((((Goods) chara1.backpack.get(i)).pos == 9) && (chara1.extra_life > 500)) {

                    chara1.extra_life -= 500;

                    ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara1);

                    GameObjectChar.send(new M65527_0(), listVo_65527_0);

                    ((Goods) chara1.backpack.get(i)).goodsInfo.shape += 1000;

                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = ("你的法宝#Y" + ((Goods) chara1.backpack.get(i)).goodsInfo.str + "#n获得了#R1000#n亲密");

                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new M20481_0(), vo_20481_0);

                    has = Boolean.valueOf(true);

                }

            }

            if (!has.booleanValue()) {

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = "你身上没有法宝！";

                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new M20481_0(), vo_20481_0);

            }

        }

        if (id == 829 && menu_item.equals("挑战掌门")) {
            String strArr[] = new String[] { "金系掌门", "木系掌门", "水系掌门", "火系掌门", "土系掌门" };
            List<String> list = new ArrayList();
            list.add(strArr[(chara1.menpai + 4) % 5]);
            // todo

            org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list);
        }
//        ShangGuYaoWangInfo info =
//                GameData.that.BaseShangGuYaoWangInfoService.findByNpcID(id,
//                        true);
//        if (menu_item.equals("挑战") && null != info){
//            if (GameObjectChar.getGameObjectChar().gameTeam == null){
//                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
//                vo_20481_0.msg = "人数不足3人！";
//                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
//                GameObjectChar.getGameObjectChar();
//                GameObjectChar.send(new M20481_0(), vo_20481_0);
//                return;
//            }
//
//            List<Chara> duiwu = GameObjectChar.getGameObjectChar().gameTeam.duiwu;
//
//            if (duiwu.size() < 3) {
//                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
//                vo_20481_0.msg = "人数不足3人！";
//                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
//                GameObjectChar.getGameObjectChar();
//                GameObjectChar.send(new M20481_0(), vo_20481_0);
//                return;
//
//            }
//            for (int i = 0; i < duiwu.size(); i++) {
//                Chara tempChara = duiwu.get(i);
//                org.linlinjava.litemall.db.domain.Characters characters = GameData.that.baseCharactersService.findById(tempChara.id);
//
//            SimpleDateFormat sdf= new SimpleDateFormat("yyyy-MM-dd");
//            Date date = new Date();
//
//        if ((org.linlinjava.litemall.gameserver.game.GameShuaGuai.list.contains(Integer.valueOf(id)))
//                && (menu_item.equals("我是来向你挑战的"))) {
//                long count =
//                        GameData.that.BaseShangGuYaoWangRewardInfoService.count(characters.getAccountId(), sdf.format(date));
//                if (count > 5) {
//
//                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
//
//                    vo_20481_0.msg = tempChara.name + "已经获取5次奖励了";
//
//                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
//
//                    GameObjectChar.getGameObjectChar();
//                    GameObjectChar.send(new M20481_0(), vo_20481_0);
//                    return;
//                }
//            }
//
//            org.linlinjava.litemall.db.domain.Npc npc =
//                    GameData.that.baseNpcService.findById(id);
//
//            List<String> list = new ArrayList();
//            list.add(npc.getName());
//
//            Random RANDOM = new Random();
////            ShangGuYaoWangInfo  info =
////                    GameData.that.BaseShangGuYaoWangInfoService.findByNpcID(npc.getId());
//            String []  xiaoGuai = info.getXiaoGuai().split(",");
//
//
//            for(int a = 0; a < 9; ++a) {
//                list.add(xiaoGuai[RANDOM.nextInt(xiaoGuai.length)]);
//            }
//
//            org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list);
//        }
//
//            for (int i = 0; i < org.linlinjava.litemall.gameserver.game.GameLine.gameShuaGuai.shuaXing.size(); i++) {
//
//                if (id == ((Vo_65529_0) org.linlinjava.litemall.gameserver.game.GameLine.gameShuaGuai.shuaXing
//                        .get(i)).id) {
//
//                    List<String> list = new ArrayList();
//
//                    list.add(((Vo_65529_0) org.linlinjava.litemall.gameserver.game.GameLine.gameShuaGuai.shuaXing
//                            .get(i)).name);
//
//                    for (int j = 0; j < 9; j++) {
//
//                        list.add("星");
//
//                    }
//
//                    org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list,
//                            (Vo_65529_0) org.linlinjava.litemall.gameserver.game.GameLine.gameShuaGuai.shuaXing.get(i));
//
//                }
//
//            }
//
//        }

        for (int i = 0; i < chara1.npcxuanshang.size(); i++) {

            if ((((Vo_65529_0) chara1.npcxuanshang.get(i)).id == id) && (menu_item.equals("追拿通缉犯"))) {

                List<String> list = new ArrayList();

                for (int j = 0; j < 5; j++) {

                    list.add("仙界叛逆");

                }

                org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list);

            }

        }

        if (id == 1195) {

            if ((menu_item.equals("我想领取悬赏经验")) && (chara1.npcXuanShangName.equals("领取奖励"))) {

                chara1.npcXuanShangName = "";

                int jingyan = 7975 * chara1.level;

                GameUtil.huodejingyan(chara1, jingyan);

            }

            if ((menu_item.equals("我想领取悬赏道行")) && (chara1.npcXuanShangName.equals("领取奖励"))) {

                int base_pet_dh = (int) (0.29D * chara1.level * chara1.level * chara1.level);

                chara1.npcXuanShangName = "";

                int owner_name = 2634 * chara1.level / (chara1.friend > base_pet_dh ? chara1.friend / base_pet_dh : 1);

                GameUtil.adddaohang(chara1, owner_name);

                for (int i = 0; i < chara1.pets.size(); i++) {

                    if (((Petbeibao) chara1.pets.get(i)).id == chara1.chongwuchanzhanId) {

                        PetShuXing petShuXing = (PetShuXing) ((Petbeibao) chara1.pets.get(i)).petShuXing.get(0);

                        base_pet_dh = (int) (0.29D * petShuXing.skill * petShuXing.skill * petShuXing.skill);

                        int intimacy = 878 * petShuXing.skill
                                / (petShuXing.intimacy > base_pet_dh ? petShuXing.intimacy / base_pet_dh : 1);

                        petShuXing.intimacy += intimacy;

                        Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                        vo_20481_0.msg = ("宠物获得武学#R" + intimacy);

                        vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                        GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M20481_0(), vo_20481_0);

                    }

                }

                ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara1);

                GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M65527_0(), listVo_65527_0);

            }

            if (menu_item.equals("领取悬赏任务")) {

                boolean b = GameUtil.belongCalendar();

                if (!b) {

                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = "不在任务时间段";

                    vo_20481_0.time = 1562987118;

                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new M20481_0(), vo_20481_0);

                    return;

                }

                if (chara1.npcXuanShangName.equals("领取奖励")) {

                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = "请先领取奖励";

                    vo_20481_0.time = 1562987118;

                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new M20481_0(), vo_20481_0);

                    return;

                }

                if (chara1.xuanshangcishu >= 2) {

                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = "今天已经做完了";

                    vo_20481_0.time = 1562987118;

                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new M20481_0(), vo_20481_0);

                    return;

                }

                if (chara1.xuanshangcishu < 2) {

                    List<RenwuMonster> all = GameData.that.baseRenwuMonsterService.findByType(Integer.valueOf(5));

                    Random random = new Random();

                    int i = random.nextInt(all.size());

                    RenwuMonster renwuMonster = (RenwuMonster) all.get(i);

                    org.linlinjava.litemall.db.domain.Map map = GameData.that.baseMapService
                            .findOneByName(renwuMonster.getMapName());

                    chara1.npcxuanshang = new ArrayList();

                    chara1.npcXuanShangName = renwuMonster.getName();

                    Vo_65529_0 vo_65529_0 = new Vo_65529_0();

                    vo_65529_0.mapid = map.getMapId().intValue();

                    vo_65529_0.id = GameUtil.getCard(chara1);

                    vo_65529_0.x = renwuMonster.getX().intValue();

                    vo_65529_0.y = renwuMonster.getY().intValue();

                    vo_65529_0.icon = renwuMonster.getIcon().intValue();

                    vo_65529_0.type = 2;

                    vo_65529_0.org_icon = renwuMonster.getIcon().intValue();

                    vo_65529_0.portrait = renwuMonster.getIcon().intValue();

                    vo_65529_0.name = (chara1.name + "的仙界叛逆");

                    vo_65529_0.level = chara1.level;

                    vo_65529_0.leixing = 4;

                    chara1.npcxuanshang.add(vo_65529_0);

                    String task_type = "悬赏祍务";

                    String task_prompt = "捉拿逃窜的#P仙界叛逆|" + renwuMonster.getMapName() + "(" + renwuMonster.getX() + ","
                            + renwuMonster.getY() + ")|M=追拿通缉犯|$0#P（建议组队）";

                    String show_name = "悬赏祍务";

                    GameUtilRenWu.renwukuangkuang(task_type, task_prompt, show_name, chara1);

                }

            }

        }

        if ((id == 1184) && (menu_item.equals("十绝阵_s0"))) {

            if (GameObjectChar.getGameObjectChar().gameTeam == null) {

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

                if (((Chara) duiwu.get(i)).xiuxingcishu > 40) {

                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = (((Chara) duiwu.get(i)).name + "已完成任务");

                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new M20481_0(), vo_20481_0);

                    return;

                }

            }

            String[] npces = { "金光阵主", "风吼阵主", "落魄阵主", "化血阵主", "红水阵主", "寒冰阵主", "烈焰阵主", "地烈阵主", "天阙阵主", "红砂阵主" };

            int i = (chara1.xiuxingcishu + 9) % 10;

            chara1.xiuxingNpcname = npces[i];

            Vo_61553_0 vo_61553_10 = new Vo_61553_0();

            vo_61553_10.count = 1;

            vo_61553_10.task_type = "十绝阵";

            vo_61553_10.task_desc = "天法道、道法自然，此乃道义根本。十位上古仙神演自然玄机，终成十绝之阵。";

            vo_61553_10.task_prompt = ("拜访#P" + npces[i] + "|M=【十绝阵】请仙人赐教#P");

            vo_61553_10.refresh = 0;

            vo_61553_10.task_end_time = 1567932239;

            vo_61553_10.attrib = 0;

            vo_61553_10.reward = "#I经验|人物经验宠物经验#I#I金钱|金钱#I";

            vo_61553_10.show_name = ("【十绝阵】修行(" + ((chara1.xiuxingcishu + 9) % 10 + 1) + "/10)");

            vo_61553_10.tasktask_extra_para = "";

            vo_61553_10.tasktask_state = "1";

            GameObjectChar.sendduiwu(new M61553_0(), vo_61553_10, chara1.id);

            org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0 vo_45063_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0();
            vo_45063_0.task_name = vo_61553_10.task_prompt;
            vo_45063_0.check_point = 147761859;
            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45063_0(), vo_45063_0,
                    chara1.id);

        }
        if (menu_item.equals("十绝阵_s1")) {

            org.linlinjava.litemall.db.domain.Npc npc = GameData.that.baseNpcService
                    .findOneByName(chara1.xiuxingNpcname);

            if (npc == null) {

                return;

            }

            if (npc.getId().intValue() == id) {

                Random random = new Random();

                List<String> list = new ArrayList();

                list.add(chara1.xiuxingNpcname);

                for (int j = 0; j < 9; j++) {

                    int i1 = random.nextInt(6);

                    if (i1 == 0) {

                        list.add("兑灵");

                    }

                    if (i1 == 1) {

                        list.add("艮灵");

                    }

                    if (i1 == 2) {

                        list.add("坎灵");

                    }

                    if (i1 == 3) {

                        list.add("离灵");

                    }

                    if (i1 == 4) {

                        list.add("狂灵");

                    }

                    if (i1 == 5) {

                        list.add("疯灵");

                    }

                }

                org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list);

            }

        }

        if ((id == 1174) && (menu_item.equals("修行_s0"))) {

            if (GameObjectChar.getGameObjectChar().gameTeam == null) {

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

                if (((Chara) duiwu.get(i)).xiuxingcishu > 40) {

                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = (((Chara) duiwu.get(i)).name + "已完成任务");

                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new M20481_0(), vo_20481_0);

                    return;

                }

            }

            String[] npces = { "雷神", "花神", "炎神", "山神", "龙神" };

            Random random = new Random();

            int i = random.nextInt(npces.length);

            chara1.xiuxingNpcname = npces[i];

            Vo_61553_0 vo_61553_10 = new Vo_61553_0();

            vo_61553_10.count = 1;

            vo_61553_10.task_type = "修炼";

            vo_61553_10.task_desc = "接受门派师尊交办的一些事情，完成后会获得嘉奖。";

            vo_61553_10.task_prompt = ("拜访#P" + npces[i] + "|M=【修行】请仙人赐教#P");

            vo_61553_10.refresh = 0;

            vo_61553_10.task_end_time = 1567932239;

            vo_61553_10.attrib = 0;

            vo_61553_10.reward = "#I经验|人物经验宠物经验#I#I金钱|金钱#I";

            vo_61553_10.show_name = ("【修炼】修行(" + chara1.xiuxingcishu + "/10)");

            vo_61553_10.tasktask_extra_para = "";

            vo_61553_10.tasktask_state = "1";

            GameObjectChar.sendduiwu(new M61553_0(), vo_61553_10, chara1.id);

        }

        if (menu_item.equals("修行_s1")) {

            org.linlinjava.litemall.db.domain.Npc npc = GameData.that.baseNpcService
                    .findOneByName(chara1.xiuxingNpcname);

            if (npc == null) {

                return;

            }

            if (npc.getId().intValue() == id) {

                Random random = new Random();

                List<String> list = new ArrayList();

                list.add(chara1.xiuxingNpcname);

                for (int j = 0; j < 4; j++) {

                    int i1 = random.nextInt(6);

                    if (i1 == 0) {

                        list.add("兑灵");

                    }

                    if (i1 == 1) {

                        list.add("艮灵");

                    }

                    if (i1 == 2) {

                        list.add("坎灵");

                    }

                    if (i1 == 3) {

                        list.add("离灵");

                    }

                    if (i1 == 4) {

                        list.add("狂灵");

                    }

                    if (i1 == 5) {

                        list.add("疯灵");

                    }

                }

                org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list);

            }

        }
        if ((id == 1185) && (menu_item.equals("飞仙渡邪_dispatch"))) {

            if (GameObjectChar.getGameObjectChar().gameTeam == null) {

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

            if (!GameUtil.duiwudengji(chara1, GameObjectChar.getGameObjectChar())) {

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = "人物等级相差10级，不能接任务！";

                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new M20481_0(), vo_20481_0);

                return;

            }

            List<RenwuMonster> all = GameData.that.baseRenwuMonsterService.findByType(Integer.valueOf(4));

            Random random = new Random();

            int i = random.nextInt(all.size());

            RenwuMonster renwuMonster = (RenwuMonster) all.get(i);

            String s = renwuMonster.getName() + "的" + GameUtil.getRandomJianHan();

            org.linlinjava.litemall.db.domain.Map map = GameData.that.baseMapService
                    .findOneByName(renwuMonster.getMapName());

            if (map == null) {

                System.out.println(renwuMonster.getMapName());

                return;

            }

            chara1.npcshuadao = new ArrayList();

            Vo_65529_0 vo_65529_0 = new Vo_65529_0();

            vo_65529_0.mapid = map.getMapId().intValue();

            vo_65529_0.id = GameUtil.getCard(chara1);

            vo_65529_0.x = renwuMonster.getX().intValue();

            vo_65529_0.y = renwuMonster.getY().intValue();

            vo_65529_0.icon = renwuMonster.getIcon().intValue();

            vo_65529_0.type = 2;

            vo_65529_0.org_icon = renwuMonster.getIcon().intValue();

            vo_65529_0.portrait = renwuMonster.getIcon().intValue();

            vo_65529_0.name = s;

            vo_65529_0.level = chara1.level;

            vo_65529_0.leixing = 4;

            chara1.npcshuadao.add(vo_65529_0);

            Vo_61553_0 vo_61553_0 = new Vo_61553_0();

            vo_61553_0.count = 1;

            vo_61553_0.task_type = "飞仙渡邪";

            vo_61553_0.task_desc = "";

            vo_61553_0.task_prompt = ("渡邪#P" + s + "|" + renwuMonster.getMapName() + "(" + renwuMonster.getX() + ","
                    + renwuMonster.getY() + ")|M=今天我要为民除害|$0#P");

            vo_61553_0.refresh = 1;

            vo_61553_0.task_end_time = 1567909190;

            vo_61553_0.attrib = 1;

            vo_61553_0.reward = "#I经验|人物经验宠物经验#I#I道行|道行#I#I潜能|潜能#I#I武学|武学#I#I金钱|金钱#I";

            int cishu = chara1.shuadao % 10;

            if (cishu == 0) {

                cishu = 10;

            }

            vo_61553_0.show_name = ("飞仙渡邪(" + cishu + "/10)");

            vo_61553_0.tasktask_extra_para = "";

            vo_61553_0.tasktask_state = "1";

            GameObjectChar.sendduiwu(new M61553_0(), vo_61553_0, chara1.id);

            org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0 vo_45063_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0();

            vo_45063_0.task_name = vo_61553_0.task_prompt;

            vo_45063_0.check_point = 147761859;

            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45063_0(), vo_45063_0,
                    chara1.id);

            org.linlinjava.litemall.gameserver.data.vo.Vo_45092_0 vo_45092_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45092_0();

            vo_45092_0.task_name = "飞仙渡邪";

            vo_45092_0.check_point = 40;

            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45092_0(), vo_45092_0,
                    chara1.id);

            org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0 vo_8165_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0();

            vo_8165_0.msg = ("现有#Y" + s + "#n在#R" + renwuMonster.getMapName() + "#n附近出没，速去将其渡邪！");

            vo_8165_0.active = 0;

            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M8165_0(), vo_8165_0, chara1.id);

            if (chara1.mapid == ((Vo_65529_0) chara1.npcshuadao.get(0)).mapid) {

                GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M65529_0(),
                        chara1.npcshuadao.get(0), chara1.id);

            }

        }

        if ((id == 866) && (menu_item.equals("领取任务"))) {

            if (GameObjectChar.getGameObjectChar().gameTeam == null) {

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

            int ret = GameUtil.duiwudengjicmp(chara1, GameObjectChar.getGameObjectChar(), 80, 119);
            if (ret != 0) {

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                if (ret == 1) {
                    vo_20481_0.msg = "小于80级不可以领取任务！";
                } else {
                    vo_20481_0.msg = "道友道行深厚，已无需在此处降妖，请去更高级的地方！";
                }

                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new M20481_0(), vo_20481_0);

                return;

            }

            if (!GameUtil.duiwudengji(chara1, GameObjectChar.getGameObjectChar())) {

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = "人物等级相差10级，不能接任务！";

                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new M20481_0(), vo_20481_0);

                return;

            }

            List<RenwuMonster> all = GameData.that.baseRenwuMonsterService.findByType(Integer.valueOf(3));

            Random random = new Random();

            int i = random.nextInt(all.size());

            RenwuMonster renwuMonster = (RenwuMonster) all.get(i);

            String s = renwuMonster.getName() + "的" + GameUtil.getRandomJianHan();

            org.linlinjava.litemall.db.domain.Map map = GameData.that.baseMapService
                    .findOneByName(renwuMonster.getMapName());

            if (map == null) {

                System.out.println(renwuMonster.getMapName());

                return;

            }

            chara1.npcshuadao = new ArrayList();

            Vo_65529_0 vo_65529_0 = new Vo_65529_0();

            vo_65529_0.mapid = map.getMapId().intValue();

            vo_65529_0.id = GameUtil.getCard(chara1);

            vo_65529_0.x = renwuMonster.getX().intValue();

            vo_65529_0.y = renwuMonster.getY().intValue();

            vo_65529_0.icon = renwuMonster.getIcon().intValue();

            vo_65529_0.type = 2;

            vo_65529_0.org_icon = renwuMonster.getIcon().intValue();

            vo_65529_0.portrait = renwuMonster.getIcon().intValue();

            vo_65529_0.name = s;

            vo_65529_0.level = chara1.level;

            vo_65529_0.leixing = 3;

            chara1.npcshuadao.add(vo_65529_0);

            Vo_61553_0 vo_61553_0 = new Vo_61553_0();

            vo_61553_0.count = 1;

            vo_61553_0.task_type = "降妖";

            vo_61553_0.task_desc = "";

            vo_61553_0.task_prompt = ("降伏#P" + s + "|" + renwuMonster.getMapName() + "(" + renwuMonster.getX() + ","
                    + renwuMonster.getY() + ")|M=今天我要为民除害|$0#P");

            vo_61553_0.refresh = 1;

            vo_61553_0.task_end_time = 1567909190;

            vo_61553_0.attrib = 1;

            vo_61553_0.reward = "#I经验|人物经验宠物经验#I#I道行|道行#I#I潜能|潜能#I#I武学|武学#I#I金钱|金钱#I";

            int cishu = chara1.shuadao % 10;

            if (cishu == 0) {

                cishu = 10;

            }

            vo_61553_0.show_name = ("附魔(" + cishu + "/10)");

            vo_61553_0.tasktask_extra_para = "";

            vo_61553_0.tasktask_state = "1";

            GameObjectChar.sendduiwu(new M61553_0(), vo_61553_0, chara1.id);

            org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0 vo_45063_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0();

            vo_45063_0.task_name = vo_61553_0.task_prompt;

            vo_45063_0.check_point = 147761859;

            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45063_0(), vo_45063_0,
                    chara1.id);

            org.linlinjava.litemall.gameserver.data.vo.Vo_45092_0 vo_45092_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45092_0();

            vo_45092_0.task_name = "附魔";

            vo_45092_0.check_point = 40;

            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45092_0(), vo_45092_0,
                    chara1.id);

            org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0 vo_8165_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0();

            vo_8165_0.msg = ("现有#Y" + s + "#n在#R" + renwuMonster.getMapName() + "#n附近出没，速去将其降伏！");

            vo_8165_0.active = 0;

            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M8165_0(), vo_8165_0, chara1.id);

            if (chara1.mapid == ((Vo_65529_0) chara1.npcshuadao.get(0)).mapid) {

                GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M65529_0(),
                        chara1.npcshuadao.get(0), chara1.id);

            }

        }

        if ((id == 957) && (menu_item.equals("dispatch_xiangy"))) {

            if (GameObjectChar.getGameObjectChar().gameTeam == null) {

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

            int ret = GameUtil.duiwudengjicmp(chara1, GameObjectChar.getGameObjectChar(), 45, 79);
            if (ret != 0) {

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                if (ret == 1) {
                    vo_20481_0.msg = "小于45级不可以领取任务！";
                } else {
                    vo_20481_0.msg = "道友道行深厚，已无需在此处降妖，请去更高级的地方！";
                }

                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new M20481_0(), vo_20481_0);

                return;

            }

            if (!GameUtil.duiwudengji(chara1, GameObjectChar.getGameObjectChar())) {

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = "人物等级相差10级，不能接任务！";

                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new M20481_0(), vo_20481_0);

            }

            List<RenwuMonster> all = GameData.that.baseRenwuMonsterService.findByType(Integer.valueOf(2));

            Random random = new Random();

            int i = random.nextInt(all.size());

            RenwuMonster renwuMonster = (RenwuMonster) all.get(i);

            String s = GameUtil.getRandomJianHan() + "的" + renwuMonster.getName();

            org.linlinjava.litemall.db.domain.Renwu tasks = GameData.that.baseRenwuService
                    .findOneByCurrentTask(chara1.current_task);

            org.linlinjava.litemall.db.domain.Map map = GameData.that.baseMapService
                    .findOneByName(renwuMonster.getMapName());

            if (map == null) {

                System.out.println(renwuMonster.getMapName());

                return;

            }

            chara1.npcshuadao = new ArrayList();

            Vo_65529_0 vo_65529_0 = new Vo_65529_0();

            vo_65529_0.mapid = map.getMapId().intValue();

            vo_65529_0.id = GameUtil.getCard(chara1);

            vo_65529_0.x = renwuMonster.getX().intValue();

            vo_65529_0.y = renwuMonster.getY().intValue();

            vo_65529_0.icon = renwuMonster.getIcon().intValue();

            vo_65529_0.type = 2;

            vo_65529_0.org_icon = renwuMonster.getIcon().intValue();

            vo_65529_0.portrait = renwuMonster.getIcon().intValue();

            vo_65529_0.name = s;

            vo_65529_0.level = chara1.level;

            vo_65529_0.leixing = 2;

            chara1.npcshuadao.add(vo_65529_0);

            Vo_61553_0 vo_61553_0 = new Vo_61553_0();

            vo_61553_0.count = 1;

            vo_61553_0.task_type = "降妖";

            vo_61553_0.task_desc = "";

            vo_61553_0.task_prompt = ("降妖#P" + s + "|" + renwuMonster.getMapName() + "(" + renwuMonster.getX() + ","
                    + renwuMonster.getY() + ")|M=今天我要为民除害|$0#P");

            vo_61553_0.refresh = 1;

            vo_61553_0.task_end_time = 1567909190;

            vo_61553_0.attrib = 1;

            vo_61553_0.reward = "#I经验|人物经验宠物经验#I#I道行|道行#I#I潜能|潜能#I#I武学|武学#I#I金钱|金钱#I";

            int cishu = chara1.shuadao % 10;

            if (cishu == 0) {

                cishu = 10;

            }

            vo_61553_0.show_name = ("降妖(" + cishu + "/10)");

            vo_61553_0.tasktask_extra_para = "";

            vo_61553_0.tasktask_state = "1";

            GameObjectChar.sendduiwu(new M61553_0(), vo_61553_0, chara1.id);

            org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0 vo_45063_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0();

            vo_45063_0.task_name = vo_61553_0.task_prompt;

            vo_45063_0.check_point = 147761859;

            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45063_0(), vo_45063_0,
                    chara1.id);

            org.linlinjava.litemall.gameserver.data.vo.Vo_45092_0 vo_45092_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45092_0();

            vo_45092_0.task_name = "降妖";

            vo_45092_0.check_point = 40;

            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45092_0(), vo_45092_0,
                    chara1.id);

            org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0 vo_8165_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0();

            vo_8165_0.msg = ("现有#Y" + s + "#n在#R" + renwuMonster.getMapName() + "#n附近出没，速去将其降伏！");

            vo_8165_0.active = 0;

            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M8165_0(), vo_8165_0, chara1.id);

            if (chara1.mapid == ((Vo_65529_0) chara1.npcshuadao.get(0)).mapid) {

                GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M65529_0(),
                        chara1.npcshuadao.get(0), chara1.id);

            }

        }

        if ((id == 928) && (menu_item.equals("【领取法宝】提交#R蟠螭结、雪魂丝链#n"))) {

            boolean banlijie = false;

            boolean xuehunsilian = false;

            for (int i = 0; i < chara1.backpack.size(); i++) {

                if (((Goods) chara1.backpack.get(i)).goodsInfo.str.equals("蟠螭结")) {

                    banlijie = true;

                }

                if (((Goods) chara1.backpack.get(i)).goodsInfo.str.equals("雪魂丝链")) {

                    xuehunsilian = true;

                }

            }

            if ((banlijie) && (xuehunsilian)) {

                GameUtil.shuafabao(chara1);

                GameUtil.removemunber(chara1, "蟠螭结", 1);

                GameUtil.removemunber(chara1, "雪魂丝链", 1);

                Vo_61553_0 vo_61553_10 = new Vo_61553_0();

                vo_61553_10.count = 1;

                vo_61553_10.task_type = "法宝任务";

                vo_61553_10.task_desc = "";

                vo_61553_10.task_prompt = "";

                vo_61553_10.refresh = 0;

                vo_61553_10.task_end_time = 1567932239;

                vo_61553_10.attrib = 0;

                vo_61553_10.reward = "";

                vo_61553_10.show_name = "法宝任务";

                vo_61553_10.tasktask_extra_para = "";

                vo_61553_10.tasktask_state = "1";

                GameObjectChar.send(new M61553_0(), vo_61553_10);

                chara1.fabaorenwu += 1;

            } else {

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = "首饰不足！";

                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                GameObjectChar.send(new M20481_0(), vo_20481_0);

            }

        }

        if ((id == 976) && (menu_item.equals("【法宝任务】我对法宝感兴趣"))) {

            if (chara1.fabaorenwu != 0) {

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = "今天已经领取任务了！";

                vo_20481_0.time = 1562987118;

                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new M20481_0(), vo_20481_0);

            } else {

                Vo_61553_0 vo_61553_10 = new Vo_61553_0();

                vo_61553_10.count = 1;

                vo_61553_10.task_type = "法宝任务";

                vo_61553_10.task_desc = "为获得强大的法宝而接受重重考验的任务。";

                vo_61553_10.task_prompt = "找#P龙王#P求取法宝";

                vo_61553_10.refresh = 0;

                vo_61553_10.task_end_time = 1567932239;

                vo_61553_10.attrib = 0;

                vo_61553_10.reward = "#I法宝|随机法宝=F$1$6#I";

                vo_61553_10.show_name = "法宝任务";

                vo_61553_10.tasktask_extra_para = "";

                vo_61553_10.tasktask_state = "0";

                GameObjectChar.send(new M61553_0(), vo_61553_10);

                chara1.fabaorenwu += 1;

                return;

            }

        }

        if (menu_item.equals("sm-002_s1")) {

            String[] npces = { "李总兵", "杨镖头", "董老头", "五行竞猜使", "逍遥仙", "陆压真人", "无名武器店老板", "清微真人", "龙王", "杜卜思", "屠娇娇",
                    "管神工", "天机老人" };

            Random random = new Random();

            int i = random.nextInt(npces.length);

            chara1.shimencishu += 1;

            if (chara1.shimencishu > 10) {

                chara1.npcName = "";

                Vo_61553_0 vo_61553_10 = new Vo_61553_0();

                vo_61553_10.count = 1;

                vo_61553_10.task_type = "sm-002";

                vo_61553_10.task_desc = "";

                vo_61553_10.task_prompt = "";

                vo_61553_10.refresh = 0;

                vo_61553_10.task_end_time = 1567932239;

                vo_61553_10.attrib = 0;

                vo_61553_10.reward = "#I经验|人物经验宠物经验#I#I金钱|金钱#I";

                vo_61553_10.show_name = "";

                vo_61553_10.tasktask_extra_para = "";

                vo_61553_10.tasktask_state = "1";

                GameObjectChar.send(new M61553_0(), vo_61553_10);

                return;

            }

            chara1.npcName = npces[i];

            Vo_61553_0 vo_61553_10 = new Vo_61553_0();

            vo_61553_10.count = 1;

            vo_61553_10.task_type = "sm-002";

            vo_61553_10.task_desc = "接受门派师尊交办的一些事情，完成后会获得嘉奖。";

            vo_61553_10.task_prompt = ("拜访#P" + npces[i] + "|M=【师门】入世#P");

            vo_61553_10.refresh = 0;

            vo_61553_10.task_end_time = 1567932239;

            vo_61553_10.attrib = 0;

            vo_61553_10.reward = "#I经验|人物经验宠物经验#I#I金钱|金钱#I";

            vo_61553_10.show_name = ("师门—入世(" + chara1.shimencishu + "/10)");

            vo_61553_10.tasktask_extra_para = "";

            vo_61553_10.tasktask_state = "1";

            GameObjectChar.send(new M61553_0(), vo_61553_10);

            GameUtil.huodejingyan(chara1, (int) (1420 * chara1.level * (1.0D + 0.1D * chara1.shimencishu)));

            chara1.use_money_type += (int) (chara1.level / 10 * 4374 * (1.0D + 0.1D * chara1.shimencishu));

            ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara1);

            GameObjectChar.send(new M65527_0(), listVo_65527_0);

        }

        if ((id == 831) || (id == 1068) || (id == 1019) || (id == 1107) || (id == 943)) {

            int[] menpai = { 831, 1068, 1019, 1107, 943 };

            if (menpai[(chara1.menpai - 1)] != id) {

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = "来错门派了！";

                vo_20481_0.time = 1562987118;

                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new M20481_0(), vo_20481_0);

                return;

            }

            String[] npces = { "李总兵", "杨镖头", "董老头", "五行竞猜使", "逍遥仙", "陆压真人", "无名武器店老板", "清微真人", "龙王", "杜卜思", "屠娇娇",
                    "管神工", "天机老人" };

            Random random = new Random();

            int i = random.nextInt(npces.length);

            if (menu_item.equals("师门任务_s0")) {

                if (chara1.shimencishu > 10) {

                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = "今天已完成任务";

                    vo_20481_0.time = 1562987118;

                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new M20481_0(), vo_20481_0);

                    return;

                }

                if (!chara1.npcName.equals("")) {

                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = "请完成当前任务";

                    vo_20481_0.time = 1562987118;

                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new M20481_0(), vo_20481_0);

                    return;

                }

                chara1.npcName = npces[i];

                Vo_61553_0 vo_61553_10 = new Vo_61553_0();

                vo_61553_10.count = 1;

                vo_61553_10.task_type = "sm-002";

                vo_61553_10.task_desc = "接受门派师尊交办的一些事情，完成后会获得嘉奖。";

                vo_61553_10.task_prompt = ("拜访#P" + npces[i] + "|M=【师门】入世#P");

                vo_61553_10.refresh = 0;

                vo_61553_10.task_end_time = 1567932239;

                vo_61553_10.attrib = 0;

                vo_61553_10.reward = "#I经验|人物经验宠物经验#I#I金钱|金钱#I";

                vo_61553_10.show_name = ("师门—入世(" + chara1.shimencishu + "/10)");

                vo_61553_10.tasktask_extra_para = "";

                vo_61553_10.tasktask_state = "1";

                GameObjectChar.send(new M61553_0(), vo_61553_10);

            }

        }

        if (id == 958) {

            if (menu_item.equals("助人为乐_s0")) {

                if ((chara1.baibangmang >= 1) || (chara1.level < 40)) {

                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = "你今天已经帮了我大忙了，还是先休息休息吧。";

                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new M20481_0(), vo_20481_0);

                    return;

                }

                org.linlinjava.litemall.gameserver.data.vo.Vo_8247_0 vo_8247_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_8247_0();

                vo_8247_0.id = id;

                vo_8247_0.portrait = 6010;

                vo_8247_0.pic_no = 1;

                vo_8247_0.content = "天墉城里的百姓有了麻烦事都爱找我帮忙，忙不过来啊，你能来帮帮忙吗？[【助人】捐助穷人领取经验奖励/助人为乐_sa][【助人】捐助穷人领取道行奖励/助人为乐_sb][【助人】捐助穷人领取潜能奖励/助人为乐_sc][离开/离开]"
                        .replace("\\", "");

                vo_8247_0.secret_key = "";

                vo_8247_0.name = "白邦芒";

                vo_8247_0.attrib = 0;

                GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M8247_0(), vo_8247_0);

                return;

            }

            if (menu_item.equals("助人为乐_sa")) {

                if ((chara1.use_money_type < chara1.level / 10 * 25) && (chara1.balance < chara1.level / 10 * 25)) {

                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = "金币不够，代金券不够，无法领取奖励";

                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new M20481_0(), vo_20481_0);

                    return;

                }

                if (chara1.use_money_type < chara1.level / 10 * 25) {

                    chara1.balance -= chara1.level / 10 * 25;

                } else {

                    chara1.use_money_type -= chara1.level / 10 * 25;

                }

                GameUtil.huodejingyan(chara1, 15689 * chara1.level);

                GameUtil.weijianding(chara1);

                ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara1);

                GameObjectChar.send(new M65527_0(), listVo_65527_0);

                chara1.baibangmang = 1;

                return;

            }

            if (menu_item.equals("助人为乐_sb")) {

                if ((chara1.use_money_type < chara1.level / 10 * 25) && (chara1.balance < chara1.level / 10 * 25)) {

                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = "金币不够，代金券不够，无法领取奖励";

                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new M20481_0(), vo_20481_0);

                    return;

                }

                if (chara1.use_money_type < chara1.level / 10 * 25) {

                    chara1.balance -= chara1.level / 10 * 25;

                } else {

                    chara1.use_money_type -= chara1.level / 10 * 25;

                }

                int base_dh = (int) (0.29D * chara1.level * chara1.level * chara1.level);

                int owner_name = 3392 * chara1.level / (chara1.friend > base_dh ? chara1.friend / base_dh : 1);

                GameUtil.adddaohang(chara1, owner_name);

                for (int i = 0; i < chara1.pets.size(); i++) {

                    if (((Petbeibao) chara1.pets.get(i)).id == chara1.chongwuchanzhanId) {

                        ((PetShuXing) ((Petbeibao) chara1.pets.get(i)).petShuXing.get(0)).intimacy += 76
                                * ((PetShuXing) ((Petbeibao) chara1.pets.get(i)).petShuXing.get(0)).skill;

                        List<Petbeibao> list = new ArrayList();

                        list.add(chara1.pets.get(i));

                        GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M65507_0(), list);

                        break;

                    }

                }

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = ("获得道行#R" + 3392 * chara1.level / 1440 + "天");

                vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new M20481_0(), vo_20481_0);

                ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara1);

                GameObjectChar.send(new M65527_0(), listVo_65527_0);

                GameUtil.weijianding(chara1);

                chara1.baibangmang = 1;

            }

            if (menu_item.equals("助人为乐_sc")) {

                if ((chara1.use_money_type < chara1.level / 10 * 25) && (chara1.balance < chara1.level / 10 * 25)) {

                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = "金币不够，代金券不够，无法领取奖励";

                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));

                    GameObjectChar.getGameObjectChar();
                    GameObjectChar.send(new M20481_0(), vo_20481_0);

                    return;

                }

                if (chara1.use_money_type < chara1.level / 10 * 25) {

                    chara1.balance -= chara1.level / 10 * 25;

                } else {

                    chara1.use_money_type -= chara1.level / 10 * 25;

                }

                chara1.cash += 3392 * chara1.level;

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = ("获得潜能#R" + 3392 * chara1.level);

                vo_20481_0.time = 1562987118;

                GameObjectChar.getGameObjectChar();
                GameObjectChar.send(new M20481_0(), vo_20481_0);

                ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara1);

                GameObjectChar.send(new M65527_0(), listVo_65527_0);

                GameUtil.weijianding(chara1);

                chara1.baibangmang = 1;

            }

            return;

        }

        for (int i = 0; i < chara1.npcchubao.size(); i++) {

            if ((((Vo_65529_0) chara1.npcchubao.get(i)).id == id) && (menu_item.equals("就是来抓你的"))) {

                Random random = new Random();

                List<String> list = new ArrayList();

                list.add(((Vo_65529_0) chara1.npcchubao.get(0)).name);

                for (int j = 0; j < random.nextInt(3) + 6; j++) {

                    int i1 = random.nextInt(2);

                    if (i1 == 1) {

                        list.add("帮凶");

                    } else {

                        list.add("喽啰");

                    }

                }

                org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list);

            }

        }

        for (int i = 0; i < chara1.npcshuadao.size(); i++) {

            if ((((Vo_65529_0) chara1.npcshuadao.get(i)).id == id) && (menu_item.equals("今天我要为民除害"))) {

                Random random = new Random();

                List<String> list = new ArrayList();

                if (((Vo_65529_0) chara1.npcshuadao.get(0)).leixing == 2) {

                    list.add(((Vo_65529_0) chara1.npcshuadao.get(0)).name);

                    for (int j = 0; j < random.nextInt(3) + 6; j++) {

                        int i1 = random.nextInt(4);

                        if (i1 == 0) {

                            list.add("疯魑");

                        }

                        if (i1 == 1) {

                            list.add("狂魍");

                        }

                        if (i1 == 2) {

                            list.add("黄怪");

                        }

                        if (i1 == 3) {

                            list.add("蓝精");

                        }

                    }

                    org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list);

                }

                if ((((Vo_65529_0) chara1.npcshuadao.get(0)).leixing == 3)
                        || (((Vo_65529_0) chara1.npcshuadao.get(0)).leixing == 4)) {

                    list.add(((Vo_65529_0) chara1.npcshuadao.get(0)).name);

                    list.add(((Vo_65529_0) chara1.npcshuadao.get(0)).name);

                    list.add(((Vo_65529_0) chara1.npcshuadao.get(0)).name);

                    for (int j = 0; j < random.nextInt(3) + 4; j++) {

                        int i1 = random.nextInt(6);

                        if (i1 == 0) {

                            list.add("兑灵");

                        }

                        if (i1 == 1) {

                            list.add("艮灵");

                        }

                        if (i1 == 2) {

                            list.add("坎灵");

                        }

                        if (i1 == 3) {

                            list.add("离灵");

                        }

                        if (i1 == 4) {

                            list.add("狂灵");

                        }

                        if (i1 == 5) {

                            list.add("疯灵");

                        }

                    }

                    org.linlinjava.litemall.gameserver.fight.FightManager.goFight(chara1, list);

                }

            }

        }

        if ((id == 956) && (menu_item.equals("dispatch_chubao"))) {

            if (chara1.chubao > 20) {

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = "你今天已经完成了";

                vo_20481_0.time = 1562987118;

                GameObjectChar.send(new M20481_0(), vo_20481_0);

                return;

            }

            List<RenwuMonster> all = GameData.that.baseRenwuMonsterService.findByType(Integer.valueOf(1));

            Random random = new Random();

            int i = random.nextInt(all.size());

            RenwuMonster renwuMonster = (RenwuMonster) all.get(i);

            String s = renwuMonster.getName() + GameUtil.getRandomJianHan();

            org.linlinjava.litemall.db.domain.Renwu tasks = GameData.that.baseRenwuService
                    .findOneByCurrentTask(chara1.current_task);

            org.linlinjava.litemall.db.domain.Map map = GameData.that.baseMapService
                    .findOneByName(renwuMonster.getMapName());

            chara1.npcchubao = new ArrayList();

            Vo_65529_0 vo_65529_0 = new Vo_65529_0();

            vo_65529_0.mapid = map.getMapId().intValue();

            vo_65529_0.id = GameUtil.getCard(chara1);

            vo_65529_0.x = renwuMonster.getX().intValue();

            vo_65529_0.y = renwuMonster.getY().intValue();

            vo_65529_0.icon = renwuMonster.getIcon().intValue();

            vo_65529_0.type = 2;

            vo_65529_0.org_icon = renwuMonster.getIcon().intValue();

            vo_65529_0.portrait = renwuMonster.getIcon().intValue();

            vo_65529_0.name = s;

            vo_65529_0.level = chara1.level;

            vo_65529_0.leixing = 1;

            chara1.npcchubao.add(vo_65529_0);

            Vo_61553_0 vo_61553_0 = new Vo_61553_0();

            vo_61553_0.count = 1;

            vo_61553_0.task_type = "为民除暴";

            vo_61553_0.task_desc = ("当前第" + chara1.chubao % 10 + "轮任务：前往#R" + renwuMonster.getMapName() + "#n附近捉拿#Y#P"
                    + s + "|" + renwuMonster.getMapName() + "(" + renwuMonster.getX() + "," + renwuMonster.getY()
                    + ")|M=就是来抓你的|$0#P#n等人。领取任务15分钟后未完成将会失败，当前剩余#R15分钟#n。（本任务队员离队、暂离、换线、下线或转移队长时会消失，任务轮次不会清除，每天只可获得20次奖励");

            vo_61553_0.task_prompt = ("捉拿#P" + s + "|" + renwuMonster.getMapName() + "(" + renwuMonster.getX() + ","
                    + renwuMonster.getY() + ")|M=就是来抓你的|$0#P");

            vo_61553_0.refresh = 1;

            vo_61553_0.task_end_time = ((int) (System.currentTimeMillis() / 1000L));

            vo_61553_0.attrib = 1;

            vo_61553_0.reward = "#I经验|人物经验宠物经验#I#I道行|道行#I#I潜能|潜能#I#I武学|武学#I#I金钱|金钱#I";

            int cishu = chara1.chubao % 10;

            if (cishu == 0) {

                cishu = 10;

            }

            vo_61553_0.show_name = ("为民除暴(" + cishu + "/10)");

            vo_61553_0.tasktask_extra_para = "";

            vo_61553_0.tasktask_state = "1";

            GameObjectChar.sendduiwu(new M61553_0(), vo_61553_0, chara1.id);

            org.linlinjava.litemall.gameserver.data.vo.Vo_45092_0 vo_45092_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45092_0();

            vo_45092_0.task_name = "为民除暴";

            vo_45092_0.check_point = 40;

            GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45092_0(), vo_45092_0,
                    chara1.id);

        }

        if ((id == 985) && (menu_item.equals("五行生肖乐"))) {

            org.linlinjava.litemall.gameserver.data.vo.Vo_40995_0 vo_40995_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_40995_0();

            vo_40995_0.flag = 0;

            vo_40995_0.money = 0;

            vo_40995_0.surlus = String.valueOf(chara1.wuxingBalance);

            vo_40995_0.overflow = "0";

            vo_40995_0.amount = 1000;

            vo_40995_0.choice = 32;

            vo_40995_0.prize = 41;

            vo_40995_0.leftCount = 77;

            GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40995_0(), vo_40995_0);

        }

        if (id == 973) {

            if (menu_item.equals("我要兑换变异宠物")) {

                org.linlinjava.litemall.gameserver.data.vo.Vo_53249_0 vo_53249_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_53249_0();

                vo_53249_0.type = 1;

                vo_53249_0.count = 12;

                vo_53249_0.name0 = "伶俐鼠";

                vo_53249_0.price0 = 100;

                vo_53249_0.name1 = "笨笨牛";

                vo_53249_0.price1 = 100;

                vo_53249_0.name2 = "威威虎";

                vo_53249_0.price2 = 100;

                vo_53249_0.name3 = "跳跳兔";

                vo_53249_0.price3 = 100;

                vo_53249_0.name4 = "酷酷龙";

                vo_53249_0.price4 = 100;

                vo_53249_0.name5 = "花花蛇";

                vo_53249_0.price5 = 100;

                vo_53249_0.name6 = "溜溜马";

                vo_53249_0.price6 = 100;

                vo_53249_0.name7 = "咩咩羊";

                vo_53249_0.price7 = 100;

                vo_53249_0.name8 = "帅帅猴";

                vo_53249_0.price8 = 100;

                vo_53249_0.name9 = "蛋蛋鸡";

                vo_53249_0.price9 = 100;

                vo_53249_0.name10 = "乖乖狗";

                vo_53249_0.price10 = 100;

                vo_53249_0.name11 = "招财猪";

                vo_53249_0.price11 = 100;

                GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M53249_0(), vo_53249_0);

            }

            if (menu_item.equals("我要兑换神兽宠物")) {

                org.linlinjava.litemall.gameserver.data.vo.Vo_53249_1 vo_53249_1 = new org.linlinjava.litemall.gameserver.data.vo.Vo_53249_1();

                vo_53249_1.type = 2;

                vo_53249_1.count = 6;

                vo_53249_1.name0 = "疆良";

                vo_53249_1.price0 = 100;

                vo_53249_1.name1 = "东山神灵";

                vo_53249_1.price1 = 100;

                vo_53249_1.name2 = "玄武";

                vo_53249_1.price2 = 100;

                vo_53249_1.name3 = "朱雀";

                vo_53249_1.price3 = 100;

                vo_53249_1.name4 = "九尾狐";

                vo_53249_1.price4 = 100;

                vo_53249_1.name5 = "白矖";

                vo_53249_1.price5 = 100;

                GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M53249_1(), vo_53249_1);

            }

        }

        if ((id == 1180) && (menu_item.equals("召唤精怪"))) {

            org.linlinjava.litemall.gameserver.data.vo.Vo_9129_0 vo_9129_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_9129_0();

            vo_9129_0.notify = 97;

            vo_9129_0.para = "PetCallDlg";

            GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M9129_0(), vo_9129_0);

        }

        if ((id == 1180) && (menu_item.equals("驯化精怪"))) {

            org.linlinjava.litemall.gameserver.data.vo.Vo_41041_0 vo_41041_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_41041_0();

            vo_41041_0.type = 2;

            vo_41041_0.limitNum = 0;

            vo_41041_0.count = 0;

            GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M41041_0(), vo_41041_0);

            GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M4155_0(), Integer.valueOf(0));

        }

        if (id == 978) {

            if (menu_item.equals("清理背包")) {

                List<Goods> listbeibao = new ArrayList();

                for (int i = 0; i < chara1.backpack.size(); i++) {

                    if (((Goods) chara1.backpack.get(i)).pos > 10) {

                        List<Goods> listbeibao1 = new ArrayList();

                        Goods goods2 = new Goods();

                        goods2.goodsBasics = null;

                        goods2.goodsInfo = null;

                        goods2.goodsLanSe = null;

                        goods2.pos = ((Goods) chara1.backpack.get(i)).pos;

                        listbeibao.add(chara1.backpack.get(i));

                        listbeibao1.add(goods2);

                        GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M65525_0(), listbeibao1);

                    }

                }

                for (int i = 0; i < listbeibao.size(); i++) {

                    chara1.backpack.remove(listbeibao.get(i));

                }

            } else if (!menu_item.equals("离开")) {

                int petId = Integer.parseInt(menu_item);

                for (int i = 0; i < chara1.pets.size(); i++) {

                    if (petId == ((Petbeibao) chara1.pets.get(i)).id) {

                        chara1.pets.remove(chara1.pets.get(i));

                        org.linlinjava.litemall.gameserver.data.vo.Vo_12269_0 vo_12269_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_12269_0();

                        vo_12269_0.id = petId;

                        vo_12269_0.owner_id = 96780;

                        GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M12269_0(), vo_12269_0);

                    }

                }

            }

        }

        if (id == 959) {
            if (menu_item.equals("进入副本")) {
                System.out.println("进入副本逻辑判断");
                // 1, 获取队伍信息,判断是否满足三人或三人以上的人数
                if (GameObjectChar.getGameObjectChar().gameTeam == null) {
                    GameUtil.sendTips("请先创建队伍");
                    return;
                }
                List<Chara> duiwu = GameObjectChar.getGameObjectChar().gameTeam.duiwu;
                if (duiwu.size() < 2) {
                    GameUtil.sendTips("人数不足3人");
                    return;
                }
                int levelDiff = -1;
                for (Chara d : duiwu) {
                    if (levelDiff != -1 && d.level - levelDiff > 15) {
                        GameUtil.sendTips("队员之间的等级差距不能超过十五级");
                        return;
                    }
                    levelDiff = d.level;
                }
                // 2，弹出创建副本窗口
                GameUtil.sendNotify(97, "DugeonCreateDlg");
            }
        }

        if (menu_item.equals("我要购买野生宠物")) {

            List<org.linlinjava.litemall.db.domain.CreepsStore> creepsStoreList = GameData.that.baseCreepsStoreService
                    .findAll();

            GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40967_0(), creepsStoreList);

        }

        if (menu_item.equals("买卖")) {

            List<org.linlinjava.litemall.db.domain.MedicineShop> medicineShopList = GameData.that.baseMedicineShopService
                    .findAll();

            GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M65503_0(), medicineShopList);

        }

        if (menu_item.equals("我要做买卖")) {

            List<org.linlinjava.litemall.db.domain.GroceriesShop> groceriesShopList = GameData.that.baseGroceriesShopService
                    .findAll();

            GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M65503_0(), groceriesShopList);

        }

        Chara chara = GameObjectChar.getGameObjectChar().chara;

        org.linlinjava.litemall.db.domain.Npc npc = GameData.that.baseNpcService.findById(id);

        if(GameData.that.superBossMng.isBoss(Integer.valueOf(id))){
            if ("我要挑战超级大BOSS".equals(menu_item)) {
                GameData.that.superBossMng.sendBossFight(chara, id);
            }
            return ;
        }

        if (npc == null) {

            return;

        }

        List<org.linlinjava.litemall.db.domain.NpcDialogueFrame> npcDialogueFrameList = GameData.that.baseNpcDialogueFrameService
                .findByName(npc.getName());

        GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M4155_0(), Integer.valueOf(id));


        // 天机老人
        if (id == 955) {
            if ("超级大BOSS".equals(menu_item)) {
                org.linlinjava.litemall.db.domain.NpcDialogueFrame npcDialogueFrame = GameData.that.baseNpcDialogueFrameService
                        .findOneByContent(npc.getName() + "超级大BOSS");
                GameUtil.sendNpcDlg(npc, npcDialogueFrame.getUncontent());
                return;
            }
            if ("查看BOSS图鉴".equals(menu_item)) {
                GameUtil.sendNotify(97, "SuperBossIntroduceDlg");
                return;
            }
            if ("查询击杀次数".equals(menu_item)) {
                //打开悬赏奖励组队悬浮框
                GameUtil.sendNotify(97, "RewardInquireDlg");
                return;
            }
            if ("查询BOSS位置".equals(menu_item)) {
                GameData.that.superBossMng.sendBossPosDlg(npc);
                return;
            }

            if ("七杀试炼".equals(menu_item)) {
                org.linlinjava.litemall.db.domain.NpcDialogueFrame npcDialogueFrame = GameData.that.baseNpcDialogueFrameService
                        .findOneByContent(npc.getName() + "七杀试炼");

                GameUtil.sendNpcDlg(npc, npcDialogueFrame.getUncontent());
                chara.nextJuBen = 0;
                chara.currentJuBens = npcDialogueFrame.getNext().split(",");

                return;
            }

            if ("开启七杀试炼".equals(menu_item)) {
                GameUtil.sendNotify(97, "QiShaDlg");
                return;
            }
            if ("了解七杀试炼".equals(menu_item)) {

                GameUtil.playNextNpcDialogueJuBen();
                return;
            }

        }

        if (!menu_item.equals("离开")) {

            if (chara.current_task.equals(menu_item)) {

                if (chara.current_task.equals("主线—浮生若梦_s1")) {

                    geizhuangb(chara);

                }

                GameUtil.renwujiangli(chara);

                if (chara.current_task.equals("主线—浮生若梦_s22")) {

                    String[] chenghao = { "五龙山云霄洞第一代弟子", "终南山玉柱洞第一代弟子", "凤凰山斗阙宫第一代弟子", "乾元山金光洞第一代弟子", "骷髅山白骨洞第一代弟子" };

                    String chenhao = chenghao[(chara.menpai - 1)];

                    chara.chenghao.put("拜师任务", chenhao);

                    GameUtil.chenghaoxiaoxi(chara);

                    Vo_20481_0 vo_20481_9 = new Vo_20481_0();

                    vo_20481_9.msg = ("你获得了#R" + chenhao + "#n的称谓。");

                    vo_20481_9.time = 1567221761;

                    GameObjectChar.send(new M20481_0(), vo_20481_9);

                    List<RenwuMonster> all = GameData.that.baseRenwuMonsterService.findByType(Integer.valueOf(1));

                    Random random = new Random();

                    int i = random.nextInt(all.size());

                    RenwuMonster renwuMonster = (RenwuMonster) all.get(i);

                    String s = renwuMonster.getName() + GameUtil.getRandomJianHan();

                    Vo_61553_0 vo_61553_0 = new Vo_61553_0();

                    vo_61553_0.count = 1;

                    vo_61553_0.task_type = "为民除暴";

                    vo_61553_0.task_desc = "为民除暴";

                    vo_61553_0.task_prompt = "去#P李总兵|E=【除暴】除暴安良|$0#P那里看看";

                    vo_61553_0.refresh = 1;

                    vo_61553_0.task_end_time = 1567909190;

                    vo_61553_0.attrib = 1;

                    vo_61553_0.reward = "#I经验|人物经验宠物经验#I#I道行|道行#I#I潜能|潜能#I#I武学|武学#I#I金钱|金钱#I";

                    vo_61553_0.show_name = "为民除暴";

                    vo_61553_0.tasktask_extra_para = "";

                    vo_61553_0.tasktask_state = "1";

                    GameObjectChar.send(new M61553_0(), vo_61553_0);

                }

                chara.current_task = GameUtil.nextrenw(menu_item);

                org.linlinjava.litemall.db.domain.Renwu tasks = GameData.that.baseRenwuService
                        .findOneByCurrentTask(chara.current_task);

                Vo_61553_0 vo_61553_0 = GameUtil.a61553(tasks, chara);

                GameObjectChar.send(new M61553_0(), vo_61553_0);

            }

            ListVo_65527_0 vo_65527_0 = GameUtil.a65527(chara);

            GameObjectChar.send(new M65527_0(), vo_65527_0);

            GameUtil.a65511(chara);

        }

        ListVo_65527_0 vo_65527_0 = GameUtil.a65527(chara);

        GameObjectChar.send(new M65527_0(), vo_65527_0);

    }

    public int cmd() {

        return 12344;

    }

    public void geizhuangb(Chara chara) {

        ZhuangbeiInfo zhuangb = new ZhuangbeiInfo();

        List<ZhuangbeiInfo> byAttrib = GameData.that.baseZhuangbeiInfoService.findByAttrib(Integer.valueOf(1));

        for (int i = 0; i < byAttrib.size(); i++) {

            if ((((ZhuangbeiInfo) byAttrib.get(i)).getMetal().intValue() == chara.menpai)
                    && (((ZhuangbeiInfo) byAttrib.get(i)).getAmount().intValue() == 1)) {

                zhuangb = (ZhuangbeiInfo) byAttrib.get(i);

                GameUtil.huodezhuangbei(chara, zhuangb, 0);

                Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                vo_20481_0.msg = ("你获得了1把#R" + zhuangb.getStr() + "#n。");

                vo_20481_0.time = 1562987118;

                GameObjectChar.send(new M20481_0(), vo_20481_0);

                org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0 vo_20480_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0();

                vo_20480_0.msg = "你获得了#R260#n点经验。";

                vo_20480_0.time = 1562593376;

                GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M20480_0(), vo_20480_0);

                org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0 vo_8165_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0();

                vo_8165_0.msg = ("你获得了#R260#n经验、1把#R" + zhuangb.getStr() + "#n。");

                vo_8165_0.active = 0;

                GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M8165_0(), vo_8165_0);

                org.linlinjava.litemall.gameserver.data.vo.Vo_40964_0 vo_40964_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_40964_0();

                vo_40964_0.type = 1;

                vo_40964_0.name = zhuangb.getStr().toString();

                vo_40964_0.param = "98107";

                vo_40964_0.rightNow = 1;

                GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40964_0(), vo_40964_0);

                org.linlinjava.litemall.gameserver.data.vo.Vo_40965_0 vo_40965_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_40965_0();

                vo_40965_0.guideId = 19;

                GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40965_0(), vo_40965_0);

            }

        }

    }

}

/*
 * Location:
 * C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\
 * gameserver\process\C12344_0.class Java compiler version: 8 (52.0) JD-Core
 * Version: 0.7.1
 */