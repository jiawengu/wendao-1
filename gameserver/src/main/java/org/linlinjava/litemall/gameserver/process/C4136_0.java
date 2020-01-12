/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import java.util.ArrayList;
/*     */ import java.util.List;
/*     */ import org.linlinjava.litemall.db.domain.Renwu;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.GameHandler;
/*     */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61553_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_TASK_PROMPT;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_INVENTORY;
/*     */
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_APPEAR;
/*     */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ import org.springframework.stereotype.Service;
/*     */

/**
 * CMD_EQUIP
 */
/*     */ @Service
/*     */ public class C4136_0 implements GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  30 */     int pos = GameReadTool.readByte(buff);
/*     */     
/*  32 */     int equip_part = GameReadTool.readByte(buff);
/*     */     
/*  34 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*     */     
/*  36 */     if (pos < 0) {
/*  37 */       pos = 129 + pos + 127;
/*     */     }
/*     */     
/*  40 */     if (chara.current_task.equals("主线—浮生若梦_s2"))
/*     */     {
/*  42 */       GameUtil.renwujiangli(chara);
/*     */       
/*  44 */       chara.current_task = GameUtil.nextrenw(chara.current_task);
/*     */       
/*     */ 
/*  47 */       Renwu tasks = GameData.that.baseRenwuService.findOneByCurrentTask(chara.current_task);
/*  48 */       Vo_61553_0 vo_61553_0 = GameUtil.a61553(tasks, chara);
/*  49 */       GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_0);
/*     */     }
/*  51 */     boolean has = false;
/*  52 */     Goods goodshas = new Goods();
/*  53 */     for (int i = 0; i < chara.backpack.size(); i++) {
/*  54 */       Goods goods = (Goods)chara.backpack.get(i);
/*  55 */       if (goods.pos == equip_part) {
/*  56 */         goodshas = goods;
/*  57 */         has = true;
/*     */       }
/*     */     }
/*  60 */     for (int i = 0; i < chara.backpack.size(); i++) {
/*  61 */       Goods goods = (Goods)chara.backpack.get(i);
/*  62 */       if (goods.pos == pos) {
/*  63 */         if ((goods.goodsInfo.master != 0) && (goods.goodsInfo.master != chara.sex)) {
/*  64 */           return;
/*     */         }
/*  66 */         goods.pos = equip_part;
/*  67 */         if (goods.pos != 1) break;
/*  68 */         chara.weapon_icon = goods.goodsInfo.type; break;
/*     */       }
/*     */     }
/*     */     
/*     */ 
/*  73 */     if (has) {  //等于flasede s时候
/*  74 */       goodshas.pos = pos;
/*     */     } else {
/*  76 */       List<Goods> listbeibao = new ArrayList();
/*  77 */       Goods goods1 = new Goods();
/*  78 */       goods1.goodsBasics = null;
/*  79 */       goods1.goodsInfo = null;
/*  80 */       goods1.goodsLanSe = null;
/*  81 */       goods1.pos = pos;
/*  82 */       listbeibao.add(goods1);
/*  83 */       GameObjectChar.send(new MSG_INVENTORY(), listbeibao);
/*     */     }
/*     */     
/*  86 */     GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
/*     */     
/*  88 */     GameUtil.MSG_UPDATE_IMPROVEMENT(chara);
/*  89 */     ListVo_65527_0 vo_65527_0 = GameUtil.a65527(chara);
/*  90 */     GameObjectChar.send(new MSG_UPDATE(), vo_65527_0);
/*     */     
/*  92 */     Vo_65529_0 vo_65529_0 = GameUtil.MSG_APPEAR(chara);
/*  93 */     GameObjectChar.send(new MSG_APPEAR(), vo_65529_0);
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 100 */     return 4136;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C4136_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */