/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import java.util.List;
/*     */ import org.json.JSONObject;
/*     */ import org.linlinjava.litemall.gameserver.GameHandler;
/*     */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*     */ import org.linlinjava.litemall.gameserver.data.game.PetAndHelpSkillUtils;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_32747_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_SKILLS;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
/*     */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.JiNeng;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ import org.springframework.stereotype.Service;
/*     */ 
/*     */ 
/*     */ @Service
/*     */ public class CMD_LEARN_SKILL_0
/*     */   implements GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  28 */     int id = GameReadTool.readInt(buff);
/*     */     
/*  30 */     int skill_no = GameReadTool.readShort(buff);
/*     */     
/*  32 */     int up_level = GameReadTool.readShort(buff);
/*     */     
/*  34 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*     */     
/*  36 */     JiNeng sjjiNeng = new JiNeng();
/*  37 */     for (JiNeng jiNeng : chara.jiNengList) {
/*  38 */       if (jiNeng.skill_no == skill_no) {
/*  39 */         sjjiNeng = jiNeng;
/*     */       }
/*     */     }
/*  42 */     if (sjjiNeng.skill_no == 0) {
/*  43 */       PetAndHelpSkillUtils petAndHelpSkillUtils = new PetAndHelpSkillUtils();
/*  44 */       int levelUp = up_level;
/*  45 */       int cash = 0;
/*  46 */       if (sjjiNeng.skill_level + up_level > sjjiNeng.skill_attrib) {
/*  47 */         up_level = sjjiNeng.skill_attrib - sjjiNeng.skill_level;
/*     */       }
/*  49 */       for (int i = 0; i < levelUp; i++) {
/*  50 */         int[] blueAndPointsLan = petAndHelpSkillUtils.getBlueAndPointsLan(skill_no, sjjiNeng.skill_level + i);
/*  51 */         cash += blueAndPointsLan[1];
/*     */       }
/*  53 */       if ((cash > chara.cash) && (skill_no != 302) && (skill_no != 301)) {
/*  54 */         Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/*  55 */         vo_20481_0.msg = "潜能不足，无法学习该技能";
/*  56 */         vo_20481_0.time = 1562987118;
/*  57 */         GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*  58 */         return;
/*     */       }
/*  60 */       sjjiNeng.skill_no = skill_no;
/*  61 */       JSONObject jsonObject = PetAndHelpSkillUtils.jsonArray(skill_no);
/*  62 */       sjjiNeng.skill_attrib1 = Integer.parseInt((String)jsonObject.get("skill_attrib"));
/*  63 */       sjjiNeng.skill_attrib = PetAndHelpSkillUtils.getMaxSkill(chara.level);
/*  64 */       sjjiNeng.skill_level = (0 + levelUp);
/*  65 */       int[] blueAndPointsLan = petAndHelpSkillUtils.getBlueAndPointsLan(skill_no, sjjiNeng.skill_level);
/*  66 */       sjjiNeng.level_improved = 0;
/*  67 */       sjjiNeng.skill_mana_cost = blueAndPointsLan[0];
/*  68 */       sjjiNeng.skill_nimbus = 42949672;
/*  69 */       sjjiNeng.skill_disabled = 0;
/*  70 */       sjjiNeng.range = petAndHelpSkillUtils.skillNummax(skill_no, sjjiNeng.skill_level);
/*  71 */       sjjiNeng.max_range = petAndHelpSkillUtils.skillNummax(skill_no, sjjiNeng.skill_attrib);
/*  72 */       int[] ints = PetAndHelpSkillUtils.skillNum(jsonObject, sjjiNeng.skill_level);
/*  73 */       sjjiNeng.skillRound = ints[1];
/*  74 */       sjjiNeng.count1 = 1;
/*  75 */       sjjiNeng.s1 = "pot";
/*  76 */       sjjiNeng.s2 = blueAndPointsLan[1];
/*  77 */       sjjiNeng.isTempSkill = 0;
/*  78 */       chara.jiNengList.add(sjjiNeng);
/*  79 */       if ((skill_no == 301) || (skill_no == 302)) {
/*  80 */         GameUtil.MSG_UPDATE_IMPROVEMENT(chara);
/*  81 */         sjjiNeng.s1 = "voucher_or_cash";
/*  82 */         if (chara.use_money_type < cash) {
/*  83 */           chara.balance -= cash;
/*     */         } else {
/*  85 */           chara.use_money_type -= cash;
/*     */         }
/*  87 */         ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/*  88 */         GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*     */       } else {
/*  90 */         chara.cash -= cash;
/*     */       }
/*     */       
/*  93 */       ListVo_65527_0 vo_65527_0 = GameUtil.a65527(chara);
/*  94 */       GameObjectChar.send(new MSG_UPDATE(), vo_65527_0);
/*  95 */       List<Vo_32747_0> vo_32747_0List = GameUtil.MSG_UPDATE_SKILLS(chara);
/*  96 */       GameObjectChar.send(new MSG_UPDATE_SKILLS(), vo_32747_0List);
/*  97 */       Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/*  98 */       vo_20481_0.msg = ("你技能等级提升到了#R" + sjjiNeng.skill_level + "#n级！");
/*  99 */       vo_20481_0.time = 1562987118;
/* 100 */       GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*     */     }
/*     */     else {
/* 103 */       sjjiNeng.skill_attrib = PetAndHelpSkillUtils.getMaxSkill(chara.level);
/* 104 */       int levelUp = up_level;
/* 105 */       int cash = 0;
/* 106 */       if (sjjiNeng.skill_level + up_level > sjjiNeng.skill_attrib) {
/* 107 */         up_level = sjjiNeng.skill_attrib - sjjiNeng.skill_level;
/*     */       }
/* 109 */       PetAndHelpSkillUtils petAndHelpSkillUtils = new PetAndHelpSkillUtils();
/* 110 */       for (int i = 0; i < levelUp; i++) {
/* 111 */         int[] blueAndPointsLan = petAndHelpSkillUtils.getBlueAndPointsLan(skill_no, sjjiNeng.skill_level + i);
/* 112 */         cash += blueAndPointsLan[1];
/*     */       }
/* 114 */       if ((cash > chara.cash) && (skill_no != 302) && (skill_no != 301)) {
/* 115 */         Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/* 116 */         vo_20481_0.msg = "金币，无法学习该技能";
/* 117 */         vo_20481_0.time = 1562987118;
/* 118 */         GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/* 119 */         return;
/*     */       }
/* 121 */       if (((skill_no == 301) || (skill_no == 302)) && 
/* 122 */         (chara.balance < chara.cash) && (chara.use_money_type < chara.cash)) {
/* 123 */         return;
/*     */       }
/*     */       
/* 126 */       JSONObject jsonObject = PetAndHelpSkillUtils.jsonArray(skill_no);
/* 127 */       sjjiNeng.skill_attrib1 = Integer.parseInt((String)jsonObject.get("skill_attrib"));
/* 128 */       sjjiNeng.skill_level += up_level;
/* 129 */       sjjiNeng.range = petAndHelpSkillUtils.skillNummax(skill_no, sjjiNeng.skill_level);
/* 130 */       int[] ints = PetAndHelpSkillUtils.skillNum(jsonObject, sjjiNeng.skill_level);
/* 131 */       sjjiNeng.skillRound = ints[1];
/* 132 */       int[] blueAndPointsLan = petAndHelpSkillUtils.getBlueAndPointsLan(skill_no, sjjiNeng.skill_level);
/* 133 */       sjjiNeng.skill_mana_cost = blueAndPointsLan[0];
/*     */       
/* 135 */       sjjiNeng.s2 = blueAndPointsLan[1];
/*     */       
/* 137 */       if ((skill_no == 301) || (skill_no == 302)) {
/* 138 */         GameUtil.MSG_UPDATE_IMPROVEMENT(chara);
/* 139 */         sjjiNeng.s1 = "voucher_or_cash";
/* 140 */         if (chara.use_money_type < cash) {
/* 141 */           chara.balance -= cash;
/*     */         } else {
/* 143 */           chara.use_money_type -= cash;
/*     */         }
/* 145 */         ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/* 146 */         GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*     */       } else {
/* 148 */         chara.cash -= cash;
/*     */       }
/* 150 */       ListVo_65527_0 vo_65527_0 = GameUtil.a65527(chara);
/* 151 */       GameObjectChar.send(new MSG_UPDATE(), vo_65527_0);
/* 152 */       List<Vo_32747_0> vo_32747_0List = GameUtil.MSG_UPDATE_SKILLS(chara);
/* 153 */       GameObjectChar.send(new MSG_UPDATE_SKILLS(), vo_32747_0List);
/* 154 */       Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/* 155 */       vo_20481_0.msg = ("你技能等级提升到了#R" + sjjiNeng.skill_level + "#n级！");
/* 156 */       vo_20481_0.time = 1562987118;
/* 157 */       GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*     */     }
/*     */     
/*     */ 
/*     */ 
/* 162 */     ListVo_65527_0 vo_65527_0 = GameUtil.a65527(chara);
/* 163 */     GameObjectChar.send(new MSG_UPDATE(), vo_65527_0);
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 171 */     return 8308;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C8308_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */