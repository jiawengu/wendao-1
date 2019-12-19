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

public class SaleClassifyGood implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private String pname;
    private String cname;
    private String attrib;
    private Integer icon;
    private String str;
    private Integer price;
    private String compose;
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

    public SaleClassifyGood() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getPname() {
        return this.pname;
    }

    public void setPname(String pname) {
        this.pname = pname;
    }

    public String getCname() {
        return this.cname;
    }

    public void setCname(String cname) {
        this.cname = cname;
    }

    public String getAttrib() {
        return this.attrib;
    }

    public void setAttrib(String attrib) {
        this.attrib = attrib;
    }

    public Integer getIcon() {
        return this.icon;
    }

    public void setIcon(Integer icon) {
        this.icon = icon;
    }

    public String getStr() {
        return this.str;
    }

    public void setStr(String str) {
        this.str = str;
    }

    public Integer getPrice() {
        return this.price;
    }

    public void setPrice(Integer price) {
        this.price = price;
    }

    public String getCompose() {
        return this.compose;
    }

    public void setCompose(String compose) {
        this.compose = compose;
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
        this.setDeleted(deleted ? SaleClassifyGood.Deleted.IS_DELETED.value() : SaleClassifyGood.Deleted.NOT_DELETED.value());
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
        sb.append(", pname=").append(this.pname);
        sb.append(", cname=").append(this.cname);
        sb.append(", attrib=").append(this.attrib);
        sb.append(", icon=").append(this.icon);
        sb.append(", str=").append(this.str);
        sb.append(", price=").append(this.price);
        sb.append(", compose=").append(this.compose);
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
            label121: {
                label113: {
                    SaleClassifyGood other = (SaleClassifyGood)that;
                    if (this.getId() == null) {
                        if (other.getId() != null) {
                            break label113;
                        }
                    } else if (!this.getId().equals(other.getId())) {
                        break label113;
                    }

                    if (this.getPname() == null) {
                        if (other.getPname() != null) {
                            break label113;
                        }
                    } else if (!this.getPname().equals(other.getPname())) {
                        break label113;
                    }

                    if (this.getCname() == null) {
                        if (other.getCname() != null) {
                            break label113;
                        }
                    } else if (!this.getCname().equals(other.getCname())) {
                        break label113;
                    }

                    if (this.getAttrib() == null) {
                        if (other.getAttrib() != null) {
                            break label113;
                        }
                    } else if (!this.getAttrib().equals(other.getAttrib())) {
                        break label113;
                    }

                    if (this.getIcon() == null) {
                        if (other.getIcon() != null) {
                            break label113;
                        }
                    } else if (!this.getIcon().equals(other.getIcon())) {
                        break label113;
                    }

                    if (this.getStr() == null) {
                        if (other.getStr() != null) {
                            break label113;
                        }
                    } else if (!this.getStr().equals(other.getStr())) {
                        break label113;
                    }

                    if (this.getPrice() == null) {
                        if (other.getPrice() != null) {
                            break label113;
                        }
                    } else if (!this.getPrice().equals(other.getPrice())) {
                        break label113;
                    }

                    if (this.getCompose() == null) {
                        if (other.getCompose() != null) {
                            break label113;
                        }
                    } else if (!this.getCompose().equals(other.getCompose())) {
                        break label113;
                    }

                    if (this.getAddTime() == null) {
                        if (other.getAddTime() != null) {
                            break label113;
                        }
                    } else if (!this.getAddTime().equals(other.getAddTime())) {
                        break label113;
                    }

                    if (this.getUpdateTime() == null) {
                        if (other.getUpdateTime() != null) {
                            break label113;
                        }
                    } else if (!this.getUpdateTime().equals(other.getUpdateTime())) {
                        break label113;
                    }

                    if (this.getDeleted() == null) {
                        if (other.getDeleted() == null) {
                            break label121;
                        }
                    } else if (this.getDeleted().equals(other.getDeleted())) {
                        break label121;
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
        result = 31 * result + (this.getPname() == null ? 0 : this.getPname().hashCode());
        result = 31 * result + (this.getCname() == null ? 0 : this.getCname().hashCode());
        result = 31 * result + (this.getAttrib() == null ? 0 : this.getAttrib().hashCode());
        result = 31 * result + (this.getIcon() == null ? 0 : this.getIcon().hashCode());
        result = 31 * result + (this.getStr() == null ? 0 : this.getStr().hashCode());
        result = 31 * result + (this.getPrice() == null ? 0 : this.getPrice().hashCode());
        result = 31 * result + (this.getCompose() == null ? 0 : this.getCompose().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        return result;
    }

    public SaleClassifyGood clone() throws CloneNotSupportedException {
        return (SaleClassifyGood)super.clone();
    }

    static {
        IS_DELETED = SaleClassifyGood.Deleted.IS_DELETED.value();
        NOT_DELETED = SaleClassifyGood.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        pname("pname", "pname", "VARCHAR", false),
        cname("cname", "cname", "VARCHAR", false),
        attrib("attrib", "attrib", "VARCHAR", false),
        icon("icon", "icon", "INTEGER", false),
        str("str", "str", "VARCHAR", false),
        price("price", "price", "INTEGER", false),
        compose("compose", "compose", "VARCHAR", false),
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

        public static SaleClassifyGood.Column[] excludes(SaleClassifyGood.Column... excludes) {
            ArrayList<SaleClassifyGood.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (SaleClassifyGood.Column[])columns.toArray(new SaleClassifyGood.Column[0]);
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
