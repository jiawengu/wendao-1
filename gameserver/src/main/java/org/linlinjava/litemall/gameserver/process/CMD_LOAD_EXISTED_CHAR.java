/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import java.util.LinkedList;
/*     */ import java.util.List;
/*     */ import org.linlinjava.litemall.db.domain.Characters;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41023_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_4163_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_4321_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_53521_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61553_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_9129_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.*;
/*     */
/*     */
import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*     */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*     */ import org.linlinjava.litemall.gameserver.domain.ShouHu;
/*     */ import org.linlinjava.litemall.gameserver.domain.ShouHuShuXing;
/*     */ import org.linlinjava.litemall.gameserver.game.GameCore;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */
/*     */

/**
 * CMD_LOAD_EXISTED_CHAR
 */
/*     */ @org.springframework.stereotype.Service
/*     */ public class CMD_LOAD_EXISTED_CHAR implements org.linlinjava.litemall.gameserver.GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, io.netty.buffer.ByteBuf buff)
/*     */   {
/*  33 */     String char_name = org.linlinjava.litemall.gameserver.data.GameReadTool.readString(buff);
/*  34 */     GameObjectChar session = GameObjectChar.getGameObjectChar();
/*     */     
/*  36 */     if (session.chara == null) {
/*  37 */       List<Characters> charactersList = GameData.that.characterService.findByAccountId(Integer.valueOf(session.accountid));
/*  38 */       Characters characters = null;
/*  39 */       for (Characters tcharacters : charactersList) {
/*  40 */         if (tcharacters.getName().equals(char_name)) {
/*  41 */           characters = tcharacters;
/*     */         }
/*     */       }
/*  44 */       if (characters == null) {
/*  45 */         ctx.disconnect();
/*  46 */         return;
/*     */       }
/*  48 */       GameObjectChar oldSession = org.linlinjava.litemall.gameserver.game.GameObjectCharMng.getGameObjectChar(characters.getId().intValue());
/*  49 */       if (oldSession != null) {
/*  50 */         characters = oldSession.characters;
/*  51 */         org.linlinjava.litemall.gameserver.game.GameObjectCharMng.save(oldSession);
/*     */       }
/*  53 */       session.init(characters);
/*     */     }
/*     */     
/*     */ 
/*  57 */     Chara chara = session.chara;
/*     */     
/*     */ 
/*     */ 
/*     */ 
/*  62 */     chara.uptime = System.currentTimeMillis();
/*  63 */     java.util.Date date = new java.util.Date(chara.updatetime);
/*  64 */     boolean isnow = GameUtil.isNow(date);//是否是今天
/*  65 */     if (!isnow) {
/*  66 */       chara.isGet = 0;
/*  67 */       chara.isCanSgin = 1;
/*  68 */       chara.online_time = 0L;
/*  69 */       chara.npcshuadao = new LinkedList();
/*     */       
/*  71 */       chara.shuadao = 1;
/*     */       
/*  73 */       chara.chubao = 1;
/*     */       
/*  75 */       chara.npcchubao = new LinkedList();
/*     */       
/*  77 */       chara.baibangmang = 0;
/*     */       
/*  79 */       chara.shimencishu = 1;
/*     */       
/*  81 */       chara.npcName = "";
/*     */       
/*  83 */       chara.fabaorenwu = 0;
/*     */       
/*  85 */       chara.xiuxingcishu = 1;
/*     */       
/*  87 */       chara.xiuxingNpcname = "";
/*     */       
/*  89 */       chara.xuanshangcishu = 0;
/*     */       
/*  91 */       chara.npcxuanshang = new LinkedList();
/*     */       
/*  93 */       chara.npcXuanShangName = "";
/*  94 */       for (int i = 0; i < chara.shenmiliwu.size(); i++) {
/*  95 */         ((Vo_41480_0)chara.shenmiliwu.get(i)).online_time = 0;
/*  96 */         ((Vo_41480_0)chara.shenmiliwu.get(i)).name = "";
/*  97 */         ((Vo_41480_0)chara.shenmiliwu.get(i)).brate = 0;
/*     */       }
/*     */     }
/*     */     
/*     */ 
/*     */ 
/* 103 */     org.linlinjava.litemall.gameserver.data.vo.Vo_45277_0 vo_45277_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_45277_0();
/* 104 */     vo_45277_0.server_type = 0;
/* 105 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M45277_0(), vo_45277_0);
/*     */     
/* 107 */     org.linlinjava.litemall.gameserver.data.vo.Vo_41009_0 vo_41009_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_41009_0();
/* 108 */     vo_41009_0.server_time = ((int)(System.currentTimeMillis() / 1000L));
/* 109 */     vo_41009_0.time_zone = 8;
/* 110 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M41009_0(), vo_41009_0);
/*     */     
/* 112 */     org.linlinjava.litemall.gameserver.data.vo.Vo_4099_0 vo_4099_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_4099_0();
/* 113 */     vo_4099_0.name = char_name;
/* 114 */     vo_4099_0.para = (char_name + "是第 7 次登录");
/* 115 */     vo_4099_0.gid = chara.uuid;
/* 116 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M4099_0(), vo_4099_0);
/*     */     
/*     */ 
/*     */ 
/* 120 */     org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/* 121 */     GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*     */     
/* 123 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M45388_0(), null);
/*     */     
/*     */ 
/* 126 */     GameUtil.a65511(chara);
/*     */
              GameUtilRenWu.notifyTTTTask(chara);
/*     */ 
/* 129 */     Vo_41023_0 vo_41023_0 = new Vo_41023_0();
/* 130 */     vo_41023_0.taskName = "拜师任务";
/* 131 */     vo_41023_0.status = 1;
/* 132 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M41023_0(), vo_41023_0);
/*     */     
/*     */ 
/* 135 */     for (int i = 0; i < chara.pets.size(); i++) {
/* 136 */       List list = new java.util.ArrayList();
/* 137 */       list.add(chara.pets.get(i));
/* 138 */       GameObjectChar.send(new MSG_UPDATE_PETS(), list);
/* 139 */       GameObjectChar.send(new MSG_REFRESH_PET_GODBOOK_SKILLS_0(), ((Petbeibao)chara.pets.get(i)).tianshu);
/* 140 */       boolean isfagong = ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).rank > ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).pet_mag_shape;
/* 141 */       GameUtil.dujineng(1, ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).metal, ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).skill, isfagong, ((Petbeibao)chara.pets.get(i)).id, chara);
/*     */     }
/*     */     
/*     */ 
/* 145 */     Vo_4163_0 vo_4163_0 = new Vo_4163_0();
/* 146 */     vo_4163_0.id = chara.chongwuchanzhanId;
/* 147 */     vo_4163_0.b = 1;
/* 148 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M4163_0(), vo_4163_0);
/*     */     
/*     */ 
/* 151 */     org.linlinjava.litemall.gameserver.data.vo.Vo_8425_0 vo_8425_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_8425_0();
/* 152 */     vo_8425_0.id = chara.zuoqiId;
/* 153 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M8425_0(), vo_8425_0);
/*     */     
/* 155 */     GameUtil.addVip(chara);
/*     */     
/*     */ 
/*     */ 
/* 159 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M41017_0(), null);
/*     */     
/*     */ 
/* 162 */     org.linlinjava.litemall.gameserver.data.vo.Vo_53399_0 vo_53399_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_53399_0();
/* 163 */     vo_53399_0.value = "10011011111";
/* 164 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M53399_0(), vo_53399_0);
/*     */     
/* 166 */     Vo_53521_0 vo_53521_0 = new Vo_53521_0();
/* 167 */     vo_53521_0.chushiLevel = 90;
/* 168 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M53521_0(), vo_53521_0);
/*     */     
/* 170 */     org.linlinjava.litemall.gameserver.data.vo.Vo_33055_0 vo_33055_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_33055_0();
/* 171 */     vo_33055_0.is_enable = 1;
/* 172 */     vo_33055_0.enable_gold_stall_cash = 0;
/* 173 */     vo_33055_0.sell_cash_aft_days = 7;
/* 174 */     vo_33055_0.start_gold_stall_cash = 0;
/* 175 */     vo_33055_0.enable_appoint = 0;
/* 176 */     vo_33055_0.enable_autcion = 0;
/* 177 */     vo_33055_0.close_time = 1536181200;
/* 178 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M33055_0(), vo_33055_0);
/*     */     
/*     */ 
/*     */ 
/*     */ 
/* 183 */     Vo_9129_0 vo_9129_0 = new Vo_9129_0();
/* 184 */     vo_9129_0.notify = 61001;
/* 185 */     vo_9129_0.para = "1";
/* 186 */     GameObjectChar.send(new M9129_0(), vo_9129_0);
/* 187 */     vo_9129_0 = new Vo_9129_0();
/* 188 */     vo_9129_0.notify = 50017;
/* 189 */     vo_9129_0.para = "0";
/* 190 */     GameObjectChar.send(new M9129_0(), vo_9129_0);
/*     */     
/*     */ 
/* 193 */     vo_9129_0 = new Vo_9129_0();
/* 194 */     vo_9129_0.notify = 20002;
/* 195 */     vo_9129_0.para = "0000FFFF060FFDFF";
/* 196 */     GameObjectChar.send(new M9129_0(), vo_9129_0);
/* 197 */     vo_9129_0 = new Vo_9129_0();
/* 198 */     vo_9129_0.notify = 39;
/* 199 */     vo_9129_0.para = "";
/* 200 */     GameObjectChar.send(new M9129_0(), vo_9129_0);
/* 201 */     vo_9129_0 = new Vo_9129_0();
/* 202 */     vo_9129_0.notify = 10012;
/* 203 */     vo_9129_0.para = "";
/* 204 */     GameObjectChar.send(new M9129_0(), vo_9129_0);
/*     */     
/* 206 */     vo_9129_0 = new Vo_9129_0();
/* 207 */     vo_9129_0.notify = 20010;
/* 208 */     vo_9129_0.para = String.valueOf(chara.qumoxiang);
/* 209 */     GameObjectChar.send(new M9129_0(), vo_9129_0);
/*     */     
/*     */ 
/*     */ 
/* 213 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M65525_0(), chara.backpack);
/*     */     
/*     */ 
/* 216 */     session.gameMap.join(session);
/*     */     
/*     */ 
/* 219 */     GameUtil.a65511(chara);
/*     */     
/*     */ 
/*     */ 
/* 223 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M12016_0(), chara.listshouhu);
/*     */     
/* 225 */     for (int i = 0; i < chara.listshouhu.size(); i++) {
/* 226 */       ShouHu shouHu = (ShouHu)chara.listshouhu.get(i);
/* 227 */       GameUtil.dujineng(2, ((ShouHuShuXing)shouHu.listShouHuShuXing.get(0)).metal, ((ShouHuShuXing)shouHu.listShouHuShuXing.get(0)).skill, true, shouHu.id, chara);
/*     */     }
/*     */     
/*     */ 
/*     */ 
/*     */ 
/* 233 */     org.linlinjava.litemall.gameserver.data.vo.Vo_36889_0 vo_36889_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_36889_0();
/* 234 */     vo_36889_0.count = 2;
/* 235 */     vo_36889_0.id = chara.id;
/* 236 */     vo_36889_0.auto_select = 1;
/* 237 */     vo_36889_0.multi_index = 0;
/* 238 */     vo_36889_0.action = 2;
/* 239 */     vo_36889_0.para = 0;
/* 240 */     vo_36889_0.multi_count = 0;
/* 241 */     GameObjectChar.send(new MSG_FIGHT_CMD_INFO(), vo_36889_0);
/*     */     
/*     */ 
/*     */ 
/* 245 */     GameUtil.a49159(chara);
/*     */     
/*     */ 
/*     */ 
/* 249 */     List<org.linlinjava.litemall.db.domain.SaleGood> saleGoodList = GameData.that.saleGoodService.findByOwnerUuid(chara.uuid);
/* 250 */     org.linlinjava.litemall.gameserver.data.vo.Vo_49179_0 vo_49179_0 = GameUtil.a49179(saleGoodList, chara);
/* 251 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M49179_0(), vo_49179_0);
/*     */     
/*     */ 
/* 254 */     org.linlinjava.litemall.gameserver.data.vo.Vo_12269_0 vo_12269_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_12269_0();
/* 255 */     vo_12269_0.id = chara.id;
/* 256 */     vo_12269_0.owner_id = 96780;
/* 257 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M12269_0(), vo_12269_0);
/*     */     
/*     */ 
/*     */ 
/* 261 */     org.linlinjava.litemall.gameserver.data.vo.Vo_61589_0 vo_61589_0 = GameUtil.a61589();
/* 262 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61589_0(), vo_61589_0);
/*     */     
/*     */ 
/*     */ 
/* 266 */     org.linlinjava.litemall.gameserver.data.vo.Vo_40965_0 vo_40965_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_40965_0();
/* 267 */     vo_40965_0.guideId = 3;
/* 268 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40965_0(), vo_40965_0);
/*     */     
/*     */ 
/* 271 */     org.linlinjava.litemall.db.domain.Renwu tasks = GameData.that.baseRenwuService.findOneByCurrentTask(chara.current_task);
/* 272 */     Vo_61553_0 vo_61553_0 = GameUtil.a61553(tasks, chara);
/* 273 */     GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_0);
/*     */     
/*     */ 
/* 276 */     org.linlinjava.litemall.gameserver.data.vo.Vo_53925_0 vo_53925_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_53925_0();
/* 277 */     vo_53925_0.isOffical = 1;
/* 278 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M53925_0(), vo_53925_0);
/*     */     
/*     */ 
/* 281 */     org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0 vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE(chara);
/* 282 */     GameObjectChar.getGameObjectChar().gameMap.send(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/*     */     
/* 284 */     List<org.linlinjava.litemall.gameserver.data.vo.Vo_32747_0> vo_32747_0List = GameUtil.a32747(chara);
/* 285 */     GameObjectChar.send(new MSG_UPDATE_SKILLS(), vo_32747_0List);
/*     */     
/*     */ 
/* 288 */     org.linlinjava.litemall.gameserver.data.vo.Vo_32985_0 vo_32985_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_32985_0();
/* 289 */     vo_32985_0.user_is_multi = 0;
/* 290 */     vo_32985_0.user_round = chara.autofight_select;
/* 291 */     vo_32985_0.user_action = chara.autofight_skillaction;
/* 292 */     vo_32985_0.user_next_action = chara.autofight_skillaction;
/* 293 */     vo_32985_0.user_para = chara.autofight_skillno;
/* 294 */     vo_32985_0.user_next_para = chara.autofight_skillno;
/* 295 */     vo_32985_0.pet_is_multi = 0;
/* 296 */     vo_32985_0.pet_round = 0;
/* 297 */     vo_32985_0.pet_action = 0;
/* 298 */     vo_32985_0.pet_next_action = 0;
/* 299 */     vo_32985_0.pet_para = 0;
/* 300 */     vo_32985_0.pet_next_para = 0;
/* 301 */     GameObjectChar.send(new MSG_AUTO_FIGHT_SKIL(), vo_32985_0);
/* 302 */     GameUtil.genchongfei(chara);
/*     */     
/*     */ 
/* 305 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61663(), GameCore.that.getGameLineAll());
/*     */     
/*     */ 
/* 308 */     if (!chara.npcName.equals("")) {
/* 309 */       Vo_61553_0 vo_61553_10 = new Vo_61553_0();
/* 310 */       vo_61553_10.count = 1;
/* 311 */       vo_61553_10.task_type = "sm-002";
/* 312 */       vo_61553_10.task_desc = "接受门派师尊交办的一些事情，完成后会获得嘉奖。";
/* 313 */       vo_61553_10.task_prompt = ("拜访#P" + chara.npcName + "|M=【师门】入世#P");
/* 314 */       vo_61553_10.refresh = 0;
/* 315 */       vo_61553_10.task_end_time = 1567932239;
/* 316 */       vo_61553_10.attrib = 0;
/* 317 */       vo_61553_10.reward = "#I经验|人物经验宠物经验#I#I金钱|金钱#I";
/* 318 */       vo_61553_10.show_name = ("师门—入世(" + chara.shimencishu + "/10)");
/* 319 */       vo_61553_10.tasktask_extra_para = "";
/* 320 */       vo_61553_10.tasktask_state = "1";
/* 321 */       GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_10);
/*     */     }
/*     */     
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/* 333 */     if (chara.fabaorenwu == 1) {
/* 334 */       Vo_61553_0 vo_61553_10 = new Vo_61553_0();
/* 335 */       vo_61553_10.count = 1;
/* 336 */       vo_61553_10.task_type = "法宝任务";
/* 337 */       vo_61553_10.task_desc = "为获得强大的法宝而接受重重考验的任务。";
/* 338 */       vo_61553_10.task_prompt = "找#P龙王#P求取法宝";
/* 339 */       vo_61553_10.refresh = 0;
/* 340 */       vo_61553_10.task_end_time = 1567932239;
/* 341 */       vo_61553_10.attrib = 0;
/* 342 */       vo_61553_10.reward = "#I法宝|随机法宝=F$1$6#I";
/* 343 */       vo_61553_10.show_name = "法宝任务";
/* 344 */       vo_61553_10.tasktask_extra_para = "";
/* 345 */       vo_61553_10.tasktask_state = "1";
/* 346 */       GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_10);
/*     */     }
/*     */     
/*     */ 
/*     */ 
/* 351 */     GameUtil.chenghaoxiaoxi(chara);
/*     */     
/* 353 */     if ((session.gameTeam != null) && (session.gameTeam.duiwu != null) && (session.gameTeam.duiwu.size() > 0)) {
/* 354 */       Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/* 355 */       vo_61671_0.id = ((Chara)session.gameTeam.duiwu.get(0)).id;
/* 356 */       vo_61671_0.count = 2;
/* 357 */       vo_61671_0.list.add(Integer.valueOf(2));
/* 358 */       vo_61671_0.list.add(Integer.valueOf(3));
/* 359 */       GameObjectChar.send(new MSG_TITLE(), vo_61671_0);
/* 360 */       for (int i = 0; i < session.gameTeam.duiwu.size(); i++) {
/* 361 */         if ((((Chara)session.gameTeam.duiwu.get(i)).id == chara.id) && (((Chara)session.gameTeam.duiwu.get(0)).id != chara.id)) {
/* 362 */           vo_61671_0 = new Vo_61671_0();
/* 363 */           vo_61671_0.id = session.chara.id;
/* 364 */           vo_61671_0.count = 2;
/* 365 */           vo_61671_0.list.add(Integer.valueOf(2));
/* 366 */           vo_61671_0.list.add(Integer.valueOf(5));
/* 367 */           GameObjectChar.send(new MSG_TITLE(), vo_61671_0);
/*     */         }
/*     */       }
/* 370 */       List<Chara> charas = GameObjectChar.getGameObjectChar().gameTeam.duiwu;
/* 371 */       GameUtil.a4119(charas);
/* 372 */       GameUtil.a4121(GameObjectChar.getGameObjectChar().gameTeam.zhanliduiyuan);
/*     */     }
/*     */     
/* 375 */     if (chara.changbaotu.mapid != 0) {
/* 376 */       vo_61553_0 = new Vo_61553_0();
/* 377 */       vo_61553_0.count = 1;
/* 378 */       vo_61553_0.task_type = "超级宝藏";
/* 379 */       vo_61553_0.task_desc = "在游戏中根据超级藏宝图进行寻宝。";
/* 380 */       vo_61553_0.task_prompt = ("#前往#Z" + chara.changbaotu.name + "|" + chara.changbaotu.name + "(" + chara.changbaotu.x + "," + chara.changbaotu.y + ")#Z寻宝");
/* 381 */       vo_61553_0.refresh = 1;
/* 382 */       vo_61553_0.task_end_time = 1567909190;
/* 383 */       vo_61553_0.attrib = 1;
/* 384 */       vo_61553_0.reward = "#I道行|道行#I#I潜能|潜能#I#I金钱|金钱#I#I物品|召唤令·十二生肖#I#I宠物|十二生肖=F#I";
/* 385 */       vo_61553_0.show_name = "超级宝藏";
/* 386 */       vo_61553_0.tasktask_extra_para = "";
/* 387 */       vo_61553_0.tasktask_state = "1";
/* 388 */       GameObjectChar.getGameObjectChar();GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_0);
/*     */     }
/*     */     
/*     */ 
/* 392 */     Vo_4321_0 vo_4321_0 = new Vo_4321_0();
/* 393 */     vo_4321_0.dist = "一战功成";
/* 394 */     vo_4321_0.b = 0;
/* 395 */     vo_4321_0.flag = 1;
/* 396 */     vo_4321_0.a = GameCore.getGameLine(chara.line).lineNum;
/* 397 */     vo_4321_0.name = GameCore.getGameLine(chara.line).lineName;
/* 398 */     vo_4321_0.time = ((int)(System.currentTimeMillis() / 1000L));
/* 399 */     vo_4321_0.c = 8;
/* 400 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M4321_0(), vo_4321_0);
/*     */     
/* 402 */     org.linlinjava.litemall.gameserver.fight.FightManager.reconnect(chara);
/*     */   }
/*     */   
/*     */   public int cmd()
/*     */   {
/* 407 */     return 4192;
/*     */   }
/*     */   
/*     */   public static void main(String[] args) throws java.io.UnsupportedEncodingException
/*     */   {
/* 412 */     String value = String.valueOf("多闻道人");
/* 413 */     byte[] bs = value.getBytes("GBK");
/* 414 */     String s = bytesToHexString(bs);
/* 415 */     System.out.println(s);
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */   public static String bytesToHexString(byte[] src)
/*     */   {
/* 425 */     StringBuilder stringBuilder = new StringBuilder("");
/* 426 */     if ((src == null) || (src.length <= 0)) {
/* 427 */       return null;
/*     */     }
/* 429 */     for (int i = 0; i < src.length; i++) {
/* 430 */       int v = src[i] & 0xFF;
/* 431 */       String hv = Integer.toHexString(v);
/* 432 */       if (hv.length() < 2) {
/* 433 */         stringBuilder.append(0);
/*     */       }
/* 435 */       stringBuilder.append(hv);
/*     */     }
/* 437 */     return stringBuilder.toString();
/*     */   }
/*     */   
/*     */   public static byte[] hexToByteArray(String inHex) {
/* 441 */     int hexlen = inHex.length();
/*     */     byte[] result;
/* 443 */     if (hexlen % 2 == 1)
/*     */     {
/* 445 */       hexlen++;
/* 446 */      result = new byte[hexlen / 2];
/* 447 */       inHex = "0" + inHex;
/*     */     }
/*     */     else {
/* 450 */       result = new byte[hexlen / 2];
/*     */     }
/* 452 */     int j = 0;
/* 453 */     for (int i = 0; i < hexlen; i += 2) {
/* 454 */       result[j] = hexToByte(inHex.substring(i, i + 2));
/* 455 */       j++;
/*     */     }
/* 457 */     return result;
/*     */   }
/*     */   
/*     */   public static byte hexToByte(String inHex) {
/* 461 */     return (byte)Integer.parseInt(inHex, 16);
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C4192_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */