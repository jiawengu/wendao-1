/*    */ package org.linlinjava.litemall.gameserver.data;
/*    */ 
/*    */ import java.io.PrintStream;
/*    */ 
/*    */ public class Test {
/*  6 */   public static void main(String[] args) { String arr = "多闻道人";
/*  7 */     byte[] sb = arr.getBytes();
/*    */     
/*  9 */     System.out.println(bytesToHexString(sb));
/*    */   }
/*    */   
/*    */   public static String bytesToHexString(byte[] src) {
/* 13 */     StringBuilder stringBuilder = new StringBuilder("");
/* 14 */     if ((src == null) || (src.length <= 0)) {
/* 15 */       return null;
/*    */     }
/* 17 */     for (int i = 0; i < src.length; i++) {
/* 18 */       int v = src[i] & 0xFF;
/* 19 */       String hv = Integer.toHexString(v);
/* 20 */       if (hv.length() < 2) {
/* 21 */         stringBuilder.append(0);
/*    */       }
/* 23 */       stringBuilder.append(hv);
/*    */     }
/* 25 */     return stringBuilder.toString();
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\Test.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */