package org.linlinjava.litemall.gameserver;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;

public abstract interface GameHandler
{
  public abstract void process(ChannelHandlerContext paramChannelHandlerContext, ByteBuf paramByteBuf);
  
  public abstract int cmd();
}


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\GameHandler.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */