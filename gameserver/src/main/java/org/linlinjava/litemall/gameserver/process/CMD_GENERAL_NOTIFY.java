//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import org.linlinjava.litemall.db.domain.Characters;
import org.linlinjava.litemall.db.domain.DaySignPrize;
import org.linlinjava.litemall.db.domain.PetHelpType;
import org.linlinjava.litemall.db.domain.SaleGood;
import org.linlinjava.litemall.db.domain.StoreInfo;
import org.linlinjava.litemall.db.util.JSONUtils;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing;
import org.linlinjava.litemall.gameserver.data.constant.TitleConst;
import org.linlinjava.litemall.gameserver.data.game.BasicAttributesUtils;
import org.linlinjava.litemall.gameserver.data.game.NoviceGiftBagUtils;
import org.linlinjava.litemall.gameserver.data.game.PetAttributesUtils;
import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_12023_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_12269_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_40964_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_41051_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_45074_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_45075_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_45128_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_49153_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_49169_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_49179_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_49183;
import org.linlinjava.litemall.gameserver.data.vo.Vo_49183_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_61553_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_9129_0;
import org.linlinjava.litemall.gameserver.data.write.M12016_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_REFRESH_PET_GODBOOK_SKILLS_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_REFRESH_PET_GODBOOK_SKILLS_1;
import org.linlinjava.litemall.gameserver.data.write.M12269_0;
import org.linlinjava.litemall.gameserver.data.write.M16383_0;
import org.linlinjava.litemall.gameserver.data.write.M20480_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
import org.linlinjava.litemall.gameserver.data.write.M40964_0;
import org.linlinjava.litemall.gameserver.data.write.M41051_0;
import org.linlinjava.litemall.gameserver.data.write.M45074_0;
import org.linlinjava.litemall.gameserver.data.write.M45075_0;
import org.linlinjava.litemall.gameserver.data.write.M45128_0;
import org.linlinjava.litemall.gameserver.data.write.M49153_0;
import org.linlinjava.litemall.gameserver.data.write.M49169_0;
import org.linlinjava.litemall.gameserver.data.write.M49179_0;
import org.linlinjava.litemall.gameserver.data.write.M49183_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_TASK_PROMPT;
import org.linlinjava.litemall.gameserver.data.write.M61677_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_PETS;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
import org.linlinjava.litemall.gameserver.data.write.M65527_1;
import org.linlinjava.litemall.gameserver.data.write.M8165_0;
import org.linlinjava.litemall.gameserver.data.write.M9129_0;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.Goods;
import org.linlinjava.litemall.gameserver.domain.PetShuXing;
import org.linlinjava.litemall.gameserver.domain.Petbeibao;
import org.linlinjava.litemall.gameserver.domain.ShouHu;
import org.linlinjava.litemall.gameserver.domain.ShouHuShuXing;
import org.linlinjava.litemall.gameserver.fight.FightContainer;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.fight.FightObject;
import org.linlinjava.litemall.gameserver.fight.FightRequest;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.linlinjava.litemall.gameserver.service.TitleService;
import org.springframework.stereotype.Service;

import static org.linlinjava.litemall.gameserver.process.GameUtil.addYuanBao;

/**
 * CMD_GENERAL_NOTIFY    一般通知
 */
@Service
public class CMD_GENERAL_NOTIFY implements GameHandler {
    public CMD_GENERAL_NOTIFY() {
    }

    public void process(ChannelHandlerContext ctx, ByteBuf buff) {
        int type = GameReadTool.readShort(buff);
        String para1 = GameReadTool.readString(buff);
        String para2 = GameReadTool.readString(buff);
        Chara chara = GameObjectChar.getGameObjectChar().chara;
        if (type == 20023) {
            Vo_9129_0 vo_9129_52 = new Vo_9129_0();
            vo_9129_52.notify = 10001;
            vo_9129_52.para = "chaoji_goon";
            GameObjectChar.getGameObjectChar();
            GameObjectChar.send(new M9129_0(), vo_9129_52);
            Vo_61553_0 vo_61553_0 = new Vo_61553_0();
            vo_61553_0.count = 1;
            vo_61553_0.task_type = "超级宝藏";
            vo_61553_0.task_desc = "";
            vo_61553_0.task_prompt = "";
            vo_61553_0.refresh = 1;
            vo_61553_0.task_end_time = 1567909190;
            vo_61553_0.attrib = 1;
            vo_61553_0.reward = "";
            vo_61553_0.show_name = "";
            vo_61553_0.tasktask_extra_para = "";
            vo_61553_0.tasktask_state = "1";
            GameObjectChar.getGameObjectChar();
            GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_0);
            String[] strings = GameUtilRenWu.luckFindDraw();
            GameUtil.huodechoujiang(strings, chara);
            Vo_8165_0 vo_8165_0 = new Vo_8165_0();
            vo_8165_0.msg = "喜从天降,恭喜#Y" + chara.name + "#n在高级挖宝中获得#R" + strings[1] + "#n ";
            vo_8165_0.active = 0;
            GameObjectCharMng.getGameObjectChar(GameObjectChar.getGameObjectChar().upduizhangid);
            GameObjectChar.send(new M8165_0(), vo_8165_0);
            Vo_20480_0 vo_20480_0 = new Vo_20480_0();
            vo_20480_0.msg = "喜从天降,恭喜#Y" + chara.name + "#n在高级挖宝中获得#R" + strings[1] + "#n ";
            vo_20480_0.time = (int)(System.currentTimeMillis() / 1000L);
            GameObjectChar.send(new M20480_0(), vo_20480_0);
            if (!strings[1].equals("金币")) {
                Vo_16383_0 vo_16383_5 = new Vo_16383_0();
                vo_16383_5.channel = 6;
                vo_16383_5.id = 0;
                vo_16383_5.name = "";
                vo_16383_5.msg = "喜从天降,恭喜#Y" + chara.name + "#n在高级挖宝中获得#R" + strings[1] + "#n ";
                vo_16383_5.time = (int)(System.currentTimeMillis() / 1000L);
                vo_16383_5.privilege = 0;
                vo_16383_5.server_name = "3周年14线";
                vo_16383_5.show_extra = 1;
                vo_16383_5.compress = 0;
                vo_16383_5.orgLength = 65535;
                vo_16383_5.cardCount = 0;
                vo_16383_5.voiceTime = 0;
                vo_16383_5.token = "";
                vo_16383_5.checksum = 0;
                GameObjectCharMng.sendAll(new M16383_0(), vo_16383_5);
            }
        }

        Vo_8165_0 vo_8165_0;
        if (type == 30046) {
            if (chara.chongfengsan == 0) {
                vo_8165_0 = new Vo_8165_0();
                vo_8165_0.msg = "你已开启宠风散功能。";
                vo_8165_0.active = 0;
                GameObjectChar.send(new M8165_0(), vo_8165_0);
                chara.chongfengsan = 1;
            } else {
                vo_8165_0 = new Vo_8165_0();
                vo_8165_0.msg = "你已关闭宠风散功能。";
                vo_8165_0.active = 0;
                GameObjectChar.send(new M8165_0(), vo_8165_0);
                chara.chongfengsan = 0;
            }
        }

        if (type == 30048) {
            if (chara.ziqihongmeng == 0) {
                vo_8165_0 = new Vo_8165_0();
                vo_8165_0.msg = "你已开启紫气鸿蒙功能。";
                vo_8165_0.active = 0;
                GameObjectChar.send(new M8165_0(), vo_8165_0);
                chara.ziqihongmeng = 1;
            } else {
                vo_8165_0 = new Vo_8165_0();
                vo_8165_0.msg = "你已关闭紫气鸿蒙功能。";
                vo_8165_0.active = 0;
                GameObjectChar.send(new M8165_0(), vo_8165_0);
                chara.ziqihongmeng = 0;
            }
        }

        if (type == 30002) {
            GameUtil.a45060(chara);
        }

        if (type == 52) {
            if (chara.charashuangbei == 0) {
                vo_8165_0 = new Vo_8165_0();
                vo_8165_0.msg = "成功开启双倍点数，部分活动将消耗双倍点数获得双倍奖励。";
                vo_8165_0.active = 0;
                GameObjectChar.send(new M8165_0(), vo_8165_0);
                chara.charashuangbei = 1;
            } else {
                vo_8165_0 = new Vo_8165_0();
                vo_8165_0.msg = "成功关闭双倍点数，双倍点数将不再消耗。";
                vo_8165_0.active = 0;
                GameObjectChar.send(new M8165_0(), vo_8165_0);
                chara.charashuangbei = 0;
            }
        }

        Vo_9129_0 vo_9129_0;
        if (type == 20009) {
            vo_8165_0 = new Vo_8165_0();
            vo_8165_0.msg = "成功关闭驱魔香，在练功区走动时将会遇怪。";
            vo_8165_0.active = 0;
            GameObjectChar.send(new M8165_0(), vo_8165_0);
            vo_9129_0 = new Vo_9129_0();
            vo_9129_0.notify = 20010;
            vo_9129_0.para = "0";
            GameObjectChar.send(new M9129_0(), vo_9129_0);
            chara.qumoxiang = 0;
        }

        if (type == 20008) {
            vo_8165_0 = new Vo_8165_0();
            vo_8165_0.msg = "成功开启驱魔香，在练功区走动时将无法遇怪。";
            vo_8165_0.active = 0;
            GameObjectChar.send(new M8165_0(), vo_8165_0);
            vo_9129_0 = new Vo_9129_0();
            vo_9129_0.notify = 20010;
            vo_9129_0.para = "1";
            GameObjectChar.send(new M9129_0(), vo_9129_0);
            chara.qumoxiang = 1;
        }

        ListVo_65527_0 listVo_65527_0;
        Vo_8165_0 vo81650;
        Characters characters;
        if (type == 1) {
            if (GameData.that.baseCharactersService.findOneByName(para1) != null) {
                vo81650 = new Vo_8165_0();
                vo81650.msg = "该名字已有人使用";
                vo81650.active = 0;
                GameObjectChar.send(new M8165_0(), vo81650);
                return;
            }

            characters = GameData.that.baseCharactersService.findById(chara.id);
            characters.setName(para1);
            GameUtil.removemunber(chara, "改头换面卡", 1);
            chara.name = para1;
            listVo_65527_0 = GameUtil.a65527(chara);
            GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
            vo81650 = new Vo_8165_0();
            vo81650.msg = "修改成功";
            vo81650.active = 0;
            GameObjectChar.send(new M8165_0(), vo81650);
            GameData.that.baseCharactersService.updateById(characters);
        }

        String name;
        int def;
        if (type == 40005) {
            characters = GameData.that.characterService.finOnByGiD(para1);
            name = characters.getData();
            Chara charaCha = (Chara)JSONUtils.parseObject(name, Chara.class);
            Vo_49153_0 vo_49153_0 = new Vo_49153_0();
            vo_49153_0.name = chara.name;
            vo_49153_0.level = chara.level;
            vo_49153_0.icon = chara.waiguan;
            vo_49153_0.special_icon = chara.special_icon;
            vo_49153_0.weapon_icon = chara.weapon_icon;
            vo_49153_0.suit_icon = chara.suit_icon;
            vo_49153_0.suit_effect = chara.suit_light_effect;
            vo_49153_0.power = 0;
            vo_49153_0.partyName = "";
            vo_49153_0.fashionIcon = 0;
            vo_49153_0.upgradetype = 0;
            vo_49153_0.upgradelevel = 0;

            for(def = 0; def < charaCha.backpack.size(); ++def) {
                if (((Goods)charaCha.backpack.get(def)).pos <= 10) {
                    vo_49153_0.backpack.add(charaCha.backpack.get(def));
                }
            }

            GameObjectChar.send(new M49153_0(), vo_49153_0);
        }

        if (32 == type) {
        }

        int weizhi;
        int size;
        int i;
        int pos2;
        int pos1;
        if (4 == type) {
            for(i = 0; i < chara.pets.size(); ++i) {
                if (((Petbeibao)chara.pets.get(i)).no == Integer.valueOf(para1)) {
                    Petbeibao petbeibao = (Petbeibao)chara.pets.get(i);
                    pos1 = 0;
                    pos2 = 0;
                    def = 0;
                    pos1 = 0;
                    pos2 = 0;
                    weizhi = 0;

                    PetShuXing petShuXing;
                    for(size = 0; size < petbeibao.petShuXing.size(); ++size) {
                        if (((PetShuXing)petbeibao.petShuXing.get(size)).str.equals(para2)) {
                            petShuXing = (PetShuXing)petbeibao.petShuXing.get(size);
                            pos1 = petShuXing.wiz;
                            pos2 = petShuXing.parry;
                            def = petShuXing.def;
                            pos1 = petShuXing.dex;
                            pos2 = petShuXing.mana;
                            weizhi = petShuXing.accurate;
                            petbeibao.petShuXing.remove(petbeibao.petShuXing.get(size));
                        }
                    }

                    for(size = 0; size < petbeibao.petShuXing.size(); ++size) {
                        if (((PetShuXing)petbeibao.petShuXing.get(size)).no == 0) {
                            petShuXing = (PetShuXing)petbeibao.petShuXing.get(size);
                            petShuXing.wiz -= pos1;
                            petShuXing.parry -= pos2;
                            petShuXing.def -= def;
                            petShuXing.dex -= pos1;
                            petShuXing.mana -= pos2;
                            petShuXing.accurate -= weizhi;
                        }
                    }

                    List list = new ArrayList();
                    list.add(chara.pets.get(i));
                    GameObjectChar.send(new MSG_UPDATE_PETS(), list);
                    Vo_8165_0 vo816501 = new Vo_8165_0();
                    vo816501.msg = "移除妖石成功！";
                    vo816501.active = 0;
                    GameObjectChar.send(new M8165_0(), vo816501);
                }
            }
        }

        String[] strings;
        Vo_8165_0 vo816501;
        Vo_20480_0 vo_20480_0;
        if (40013 == type) {
            i = (Integer.parseInt(para1) + 1) * 10;
            strings = NoviceGiftBagUtils.giftBags(i, chara.sex, chara.menpai);
            chara.xinshoulibao[Integer.parseInt(para1)] = 1;
            GameUtil.a49171(chara);

            for(pos1 = 0; pos1 < strings.length; ++pos1) {
                String[] split = strings[pos1].split("\\#");
                vo816501 = new Vo_8165_0();
                vo816501.msg = "你获得了#R" + split[0];
                vo816501.active = 0;
                GameObjectChar.send(new M8165_0(), vo816501);
                vo_20480_0 = new Vo_20480_0();
                vo_20480_0.msg = "你获得了#R" + split[0];
                vo_20480_0.time = (int)System.currentTimeMillis();
                GameObjectChar.send(new M20480_0(), vo_20480_0);
                GameUtil.huodechoujiang(split, chara);
            }
        }

        if (40014 == type) {
            GameUtil.a49171(chara);
        }

        int coin;
        List saleGoodList;
        if (37 == type) {//自动战斗
            chara.autofight_select = Integer.valueOf(para1);
            saleGoodList = chara.pets;

            for(coin = 0; coin < saleGoodList.size(); ++coin) {
                if (((Petbeibao)saleGoodList.get(coin)).id == chara.chongwuchanzhanId) {
                    ((Petbeibao)saleGoodList.get(coin)).autofight_select = Integer.valueOf(para1);
                    break;
                }
            }

            FightObject fightObject = FightManager.getFightObject(chara.id);
            if (fightObject == null) {
                return;
            }

            fightObject.autofight_select = chara.autofight_select;
            FightContainer fightContainer = FightManager.getFightContainer();
            FightObject fightObjectPet = FightManager.getFightObjectPet(fightContainer, fightObject);
            if (fightObjectPet != null) {
                fightObjectPet.autofight_select = Integer.valueOf(para1);
            }

            if (chara.autofight_select == 0) {
                return;
            }

            if (fightContainer.state.intValue() == 3) {
                return;
            }

            if (fightObject.fightRequest != null) {
                FightManager.addRequest(FightManager.getFightContainer(), (FightRequest)null);
            }

            FightRequest fightRequest = new FightRequest();
            fightRequest.id = chara.id;
            fightRequest.action = fightObject.autofight_skillaction;
            fightRequest.para = fightObject.autofight_skillno;
            FightManager.generateActionDM(FightManager.getFightContainer(), fightObject, fightRequest);
            FightManager.addRequest(FightManager.getFightContainer(), fightRequest);
            if (fightObjectPet != null) {
                fightRequest = new FightRequest();
                fightRequest.id = fightObjectPet.fid;
                fightRequest.action = fightObjectPet.autofight_skillaction;
                fightRequest.para = fightObjectPet.autofight_skillno;
                FightManager.generateActionDM(fightContainer, fightObjectPet, fightRequest);
                FightManager.addRequest(FightManager.getFightContainer(), fightRequest);
            }
        }

        if (10007 == type) {
            if (para1.equals("1")) {
                chara.extra_mana += 300000;
                if (chara.extra_mana > 90000000) {
                    chara.extra_mana = 90000000;
                }

                GameUtil.removemoney(chara, 120000);
            }

            if (para1.equals("2")) {
                chara.have_coin_pwd += 300000;
                if (chara.have_coin_pwd > 90000000) {
                    chara.have_coin_pwd = 90000000;
                }

                GameUtil.removemoney(chara, 360000);
            }

            if (para1.equals("3")) {
                chara.use_skill_d += 300000;
                if (chara.use_skill_d > 3000000) {
                    chara.use_skill_d = 3000000;
                }

                GameUtil.removemoney(chara, 1800000);
            }
        }

        if (50007 == type) {
            i = Integer.valueOf(para1);
            if (i == 1) {
                chara.extra_life += 100;
                listVo_65527_0 = GameUtil.a65527(chara);
                GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
            }

            if (i == 2) {
                chara.extra_life += 120;
                listVo_65527_0 = GameUtil.a65527(chara);
                GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
            }

            if (i == 3) {
                chara.extra_life += 150;
                listVo_65527_0 = GameUtil.a65527(chara);
                GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
            }

            chara.isGet = 1;
            Vo_40964_0 vo_40964_18 = new Vo_40964_0();
            vo_40964_18.type = 4;
            vo_40964_18.name = "银元宝";
            vo_40964_18.param = "100";
            vo_40964_18.rightNow = 0;
            GameObjectChar.send(new M40964_0(), vo_40964_18);
            GameUtil.addVip(chara);
        }

        if (50006 == type) {
            if (chara.vipTime != 0) {
                chara.vipTime = (int)(System.currentTimeMillis() / 1000L);
            }

            i = Integer.valueOf(para1);
            if (i == 1) {
                chara.extra_life -= 3000;
                listVo_65527_0 = GameUtil.a65527(chara);
                GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
                chara.vipTimeShengYu += 2592000;
            }

            if (i == 2) {
                chara.extra_life -= 9000;
                listVo_65527_0 = GameUtil.a65527(chara);
                GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
                chara.vipTimeShengYu += 7776000;
            }

            if (i == 3) {
                chara.extra_life -= 36000;
                listVo_65527_0 = GameUtil.a65527(chara);
                GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
                chara.vipTimeShengYu += 31536000;
            }

            if (chara.vipType <= i) {
                chara.vipType = i;
                if (chara.vipTimeShengYu >= 7776000) {
                    chara.vipType = 2;
                }

                if (chara.vipTimeShengYu >= 31536000) {
                    chara.vipType = 3;
                }
            }

            switch (chara.vipType) {
                case 1:
                    TitleService.grantTitle(GameObjectChar.getGameObjectChar(), TitleConst.TITLE_EVENT_YUEKA, "位列仙班·灵识初开");
                    break;
                case 2:
                    TitleService.grantTitle(GameObjectChar.getGameObjectChar(), TitleConst.TITLE_EVENT_YUEKA, "位列仙班·道法自然");
                    break;
                case 3:
                    TitleService.grantTitle(GameObjectChar.getGameObjectChar(), TitleConst.TITLE_EVENT_YUEKA, "位列仙班·大道无穷");
                    break;
                default:
                    break;
            }

            GameUtil.addVip(chara);
        }

