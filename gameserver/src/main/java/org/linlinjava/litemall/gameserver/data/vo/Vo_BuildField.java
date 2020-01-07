package org.linlinjava.litemall.gameserver.data.vo;

public class Vo_BuildField {
    public static final int FIELD_INT8 = 1;
    public static final int FIELD_INT16 = 2;
    public static final int FIELD_INT32 = 3;
    public static final int FIELD_STRING = 4;
    public static final int FIELD_LONGSTRING = 5;
    public static final int FIELD_UINT8 = 6;
    public static final int FIELD_UINT16 = 7;
    public static final int FIELD_UINT32 = 8;

    public int type = 0;
    public int field_no = 0;
    public int int_data;
    public String str_data;

    public Vo_BuildField(int type, int field_no, int int_data){
        this.type = type;
        this.field_no = field_no;
        this.int_data = int_data;
    }

    public Vo_BuildField(int type, int field_no, String str_data){
        this.type = type;
        this.field_no = field_no;
        this.str_data = str_data;
    }


    public static Vo_BuildField int8(int field_no, int int_data){ return new Vo_BuildField(Vo_BuildField.FIELD_INT8, field_no, int_data); }
    public static Vo_BuildField int16(int field_no, int int_data){ return new Vo_BuildField(Vo_BuildField.FIELD_INT16, field_no, int_data); }
    public static Vo_BuildField int32(int field_no, int int_data){ return new Vo_BuildField(Vo_BuildField.FIELD_INT32, field_no, int_data); }
    public static Vo_BuildField uint8(int field_no, int int_data){ return new Vo_BuildField(Vo_BuildField.FIELD_UINT8, field_no, int_data); }
    public static Vo_BuildField uint16(int field_no, int int_data){ return new Vo_BuildField(Vo_BuildField.FIELD_UINT16, field_no, int_data); }
    public static Vo_BuildField uint32(int field_no, int int_data){ return new Vo_BuildField(Vo_BuildField.FIELD_UINT32, field_no, int_data); }
    public static Vo_BuildField stringc(int field_no, String str_data){ return new Vo_BuildField(Vo_BuildField.FIELD_STRING, field_no, str_data); }
    public static Vo_BuildField lstringc(int field_no, String str_data){ return new Vo_BuildField(Vo_BuildField.FIELD_LONGSTRING, field_no, str_data); }

}
