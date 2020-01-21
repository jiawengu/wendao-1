/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_4163_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_SET_CURRENT_PET;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class CMD_SELECT_CURRENT_PET implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 18 */     int id = GameReadTool.readInt(buff);
/*    */     //1:参战，2:掠阵
/* 20 */     int pet_status = GameReadTool.readShort(buff);
/*    */     
/* 22 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
            if(0 == pet_status){
                if(chara.chongwuchanzhanId == id){
                    chara.chongwuchanzhanId = 0;
                }
                if(chara.petLueZhenId == id){
                    chara.petLueZhenId = 0;
                }
            }else if(1 == pet_status){
                chara.chongwuchanzhanId = id;
            }else if(2 == pet_status){
                chara.petLueZhenId = id;
            }

/* 27 */     Vo_4163_0 vo_4163_0 = new Vo_4163_0();
/* 28 */     vo_4163_0.id = id;
/* 29 */     vo_4163_0.pet_status = pet_status;
/* 30 */     GameObjectChar.send(new MSG_SET_CURRENT_PET(), vo_4163_0);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 35 */     return 4162;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C4162_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */