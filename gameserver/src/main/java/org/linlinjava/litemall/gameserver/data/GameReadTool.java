/*    */
package org.linlinjava.litemall.gameserver.data;
/*    */
/*    */

import io.netty.buffer.ByteBuf;
/*    */ import io.netty.buffer.Unpooled;
/*    */ import java.nio.charset.Charset;

/*    */
/*    */ public class GameReadTool
        /*    */ {
    /*  9 */   public static final Charset DEFAULT_CHARSET = Charset.forName("GBK");

    /*    */
    /*    */
    public static String readString(ByteBuf cb) throws IndexOutOfBoundsException {
        /* 12 */
        int lenght = readUnsignedByte(cb);
        /* 13 */
        if (lenght == 0) {
            /* 14 */
            return "";
            /*    */
        }
    /*    byte[] strByte2 = new byte[lenght];
        cb.readBytes(strByte2);*/
        /* 16 */
        if ((lenght > 0) && (lenght <= cb.readableBytes())) {
            /* 17 */
            byte[] strByte = new byte[lenght];
            /* 18 */
            cb.readBytes(strByte);
            /* 19 */
            return readString(strByte);
            /*    */
        }
        /* 21 */
        throw new IndexOutOfBoundsException("字符串长度不够 ! ");
//        return "";
        /*    */
    }

    /*    */
    /*    */
    public static String readString2(ByteBuf cb) throws IndexOutOfBoundsException {
        int lenght = cb.readUnsignedShort();
        if (lenght == 0) {
            return "";
        }
        if ((lenght > 0) && (lenght <= cb.readableBytes())) {
            byte[] strByte = new byte[lenght];
            cb.readBytes(strByte);
            return readString(strByte);
        }
        /* 34 */
        throw new IndexOutOfBoundsException("字符串长度不够 ! ");
        /*    */
    }

    /*    */
    /*    */
    public static String readString(byte[] bytes) {
        /* 38 */
        return new String(bytes, DEFAULT_CHARSET);
        /*    */
    }

    /*    */
    /* 41 */
    public static String readString(byte[] bytes, int length) {
        return new String(bytes, 0, length, DEFAULT_CHARSET);
    }

    /*    */
    /*    */
    public static int readUnsignedByte(ByteBuf cb) {
        /* 44 */
        return cb.readUnsignedByte();
        /*    */
    }

    /*    */
    /* 47 */
    public static int readInt(ByteBuf cb) {
        return cb.readInt();
    }

    /*    */
    /*    */
    public static int readByte(ByteBuf cb) {
        /* 50 */
        return cb.readUnsignedByte();
        /*    */
    }

    /*    */
    /* 53 */
    public static int readShort(ByteBuf cb) {
        return cb.readUnsignedShort();
    }

    /*    */
    /*    */
    public static ByteBuf readLenBuffer2(ByteBuf cb) {
        /* 56 */
        int len = cb.readUnsignedShort();
        /* 57 */
        ByteBuf byteBuf = Unpooled.buffer(len);
        /* 58 */
        cb.readBytes(byteBuf);
        /* 59 */
        return byteBuf;
        /*    */
    }
    /*    */
}


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\GameReadTool.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */