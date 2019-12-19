/*     */ package org.linlinjava.litemall.gameserver.data.write;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45381_0;
/*     */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*     */ 
/*     */ @org.springframework.stereotype.Service
/*     */ public class M45381_0 extends BaseWrite
/*     */ {
/*     */   protected void writeO(ByteBuf writeBuf, Object object)
/*     */   {
/*  13 */     Vo_45381_0 object1 = (Vo_45381_0)object;
/*  14 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.start_time));
/*     */     
/*  16 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.end_time));
/*     */     
/*  18 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.all_rewards_count));
/*     */     
/*  20 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no0));
/*     */     
/*  22 */     GameWriteTool.writeString(writeBuf, object1.name0);
/*     */     
/*  24 */     GameWriteTool.writeString(writeBuf, object1.desc0);
/*     */     
/*  26 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level0));
/*     */     
/*  28 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no1));
/*     */     
/*  30 */     GameWriteTool.writeString(writeBuf, object1.name1);
/*     */     
/*  32 */     GameWriteTool.writeString(writeBuf, object1.desc1);
/*     */     
/*  34 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level1));
/*     */     
/*  36 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no2));
/*     */     
/*  38 */     GameWriteTool.writeString(writeBuf, object1.name2);
/*     */     
/*  40 */     GameWriteTool.writeString(writeBuf, object1.desc2);
/*     */     
/*  42 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level2));
/*     */     
/*  44 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no3));
/*     */     
/*  46 */     GameWriteTool.writeString(writeBuf, object1.name3);
/*     */     
/*  48 */     GameWriteTool.writeString(writeBuf, object1.desc3);
/*     */     
/*  50 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level3));
/*     */     
/*  52 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no4));
/*     */     
/*  54 */     GameWriteTool.writeString(writeBuf, object1.name4);
/*     */     
/*  56 */     GameWriteTool.writeString(writeBuf, object1.desc4);
/*     */     
/*  58 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level4));
/*     */     
/*  60 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no5));
/*     */     
/*  62 */     GameWriteTool.writeString(writeBuf, object1.name5);
/*     */     
/*  64 */     GameWriteTool.writeString(writeBuf, object1.desc5);
/*     */     
/*  66 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level5));
/*     */     
/*  68 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no6));
/*     */     
/*  70 */     GameWriteTool.writeString(writeBuf, object1.name6);
/*     */     
/*  72 */     GameWriteTool.writeString(writeBuf, object1.desc6);
/*     */     
/*  74 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level6));
/*     */     
/*  76 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no7));
/*     */     
/*  78 */     GameWriteTool.writeString(writeBuf, object1.name7);
/*     */     
/*  80 */     GameWriteTool.writeString(writeBuf, object1.desc7);
/*     */     
/*  82 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level7));
/*     */     
/*  84 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no8));
/*     */     
/*  86 */     GameWriteTool.writeString(writeBuf, object1.name8);
/*     */     
/*  88 */     GameWriteTool.writeString(writeBuf, object1.desc8);
/*     */     
/*  90 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level8));
/*     */     
/*  92 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no9));
/*     */     
/*  94 */     GameWriteTool.writeString(writeBuf, object1.name9);
/*     */     
/*  96 */     GameWriteTool.writeString(writeBuf, object1.desc9);
/*     */     
/*  98 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level9));
/*     */     
/* 100 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no10));
/*     */     
/* 102 */     GameWriteTool.writeString(writeBuf, object1.name10);
/*     */     
/* 104 */     GameWriteTool.writeString(writeBuf, object1.desc10);
/*     */     
/* 106 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level10));
/*     */     
/* 108 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no11));
/*     */     
/* 110 */     GameWriteTool.writeString(writeBuf, object1.name11);
/*     */     
/* 112 */     GameWriteTool.writeString(writeBuf, object1.desc11);
/*     */     
/* 114 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level11));
/*     */     
/* 116 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no12));
/*     */     
/* 118 */     GameWriteTool.writeString(writeBuf, object1.name12);
/*     */     
/* 120 */     GameWriteTool.writeString(writeBuf, object1.desc12);
/*     */     
/* 122 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level12));
/*     */     
/* 124 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no13));
/*     */     
/* 126 */     GameWriteTool.writeString(writeBuf, object1.name13);
/*     */     
/* 128 */     GameWriteTool.writeString(writeBuf, object1.desc13);
/*     */     
/* 130 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level13));
/*     */     
/* 132 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no14));
/*     */     
/* 134 */     GameWriteTool.writeString(writeBuf, object1.name14);
/*     */     
/* 136 */     GameWriteTool.writeString(writeBuf, object1.desc14);
/*     */     
/* 138 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level14));
/*     */     
/* 140 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no15));
/*     */     
/* 142 */     GameWriteTool.writeString(writeBuf, object1.name15);
/*     */     
/* 144 */     GameWriteTool.writeString(writeBuf, object1.desc15);
/*     */     
/* 146 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level15));
/*     */     
/* 148 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no16));
/*     */     
/* 150 */     GameWriteTool.writeString(writeBuf, object1.name16);
/*     */     
/* 152 */     GameWriteTool.writeString(writeBuf, object1.desc16);
/*     */     
/* 154 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level16));
/*     */     
/* 156 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no17));
/*     */     
/* 158 */     GameWriteTool.writeString(writeBuf, object1.name17);
/*     */     
/* 160 */     GameWriteTool.writeString(writeBuf, object1.desc17);
/*     */     
/* 162 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level17));
/*     */     
/* 164 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no18));
/*     */     
/* 166 */     GameWriteTool.writeString(writeBuf, object1.name18);
/*     */     
/* 168 */     GameWriteTool.writeString(writeBuf, object1.desc18);
/*     */     
/* 170 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level18));
/*     */     
/* 172 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no19));
/*     */     
/* 174 */     GameWriteTool.writeString(writeBuf, object1.name19);
/*     */     
/* 176 */     GameWriteTool.writeString(writeBuf, object1.desc19);
/*     */     
/* 178 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level19));
/*     */     
/* 180 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no20));
/*     */     
/* 182 */     GameWriteTool.writeString(writeBuf, object1.name20);
/*     */     
/* 184 */     GameWriteTool.writeString(writeBuf, object1.desc20);
/*     */     
/* 186 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level20));
/*     */     
/* 188 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no21));
/*     */     
/* 190 */     GameWriteTool.writeString(writeBuf, object1.name21);
/*     */     
/* 192 */     GameWriteTool.writeString(writeBuf, object1.desc21);
/*     */     
/* 194 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level21));
/*     */     
/* 196 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no22));
/*     */     
/* 198 */     GameWriteTool.writeString(writeBuf, object1.name22);
/*     */     
/* 200 */     GameWriteTool.writeString(writeBuf, object1.desc22);
/*     */     
/* 202 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level22));
/*     */     
/* 204 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no23));
/*     */     
/* 206 */     GameWriteTool.writeString(writeBuf, object1.name23);
/*     */     
/* 208 */     GameWriteTool.writeString(writeBuf, object1.desc23);
/*     */     
/* 210 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level23));
/*     */     
/* 212 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no24));
/*     */     
/* 214 */     GameWriteTool.writeString(writeBuf, object1.name24);
/*     */     
/* 216 */     GameWriteTool.writeString(writeBuf, object1.desc24);
/*     */     
/* 218 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level24));
/*     */     
/* 220 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no25));
/*     */     
/* 222 */     GameWriteTool.writeString(writeBuf, object1.name25);
/*     */     
/* 224 */     GameWriteTool.writeString(writeBuf, object1.desc25);
/*     */     
/* 226 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level25));
/*     */     
/* 228 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no26));
/*     */     
/* 230 */     GameWriteTool.writeString(writeBuf, object1.name26);
/*     */     
/* 232 */     GameWriteTool.writeString(writeBuf, object1.desc26);
/*     */     
/* 234 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level26));
/*     */     
/* 236 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no27));
/*     */     
/* 238 */     GameWriteTool.writeString(writeBuf, object1.name27);
/*     */     
/* 240 */     GameWriteTool.writeString(writeBuf, object1.desc27);
/*     */     
/* 242 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level27));
/*     */     
/* 244 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no28));
/*     */     
/* 246 */     GameWriteTool.writeString(writeBuf, object1.name28);
/*     */     
/* 248 */     GameWriteTool.writeString(writeBuf, object1.desc28);
/*     */     
/* 250 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level28));
/*     */     
/* 252 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no29));
/*     */     
/* 254 */     GameWriteTool.writeString(writeBuf, object1.name29);
/*     */     
/* 256 */     GameWriteTool.writeString(writeBuf, object1.desc29);
/*     */     
/* 258 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level29));
/*     */     
/* 260 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no30));
/*     */     
/* 262 */     GameWriteTool.writeString(writeBuf, object1.name30);
/*     */     
/* 264 */     GameWriteTool.writeString(writeBuf, object1.desc30);
/*     */     
/* 266 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level30));
/*     */     
/* 268 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no31));
/*     */     
/* 270 */     GameWriteTool.writeString(writeBuf, object1.name31);
/*     */     
/* 272 */     GameWriteTool.writeString(writeBuf, object1.desc31);
/*     */     
/* 274 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level31));
/*     */     
/* 276 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no32));
/*     */     
/* 278 */     GameWriteTool.writeString(writeBuf, object1.name32);
/*     */     
/* 280 */     GameWriteTool.writeString(writeBuf, object1.desc32);
/*     */     
/* 282 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level32));
/*     */     
/* 284 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no33));
/*     */     
/* 286 */     GameWriteTool.writeString(writeBuf, object1.name33);
/*     */     
/* 288 */     GameWriteTool.writeString(writeBuf, object1.desc33);
/*     */     
/* 290 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level33));
/*     */     
/* 292 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no34));
/*     */     
/* 294 */     GameWriteTool.writeString(writeBuf, object1.name34);
/*     */     
/* 296 */     GameWriteTool.writeString(writeBuf, object1.desc34);
/*     */     
/* 298 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level34));
/*     */     
/* 300 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.no35));
/*     */     
/* 302 */     GameWriteTool.writeString(writeBuf, object1.name35);
/*     */     
/* 304 */     GameWriteTool.writeString(writeBuf, object1.desc35);
/*     */     
/* 306 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level35));
/*     */   }
/*     */   
/*     */   public int cmd()
/*     */   {
/* 311 */     return 45381;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M45381_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */