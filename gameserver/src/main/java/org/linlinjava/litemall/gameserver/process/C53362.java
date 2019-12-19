package org.linlinjava.litemall.gameserver.process;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameReadTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_4275_0;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.linlinjava.litemall.gameserver.data.write.M53363_0;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;


@Service
public class C53362 implements GameHandler {

	public void process(ChannelHandlerContext ctx, ByteBuf buff)
 {
		
		Object vo_4275_0 = new Vo_4275_0();;
		ByteBuf write = new M53363_0().write(vo_4275_0);
		ctx.writeAndFlush(write);
 }


	public int cmd() {
		return 53362;
	}
}