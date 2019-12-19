//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import org.springframework.format.annotation.DateTimeFormat;

public class ZhuangbeiInfo implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private Integer attrib;
    private Integer amount;
    private Integer type;
    private String str;
    private String quality;
    private Integer master;
    private Integer metal;
    private Integer mana;
    private Integer accurate;
    private Integer def;
    private Integer dex;
    private Integer wiz;
    private Integer parry;
    @JsonDeserialize(
            using = LocalDateTimeDeserializer.class
    )
    @JsonSerialize(
            using = LocalDateTimeSerializer.class
    )
    @DateTimeFormat(
            pattern = "yyyy-MM-dd HH:mm:ss"
    )
    private LocalDateTime addTime;
    @JsonDeserialize(
            using = LocalDateTimeDeserializer.class
    )
    @JsonSerialize(
            using = LocalDateTimeSerializer.class
    )
    @DateTimeFormat(
            pattern = "yyyy-MM-dd HH:mm:ss"
    )
    private LocalDateTime updateTime;
    private Boolean deleted;
    private static final long serialVersionUID = 1L;

    public ZhuangbeiInfo() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getAttrib() {
        return this.attrib;
    }

    public void setAttrib(Integer attrib) {
        this.attrib = attrib;
    }

    public Integer getAmount() {
        return this.amount;
    }

    public void setAmount(Integer amount) {
        this.amount = amount;
    }

    public Integer getType() {
        return this.type;
    }

    public void setType(Integer type) {
        this.type = type;
    }

    public String getStr() {
        return this.str;
    }

    public void setStr(String str) {
        this.str = str;
    }

    public String getQuality() {
        return this.quality;
    }

    public void setQuality(String quality) {
        this.quality = quality;
    }

    public Integer getMaster() {
        return this.master;
    }

    public void setMaster(Integer master) {
        this.master = master;
    }

    public Integer getMetal() {
        return this.metal;
    }

    public void setMetal(Integer metal) {
        this.metal = metal;
    }

    public Integer getMana() {
        return this.mana;
    }

    public void setMana(Integer mana) {
        this.mana = mana;
    }

    public Integer getAccurate() {
        return this.accurate;
    }

    public void setAccurate(Integer accurate) {
        this.accurate = accurate;
    }

    public Integer getDef() {
        return this.def;
    }

    public void setDef(Integer def) {
        this.def = def;
    }

    public Integer getDex() {
        return this.dex;
    }

    public void setDex(Integer dex) {
        this.dex = dex;
    }

    public Integer getWiz() {
        return this.wiz;
    }

    public void setWiz(Integer wiz) {
        this.wiz = wiz;
    }

    public Integer getParry() {
        return this.parry;
    }

    public void setParry(Integer parry) {
        this.parry = parry;
    }

    public LocalDateTime getAddTime() {
        return this.addTime;
    }

    public void setAddTime(LocalDateTime addTime) {
        this.addTime = addTime;
    }

    public LocalDateTime getUpdateTime() {
        return this.updateTime;
    }

    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }

    public void andLogicalDeleted(boolean deleted) {
        this.setDeleted(deleted ? ZhuangbeiInfo.Deleted.IS_DELETED.value() : ZhuangbeiInfo.Deleted.NOT_DELETED.value());
    }

    public Boolean getDeleted() {
        return this.deleted;
    }

    public void setDeleted(Boolean deleted) {
        this.deleted = deleted;
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(this.getClass().getSimpleName());
        sb.append(" [");
        sb.append("Hash = ").append(this.hashCode());
        sb.append(", IS_DELETED=").append(IS_DELETED);
        sb.append(", NOT_DELETED=").append(NOT_DELETED);
        sb.append(", id=").append(this.id);
        sb.append(", attrib=").append(this.attrib);
        sb.append(", amount=").append(this.amount);
        sb.append(", type=").append(this.type);
        sb.append(", str=").append(this.str);
        sb.append(", quality=").append(this.quality);
        sb.append(", master=").append(this.master);
        sb.append(", metal=").append(this.metal);
        sb.append(", mana=").append(this.mana);
        sb.append(", accurate=").append(this.accurate);
        sb.append(", def=").append(this.def);
        sb.append(", dex=").append(this.dex);
        sb.append(", wiz=").append(this.wiz);
        sb.append(", parry=").append(this.parry);
        sb.append(", addTime=").append(this.addTime);
        sb.append(", updateTime=").append(this.updateTime);
        sb.append(", deleted=").append(this.deleted);
        sb.append("]");
        return sb.toString();
    }

    public boolean equals(Object that) {
        if (this == that) {
            return true;
        } else if (that == null) {
            return false;
        } else if (this.getClass() != that.getClass()) {
            return false;
        } else {
            boolean var10000;
            label169: {
                label161: {
                    ZhuangbeiInfo other = (ZhuangbeiInfo)that;
                    if (this.getId() == null) {
                        if (other.getId() != null) {
                            break label161;
                        }
                    } else if (!this.getId().equals(other.getId())) {
                        break label161;
                    }

                    if (this.getAttrib() == null) {
                        if (other.getAttrib() != null) {
                            break label161;
                        }
                    } else if (!this.getAttrib().equals(other.getAttrib())) {
                        break label161;
                    }

                    if (this.getAmount() == null) {
                        if (other.getAmount() != null) {
                            break label161;
                        }
                    } else if (!this.getAmount().equals(other.getAmount())) {
                        break label161;
                    }

                    if (this.getType() == null) {
                        if (other.getType() != null) {
                            break label161;
                        }
                    } else if (!this.getType().equals(other.getType())) {
                        break label161;
                    }

                    if (this.getStr() == null) {
                        if (other.getStr() != null) {
                            break label161;
                        }
                    } else if (!this.getStr().equals(other.getStr())) {
                        break label161;
                    }

                    if (this.getQuality() == null) {
                        if (other.getQuality() != null) {
                            break label161;
                        }
                    } else if (!this.getQuality().equals(other.getQuality())) {
                        break label161;
                    }

                    if (this.getMaster() == null) {
                        if (other.getMaster() != null) {
                            break label161;
                        }
                    } else if (!this.getMaster().equals(other.getMaster())) {
                        break label161;
                    }

                    if (this.getMetal() == null) {
                        if (other.getMetal() != null) {
                            break label161;
                        }
                    } else if (!this.getMetal().equals(other.getMetal())) {
                        break label161;
                    }

                    if (this.getMana() == null) {
                        if (other.getMana() != null) {
                            break label161;
                        }
                    } else if (!this.getMana().equals(other.getMana())) {
                        break label161;
                    }

                    if (this.getAccurate() == null) {
                        if (other.getAccurate() != null) {
                            break label161;
                        }
                    } else if (!this.getAccurate().equals(other.getAccurate())) {
                        break label161;
                    }

                    if (this.getDef() == null) {
                        if (other.getDef() != null) {
                            break label161;
                        }
                    } else if (!this.getDef().equals(other.getDef())) {
                        break label161;
                    }

                    if (this.getDex() == null) {
                        if (other.getDex() != null) {
                            break label161;
                        }
                    } else if (!this.getDex().equals(other.getDex())) {
                        break label161;
                    }

                    if (this.getWiz() == null) {
                        if (other.getWiz() != null) {
                            break label161;
                        }
                    } else if (!this.getWiz().equals(other.getWiz())) {
                        break label161;
                    }

                    if (this.getParry() == null) {
                        if (other.getParry() != null) {
                            break label161;
                        }
                    } else if (!this.getParry().equals(other.getParry())) {
                        break label161;
                    }

                    if (this.getAddTime() == null) {
                        if (other.getAddTime() != null) {
                            break label161;
                        }
                    } else if (!this.getAddTime().equals(other.getAddTime())) {
                        break label161;
                    }

                    if (this.getUpdateTime() == null) {
                        if (other.getUpdateTime() != null) {
                            break label161;
                        }
                    } else if (!this.getUpdateTime().equals(other.getUpdateTime())) {
                        break label161;
                    }

                    if (this.getDeleted() == null) {
                        if (other.getDeleted() == null) {
                            break label169;
                        }
                    } else if (this.getDeleted().equals(other.getDeleted())) {
                        break label169;
                    }
                }

                var10000 = false;
                return var10000;
            }

            var10000 = true;
            return var10000;
        }
    }

    public int hashCode() {
        int result = 1;
        result = 31 * result + (this.getId() == null ? 0 : this.getId().hashCode());
        result = 31 * result + (this.getAttrib() == null ? 0 : this.getAttrib().hashCode());
        result = 31 * result + (this.getAmount() == null ? 0 : this.getAmount().hashCode());
        result = 31 * result + (this.getType() == null ? 0 : this.getType().hashCode());
        result = 31 * result + (this.getStr() == null ? 0 : this.getStr().hashCode());
        result = 31 * result + (this.getQuality() == null ? 0 : this.getQuality().hashCode());
        result = 31 * result + (this.getMaster() == null ? 0 : this.getMaster().hashCode());
        result = 31 * result + (this.getMetal() == null ? 0 : this.getMetal().hashCode());
        result = 31 * result + (this.getMana() == null ? 0 : this.getMana().hashCode());
        result = 31 * result + (this.getAccurate() == null ? 0 : this.getAccurate().hashCode());
        result = 31 * result + (this.getDef() == null ? 0 : this.getDef().hashCode());
        result = 31 * result + (this.getDex() == null ? 0 : this.getDex().hashCode());
        result = 31 * result + (this.getWiz() == null ? 0 : this.getWiz().hashCode());
        result = 31 * result + (this.getParry() == null ? 0 : this.getParry().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        return result;
    }

    public ZhuangbeiInfo clone() throws CloneNotSupportedException {
        return (ZhuangbeiInfo)super.clone();
    }

    static {
        IS_DELETED = ZhuangbeiInfo.Deleted.IS_DELETED.value();
        NOT_DELETED = ZhuangbeiInfo.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        attrib("attrib", "attrib", "INTEGER", false),
        amount("amount", "amount", "INTEGER", false),
        type("type", "type", "INTEGER", true),
        str("str", "str", "VARCHAR", false),
        quality("quality", "quality", "VARCHAR", false),
        master("master", "master", "INTEGER", false),
        metal("metal", "metal", "INTEGER", false),
        mana("mana", "mana", "INTEGER", false),
        accurate("accurate", "accurate", "INTEGER", false),
        def("def", "def", "INTEGER", false),
        dex("dex", "dex", "INTEGER", false),
        wiz("wiz", "wiz", "INTEGER", false),
        parry("parry", "parry", "INTEGER", false),
        addTime("add_time", "addTime", "TIMESTAMP", false),
        updateTime("update_time", "updateTime", "TIMESTAMP", false),
        deleted("deleted", "deleted", "BIT", false);

        private static final String BEGINNING_DELIMITER = "`";
        private static final String ENDING_DELIMITER = "`";
        private final String column;
        private final boolean isColumnNameDelimited;
        private final String javaProperty;
        private final String jdbcType;

        public String value() {
            return this.column;
        }

        public String getValue() {
            return this.column;
        }

        public String getJavaProperty() {
            return this.javaProperty;
        }

        public String getJdbcType() {
            return this.jdbcType;
        }

        private Column(String column, String javaProperty, String jdbcType, boolean isColumnNameDelimited) {
            this.column = column;
            this.javaProperty = javaProperty;
            this.jdbcType = jdbcType;
            this.isColumnNameDelimited = isColumnNameDelimited;
        }

        public String desc() {
            return this.getEscapedColumnName() + " DESC";
        }

        public String asc() {
            return this.getEscapedColumnName() + " ASC";
        }

        public static ZhuangbeiInfo.Column[] excludes(ZhuangbeiInfo.Column... excludes) {
            ArrayList<ZhuangbeiInfo.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (ZhuangbeiInfo.Column[])columns.toArray(new ZhuangbeiInfo.Column[0]);
        }

        public String getEscapedColumnName() {
            return this.isColumnNameDelimited ? "`" + this.column + "`" : this.column;
        }
    }

    public static enum Deleted {
        NOT_DELETED(new Boolean("0"), "未删除"),
        IS_DELETED(new Boolean("1"), "已删除");

        private final Boolean value;
        private final String name;

        private Deleted(Boolean value, String name) {
            this.value = value;
            this.name = name;
        }

        public Boolean getValue() {
            return this.value;
        }

        public Boolean value() {
            return this.value;
        }

        public String getName() {
            return this.name;
        }
    }
}
