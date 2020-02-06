
package org.linlinjava.litemall.gameserver.process;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.apache.commons.lang3.StringUtils;
import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.db.domain.NpcDialogueFrame;
import org.linlinjava.litemall.db.domain.Renwu;
import org.linlinjava.litemall.db.domain.ShangGuYaoWangInfo;
import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
import org.linlinjava.litemall.gameserver.data.vo.MSG_MENU_LIST_VO;
import org.linlinjava.litemall.gameserver.data.write.MSG_MENU_LIST;
import org.linlinjava.litemall.gameserver.data.xls_config.PartyDailyTaskItem;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.PetShuXing;
import org.linlinjava.litemall.gameserver.domain.Petbeibao;
import org.linlinjava.litemall.gameserver.game.*;
import org.linlinjava.litemall.gameserver.service.HeroPubService;
import org.linlinjava.litemall.gameserver.service.MapGuardianService;
import org.linlinjava.litemall.gameserver.service.ZhengDaoDianService;
import org.linlinjava.litemall.gameserver.user_logic.UserLogic;
import org.linlinjava.litemall.gameserver.user_logic.UserPartyDailyChallengeLogic;
import org.linlinjava.litemall.gameserver.user_logic.UserPartyDailyTaskLogic;
import org.linlinjava.litemall.gameserver.util.NpcIds;

import java.util.List;
import static org.linlinjava.litemall.gameserver.util.MsgUtil.*;

/**
 * 返回NPC的对话选项
 */
@org.springframework.stereotype.Service
 public class CMD_OPEN_MENU implements org.linlinjava.litemall.gameserver.GameHandler
         {

    public void process(ChannelHandlerContext ctx, ByteBuf buff)
     {

        int id = org.linlinjava.litemall.gameserver.data.GameReadTool.readInt(buff);
        int type = org.linlinjava.litemall.gameserver.data.GameReadTool.readByte(buff);
        System.out.println("CMD_OPEN_MENU:" + id + ":" + type);

        Chara chara = GameObjectChar.getGameObjectChar().chara;
        // 先处理副本的，可能是monsterid,可能是npcid，为避免冲突尽量不要放在这个前面处理
         GameMap gameMap = GameObjectChar.getGameObjectChar().gameMap;
         if (gameMap.isDugeno() && ((GameZone)gameMap).gameDugeon.meetNpc(chara, id))
         {
             return;
         }

         if(NpcIds.isZhengDaoDianNpc(id)){//证道殿npc
           ZhengDaoDianService.openMenu(chara, id);
            return;
        }
        if(NpcIds.isHeroPubNpc(id)){//英雄会
            HeroPubService.openMenu(chara, id);
            return;
        }
        if(NpcIds.isMapGuardianNpc(id)){//地图守护神
            MapGuardianService.openMenu(chara, id);
            return;
        }

        String[] shidaolevel = {"试道场(60-79)", "试道场(80-89)", "试道场(90-99)", "试道场(100-109)", "试道场(110-119)", "试道场(120-129)"};

        for (int k = 0; k < shidaolevel.length; k++) {
            gameMap = GameLine.getGameMap(1, shidaolevel[k]);
            for (int i = 0; i < gameMap.gameShiDao.shidaoyuanmo.size(); i++) {
                if (id == ((Vo_65529_0) gameMap.gameShiDao.shidaoyuanmo.get(i)).id) {
                    MSG_MENU_LIST_VO menu_list_vo = new MSG_MENU_LIST_VO();
                    menu_list_vo.id = id;
                    menu_list_vo.portrait = ((Vo_65529_0) gameMap.gameShiDao.shidaoyuanmo.get(i)).icon;
                    menu_list_vo.pic_no = 1;
                    menu_list_vo.content = "今天又可以活动活动筋骨了！真是开心呐！实力太弱的我可不陪他玩，如果#R20#n回合内没打败我，可是要被传出试道场外的！[让我试试你的厉害！/开始战斗][回头再说吧！/离开]"
                            .replace("\\", "");
                    menu_list_vo.secret_key = "";
                    menu_list_vo.name = ((Vo_65529_0) gameMap.gameShiDao.shidaoyuanmo.get(i)).name;
                    menu_list_vo.attrib = 0;

                    GameObjectChar.send(new MSG_MENU_LIST(), menu_list_vo);

                }
            }
        }
        if (GameShuaGuai.list.contains(Integer.valueOf(id))) {
            for (int i = 0; i < GameLine.gameShuaGuai.shuaXing.size(); i++) {
                if (id == ((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).id) {
                    if ((((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).wanjiaid == chara.id)
                            || (((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).wanjiaid == 0)) {
                        MSG_MENU_LIST_VO menu_list_vo = new MSG_MENU_LIST_VO();
                        menu_list_vo.id = id;
                        menu_list_vo.portrait = ((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).icon;
                        menu_list_vo.pic_no = 1;
                        menu_list_vo.content = ("我乃天界星官 , 巡游至此，你一介凡人,怎可挡我去路?高于星官29级以上将无法获得奖励。盘还穷追不舍!\n[我是来向你挑战的]\n"
                                + "[我是路过的]".replace("\\", ""));
                        menu_list_vo.secret_key = "";
                        menu_list_vo.name = ((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).name;
                        menu_list_vo.attrib = 0;

                        GameObjectChar.send(new MSG_MENU_LIST(), menu_list_vo);

                        return;
                    }
                    MSG_MENU_LIST_VO menu_list_vo = new MSG_MENU_LIST_VO();
                    menu_list_vo.id = id;
                    menu_list_vo.portrait = ((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).icon;
                    menu_list_vo.pic_no = 1;
                    menu_list_vo.content = ("我乃天界星官 , 巡游至此，你一介凡人,怎可挡我去路?高于星官29级以上将无法获得奖励。盘还穷追不舍!\n"
                            + "[我是路过的]".replace("\\", ""));
                    menu_list_vo.secret_key = "";
                    menu_list_vo.name = ((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).name;
                    menu_list_vo.attrib = 0;

                    GameObjectChar.send(new MSG_MENU_LIST(), menu_list_vo);

                    return;
                }
            }
        }
        for (int i = 0; i < chara.npcxuanshang.size(); i++) {
            if (id == ((Vo_65529_0) chara.npcxuanshang.get(i)).id) {
                MSG_MENU_LIST_VO menu_list_vo = new MSG_MENU_LIST_VO();
                menu_list_vo.id = ((Vo_65529_0) chara.npcxuanshang.get(i)).id;
                menu_list_vo.portrait = ((Vo_65529_0) chara.npcxuanshang.get(i)).icon;
                menu_list_vo.pic_no = 1;
                menu_list_vo.content = ("那天杀的仙界臭捕,爷爷逃到凡人的地\n盘还穷追不舍!\n[追拿通缉犯]\n" + "[离开]".replace("\\", ""));
                menu_list_vo.secret_key = "";
                menu_list_vo.name = ((Vo_65529_0) chara.npcxuanshang.get(i)).name;
                menu_list_vo.attrib = 0;

                GameObjectChar.send(new MSG_MENU_LIST(), menu_list_vo);

                return;
            }
        }
        for (int i = 0; i < chara.npcchubao.size(); i++) {
            if (id == ((Vo_65529_0) chara.npcchubao.get(i)).id) {
                MSG_MENU_LIST_VO menu_list_vo = new MSG_MENU_LIST_VO();
                menu_list_vo.id = ((Vo_65529_0) chara.npcchubao.get(i)).id;
                menu_list_vo.portrait = ((Vo_65529_0) chara.npcchubao.get(i)).icon;
                menu_list_vo.pic_no = 1;
                menu_list_vo.content = ("想抓我得先问问我手中的家伙答不答应。\n[就是来抓你的]\n" + "[我先准备准备]".replace("\\", ""));
                menu_list_vo.secret_key = "";
                menu_list_vo.name = ((Vo_65529_0) chara.npcchubao.get(i)).name;
                menu_list_vo.attrib = 0;

                GameObjectChar.send(new MSG_MENU_LIST(), menu_list_vo);

                return;
            }
        }
        for (int i = 0; i < chara.npcshuadao.size(); i++) {
            if (id == ((Vo_65529_0) chara.npcshuadao.get(i)).id) {
                MSG_MENU_LIST_VO menu_list_vo = new MSG_MENU_LIST_VO();
                menu_list_vo.id = ((Vo_65529_0) chara.npcshuadao.get(i)).id;
                menu_list_vo.portrait = ((Vo_65529_0) chara.npcshuadao.get(i)).icon;
                menu_list_vo.pic_no = 1;
                menu_list_vo.content = ("哈哈，送上们的肥肉。\n[今天我要为民除害]\n" + "[我先准备准备]".replace("\\", ""));
                menu_list_vo.secret_key = "";
                menu_list_vo.name = ((Vo_65529_0) chara.npcshuadao.get(i)).name;
                menu_list_vo.attrib = 0;

                GameObjectChar.send(new MSG_MENU_LIST(), menu_list_vo);

                return;
            }
        }

        if(GameData.that.superBossMng.isBoss(Integer.valueOf(id))){
            //是超级BOSS;
            GameData.that.superBossMng.sendBossDlg(id);
            return ;
        }
        if(GameData.that.outdoorBossMng.isBoss(Integer.valueOf(id))){
            //野怪
            GameData.that.outdoorBossMng.sendBossDlg(id);
        }
        Npc npc = GameData.that.baseNpcService.findById(id);
        if (npc == null) {
            return;
        }

        List<NpcDialogueFrame> npcDialogueFrameList = GameData.that.baseNpcDialogueFrameService.findByName(npc.getName());

        String content = "找我有什么事吗？[离开\\/离开]";
        if (npcDialogueFrameList.size() != 0) {
            content = ((NpcDialogueFrame) npcDialogueFrameList.get(0)).getUncontent();
        }
        if(MapGuardianService.isProtector(npc.getName())){//地图守护神
            MapGuardianService.openMenu(chara, npc);
            return;
        }

        //牢头
         if (1015 == npc.getId()){
             content = "你来探监吗？\n[查看在押犯人]\n[离开]\n";
         }
        //飞升
        if (GamePetFeiSheng.zhanDouNpcName.equals(npc.getName())) {
            if ( GamePetFeiSheng.isTongGuoKaoYan(chara)) {
                content =
                        ("飞升宠物所需材料：2阶骑宠灵魂3个以重塑其魂，驯兽诀1本以定其魂，萦香丸20颗以滋养其血肉，聚灵丹20颗以调养精气\n[飞升]\n" + "[离开]".replace("\\", ""));
            } else {
                content =
                        ("人可修道，宠物亦可修道，不管是人还是宠物，修炼到深处，皆可得道飞升\n[宠物飞升]\n[帮派求助]\n" + "[离开]".replace("\\", ""));
            }
        }

        ShangGuYaoWangInfo info =
                GameShangGuYaoWang.getYaoWangNpc(npc.getId(),
                        GameShangGuYaoWang.YAOWANG_STATE.YAOWANG_STATE_OPEN);
        if (null != info){
            int level = info.getLevel();
            content =
                    ("大胆狂徒，敢在本大王面前撒野，真是活得不耐烦了！(妖王等级"+level+"级，适合"+level+"-"+(level+29)+"级玩家挑战）\n[挑战]\n" + "[离开]".replace("\\",""));
        }
        if (GameUtil.isZhangeMenNpc(npc.getName())) {//掌门npc
            if(GameUtil.getMenPai(npc.getName()) == chara.menpai){//自己的掌门
                content = getTalk(TIAO_ZHAN_ZHANG_MEN)+
                        getTalk(CHA_KAN_ZHANG_MEN)+
                        getTalk(JIN_RU_ZHENG_DAO_DIAN);
            }else{//其他门派掌门
                content = getTalk(KAN_KAN_YE_WU_FANG)+
                        getTalk(BU_KAN_LE);
            }
        }
        if (npc.getName().equals(chara.npcName)) {
            content = "[【师门】入世/sm-002_s1]" + content;
        }
        if (npc.getName().equals(chara.xiuxingNpcname)) {
            content = "[【十绝阵】讨教/十绝阵_s1]" + content;
        }
        if(npc.getMapId()==37000){//通天塔
            if (!chara.ttt_xj_success && npc.getName().equals(chara.ttt_xj_name)) {
                content = "[挑战星君]"+ content;
            }
            if(npc.getName().equals("北斗神将")){
                if(chara.ttt_challenge_num>0){//挑战了
                    if(chara.ttt_xj_success){//挑战成功
                        content = "道友已参透此处玄机，佩服，佩服[挑战下层][飞升][离开]";
                    }else{//挑战失败
                        content = "来日方长，待道友重整旗鼓，再来见识通天塔之玄妙[重新挑战][离开]";
                    }
                }else{//还没用挑战
                    content = "吾奉天命，在此负责通天塔之传送事宜。[更换奖励类型][传送出塔][离开]";
                }
            }
        }


        Renwu renwu = GameData.that.baseRenwuService.findOneByCurrentTask(chara.current_task);
        if ((renwu != null) && (renwu.getNpcName() != null)) {
            if (npc.getName().equals(renwu.getNpcName())) {
                content = renwu.getUncontent() + content;
            }
            if (chara.current_task.equals("主线—浮生若梦_s22")) {
                String[] split = renwu.getNpcName().split("\\_");
                String name = split[(chara.menpai - 1)];
                if (name.equals(npc.getName())) {
                    content = renwu.getUncontent() + content;
                }
            }
        }
        if (id == 978) {
            for (int i = 0; i < chara.pets.size(); i++) {
                content = "[销毁#R" + ((PetShuXing) ((Petbeibao) chara.pets.get(i)).petShuXing.get(0)).str + "#n\\/"
                        + ((Petbeibao) chara.pets.get(i)).id + "]" + content;
            }
        }
        if ((id == 928) && (chara.fabaorenwu == 1)) {
            content = "[【领取法宝】提交#R蟠螭结、雪魂丝链#n]" + content;
        }
        UserLogic logic = GameObjectChar.getGameObjectChar().logic;
        UserPartyDailyTaskLogic dailyTaskLogic = (UserPartyDailyTaskLogic)logic.getMod("party_daily_task");
        PartyDailyTaskItem dailyTaskItem = dailyTaskLogic.checkCurTaskByNpcId(id);
        if(dailyTaskItem != null){
            content = "[" + dailyTaskItem.show_name + "]" + content;
        }

        UserPartyDailyChallengeLogic dailyChallengeLogic = (UserPartyDailyChallengeLogic)logic.getMod("party_daily_challenge");
        if(dailyChallengeLogic.openMenu(id) != null){
            content = dailyChallengeLogic.openMenu(id) + content;
        }



        if (id == NpcIds.HAO_WEN_JIA_NPC_ID && StringUtils.isNotBlank(chara.house.getHouseName())){
            String[] strings = content.split("]");
            strings[1] += "][我要进入居所/enter_house";
            content = "";
            for (String s : strings) {
                content += s + "]" ;
            }
        }

        if(id == NpcIds.GUAN_JIA_NPC_ID){

        }

        MSG_MENU_LIST_VO menu_list_vo = GameUtil.MSG_MENU_LIST(npc, content);

        GameObjectChar.send(new MSG_MENU_LIST(), menu_list_vo);

    }
    public int cmd() {
        return 4150;
    }

}
