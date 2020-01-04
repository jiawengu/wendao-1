/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import java.util.ArrayList;
/*     */ import java.util.List;
/*     */ import java.util.Random;
/*     */ import org.linlinjava.litemall.db.domain.CreepsStore;
/*     */ import org.linlinjava.litemall.db.domain.Pet;
/*     */
/*     */
/*     */ import org.linlinjava.litemall.gameserver.GameHandler;
/*     */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*     */ import org.linlinjava.litemall.gameserver.data.game.BasicAttributesUtils;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_40964_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M40964_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_PETS;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
/*     */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*     */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ import org.springframework.stereotype.Service;
/*     */

/**
 * 天技秘笈商店
 */
/*     */ @Service
/*     */ public class CMD_EXCHANGE_GOODS implements GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  34 */     int type = GameReadTool.readByte(buff);
/*     */     
/*  36 */     String name = GameReadTool.readString(buff);
/*     */     
/*  38 */     int amount = GameReadTool.readShort(buff);
/*     */     
/*  40 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*     */     
/*  42 */     if (1 == type) {
/*  43 */       CreepsStore creepsStore = GameData.that.baseCreepsStoreService.findOneByName(name);
/*  44 */       Integer price = creepsStore.getPrice();
/*     */       
/*     */ 
/*  47 */       Pet pet = GameData.that.basePetService.findOneByName(name);
/*  48 */       Petbeibao petbeibao = new Petbeibao();
/*  49 */       petbeibao.petCreate(pet, chara, 20);
/*  50 */       ((PetShuXing)petbeibao.petShuXing.get(0)).penetrate = 1;
/*  51 */       PetShuXing shuXing = (PetShuXing)petbeibao.petShuXing.get(0);
/*  52 */       chara.pets.add(petbeibao);
/*     */       
/*     */ 
/*  55 */       shuXing.skill = pet.getLevelReq().intValue();
/*  56 */       shuXing.attrib = pet.getLevelReq().intValue();
/*  57 */       int polar_point = shuXing.skill * 4;
/*  58 */       int addpoint = subtraction(polar_point - shuXing.skill * 3);
/*  59 */       polar_point -= addpoint;
/*  60 */       shuXing.life = (shuXing.skill + addpoint);
/*  61 */       addpoint = subtraction(polar_point);
/*  62 */       polar_point -= addpoint;
/*  63 */       shuXing.mag_power = (shuXing.skill + addpoint);
/*  64 */       addpoint = subtraction(polar_point);
/*  65 */       polar_point -= addpoint;
/*  66 */       shuXing.phy_power = (shuXing.skill + addpoint);
/*  67 */       addpoint = subtraction(polar_point);
/*  68 */       polar_point -= addpoint;
/*  69 */       shuXing.speed = (shuXing.skill + addpoint);
/*     */       
/*     */ 
/*  72 */       shuXing.polar_point = 0;
/*  73 */       List list = new ArrayList();
/*  74 */       BasicAttributesUtils.petshuxing(shuXing);
/*  75 */       shuXing.max_life = shuXing.def;
/*  76 */       shuXing.max_mana = shuXing.dex;
/*  77 */       list.add(petbeibao);
/*     */       
/*  79 */       GameObjectChar.send(new MSG_UPDATE_PETS(), list);
/*  80 */       chara.balance -= price.intValue();
/*  81 */       ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/*  82 */       GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*  83 */       Vo_40964_0 vo_40964_0 = new Vo_40964_0();
/*  84 */       vo_40964_0.type = 2;
/*  85 */       vo_40964_0.name = name;
/*  86 */       vo_40964_0.param = String.valueOf(pet.getIcon());
/*  87 */       vo_40964_0.rightNow = 0;
/*  88 */       GameObjectChar.send(new M40964_0(), vo_40964_0);
/*  89 */       Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/*  90 */       vo_20481_0.msg = ("你购买了一只#Y" + name + "（野生）#n。");
/*  91 */       vo_20481_0.time = 1562987118;
/*  92 */       GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*  93 */       boolean isfagong = ((PetShuXing)petbeibao.petShuXing.get(0)).rank > ((PetShuXing)petbeibao.petShuXing.get(0)).pet_mag_shape;
/*  94 */       GameUtil.dujineng(1, ((PetShuXing)petbeibao.petShuXing.get(0)).metal, ((PetShuXing)petbeibao.petShuXing.get(0)).skill, isfagong, petbeibao.id, chara);
/*     */     }
/*     */   }
/*     */   
/*     */   public int cmd()
/*     */   {
/* 100 */     return 40966;
/*     */   }
/*     */   
/*     */   public int subtraction(int i) {
/* 104 */     Random r = new Random();
/*     */     
/* 106 */     return r.nextInt(i);
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C40966_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */