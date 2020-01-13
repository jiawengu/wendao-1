
package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.db.domain.NpcDialogueFrame;
import org.linlinjava.litemall.db.domain.Renwu;
import org.linlinjava.litemall.db.domain.ShangGuYaoWangInfo;
import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_8247_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_MENU_LIST;
import org.linlinjava.litemall.gameserver.data.xls_config.PartyDailyTaskItem;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.PetShuXing;
import org.linlinjava.litemall.gameserver.domain.Petbeibao;
import org.linlinjava.litemall.gameserver.game.*;
import org.linlinjava.litemall.gameserver.service.HeroPubService;
import org.linlinjava.litemall.gameserver.service.ZhengDaoDianService;
import org.linlinjava.litemall.gameserver.user_logic.UserLogic;
import org.linlinjava.litemall.gameserver.user_logic.UserPartyDailyTaskLogic;
import org.linlinjava.litemall.gameserver.util.MsgUtil;
import org.linlinjava.litemall.gameserver.util.NpcIds;

import java.util.List;

import static org.linlinjava.litemall.gameserver.util.MsgUtil.*;


/**
 * CMD_OPEN_MENU
 */
@org.springframework.stereotype.Service
/*     */ public class CMD_OPEN_MENU implements org.linlinjava.litemall.gameserver.GameHandler
        /*     */ {
    /*     */
    public void process(ChannelHandlerContext ctx, ByteBuf buff)
    /*     */ {
        /*  27 */
        int id = org.linlinjava.litemall.gameserver.data.GameReadTool.readInt(buff);

        int type = org.linlinjava.litemall.gameserver.data.GameReadTool.readByte(buff);
        System.out.println("CMD_OPEN_MENU:" + id + ":" + type);
        /*     */
        /*  31 */
        Chara chara = GameObjectChar.getGameObjectChar().chara;

        if(NpcIds.isZhengDaoDianNpc(id)){//证道殿npc
           ZhengDaoDianService.openMenu(chara, id);
            return;
        }
        if(NpcIds.isHeroPubNpc(id)){//英雄会
            HeroPubService.openMenu(chara, id);
            return;
        }
        /*     */
        /*  33 */
        String[] shidaolevel = {"试道场(60-79)", "试道场(80-89)", "试道场(90-99)", "试道场(100-109)", "试道场(110-119)", "试道场(120-129)"};
        /*  34 */
        for (int k = 0; k < shidaolevel.length; k++) {

            GameMap gameMap = GameLine.getGameMap(1, shidaolevel[k]);

            for (int i = 0; i < gameMap.gameShiDao.shidaoyuanmo.size(); i++) {

                if (id == ((Vo_65529_0) gameMap.gameShiDao.shidaoyuanmo.get(i)).id) {

                    Vo_8247_0 vo_8247_0 = new Vo_8247_0();

                    vo_8247_0.id = id;

                    vo_8247_0.portrait = ((Vo_65529_0) gameMap.gameShiDao.shidaoyuanmo.get(i)).icon;

                    vo_8247_0.pic_no = 1;

                    vo_8247_0.content = "今天又可以活动活动筋骨了！真是开心呐！实力太弱的我可不陪他玩，如果#R20#n回合内没打败我，可是要被传出试道场外的！[让我试试你的厉害！/开始战斗][回头再说吧！/离开]"
                            .replace("\\", "");

                    vo_8247_0.secret_key = "";

                    vo_8247_0.name = ((Vo_65529_0) gameMap.gameShiDao.shidaoyuanmo.get(i)).name;

                    vo_8247_0.attrib = 0;
                    /*  46 */
                    GameObjectChar.send(new MSG_MENU_LIST(), vo_8247_0);
                    /*     */
                }

            }

        }

        if (GameShuaGuai.list.contains(Integer.valueOf(id))) {

            for (int i = 0; i < GameLine.gameShuaGuai.shuaXing.size(); i++) {

                if (id == ((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).id) {

                    if ((((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).wanjiaid == chara.id)
                            || (((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).wanjiaid == 0)) {

                        Vo_8247_0 vo_8247_0 = new Vo_8247_0();

                        vo_8247_0.id = id;

                        vo_8247_0.portrait = ((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).icon;

                        vo_8247_0.pic_no = 1;

                        vo_8247_0.content = ("我乃天界星官 , 巡游至此，你一介凡人,怎可挡我去路?高于星官29级以上将无法获得奖励。盘还穷追不舍!\n[我是来向你挑战的]\n"
                                + "[我是路过的]".replace("\\", ""));

                        vo_8247_0.secret_key = "";

                        vo_8247_0.name = ((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).name;

                        vo_8247_0.attrib = 0;
                        /*  67 */
                        GameObjectChar.send(new MSG_MENU_LIST(), vo_8247_0);
                        /*  68 */
                        return;

                    }

                    Vo_8247_0 vo_8247_0 = new Vo_8247_0();

                    vo_8247_0.id = id;

                    vo_8247_0.portrait = ((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).icon;

                    vo_8247_0.pic_no = 1;

                    vo_8247_0.content = ("我乃天界星官 , 巡游至此，你一介凡人,怎可挡我去路?高于星官29级以上将无法获得奖励。盘还穷追不舍!\n"
                            + "[我是路过的]".replace("\\", ""));

                    vo_8247_0.secret_key = "";

                    vo_8247_0.name = ((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).name;

                    vo_8247_0.attrib = 0;
                    /*  80 */
                    GameObjectChar.send(new MSG_MENU_LIST(), vo_8247_0);
                    /*  81 */
                    return;

                }

            }

        }

        for (int i = 0; i < chara.npcxuanshang.size(); i++) {

            if (id == ((Vo_65529_0) chara.npcxuanshang.get(i)).id) {

                Vo_8247_0 vo_8247_0 = new Vo_8247_0();

                vo_8247_0.id = ((Vo_65529_0) chara.npcxuanshang.get(i)).id;

                vo_8247_0.portrait = ((Vo_65529_0) chara.npcxuanshang.get(i)).icon;

                vo_8247_0.pic_no = 1;

                vo_8247_0.content = ("那天杀的仙界臭捕,爷爷逃到凡人的地\n盘还穷追不舍!\n[追拿通缉犯]\n" + "[离开]".replace("\\", ""));

                vo_8247_0.secret_key = "";

                vo_8247_0.name = ((Vo_65529_0) chara.npcxuanshang.get(i)).name;

                vo_8247_0.attrib = 0;
                /* 102 */
                GameObjectChar.send(new MSG_MENU_LIST(), vo_8247_0);
                /* 103 */
                return;

            }

        }

        for (int i = 0; i < chara.npcchubao.size(); i++) {

            if (id == ((Vo_65529_0) chara.npcchubao.get(i)).id) {

                Vo_8247_0 vo_8247_0 = new Vo_8247_0();

                vo_8247_0.id = ((Vo_65529_0) chara.npcchubao.get(i)).id;

                vo_8247_0.portrait = ((Vo_65529_0) chara.npcchubao.get(i)).icon;

                vo_8247_0.pic_no = 1;

                vo_8247_0.content = ("想抓我得先问问我手中的家伙答不答应。\n[就是来抓你的]\n" + "[我先准备准备]".replace("\\", ""));

                vo_8247_0.secret_key = "";

                vo_8247_0.name = ((Vo_65529_0) chara.npcchubao.get(i)).name;

                vo_8247_0.attrib = 0;
                /* 119 */
                GameObjectChar.send(new MSG_MENU_LIST(), vo_8247_0);
                /* 120 */
                return;

            }

        }

        for (int i = 0; i < chara.npcshuadao.size(); i++) {

            if (id == ((Vo_65529_0) chara.npcshuadao.get(i)).id) {

                Vo_8247_0 vo_8247_0 = new Vo_8247_0();

                vo_8247_0.id = ((Vo_65529_0) chara.npcshuadao.get(i)).id;

                vo_8247_0.portrait = ((Vo_65529_0) chara.npcshuadao.get(i)).icon;

                vo_8247_0.pic_no = 1;

                vo_8247_0.content = ("哈哈，送上们的肥肉。\n[今天我要为民除害]\n" + "[我先准备准备]".replace("\\", ""));

                vo_8247_0.secret_key = "";

                vo_8247_0.name = ((Vo_65529_0) chara.npcshuadao.get(i)).name;

                vo_8247_0.attrib = 0;
                /* 136 */
                GameObjectChar.send(new MSG_MENU_LIST(), vo_8247_0);
                /* 137 */
                return;

            }

        }

        GameMap gameMap = GameObjectChar.getGameObjectChar().gameMap;
        if (gameMap.isDugeno() && ((GameZone)gameMap).gameDugeon.meetNpc(chara, id))
        {
            return;
        }
        /*     */


        if(GameData.that.superBossMng.isBoss(Integer.valueOf(id))){
            //是超级BOSS;
            GameData.that.superBossMng.sendBossDlg(id);
            return ;
        }
        Npc npc = GameData.that.baseNpcService.findById(id);

        if (npc == null) {

            return;

        }

        /* 146 */
        List<NpcDialogueFrame> npcDialogueFrameList = GameData.that.baseNpcDialogueFrameService.findByName(npc.getName());
        /* 147 */
        String content = "找我有什么事吗？[离开\\/离开]";

        if (npcDialogueFrameList.size() != 0) {

            content = ((NpcDialogueFrame) npcDialogueFrameList.get(0)).getUncontent();

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
        /*     */
        /* 155 */
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
        /*     */
        /*     */
        /*     */
        /* 179 */
        Vo_8247_0 vo_8247_0 = GameUtil.MSG_MENU_LIST(npc, content);
        /* 180 */
        GameObjectChar.send(new MSG_MENU_LIST(), vo_8247_0);
        /*     */
    }

    public int cmd() {

        return 4150;

    }
    /*     */
}
