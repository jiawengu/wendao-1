/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import java.util.List;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20568_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61591_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61593_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.*;
/*     */
/*     */
/*     */
/*     */
/*     */
/*     */
/*     */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
/*     */ import org.linlinjava.litemall.gameserver.game.GameTeam;
/*     */ 
/*     */ @org.springframework.stereotype.Service
/*     */ public class C4132_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*     */ {
/*     */   public void process(io.netty.channel.ChannelHandlerContext ctx, io.netty.buffer.ByteBuf buff)
/*     */   {
/*  26 */     String peer_name = org.linlinjava.litemall.gameserver.data.GameReadTool.readString(buff);
/*     */     
/*  28 */     String ask_type = org.linlinjava.litemall.gameserver.data.GameReadTool.readString(buff);
/*  29 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*  30 */     org.linlinjava.litemall.db.domain.Characters characters = org.linlinjava.litemall.gameserver.game.GameData.that.characterService.findOneByName(peer_name);
/*  31 */     String data = characters.getData();
/*  32 */     Chara chara1 = (Chara)org.linlinjava.litemall.db.util.JSONUtils.parseObject(data, Chara.class);
/*  33 */     if (GameObjectChar.getGameObjectChar().gameTeam.duiwu.size() >= 5) {
/*  34 */       return;
/*     */     }
/*  36 */     if ("request_join".equals(ask_type))
/*     */     {
/*  38 */       if ((GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam != null) && 
/*  39 */         (GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu != null)) {
/*  40 */         org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0 vo_20481_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0();
/*  41 */         vo_20481_0.msg = ("#Y#<" + peer_name + "#>#n已有队伍");
/*  42 */         vo_20481_0.time = 1562987118;
/*  43 */         GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*  44 */         return;
/*     */       }
/*     */       
/*     */ 
/*  48 */       List<org.linlinjava.litemall.gameserver.data.vo.Vo_61545_0> vo_61545_0List = GameUtil.a61545(chara1);
/*  49 */       GameObjectChar.send(new M61545_0(), vo_61545_0List);
/*     */       
/*  51 */       org.linlinjava.litemall.gameserver.data.vo.Vo_24505_0 vo_24505_0 = GameUtil.MSG_FRIEND_UPDATE_PARTIAL(chara1);
/*  52 */       GameObjectChar.send(new M24505_0(), vo_24505_0);
/*     */       
/*     */ 
/*  55 */       Vo_61591_0 vo_61591_0 = new Vo_61591_0();
/*  56 */       vo_61591_0.ask_type = ask_type;
/*  57 */       vo_61591_0.name = peer_name;
/*  58 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61591_0(), vo_61591_0);
/*     */       
/*  60 */       Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/*  61 */       vo_20480_0.msg = ("#Y#<" + peer_name + "#>#n加入你的的队伍");
/*  62 */       vo_20480_0.time = 1562593376;
/*  63 */       GameObjectChar.send(new M20480_0(), vo_20480_0);
/*     */       
/*  65 */       Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/*  66 */       vo_61671_0.id = chara1.id;
/*  67 */       vo_61671_0.count = 2;
/*  68 */       vo_61671_0.list.add(Integer.valueOf(2));
/*  69 */       vo_61671_0.list.add(Integer.valueOf(5));
/*  70 */       GameObjectChar.send(new MSG_TITLE(), vo_61671_0);
/*     */       
/*  72 */       vo_61545_0List = GameUtil.a61545(chara1);
/*  73 */       GameObjectChar.send(new M61545_0(), vo_61545_0List);
/*     */       
/*  75 */       vo_24505_0 = GameUtil.MSG_FRIEND_UPDATE_PARTIAL(chara1);
/*  76 */       GameObjectChar.send(new M24505_0(), vo_24505_0);
/*     */       
/*  78 */       org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0 vo_65529_0 = GameUtil.MSG_APPEAR(chara1);
/*  79 */       GameObjectChar.send(new MSG_APPEAR(), vo_65529_0);
/*     */       
/*     */ 
/*     */ 
/*  83 */       Vo_61593_0 vo_61593_0 = new Vo_61593_0();
/*  84 */       vo_61593_0.ask_type = "invite_join";
/*  85 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M61593_0(), vo_61593_0);
/*     */       
/*  87 */       vo_20480_0 = new Vo_20480_0();
/*  88 */       vo_20480_0.msg = ("你加入#Y#<" + chara.name + "#>#n的队伍");
/*  89 */       vo_20480_0.time = 1562593376;
/*  90 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M20480_0(), vo_20480_0);
/*     */       
/*  92 */       vo_61671_0 = new Vo_61671_0();
/*  93 */       vo_61671_0.id = chara1.id;
/*  94 */       vo_61671_0.count = 2;
/*  95 */       vo_61671_0.list.add(Integer.valueOf(2));
/*  96 */       vo_61671_0.list.add(Integer.valueOf(5));
/*  97 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_TITLE(), vo_61671_0);
/*  98 */       vo_61671_0 = new Vo_61671_0();
/*  99 */       vo_61671_0.id = chara1.id;
/* 100 */       vo_61671_0.count = 2;
/* 101 */       vo_61671_0.list.add(Integer.valueOf(2));
/* 102 */       vo_61671_0.list.add(Integer.valueOf(4));
/* 103 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_TITLE(), vo_61671_0);
/*     */       
/*     */ 
/* 106 */       vo_61545_0List = GameUtil.a61545(chara);
/* 107 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M61545_0(), vo_61545_0List);
/*     */       
/*     */ 
/* 110 */       vo_24505_0 = GameUtil.MSG_FRIEND_UPDATE_PARTIAL(chara);
/* 111 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M24505_0(), vo_24505_0);
/*     */       
/* 113 */       vo_65529_0 = GameUtil.MSG_APPEAR(chara);
/* 114 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_APPEAR(), vo_65529_0);
/*     */       
/* 116 */       vo_61671_0 = new Vo_61671_0();
/* 117 */       vo_61671_0.id = chara.id;
/* 118 */       vo_61671_0.count = 2;
/* 119 */       vo_61671_0.list.add(Integer.valueOf(2));
/* 120 */       vo_61671_0.list.add(Integer.valueOf(3));
/* 121 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_TITLE(), vo_61671_0);
/*     */       
/*     */ 
/* 124 */       GameObjectChar.getGameObjectChar().gameTeam.duiwu.add(chara1);
/* 125 */       GameObjectChar.getGameObjectChar().gameTeam.zhanliduiyuan.add(GameUtil.add4121(chara1, 1));
/* 126 */       GameObjectChar.getGameObjectChar().gameTeam.liebiao.remove(chara1);
/* 127 */       GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam = GameObjectChar.getGameObjectChar().gameTeam;
/* 128 */       GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.liebiao.clear();
/* 129 */       List<Chara> charas = GameObjectChar.getGameObjectChar().gameTeam.duiwu;
/* 130 */       GameUtil.a4119(charas);
/* 131 */       GameUtil.a4121(GameObjectChar.getGameObjectChar().gameTeam.zhanliduiyuan);
/*     */       
/* 133 */       Vo_20568_0 vo_20568_0 = new Vo_20568_0();
/* 134 */       vo_20568_0.gid = "";
/* 135 */       GameObjectChar.send(new M20568_0(), vo_20568_0);
/*     */       
/* 137 */       org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0 vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE(chara);
/* 138 */       GameObjectChar.send(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/*     */       
/* 140 */       vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE(chara1);
/* 141 */       GameObjectChar.send(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/*     */       
/* 143 */       org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0 vo_8165_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0();
/* 144 */       vo_8165_0.msg = (peer_name + "加入队伍");
/* 145 */       vo_8165_0.active = 0;
/* 146 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M8165_0(), vo_8165_0);
/*     */       
/*     */ 
/* 149 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M20568_0(), vo_20568_0);
/*     */       
/*     */ 
/* 152 */       vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE(chara1);
/* 153 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/* 154 */       vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE(chara);
/* 155 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/*     */       
/*     */ 
/* 158 */       vo_61593_0 = new Vo_61593_0();
/* 159 */       vo_61593_0.ask_type = "invite_join";
/* 160 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new M61593_0(), vo_61593_0);
/*     */       
/*     */ 
/* 163 */       vo_61671_0 = new Vo_61671_0();
/* 164 */       vo_61671_0.id = chara1.id;
/* 165 */       vo_61671_0.count = 2;
/* 166 */       vo_61671_0.list.add(Integer.valueOf(2));
/* 167 */       vo_61671_0.list.add(Integer.valueOf(5));
/* 168 */       GameObjectChar.send(new MSG_TITLE(), vo_61671_0);
/*     */       
/*     */ 
/* 171 */       vo_61671_0 = new Vo_61671_0();
/* 172 */       vo_61671_0.id = chara1.id;
/* 173 */       vo_61671_0.count = 2;
/* 174 */       vo_61671_0.list.add(Integer.valueOf(2));
/* 175 */       vo_61671_0.list.add(Integer.valueOf(5));
/* 176 */       GameObjectCharMng.getGameObjectChar(chara1.id).sendOne(new MSG_TITLE(), vo_61671_0);
/*     */     }
/*     */     else
/*     */     {
/* 180 */       if (GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam == null) {
/* 181 */         GameObjectChar.getGameObjectChar().gameTeam.duiwu = null;
/* 182 */         Vo_61593_0 vo_61593_0 = new Vo_61593_0();
/* 183 */         vo_61593_0.ask_type = ask_type;
/* 184 */         GameObjectChar.send(new M61593_0(), vo_61593_0);
/* 185 */         Vo_20568_0 vo_20568_0 = new Vo_20568_0();
/* 186 */         vo_20568_0.gid = "";
/* 187 */         GameObjectChar.send(new M20568_0(), vo_20568_0);
/*     */         
/* 189 */         return;
/*     */       }
/* 191 */       List<org.linlinjava.litemall.gameserver.data.vo.Vo_61545_0> vo_61545_0List = GameUtil.a61545(chara);
/* 192 */       GameObjectChar.send(new M61545_0(), vo_61545_0List);
/*     */       
/* 194 */       GameUtil.MSG_FRIEND_UPDATE_PARTIAL(chara1);
/*     */       
/* 196 */       Vo_61591_0 vo_61591_0 = new Vo_61591_0();
/* 197 */       vo_61591_0.ask_type = ask_type;
/* 198 */       vo_61591_0.name = peer_name;
/* 199 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61591_0(), vo_61591_0);
/*     */       
/* 201 */       Vo_61593_0 vo_61593_0 = new Vo_61593_0();
/* 202 */       vo_61593_0.ask_type = ask_type;
/* 203 */       GameObjectChar.send(new M61593_0(), vo_61593_0);
/*     */       
/* 205 */       Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/* 206 */       vo_20480_0.msg = ("你加入#Y#<" + peer_name + "#>#n的队伍");
/* 207 */       vo_20480_0.time = 1562593376;
/* 208 */       GameObjectChar.send(new M20480_0(), vo_20480_0);
/*     */       
/* 210 */       Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/* 211 */       vo_61671_0.id = chara.id;
/* 212 */       vo_61671_0.count = 2;
/* 213 */       vo_61671_0.list.add(Integer.valueOf(2));
/* 214 */       vo_61671_0.list.add(Integer.valueOf(5));
/* 215 */       GameObjectChar.send(new MSG_TITLE(), vo_61671_0);
/*     */       
/* 217 */       org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0 vo_65529_0 = GameUtil.MSG_APPEAR(chara);
/* 218 */       GameObjectChar.send(new MSG_APPEAR(), vo_65529_0);
/*     */       
/* 220 */       vo_61671_0 = new Vo_61671_0();
/* 221 */       vo_61671_0.id = chara1.id;
/* 222 */       vo_61671_0.count = 2;
/* 223 */       vo_61671_0.list.add(Integer.valueOf(2));
/* 224 */       vo_61671_0.list.add(Integer.valueOf(3));
/* 225 */       GameObjectChar.send(new MSG_TITLE(), vo_61671_0);
/*     */       
/* 227 */       GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu.add(chara);
/* 228 */       GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.zhanliduiyuan.add(GameUtil.add4121(chara, 1));
/* 229 */       GameObjectChar.getGameObjectChar().gameTeam = GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam;
/* 230 */       GameTeam gameTeam = GameObjectChar.getGameObjectChar().gameTeam;
/* 231 */       GameObjectChar.getGameObjectChar().gameTeam.liebiao.clear();
/* 232 */       List<Chara> charas = GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.duiwu;
/* 233 */       GameUtil.a4119(charas);
/* 234 */       GameUtil.a4121(GameObjectCharMng.getGameObjectChar(chara1.id).gameTeam.zhanliduiyuan);
/*     */       
/* 236 */       Vo_20568_0 vo_20568_0 = new Vo_20568_0();
/* 237 */       vo_20568_0.gid = "";
/* 238 */       GameObjectChar.send(new M20568_0(), vo_20568_0);
/*     */       
/*     */ 
/* 241 */       org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0 vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE(chara1);
/* 242 */       GameObjectChar.send(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/*     */     }
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 251 */     return 4132;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C4132_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */