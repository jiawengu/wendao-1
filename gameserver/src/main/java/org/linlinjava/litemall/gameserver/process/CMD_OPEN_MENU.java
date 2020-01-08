/*     */
package org.linlinjava.litemall.gameserver.process;
/*     */
/*     */

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
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

import java.util.List;


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
        /*     */
        /*  29 */
        int type = org.linlinjava.litemall.gameserver.data.GameReadTool.readByte(buff);
        /*     */
        /*  31 */
        Chara chara = GameObjectChar.getGameObjectChar().chara;
        /*     */
        /*  33 */
        String[] shidaolevel = {"试道场(60-79)", "试道场(80-89)", "试道场(90-99)", "试道场(100-109)", "试道场(110-119)", "试道场(120-129)"};
        /*  34 */
        for (int k = 0; k < shidaolevel.length; k++) {
            /*  35 */
            GameMap gameMap = GameLine.getGameMap(1, shidaolevel[k]);
            /*  36 */
            for (int i = 0; i < gameMap.gameShiDao.shidaoyuanmo.size(); i++) {
                /*  37 */
                if (id == ((Vo_65529_0) gameMap.gameShiDao.shidaoyuanmo.get(i)).id) {
                    /*  38 */
                    Vo_8247_0 vo_8247_0 = new Vo_8247_0();
                    /*  39 */
                    vo_8247_0.id = id;
                    /*  40 */
                    vo_8247_0.portrait = ((Vo_65529_0) gameMap.gameShiDao.shidaoyuanmo.get(i)).icon;
                    /*  41 */
                    vo_8247_0.pic_no = 1;
                    /*  42 */
                    vo_8247_0.content = "今天又可以活动活动筋骨了！真是开心呐！实力太弱的我可不陪他玩，如果#R20#n回合内没打败我，可是要被传出试道场外的！[让我试试你的厉害！/开始战斗][回头再说吧！/离开]".replace("\\", "");
                    /*  43 */
                    vo_8247_0.secret_key = "";
                    /*  44 */
                    vo_8247_0.name = ((Vo_65529_0) gameMap.gameShiDao.shidaoyuanmo.get(i)).name;
                    /*  45 */
                    vo_8247_0.attrib = 0;
                    /*  46 */
                    GameObjectChar.send(new M8247_0(), vo_8247_0);
                    /*     */
                }
                /*     */
            }
            /*     */
        }
        /*     */
        /*     */
        /*  52 */
        if (GameShuaGuai.list.contains(Integer.valueOf(id))) {
            /*  53 */
            for (int i = 0; i < GameLine.gameShuaGuai.shuaXing.size(); i++) {
                /*  54 */
                if (id == ((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).id) {
                    /*  55 */
                    if ((((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).wanjiaid == chara.id) || (((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).wanjiaid == 0)) {
                        /*  56 */
                        Vo_8247_0 vo_8247_0 = new Vo_8247_0();
                        /*  57 */
                        vo_8247_0.id = id;
                        /*  58 */
                        vo_8247_0.portrait = ((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).icon;
                        /*  59 */
                        vo_8247_0.pic_no = 1;
                        /*     */
                        /*     */
                        /*     */
                        /*  63 */
                        vo_8247_0.content = ("我乃天界星官 , 巡游至此，你一介凡人,怎可挡我去路?高于星官29级以上将无法获得奖励。盘还穷追不舍!\n[我是来向你挑战的]\n" + "[我是路过的]".replace("\\", ""));
                        /*  64 */
                        vo_8247_0.secret_key = "";
                        /*  65 */
                        vo_8247_0.name = ((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).name;
                        /*  66 */
                        vo_8247_0.attrib = 0;
                        /*  67 */
                        GameObjectChar.send(new M8247_0(), vo_8247_0);
                        /*  68 */
                        return;
                        /*     */
                    }
                    /*  70 */
                    Vo_8247_0 vo_8247_0 = new Vo_8247_0();
                    /*  71 */
                    vo_8247_0.id = id;
                    /*  72 */
                    vo_8247_0.portrait = ((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).icon;
                    /*  73 */
                    vo_8247_0.pic_no = 1;
                    /*     */
                    /*     */
                    /*  76 */
                    vo_8247_0.content = ("我乃天界星官 , 巡游至此，你一介凡人,怎可挡我去路?高于星官29级以上将无法获得奖励。盘还穷追不舍!\n" + "[我是路过的]".replace("\\", ""));
                    /*  77 */
                    vo_8247_0.secret_key = "";
                    /*  78 */
                    vo_8247_0.name = ((Vo_65529_0) GameLine.gameShuaGuai.shuaXing.get(i)).name;
                    /*  79 */
                    vo_8247_0.attrib = 0;
                    /*  80 */
                    GameObjectChar.send(new M8247_0(), vo_8247_0);
                    /*  81 */
                    return;
                    /*     */
                }
                /*     */
            }
            /*     */
        }
        /*     */
        /*     */
        /*     */
        /*     */
        /*  89 */
        for (int i = 0; i < chara.npcxuanshang.size(); i++) {
            /*  90 */
            if (id == ((Vo_65529_0) chara.npcxuanshang.get(i)).id) {
                /*  91 */
                Vo_8247_0 vo_8247_0 = new Vo_8247_0();
                /*  92 */
                vo_8247_0.id = ((Vo_65529_0) chara.npcxuanshang.get(i)).id;
                /*  93 */
                vo_8247_0.portrait = ((Vo_65529_0) chara.npcxuanshang.get(i)).icon;
                /*  94 */
                vo_8247_0.pic_no = 1;
                /*     */
                /*     */
                /*     */
                /*  98 */
                vo_8247_0.content = ("那天杀的仙界臭捕,爷爷逃到凡人的地\n盘还穷追不舍!\n[追拿通缉犯]\n" + "[离开]".replace("\\", ""));
                /*  99 */
                vo_8247_0.secret_key = "";
                /* 100 */
                vo_8247_0.name = ((Vo_65529_0) chara.npcxuanshang.get(i)).name;
                /* 101 */
                vo_8247_0.attrib = 0;
                /* 102 */
                GameObjectChar.send(new M8247_0(), vo_8247_0);
                /* 103 */
                return;
                /*     */
            }
            /*     */
        }
        /*     */
        /* 107 */
        for (int i = 0; i < chara.npcchubao.size(); i++) {
            /* 108 */
            if (id == ((Vo_65529_0) chara.npcchubao.get(i)).id) {
                /* 109 */
                Vo_8247_0 vo_8247_0 = new Vo_8247_0();
                /* 110 */
                vo_8247_0.id = ((Vo_65529_0) chara.npcchubao.get(i)).id;
                /* 111 */
                vo_8247_0.portrait = ((Vo_65529_0) chara.npcchubao.get(i)).icon;
                /* 112 */
                vo_8247_0.pic_no = 1;
                /*     */
                /*     */
                /* 115 */
                vo_8247_0.content = ("想抓我得先问问我手中的家伙答不答应。\n[就是来抓你的]\n" + "[我先准备准备]".replace("\\", ""));
                /* 116 */
                vo_8247_0.secret_key = "";
                /* 117 */
                vo_8247_0.name = ((Vo_65529_0) chara.npcchubao.get(i)).name;
                /* 118 */
                vo_8247_0.attrib = 0;
                /* 119 */
                GameObjectChar.send(new M8247_0(), vo_8247_0);
                /* 120 */
                return;
                /*     */
            }
            /*     */
        }

        /*     */
        /* 124 */
        for (int i = 0; i < chara.npcshuadao.size(); i++) {
            /* 125 */
            if (id == ((Vo_65529_0) chara.npcshuadao.get(i)).id) {
                /* 126 */
                Vo_8247_0 vo_8247_0 = new Vo_8247_0();
                /* 127 */
                vo_8247_0.id = ((Vo_65529_0) chara.npcshuadao.get(i)).id;
                /* 128 */
                vo_8247_0.portrait = ((Vo_65529_0) chara.npcshuadao.get(i)).icon;
                /* 129 */
                vo_8247_0.pic_no = 1;
                /*     */
                /*     */
                /* 132 */
                vo_8247_0.content = ("哈哈，送上们的肥肉。\n[今天我要为民除害]\n" + "[我先准备准备]".replace("\\", ""));
                /* 133 */
                vo_8247_0.secret_key = "";
                /* 134 */
                vo_8247_0.name = ((Vo_65529_0) chara.npcshuadao.get(i)).name;
                /* 135 */
                vo_8247_0.attrib = 0;
                /* 136 */
                GameObjectChar.send(new M8247_0(), vo_8247_0);
                /* 137 */
                return;
                /*     */
            }
            /*     */
        }
        /*     */

        /*     */
        /* 142 */
        Npc npc = GameData.that.baseNpcService.findById(id);
        /* 143 */
        if (npc == null) {
            /* 144 */
            return;
            /*     */
        }

        /* 146 */
        List<NpcDialogueFrame> npcDialogueFrameList = GameData.that.baseNpcDialogueFrameService.findByName(npc.getName());
        /* 147 */
        String content = "找我有什么事吗？[离开\\/离开]";

        /* 148 */
        if (npcDialogueFrameList.size() != 0) {
            /* 149 */
            content = ((NpcDialogueFrame) npcDialogueFrameList.get(0)).getUncontent();
            /*     */
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

        /* 151 */
        if (npc.getName().equals(chara.npcName)) {
            /* 152 */
            content = "[【师门】入世/sm-002_s1]" + content;
            /*     */
        }
        if (npc.getName().equals(chara.xiuxingNpcname)) {
            /* 152 */
            content = "[【十绝阵】讨教/十绝阵_s1]" + content;
            /*     */
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
        /* 156 */
        if ((renwu != null) && (renwu.getNpcName() != null)) {
            /* 157 */
            if (npc.getName().equals(renwu.getNpcName())) {
                /* 158 */
                content = renwu.getUncontent() + content;
                /*     */
            }
            /* 160 */
            if (chara.current_task.equals("主线—浮生若梦_s22")) {
                /* 161 */
                String[] split = renwu.getNpcName().split("\\_");
                /* 162 */
                String name = split[(chara.menpai - 1)];
                /* 163 */
                if (name.equals(npc.getName())) {
                    /* 164 */
                    content = renwu.getUncontent() + content;
                    /*     */
                }
                /*     */
            }
            /*     */
        }
        /* 168 */
        if (id == 978) {
            /* 169 */
            for (int i = 0; i < chara.pets.size(); i++) {
                /* 170 */
                content = "[销毁#R" + ((PetShuXing) ((Petbeibao) chara.pets.get(i)).petShuXing.get(0)).str + "#n\\/" + ((Petbeibao) chara.pets.get(i)).id + "]" + content;
                /*     */
            }
            /*     */
        }
        /* 173 */
        if ((id == 928) && (chara.fabaorenwu == 1)) {
            /* 174 */
            content = "[【领取法宝】提交#R蟠螭结、雪魂丝链#n]" + content;
            /*     */
        }
        /*     */
        /*     */
        /*     */
        /* 179 */
        Vo_8247_0 vo_8247_0 = GameUtil.a8247(npc, content);
        /* 180 */
        GameObjectChar.send(new M8247_0(), vo_8247_0);
        /*     */
    }

    /*     */
    /*     */
    public int cmd()
    /*     */ {
        /* 185 */
        return 4150;
        /*     */
    }
    /*     */
}


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C4150_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */