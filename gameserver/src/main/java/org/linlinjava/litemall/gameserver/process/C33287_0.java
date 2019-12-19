/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.db.domain.Characters;
/*    */ import org.linlinjava.litemall.db.service.CharacterService;
/*    */ import org.linlinjava.litemall.db.util.JSONUtils;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_36871_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M36871_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.game.GameData;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
/*    */ import org.linlinjava.litemall.gameserver.game.GameTeam;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C33287_0 implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 24 */     String char_gid = GameReadTool.readString(buff);
/*    */     
/* 26 */     String dlg_type = GameReadTool.readString(buff);
/*    */     
/* 28 */     int offline = GameReadTool.readByte(buff);
/*    */     
/* 30 */     String para = GameReadTool.readString(buff);
/*    */     
/* 32 */     String user_dist = GameReadTool.readString(buff);
/*    */     
/*    */ 
/* 35 */     Characters characters = GameData.that.characterService.finOnByGiD(char_gid);
/* 36 */     String data = characters.getData();
/* 37 */     Chara chara = (Chara)JSONUtils.parseObject(data, Chara.class);
/*    */     
/*    */ 
/* 40 */     Vo_36871_0 vo_36871_0 = new Vo_36871_0();
/* 41 */     vo_36871_0.msg_type = "";
/* 42 */     vo_36871_0.icon = chara.waiguan;
/* 43 */     vo_36871_0.id = characters.getId().intValue();
/* 44 */     vo_36871_0.level = chara.level;
/* 45 */     vo_36871_0.gid = char_gid;
/* 46 */     vo_36871_0.name = chara.name;
/* 47 */     vo_36871_0.party = "";
/* 48 */     vo_36871_0.friend_score = 0;
/* 49 */     vo_36871_0.setting_flag = 363017012;
/* 50 */     if (GameObjectCharMng.getGameObjectChar(chara.id) == null) {
/* 51 */       return;
/*    */     }
/* 53 */     if (GameObjectCharMng.getGameObjectChar(chara.id).gameTeam != null) {
/* 54 */       if (GameObjectCharMng.getGameObjectChar(chara.id).gameTeam.duiwu != null) {
/* 55 */         vo_36871_0.char_status = 3;
/*    */       } else {
/* 57 */         vo_36871_0.char_status = 0;
/*    */       }
/*    */     } else {
/* 60 */       vo_36871_0.char_status = 0;
/*    */     }
/* 62 */     vo_36871_0.vip = 0;
/* 63 */     vo_36871_0.serverId = user_dist;
/* 64 */     vo_36871_0.account = "110001bph1cq2p";
/* 65 */     vo_36871_0.polar = 1;
/* 66 */     vo_36871_0.isInThereFrend = 0;
/* 67 */     vo_36871_0.ringScore = 0;
/* 68 */     vo_36871_0.comeback_flag = 0;
/* 69 */     GameObjectChar.send(new M36871_0(), vo_36871_0);
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 77 */     return 33287;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C33287_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */