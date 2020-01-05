/*     */ package org.linlinjava.litemall.gameserver.data.write;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
/*     */

/**
 * MSG_APPEAR
 */
/*     */ @org.springframework.stereotype.Service
/*     */ public class MSG_APPEAR extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*     */ {
/*     */   protected void writeO(ByteBuf writeBuf, Object object)
/*     */   {
/*  12 */     Vo_65529_0 object1 = (Vo_65529_0)object;
/*  13 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/*     */     
/*  15 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.x));
/*     */     
/*  17 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.y));
/*     */     
/*  19 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.dir));
/*     */     
/*  21 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.icon));
/*     */     
/*  23 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.weapon_icon));
/*     */     
/*  25 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.type));
/*     */     
/*  27 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.sub_type));
/*     */     
/*  29 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.owner_id));
/*     */     
/*  31 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.leader_id));
/*     */     
/*  33 */     GameWriteTool.writeString(writeBuf, object1.name);
/*     */     
/*  35 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.level));
/*     */     
/*  37 */     GameWriteTool.writeString(writeBuf, object1.title);
/*     */     
/*  39 */     GameWriteTool.writeString(writeBuf, object1.family);
/*     */     
/*  41 */     GameWriteTool.writeString(writeBuf, object1.party);
/*     */     
/*  43 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.status));
/*     */     
/*  45 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.special_icon));
/*     */     
/*  47 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.org_icon));
/*     */     
/*  49 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.suit_icon));
/*     */     
/*  51 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.suit_light_effect));
/*     */     
/*  53 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.guard_icon));
/*     */     
/*  55 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.pet_icon));
/*     */     
/*  57 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.shadow_icon));
/*     */     
/*  59 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.shelter_icon));
/*     */     
/*  61 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.mount_icon));
/*     */     
/*  63 */     GameWriteTool.writeString(writeBuf, object1.alicename);
/*     */     
/*  65 */     GameWriteTool.writeString(writeBuf, object1.gid);
/*     */     
/*  67 */     GameWriteTool.writeString(writeBuf, object1.camp);
/*     */     
/*  69 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.vip_type));
/*     */     
/*  71 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isHide));
/*     */     
/*  73 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.moveSpeedPercent));
/*     */     
/*  75 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.score));
/*     */     
/*  77 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.opacity));
/*     */     
/*  79 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.masquerade));
/*     */     
/*  81 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.upgradestate));
/*     */     
/*  83 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.upgradetype));
/*     */     
/*  85 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.obstacle));
/*     */     
/*  87 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.light_effect_count));
/*     */     
/*  89 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.effect));
/*     */     
/*  91 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.share_mount_icon));
/*     */     
/*  93 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.share_mount_leader_id));
/*     */     
/*  95 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.gather_count));
/*     */     
/*  97 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.gather_name_num));
/*     */     
/*  99 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.portrait));
/*     */     
/* 101 */     GameWriteTool.writeString(writeBuf, object1.customIcon);
/*     */   }
/*     */   
/* 104 */   public int cmd() { return 65529; }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\MSG_APPEAR.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */