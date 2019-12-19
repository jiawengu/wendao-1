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

public class NpcPoint implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private String mapname;
    private String doorname;
    private Integer x;
    private Integer y;
    private Integer z;
    private Integer inx;
    private Integer iny;
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

    public NpcPoint() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getMapname() {
        return this.mapname;
    }

    public void setMapname(String mapname) {
        this.mapname = mapname;
    }

    public String getDoorname() {
        return this.doorname;
    }

    public void setDoorname(String doorname) {
        this.doorname = doorname;
    }

    public Integer getX() {
        return this.x;
    }

    public void setX(Integer x) {
        this.x = x;
    }

    public Integer getY() {
        return this.y;
    }

    public void setY(Integer y) {
        this.y = y;
    }

    public Integer getZ() {
        return this.z;
    }

    public void setZ(Integer z) {
        this.z = z;
    }

    public Integer getInx() {
        return this.inx;
    }

    public void setInx(Integer inx) {
        this.inx = inx;
    }

    public Integer getIny() {
        return this.iny;
    }

    public void setIny(Integer iny) {
        this.iny = iny;
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
        this.setDeleted(deleted ? NpcPoint.Deleted.IS_DELETED.value() : NpcPoint.Deleted.NOT_DELETED.value());
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
        sb.append(", mapname=").append(this.mapname);
        sb.append(", doorname=").append(this.doorname);
        sb.append(", x=").append(this.x);
        sb.append(", y=").append(this.y);
        sb.append(", z=").append(this.z);
        sb.append(", inx=").append(this.inx);
        sb.append(", iny=").append(this.iny);
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
                    NpcPoint other = (NpcPoint)that;
                    if (this.getId() == null) {
                        if (other.getId() != null) {
                            break label113;
                        }
                    } else if (!this.getId().equals(other.getId())) {
                        break label113;
                    }

                    if (this.getMapname() == null) {
                        if (other.getMapname() != null) {
                            break label113;
                        }
                    } else if (!this.getMapname().equals(other.getMapname())) {
                        break label113;
                    }

                    if (this.getDoorname() == null) {
                        if (other.getDoorname() != null) {
                            break label113;
                        }
                    } else if (!this.getDoorname().equals(other.getDoorname())) {
                        break label113;
                    }

                    if (this.getX() == null) {
                        if (other.getX() != null) {
                            break label113;
                        }
                    } else if (!this.getX().equals(other.getX())) {
                        break label113;
                    }

                    if (this.getY() == null) {
                        if (other.getY() != null) {
                            break label113;
                        }
                    } else if (!this.getY().equals(other.getY())) {
                        break label113;
                    }

                    if (this.getZ() == null) {
                        if (other.getZ() != null) {
                            break label113;
                        }
                    } else if (!this.getZ().equals(other.getZ())) {
                        break label113;
                    }

                    if (this.getInx() == null) {
                        if (other.getInx() != null) {
                            break label113;
                        }
                    } else if (!this.getInx().equals(other.getInx())) {
                        break label113;
                    }

                    if (this.getIny() == null) {
                        if (other.getIny() != null) {
                            break label113;
                        }
                    } else if (!this.getIny().equals(other.getIny())) {
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
        result = 31 * result + (this.getMapname() == null ? 0 : this.getMapname().hashCode());
        result = 31 * result + (this.getDoorname() == null ? 0 : this.getDoorname().hashCode());
        result = 31 * result + (this.getX() == null ? 0 : this.getX().hashCode());
        result = 31 * result + (this.getY() == null ? 0 : this.getY().hashCode());
        result = 31 * result + (this.getZ() == null ? 0 : this.getZ().hashCode());
        result = 31 * result + (this.getInx() == null ? 0 : this.getInx().hashCode());
        result = 31 * result + (this.getIny() == null ? 0 : this.getIny().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        return result;
    }

    public NpcPoint clone() throws CloneNotSupportedException {
        return (NpcPoint)super.clone();
    }

    static {
        IS_DELETED = NpcPoint.Deleted.IS_DELETED.value();
        NOT_DELETED = NpcPoint.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        mapname("mapname", "mapname", "VARCHAR", false),
        doorname("doorname", "doorname", "VARCHAR", false),
        x("x", "x", "INTEGER", false),
        y("y", "y", "INTEGER", false),
        z("z", "z", "INTEGER", false),
        inx("inx", "inx", "INTEGER", false),
        iny("iny", "iny", "INTEGER", false),
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

        public static NpcPoint.Column[] excludes(NpcPoint.Column... excludes) {
            ArrayList<NpcPoint.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (NpcPoint.Column[])columns.toArray(new NpcPoint.Column[0]);
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
