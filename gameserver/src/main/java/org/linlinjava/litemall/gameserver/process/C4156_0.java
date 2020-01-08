/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */

import org.linlinjava.litemall.db.domain.Characters;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.vo.*;
import org.linlinjava.litemall.gameserver.data.write.*;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.GameParty;
import org.linlinjava.litemall.gameserver.game.*;

import java.util.ArrayList;
import java.util.List;

/*     */ //CMD_REQUEST_JOIN
/*     */ @org.springframework.stereotype.Service
/*     */ public class C4156_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*     */ {
/*     */   public void process(io.netty.channel.ChannelHandlerContext ctx, io.netty.buffer.ByteBuf buff)
/*     */   {
/*  28 */     String peer_name = GameReadTool.readString(buff);
/*     */     
/*  30 */     int id = GameReadTool.readInt(buff);
/*     */     
/*  32 */     String ask_type = GameReadTool.readString(buff);
              System.out.println("CMD_REQUEST_JOIN:" + peer_name + ":" + id + ":" + ask_type);

              if(ask_type.compareTo("party_remote") == 0){
                  this.joinParty(peer_name, id, ask_type);
                  return;
              }
/*     */     
/*  34 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*     */     
/*  36 */     GameObjectChar session = GameObjectChar.getGameObjectChar();
/*     */     
/*  38 */     Characters characters = GameData.that.characterService.findOneByName(peer_name);
/*  39 */     String data = characters.getData();
/*  40 */     Chara chara1 = (Chara)org.linlinjava.litemall.db.util.JSONUtils.parseObject(data, Chara.class);
/*     */     
/*  42 */     GameObjectChar session1 = GameObjectCharMng.getGameObjectChar(chara1.id);
/*     */     
/*  44 */     if ("request_team_leader".equals(ask_type)) {
/*  45 */       List<Vo_61545_0> vo_61545_0List = GameUtil.a61545(chara1);
/*  46 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61545_0(), vo_61545_0List);
/*  47 */       org.linlinjava.litemall.gameserver.data.vo.Vo_24505_0 vo_24505_0 = GameUtil.MSG_FRIEND_UPDATE_PARTIAL(chara1);
/*  48 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M24505_0(), vo_24505_0);
/*  49 */       Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/*  50 */       vo_8165_0.msg = "你的申请已发送";
/*  51 */       vo_8165_0.active = 0;
/*  52 */       GameObjectChar.send(new M8165_0(), vo_8165_0);
/*     */       
/*     */ 
/*  55 */       Vo_20467_0 vo_20467_1 = new Vo_20467_0();
/*  56 */       vo_20467_1.caption = "";
/*  57 */       vo_20467_1.content = "";
/*  58 */       vo_20467_1.peer_name = peer_name;
/*  59 */       vo_20467_1.ask_type = "request_team_leader";
/*  60 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M20467_0(), vo_20467_1);
/*  61 */       Vo_45240_0 vo_45240_0 = new Vo_45240_0();
/*  62 */       vo_45240_0.tips = (peer_name + "申请成为队长，是否同意？");
/*  63 */       vo_45240_0.down_count = 30;
/*  64 */       vo_45240_0.only_confirm = 0;
/*  65 */       vo_45240_0.confirm_type = "reject_count_down";
/*  66 */       vo_45240_0.confirmText = "";
/*  67 */       vo_45240_0.cancelText = "";
/*  68 */       vo_45240_0.show_dlg_mode = 3;
/*  69 */       vo_45240_0.countDownTips = "";
/*  70 */       vo_45240_0.para_str = "{}";
/*  71 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new org.linlinjava.litemall.gameserver.data.write.M45240_0(), vo_45240_0);
/*  72 */       GameObjectCharMng.getGameObjectChar(chara1.id).upduizhangid = chara.id;
/*     */     }
/*     */     
/*  75 */     if (ask_type.equals("request_join"))
/*     */     {
/*  77 */       if (GameObjectCharMng.getGameObjectChar(id).gameTeam != null) {
/*  78 */         Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/*  79 */         vo_8165_0.msg = "你已发出申请，请耐心等待";
/*  80 */         vo_8165_0.active = 0;
/*  81 */         GameObjectChar.send(new M8165_0(), vo_8165_0);
/*  82 */         Boolean has = Boolean.valueOf(false);
/*     */         
/*  84 */         for (int i = 0; i < GameObjectCharMng.getGameObjectChar(id).gameTeam.liebiao.size(); i++) {
/*  85 */           for (int j = 0; j < ((List)GameObjectCharMng.getGameObjectChar(id).gameTeam.liebiao.get(i)).size(); j++) {
/*  86 */             if (((Chara)((List)GameObjectCharMng.getGameObjectChar(id).gameTeam.liebiao.get(i)).get(j)).id == chara.id) {
/*  87 */               has = Boolean.valueOf(true);
/*     */             }
/*     */           }
/*     */         }
/*     */         
/*  92 */         if (!has.booleanValue())
/*     */         {
/*  94 */           List<Chara> list = new java.util.ArrayList();
/*  95 */           list.add(chara);
/*     */           
/*  97 */           GameObjectCharMng.getGameObjectChar(id).gameTeam.liebiao.add(list);
/*     */         }
/*     */         
/*     */ 
/* 101 */         Vo_20467_0 vo_20467_0 = new Vo_20467_0();
/* 102 */         vo_20467_0.caption = "";
/* 103 */         vo_20467_0.content = "";
/*     */         
/* 105 */         vo_20467_0.peer_name = chara.name;
/* 106 */         vo_20467_0.ask_type = "invite_join";
/* 107 */         vo_20467_0.org_icon = chara.waiguan;
/* 108 */         vo_20467_0.iid_str = chara.uuid;
/* 109 */         vo_20467_0.skill = chara.level;
/* 110 */         vo_20467_0.str = chara.name;
/* 111 */         vo_20467_0.master = chara.sex;
/* 112 */         vo_20467_0.metal = chara.menpai;
/* 113 */         vo_20467_0.req_str = "";
/* 114 */         vo_20467_0.passive_mode = chara.waiguan;
/*     */         
/* 116 */         vo_20467_0.party_contrib = "";
/* 117 */         vo_20467_0.teamMembersCount = 1;
/* 118 */         vo_20467_0.comeback_flag = 0;
/* 119 */         GameObjectCharMng.getGameObjectChar(id).sendOne(new M20467_0(), vo_20467_0);
/* 120 */         vo_8165_0 = new Vo_8165_0();
/* 121 */         vo_8165_0.msg = "有人申请组队，请查看";
/* 122 */         vo_8165_0.active = 0;
/* 123 */         GameObjectCharMng.getGameObjectChar(id).sendOne(new M8165_0(), vo_8165_0);
/* 124 */         return;
/*     */       }
/*     */       
/* 127 */       Vo_61593_0 vo_61593_0 = new Vo_61593_0();
/* 128 */       vo_61593_0.ask_type = "invite_join";
/* 129 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61593_0(), vo_61593_0);
/*     */       
/*     */ 
/* 132 */       Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/* 133 */       vo_61671_0.id = chara.id;
/* 134 */       vo_61671_0.count = 2;
/* 135 */       vo_61671_0.list.add(Integer.valueOf(2));
/* 136 */       vo_61671_0.list.add(Integer.valueOf(3));
/* 137 */       GameObjectChar.getGameObjectChar().gameMap.send(new MSG_TITLE(), vo_61671_0);
/*     */       
/*     */ 
/* 140 */       GameTeam gameTeam = new GameTeam();
/* 141 */       gameTeam.duiwu.add(chara);
/* 142 */       gameTeam.zhanliduiyuan.add(GameUtil.add4121(chara, 1));
/* 143 */       GameObjectChar.getGameObjectChar().creator(gameTeam);
/* 144 */       List<Chara> duiwu = GameObjectChar.getGameObjectChar().gameTeam.duiwu;
/* 145 */       GameUtil.a4119(duiwu);
/* 146 */       GameUtil.a4121(GameObjectChar.getGameObjectChar().gameTeam.zhanliduiyuan);
/* 147 */       Vo_20568_0 vo_20568_0 = new Vo_20568_0();
/* 148 */       vo_20568_0.gid = "";
/* 149 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M20568_0(), vo_20568_0);
/*     */       
/*     */ 
/* 152 */       Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/* 153 */       vo_20480_0.msg = "你组建了一支队伍。";
/* 154 */       vo_20480_0.time = 1562593376;
/* 155 */       GameObjectChar.send(new M20480_0(), vo_20480_0);
/*     */     }
/* 157 */     if ("invite_join".equals(ask_type))
/*     */     {
/*     */ 
/* 160 */       if (GameObjectChar.getGameObjectChar().gameTeam == null) {
/* 161 */         Vo_61593_0 vo_61593_0 = new Vo_61593_0();
/* 162 */         vo_61593_0.ask_type = "invite_join";
/* 163 */         GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61593_0(), vo_61593_0);
/*     */         
/*     */ 
/* 166 */         Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/* 167 */         vo_61671_0.id = chara.id;
/* 168 */         vo_61671_0.count = 2;
/* 169 */         vo_61671_0.list.add(Integer.valueOf(2));
/* 170 */         vo_61671_0.list.add(Integer.valueOf(3));
/* 171 */         GameObjectChar.getGameObjectChar().gameMap.send(new MSG_TITLE(), vo_61671_0);
/*     */         
/*     */ 
/* 174 */         GameTeam gameTeam = new GameTeam();
/* 175 */         gameTeam.duiwu.add(chara);
/* 176 */         gameTeam.zhanliduiyuan.add(GameUtil.add4121(chara, 1));
/* 177 */         GameObjectChar.getGameObjectChar().creator(gameTeam);
/* 178 */         List<Chara> duiwu = GameObjectChar.getGameObjectChar().gameTeam.duiwu;
/* 179 */         GameUtil.a4119(duiwu);
/* 180 */         GameUtil.a4121(GameObjectChar.getGameObjectChar().gameTeam.zhanliduiyuan);
/* 181 */         Vo_20568_0 vo_20568_0 = new Vo_20568_0();
/* 182 */         vo_20568_0.gid = "";
/* 183 */         GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M20568_0(), vo_20568_0);
/*     */         
/*     */ 
/* 186 */         Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/* 187 */         vo_20480_0.msg = "你组建了一支队伍。";
/* 188 */         vo_20480_0.time = 1562593376;
/* 189 */         GameObjectChar.send(new M20480_0(), vo_20480_0);
/*     */       }
/* 191 */       else if (GameObjectChar.getGameObjectChar().gameTeam.duiwu.size() >= 5) {
/* 192 */         return;
/*     */       }
/*     */       
/*     */ 
/*     */ 
/* 197 */       List<Vo_61545_0> vo_61545_0List = GameUtil.a61545(chara1);
/* 198 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61545_0(), vo_61545_0List);
/*     */       
/*     */ 
/* 201 */       Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/* 202 */       vo_8165_0.msg = "你已发出邀请，请耐心等待";
/* 203 */       vo_8165_0.active = 0;
/* 204 */       GameObjectChar.send(new M8165_0(), vo_8165_0);
/*     */       
/*     */ 
/* 207 */       GameUtil.a20467(chara, id, ask_type);
/*     */       
/*     */ 
/* 210 */       vo_8165_0.msg = ("" + chara.name + "邀请你加入其队伍，请打开队伍界面查看邀请信息。");
/* 211 */       vo_8165_0.active = 0;
/* 212 */       GameObjectCharMng.getGameObjectChar(id).sendOne(new M8165_0(), vo_8165_0);
/*     */     }
/*     */   }
/*     */   
/*     */ 
/*     */
            private void joinParty(String name, int id, String ask_type){
                GameParty party = GameCore.that.partyMgr.checkExist(name);
                if(party == null) { return; }
                Chara chara = GameObjectChar.getGameObjectChar().chara;
                if(chara.partyId > 0){ return; }
                party.requestJoin(chara);

                party.members.forEach((id_, m)->{
                    GameObjectChar c = GameObjectCharMng.getGameObjectChar(id_);
                    if(c != null){
                        Vo_MSG_DIALOG vo = new Vo_MSG_DIALOG();
                        vo.ask_type = "party";
                        vo.list = new ArrayList<>();
                        Vo_MSG_DIALOG_item item = new Vo_MSG_DIALOG_item();
                        item.bf_list.add(Vo_BuildField.stringc(1, chara.name)); //name
                        item.bf_list.add(Vo_BuildField.int32(31, chara.level)); //level
                        item.bf_list.add(Vo_BuildField.int32(44, chara.polar_point)); //polar
                        item.bf_list.add(Vo_BuildField.int32(20, 0)); //tao
                        item.bf_list.add(Vo_BuildField.int32(29, chara.gender)); //gender
                        vo.list.add(item);
                        c.sendOne(new M_MSG_DIALOG(), vo);
                    }
                });
            }
/*     */ 
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 222 */     return 4156;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C4156_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */