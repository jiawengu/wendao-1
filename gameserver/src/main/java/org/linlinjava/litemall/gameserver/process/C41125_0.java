/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.ArrayList;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20568_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M20568_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M53741_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.domain.Duiyuan;
/*    */ import org.linlinjava.litemall.gameserver.domain.LieBiao;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C41125_0 implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 24 */     String ask_type = GameReadTool.readString(buff);
/* 25 */     GameObjectChar session = GameObjectChar.getGameObjectChar();
/* 26 */     if (ask_type.equals("invite_join"))
/*    */     {
/* 28 */       List<LieBiao> lieBiaoList = new ArrayList();
/*    */       
/* 30 */       if (GameObjectChar.getGameObjectChar().gameTeam != null) {
/* 31 */         for (int i = 0; i < GameObjectChar.getGameObjectChar().gameTeam.liebiao.size(); i++) {
/* 32 */           LieBiao lieBiao = new LieBiao();
/* 33 */           lieBiao.ask_type = "invite_join";
/* 34 */           lieBiao.peer_name = ((Chara)((List)GameObjectChar.getGameObjectChar().gameTeam.liebiao.get(i)).get(0)).name;
/* 35 */           Duiyuan duiyuan = new Duiyuan();
/* 36 */           Chara chara = (Chara)((List)GameObjectChar.getGameObjectChar().gameTeam.liebiao.get(i)).get(0);
/* 37 */           duiyuan.org_icon = chara.waiguan;
/* 38 */           duiyuan.iid_str = chara.uuid;
/* 39 */           duiyuan.str = chara.name;
/* 40 */           duiyuan.skill = chara.level;
/* 41 */           duiyuan.master = chara.sex;
/* 42 */           duiyuan.metal = chara.menpai;
/* 43 */           duiyuan.req_str = "";
/* 44 */           duiyuan.passive_mode = chara.waiguan;
/* 45 */           duiyuan.party_contrib = "";
/* 46 */           duiyuan.mapteamMembersCount = 1;
/* 47 */           duiyuan.mapcomeback_flag = 0;
/* 48 */           lieBiao.duiyuanList.add(duiyuan);
/*    */           
/* 50 */           lieBiaoList.add(lieBiao);
/*    */         }
/* 52 */         GameObjectChar.send(new M53741_0(), lieBiaoList);
/*    */       }
/*    */     }
/*    */     
/* 56 */     if (ask_type.equals("request_join")) {
/* 57 */       GameUtil.a4121(GameObjectChar.getGameObjectChar().gameTeam.zhanliduiyuan);
/* 58 */       Vo_20568_0 vo_20568_0 = new Vo_20568_0();
/* 59 */       vo_20568_0.gid = "";
/* 60 */       GameObjectChar.send(new M20568_0(), vo_20568_0);
/*    */       
/* 62 */       List<LieBiao> lieBiaoList = new ArrayList();
/*    */       
/* 64 */       if (GameObjectChar.getGameObjectChar().gameTeam != null) {
/* 65 */         for (int i = 0; i < GameObjectChar.getGameObjectChar().gameTeam.liebiao.size(); i++) {
/* 66 */           LieBiao lieBiao = new LieBiao();
/* 67 */           lieBiao.ask_type = "request_join";
/* 68 */           lieBiao.peer_name = ((Chara)((List)GameObjectChar.getGameObjectChar().gameTeam.liebiao.get(i)).get(0)).name;
/* 69 */           for (int j = 0; j < ((List)GameObjectChar.getGameObjectChar().gameTeam.liebiao.get(i)).size(); j++) {
/* 70 */             Duiyuan duiyuan = new Duiyuan();
/* 71 */             Chara chara = (Chara)((List)GameObjectChar.getGameObjectChar().gameTeam.liebiao.get(i)).get(j);
/* 72 */             duiyuan.org_icon = chara.waiguan;
/* 73 */             duiyuan.iid_str = chara.uuid;
/* 74 */             duiyuan.str = chara.name;
/* 75 */             duiyuan.skill = chara.level;
/* 76 */             duiyuan.master = chara.sex;
/* 77 */             duiyuan.metal = chara.menpai;
/* 78 */             duiyuan.req_str = "";
/* 79 */             duiyuan.passive_mode = chara.waiguan;
/* 80 */             duiyuan.party_contrib = "";
/* 81 */             duiyuan.mapteamMembersCount = 1;
/* 82 */             duiyuan.mapcomeback_flag = 0;
/* 83 */             lieBiao.duiyuanList.add(duiyuan);
/*    */           }
/* 85 */           lieBiaoList.add(lieBiao);
/*    */         }
/* 87 */         GameObjectChar.send(new M53741_0(), lieBiaoList);
/*    */       }
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 95 */     return 41125;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C41125_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */