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

public class Reports implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private String zhanghao;
    private Integer yuanbaoshu;
    private String shifouchongzhi;
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

    public Reports() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getZhanghao() {
        return this.zhanghao;
    }

    public void setZhanghao(String zhanghao) {
        this.zhanghao = zhanghao;
    }

    public Integer getYuanbaoshu() {
        return this.yuanbaoshu;
    }

    public void setYuanbaoshu(Integer yuanbaoshu) {
        this.yuanbaoshu = yuanbaoshu;
    }

    public String getShifouchongzhi() {
        return this.shifouchongzhi;
    }

    public void setShifouchongzhi(String shifouchongzhi) {
        this.shifouchongzhi = shifouchongzhi;
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
        this.setDeleted(deleted ? Reports.Deleted.IS_DELETED.value() : Reports.Deleted.NOT_DELETED.value());
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
        sb.append(", zhanghao=").append(this.zhanghao);
        sb.append(", yuanbaoshu=").append(this.yuanbaoshu);
        sb.append(", shifouchongzhi=").append(this.shifouchongzhi);
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
            label89: {
                label81: {
                    Reports other = (Reports)that;
                    if (this.getId() == null) {
                        if (other.getId() != null) {
                            break label81;
                        }
                    } else if (!this.getId().equals(other.getId())) {
                        break label81;
                    }

                    if (this.getZhanghao() == null) {
                        if (other.getZhanghao() != null) {
                            break label81;
                        }
                    } else if (!this.getZhanghao().equals(other.getZhanghao())) {
                        break label81;
                    }

                    if (this.getYuanbaoshu() == null) {
                        if (other.getYuanbaoshu() != null) {
                            break label81;
                        }
                    } else if (!this.getYuanbaoshu().equals(other.getYuanbaoshu())) {
                        break label81;
                    }

                    if (this.getShifouchongzhi() == null) {
                        if (other.getShifouchongzhi() != null) {
                            break label81;
                        }
                    } else if (!this.getShifouchongzhi().equals(other.getShifouchongzhi())) {
                        break label81;
                    }

                    if (this.getAddTime() == null) {
                        if (other.getAddTime() != null) {
                            break label81;
                        }
                    } else if (!this.getAddTime().equals(other.getAddTime())) {
                        break label81;
                    }

                    if (this.getUpdateTime() == null) {
                        if (other.getUpdateTime() != null) {
                            break label81;
                        }
                    } else if (!this.getUpdateTime().equals(other.getUpdateTime())) {
                        break label81;
                    }

                    if (this.getDeleted() == null) {
                        if (other.getDeleted() == null) {
                            break label89;
                        }
                    } else if (this.getDeleted().equals(other.getDeleted())) {
                        break label89;
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
        result = 31 * result + (this.getZhanghao() == null ? 0 : this.getZhanghao().hashCode());
        result = 31 * result + (this.getYuanbaoshu() == null ? 0 : this.getYuanbaoshu().hashCode());
        result = 31 * result + (this.getShifouchongzhi() == null ? 0 : this.getShifouchongzhi().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        return result;
    }

    public Reports clone() throws CloneNotSupportedException {
        return (Reports)super.clone();
    }

    static {
        IS_DELETED = Reports.Deleted.IS_DELETED.value();
        NOT_DELETED = Reports.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        zhanghao("zhanghao", "zhanghao", "VARCHAR", false),
        yuanbaoshu("yuanbaoshu", "yuanbaoshu", "INTEGER", false),
        shifouchongzhi("shifouchongzhi", "shifouchongzhi", "VARCHAR", false),
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

        public static Reports.Column[] excludes(Reports.Column... excludes) {
            ArrayList<Reports.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (Reports.Column[])columns.toArray(new Reports.Column[0]);
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
