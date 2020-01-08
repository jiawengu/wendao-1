//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Random;
import java.util.concurrent.CopyOnWriteArrayList;
import org.linlinjava.litemall.db.domain.Pet;
import org.linlinjava.litemall.gameserver.data.constant.TitleConst;
import org.linlinjava.litemall.db.domain.T_FightObject;
import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_12023_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_12025_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_15857_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_19959_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_32985_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_3581_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_3583_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_45141_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_64971_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_65017_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_7653_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_7655_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_7659_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_7669_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_GODBOOK_EFFECT_NORMAL;
import org.linlinjava.litemall.gameserver.data.write.M12285_1;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_LIFE_DELTA;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_ACTION;
import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
import org.linlinjava.litemall.gameserver.data.write.MSG_AUTO_FIGHT_SKIL;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_END_COMBAT;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_START_COMBAT;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_CUR_ROUND;
import org.linlinjava.litemall.gameserver.data.write.MSG_TITLE;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_REFRESH_PET_LIST;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_OPPONENTS;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_FRIENDS;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_QUIT_COMBAT;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_END_ACTION;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_WAIT_COMMAND;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_CHAR_DIED;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.JiNeng;
import org.linlinjava.litemall.gameserver.domain.Petbeibao;
import org.linlinjava.litemall.gameserver.domain.ShouHu;
import org.linlinjava.litemall.gameserver.domain.ShouHuShuXing;
import org.linlinjava.litemall.gameserver.game.*;
import org.linlinjava.litemall.gameserver.job.SaveCharaTimes;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.linlinjava.litemall.gameserver.process.GameUtilRenWu;
import org.linlinjava.litemall.gameserver.service.TitleService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class FightManager {
    private static final Logger log = LoggerFactory.getLogger(FightManager.class);
    public static final List<FightContainer> listFight = new CopyOnWriteArrayList();
    public static final List<Integer> MONSTER_POS = new CopyOnWriteArrayList(new Integer[]{3, 2, 4, 1, 5, 8, 7, 9, 6, 10});
    public static final List<Integer> PERSON_POS = new CopyOnWriteArrayList(new Integer[]{3, 2, 4, 1, 5});
    public static final Random RANDOM = new Random();

    public FightManager() {
    }

    public static void goFight(Chara chara, String mapName) {
        int monsterNum = 6;
        goFight(chara, mapName, monsterNum);
    }

    public static void goFight(Chara chara, String mapName, int monsterNum) {
        List<Pet> monsterList = GameData.that.basePetService.findByZoon(mapName);
        List<String> monsterNameList = new ArrayList();
        if (monsterList.size() != 0) {
            for(int i = 0; i < monsterNum; ++i) {
                Pet pet = (Pet)monsterList.get(RANDOM.nextInt(monsterList.size()));
                monsterNameList.add(pet.getName());
            }

            goFight(chara, (List)monsterNameList);
        }
    }

    private static void addFabao(FightContainer fc, Chara chara, FightObject fightObject) {
        List zhandouisyoufabao = GameUtil.zhandouisyoufabao(chara);
        if (zhandouisyoufabao.size() >= 3) {
            String fabaoName = (String)zhandouisyoufabao.get(0);
            FightFabaoSkill fabaoSkill = FightSkill.getFabaoSkill(fabaoName);
            if (fabaoSkill != null) {
                int level = (Integer)zhandouisyoufabao.get(1);
                int qinmi = (Integer)zhandouisyoufabao.get(2);
                fabaoSkill.level = level;
                fabaoSkill.qinmi = qinmi;
                fabaoSkill.buffObject = fightObject;
                fabaoSkill.fightContainer = fc;
                fightObject.addSkill(fabaoSkill);
            }
        }

    }

    public static void goFight(Chara chara, List<String> monsterList) {
        FightContainer fc;///战斗空间
        for(fc = getFightContainer(chara.id); fc != null; fc = getFightContainer(chara.id)) {
            listFight.remove(fc);
        }

        fc = new FightContainer();
        FightTeam ft = new FightTeam();
        ft.type = 1;
        GameObjectChar session = GameObjectCharMng.getGameObjectChar(chara.id);
        int num = 0;
        int i;
        FightObject fightObject;
        if (session.gameTeam != null) {
            for(i = 0; i < session.gameTeam.duiwu.size(); ++i) {
                fightObject = new FightObject((Chara)session.gameTeam.duiwu.get(i));
                fightObject.pos = (Integer)PERSON_POS.get(num);
                fightObject.fid = ((Chara)session.gameTeam.duiwu.get(i)).id;
                fightObject.id = ((Chara)session.gameTeam.duiwu.get(i)).id;
                addFabao(fc, (Chara)session.gameTeam.duiwu.get(i), fightObject);
                if (i == 0) {
                    fightObject.leader = 1;
                }

                ft.add(fightObject);
                List<Petbeibao> pets = ((Chara)session.gameTeam.duiwu.get(i)).pets;

                for(int j = 0; j < pets.size(); ++j) {
                    Petbeibao petbeibao = (Petbeibao)pets.get(j);
                    if (((Petbeibao)pets.get(j)).id == ((Chara)session.gameTeam.duiwu.get(i)).chongwuchanzhanId) {
                        fightObject = new FightObject(petbeibao);
                        fightObject.pos = (Integer)PERSON_POS.get(num) + 5;
                        fightObject.fid = petbeibao.id;
                        fightObject.id = petbeibao.id;
                        fightObject.cid = ((Chara)session.gameTeam.duiwu.get(i)).id;
                        if (petbeibao.tianshu.size() != 0) {
                            Vo_12023_0 vo_12023_0 = (Vo_12023_0)petbeibao.tianshu.get(RANDOM.nextInt(petbeibao.tianshu.size()));
                            fightObject.godbook = (Integer)FightTianshuMap.TIANSHU_EFFECT.get(vo_12023_0.god_book_skill_name);
                            if (vo_12023_0.god_book_skill_name.equals("修罗术")) {
                                XiuluoshuSkill xiuluoshuSkill = new XiuluoshuSkill();
                                xiuluoshuSkill.buffObject = fightObject;
                                xiuluoshuSkill.fightContainer = fc;
                                fightObject.addSkill(xiuluoshuSkill);
                            }
                        }

                        ft.add(fightObject);
                        break;
                    }
                }

                ++num;
            }
        } else {
         fightObject = new FightObject(chara);
            fightObject.pos = (Integer)PERSON_POS.get(num);
            fightObject.fid = chara.id;
            fightObject.leader = 1;
            fightObject.id = chara.id;
            addFabao(fc, chara, fightObject);
            ft.add(fightObject);//战斗加入法宝
            List<Petbeibao> pets = chara.pets;

            for(int j = 0; j < pets.size(); ++j) {//判断是哪个宠物上场
                Petbeibao petbeibao = (Petbeibao)pets.get(j);
                if (petbeibao.id == chara.chongwuchanzhanId) {//商场的宠物id
                    fightObject = new FightObject(petbeibao);
                    fightObject.pos = (Integer)PERSON_POS.get(num) + 5;
                    fightObject.fid = petbeibao.id;
                    fightObject.id = petbeibao.id;
                    fightObject.cid = chara.id;
                    if (petbeibao.tianshu.size() != 0) {
                        Vo_12023_0 vo_12023_0 = (Vo_12023_0)petbeibao.tianshu.get(RANDOM.nextInt(petbeibao.tianshu.size()));
                        fightObject.godbook = (Integer)FightTianshuMap.TIANSHU_EFFECT.get(vo_12023_0.god_book_skill_name);
                        if (vo_12023_0.god_book_skill_name.equals("修罗术")) {
                            XiuluoshuSkill xiuluoshuSkill = new XiuluoshuSkill();
                            xiuluoshuSkill.buffObject = fightObject;
                            xiuluoshuSkill.fightContainer = fc;
                            fightObject.addSkill(xiuluoshuSkill);
                        }
                    }

                    ft.add(fightObject);
                    break;
                }
            }

            ++num;
        }

        for(i = 0; i < chara.listshouhu.size() && num < 5; ++i) {
            if (((ShouHuShuXing)((ShouHu)chara.listshouhu.get(i)).listShouHuShuXing.get(0)).nil != 0) {
                fightObject = new FightObject((ShouHu)chara.listshouhu.get(i));
                fightObject.pos = (Integer)PERSON_POS.get(num);
                fightObject.fid = fc.id++;
                ft.add(fightObject);
                ++num;
            }
        }

        FightTeam monsterTeam = new FightTeam();
        monsterTeam.type = 2;
        num = 0;



        for(Iterator var20 = monsterList.iterator(); var20.hasNext(); ++num) {
            String monsterName = (String)var20.next();
            fightObject = new FightObject(chara, monsterName);
            fightObject.pos = (Integer)MONSTER_POS.get(num);
            fightObject.fid = fc.id++;
            if (num == 1) {
                fightObject.leader = 1;
            }

            monsterTeam.add(fightObject);
        }

        fc.teamList.add(ft);
        fc.teamList.add(monsterTeam);
        listFight.add(fc);
        if (chara.autofight_select != 0) {
            Vo_32985_0 vo_32985_0 = new Vo_32985_0();
            vo_32985_0.user_is_multi = 0;
            vo_32985_0.user_round = chara.autofight_select;
            vo_32985_0.user_action = chara.autofight_skillaction;
            vo_32985_0.user_next_action = chara.autofight_skillaction;
            vo_32985_0.user_para = chara.autofight_skillno;
            vo_32985_0.user_next_para = chara.autofight_skillno;
            vo_32985_0.pet_is_multi = 0;
            vo_32985_0.pet_round = 0;
            vo_32985_0.pet_action = 0;
            vo_32985_0.pet_next_action = 0;
            vo_32985_0.pet_para = 0;
            vo_32985_0.pet_next_para = 0;
            GameObjectChar.send(new MSG_AUTO_FIGHT_SKIL(), vo_32985_0);
        }

        GameUtil.MSG_FRIEND_UPDATE_PARTIAL(chara);
        GameUtil.MSG_UPDATE_IMPROVEMENT(chara);
        Vo_3583_0 vo_3583_0 = new Vo_3583_0();
        vo_3583_0.a = 1;
        vo_3583_0.b = 3;
        send(fc, new MSG_C_START_COMBAT(), vo_3583_0);
        Vo_61671_0 vo_61671_0 = new Vo_61671_0();
        vo_61671_0.id = chara.id;
        vo_61671_0.count = 1;
        vo_61671_0.list.add(1);
        GameObjectChar.getGameObjectChar().gameMap.send(new MSG_TITLE(), vo_61671_0);
        FightTeam friendsFightTeam = getFightTeam(fc, chara.id);
        List<FightObject> fightObjectList1 = friendsFightTeam.fightObjectList;
        Iterator var31 = fightObjectList1.iterator();

        while(var31.hasNext()) {
           fightObject = (FightObject)var31.next();
            if (fightObject.type == 2) {
                Vo_64971_0 vo_64971_0 = new Vo_64971_0();
                vo_64971_0.count = 1;
                vo_64971_0.id = fightObject.id;
                vo_64971_0.haveCalled = 1;
                GameObjectCharMng.getGameObjectChar(fightObject.cid).sendOne(new MSG_C_REFRESH_PET_LIST(), vo_64971_0);
            }
        }

        List<Vo_65017_0> list65019 = new ArrayList();
        List<FightObject> fightObjectList = getFightTeam(fc, chara.id).fightObjectList;
        Iterator var37 = fightObjectList.iterator();

        while(var37.hasNext()) {
            fightObject = (FightObject)var37.next();
            Vo_65017_0 vo_65019_0 = new Vo_65017_0();
            vo_65019_0.id = fightObject.fid;
            vo_65019_0.leader = fightObject.leader;
            vo_65019_0.weapon_icon = fightObject.weapon_icon;
            vo_65019_0.pos = fightObject.pos;
            vo_65019_0.rank = fightObject.rank;
            vo_65019_0.vip_type = 0;
            vo_65019_0.str = fightObject.str;
            vo_65019_0.type = fightObject.org_icon;
            vo_65019_0.durability = fightObject.durability;
            vo_65019_0.req_level = 0;
            vo_65019_0.upgrade_level = 0;
            vo_65019_0.upgrade_type = 0;
            vo_65019_0.dex = fightObject.max_mofa;
            vo_65019_0.max_mana = fightObject.max_mofa;
            vo_65019_0.max_life = fightObject.max_shengming;
            vo_65019_0.def = fightObject.max_shengming;
            vo_65019_0.org_icon = fightObject.org_icon;
            vo_65019_0.suit_icon = fightObject.suit_icon;
            vo_65019_0.suit_light_effect = fightObject.suit_light_effect;
            vo_65019_0.special_icon = 0;
            list65019.add(vo_65019_0);
        }

        send(fc, new MSG_C_FRIENDS(), list65019);
        List<Vo_65017_0> list65017 = new ArrayList();
        fightObjectList = getFightTeamDM(fc, chara.id).fightObjectList;
        Iterator var39 = fightObjectList.iterator();

        while(var39.hasNext()) {
           fightObject = (FightObject)var39.next();
            Vo_65017_0 vo_65017_0 = new Vo_65017_0();
            vo_65017_0.id = fightObject.fid;
            vo_65017_0.leader = fightObject.leader;
            vo_65017_0.weapon_icon = 0;
            vo_65017_0.pos = fightObject.pos;
            vo_65017_0.rank = 0;
            vo_65017_0.vip_type = 0;
            vo_65017_0.str = fightObject.str;
            vo_65017_0.type = fightObject.org_icon;
            vo_65017_0.durability = 2;
            vo_65017_0.req_level = 0;
            vo_65017_0.upgrade_level = 0;
            vo_65017_0.upgrade_type = 0;
            vo_65017_0.dex = fightObject.max_mofa;
            vo_65017_0.max_mana = fightObject.max_mofa;
            vo_65017_0.max_life = fightObject.max_shengming;
            vo_65017_0.def = fightObject.max_shengming;
            vo_65017_0.org_icon = fightObject.org_icon;
            vo_65017_0.suit_icon = fightObject.suit_icon;
            vo_65017_0.suit_light_effect = fightObject.suit_light_effect;
            vo_65017_0.special_icon = 0;
            list65017.add(vo_65017_0);
        }

        send(fc, new MSG_C_OPPONENTS(), list65017);
        fightObjectList = getFightTeam(fc, chara.id).fightObjectList;
        Vo_19959_0 vo_19959_0 = new Vo_19959_0();
        vo_19959_0.round = fc.round;
        vo_19959_0.aid = 0;
        vo_19959_0.action = 0;
        vo_19959_0.vid = 0;
        vo_19959_0.para = 0;
        send(fc, new MSG_C_ACTION(), vo_19959_0);
        Iterator var42 = fightObjectList.iterator();

        while(var42.hasNext()) {
           fightObject = (FightObject)var42.next();
            if (fightObject.godbook != 0) {
                Vo_12025_0 vo_12025_0 = new Vo_12025_0();
                vo_12025_0.id = fightObject.fid;
                vo_12025_0.effect_no = fightObject.godbook;
                send(fc, new MSG_GODBOOK_EFFECT_NORMAL(), vo_12025_0);
            }
        }

        Vo_7655_0 vo_7655_0 = new Vo_7655_0();
        vo_7655_0.id = 0;
        send(fc, new MSG_C_END_ACTION(), vo_7655_0);
        round(fc);
    }

    /**
     * 通天塔战斗
     * @param chara
     */
    public static void goFightTTT(Chara chara) {
        FightContainer fc;///战斗空间
        for(fc = getFightContainer(chara.id); fc != null; fc = getFightContainer(chara.id)) {
            listFight.remove(fc);
        }

        fc = new FightContainer();
        FightTeam ft = new FightTeam();
        ft.type = 1;
        GameObjectChar session = GameObjectCharMng.getGameObjectChar(chara.id);
        int num = 0;
        int i;
        FightObject fightObject;
        if (session.gameTeam != null) {
            for(i = 0; i < session.gameTeam.duiwu.size(); ++i) {
                fightObject = new FightObject((Chara)session.gameTeam.duiwu.get(i));
                fightObject.pos = (Integer)PERSON_POS.get(num);
                fightObject.fid = ((Chara)session.gameTeam.duiwu.get(i)).id;
                fightObject.id = ((Chara)session.gameTeam.duiwu.get(i)).id;
                addFabao(fc, (Chara)session.gameTeam.duiwu.get(i), fightObject);
                if (i == 0) {
                    fightObject.leader = 1;
                }

                ft.add(fightObject);
                List<Petbeibao> pets = ((Chara)session.gameTeam.duiwu.get(i)).pets;

                for(int j = 0; j < pets.size(); ++j) {
                    Petbeibao petbeibao = (Petbeibao)pets.get(j);
                    if (((Petbeibao)pets.get(j)).id == ((Chara)session.gameTeam.duiwu.get(i)).chongwuchanzhanId) {
                        fightObject = new FightObject(petbeibao);
                        fightObject.pos = (Integer)PERSON_POS.get(num) + 5;
                        fightObject.fid = petbeibao.id;
                        fightObject.id = petbeibao.id;
                        fightObject.cid = ((Chara)session.gameTeam.duiwu.get(i)).id;
                        if (petbeibao.tianshu.size() != 0) {
                            Vo_12023_0 vo_12023_0 = (Vo_12023_0)petbeibao.tianshu.get(RANDOM.nextInt(petbeibao.tianshu.size()));
                            fightObject.godbook = (Integer)FightTianshuMap.TIANSHU_EFFECT.get(vo_12023_0.god_book_skill_name);
                            if (vo_12023_0.god_book_skill_name.equals("修罗术")) {
                                XiuluoshuSkill xiuluoshuSkill = new XiuluoshuSkill();
                                xiuluoshuSkill.buffObject = fightObject;
                                xiuluoshuSkill.fightContainer = fc;
                                fightObject.addSkill(xiuluoshuSkill);
                            }
                        }

                        ft.add(fightObject);
                        break;
                    }
                }

                ++num;
            }
        } else {
         fightObject = new FightObject(chara);
            fightObject.pos = (Integer)PERSON_POS.get(num);
            fightObject.fid = chara.id;
            fightObject.leader = 1;
            fightObject.id = chara.id;
            addFabao(fc, chara, fightObject);
            ft.add(fightObject);//战斗加入法宝
            List<Petbeibao> pets = chara.pets;

            for(int j = 0; j < pets.size(); ++j) {//判断是哪个宠物上场
                Petbeibao petbeibao = (Petbeibao)pets.get(j);
                if (petbeibao.id == chara.chongwuchanzhanId) {//商场的宠物id
                    fightObject = new FightObject(petbeibao);
                    fightObject.pos = (Integer)PERSON_POS.get(num) + 5;
                    fightObject.fid = petbeibao.id;
                    fightObject.id = petbeibao.id;
                    fightObject.cid = chara.id;
                    if (petbeibao.tianshu.size() != 0) {
                        Vo_12023_0 vo_12023_0 = (Vo_12023_0)petbeibao.tianshu.get(RANDOM.nextInt(petbeibao.tianshu.size()));
                        fightObject.godbook = (Integer)FightTianshuMap.TIANSHU_EFFECT.get(vo_12023_0.god_book_skill_name);
                        if (vo_12023_0.god_book_skill_name.equals("修罗术")) {
                            XiuluoshuSkill xiuluoshuSkill = new XiuluoshuSkill();
                            xiuluoshuSkill.buffObject = fightObject;
                            xiuluoshuSkill.fightContainer = fc;
                            fightObject.addSkill(xiuluoshuSkill);
                        }
                    }

                    ft.add(fightObject);
                    break;
                }
            }

            ++num;
        }

        FightTeam monsterTeam = new FightTeam();
        monsterTeam.type = 2;
        num = 0;


        //星君
        {
            T_FightObject t_fightObject = GameData.that.baseFightObjectService.findOneByName(chara.ttt_xj_name);
            fightObject = new FightObject(t_fightObject, chara.ttt_layer);
            fightObject.pos = (Integer)MONSTER_POS.get(0);
            fightObject.fid = fc.id++;
            fightObject.leader = 1;
            fightObject.type = 3;
            monsterTeam.add(fightObject);
            num++;
        }

        //宠物
        {
            T_FightObject t_fightObject = GameData.that.baseFightObjectService.findOneByName(GameUtil.randomTTTPetName());
            FightObject tttPet = new FightObject(t_fightObject, chara.ttt_layer);
            tttPet.pos = (Integer)MONSTER_POS.get(5);
            tttPet.fid = fc.id++;
            tttPet.tttXingjun = fightObject;
            monsterTeam.add(tttPet);
            num++;
        }



        fc.teamList.add(ft);
        fc.teamList.add(monsterTeam);
        listFight.add(fc);
        if (chara.autofight_select != 0) {
            Vo_32985_0 vo_32985_0 = new Vo_32985_0();
            vo_32985_0.user_is_multi = 0;
            vo_32985_0.user_round = chara.autofight_select;
            vo_32985_0.user_action = chara.autofight_skillaction;
            vo_32985_0.user_next_action = chara.autofight_skillaction;
            vo_32985_0.user_para = chara.autofight_skillno;
            vo_32985_0.user_next_para = chara.autofight_skillno;
            vo_32985_0.pet_is_multi = 0;
            vo_32985_0.pet_round = 0;
            vo_32985_0.pet_action = 0;
            vo_32985_0.pet_next_action = 0;
            vo_32985_0.pet_para = 0;
            vo_32985_0.pet_next_para = 0;
            GameObjectChar.send(new MSG_AUTO_FIGHT_SKIL(), vo_32985_0);
        }

        GameUtil.MSG_FRIEND_UPDATE_PARTIAL(chara);
        GameUtil.MSG_UPDATE_IMPROVEMENT(chara);
        Vo_3583_0 vo_3583_0 = new Vo_3583_0();
        vo_3583_0.a = 1;
        vo_3583_0.b = 3;
        send(fc, new MSG_C_START_COMBAT(), vo_3583_0);
        Vo_61671_0 vo_61671_0 = new Vo_61671_0();
        vo_61671_0.id = chara.id;
        vo_61671_0.count = 1;
        vo_61671_0.list.add(1);
        GameObjectChar.getGameObjectChar().gameMap.send(new MSG_TITLE(), vo_61671_0);
        FightTeam friendsFightTeam = getFightTeam(fc, chara.id);
        List<FightObject> fightObjectList1 = friendsFightTeam.fightObjectList;
        Iterator var31 = fightObjectList1.iterator();

        while(var31.hasNext()) {
           fightObject = (FightObject)var31.next();
            if (fightObject.type == 2) {
                Vo_64971_0 vo_64971_0 = new Vo_64971_0();
                vo_64971_0.count = 1;
                vo_64971_0.id = fightObject.id;
                vo_64971_0.haveCalled = 1;
                GameObjectCharMng.getGameObjectChar(fightObject.cid).sendOne(new MSG_C_REFRESH_PET_LIST(), vo_64971_0);
            }
        }

        List<Vo_65017_0> list65019 = new ArrayList();
        List<FightObject> fightObjectList = getFightTeam(fc, chara.id).fightObjectList;
        Iterator var37 = fightObjectList.iterator();

        while(var37.hasNext()) {
            fightObject = (FightObject)var37.next();
            Vo_65017_0 vo_65019_0 = new Vo_65017_0();
            vo_65019_0.id = fightObject.fid;
            vo_65019_0.leader = fightObject.leader;
            vo_65019_0.weapon_icon = fightObject.weapon_icon;
            vo_65019_0.pos = fightObject.pos;
            vo_65019_0.rank = fightObject.rank;
            vo_65019_0.vip_type = 0;
            vo_65019_0.str = fightObject.str;
            vo_65019_0.type = fightObject.org_icon;
            vo_65019_0.durability = fightObject.durability;
            vo_65019_0.req_level = 0;
            vo_65019_0.upgrade_level = 0;
            vo_65019_0.upgrade_type = 0;
            vo_65019_0.dex = fightObject.max_mofa;
            vo_65019_0.max_mana = fightObject.max_mofa;
            vo_65019_0.max_life = fightObject.max_shengming;
            vo_65019_0.def = fightObject.max_shengming;
            vo_65019_0.org_icon = fightObject.org_icon;
            vo_65019_0.suit_icon = fightObject.suit_icon;
            vo_65019_0.suit_light_effect = fightObject.suit_light_effect;
            vo_65019_0.special_icon = 0;
            list65019.add(vo_65019_0);
        }

        send(fc, new MSG_C_FRIENDS(), list65019);
        List<Vo_65017_0> list65017 = new ArrayList();
        fightObjectList = getFightTeamDM(fc, chara.id).fightObjectList;
        Iterator var39 = fightObjectList.iterator();

        while(var39.hasNext()) {
           fightObject = (FightObject)var39.next();
            Vo_65017_0 vo_65017_0 = new Vo_65017_0();
            vo_65017_0.id = fightObject.fid;
            vo_65017_0.leader = fightObject.leader;
            vo_65017_0.weapon_icon = 0;
            vo_65017_0.pos = fightObject.pos;
            vo_65017_0.rank = 0;
            vo_65017_0.vip_type = 0;
            vo_65017_0.str = fightObject.str;
            vo_65017_0.type = fightObject.org_icon;
            vo_65017_0.durability = 2;
            vo_65017_0.req_level = 0;
            vo_65017_0.upgrade_level = 0;
            vo_65017_0.upgrade_type = 0;
            vo_65017_0.dex = fightObject.max_mofa;
            vo_65017_0.max_mana = fightObject.max_mofa;
            vo_65017_0.max_life = fightObject.max_shengming;
            vo_65017_0.def = fightObject.max_shengming;
            vo_65017_0.org_icon = fightObject.org_icon;
            vo_65017_0.suit_icon = fightObject.suit_icon;
            vo_65017_0.suit_light_effect = fightObject.suit_light_effect;
            vo_65017_0.special_icon = 0;
            list65017.add(vo_65017_0);
        }

        send(fc, new MSG_C_OPPONENTS(), list65017);
        fightObjectList = getFightTeam(fc, chara.id).fightObjectList;
        Vo_19959_0 vo_19959_0 = new Vo_19959_0();
        vo_19959_0.round = fc.round;
        vo_19959_0.aid = 0;
        vo_19959_0.action = 0;
        vo_19959_0.vid = 0;
        vo_19959_0.para = 0;
        send(fc, new MSG_C_ACTION(), vo_19959_0);
        Iterator var42 = fightObjectList.iterator();

        while(var42.hasNext()) {
           fightObject = (FightObject)var42.next();
            if (fightObject.godbook != 0) {
                Vo_12025_0 vo_12025_0 = new Vo_12025_0();
                vo_12025_0.id = fightObject.fid;
                vo_12025_0.effect_no = fightObject.godbook;
                send(fc, new MSG_GODBOOK_EFFECT_NORMAL(), vo_12025_0);
            }
        }

        Vo_7655_0 vo_7655_0 = new Vo_7655_0();
        vo_7655_0.id = 0;
        send(fc, new MSG_C_END_ACTION(), vo_7655_0);
        round(fc);
    }

    public static void addRequest(FightContainer fightContainer, FightRequest fightRequest) {
        if (fightContainer.state.get() == 1) {
            if (fightRequest != null) {
                FightObject fightObject = getFightObject(fightContainer, fightRequest.id);
                if (fightObject.fightRequest == null) {
                    fightObject.fightRequest = fightRequest;
                }
            }

            boolean doAction = isAllRequested(fightContainer);
            if (doAction) {
                List<FightObject> doActionList = getAllFightObject(fightContainer);
                sortActions(doActionList);
                fightContainer.doActionList = doActionList;
                if (!fabao(fightContainer)) {
                    doAction(fightContainer);
                }

                endaction(fightContainer);
            }

        }
    }

    public static void doAutoSkill(FightContainer fightContainer) {
        List<FightObject> allFightObject = getAllFightObject(fightContainer);
        Iterator var2 = allFightObject.iterator();

        while(true) {
            FightObject fightObject;
            do {
                if (!var2.hasNext()) {
                    addRequest(fightContainer, (FightRequest)null);
                    return;
                }

                fightObject = (FightObject)var2.next();
            } while(fightObject.type != 1 && fightObject.type != 2);

            if (fightObject.fightRequest == null && fightObject.autofight_select != 0) {
                fightObject.fightRequest = new FightRequest();
                fightObject.fightRequest.id = fightObject.fid;
                fightObject.fightRequest.action = fightObject.autofight_skillaction;
                fightObject.fightRequest.para = fightObject.autofight_skillno;
                generateActionDM(fightContainer, fightObject, fightObject.fightRequest);
            }
        }
    }

    public static void doTimeupSkill(FightContainer fightContainer) {
        List<FightObject> allFightObject = getAllFightObject(fightContainer);
        Iterator var2 = allFightObject.iterator();

        while(true) {
            FightObject fightObject;
            do {
                if (!var2.hasNext()) {
                    addRequest(fightContainer, (FightRequest)null);
                    return;
                }

                fightObject = (FightObject)var2.next();
            } while(fightObject.type != 1 && (fightObject.type != 2 || fightObject.fightRequest != null));

            fightObject.fightRequest = new FightRequest();
            fightObject.fightRequest.id = fightObject.fid;
            fightObject.fightRequest.action = 2;
            fightObject.fightRequest.para = 2;
            generateActionDM(fightContainer, fightObject, fightObject.fightRequest);
        }
    }

    private static void sortActions(List<FightObject> doActionList) {
        doActionList.sort((ob1, ob2) -> {
            return ob2.parry + ob2.parry_ext - ob1.parry - ob1.parry_ext;
        });
    }

    private static FightRequest generateAction(FightContainer fightContainer, FightObject fightObject) {
        FightRequest fightRequest = new FightRequest();
        List<JiNeng> skillsList = fightObject.skillsList;
        if (skillsList != null && skillsList.size() != 0) {
            JiNeng jiNeng = null;
            if(fightContainer.round==1 && GameUtil.isTTTPet(fightObject.str)){
                jiNeng = skillsList.get(0);
            }else{
                jiNeng = (JiNeng)skillsList.get(RANDOM.nextInt(skillsList.size()));
            }

            fightRequest.para = jiNeng.skill_no;
            fightRequest.action = 3;
            fightRequest.id = fightObject.fid;
            if (FightSkill.isOpSkill(jiNeng.skill_no)) {
                generateActionDM(fightContainer, fightObject, fightRequest);
            } else {
                generateActionVt(fightContainer, fightObject, fightRequest);
            }
        } else {
            fightRequest.normalSkill(fightObject.fid);
            generateActionDM(fightContainer, fightObject, fightRequest);
        }

        return fightRequest;
    }

    /**
     * 随机敌方阵营的受伤害者
     * @param fightContainer
     * @param fightObject
     * @param fightRequest
     * @return
     */
    public static FightRequest generateActionDM(FightContainer fightContainer, FightObject fightObject, FightRequest fightRequest) {
        ArrayList<FightObject> fightObjects = new ArrayList();
        FightTeam opponentsFightTeam = getFightTeamDM(fightContainer, fightObject.fid);
        Iterator target = opponentsFightTeam.fightObjectList.iterator();

        while(target.hasNext()) {
            FightObject object = (FightObject)target.next();
            if (object.canbeVictim()) {
                fightObjects.add(object);
            }
        }

        target = null;
        if (fightObjects.size() == 0) {
            return null;
        } else {
            FightObject fightObject1;
            if (fightObjects.size() == 1) {
                fightObject1 = (FightObject)fightObjects.get(0);
            } else {
                int index = (new Random()).nextInt(fightObjects.size());
                fightObject1 = (FightObject)fightObjects.get(index);
            }

            fightRequest.vid = fightObject1.fid;
            return fightRequest;
        }
    }
    /**
     * 随机已方阵营的受伤害者
     * @param fightContainer
     * @param fightObject
     * @param fightRequest
     * @return
     */
    public static FightRequest generateActionVt(FightContainer fightContainer, FightObject fightObject, FightRequest fightRequest) {
        ArrayList<FightObject> fightObjects = new ArrayList();
        FightTeam friendsFightTeam = getFightTeam(fightContainer, fightObject.fid);
        Iterator target = friendsFightTeam.fightObjectList.iterator();

        while(target.hasNext()) {
            FightObject object = (FightObject)target.next();
            if (object.canbeVictim()) {
                fightObjects.add(object);
            }
        }

        target = null;
        if (fightObjects.size() == 0) {
            return null;
        } else {
            FightObject fightObject1;
            if (fightObjects.size() == 1) {
                fightObject1 = (FightObject)fightObjects.get(0);
            } else {
                int index = (new Random()).nextInt(fightObjects.size());
                fightObject1 = (FightObject)fightObjects.get(index);
            }

            fightRequest.vid = fightObject1.fid;
            return fightRequest;
        }
    }

    public static FightRequest generateActionHunluan(FightContainer fightContainer, FightObject fightObject, FightRequest fightRequest) {
        List<FightObject> allFightObject = getAlive(getAllFightObject(fightContainer));
        Iterator iterator = allFightObject.iterator();

        FightObject next;
        while(iterator.hasNext()) {
            next = (FightObject)iterator.next();
            if (next.fid == fightObject.fid) {
                iterator.remove();
            }
        }

        next = (FightObject)allFightObject.get((new Random()).nextInt(allFightObject.size()));
        fightRequest.vid = next.fid;
        return fightRequest;
    }

    private static void doAction(FightContainer fightContainer) {
        fightContainer.state.set(3);
        sendReadyAction(fightContainer);

        do {
            FightObject fightObject;
            FightRequest fightRequest;
            FightSkill skill;
            JiNeng jiNeng;
            List resultList;
            Iterator var7;
            do {
                do {
                    do {
                        do {
                            do {
                                if (fightContainer.doActionList.size() <= 0) {
                                    return;
                                }

                                fightObject = (FightObject)fightContainer.doActionList.remove(0);
                                fightRequest = fightObject.fightRequest;
                                fightObject.fightRequest = null;
                                if (fightRequest == null) {
                                    fightRequest = generateAction(fightContainer, fightObject);
                                }
                            } while((fightObject.isDead() || !fightObject.canAtta()) && fightRequest.action != 7 && fightRequest.action != 4);
                        } while(fightObject.isYiwang() && RANDOM.nextBoolean());

                        if (!fightObject.canbeSkill()) {
                            fightRequest.action = 2;
                            fightRequest.para = 2;
                        }
                    } while(fightObject.isZhongdu() && (fightRequest.action == 3 && fightRequest.para == 501 || fightRequest.action == 2 && fightRequest.para == 2));

                    FightObject victimObject = getFightObject(fightContainer, fightRequest.vid);
                    if (fightObject.isHunluan()) {
                        generateActionHunluan(fightContainer, fightObject, fightRequest);
                    } else if (victimObject != null && !victimObject.canbeVictim() && fightRequest.action != 4) {
                        if (FightSkill.isOpSkill(fightRequest.para)) {
                            generateActionDM(fightContainer, fightObject, fightRequest);
                        } else {
                            generateActionVt(fightContainer, fightObject, fightRequest);
                        }
                    }

                    skill = FightSkill.getFightSkill(fightRequest.action, fightRequest.para);
                    jiNeng = null;
                    if (fightRequest.action == 3) {
                        resultList = fightObject.skillsList;
                        var7 = resultList.iterator();

                        while(var7.hasNext()) {
                            JiNeng tjiNeng = (JiNeng)var7.next();
                            if (tjiNeng.skill_no == fightRequest.para) {
                                jiNeng = tjiNeng;
                            }
                        }
                    }
                } while(skill == null);
            } while(jiNeng == null && fightRequest.action == 3);

            resultList = skill.doSkill(fightContainer, fightRequest, jiNeng);
            if (resultList != null) {
                var7 = resultList.iterator();

                while(var7.hasNext()) {
                    FightResult fightResult = (FightResult)var7.next();
                    send_LIFE_DELTA(fightContainer, fightResult);
                }
            }

            Vo_7655_0 vo_7655_0 = new Vo_7655_0();
            vo_7655_0.id = fightObject.fid;
            send(fightContainer, new MSG_C_END_ACTION(), vo_7655_0);
        } while(!isOver(fightContainer));

        doOver(fightContainer);
    }

    public static void send_LIFE_DELTA(FightContainer fightContainer, FightResult fightResult) {
        Vo_15857_0 vo_15857_0 = new Vo_15857_0();
        vo_15857_0.id = fightResult.vid;
        vo_15857_0.hitter_id = fightResult.id;
        vo_15857_0.point = fightResult.point;
        vo_15857_0.effect_no = fightResult.effect_no;
        vo_15857_0.damage_type = fightResult.damage_type;
        send(fightContainer, new MSG_C_LIFE_DELTA(), vo_15857_0);
        FightTeam friendsFightTeam = getFightTeam(fightContainer, fightResult.vid);
        FightObject victimObject;
        if (friendsFightTeam.type == 1) {
            victimObject = getFightObject(fightContainer, fightResult.vid);
            victimObject.update(fightContainer);
        }

        victimObject = getFightObject(fightContainer, fightResult.vid);
        if (victimObject.doDead()) {
            Vo_7669_0 vo_7669_0 = new Vo_7669_0();
            vo_7669_0.id = victimObject.fid;
            vo_7669_0.damage_type = 4098;
            send(fightContainer, new MSG_C_CHAR_DIED(), vo_7669_0);
            if (victimObject.state == 3) {
                Vo_7653_0 vo_7653_0 = new Vo_7653_0();
                vo_7653_0.id = victimObject.fid;
                send(fightContainer, new MSG_C_QUIT_COMBAT(), vo_7653_0);
            }
        }

    }

    public static void doOver(FightContainer fightContainer) {
        fightContainer.state.set(4);
    }

    public static void changeAutoFightSkill(FightContainer fightContainer, FightObject fightObject, int action, int para) {
        if (action == 1 || action == 2 || action == 3) {
            fightObject.autofight_skillaction = action;
            fightObject.autofight_skillno = para;
            GameObjectChar session;
            if (fightObject.type == 1) {
                session = GameObjectCharMng.getGameObjectChar(fightObject.id);
                session.chara.autofight_skillaction = action;
                session.chara.autofight_skillno = para;
            } else if (fightObject.type == 2) {
                session = GameObjectCharMng.getGameObjectChar(fightObject.cid);
                List<Petbeibao> pets = session.chara.pets;
                Iterator var6 = pets.iterator();

                while(var6.hasNext()) {
                    Petbeibao pet = (Petbeibao)var6.next();
                    if (pet.id == fightObject.fid) {
                        pet.autofight_skillaction = action;
                        pet.autofight_skillno = para;
                        break;
                    }
                }
            }
        }

    }

    public static void nextRoundOrSendOver(FightContainer fightContainer) {
        if (fightContainer.state.compareAndSet(4, 5)) {
            listFight.remove(fightContainer);
            sendOver(fightContainer);
        } else if (fightContainer.state.get() == 1) {
            ++fightContainer.round;
            round(fightContainer);
        }

    }

    private static void endaction(FightContainer fightContainer) {
        List<FightObject> allFightObject = getAllFightObject(fightContainer);
        Iterator var2 = allFightObject.iterator();

        while(var2.hasNext()) {
            FightObject fightObject = (FightObject)var2.next();
            List<FightRoundSkill> fightSkillList = fightObject.getRoundSkill();
            Iterator var5 = fightSkillList.iterator();

            while(var5.hasNext()) {
                FightRoundSkill fightSkill = (FightRoundSkill)var5.next();
                boolean remove = fightSkill.disappear(fightContainer);
                if (remove) {
                    fightObject.removeBuffSK(fightContainer, fightSkill.getStateType());
                }
            }

            FightFabaoSkill fabaoSkill = fightObject.getFabaoSkill();
            if (fabaoSkill != null) {
                fabaoSkill.resetTimes();
            }
        }

        for(FightObject fightObject:getAllFightObject(fightContainer)){
            if(fightObject.isTTTPet() && !fightObject.isDead() && fightObject.tttXingjun.isDead()){//拉起通天塔星君
                Vo_19959_0 vo_19959_0 = new Vo_19959_0();
                vo_19959_0.round = fightContainer.round;
                vo_19959_0.aid = fightObject.fid;
                vo_19959_0.action = 26;
                vo_19959_0.vid = fightObject.tttXingjun.fid;
                vo_19959_0.para = 0;
                FightManager.send(fightContainer, new MSG_C_ACTION(), vo_19959_0);
                fightObject.tttXingjun.state = 1;
                int blood = fightObject.tttXingjun.max_shengming / 2;
                fightObject.tttXingjun.shengming = blood;
                fightObject.tttXingjun.revive(fightContainer);
                Vo_7655_0 vo_7655_0 = new Vo_7655_0();
                vo_7655_0.id = fightObject.fid;
                FightManager.send(fightContainer, new MSG_C_END_ACTION(), vo_7655_0);
                log.info("通天塔=>:"+fightObject.str+"救活了："+fightObject.tttXingjun.str);
                break;
            }

        }

    }

    private static boolean fabao(FightContainer fightContainer) {
        List<FightObject> allFightObject = getAllFightObject(fightContainer);
        Iterator var2 = allFightObject.iterator();

        while(var2.hasNext()) {
            FightObject fightObject = (FightObject)var2.next();
            List<FightRoundSkill> fightSkillList = fightObject.getRoundSkill();
            Iterator var5 = fightSkillList.iterator();

            while(var5.hasNext()) {
                FightRoundSkill fightSkill = (FightRoundSkill)var5.next();
                fightSkill.doRoundSkill();
            }

            FightFabaoSkill fabaoSkill = fightObject.getFabaoSkill();
            if (fabaoSkill != null) {
                fabaoSkill.active();
            }
        }

        if (isOver(fightContainer)) {
            doOver(fightContainer);
            nextRoundOrSendOver(fightContainer);
            return true;
        } else {
            return false;
        }
    }

    private static void sendReadyAction(FightContainer fightContainer) {
        List<FightObject> allFightObject = getAllFightObject(fightContainer);
        Vo_19959_0 vo_19959_0 = new Vo_19959_0();
        vo_19959_0.round = fightContainer.round;
        vo_19959_0.aid = 0;
        vo_19959_0.action = 0;
        vo_19959_0.vid = 0;
        vo_19959_0.para = 0;
        send(fightContainer, new MSG_C_ACTION(), vo_19959_0);
        vo_19959_0 = new Vo_19959_0();
        vo_19959_0.round = fightContainer.round;
        vo_19959_0.aid = 0;
        vo_19959_0.action = 0;
        vo_19959_0.vid = 0;
        vo_19959_0.para = 0;
        send(fightContainer, new MSG_C_ACTION(), vo_19959_0);
        Vo_7655_0 vo_7655_0 = new Vo_7655_0();
        vo_7655_0.id = 0;
        send(fightContainer, new MSG_C_END_ACTION(), vo_7655_0);
        vo_7655_0 = new Vo_7655_0();
        vo_7655_0.id = 0;
        send(fightContainer, new MSG_C_END_ACTION(), vo_7655_0);
        Iterator var4 = allFightObject.iterator();

        while(var4.hasNext()) {
            FightObject fightObject = (FightObject)var4.next();
            vo_19959_0 = new Vo_19959_0();
            vo_19959_0.round = fightContainer.round;
            vo_19959_0.aid = fightObject.fid;
            vo_19959_0.action = 0;
            vo_19959_0.vid = fightObject.fid;
            vo_19959_0.para = 0;
            send(fightContainer, new MSG_C_ACTION(), vo_19959_0);
            vo_19959_0 = new Vo_19959_0();
            vo_19959_0.round = fightContainer.round;
            vo_19959_0.aid = fightObject.fid;
            vo_19959_0.action = 0;
            vo_19959_0.vid = fightObject.fid;
            vo_19959_0.para = 0;
            send(fightContainer, new MSG_C_ACTION(), vo_19959_0);
            vo_7655_0 = new Vo_7655_0();
            vo_7655_0.id = fightObject.fid;
            send(fightContainer, new MSG_C_END_ACTION(), vo_7655_0);
            vo_7655_0 = new Vo_7655_0();
            vo_7655_0.id = fightObject.fid;
            send(fightContainer, new MSG_C_END_ACTION(), vo_7655_0);
        }

    }

    public static void send(FightContainer fightContainer, BaseWrite baseWrite, Object obj) {
        List<FightObject> allFightObject = getAllFightObject(fightContainer);
        Iterator var4 = allFightObject.iterator();

        while(var4.hasNext()) {
            FightObject fightObject = (FightObject)var4.next();
            if (fightObject.type == 1) {
                try {
                    GameObjectCharMng.getGameObjectChar(fightObject.id).sendOne(baseWrite, obj);
                } catch (Exception var7) {
                    log.error("    public static void send(FightContainer fightContainer, BaseWrite baseWrite, Object obj) {\n", var7);
                }
            }
        }

    }

    public static void sendTeam(FightContainer fightContainer, List<FightObject> fightObjectList, BaseWrite baseWrite, Object obj) {
        Iterator var4 = fightObjectList.iterator();

        while(var4.hasNext()) {
            FightObject fightObject = (FightObject)var4.next();
            if (fightObject.type == 1) {
                GameObjectCharMng.getGameObjectChar(fightObject.id).sendOne(baseWrite, obj);
            }
        }

    }

    private static void sendOver(FightContainer fightContainer) {
        List<FightObject> allFightObject = getAllFightObject(fightContainer);
        Iterator var2 = allFightObject.iterator();

        while(var2.hasNext()) {
            FightObject fightObject = (FightObject)var2.next();
            if (fightObject.type == 1) {
                Vo_19959_0 vo_19959_0 = new Vo_19959_0();
                vo_19959_0.round = fightContainer.round;
                vo_19959_0.aid = fightObject.fid;
                vo_19959_0.action = 43;
                vo_19959_0.vid = fightObject.fid;
                vo_19959_0.para = 0;
                send(fightContainer, new MSG_C_ACTION(), vo_19959_0);
                Vo_7655_0 vo_7655_0 = new Vo_7655_0();
                vo_7655_0.id = fightObject.fid;
                send(fightContainer, new MSG_C_END_ACTION(), vo_7655_0);
                fightObject.updateState(fightContainer, 0, 0);
                Vo_3581_0 vo_3581_0 = new Vo_3581_0();
                vo_3581_0.a = 1;
                GameObjectChar.send(new MSG_C_END_COMBAT(), vo_3581_0, fightObject.id);
                Vo_61671_0 vo_61671_0 = new Vo_61671_0();
                vo_61671_0.id = fightObject.fid;
                vo_61671_0.count = 0;
                GameObjectChar session = GameObjectCharMng.getGameObjectChar(fightObject.id);
                session.gameMap.send(new MSG_TITLE(), vo_61671_0);
                fightObject.max_shengming = fightObject.shengming;
                fightObject.update(fightContainer);
            } else if (fightObject.type == 2) {
                fightObject.max_shengming = fightObject.shengming;
                fightObject.update(fightContainer);
            }
        }

        afterFight(fightContainer);
    }

    /**
     * 是否战斗结束
     * @param fightContainer
     * @return
     */
    private static boolean isOver(FightContainer fightContainer) {
        List<FightTeam> teamList = fightContainer.teamList;
        Iterator var2 = teamList.iterator();

        boolean over;
        do {
            if (!var2.hasNext()) {
                return false;
            }

            FightTeam fightTeam = (FightTeam)var2.next();
            List<FightObject> fightObjectList = fightTeam.fightObjectList;
            over = true;
            int humanNum = 0;
            int runNum = 0;
            Iterator var8 = fightObjectList.iterator();

            while(var8.hasNext()) {
                FightObject fightObject = (FightObject)var8.next();
                if (!fightObject.isDead() && !fightObject.isRun()) {
                    over = false;
                }

                if (fightObject.type == 1) {
                    ++humanNum;
                    if (fightObject.isRun()) {
                        ++runNum;
                    }
                }
            }

            if (humanNum == runNum && humanNum > 0) {
                return true;
            }
        } while(!over);

        return true;
    }

    private static void round(FightContainer fightContainer) {
        List<FightObject> allFightObject = getAllFightObject(fightContainer);
        Vo_19959_0 vo_19959_0 = new Vo_19959_0();
        vo_19959_0.round = fightContainer.round;
        vo_19959_0.aid = 0;
        vo_19959_0.action = 0;
        vo_19959_0.vid = 0;
        vo_19959_0.para = 0;
        send(fightContainer, new MSG_C_ACTION(), vo_19959_0);
        Vo_7655_0 vo_7655_0 = new Vo_7655_0();
        vo_7655_0.id = 0;
        send(fightContainer, new MSG_C_END_ACTION(), vo_7655_0);
        Iterator var4 = allFightObject.iterator();

        while(var4.hasNext()) {
            FightObject fightObject = (FightObject)var4.next();
            if (fightObject.type == 1) {
                Vo_45141_0 vo_45141_0 = new Vo_45141_0();
                vo_45141_0.round = fightContainer.round;
                vo_45141_0.animate_done = 1;
                GameObjectChar.send(new MSG_C_CUR_ROUND(), vo_45141_0, fightObject.id);
                Vo_7659_0 vo_7659_0 = new Vo_7659_0();
                vo_7659_0.a = 0;
                vo_7659_0.id = 0;
                vo_7659_0.time = 25;
                vo_7659_0.question = 265576908;
                vo_7659_0.round = fightContainer.round;
                vo_7659_0.curTime = (int)(System.currentTimeMillis() / 1000L);
                GameObjectChar.send(new MSG_C_WAIT_COMMAND(), vo_7659_0, fightObject.id);
            }
        }

        fightContainer.roundTime = System.currentTimeMillis();
    }

    private static boolean isAllRequested(FightContainer fightContainer) {
        List<FightTeam> teamList = fightContainer.teamList;
        Iterator var2 = teamList.iterator();

        label40:
        while(true) {
            FightTeam fightTeam;
            do {
                if (!var2.hasNext()) {
                    return true;
                }

                fightTeam = (FightTeam)var2.next();
            } while(fightTeam.type == 2);

            List<FightObject> fightObjectList = fightTeam.fightObjectList;
            Iterator var5 = fightObjectList.iterator();

            FightObject fightObject;
            do {
                do {
                    do {
                        if (!var5.hasNext()) {
                            continue label40;
                        }

                        fightObject = (FightObject)var5.next();
                    } while(!fightObject.canAtta());
                } while(fightObject.type != 1 && fightObject.type != 2);
            } while(fightObject.fightRequest != null);

            return false;
        }
    }

    public static FightContainer getFightContainer() {
        int id = GameObjectChar.getGameObjectChar().chara.id;
        Iterator var1 = listFight.iterator();

        while(var1.hasNext()) {
            FightContainer fightContainer = (FightContainer)var1.next();
            List<FightTeam> teamList = fightContainer.teamList;
            Iterator var4 = teamList.iterator();

            while(var4.hasNext()) {
                FightTeam fightTeam = (FightTeam)var4.next();
                List<FightObject> fightObjectList = fightTeam.fightObjectList;
                Iterator var7 = fightObjectList.iterator();

                while(var7.hasNext()) {
                    FightObject fightObject = (FightObject)var7.next();
                    if (fightObject.fid == id) {
                        return fightContainer;
                    }
                }
            }
        }

        return null;
    }

    public static FightContainer getFightContainer(int id) {
        Iterator var1 = listFight.iterator();

        while(var1.hasNext()) {
            FightContainer fightContainer = (FightContainer)var1.next();
            List<FightTeam> teamList = fightContainer.teamList;
            Iterator var4 = teamList.iterator();

            while(var4.hasNext()) {
                FightTeam fightTeam = (FightTeam)var4.next();
                List<FightObject> fightObjectList = fightTeam.fightObjectList;
                Iterator var7 = fightObjectList.iterator();

                while(var7.hasNext()) {
                    FightObject fightObject = (FightObject)var7.next();
                    if (fightObject.fid == id) {
                        return fightContainer;
                    }
                }
            }
        }

        return null;
    }

    /**
     * 获取已方的team
     * @param fightContainer
     * @param id
     * @return
     */
    public static FightTeam getFightTeam(FightContainer fightContainer, int id) {
        List<FightTeam> teamList = fightContainer.teamList;
        Iterator var3 = teamList.iterator();

        while(var3.hasNext()) {
            FightTeam fightTeam = (FightTeam)var3.next();
            List<FightObject> fightObjectList = fightTeam.fightObjectList;
            Iterator var6 = fightObjectList.iterator();

            while(var6.hasNext()) {
                FightObject fightObject = (FightObject)var6.next();
                if (fightObject.fid == id) {
                    return fightTeam;
                }
            }
        }

        return null;
    }

    /**
     * 获取对手team
     * @param fightContainer
     * @param id
     * @return
     */
    public static FightTeam getFightTeamDM(FightContainer fightContainer, int id) {
        List<FightTeam> teamList = fightContainer.teamList;
        Iterator var3 = teamList.iterator();

        while(var3.hasNext()) {
            FightTeam fightTeam = (FightTeam)var3.next();
            List<FightObject> fightObjectList = fightTeam.fightObjectList;
            Iterator var6 = fightObjectList.iterator();

            while(var6.hasNext()) {
                FightObject fightObject = (FightObject)var6.next();
                if (fightObject.fid == id) {
                    return teamList.get(0) == fightTeam ? (FightTeam)teamList.get(1) : (FightTeam)teamList.get(0);
                }
            }
        }

        return null;
    }

    private static List<FightObject> getAllFightObject(FightContainer fightContainer) {
        List<FightObject> list = new ArrayList();
        Iterator var2 = fightContainer.teamList.iterator();

        while(var2.hasNext()) {
            FightTeam fightTeam = (FightTeam)var2.next();
            list.addAll(fightTeam.fightObjectList);
        }

        return list;
    }

    public static FightObject getFightObject(int id) {
        Iterator var1 = listFight.iterator();

        while(var1.hasNext()) {
            FightContainer fightContainer = (FightContainer)var1.next();
            List<FightTeam> teamList = fightContainer.teamList;
            Iterator var4 = teamList.iterator();

            while(var4.hasNext()) {
                FightTeam fightTeam = (FightTeam)var4.next();
                List<FightObject> fightObjectList = fightTeam.fightObjectList;
                Iterator var7 = fightObjectList.iterator();

                while(var7.hasNext()) {
                    FightObject fightObject = (FightObject)var7.next();
                    if (fightObject.fid == id) {
                        return fightObject;
                    }
                }
            }
        }

        return null;
    }

    public static FightObject getFightObject(FightContainer fightContainer, int id) {
        List<FightTeam> teamList = fightContainer.teamList;
        Iterator var3 = teamList.iterator();

        while(var3.hasNext()) {
            FightTeam fightTeam = (FightTeam)var3.next();
            List<FightObject> fightObjectList = fightTeam.fightObjectList;
            Iterator var6 = fightObjectList.iterator();

            while(var6.hasNext()) {
                FightObject fightObject = (FightObject)var6.next();
                if (fightObject.fid == id) {
                    return fightObject;
                }
            }
        }

        return null;
    }

    public static FightObject getFightObjectPet(FightContainer fightContainer, FightObject fightObject) {
        List<FightTeam> teamList = fightContainer.teamList;
        Iterator var3 = teamList.iterator();

        while(var3.hasNext()) {
            FightTeam fightTeam = (FightTeam)var3.next();
            List<FightObject> fightObjectList = fightTeam.fightObjectList;
            Iterator var6 = fightObjectList.iterator();

            while(var6.hasNext()) {
                FightObject tfightObject = (FightObject)var6.next();
                if (tfightObject.cid == fightObject.id) {
                    return tfightObject;
                }
            }
        }

        return null;
    }

    public static List<FightObject> getAlive(List<FightObject> list) {
        List<FightObject> rlist = new ArrayList();
        Iterator var2 = list.iterator();

        while(var2.hasNext()) {
            FightObject fightObject = (FightObject)var2.next();
            if (!fightObject.isDead()) {
                rlist.add(fightObject);
            }
        }

        return rlist;
    }

    /**
     * 找技能范围目标
     * @param fightContainer
     * @param fightRequest
     * @param type  1：敌方内寻找 ，2：友方内寻找，必定包括fightRequest.vid，3：友方内寻找，纯随机，不一定包括fightRequest.vid
     * @param num   技能目标数量
     * @return
     */
    public static List<FightObject> findTarget(FightContainer fightContainer, FightRequest fightRequest, int type, int num) {
        List<FightObject> fightObjects = new ArrayList();
        FightObject newTarget;
        FightTeam friendsFightTeam;
        List alive;
        Iterator iterator;
        int i;
        if (type == 1) {
            if (num == 1) {
                FightObject fightObject = getFightObject(fightContainer, fightRequest.vid);
                if (fightObject.isDead()) {
                    FightTeam opponentsFightTeam = getFightTeamDM(fightContainer, fightRequest.id);
                    List<FightObject> fightObjects1 = getAlive(opponentsFightTeam.fightObjectList);
                    newTarget = (FightObject)fightObjects1.get(RANDOM.nextInt(fightObjects1.size()));
                    fightObjects.add(newTarget);
                } else {
                    fightObjects.add(fightObject);
                }
            } else {
                friendsFightTeam = getFightTeamDM(fightContainer, fightRequest.id);
                alive = getAlive(friendsFightTeam.fightObjectList);
                iterator = alive.iterator();

                while(iterator.hasNext()) {
                    newTarget = (FightObject)iterator.next();
                    if (newTarget.fid == fightRequest.vid) {
                        --num;
                        fightObjects.add(newTarget);
                        iterator.remove();
                    }
                }

                for(i = 0; i < num && alive.size() != 0; ++i) {
                    newTarget = (FightObject)alive.remove(RANDOM.nextInt(alive.size()));
                    fightObjects.add(newTarget);
                }
            }
        } else if (type == 2) {
            friendsFightTeam = getFightTeam(fightContainer, fightRequest.id);
            alive = getAlive(friendsFightTeam.fightObjectList);
            iterator = alive.iterator();

            while(iterator.hasNext()) {
                newTarget = (FightObject)iterator.next();
                if (newTarget.fid == fightRequest.vid) {
                    --num;
                    fightObjects.add(newTarget);
                    iterator.remove();
                }
            }

            for(i = 0; i < num && alive.size() != 0; ++i) {
                newTarget = (FightObject)alive.remove(RANDOM.nextInt(alive.size()));
                fightObjects.add(newTarget);
            }
        } else if (type == 3) {
            friendsFightTeam = getFightTeam(fightContainer, fightRequest.id);
            alive = getAlive(friendsFightTeam.fightObjectList);

            for(i = 0; i < num && alive.size() != 0; ++i) {
                newTarget = (FightObject)alive.remove(RANDOM.nextInt(alive.size()));
                fightObjects.add(newTarget);
            }
        }

        return fightObjects;
    }

    private static void afterFight(FightContainer fightContainer) {
        List<FightTeam> teamList = fightContainer.teamList;
        Iterator var2 = teamList.iterator();

        while(true) {
            int i;
            while(var2.hasNext()) {
                FightTeam fightTeam = (FightTeam)var2.next();
                List<FightObject> fightObjectList = fightTeam.fightObjectList;
                Iterator var5 = fightObjectList.iterator();

                while(var5.hasNext()) {
                    FightObject fightObject = (FightObject)var5.next();
                    if (fightObject.type == 1) {
                        i = fightObject.fid;
                        Chara chara = GameObjectCharMng.getGameObjectChar(i).chara;
                        GameUtilRenWu.feiditu(chara.mapid, chara);
                        break;
                    }
                }
            }

            List<FightObject> guaiwu = guaiwu(fightContainer);
            boolean monsterNotAllDead = false;
            if (guaiwu != null) {
                Iterator var16 = guaiwu.iterator();

                while(var16.hasNext()) {
                    FightObject fightObject = (FightObject)var16.next();
                    if (!fightObject.isDead()) {
                        monsterNotAllDead = true;
                    }
                }
            }

            Chara chara1 = chara(fightContainer);
            GameUtilRenWu.feiditu(chara1.mapid, chara1);
            if (!monsterNotAllDead) {
                if (chara1.npcchubao.size() > 0 && guaiwu != null && ((Vo_65529_0)chara1.npcchubao.get(0)).name.equals(((FightObject)guaiwu.get(0)).str)) {
                    if (GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam != null && GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu != null) {
                        for(i = 0; i < GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu.size(); ++i) {
                            GameUtil.chubaorenwu(chara1, (Chara)GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu.get(i));
                        }
                    } else {
                        GameUtil.chubaorenwu(chara1, chara1);
                    }

                    return;
                }

                if (chara1.npcshuadao.size() > 0 && guaiwu != null && ((Vo_65529_0)chara1.npcshuadao.get(0)).name.equals(((FightObject)guaiwu.get(0)).str)) {
                    if (GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam != null && GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu != null) {
                        for(i = 0; i < GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu.size(); ++i) {
                            GameUtil.nextshuadao(chara1, (Chara)GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu.get(i));
                        }
                    } else {
                        GameUtil.nextshuadao(chara1, chara1);
                    }

                    return;
                }

                if (chara1.npcxuanshang.size() > 0 && "仙界叛逆".equals(((FightObject)guaiwu.get(0)).str)) {
                    if (GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam != null && GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu != null) {
                        for(i = 0; i < GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu.size(); ++i) {
                            GameUtil.nextxuanshang(chara1, (Chara)GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu.get(i));
                        }
                    } else {
                        GameUtil.nextxuanshang(chara1, chara1);
                    }

                    return;
                }

                if (guaiwu != null && chara1.xiuxingNpcname.equals(((FightObject)guaiwu.get(0)).str)) {
                    boolean isZhenZhu = false;
                    if(chara1.xiuxingNpcname.contains("阵主")) isZhenZhu = true;
                    if (GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam != null && GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu != null) {
                        for(i = 0; i < GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu.size(); ++i) {
                            if(isZhenZhu)
                            {
                                GameUtil.nextzhengzhu(chara1, (Chara)GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu.get(i));
                                continue;
                            }
                            GameUtil.nextxiuxing(chara1, (Chara)GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu.get(i));
                        }
                    } else {
                        if(isZhenZhu)
                        {
                            GameUtil.nextzhengzhu(chara1, chara1);
                            continue;
                        }
                        GameUtil.nextxiuxing(chara1, chara1);
                    }

                    return;
                }

                for(i = 0; i < GameLine.gameShuaGuai.shuaXing.size(); ++i) {
                    if (guaiwu != null && ((Vo_65529_0)GameLine.gameShuaGuai.shuaXing.get(i)).name.equals(((FightObject)guaiwu.get(0)).str)) {
                        String replace = "";
                        if (((FightObject)guaiwu.get(0)).str.length() > 1) {
                            String substring = ((FightObject)guaiwu.get(0)).str.substring(1, 2);
                            replace = ((FightObject)guaiwu.get(0)).str.replace(substring, "");
                        }

                        if (GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam != null && GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu != null) {
                            for(i = 0; i < GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu.size(); ++i) {
                                GameUtil.nextshaxing(chara1, (Chara)GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu.get(i), ((FightObject)guaiwu.get(0)).guaiwulevel, replace);
                            }
                        } else {
                            GameUtil.nextshaxing(chara1, chara1, ((FightObject)guaiwu.get(0)).guaiwulevel, replace);
                        }

                        GameObjectChar.sendduiwu(new M12285_1(), ((Vo_65529_0)GameLine.gameShuaGuai.shuaXing.get(i)).id, chara1.id);
                        GameLine.gameShuaGuai.shuaXing.remove(GameLine.gameShuaGuai.shuaXing.get(i));
                        return;
                    }
                }

                if (guaiwu != null && "试道元魔".equals(((FightObject)guaiwu.get(0)).str)) {
                    if (GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam != null && GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu != null) {
                        for(i = 0; i < GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu.size(); ++i) {
                            GameUtil.shidaojingyan(chara1, (Chara)GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu.get(i), ((FightObject)guaiwu.get(0)).id);
                        }
                    } else {
                        GameUtil.shidaojingyan(chara1, chara1, ((FightObject)guaiwu.get(0)).id);
                    }

                    return;
                }
                if (chara1.mapid == 37000 && guaiwu != null && (guaiwu.get(0)).str.contains("星君")) {//通天塔挑战成功
                    assert chara1.ttt_xj_name.equals(guaiwu.get(0).str);
                    if(chara1.ttt_layer==chara1.level){//突破修炼
                        GameUtil.a49157_exp(chara1, 1000);//TODO
                    }

                    if(chara1.ttt_layer>chara1.level){//突破层

                    }

                    chara1.onTttChallengeSuccess();
                    GameUtil.notifyTTTPanelInfo(chara1);
                    GameUtilRenWu.notifyTTTTask(chara1);
                    return;
                }

                //妖王
                if (null != guaiwu && ((FightObject)guaiwu.get(0)).str.contains("妖王")){
                    System.out.println("妖王");
                    GameShangGuYaoWang.onReward(chara1,((FightObject)guaiwu.get(0)).str);
                    return;
                }

                if (chara1.mapid == 38004) {
                    GameShiDao var10000 = GameObjectCharMng.getGameObjectChar(chara1.id).gameMap.gameShiDao;
                    if (GameShiDao.statzhuangtai == 3) {
                        teamList = fightContainer.teamList;

                        label267:
                        for(i = 0; i < teamList.size(); ++i) {
                            boolean iswin = true;
                            Iterator var23 = ((FightTeam)teamList.get(i)).fightObjectList.iterator();

                            FightObject fightObject;
                            while(var23.hasNext()) {
                                fightObject = (FightObject)var23.next();
                                if (fightObject.isDead()) {
                                    iswin = false;
                                }
                            }

                            List gameSessions;
                            String mingname;
                            int mingci;
                            int j;
                            Vo_20481_0 vo_20481_0;
                            Chara var26;
                            if (iswin) {
                                var23 = ((FightTeam)teamList.get(i)).fightObjectList.iterator();

                                while(true) {
                                    do {
                                        if (!var23.hasNext()) {
                                            continue label267;
                                        }

                                        fightObject = (FightObject)var23.next();
                                    } while(fightObject.type == 2);

                                    var26 = GameObjectCharMng.getGameObjectChar(fightObject.id).chara;
                                    var26.shidaodaguaijifen += 25;
                                    gameSessions = SaveCharaTimes.insertionSort(GameObjectCharMng.getGameObjectChar(fightObject.id).gameMap.sessionList);
                                    mingname = "";
                                    mingci = 0;

                                    for(j = 0; j < gameSessions.size(); ++j) {
                                        if (!mingname.equals(((Chara)((GameObjectChar)gameSessions.get(j)).gameTeam.duiwu.get(0)).name + ((Chara)((GameObjectChar)gameSessions.get(j)).gameTeam.duiwu.get(0)).shidaodaguaijifen)) {
                                            mingname = ((Chara)((GameObjectChar)gameSessions.get(j)).gameTeam.duiwu.get(0)).name + ((Chara)((GameObjectChar)gameSessions.get(j)).gameTeam.duiwu.get(0)).shidaodaguaijifen;
                                            ++mingci;
                                        }
                                    }

                                    vo_20481_0 = new Vo_20481_0();
                                    vo_20481_0.msg = "你当前队伍积分" + GameObjectCharMng.getGameObjectChar(fightObject.id).chara.shidaodaguaijifen;
                                    vo_20481_0.time = (int)(System.currentTimeMillis() / 1000L);
                                    GameObjectCharMng.getGameObjectChar(fightObject.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                                }
                            } else {
                                var23 = ((FightTeam)teamList.get(i)).fightObjectList.iterator();

                                while(true) {
                                    do {
                                        if (!var23.hasNext()) {
                                            continue label267;
                                        }

                                        fightObject = (FightObject)var23.next();
                                    } while(fightObject.type == 2);

                                    var26 = GameObjectCharMng.getGameObjectChar(fightObject.id).chara;
                                    var26.shidaodaguaijifen -= 25;
                                    --GameObjectCharMng.getGameObjectChar(fightObject.id).chara.shidaocishu;
                                    gameSessions = SaveCharaTimes.insertionSort(GameObjectCharMng.getGameObjectChar(fightObject.id).gameMap.sessionList);
                                    mingname = "";
                                    mingci = 0;

                                    for(j = 0; j < gameSessions.size(); ++j) {
                                        if (!mingname.equals(((Chara)((GameObjectChar)gameSessions.get(j)).gameTeam.duiwu.get(0)).name + ((Chara)((GameObjectChar)gameSessions.get(j)).gameTeam.duiwu.get(0)).shidaodaguaijifen)) {
                                            mingname = ((Chara)((GameObjectChar)gameSessions.get(j)).gameTeam.duiwu.get(0)).name + ((Chara)((GameObjectChar)gameSessions.get(j)).gameTeam.duiwu.get(0)).shidaodaguaijifen;
                                            ++mingci;
                                        }
                                    }

                                    ListVo_65527_0 listVo_65527_0;
                                    if (mingci == 3) {
                                        TitleService.grantTitle(GameObjectCharMng.getGameObjectChar(fightObject.id), TitleConst.TITLE_EVENT_YONGZHE, TitleConst.TITLE_YONGZHE);
                                        GameObjectCharMng.getGameObjectChar(fightObject.id).chara.chenghao.put("试道勇者", "试道勇者");
                                        GameUtil.chenghaoxiaoxi(GameObjectCharMng.getGameObjectChar(fightObject.id).chara);
                                        vo_20481_0 = new Vo_20481_0();
                                        vo_20481_0.msg = "你获得了#R试道勇者#n的称谓。";
                                        vo_20481_0.time = (int)(System.currentTimeMillis() / 1000L);
                                        GameObjectCharMng.getGameObjectChar(fightObject.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                                        GameObjectCharMng.getGameObjectChar(fightObject.id).chara.extra_life += 50000;
                                        vo_20481_0 = new Vo_20481_0();
                                        vo_20481_0.msg = "你获得了50000元宝。";
                                        vo_20481_0.time = (int)(System.currentTimeMillis() / 1000L);
                                        GameObjectCharMng.getGameObjectChar(fightObject.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                                        listVo_65527_0 = GameUtil.a65527(GameObjectCharMng.getGameObjectChar(fightObject.id).chara);
                                        GameObjectCharMng.getGameObjectChar(fightObject.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
                                    }

                                    if (mingci == 2) {
                                        TitleService.grantTitle(GameObjectCharMng.getGameObjectChar(fightObject.id), TitleConst.TITLE_EVENT_YONGZHE, TitleConst.TITLE_YONGZHE);
                                        GameObjectCharMng.getGameObjectChar(fightObject.id).chara.chenghao.put("试道勇者", "试道勇者");
                                        GameUtil.chenghaoxiaoxi(GameObjectCharMng.getGameObjectChar(fightObject.id).chara);
                                        vo_20481_0 = new Vo_20481_0();
                                        vo_20481_0.msg = "你获得了#R试道勇者#n的称谓。";
                                        vo_20481_0.time = (int)(System.currentTimeMillis() / 1000L);
                                        GameObjectCharMng.getGameObjectChar(fightObject.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                                        GameObjectCharMng.getGameObjectChar(fightObject.id).chara.extra_life += 100000;
                                        vo_20481_0 = new Vo_20481_0();
                                        vo_20481_0.msg = "你获得了100000元宝。";
                                        vo_20481_0.time = (int)(System.currentTimeMillis() / 1000L);
                                        GameObjectCharMng.getGameObjectChar(fightObject.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                                        listVo_65527_0 = GameUtil.a65527(GameObjectCharMng.getGameObjectChar(fightObject.id).chara);
                                        GameObjectCharMng.getGameObjectChar(fightObject.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
                                    }

                                    vo_20481_0 = new Vo_20481_0();
                                    vo_20481_0.msg = "你当前队伍积分" + GameObjectCharMng.getGameObjectChar(fightObject.id).chara.shidaodaguaijifen;
                                    vo_20481_0.time = (int)(System.currentTimeMillis() / 1000L);
                                    GameObjectCharMng.getGameObjectChar(fightObject.id).sendOne(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                                    if (GameObjectCharMng.getGameObjectChar(fightObject.id).chara.shidaocishu <= 0) {
                                        GameUtilRenWu.shidaohuicheng(GameObjectCharMng.getGameObjectChar(fightObject.id).chara);
                                    }
                                }
                            }
                        }

                        return;
                    }
                }

                if (guaiwu != null) {
                    if (GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam != null && GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu != null) {
                        for(i = 0; i < GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu.size(); ++i) {
                            GameUtil.shuayeguai(chara1, (Chara)GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu.get(i), ((FightObject)guaiwu.get(0)).guaiwulevel);
                        }
                    } else {
                        GameUtil.shuayeguai(chara1, chara1, ((FightObject)guaiwu.get(0)).guaiwulevel);
                    }
                }
            }else{
                if (chara1.mapid == 37000 ) {//通天塔挑战失败
                    assert chara1.ttt_xj_name.equals(guaiwu.get(0).str);
                    chara1.onTttChallengeFail();
                    GameUtil.notifyTTTPanelInfo(chara1);
                    return;
                }
            }

            return;
        }
    }

    /**
     * 怪物阵营的战斗对象列表
     * @param fightContainer
     * @return
     */
    private static List<FightObject> guaiwu(FightContainer fightContainer) {
        List<FightTeam> teamList = fightContainer.teamList;
        Iterator var2 = teamList.iterator();

        FightTeam fightTeam;
        do {
            if (!var2.hasNext()) {
                return null;
            }

            fightTeam = (FightTeam)var2.next();
        } while(fightTeam.type != 2);

        List<FightObject> fightObjectList = fightTeam.fightObjectList;
        return fightObjectList;
    }

    /**
     * 找到第一个玩家
     * @param fightContainer
     * @return
     */
    private static Chara chara(FightContainer fightContainer) {
        List<FightTeam> teamList = fightContainer.teamList;
        Iterator var2 = teamList.iterator();

        while(true) {
            FightTeam fightTeam;
            do {
                if (!var2.hasNext()) {
                    return null;
                }

                fightTeam = (FightTeam)var2.next();
            } while(fightTeam.type != 1);

            List<FightObject> fightObjectList = fightTeam.fightObjectList;
            Iterator var5 = fightObjectList.iterator();

            while(var5.hasNext()) {
                FightObject fightObject = (FightObject)var5.next();
                if (fightObject.type == 1) {
                    int fid = fightObject.fid;
                    Chara chara = GameObjectCharMng.getGameObjectChar(fid).chara;
                    return chara;
                }
            }
        }
    }

    public static void goFight(Chara chara, Chara charaduishou) {
        FightContainer fc = getFightContainer(chara.id);
        if (fc == null) {
            fc = getFightContainer(charaduishou.id);
            if (fc == null) {
                fc = new FightContainer();
                FightTeam ft = new FightTeam();
                ft.type = 1;
                GameObjectChar session = GameObjectCharMng.getGameObjectChar(chara.id);
                int num = 0;
                FightObject fightObject;
                List fightObjectList;
                Petbeibao petbeibao;
                Vo_12023_0 vo_12023_0;
                XiuluoshuSkill xiuluoshuSkill;
                if (session.gameTeam != null) {
                    for(num = 0; num < session.gameTeam.duiwu.size(); ++num) {
                        fightObject = new FightObject((Chara)session.gameTeam.duiwu.get(num));
                        fightObject.pos = (Integer)PERSON_POS.get(num);
                        fightObject.fid = ((Chara)session.gameTeam.duiwu.get(num)).id;
                        fightObject.id = ((Chara)session.gameTeam.duiwu.get(num)).id;
                        if (num == 0) {
                            fightObject.leader = 1;
                        }

                        addFabao(fc, (Chara)session.gameTeam.duiwu.get(num), fightObject);
                        ft.add(fightObject);
                        fightObjectList = ((Chara)session.gameTeam.duiwu.get(num)).pets;

                        for( int j = 0; j < fightObjectList.size(); ++j) {
                            if (((Petbeibao)fightObjectList.get(j)).id == ((Chara)session.gameTeam.duiwu.get(num)).chongwuchanzhanId) {
                                petbeibao = (Petbeibao)fightObjectList.get(j);
                                fightObject = new FightObject((Petbeibao)fightObjectList.get(j));
                                fightObject.pos = (Integer)PERSON_POS.get(num) + 5;
                                fightObject.fid = ((Petbeibao)fightObjectList.get(j)).id;
                                fightObject.id = ((Petbeibao)fightObjectList.get(j)).id;
                                fightObject.cid = ((Chara)session.gameTeam.duiwu.get(num)).id;
                                ft.add(fightObject);
                                if (petbeibao.tianshu.size() != 0) {
                                    vo_12023_0 = (Vo_12023_0)petbeibao.tianshu.get(RANDOM.nextInt(petbeibao.tianshu.size()));
                                    fightObject.godbook = (Integer)FightTianshuMap.TIANSHU_EFFECT.get(vo_12023_0.god_book_skill_name);
                                    if (vo_12023_0.god_book_skill_name.equals("修罗术")) {
                                        xiuluoshuSkill = new XiuluoshuSkill();
                                        xiuluoshuSkill.buffObject = fightObject;
                                        xiuluoshuSkill.fightContainer = fc;
                                        fightObject.addSkill(xiuluoshuSkill);
                                    }
                                }
                                break;
                            }
                        }

                        ++num;
                    }
                } else {
                    FightObject object = new FightObject(chara);
                    object.pos = (Integer)PERSON_POS.get(num);
                    object.fid = chara.id;
                    object.leader = 1;
                    object.id = chara.id;
                    addFabao(fc, chara, object);
                    ft.add(object);
                    List<Petbeibao> pets = chara.pets;

                    for(int j = 0; j < pets.size(); ++j) {
                        if (((Petbeibao)pets.get(j)).id == chara.chongwuchanzhanId) {
                            Petbeibao petbeibao2 = (Petbeibao)pets.get(j);
                            object = new FightObject((Petbeibao)pets.get(j));
                            object.pos = (Integer)PERSON_POS.get(num) + 5;
                            object.fid = ((Petbeibao)pets.get(j)).id;
                            object.id = ((Petbeibao)pets.get(j)).id;
                            object.cid = chara.id;
                            ft.add(object);

                            if (petbeibao2.tianshu.size() != 0) {
                                Vo_12023_0 vo120230 = (Vo_12023_0)petbeibao2.tianshu.get(RANDOM.nextInt(petbeibao2.tianshu.size()));
                                object.godbook = (Integer)FightTianshuMap.TIANSHU_EFFECT.get(vo120230.god_book_skill_name);
                                if (vo120230.god_book_skill_name.equals("修罗术")) {
                                    XiuluoshuSkill skill = new XiuluoshuSkill();
                                    skill.buffObject = object;
                                    skill.fightContainer = fc;
                                    object.addSkill(skill);
                                }
                            }
                            break;
                        }
                    }

                    ++num;
                }

                FightTeam ftother = new FightTeam();
                ftother.type = 1;
                GameObjectChar gameObjectChar = GameObjectCharMng.getGameObjectChar(charaduishou.id);
                num = 0;
                FightObject object;
                if (gameObjectChar.gameTeam != null) {
                    for(int i = 0; i < gameObjectChar.gameTeam.duiwu.size(); ++i) {
                        object = new FightObject((Chara)gameObjectChar.gameTeam.duiwu.get(i));
                        object.pos = (Integer)PERSON_POS.get(num);
                        object.fid = ((Chara)gameObjectChar.gameTeam.duiwu.get(i)).id;
                        object.id = ((Chara)gameObjectChar.gameTeam.duiwu.get(i)).id;
                        if (i == 0) {
                            object.leader = 1;
                        }

                        addFabao(fc, (Chara)gameObjectChar.gameTeam.duiwu.get(i), object);
                        ftother.add(object);
                        List<Petbeibao> pets = ((Chara)gameObjectChar.gameTeam.duiwu.get(i)).pets;

                        for(int j = 0; j < pets.size(); ++j) {
                            if (((Petbeibao)pets.get(j)).id == ((Chara)gameObjectChar.gameTeam.duiwu.get(i)).chongwuchanzhanId) {
                                Petbeibao q = (Petbeibao)pets.get(j);
                                object = new FightObject((Petbeibao)pets.get(j));
                                object.pos = (Integer)PERSON_POS.get(num) + 5;
                                object.fid = ((Petbeibao)pets.get(j)).id;
                                object.id = ((Petbeibao)pets.get(j)).id;
                                object.cid = ((Chara)gameObjectChar.gameTeam.duiwu.get(i)).id;
                                ftother.add(object);

                                if (q.tianshu.size() != 0) {
                                    Vo_12023_0 vo120230 = (Vo_12023_0)q.tianshu.get(RANDOM.nextInt(q.tianshu.size()));
                                    object.godbook = (Integer)FightTianshuMap.TIANSHU_EFFECT.get(vo120230.god_book_skill_name);
                                    if (vo120230.god_book_skill_name.equals("修罗术")) {
                                        XiuluoshuSkill skill = new XiuluoshuSkill();
                                        skill.buffObject = object;
                                        skill.fightContainer = fc;
                                        object.addSkill(skill);
                                    }
                                }
                                break;
                            }
                        }

                        ++num;
                    }
                } else {
                    object = new FightObject(charaduishou);
                    object.pos = (Integer)PERSON_POS.get(num);
                    object.fid = charaduishou.id;
                    object.leader = 1;
                    object.id = charaduishou.id;
                    addFabao(fc, charaduishou, object);
                    ftother.add(object);
                    fightObjectList = charaduishou.pets;

                    for(int j = 0; j < fightObjectList.size(); ++j) {
                        if (((Petbeibao)fightObjectList.get(j)).id == charaduishou.chongwuchanzhanId) {
                            petbeibao = (Petbeibao)fightObjectList.get(j);
                            object = new FightObject(petbeibao);
                            object.pos = (Integer)PERSON_POS.get(num) + 5;
                            object.fid = ((Petbeibao)fightObjectList.get(j)).id;
                            object.id = ((Petbeibao)fightObjectList.get(j)).id;
                            object.cid = charaduishou.id;
                            if (petbeibao.tianshu.size() != 0) {
                                vo_12023_0 = (Vo_12023_0)petbeibao.tianshu.get(RANDOM.nextInt(petbeibao.tianshu.size()));
                                object.godbook = (Integer)FightTianshuMap.TIANSHU_EFFECT.get(vo_12023_0.god_book_skill_name);
                                if (vo_12023_0.god_book_skill_name.equals("修罗术")) {
                                    xiuluoshuSkill = new XiuluoshuSkill();
                                    xiuluoshuSkill.buffObject = object;
                                    xiuluoshuSkill.fightContainer = fc;
                                    object.addSkill(xiuluoshuSkill);
                                }
                            }

                            ftother.add(object);
                            break;
                        }
                    }

                    ++num;
                }

                fc.teamList.add(ft);
                fc.teamList.add(ftother);
                listFight.add(fc);
                List<FightObject> fightObjectListAll = getAllFightObject(fc);
                Iterator var21 = fightObjectListAll.iterator();

                while(var21.hasNext()) {
                    object = (FightObject)var21.next();
                    if (object.type == 1) {
                        GameObjectChar objectChar = GameObjectCharMng.getGameObjectChar(object.id);
                        Chara tchar = objectChar.chara;
                        if (chara.autofight_select != 0) {
                            Vo_32985_0 vo_32985_0 = new Vo_32985_0();
                            vo_32985_0.user_is_multi = 0;
                            vo_32985_0.user_round = tchar.autofight_select;
                            vo_32985_0.user_action = tchar.autofight_skillaction;
                            vo_32985_0.user_next_action = tchar.autofight_skillaction;
                            vo_32985_0.user_para = tchar.autofight_skillno;
                            vo_32985_0.user_next_para = tchar.autofight_skillno;
                            vo_32985_0.pet_is_multi = 0;
                            vo_32985_0.pet_round = 0;
                            vo_32985_0.pet_action = 0;
                            vo_32985_0.pet_next_action = 0;
                            vo_32985_0.pet_para = 0;
                            vo_32985_0.pet_next_para = 0;
                            GameObjectChar.send(new MSG_AUTO_FIGHT_SKIL(), vo_32985_0);
                        }

                        Vo_61671_0 vo_61671_0 = new Vo_61671_0();
                        vo_61671_0.id = object.id;
                        vo_61671_0.count = 1;
                        vo_61671_0.list.add(1);
                        objectChar.gameMap.send(new MSG_TITLE(), vo_61671_0);
                    }
                }

                Vo_3583_0 vo_3583_0 = new Vo_3583_0();
                vo_3583_0.a = 1;
                vo_3583_0.b = 3;
                send(fc, new MSG_C_START_COMBAT(), vo_3583_0);
                Iterator var25 = fightObjectListAll.iterator();

                while(var25.hasNext()) {
                    object = (FightObject)var25.next();
                    if (object.type == 2) {
                        Vo_64971_0 vo_64971_0 = new Vo_64971_0();
                        vo_64971_0.count = 1;
                        vo_64971_0.id = object.id;
                        vo_64971_0.haveCalled = 1;
                        GameObjectCharMng.getGameObjectChar(object.cid);
                        GameObjectChar.send(new MSG_C_REFRESH_PET_LIST(), vo_64971_0);
                    }
                }

                List<Vo_65017_0> list65019 = new ArrayList();
                fightObjectList = getFightTeam(fc, chara.id).fightObjectList;
                Iterator var34 = fightObjectList.iterator();

                while(var34.hasNext()) {
                    FightObject object1 = (FightObject)var34.next();
                    Vo_65017_0 vo_65019_0 = new Vo_65017_0();
                    vo_65019_0.id = object1.fid;
                    vo_65019_0.leader = object1.leader;
                    vo_65019_0.weapon_icon = object1.weapon_icon;
                    vo_65019_0.pos = object1.pos;
                    vo_65019_0.rank = object1.rank;
                    vo_65019_0.vip_type = 0;
                    vo_65019_0.str = object1.str;
                    vo_65019_0.type = object1.org_icon;
                    vo_65019_0.durability = object1.durability;
                    vo_65019_0.req_level = 0;
                    vo_65019_0.upgrade_level = 0;
                    vo_65019_0.upgrade_type = 0;
                    vo_65019_0.dex = object1.max_mofa;
                    vo_65019_0.max_mana = object1.max_mofa;
                    vo_65019_0.max_life = object1.max_shengming;
                    vo_65019_0.def = object1.max_shengming;
                    vo_65019_0.org_icon = object1.org_icon;
                    vo_65019_0.suit_icon = object1.suit_icon;
                    vo_65019_0.suit_light_effect = object1.suit_light_effect;
                    vo_65019_0.special_icon = 0;
                    vo_65019_0.portrait = object1.org_icon;
                    list65019.add(vo_65019_0);
                }

                List<Vo_65017_0> list65017 = new ArrayList();
                List<FightObject> fightObjectListOther = getFightTeamDM(fc, chara.id).fightObjectList;
                Iterator var43 = fightObjectListOther.iterator();

                FightObject object1;
                while(var43.hasNext()) {
                    object1 = (FightObject)var43.next();
                    Vo_65017_0 vo_65017_0 = new Vo_65017_0();
                    vo_65017_0.id = object1.fid;
                    vo_65017_0.leader = object1.leader;
                    vo_65017_0.weapon_icon = object1.weapon_icon;
                    vo_65017_0.pos = object1.pos;
                    vo_65017_0.rank = 0;
                    vo_65017_0.vip_type = 0;
                    vo_65017_0.str = object1.str;
                    vo_65017_0.type = object1.org_icon;
                    vo_65017_0.durability = 2;
                    vo_65017_0.req_level = 0;
                    vo_65017_0.upgrade_level = 0;
                    vo_65017_0.upgrade_type = 0;
                    vo_65017_0.dex = object1.max_mofa;
                    vo_65017_0.max_mana = object1.max_mofa;
                    vo_65017_0.max_life = object1.max_shengming;
                    vo_65017_0.def = object1.max_shengming;
                    vo_65017_0.org_icon = object1.org_icon;
                    vo_65017_0.suit_icon = object1.suit_icon;
                    vo_65017_0.suit_light_effect = object1.suit_light_effect;
                    vo_65017_0.portrait = object1.org_icon;
                    vo_65017_0.special_icon = 0;
                    list65017.add(vo_65017_0);
                }

                sendTeam(fc, fightObjectList, new MSG_C_FRIENDS(), list65019);
                sendTeam(fc, fightObjectList, new MSG_C_OPPONENTS(), list65017);
                sendTeam(fc, fightObjectListOther, new MSG_C_FRIENDS(), list65017);
                sendTeam(fc, fightObjectListOther, new MSG_C_OPPONENTS(), list65019);
                fightObjectList = getAllFightObject(fc);
                var43 = fightObjectList.iterator();

                while(var43.hasNext()) {
                    object1 = (FightObject)var43.next();
                    if (object1.godbook != 0) {
                        Vo_12025_0 vo_12025_0 = new Vo_12025_0();
                        vo_12025_0.id = object1.fid;
                        vo_12025_0.effect_no = object1.godbook;
                        send(fc, new MSG_GODBOOK_EFFECT_NORMAL(), vo_12025_0);
                    }
                }

                round(fc);
            }
        }
    }

    public static void goFight(Chara chara, List<String> monsterList, Vo_65529_0 vo_65529_0) {
        FightContainer fc;
        for(fc = getFightContainer(chara.id); fc != null; fc = getFightContainer(chara.id)) {
            listFight.remove(fc);
        }

        fc = new FightContainer();
        FightTeam ft = new FightTeam();
        ft.type = 1;
        GameObjectChar session = GameObjectCharMng.getGameObjectChar(chara.id);
        int num = 0;
        if (session.gameTeam != null) {
            for(int i = 0; i < session.gameTeam.duiwu.size(); ++i) {
                FightObject fightObject = new FightObject((Chara)session.gameTeam.duiwu.get(i));
                fightObject.pos = (Integer)PERSON_POS.get(num);
                fightObject.fid = ((Chara)session.gameTeam.duiwu.get(i)).id;
                fightObject.id = ((Chara)session.gameTeam.duiwu.get(i)).id;
                if (i == 0) {
                    fightObject.leader = 1;
                }

                addFabao(fc, (Chara)session.gameTeam.duiwu.get(i), fightObject);
                ft.add(fightObject);
                List<Petbeibao> pets = ((Chara)session.gameTeam.duiwu.get(i)).pets;

                for(int j = 0; j < pets.size(); ++j) {
                    if (((Petbeibao)pets.get(j)).id == ((Chara)session.gameTeam.duiwu.get(i)).chongwuchanzhanId) {
                        fightObject = new FightObject((Petbeibao)pets.get(j));
                        fightObject.pos = (Integer)PERSON_POS.get(num) + 5;
                        fightObject.fid = ((Petbeibao)pets.get(j)).id;
                        fightObject.id = ((Petbeibao)pets.get(j)).id;
                        fightObject.cid = ((Chara)session.gameTeam.duiwu.get(i)).id;
                        ft.add(fightObject);
                        break;
                    }
                }

                ++num;
            }
        } else {
            FightObject fightObject = new FightObject(chara);
            fightObject.pos = (Integer)PERSON_POS.get(num);
            fightObject.fid = chara.id;
            fightObject.leader = 1;
            fightObject.id = chara.id;
            ft.add(fightObject);
            addFabao(fc, chara, fightObject);
            List<Petbeibao> pets = chara.pets;

            for(int j = 0; j < pets.size(); ++j) {
                if (((Petbeibao)pets.get(j)).id == chara.chongwuchanzhanId) {
                    fightObject = new FightObject((Petbeibao)pets.get(j));
                    fightObject.pos = (Integer)PERSON_POS.get(num) + 5;
                    fightObject.fid = ((Petbeibao)pets.get(j)).id;
                    fightObject.id = ((Petbeibao)pets.get(j)).id;
                    fightObject.cid = chara.id;
                    ft.add(fightObject);
                    break;
                }
            }

            ++num;
        }

        FightTeam monsterTeam = new FightTeam();
        monsterTeam.type = 2;
        num = 0;

        for(Iterator var19 = monsterList.iterator(); var19.hasNext(); ++num) {
            String monsterName = (String)var19.next();
            FightObject fightObject = new FightObject(chara, monsterName, vo_65529_0);
            fightObject.pos = (Integer)MONSTER_POS.get(num);
            fightObject.fid = fc.id++;
            if (num == 1) {
                fightObject.leader = 1;
            }

            monsterTeam.add(fightObject);
        }

        fc.teamList.add(ft);
        fc.teamList.add(monsterTeam);
        listFight.add(fc);
        if (chara.autofight_select != 0) {
            Vo_32985_0 vo_32985_0 = new Vo_32985_0();
            vo_32985_0.user_is_multi = 0;
            vo_32985_0.user_round = chara.autofight_select;
            vo_32985_0.user_action = chara.autofight_skillaction;
            vo_32985_0.user_next_action = chara.autofight_skillaction;
            vo_32985_0.user_para = chara.autofight_skillno;
            vo_32985_0.user_next_para = chara.autofight_skillno;
            vo_32985_0.pet_is_multi = 0;
            vo_32985_0.pet_round = 0;
            vo_32985_0.pet_action = 0;
            vo_32985_0.pet_next_action = 0;
            vo_32985_0.pet_para = 0;
            vo_32985_0.pet_next_para = 0;
            GameObjectChar.send(new MSG_AUTO_FIGHT_SKIL(), vo_32985_0);
        }

        GameUtil.MSG_FRIEND_UPDATE_PARTIAL(chara);
        GameUtil.MSG_UPDATE_IMPROVEMENT(chara);
        Vo_3583_0 vo_3583_0 = new Vo_3583_0();
        vo_3583_0.a = 1;
        vo_3583_0.b = 3;
        send(fc, new MSG_C_START_COMBAT(), vo_3583_0);
        Vo_61671_0 vo_61671_0 = new Vo_61671_0();
        vo_61671_0.id = chara.id;
        vo_61671_0.count = 1;
        vo_61671_0.list.add(1);
        GameObjectChar.getGameObjectChar().gameMap.send(new MSG_TITLE(), vo_61671_0);
        FightTeam friendsFightTeam = getFightTeam(fc, chara.id);
        List<FightObject> fightObjectList1 = friendsFightTeam.fightObjectList;
        Iterator var11 = fightObjectList1.iterator();

        while(var11.hasNext()) {
            FightObject fightObject = (FightObject)var11.next();
            if (fightObject.type == 2) {
                Vo_64971_0 vo_64971_0 = new Vo_64971_0();
                vo_64971_0.count = 1;
                vo_64971_0.id = fightObject.id;
                vo_64971_0.haveCalled = 1;
                GameObjectCharMng.getGameObjectChar(fightObject.cid).sendOne(new MSG_C_REFRESH_PET_LIST(), vo_64971_0);
            }
        }

        List<Vo_65017_0> list65019 = new ArrayList();
        List<FightObject> fightObjectList = getFightTeam(fc, chara.id).fightObjectList;
        Iterator var31 = fightObjectList.iterator();

        while(var31.hasNext()) {
            FightObject fightObject = (FightObject)var31.next();
            Vo_65017_0 vo_65019_0 = new Vo_65017_0();
            vo_65019_0.id = fightObject.fid;
            vo_65019_0.leader = fightObject.leader;
            vo_65019_0.weapon_icon = fightObject.weapon_icon;
            vo_65019_0.pos = fightObject.pos;
            vo_65019_0.rank = fightObject.rank;
            vo_65019_0.vip_type = 0;
            vo_65019_0.str = fightObject.str;
            vo_65019_0.type = fightObject.org_icon;
            vo_65019_0.durability = fightObject.durability;
            vo_65019_0.req_level = 0;
            vo_65019_0.upgrade_level = 0;
            vo_65019_0.upgrade_type = 0;
            vo_65019_0.dex = fightObject.max_mofa;
            vo_65019_0.max_mana = fightObject.max_mofa;
            vo_65019_0.max_life = fightObject.max_shengming;
            vo_65019_0.def = fightObject.max_shengming;
            vo_65019_0.org_icon = fightObject.org_icon;
            vo_65019_0.suit_icon = fightObject.suit_icon;
            vo_65019_0.suit_light_effect = fightObject.suit_light_effect;
            vo_65019_0.special_icon = 0;
            vo_65019_0.portrait = fightObject.org_icon;
            list65019.add(vo_65019_0);
        }

        send(fc, new MSG_C_FRIENDS(), list65019);
        List<Vo_65017_0> list65017 = new ArrayList();
        fightObjectList = getFightTeamDM(fc, chara.id).fightObjectList;
        Iterator var33 = fightObjectList.iterator();

        FightObject fightObject;
        while(var33.hasNext()) {
            fightObject = (FightObject)var33.next();
            Vo_65017_0 vo_65017_0 = new Vo_65017_0();
            vo_65017_0.id = fightObject.fid;
            vo_65017_0.leader = fightObject.leader;
            vo_65017_0.weapon_icon = fightObject.weapon_icon;
            vo_65017_0.pos = fightObject.pos;
            vo_65017_0.rank = 0;
            vo_65017_0.vip_type = 0;
            vo_65017_0.str = fightObject.str;
            vo_65017_0.type = fightObject.org_icon;
            vo_65017_0.durability = 2;
            vo_65017_0.req_level = 0;
            vo_65017_0.upgrade_level = 0;
            vo_65017_0.upgrade_type = 0;
            vo_65017_0.dex = fightObject.max_mofa;
            vo_65017_0.max_mana = fightObject.max_mofa;
            vo_65017_0.max_life = fightObject.max_shengming;
            vo_65017_0.def = fightObject.max_shengming;
            vo_65017_0.org_icon = fightObject.org_icon;
            vo_65017_0.suit_icon = fightObject.suit_icon;
            vo_65017_0.suit_light_effect = fightObject.suit_light_effect;
            vo_65017_0.portrait = fightObject.org_icon;
            vo_65017_0.special_icon = 0;
            list65017.add(vo_65017_0);
        }

        send(fc, new MSG_C_OPPONENTS(), list65017);
        fightObjectList = getAllFightObject(fc);
        var33 = fightObjectList.iterator();

        while(var33.hasNext()) {
            fightObject = (FightObject)var33.next();
            if (fightObject.godbook != 0) {
                Vo_12025_0 vo_12025_0 = new Vo_12025_0();
                vo_12025_0.id = fightObject.fid;
                vo_12025_0.effect_no = fightObject.godbook;
                send(fc, new MSG_GODBOOK_EFFECT_NORMAL(), vo_12025_0);
            }
        }

        round(fc);
    }

    public static FightObject getRandomObject(FightContainer fightContainer, List<FightObject> exclude) {
        List<FightObject> allFightObject = getAllFightObject(fightContainer);
        Iterator var3 = allFightObject.iterator();

        FightObject fightObject;
        do {
            if (!var3.hasNext()) {
                return null;
            }

            fightObject = (FightObject)var3.next();
        } while(fightObject.isDead() || exclude.contains(fightObject));

        return fightObject;
    }


    /**
     * 移除战斗单元
     * @param fightContainer
     * @param fightObject
     */
    public static void remove(FightContainer fightContainer, FightObject fightObject) {
        List<FightTeam> teamList = fightContainer.teamList;
        Iterator iterator = teamList.iterator();

        while(true) {
            while(iterator.hasNext()) {
                FightTeam fightTeam = (FightTeam)iterator.next();
                Iterator fightObjectIterator = fightTeam.fightObjectList.iterator();

                while(fightObjectIterator.hasNext()) {
                    FightObject next = (FightObject)fightObjectIterator.next();
                    if (next.fid == fightObject.fid) {
                        fightObjectIterator.remove();
                        break;
                    }
                }
            }

            iterator = fightContainer.doActionList.iterator();

            while(iterator.hasNext()) {
                FightObject next = (FightObject)iterator.next();
                if (next.fid == fightObject.fid) {
                    iterator.remove();
                    break;
                }
            }

            return;
        }
    }

    public static void reconnect(Chara chara) {
        int id = chara.id;
        GameObjectChar session = GameObjectCharMng.getGameObjectChar(id);
        FightContainer fc = getFightContainer(id);
        if (fc != null) {
            Vo_3583_0 vo_3583_0 = new Vo_3583_0();
            vo_3583_0.a = 1;
            vo_3583_0.b = 3;
            GameObjectChar.send(new MSG_C_START_COMBAT(), vo_3583_0);
            List<FightObject> fightObjectList = getFightTeam(fc, id).fightObjectList;
            List<Vo_65017_0> list65019 = new ArrayList();
            Iterator var7 = fightObjectList.iterator();

            while(var7.hasNext()) {
                FightObject fightObject = (FightObject)var7.next();
                Vo_65017_0 vo_65019_0 = new Vo_65017_0();
                vo_65019_0.id = fightObject.fid;
                vo_65019_0.leader = fightObject.leader;
                vo_65019_0.weapon_icon = fightObject.weapon_icon;
                vo_65019_0.pos = fightObject.pos;
                vo_65019_0.rank = fightObject.rank;
                vo_65019_0.vip_type = 0;
                vo_65019_0.str = fightObject.str;
                vo_65019_0.type = fightObject.org_icon;
                vo_65019_0.durability = fightObject.durability;
                vo_65019_0.req_level = 0;
                vo_65019_0.upgrade_level = 0;
                vo_65019_0.upgrade_type = 0;
                vo_65019_0.dex = fightObject.max_mofa;
                vo_65019_0.max_mana = fightObject.max_mofa;
                vo_65019_0.max_life = fightObject.max_shengming;
                vo_65019_0.def = fightObject.max_shengming;
                vo_65019_0.org_icon = fightObject.org_icon;
                vo_65019_0.suit_icon = fightObject.suit_icon;
                vo_65019_0.suit_light_effect = fightObject.suit_light_effect;
                vo_65019_0.special_icon = 0;
                list65019.add(vo_65019_0);
            }

            GameObjectChar.send(new MSG_C_FRIENDS(), list65019);
            new ArrayList();
            List<Vo_65017_0> list65017 = new ArrayList();
            fightObjectList = getFightTeamDM(fc, id).fightObjectList;
            Iterator var13 = fightObjectList.iterator();

            while(var13.hasNext()) {
                FightObject fightObject = (FightObject)var13.next();
                Vo_65017_0 vo_65017_0 = new Vo_65017_0();
                vo_65017_0.id = fightObject.fid;
                vo_65017_0.leader = fightObject.leader;
                vo_65017_0.weapon_icon = 0;
                vo_65017_0.pos = fightObject.pos;
                vo_65017_0.rank = 0;
                vo_65017_0.vip_type = 0;
                vo_65017_0.str = fightObject.str;
                vo_65017_0.type = fightObject.org_icon;
                vo_65017_0.durability = 2;
                vo_65017_0.req_level = 0;
                vo_65017_0.upgrade_level = 0;
                vo_65017_0.upgrade_type = 0;
                vo_65017_0.dex = fightObject.max_mofa;
                vo_65017_0.max_mana = fightObject.max_mofa;
                vo_65017_0.max_life = fightObject.max_shengming;
                vo_65017_0.def = fightObject.max_shengming;
                vo_65017_0.org_icon = fightObject.org_icon;
                vo_65017_0.suit_icon = fightObject.suit_icon;
                vo_65017_0.suit_light_effect = fightObject.suit_light_effect;
                vo_65017_0.special_icon = 0;
                list65017.add(vo_65017_0);
            }

            GameObjectChar.send(new MSG_C_OPPONENTS(), list65017);
            fightObjectList = getFightTeam(fc, id).fightObjectList;
            Vo_19959_0 vo_19959_0 = new Vo_19959_0();
            vo_19959_0.round = fc.round;
            vo_19959_0.aid = 0;
            vo_19959_0.action = 0;
            vo_19959_0.vid = 0;
            vo_19959_0.para = 0;
            GameObjectChar.send(new MSG_C_ACTION(), vo_19959_0);
            Iterator var16 = fightObjectList.iterator();

            while(var16.hasNext()) {
                FightObject fightObject = (FightObject)var16.next();
                if (fightObject.godbook != 0) {
                    Vo_12025_0 vo_12025_0 = new Vo_12025_0();
                    vo_12025_0.id = fightObject.fid;
                    vo_12025_0.effect_no = fightObject.godbook;
                    GameObjectChar.send(new MSG_GODBOOK_EFFECT_NORMAL(), vo_12025_0);
                }
            }

            Vo_7655_0 vo_7655_0 = new Vo_7655_0();
            vo_7655_0.id = 0;
            GameObjectChar.send(new MSG_C_END_ACTION(), vo_7655_0);
        }
    }
}
