package org.linlinjava.litemall.core.util;

import com.qcloud.cos.utils.Md5Utils;
import org.json.JSONObject;
import org.linlinjava.litemall.db.domain.Accounts;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import java.io.IOException;
import java.math.BigInteger;
import java.security.Key;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class DesUtil
{
    public static String byteArr2HexStr(byte[] paramArrayOfByte)
            throws Exception
    {
        int i = 0;
        int k = paramArrayOfByte.length;
        StringBuffer localStringBuffer = new StringBuffer(k * 2);
        while (i < k)
        {
            int j = paramArrayOfByte[i];
            while (j < 0) {
                j += 256;
            }
            if (j < 16) {
                localStringBuffer.append("0");
            }
            localStringBuffer.append(Integer.toString(j, 16));
            i += 1;
        }
        return localStringBuffer.toString();
    }

    public static String decrypt(String paramString1, String paramString2)
    {
        Key key = getKey(paramString2.getBytes());
        try
        {
            paramString1 = new String(decrypt(hexStr2ByteArr(paramString1), key));
            return paramString1;
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
        return null;
    }

    public static byte[] decrypt(byte[] paramArrayOfByte, Key paramKey)
            throws Exception
    {
        Cipher localCipher = Cipher.getInstance("DES");
        localCipher.init(2, paramKey);
        return localCipher.doFinal(paramArrayOfByte);
    }

    public static String encrypt(String paramString1, String paramString2)
    {
        Key key = getKey(paramString2.getBytes());
        try
        {
            paramString1 = byteArr2HexStr(encrypt(paramString1.getBytes(), key));
            return paramString1;
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
        return null;
    }

    public static byte[] encrypt(byte[] paramArrayOfByte, Key paramKey)
            throws Exception
    {
        Cipher localCipher = Cipher.getInstance("DES");
        localCipher.init(1, paramKey);
        return localCipher.doFinal(paramArrayOfByte);
    }

    private static Key getKey(byte[] paramArrayOfByte)
    {
        byte[] arrayOfByte = new byte[8];
        int i = 0;
        while ((i < paramArrayOfByte.length) && (i < arrayOfByte.length))
        {
            arrayOfByte[i] = paramArrayOfByte[i];
            i += 1;
        }
        return new SecretKeySpec(arrayOfByte, "DES");
    }

    public static byte[] hexStr2ByteArr(String paramString)
            throws Exception
    {
        final byte[] bytes = paramString.getBytes();
        int i = 0;
        int j = bytes.length;
        byte[] arrayOfByte = new byte[j / 2];
        while (i < j)
        {
            String str = new String(bytes, i, 2);
            arrayOfByte[(i / 2)] = ((byte)Integer.parseInt(str, 16));
            i += 2;
        }
        return arrayOfByte;
    }

    public static void main(String[] args) throws IOException {
     String a = "{\"account\":\"1100011100017da282b4-53b4-4c42-9f09-5592e43bfa1d\"}";//1100017da282b4-53b4-4c42-9f09-5592e43bfa1d

        JSONObject jo = new JSONObject(a);
        String o = (String) jo.get("account");
        String substring = o.substring(6);
        /* 26 */

        System.out.println(substring);
//        ClassPathResource res = new ClassPathResource("sdkConfigold.properties");
//        final String path = res.getURL().getPath();
//        FileReader reader = new FileReader(path);
//        BufferedReader br = new BufferedReader(reader);
//        String str = br.readLine();
//        while(str!=null){
//            final String[] split = str.split("=");
//            if(split.length==1){
//                str = br.readLine();
//                continue;
//            }
//            if(split[1].length()<50){
//                str = br.readLine();
//                continue;
//            }
//            System.out.println(split[0]);
//            final String decrypt = decrypt(split[1], "548711fdc20a2129");
//            System.out.println(decrypt);
//            str = br.readLine();
//        }




    }

    public static  void zhuanhuan(){
        //定义一个十进制值
        int valueTen = 328;
        //将其转换为十六进制并输出
        String strHex = Integer.toHexString(valueTen);
        System.out.println(valueTen + " [十进制]---->[十六进制] " + strHex);
        //将十六进制格式化输出
        String strHex2 = String.format("%08x",valueTen);
        System.out.println(valueTen + " [十进制]---->[十六进制] " + strHex2);

        System.out.println("==========================================================");
        //定义一个十六进制值
        String strHex3 = "00001322";
        //将十六进制转化成十进制
        int valueTen2 = Integer.parseInt(strHex3,16);
        System.out.println(strHex3 + " [十六进制]---->[十进制] " + valueTen2);

        System.out.println("==========================================================");
        //可以在声明十进制时，自动完成十六进制到十进制的转换
        int valueHex = 0x00001322;
        System.out.println("int valueHex = 0x00001322 --> " + valueHex);

    }

    public static String stringToMD5(String plainText) {
        byte[] secretBytes = null;
        try {
            secretBytes = MessageDigest.getInstance("md5").digest(
                    plainText.getBytes());
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("没有这个md5算法！");
        }
        String md5code = new BigInteger(1, secretBytes).toString(16);
        for (int i = 0; i < 32 - md5code.length(); i++) {
            md5code = "0" + md5code;
        }
        return md5code;
    }

}
