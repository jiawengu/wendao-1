/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */

/**
 * MSG_UPDATE_APPEARANCE    更新外观
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_UPDATE_APPEARANCE extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     Vo_61661_0 object1 = (Vo_61661_0)object;
/* 14 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/*    */     
/* 16 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.x));
/*    */     
/* 18 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.y));
/*    */     
/* 20 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.dir));
/*    */     
/* 22 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.icon));
/*    */     
/* 24 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.weapon_icon));
/*    */     
/* 26 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.type));
/*    */     
/* 28 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.sub_type));
/*    */     
/* 30 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.owner_id));
/*    */     
/* 32 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.leader_id));
/*    */     
/* 34 */     GameWriteTool.writeString(writeBuf, object1.name);
/*    */     
/* 36 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.level));
/*    */     
/* 38 */     GameWriteTool.writeString(writeBuf, object1.title);
/*    */     
/* 40 */     GameWriteTool.writeString(writeBuf, object1.family);
/*    */     
/* 42 */     GameWriteTool.writeString(writeBuf, object1.partyname);
/*    */     
/* 44 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.status));
/*    */     
/* 46 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.special_icon));
/*    */     
/* 48 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.org_icon));
/*    */     
/* 50 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.suit_icon));
/*    */     
/* 52 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.suit_light_effect));
/*    */     
/* 54 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.guard_icon));
/*    */     
/* 56 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.pet_icon));
/*    */     
/* 58 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.shadow_icon));
/*    */     
/* 60 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.shelter_icon));
/*    */     
/* 62 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.mount_icon));
/*    */     
/* 64 */     GameWriteTool.writeString(writeBuf, object1.alicename);
/*    */     
/* 66 */     GameWriteTool.writeString(writeBuf, object1.gid);
/*    */     
/* 68 */     GameWriteTool.writeString(writeBuf, object1.camp);
/*    */     
/* 70 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.vip_type));
/*    */     
/* 72 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isHide));
/*    */     
/* 74 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.moveSpeedPercent));
/*    */     
/* 76 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.score));
/*    */     
/* 78 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.opacity));
/*    */     
/* 80 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.masquerade));
/*    */     
/* 82 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.upgradestate));
/*    */     
/* 84 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.upgradetype));
/*    */     
/* 86 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.obstacle));
/*    */     
/* 88 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.light_effect_count));
/*    */     
/* 90 */     for (int i = 0; i < object1.light_effect_count; i++) {
/* 91 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.effect));
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 98 */     return 61661;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M61661_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */