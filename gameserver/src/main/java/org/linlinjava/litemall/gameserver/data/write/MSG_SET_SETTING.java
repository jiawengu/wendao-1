/*     */ package org.linlinjava.litemall.gameserver.data.write;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61589_0;
/*     */ 
/*     */ @org.springframework.stereotype.Service
/*     */ public class MSG_SET_SETTING extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*     */ {
/*     */   protected void writeO(ByteBuf writeBuf, Object object)
/*     */   {
/*  12 */     Vo_61589_0 object1 = (Vo_61589_0)object;
/*  13 */     GameWriteTool.writeString(writeBuf, object1.key0);
/*     */     
/*  15 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey0));
/*     */     
/*  17 */     GameWriteTool.writeString(writeBuf, object1.key1);
/*     */     
/*  19 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey1));
/*     */     
/*  21 */     GameWriteTool.writeString(writeBuf, object1.key2);
/*     */     
/*  23 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey2));
/*     */     
/*  25 */     GameWriteTool.writeString(writeBuf, object1.key3);
/*     */     
/*  27 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey3));
/*     */     
/*  29 */     GameWriteTool.writeString(writeBuf, object1.key4);
/*     */     
/*  31 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey4));
/*     */     
/*  33 */     GameWriteTool.writeString(writeBuf, object1.key5);
/*     */     
/*  35 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey5));
/*     */     
/*  37 */     GameWriteTool.writeString(writeBuf, object1.key6);
/*     */     
/*  39 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey6));
/*     */     
/*  41 */     GameWriteTool.writeString(writeBuf, object1.key7);
/*     */     
/*  43 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey7));
/*     */     
/*  45 */     GameWriteTool.writeString(writeBuf, object1.key8);
/*     */     
/*  47 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey8));
/*     */     
/*  49 */     GameWriteTool.writeString(writeBuf, object1.key9);
/*     */     
/*  51 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey9));
/*     */     
/*  53 */     GameWriteTool.writeString(writeBuf, object1.key10);
/*     */     
/*  55 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey10));
/*     */     
/*  57 */     GameWriteTool.writeString(writeBuf, object1.key11);
/*     */     
/*  59 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey11));
/*     */     
/*  61 */     GameWriteTool.writeString(writeBuf, object1.key12);
/*     */     
/*  63 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey12));
/*     */     
/*  65 */     GameWriteTool.writeString(writeBuf, object1.key13);
/*     */     
/*  67 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey13));
/*     */     
/*  69 */     GameWriteTool.writeString(writeBuf, object1.key14);
/*     */     
/*  71 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey14));
/*     */     
/*  73 */     GameWriteTool.writeString(writeBuf, object1.key15);
/*     */     
/*  75 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey15));
/*     */     
/*  77 */     GameWriteTool.writeString(writeBuf, object1.key16);
/*     */     
/*  79 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey16));
/*     */     
/*  81 */     GameWriteTool.writeString(writeBuf, object1.key17);
/*     */     
/*  83 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey17));
/*     */     
/*  85 */     GameWriteTool.writeString(writeBuf, object1.key18);
/*     */     
/*  87 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey18));
/*     */     
/*  89 */     GameWriteTool.writeString(writeBuf, object1.key19);
/*     */     
/*  91 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey19));
/*     */     
/*  93 */     GameWriteTool.writeString(writeBuf, object1.key20);
/*     */     
/*  95 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey20));
/*     */     
/*  97 */     GameWriteTool.writeString(writeBuf, object1.key21);
/*     */     
/*  99 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey21));
/*     */     
/* 101 */     GameWriteTool.writeString(writeBuf, object1.key22);
/*     */     
/* 103 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey22));
/*     */     
/* 105 */     GameWriteTool.writeString(writeBuf, object1.key23);
/*     */     
/* 107 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey23));
/*     */     
/* 109 */     GameWriteTool.writeString(writeBuf, object1.key24);
/*     */     
/* 111 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey24));
/*     */     
/* 113 */     GameWriteTool.writeString(writeBuf, object1.key25);
/*     */     
/* 115 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey25));
/*     */     
/* 117 */     GameWriteTool.writeString(writeBuf, object1.key26);
/*     */     
/* 119 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey26));
/*     */     
/* 121 */     GameWriteTool.writeString(writeBuf, object1.key27);
/*     */     
/* 123 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey27));
/*     */     
/* 125 */     GameWriteTool.writeString(writeBuf, object1.key28);
/*     */     
/* 127 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey28));
/*     */     
/* 129 */     GameWriteTool.writeString(writeBuf, object1.key29);
/*     */     
/* 131 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey29));
/*     */     
/* 133 */     GameWriteTool.writeString(writeBuf, object1.key30);
/*     */     
/* 135 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey30));
/*     */     
/* 137 */     GameWriteTool.writeString(writeBuf, object1.key31);
/*     */     
/* 139 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey31));
/*     */     
/* 141 */     GameWriteTool.writeString(writeBuf, object1.key32);
/*     */     
/* 143 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey32));
/*     */     
/* 145 */     GameWriteTool.writeString(writeBuf, object1.key33);
/*     */     
/* 147 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey33));
/*     */     
/* 149 */     GameWriteTool.writeString(writeBuf, object1.key34);
/*     */     
/* 151 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey34));
/*     */     
/* 153 */     GameWriteTool.writeString(writeBuf, object1.key35);
/*     */     
/* 155 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey35));
/*     */     
/* 157 */     GameWriteTool.writeString(writeBuf, object1.key36);
/*     */     
/* 159 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey36));
/*     */     
/* 161 */     GameWriteTool.writeString(writeBuf, object1.key37);
/*     */     
/* 163 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey37));
/*     */     
/* 165 */     GameWriteTool.writeString(writeBuf, object1.key38);
/*     */     
/* 167 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey38));
/*     */     
/* 169 */     GameWriteTool.writeString(writeBuf, object1.key39);
/*     */     
/* 171 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey39));
/*     */     
/* 173 */     GameWriteTool.writeString(writeBuf, object1.key40);
/*     */     
/* 175 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey40));
/*     */     
/* 177 */     GameWriteTool.writeString(writeBuf, object1.key41);
/*     */     
/* 179 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey41));
/*     */     
/* 181 */     GameWriteTool.writeString(writeBuf, object1.key42);
/*     */     
/* 183 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey42));
/*     */     
/* 185 */     GameWriteTool.writeString(writeBuf, object1.key43);
/*     */     
/* 187 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey43));
/*     */     
/* 189 */     GameWriteTool.writeString(writeBuf, object1.key44);
/*     */     
/* 191 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey44));
/*     */     
/* 193 */     GameWriteTool.writeString(writeBuf, object1.key45);
/*     */     
/* 195 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey45));
/*     */     
/* 197 */     GameWriteTool.writeString(writeBuf, object1.key46);
/*     */     
/* 199 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey46));
/*     */     
/* 201 */     GameWriteTool.writeString(writeBuf, object1.key47);
/*     */     
/* 203 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey47));
/*     */     
/* 205 */     GameWriteTool.writeString(writeBuf, object1.key48);
/*     */     
/* 207 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey48));
/*     */     
/* 209 */     GameWriteTool.writeString(writeBuf, object1.key49);
/*     */     
/* 211 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey49));
/*     */     
/* 213 */     GameWriteTool.writeString(writeBuf, object1.key50);
/*     */     
/* 215 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey50));
/*     */     
/* 217 */     GameWriteTool.writeString(writeBuf, object1.key51);
/*     */     
/* 219 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey51));
/*     */     
/* 221 */     GameWriteTool.writeString(writeBuf, object1.key52);
/*     */     
/* 223 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey52));
/*     */     
/* 225 */     GameWriteTool.writeString(writeBuf, object1.key53);
/*     */     
/* 227 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey53));
/*     */     
/* 229 */     GameWriteTool.writeString(writeBuf, object1.key54);
/*     */     
/* 231 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey54));
/*     */     
/* 233 */     GameWriteTool.writeString(writeBuf, object1.key55);
/*     */     
/* 235 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey55));
/*     */     
/* 237 */     GameWriteTool.writeString(writeBuf, object1.key56);
/*     */     
/* 239 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey56));
/*     */     
/* 241 */     GameWriteTool.writeString(writeBuf, object1.key57);
/*     */     
/* 243 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey57));
/*     */     
/* 245 */     GameWriteTool.writeString(writeBuf, object1.key58);
/*     */     
/* 247 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey58));
/*     */     
/* 249 */     GameWriteTool.writeString(writeBuf, object1.key59);
/*     */     
/* 251 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey59));
/*     */     
/* 253 */     GameWriteTool.writeString(writeBuf, object1.key60);
/*     */     
/* 255 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.settingkey60));
/*     */   }
/*     */   
/* 258 */   public int cmd() { return 61589; }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M61589_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */