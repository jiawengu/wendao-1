package org.linlinjava.litemall.gameserver.process;


import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.db.domain.Characters;
import org.linlinjava.litemall.gameserver.data.vo.*;
import org.linlinjava.litemall.gameserver.data.write.*;
import org.linlinjava.litemall.gameserver.data.xls_config.PartyDailyTaskItem;
import org.linlinjava.litemall.gameserver.domain.*;
import org.linlinjava.litemall.gameserver.game.GameCore;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.linlinjava.litemall.gameserver.service.DayBreakService;
import org.linlinjava.litemall.gameserver.user_logic.UserLogic;
import org.linlinjava.litemall.gameserver.user_logic.UserPartyDailyTaskLogic;

import java.util.LinkedList;
import java.util.List;


/**
 * CMD_LOAD_EXISTED_CHAR
 */
@org.springframework.stereotype.Service
public class CMD_LOAD_EXISTED_CHAR implements org.linlinjava.litemall.gameserver.GameHandler {
    public void process(ChannelHandlerContext ctx, io.netty.buffer.ByteBuf buff) {
        String char_name = org.linlinjava.litemall.gameserver.data.GameReadTool.readString(buff);
        GameObjectChar session = GameObjectChar.getGameObjectChar();

        if (session.chara == null) {
            Characters characters = GameData.that.characterService.findOneByAccountIdAndName(session.getAccountid(), char_name);
            if (characters == null) {
                ctx.disconnect();
                return;
            }

            if(GameObjectCharMng.isCharaCached(characters.getId().intValue())){
                GameObjectCharMng.relogin(session, characters.getId());
            }else{
                session.init(characters);
            }
        }

        Chara chara = session.chara;


        DayBreakService.checkDayBreak(chara);

        chara.uptime = System.currentTimeMillis();
        java.util.Date date = new java.util.Date(chara.updatetime);
        boolean isnow = GameUtil.isToday(date);//是否是今天
        if (!isnow) {
            chara.isGet = 0;
            chara.isCanSgin = 1;
            chara.online_time = 0L;
            chara.npcshuadao = new LinkedList();

            chara.shuadao = 1;

            chara.chubao = 1;

            chara.npcchubao = new LinkedList();

            chara.baibangmang = 0;

            chara.shimencishu = 1;

            chara.npcName = "";

            chara.fabaorenwu = 0;

            chara.xiuxingcishu = 1;

            chara.xiuxingNpcname = "";

            chara.xuanshangcishu = 0;

            chara.npcxuanshang = new LinkedList();

            chara.npcXuanShangName = "";

            for (int i = 0; i < chara.shenmiliwu.size(); i++) {
                ((Vo_41480_0) chara.shenmiliwu.get(i)).online_time = 0;
                ((Vo_41480_0) chara.shenmiliwu.get(i)).name = "";
                ((Vo_41480_0) chara.shenmiliwu.get(i)).brate = 0;
            }
        }


        org.linlinjava.litemall.gameserver.data.vo.Vo_45277_0 vo_45277_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45277_0();
        vo_45277_0.server_type = 0;
        GameObjectChar.send(new MSG_CS_SERVER_TYPE(), vo_45277_0);

        org.linlinjava.litemall.gameserver.data.vo.Vo_41009_0 vo_41009_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_41009_0();
        vo_41009_0.server_time = ((int) (System.currentTimeMillis() / 1000L));
        vo_41009_0.time_zone = 8;
        GameObjectChar.send(new MSG_REPLY_SERVER_TIME(), vo_41009_0);

        org.linlinjava.litemall.gameserver.data.vo.Vo_4099_0 vo_4099_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_4099_0();
        vo_4099_0.name = char_name;
        vo_4099_0.para = (char_name + "是第 7 次登录");
        vo_4099_0.gid = chara.uuid;
        GameObjectChar.send(new MSG_LOGIN_DONE(), vo_4099_0);


        org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0 listVo_65527_0 = GameUtil.MSG_UPDATE(chara);
        GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);

        GameObjectChar.send(new MSG_NEW_LOTTERY_OPEN(), null);


        GameUtil.MSG_UPDATE_IMPROVEMENT(chara);

        GameUtilRenWu.notifyTTTTask(chara);

        Vo_41023_0 vo_41023_0 = new Vo_41023_0();
        vo_41023_0.taskName = "拜师任务";
        vo_41023_0.status = 1;
        GameObjectChar.send(new MSG_TASK_STATUS_INFO(), vo_41023_0);


        for (int i = 0; i < chara.pets.size(); i++) {
            List list = new java.util.ArrayList();
            list.add(chara.pets.get(i));
            GameObjectChar.send(new MSG_UPDATE_PETS(), list);
            GameObjectChar.send(new MSG_REFRESH_PET_GODBOOK_SKILLS_0(), ((Petbeibao) chara.pets.get(i)).tianshu);
            boolean isfagong = ((PetShuXing) ((Petbeibao) chara.pets.get(i)).petShuXing.get(0)).rank > ((PetShuXing) ((Petbeibao) chara.pets.get(i)).petShuXing.get(0)).pet_mag_shape;
            GameUtil.dujineng(1, ((PetShuXing) ((Petbeibao) chara.pets.get(i)).petShuXing.get(0)).metal, ((PetShuXing) ((Petbeibao) chara.pets.get(i)).petShuXing.get(0)).skill, isfagong, ((Petbeibao) chara.pets.get(i)).id, chara);
        }


       GameUtil.notifyFightPet(GameObjectChar.getGameObjectChar());


        org.linlinjava.litemall.gameserver.data.vo.Vo_8425_0 vo_8425_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_8425_0();
        vo_8425_0.id = chara.zuoqiId;
        GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M8425_0(), vo_8425_0);

        GameUtil.addVip(chara);


        GameObjectChar.send(new MSG_SUIJI_RICHANGE_FANBEI(), null);


        org.linlinjava.litemall.gameserver.data.vo.Vo_53399_0 vo_53399_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_53399_0();
        vo_53399_0.value = "10011011111";
        GameObjectChar.send(new MSG_SET_PUSH_SETTINGS(), vo_53399_0);

        Vo_53521_0 vo_53521_0 = new Vo_53521_0();
        vo_53521_0.chushiLevel = 90;
        GameObjectChar.send(new MSG_NOTIFY_CHUSHI_LEVEL(), vo_53521_0);

        org.linlinjava.litemall.gameserver.data.vo.Vo_33055_0 vo_33055_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_33055_0();
        vo_33055_0.is_enable = 1;
        vo_33055_0.enable_gold_stall_cash = 0;
        vo_33055_0.sell_cash_aft_days = 7;
        vo_33055_0.start_gold_stall_cash = 0;
        vo_33055_0.enable_appoint = 0;
        vo_33055_0.enable_autcion = 0;
        vo_33055_0.close_time = 1536181200;
        GameObjectChar.send(new MSG_GOLD_STALL_CONFIG(), vo_33055_0);


        Vo_9129_0 vo_9129_0 = new Vo_9129_0();
        vo_9129_0.notify = 61001;
        vo_9129_0.para = "1";
        GameObjectChar.send(new MSG_GENERAL_NOTIFY(), vo_9129_0);
        vo_9129_0 = new Vo_9129_0();
        vo_9129_0.notify = 50017;
        vo_9129_0.para = "0";
        GameObjectChar.send(new MSG_GENERAL_NOTIFY(), vo_9129_0);


        vo_9129_0 = new Vo_9129_0();
        vo_9129_0.notify = 20002;
        vo_9129_0.para = "0000FFFF060FFDFF";
        GameObjectChar.send(new MSG_GENERAL_NOTIFY(), vo_9129_0);
        vo_9129_0 = new Vo_9129_0();
        vo_9129_0.notify = 39;
        vo_9129_0.para = "";
        GameObjectChar.send(new MSG_GENERAL_NOTIFY(), vo_9129_0);
        vo_9129_0 = new Vo_9129_0();
        vo_9129_0.notify = 10012;
        vo_9129_0.para = "";
        GameObjectChar.send(new MSG_GENERAL_NOTIFY(), vo_9129_0);

        vo_9129_0 = new Vo_9129_0();
        vo_9129_0.notify = 20010;
        vo_9129_0.para = String.valueOf(chara.qumoxiang);
        GameObjectChar.send(new MSG_GENERAL_NOTIFY(), vo_9129_0);


        GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);


        session.gameMap.join(session);


        GameUtil.MSG_UPDATE_IMPROVEMENT(chara);


        GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M12016_0(), chara.listshouhu);

        for (int i = 0; i < chara.listshouhu.size(); i++) {
            ShouHu shouHu = (ShouHu) chara.listshouhu.get(i);
            GameUtil.dujineng(2, ((ShouHuShuXing) shouHu.listShouHuShuXing.get(0)).metal, ((ShouHuShuXing) shouHu.listShouHuShuXing.get(0)).skill, true, shouHu.id, chara);
        }


        org.linlinjava.litemall.gameserver.data.vo.Vo_36889_0 vo_36889_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_36889_0();
        vo_36889_0.count = 2;
        vo_36889_0.id = chara.id;
        vo_36889_0.auto_select = 1;
        vo_36889_0.multi_index = 0;
        vo_36889_0.action = 2;
        vo_36889_0.para = 0;
        vo_36889_0.multi_count = 0;
        GameObjectChar.send(new MSG_FIGHT_CMD_INFO(), vo_36889_0);


        GameUtil.a49159(chara);


        List<org.linlinjava.litemall.db.domain.SaleGood> saleGoodList = GameData.that.saleGoodService.findByOwnerUuid(chara.uuid);
        org.linlinjava.litemall.gameserver.data.vo.Vo_49179_0 vo_49179_0 = GameUtil.a49179(saleGoodList, chara);
        GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M49179_0(), vo_49179_0);


        org.linlinjava.litemall.gameserver.data.vo.Vo_12269_0 vo_12269_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_12269_0();
        vo_12269_0.id = chara.id;
        vo_12269_0.owner_id = 96780;
        GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M12269_0(), vo_12269_0);


        org.linlinjava.litemall.gameserver.data.vo.Vo_61589_0 vo_61589_0 = GameUtil.a61589();
        GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61589_0(), vo_61589_0);


        org.linlinjava.litemall.gameserver.data.vo.Vo_40965_0 vo_40965_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_40965_0();
        vo_40965_0.guideId = 3;
        GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40965_0(), vo_40965_0);


        org.linlinjava.litemall.db.domain.Renwu tasks = GameData.that.baseRenwuService.findOneByCurrentTask(chara.current_task);
        Vo_61553_0 vo_61553_0 = GameUtil.a61553(tasks, chara);
        GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_0);


        org.linlinjava.litemall.gameserver.data.vo.Vo_53925_0 vo_53925_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_53925_0();
        vo_53925_0.isOffical = 1;
        GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M53925_0(), vo_53925_0);


        org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0 vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE(chara);
        GameObjectChar.getGameObjectChar().gameMap.send(new MSG_UPDATE_APPEARANCE(), vo_61661_0);

        List<org.linlinjava.litemall.gameserver.data.vo.Vo_32747_0> vo_32747_0List = GameUtil.MSG_UPDATE_SKILLS(chara);
        GameObjectChar.send(new MSG_UPDATE_SKILLS(), vo_32747_0List);


        org.linlinjava.litemall.gameserver.data.vo.Vo_32985_0 vo_32985_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_32985_0();
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
        GameUtil.genchongfei(chara);


        GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61663(), GameCore.that.getGameLineAll());


        if (!chara.npcName.equals("")) {
            Vo_61553_0 vo_61553_10 = new Vo_61553_0();
            vo_61553_10.count = 1;
            vo_61553_10.task_type = "sm-002";
            vo_61553_10.task_desc = "接受门派师尊交办的一些事情，完成后会获得嘉奖。";
            vo_61553_10.task_prompt = ("拜访#P" + chara.npcName + "|M=【师门】入世#P");
            vo_61553_10.refresh = 0;
            vo_61553_10.task_end_time = 1567932239;
            vo_61553_10.attrib = 0;
            vo_61553_10.reward = "#I经验|人物经验宠物经验#I#I金钱|金钱#I";
            vo_61553_10.show_name = ("师门—入世(" + chara.shimencishu + "/10)");
            vo_61553_10.tasktask_extra_para = "";
            vo_61553_10.tasktask_state = "1";
            GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_10);
        }


        if (chara.fabaorenwu == 1) {
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
            vo_61553_10.tasktask_state = "1";
            GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_10);
        }


        GameUtil.chenghaoxiaoxi(chara);

        if ((session.gameTeam != null) && (session.gameTeam.duiwu != null) && (session.gameTeam.duiwu.size() > 0)) {
            Vo_61671_0 vo_61671_0 = new Vo_61671_0();
            vo_61671_0.id = ((Chara) session.gameTeam.duiwu.get(0)).id;
            vo_61671_0.count = 2;
            vo_61671_0.list.add(Integer.valueOf(2));
            vo_61671_0.list.add(Integer.valueOf(3));
            GameObjectChar.send(new MSG_TITLE(), vo_61671_0);
            for (int i = 0; i < session.gameTeam.duiwu.size(); i++) {
                if ((((Chara) session.gameTeam.duiwu.get(i)).id == chara.id) && (((Chara) session.gameTeam.duiwu.get(0)).id != chara.id)) {
                    vo_61671_0 = new Vo_61671_0();
                    vo_61671_0.id = session.chara.id;
                    vo_61671_0.count = 2;
                    vo_61671_0.list.add(Integer.valueOf(2));
                    vo_61671_0.list.add(Integer.valueOf(5));
                    GameObjectChar.send(new MSG_TITLE(), vo_61671_0);
                }
            }
            List<Chara> charas = GameObjectChar.getGameObjectChar().gameTeam.duiwu;
            GameUtil.MSG_UPDATE_TEAM_LIST(charas);
            GameUtil.MSG_UPDATE_TEAM_LIST_EX(GameObjectChar.getGameObjectChar().gameTeam.zhanliduiyuan);
        }

        if (chara.changbaotu.mapid != 0) {
            vo_61553_0 = new Vo_61553_0();
            vo_61553_0.count = 1;
            vo_61553_0.task_type = "超级宝藏";
            vo_61553_0.task_desc = "在游戏中根据超级藏宝图进行寻宝。";
            vo_61553_0.task_prompt = ("#前往#Z" + chara.changbaotu.name + "|" + chara.changbaotu.name + "(" + chara.changbaotu.x + "," + chara.changbaotu.y + ")#Z寻宝");
            vo_61553_0.refresh = 1;
            vo_61553_0.task_end_time = 1567909190;
            vo_61553_0.attrib = 1;
            vo_61553_0.reward = "#I道行|道行#I#I潜能|潜能#I#I金钱|金钱#I#I物品|召唤令·十二生肖#I#I宠物|十二生肖=F#I";
            vo_61553_0.show_name = "超级宝藏";
            vo_61553_0.tasktask_extra_para = "";
            vo_61553_0.tasktask_state = "1";
            GameObjectChar.getGameObjectChar();
            GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_0);
        }


        Vo_4321_0 vo_4321_0 = new Vo_4321_0();
        vo_4321_0.dist = "一战功成";
        vo_4321_0.b = 0;
        vo_4321_0.flag = 1;
        vo_4321_0.a = GameCore.getGameLine(chara.line).lineNum;
        vo_4321_0.name = GameCore.getGameLine(chara.line).lineName;
        vo_4321_0.time = ((int) (System.currentTimeMillis() / 1000L));
        vo_4321_0.c = 8;
        GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M_MSG_ENTER_GAME(), vo_4321_0);


        UserLogic logic = GameObjectChar.getGameObjectChar().logic;
        UserPartyDailyTaskLogic dailyTaskLogic = (UserPartyDailyTaskLogic) logic.getMod("party_daily_task");
        boolean hasPartyDailyTask = dailyTaskLogic.hasTask();
        PartyDailyTaskItem newDailyTaskItem = null;
        if (hasPartyDailyTask) {
            newDailyTaskItem = dailyTaskLogic.getCfgItem(dailyTaskLogic.data.getCurTaskId());
        }
        if (newDailyTaskItem != null) {
            vo_61553_0 = new Vo_61553_0();
            vo_61553_0.count = 1;
            vo_61553_0.task_type = "帮派日常任务";
            vo_61553_0.task_desc = newDailyTaskItem.task_desc;
            vo_61553_0.task_prompt = newDailyTaskItem.task_prompt;
            vo_61553_0.refresh = 1;
            vo_61553_0.task_end_time = 1567909190;
            vo_61553_0.attrib = 1;
            vo_61553_0.reward = "帮贡x" + newDailyTaskItem.reward;
            vo_61553_0.show_name = newDailyTaskItem.show_name;
            vo_61553_0.tasktask_extra_para = "";
            vo_61553_0.tasktask_state = "1";
            GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_0);
        }


        org.linlinjava.litemall.gameserver.fight.FightManager.reconnect(chara);
    }

    public int cmd() {
        return 4192;
    }

    public static void main(String[] args) throws java.io.UnsupportedEncodingException {
        String value = String.valueOf("多闻道人");
        byte[] bs = value.getBytes("GBK");
        String s = bytesToHexString(bs);
        System.out.println(s);
    }


    public static String bytesToHexString(byte[] src) {
        StringBuilder stringBuilder = new StringBuilder("");
        if ((src == null) || (src.length <= 0)) {
            return null;
        }
        for (int i = 0; i < src.length; i++) {
            int v = src[i] & 0xFF;
            String hv = Integer.toHexString(v);
            if (hv.length() < 2) {
                stringBuilder.append(0);
            }
            stringBuilder.append(hv);
        }
        return stringBuilder.toString();
    }

    public static byte[] hexToByteArray(String inHex) {
        int hexlen = inHex.length();
        byte[] result;
        if (hexlen % 2 == 1) {
            hexlen++;
            result = new byte[hexlen / 2];
            inHex = "0" + inHex;
        } else {
            result = new byte[hexlen / 2];
        }
        int j = 0;
        for (int i = 0; i < hexlen; i += 2) {
            result[j] = hexToByte(inHex.substring(i, i + 2));
            j++;
        }
        return result;
    }

    public static byte hexToByte(String inHex) {
        /* 461 */
        return (byte) Integer.parseInt(inHex, 16);
        /*     */
    }
}
