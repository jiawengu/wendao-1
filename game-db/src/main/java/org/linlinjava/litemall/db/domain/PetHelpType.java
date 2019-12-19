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

public class PetHelpType implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private Integer type;
    private String name;
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
    private Integer quality;
    private Integer money;
    private Integer polar;
    private static final long serialVersionUID = 1L;

    public PetHelpType() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getType() {
        return this.type;
    }

    public void setType(Integer type) {
        this.type = type;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;
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
        this.setDeleted(deleted ? PetHelpType.Deleted.IS_DELETED.value() : PetHelpType.Deleted.NOT_DELETED.value());
    }

    public Boolean getDeleted() {
        return this.deleted;
    }

    public void setDeleted(Boolean deleted) {
        this.deleted = deleted;
    }

    public Integer getQuality() {
        return this.quality;
    }

    public void setQuality(Integer quality) {
        this.quality = quality;
    }

    public Integer getMoney() {
        return this.money;
    }

    public void setMoney(Integer money) {
        this.money = money;
    }

    public Integer getPolar() {
        return this.polar;
    }

    public void setPolar(Integer polar) {
        this.polar = polar;
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(this.getClass().getSimpleName());
        sb.append(" [");
        sb.append("Hash = ").append(this.hashCode());
        sb.append(", IS_DELETED=").append(IS_DELETED);
        sb.append(", NOT_DELETED=").append(NOT_DELETED);
        sb.append(", id=").append(this.id);
        sb.append(", type=").append(this.type);
        sb.append(", name=").append(this.name);
        sb.append(", addTime=").append(this.addTime);
        sb.append(", updateTime=").append(this.updateTime);
        sb.append(", deleted=").append(this.deleted);
        sb.append(", quality=").append(this.quality);
        sb.append(", money=").append(this.money);
        sb.append(", polar=").append(this.polar);
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
            label105: {
                label97: {
                    PetHelpType other = (PetHelpType)that;
                    if (this.getId() == null) {
                        if (other.getId() != null) {
                            break label97;
                        }
                    } else if (!this.getId().equals(other.getId())) {
                        break label97;
                    }

                    if (this.getType() == null) {
                        if (other.getType() != null) {
                            break label97;
                        }
                    } else if (!this.getType().equals(other.getType())) {
                        break label97;
                    }

                    if (this.getName() == null) {
                        if (other.getName() != null) {
                            break label97;
                        }
                    } else if (!this.getName().equals(other.getName())) {
                        break label97;
                    }

                    if (this.getAddTime() == null) {
                        if (other.getAddTime() != null) {
                            break label97;
                        }
                    } else if (!this.getAddTime().equals(other.getAddTime())) {
                        break label97;
                    }

                    if (this.getUpdateTime() == null) {
                        if (other.getUpdateTime() != null) {
                            break label97;
                        }
                    } else if (!this.getUpdateTime().equals(other.getUpdateTime())) {
                        break label97;
                    }

                    if (this.getDeleted() == null) {
                        if (other.getDeleted() != null) {
                            break label97;
                        }
                    } else if (!this.getDeleted().equals(other.getDeleted())) {
                        break label97;
                    }

                    if (this.getQuality() == null) {
                        if (other.getQuality() != null) {
                            break label97;
                        }
                    } else if (!this.getQuality().equals(other.getQuality())) {
                        break label97;
                    }

                    if (this.getMoney() == null) {
                        if (other.getMoney() != null) {
                            break label97;
                        }
                    } else if (!this.getMoney().equals(other.getMoney())) {
                        break label97;
                    }

                    if (this.getPolar() == null) {
                        if (other.getPolar() == null) {
                            break label105;
                        }
                    } else if (this.getPolar().equals(other.getPolar())) {
                        break label105;
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
        result = 31 * result + (this.getType() == null ? 0 : this.getType().hashCode());
        result = 31 * result + (this.getName() == null ? 0 : this.getName().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        result = 31 * result + (this.getQuality() == null ? 0 : this.getQuality().hashCode());
        result = 31 * result + (this.getMoney() == null ? 0 : this.getMoney().hashCode());
        result = 31 * result + (this.getPolar() == null ? 0 : this.getPolar().hashCode());
        return result;
    }

    public PetHelpType clone() throws CloneNotSupportedException {
        return (PetHelpType)super.clone();
    }

    static {
        IS_DELETED = PetHelpType.Deleted.IS_DELETED.value();
        NOT_DELETED = PetHelpType.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        type("type", "type", "INTEGER", true),
        name("name", "name", "VARCHAR", true),
        addTime("add_time", "addTime", "TIMESTAMP", false),
        updateTime("update_time", "updateTime", "TIMESTAMP", false),
        deleted("deleted", "deleted", "BIT", false),
        quality("quality", "quality", "INTEGER", false),
        money("money", "money", "INTEGER", false),
        polar("polar", "polar", "INTEGER", false);

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

        public static PetHelpType.Column[] excludes(PetHelpType.Column... excludes) {
            ArrayList<PetHelpType.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (PetHelpType.Column[])columns.toArray(new PetHelpType.Column[0]);
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
