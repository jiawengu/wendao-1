/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.ArrayList;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.db.domain.Pet;
/*    */
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.game.BasicAttributesUtils;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_PETS;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M8165_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*    */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*    */ import org.linlinjava.litemall.gameserver.game.GameData;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C32772_0
/*    */   implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 28 */     int no = GameReadTool.readByte(buff);
/*    */     
/* 30 */     int is_set = GameReadTool.readByte(buff);
/*    */     
/* 32 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*    */     
/* 34 */     if (is_set == 1) {
/* 35 */       for (int i = 0; i < chara.pets.size(); i++) {
/* 36 */         Petbeibao petbeibao = (Petbeibao)chara.pets.get(i);
/* 37 */         if (petbeibao.no == no) {
/* 38 */           Pet pet = GameData.that.basePetService.findOneByName(((PetShuXing)petbeibao.petShuXing.get(0)).str);
/* 39 */           PetShuXing shuXing = (PetShuXing)petbeibao.petShuXing.get(0);
/* 40 */           shuXing.pet_mana_shape += shuXing.pet_mana_shape_temp;
/* 41 */           shuXing.pet_speed_shape += shuXing.pet_speed_shape_temp;
/* 42 */           shuXing.pet_phy_shape += shuXing.pet_phy_shape_temp;
/* 43 */           shuXing.pet_mag_shape += shuXing.pet_mag_shape_temp;
/* 44 */           shuXing.rank += shuXing.evolve_degree;
/*    */           
/* 46 */           shuXing.mana_effect += shuXing.pet_mana_shape_temp;
/* 47 */           shuXing.attack_effect += shuXing.pet_speed_shape_temp;
/* 48 */           shuXing.mag_effect += shuXing.pet_mag_shape_temp;
/* 49 */           shuXing.phy_absorb += shuXing.evolve_degree;
/* 50 */           shuXing.phy_effect += shuXing.pet_phy_shape_temp;
/*    */           
/*    */ 
/* 53 */           shuXing.pet_mana_shape_temp = 0;
/*    */           
/* 55 */           shuXing.pet_speed_shape_temp = 0;
/*    */           
/* 57 */           shuXing.pet_phy_shape_temp = 0;
/*    */           
/* 59 */           shuXing.pet_mag_shape_temp = 0;
/*    */           
/* 61 */           shuXing.evolve_degree = 0;
/*    */           
/*    */ 
/* 64 */           List list = new ArrayList();
/*    */           
/* 66 */           BasicAttributesUtils.petshuxing((PetShuXing)petbeibao.petShuXing.get(0));
/* 67 */           shuXing.max_life = shuXing.def;
/* 68 */           shuXing.max_mana = shuXing.dex;
/* 69 */           list.add(petbeibao);
/* 70 */           GameObjectChar.send(new MSG_UPDATE_PETS(), list);
/* 71 */           Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/* 72 */           vo_8165_0.msg = ("你的#Y" + pet.getName() + "#n经过洗炼，基础成长已重新生成。");
/* 73 */           vo_8165_0.active = 0;
/* 74 */           GameObjectChar.send(new M8165_0(), vo_8165_0);
/*    */         }
/*    */       }
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 85 */     return 32772;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C32772_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */