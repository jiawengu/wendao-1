
package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import java.util.List;
import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.db.domain.NpcDialogueFrame;
import org.linlinjava.litemall.db.domain.Renwu;
import org.linlinjava.litemall.db.domain.ShangGuYaoWangInfo;
import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_8247_0;
import org.linlinjava.litemall.gameserver.data.write.M8247_0;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.PetShuXing;
import org.linlinjava.litemall.gameserver.domain.Petbeibao;
import org.linlinjava.litemall.gameserver.game.*;
import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
@org.springframework.stereotype.Service
public class C4150_0 implements org.linlinjava.litemall.gameserver.GameHandler {

    public void process(ChannelHandlerContext ctx, ByteBuf buff) {

        int id = org.linlinjava.litemall.gameserver.data.GameReadTool.readInt(buff);

        int type = org.linlinjava.litemall.gameserver.data.GameReadTool.readByte(buff);

        System.out.println(String.format("打开菜单:type[%s];id[%s]", type, id));

        Chara chara = GameObjectChar.getGameObjectChar().chara;

        String[] shidaolevel = { "试道场(60-79)", "试道场(80-89)", "试道场(90-99)", "试道场(100-109)", "试道场(110-119)",
                "试道场(120-129)" };

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

                    GameObjectChar.send(new M8247_0(), vo_8247_0);

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

                        GameObjectChar.send(new M8247_0(), vo_8247_0);

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

                    GameObjectChar.send(new M8247_0(), vo_8247_0);

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

                GameObjectChar.send(new M8247_0(), vo_8247_0);

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

                GameObjectChar.send(new M8247_0(), vo_8247_0);

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

                GameObjectChar.send(new M8247_0(), vo_8247_0);

                return;

            }

        }


        if(GameData.that.superBossMng.isBoss(Integer.valueOf(id))){
            //是超级BOSS;
            GameData.that.superBossMng.sendBossDlg(id);
            return ;
        }
        Npc npc = GameData.that.baseNpcService.findById(id);

        if (npc == null) {

            return;

        }

        List<NpcDialogueFrame> npcDialogueFrameList = GameData.that.baseNpcDialogueFrameService
                .findByName(npc.getName());

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

        if (id == 829) {
            content = "[挑战掌门]" + content;
        }

        if (npc.getName().equals(chara.npcName)) {

            content = "[【师门】入世/sm-002_s1]" + content;

        }
        if (npc.getName().equals(chara.xiuxingNpcname)) {

            content = "[【十绝阵】讨教/十绝阵_s1]" + content;

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

        Vo_8247_0 vo_8247_0 = GameUtil.a8247(npc, content);

        GameObjectChar.send(new M8247_0(), vo_8247_0);

    }

    public int cmd() {

        return 4150;

    }

}

/*
 * Location:
 * C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\
 * gameserver\process\C4150_0.class Java compiler version: 8 (52.0) JD-Core
 * Version: 0.7.1
 */