        Vo_20481_0 vo_20481_0;
        if (5 == type) {
            for(i = 0; i < chara.pets.size(); ++i) {
                if (((Petbeibao)chara.pets.get(i)).no == Integer.valueOf(para1)) {
                    for(coin = 0; coin < ((Petbeibao)chara.pets.get(i)).tianshu.size(); ++coin) {
                        if (((Vo_12023_0)((Petbeibao)chara.pets.get(i)).tianshu.get(coin)).god_book_skill_name.equals(para2)) {
                            ((Petbeibao)chara.pets.get(i)).tianshu.remove(((Petbeibao)chara.pets.get(i)).tianshu.get(coin));
                            List list = new ArrayList();
                            list.add(chara.pets.get(i));
                            GameObjectChar.send(new MSG_UPDATE_PETS(), list);
                            boolean isfagong = ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).rank > ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).pet_mag_shape;
                            GameUtil.dujineng(1, ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).metal, ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).skill, isfagong, ((Petbeibao)chara.pets.get(i)).id, chara);
                            if (((Petbeibao)chara.pets.get(i)).tianshu.size() == 0) {
                                Vo_12023_0 vo_12023_0 = new Vo_12023_0();
                                vo_12023_0.owner_id = chara.id;
                                vo_12023_0.id = ((Petbeibao)chara.pets.get(i)).id;
                                GameObjectChar.send(new MSG_REFRESH_PET_GODBOOK_SKILLS_1(), vo_12023_0);
                            } else {
                                GameObjectChar.send(new MSG_REFRESH_PET_GODBOOK_SKILLS_0(), ((Petbeibao)chara.pets.get(i)).tianshu);
                            }

                            StoreInfo info = GameData.that.baseStoreInfoService.findOneByName(para2);
                            GameUtil.huodedaoju(chara, info, 1);
                            vo_20481_0 = new Vo_20481_0();
                            vo_20481_0.msg = "你的宠物#Y" + ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).str + "#n成功取出了天书散卷#R" + para2 + "#n。";
                            vo_20481_0.time = (int)(System.currentTimeMillis() / 1000L);
                            GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                            break;
                        }
                    }
                }
            }
        }

        ArrayList list;
        if (30010 == type) {
            for(i = 0; i < chara.listshouhu.size(); ++i) {
                if (((ShouHu)chara.listshouhu.get(i)).id == Integer.parseInt(para2)) {
                    --chara.canzhanshouhunumber;
                    ((ShouHuShuXing)((ShouHu)chara.listshouhu.get(i)).listShouHuShuXing.get(0)).salary = 0;
                    if (((ShouHuShuXing)((ShouHu)chara.listshouhu.get(i)).listShouHuShuXing.get(0)).nil == 0) {
                        ((ShouHuShuXing)((ShouHu)chara.listshouhu.get(i)).listShouHuShuXing.get(0)).nil = 1;
                    } else {
                        ((ShouHuShuXing)((ShouHu)chara.listshouhu.get(i)).listShouHuShuXing.get(0)).nil = 0;
                    }

                    list = new ArrayList();
                    list.add(chara.listshouhu.get(i));
                    GameObjectChar.send(new M12016_0(), list);
                }

                if (((ShouHu)chara.listshouhu.get(i)).id == Integer.parseInt(para1)) {
                    if (chara.canzhanshouhunumber == 0) {
                        ((ShouHuShuXing)((ShouHu)chara.listshouhu.get(i)).listShouHuShuXing.get(0)).salary = 5;
                        ++chara.canzhanshouhunumber;
                    } else {
                        ((ShouHuShuXing)((ShouHu)chara.listshouhu.get(i)).listShouHuShuXing.get(0)).salary = chara.canzhanshouhunumber++;
                    }

                    if (((ShouHuShuXing)((ShouHu)chara.listshouhu.get(i)).listShouHuShuXing.get(0)).nil == 0) {
                        ((ShouHuShuXing)((ShouHu)chara.listshouhu.get(i)).listShouHuShuXing.get(0)).nil = 1;
                    } else {
                        ((ShouHuShuXing)((ShouHu)chara.listshouhu.get(i)).listShouHuShuXing.get(0)).nil = 0;
                    }

                    list = new ArrayList();
                    list.add(chara.listshouhu.get(i));
                    GameObjectChar.send(new M12016_0(), list);
                }
            }

            GameObjectChar.send(new M12016_0(), chara.listshouhu);
            List<Vo_45074_0> arrayList = new ArrayList();

            for(coin = 0; coin < chara.listshouhu.size(); ++coin) {
                if (((ShouHuShuXing)((ShouHu)chara.listshouhu.get(coin)).listShouHuShuXing.get(0)).nil != 0) {
                    Vo_45074_0 vo_45074_0 = new Vo_45074_0();
                    vo_45074_0.guardName = ((ShouHuShuXing)((ShouHu)chara.listshouhu.get(coin)).listShouHuShuXing.get(0)).str;
                    vo_45074_0.guardLevel = chara.level;
                    vo_45074_0.guardIcon = ((ShouHuShuXing)((ShouHu)chara.listshouhu.get(coin)).listShouHuShuXing.get(0)).type;
                    vo_45074_0.guardOrder = ((ShouHuShuXing)((ShouHu)chara.listshouhu.get(coin)).listShouHuShuXing.get(0)).salary;
                    vo_45074_0.guardId = ((ShouHu)chara.listshouhu.get(coin)).id;
                    arrayList.add(vo_45074_0);
                }
            }

            GameObjectChar.sendduiwu(new M45074_0(), arrayList, chara.id);
            if (GameObjectChar.getGameObjectChar().gameTeam != null && GameObjectChar.getGameObjectChar().gameTeam.duiwu != null) {
                for(coin = 0; coin < GameObjectChar.getGameObjectChar().gameTeam.duiwu.size(); ++coin) {
                    GameObjectCharMng.getGameObjectChar(((Chara)GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(coin)).id).sendOne(new M45074_0(), arrayList);
                }
            }
        }

        if (8 == type) {
            for(i = 0; i < chara.listshouhu.size(); ++i) {
                if (((ShouHu)chara.listshouhu.get(i)).id == Integer.parseInt(para1)) {
                    ((ShouHuShuXing)((ShouHu)chara.listshouhu.get(i)).listShouHuShuXing.get(0)).max_degree = Integer.parseInt(para2);
                    list = new ArrayList();
                    list.add(chara.listshouhu.get(i));
                    GameObjectChar.send(new M12016_0(), list);
                }
            }
        }

        ListVo_65527_0 listVo6552701;
        if (30006 == type) {
            for(i = 0; i < chara.backpack.size(); ++i) {
                Goods goods = (Goods)chara.backpack.get(i);
                if (goods.pos == Integer.parseInt(para1)) {
                    GameUtil.removemunber(chara, goods, Integer.valueOf(para2));
                    chara.use_money_type += goods.goodsInfo.rebuild_level / 5 * Integer.valueOf(para2);
                    listVo6552701 = GameUtil.a65527(chara);
                    GameObjectChar.send(new MSG_UPDATE(), listVo6552701);
                    Vo_20481_0 vo204810 = new Vo_20481_0();
                    vo204810.msg = "你成功出售" + goods.goodsInfo.str + "#n获得代金券#n。";
                    vo204810.time = 1562987118;
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo204810);
                    break;
                }
            }
        }

        if (10002 == type) {
            Vo_61677_0 vo_61677_0 = new Vo_61677_0();
            vo_61677_0.list = chara.cangku;
            GameObjectChar.send(new M61677_0(), vo_61677_0);
        }

        Vo_49179_0 vo_49179_0;
        Vo_40964_0 vo_40964_9;
        List list1;
        if (40022 == type) {
            chara.balance += chara.jishou_coin;
            chara.jishou_coin = 0;
            ListVo_65527_0 vo655270 = GameUtil.a65527(chara);
            GameObjectChar.send(new MSG_UPDATE(), vo655270);
            list1 = GameData.that.baseSaleGoodService.findByOwnerUuid(chara.uuid);
            vo_49179_0 = GameUtil.a49179(list1, chara);
            GameObjectChar.send(new M49179_0(), vo_49179_0);
            vo_40964_9 = new Vo_40964_0();
            vo_40964_9.type = 4;
            vo_40964_9.name = "金币";
            vo_40964_9.param = "100";
            vo_40964_9.rightNow = 1;
            GameObjectChar.send(new M40964_0(), vo_40964_9);
            vo816501 = new Vo_8165_0();
            vo816501.msg = "你提款了钱";
            vo816501.active = 0;
            GameObjectChar.send(new M8165_0(), vo816501);
            vo_20480_0 = new Vo_20480_0();
            vo_20480_0.msg = "你提款了钱";
            vo_20480_0.time = (int)(System.currentTimeMillis() / 1000L);
            GameObjectChar.send(new M20480_0(), vo_20480_0);
        }

        if (40016 == type) {
            SaleGood saleGood = GameData.that.saleGoodService.findOneByGoodsId(para1);
            Vo_40964_0 vo_40964_0;
            if (saleGood.getIspet() == 1) {
                name = saleGood.getGoods();
                Goods goods1 = (Goods)JSONUtils.parseObject(name, Goods.class);
                new LinkedList();
                goods1.pos = GameUtil.beibaoweizhi(chara);
                goods1.goodsInfo.owner_id = 1;
                GameUtil.addwupin(goods1, chara);
                GameData.that.baseSaleGoodService.deleteById(saleGood.getId());
                vo_40964_0 = new Vo_40964_0();
                vo_40964_0.type = 1;
                vo_40964_0.name = saleGood.getName();
                vo_40964_0.param = "32271173";
                vo_40964_0.rightNow = 0;
                vo_20481_0 = new Vo_20481_0();
                vo_20481_0.msg = "你成功将#R" + saleGood.getName() + "#n撤摊了";
                vo_20481_0.time = (int)(System.currentTimeMillis() / 1000L);
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
            } else {
                name = saleGood.getGoods();
                Petbeibao petbeibao = (Petbeibao)JSONUtils.parseObject(name, Petbeibao.class);
                Vo_12269_0 vo_12269_0 = new Vo_12269_0();
                vo_12269_0.id = petbeibao.id;
                vo_12269_0.owner_id = chara.id;
                GameObjectChar.send(new M12269_0(), vo_12269_0);
                vo_40964_0 = new Vo_40964_0();
                vo_40964_0.type = 2;
                vo_40964_0.name = "立正";
                vo_40964_0.param = String.valueOf(((PetShuXing)petbeibao.petShuXing.get(0)).type);
                vo_40964_0.rightNow = 0;
                GameObjectChar.send(new M40964_0(), vo_40964_0);
                vo_20481_0 = new Vo_20481_0();
                vo_20481_0.msg = "你成功将#R" + saleGood.getName() + "#n撤摊了";
                vo_20481_0.time = (int)(System.currentTimeMillis() / 1000L);
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                List arrayList = new ArrayList();
                arrayList.add(petbeibao);
                GameObjectChar.send(new MSG_UPDATE_PETS(), arrayList);
                boolean isfagong = ((PetShuXing)petbeibao.petShuXing.get(0)).rank > ((PetShuXing)petbeibao.petShuXing.get(0)).pet_mag_shape;
                GameUtil.dujineng(1, ((PetShuXing)petbeibao.petShuXing.get(0)).metal, ((PetShuXing)petbeibao.petShuXing.get(0)).skill, isfagong, petbeibao.id, chara);
                chara.pets.add(petbeibao);
                GameData.that.baseSaleGoodService.deleteById(saleGood.getId());
            }

            list1 = GameData.that.baseSaleGoodService.findByOwnerUuid(chara.uuid);
            vo_49179_0 = GameUtil.a49179(list1, chara);
            GameObjectChar.send(new M49179_0(), vo_49179_0);
        }

        if (40018 == type) {
            String[] split = para2.split("\\;");
            coin = Integer.parseInt(split[0]);
            pos1 = Integer.parseInt(split[1]);
            pos2 = Integer.parseInt(split[2]);
            String pos4 = split[2];
            List<SaleGood> byStr = GameData.that.saleGoodService.findByStr(para1);
            Collections.sort(byStr);
            Vo_49183_0 vo_49183_0 = new Vo_49183_0();
            vo_49183_0.totalPage = byStr.size() / 8 + 1;
            if (coin > vo_49183_0.totalPage) {
                return;
            }

            vo_49183_0.cur_page = coin;
            weizhi = (coin - 1) * 8;
            size = byStr.size() - (coin - 1) * 8;
            if (size > 8) {
                size = 8;
            }

            for( i = 0; i < size; ++i) {
                Vo_49183 vo_49183 = new Vo_49183();
                vo_49183.name = ((SaleGood)byStr.get(i + weizhi)).getName();
                if (((SaleGood)byStr.get(i + weizhi)).getName().contains("超级黑水晶·")) {
                    SaleGood saleGood = (SaleGood)byStr.get(i + weizhi);
                    String goods = saleGood.getGoods();
                    Goods goods1 = (Goods)JSONUtils.parseObject(goods, Goods.class);
                    Map<Object, Object> goodsFenSe1 = UtilObjMapshuxing.GoodsLanSe(goods1.goodsLanSe);
                    int value = 0;
                    Iterator var23 = goodsFenSe1.entrySet().iterator();

                    while(var23.hasNext()) {
                        Entry<Object, Object> entry = (Entry)var23.next();
                        if (!entry.getKey().equals("groupNo") && !entry.getKey().equals("groupType") && (Integer)entry.getValue() != 0) {
                            value = (Integer)entry.getValue();
                            break;
                        }
                    }

                    vo_49183.name = ((SaleGood)byStr.get(i + weizhi)).getName() + "|" + value + "|1";
                }

                vo_49183.is_my_goods = 0;
                vo_49183.id = ((SaleGood)byStr.get(i + weizhi)).getGoodsId();
                vo_49183.price = ((SaleGood)byStr.get(i + weizhi)).getPrice();
                vo_49183.status = 2;
                vo_49183.startTime = ((SaleGood)byStr.get(i + weizhi)).getStartTime();
                vo_49183.endTime = ((SaleGood)byStr.get(i + weizhi)).getEndTime();
                vo_49183.level = ((SaleGood)byStr.get(i + weizhi)).getReqLevel();
                vo_49183.unidentified = ((SaleGood)byStr.get(i + weizhi)).getLevel() > 0 ? 1 : 0;
                if (((SaleGood)byStr.get(i + weizhi)).getIspet() == 2) {
                    vo_49183.unidentified = 0;
                }

                vo_49183.amount = 1;
                vo_49183.req_level = ((SaleGood)byStr.get(i + weizhi)).getReqLevel();
                vo_49183.extra = "\"{\"rank\":2,\"enchant\":0,\"mount_type\":0,\"rebuild_level\":1,\"eclosion\":0}\"";
                vo_49183.item_polar = 0;
                vo_49183_0.vo_49183s.add(vo_49183);
            }

            vo_49183_0.path_str = para1;
            vo_49183_0.select_gid = "";
            vo_49183_0.sell_stage = 2;
            vo_49183_0.sort_key = "price";
            vo_49183_0.is_descending = 0;
            GameObjectChar.send(new M49183_0(), vo_49183_0);
        }

        if (40012 == type) {
        }

        if (40015 == type) {
            list1 = GameData.that.saleGoodService.findByOwnerUuid(chara.uuid);
            Vo_49179_0 vo491790 = GameUtil.a49179(list1, chara);
            GameObjectChar.send(new M49179_0(), vo491790);
        }

        if (40010 == type) {
            DaySignPrize daySignPrize = GameData.that.baseDaySignPrizeService.findOneByIndex(chara.signDays + 1);
            name = daySignPrize.getName();
            if (name.equals("银元宝")) {
                Vo_40964_0 vo_40964_0 = new Vo_40964_0();
                vo_40964_0.type = 4;
                vo_40964_0.name = "银元宝";
                vo_40964_0.param = "100";
                vo_40964_0.rightNow = 0;
                GameObjectChar.send(new M40964_0(), vo_40964_0);
                chara.gold_coin += 100;
                ListVo_65527_0 listVo655270 = GameUtil.a65527(chara);
                GameObjectChar.send(new MSG_UPDATE(), listVo655270);
            } else {
                StoreInfo storeInfo = GameData.that.baseStoreInfoService.findOneByName(name);
                GameUtil.huodedaoju(chara, storeInfo, 1);
                vo_40964_9 = new Vo_40964_0();
                vo_40964_9.type = 1;
                vo_40964_9.name = name;
                vo_40964_9.param = "-1";
                vo_40964_9.rightNow = 0;
                GameObjectChar.send(new M40964_0(), vo_40964_9);
            }

            vo816501 = new Vo_8165_0();
            vo816501.msg = "你获得了" + name;
            vo816501.active = 0;
            GameObjectChar.send(new M8165_0(), vo816501);
            Vo_20480_0 vo204800 = new Vo_20480_0();
            vo204800.msg = "你领取了签到奖励。";
            vo204800.time = 1562593376;
            GameObjectChar.send(new M20480_0(), vo204800);
            chara.isCanSgin = 2;
            ++chara.signDays;
            Vo_41051_0 vo_41051_0 = new Vo_41051_0();
            vo_41051_0.count = 1;
            vo_41051_0.name0 = "month_charge_gift";
            vo_41051_0.amount0 = 0;
            vo_41051_0.startTime0 = 1577825999;
            vo_41051_0.endTime0 = 1577825999;
            GameObjectChar.send(new M41051_0(), vo_41051_0);
            Vo_49169_0 vo_49169_0 = new Vo_49169_0();
            vo_49169_0.monthDays = 31;
            vo_49169_0.signDays = chara.signDays;
            vo_49169_0.isCanSgin = chara.isCanSgin;
            vo_49169_0.isCanReplenishSign = 0;
            vo_49169_0.name0 = "超级归元露";
            vo_49169_0.number0 = 1;
            vo_49169_0.name1 = "银元宝";
            vo_49169_0.number1 = 100;
            vo_49169_0.name2 = "超级神兽丹";
            vo_49169_0.number2 = 1;
            vo_49169_0.name3 = "超级晶石";
            vo_49169_0.number3 = 1;
            vo_49169_0.name4 = "宠物强化丹";
            vo_49169_0.number4 = 1;
            vo_49169_0.name5 = "宠风散";
            vo_49169_0.number5 = 1;
            vo_49169_0.name6 = "银元宝";
            vo_49169_0.number6 = 100;
            vo_49169_0.name7 = "超级神兽丹";
            vo_49169_0.number7 = 1;
            vo_49169_0.name8 = "超级晶石";
            vo_49169_0.number8 = 1;
            vo_49169_0.name9 = "点化丹";
            vo_49169_0.number9 = 1;
            vo_49169_0.name10 = "超级归元露";
            vo_49169_0.number10 = 1;
            vo_49169_0.name11 = "银元宝";
            vo_49169_0.number11 = 100;
            vo_49169_0.name12 = "超级神兽丹";
            vo_49169_0.number12 = 1;
            vo_49169_0.name13 = "超级晶石";
            vo_49169_0.number13 = 1;
            vo_49169_0.name14 = "装备共鸣石";
            vo_49169_0.number14 = 1;
            vo_49169_0.name15 = "宠风散";
            vo_49169_0.number15 = 1;
            vo_49169_0.name16 = "银元宝";
            vo_49169_0.number16 = 100;
            vo_49169_0.name17 = "超级神兽丹";
            vo_49169_0.number17 = 1;
            vo_49169_0.name18 = "超级晶石";
            vo_49169_0.number18 = 1;
            vo_49169_0.name19 = "羽化丹";
            vo_49169_0.number19 = 1;
            vo_49169_0.name20 = "超级归元露";
            vo_49169_0.number20 = 1;
            vo_49169_0.name21 = "银元宝";
            vo_49169_0.number21 = 100;
            vo_49169_0.name22 = "超级神兽丹";
            vo_49169_0.number22 = 1;
            vo_49169_0.name23 = "超级晶石";
            vo_49169_0.number23 = 1;
            vo_49169_0.name24 = "神木鼎";
            vo_49169_0.number24 = 1;
            vo_49169_0.name25 = "宠风散";
            vo_49169_0.number25 = 1;
            vo_49169_0.name26 = "银元宝";
            vo_49169_0.number26 = 100;
            vo_49169_0.name27 = "超级神兽丹";
            vo_49169_0.number27 = 1;
            vo_49169_0.name28 = "超级晶石";
            vo_49169_0.number28 = 1;
            vo_49169_0.name29 = "精怪诱饵";
            vo_49169_0.number29 = 1;
            vo_49169_0.name30 = "超级归元露";
            vo_49169_0.number30 = 1;
            GameObjectChar.send(new M49169_0(), vo_49169_0);
        }

        if (40009 == type) {
            Vo_49169_0 vo_49169_0 = new Vo_49169_0();
            vo_49169_0.monthDays = 31;
            vo_49169_0.signDays = chara.signDays;
            vo_49169_0.isCanSgin = chara.isCanSgin;
            vo_49169_0.isCanReplenishSign = 0;
            vo_49169_0.name0 = "超级归元露";
            vo_49169_0.number0 = 1;
            vo_49169_0.name1 = "银元宝";
            vo_49169_0.number1 = 100;
            vo_49169_0.name2 = "超级神兽丹";
            vo_49169_0.number2 = 1;
            vo_49169_0.name3 = "超级晶石";
            vo_49169_0.number3 = 1;
            vo_49169_0.name4 = "宠物强化丹";
            vo_49169_0.number4 = 1;
            vo_49169_0.name5 = "宠风散";
            vo_49169_0.number5 = 1;
            vo_49169_0.name6 = "银元宝";
            vo_49169_0.number6 = 100;
            vo_49169_0.name7 = "超级神兽丹";
            vo_49169_0.number7 = 1;
            vo_49169_0.name8 = "超级晶石";
            vo_49169_0.number8 = 1;
            vo_49169_0.name9 = "点化丹";
            vo_49169_0.number9 = 1;
            vo_49169_0.name10 = "超级归元露";
            vo_49169_0.number10 = 1;
            vo_49169_0.name11 = "银元宝";
            vo_49169_0.number11 = 100;
            vo_49169_0.name12 = "超级神兽丹";
            vo_49169_0.number12 = 1;
            vo_49169_0.name13 = "超级晶石";
            vo_49169_0.number13 = 1;
            vo_49169_0.name14 = "装备共鸣石";
            vo_49169_0.number14 = 1;
            vo_49169_0.name15 = "宠风散";
            vo_49169_0.number15 = 1;
            vo_49169_0.name16 = "银元宝";
            vo_49169_0.number16 = 100;
            vo_49169_0.name17 = "超级神兽丹";
            vo_49169_0.number17 = 1;
            vo_49169_0.name18 = "超级晶石";
            vo_49169_0.number18 = 1;
            vo_49169_0.name19 = "羽化丹";
            vo_49169_0.number19 = 1;
            vo_49169_0.name20 = "超级归元露";
            vo_49169_0.number20 = 1;
            vo_49169_0.name21 = "银元宝";
            vo_49169_0.number21 = 100;
            vo_49169_0.name22 = "超级神兽丹";
            vo_49169_0.number22 = 1;
            vo_49169_0.name23 = "超级晶石";
            vo_49169_0.number23 = 1;
            vo_49169_0.name24 = "神木鼎";
            vo_49169_0.number24 = 1;
            vo_49169_0.name25 = "宠风散";
            vo_49169_0.number25 = 1;
            vo_49169_0.name26 = "银元宝";
            vo_49169_0.number26 = 100;
            vo_49169_0.name27 = "超级神兽丹";
            vo_49169_0.number27 = 1;
            vo_49169_0.name28 = "超级晶石";
            vo_49169_0.number28 = 1;
            vo_49169_0.name29 = "精怪诱饵";
            vo_49169_0.number29 = 1;
            vo_49169_0.name30 = "超级归元露";
            vo_49169_0.number30 = 1;
            GameObjectChar.send(new M49169_0(), vo_49169_0);
        }

        int[] ints;
        PetHelpType petHelpType;
        if (6 == type) {
            petHelpType = GameData.that.basePetHelpTypeService.findOneByName(para1);
            coin = petHelpType.getMoney();
            Vo_20481_0 vo204810;
            if (petHelpType.getQuality() == 3) {
                if (chara.extra_life < coin) {
                    vo204810 = new Vo_20481_0();
                    vo204810.msg = "代金卷不足";
                    vo204810.time = (int)(System.currentTimeMillis() / 1000L);
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo204810);
                    return;
                }

                chara.extra_life -= coin;
            } else {
                if (chara.balance < coin) {
                    vo204810 = new Vo_20481_0();
                    vo204810.msg = "金币不足";
                    vo204810.time = (int)(System.currentTimeMillis() / 1000L);
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo204810);
                    return;
                }

                chara.balance -= coin;
            }

            listVo6552701 = GameUtil.a65527(chara);
            GameObjectChar.send(new MSG_UPDATE(), listVo6552701);
            ShouHu shouHu = new ShouHu();
            shouHu.id = GameUtil.getCard(chara);
            ShouHuShuXing shouHuShuXing = new ShouHuShuXing();
            pos1 = petHelpType.getPolar();
            pos2 = petHelpType.getQuality();
            Hashtable<String, int[]> stringHashtable = PetAttributesUtils.helpPet(pos2, pos1, chara.level);
            ints = (int[])stringHashtable.get("attribute");
            int[] polars = (int[])stringHashtable.get("polars");
            new Vo_45128_0();
            shouHuShuXing.life = ints[0];
            shouHuShuXing.mag_power = ints[1];
            shouHuShuXing.phy_power = ints[2];
            shouHuShuXing.speed = ints[3];
            shouHuShuXing.wood = polars[0];
            shouHuShuXing.water = polars[1];
            shouHuShuXing.fire = polars[2];
            shouHuShuXing.earth = polars[3];
            shouHuShuXing.resist_metal = polars[4];
            shouHuShuXing.skill = chara.level;
            shouHuShuXing.str = para1;
            shouHuShuXing.shape = 0;
            shouHuShuXing.penetrate = pos2;
            shouHuShuXing.metal = pos1;
            shouHuShuXing.color = pos2;
            shouHuShuXing.suit_polar = para1;
            shouHuShuXing.type = petHelpType.getType();
            ints = BasicAttributesUtils.calculationHelpAttributes(chara.level, ints[0], ints[1], ints[2], ints[3], polars[0], polars[1], polars[2], polars[3], polars[4], pos1);
            shouHuShuXing.max_life = ints[0];
            shouHuShuXing.def = ints[0];
            shouHuShuXing.accurate = ints[2];
            shouHuShuXing.mana = ints[3];
            shouHuShuXing.parry = ints[4];
            shouHuShuXing.wiz = ints[5];
            shouHuShuXing.salary = 0;
            shouHu.listShouHuShuXing.add(shouHuShuXing);
            chara.listshouhu.add(shouHu);
            List arrayList = new ArrayList();
            arrayList.add(shouHu);
            GameObjectChar.send(new M12016_0(), arrayList);
            Vo_20481_0 vo2048101 = new Vo_20481_0();
            vo2048101.msg = "#n召唤守护#Y" + para1 + "#n";
            vo2048101.time = 1562987118;
            GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo2048101);
            GameUtil.dujineng(2, pos1, shouHuShuXing.skill, true, shouHu.id, chara);
        }

        if (10008 == type) {
        }

        if (30013 == type) {
            Vo_45075_0 vo_45075_0 = new Vo_45075_0();
            vo_45075_0.teams = 0;
            vo_45075_0.members = 0;
            GameObjectChar.send(new M45075_0(), vo_45075_0);
        }

        if (26 == type) {
        }

        if (30038 == type) {
            petHelpType = GameData.that.basePetHelpTypeService.findOneByName(para1);
            strings = para2.split(";");
            pos1 = Integer.parseInt(strings[0]);
            pos2 = Integer.parseInt(strings[1]);
            Hashtable<String, int[]> stringHashtable = PetAttributesUtils.helpPet(pos2, pos1, chara.level);
            int[] attributes = (int[])stringHashtable.get("attribute");
            int[] polars = (int[])stringHashtable.get("polars");
            Vo_45128_0 vo_45128_0 = new Vo_45128_0();
            vo_45128_0.life = attributes[0];
            vo_45128_0.mag_power = attributes[1];
            vo_45128_0.phy_power = attributes[2];
            vo_45128_0.speed = attributes[3];
            vo_45128_0.wood = polars[0];
            vo_45128_0.water = polars[1];
            vo_45128_0.fire = polars[2];
            vo_45128_0.earth = polars[3];
            vo_45128_0.resist_metal = polars[4];
            vo_45128_0.skill = chara.level;
            vo_45128_0.str = para1;
            vo_45128_0.shape = 0;
            vo_45128_0.penetrate = pos2;
            vo_45128_0.metal = pos1;
            vo_45128_0.color = pos2;
            vo_45128_0.suit_polar = para1;
            vo_45128_0.type = petHelpType.getType();
            ints = BasicAttributesUtils.calculationHelpAttributes(chara.level, attributes[0], attributes[1], attributes[2], attributes[3], polars[0], polars[1], polars[2], polars[3], polars[4], pos1);
            vo_45128_0.max_life = ints[0];
            vo_45128_0.def = ints[0];
            vo_45128_0.accurate = ints[2];
            vo_45128_0.mana = ints[3];
            vo_45128_0.parry = ints[4];
            vo_45128_0.wiz = ints[5];
            GameObjectChar.send(new M45128_0(), vo_45128_0);
        }

        if (30023 == type) {
            if (Integer.parseInt(para1) == 0) {
                chara.lock_exp = 0;
            } else {
                chara.lock_exp = 1;
            }

            List linkedList = new LinkedList();
            linkedList.add(chara.id);
            linkedList.add(Integer.parseInt(para1));
            GameObjectChar.send(new M65527_1(), linkedList);
        }

        if (type == 40008) {
            GameUtil.a49159(chara);
        }

        if(type==30025){
            System.out.println("NOTIFY_TTT_JUMP_ASSURE=  30025, \n" +
                    "  -- 通天塔飞升确认");
        }
        if(type==30026){
            System.out.println("NOTIFY_TTT_JUMP_CANCEL=  30026,  \n" +
                    " -- 通天塔飞升取消");
        }
        if(type==40000){
            System.out.println("NOTIFY_TTT_GET_BONUS=  40000, \n" +
                    "  -- 通天塔领取奖励");
        }
        if(type==40001){
            System.out.println(" NOTIFY_TTT_DO_REVIVE=  40001, \n" +
                    "  -- 通天塔请求复活");
        }
        if(type==40002){//通天塔急速飞升  元宝
            int flyLayer = Integer.valueOf(para1);
            //扣元宝
            int cost = 0;
            if (flyLayer <= 5){
                cost = 90;
            }else{
                cost = 180;
            }
            addYuanBao(chara, -cost);
            chara.onEnterTttLayer(chara.ttt_layer+flyLayer ,GameUtil.randomTTTXingJunName());
            GameUtil.a45090(chara, (byte) 1, cost, flyLayer);
            GameUtil.notifyTTTPanelInfo(chara);
            GameUtilRenWu.notifyTTTTask(chara);
        }
        if(type==40003){//通天塔快速飞升 金钱
            int flyLayer = Integer.valueOf(para1);
            //扣金钱
            int cost = 0;
            if (flyLayer <= 5){
                cost = (flyLayer - 1) * 800000;
            }else{
                cost = (5 - 1) * 800000;
            }
            GameUtil.addCoin(chara, -cost);

            chara.onEnterTttLayer(chara.ttt_layer+flyLayer ,GameUtil.randomTTTXingJunName());

            GameUtil.a45090(chara, (byte) 2, cost, flyLayer);

            GameUtil.notifyTTTPanelInfo(chara);
        }
        if(type==40004){
            System.out.println("NOTIFY_TTT_RESET_TASK =  40004,\n" +
                    "   -- 通天塔重置任务");
        }
        if(type==40006){//通天塔-挑战下层
            GameUtil.tttChallengeNextLayer(chara);
        }
        if(type == 40007 || type == 50022){//通天塔离开
            GameUtilRenWu.huicheng(chara);
        }

    }

    public int cmd() {
        return 63752;
    }
}
