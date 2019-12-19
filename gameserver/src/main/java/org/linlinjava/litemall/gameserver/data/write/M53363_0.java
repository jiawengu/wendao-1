package org.linlinjava.litemall.gameserver.data.write;


import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;

@org.springframework.stereotype.Service
public class M53363_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite{
	
	 protected void writeO(ByteBuf writeBuf, Object object)
	{
	  GameWriteTool.writeShort(writeBuf, 2);
	  GameWriteTool.writeString(writeBuf, "这是文本");
	  GameWriteTool.writeString(writeBuf, "这是文本2");
	 }
	 public int cmd() { return 53363; }
}
