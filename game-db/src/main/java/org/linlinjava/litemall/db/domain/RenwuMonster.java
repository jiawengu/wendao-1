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

public class RenwuMonster implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private String mapName;
    private Integer x;
    private Integer y;
    private String name;
    private Integer icon;
    private String skills;
    private Integer type;
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

    public RenwuMonster() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getMapName() {
        return this.mapName;
    }

    public void setMapName(String mapName) {
        this.mapName = mapName;
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

    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getIcon() {
        return this.icon;
    }

    public void setIcon(Integer icon) {
        this.icon = icon;
    }

    public String getSkills() {
        return this.skills;
    }

    public void setSkills(String skills) {
        this.skills = skills;
    }

    public Integer getType() {
        return this.type;
    }

    public void setType(Integer type) {
        this.type = type;
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
        this.setDeleted(deleted ? RenwuMonster.Deleted.IS_DELETED.value() : RenwuMonster.Deleted.NOT_DELETED.value());
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
        sb.append(", mapName=").append(this.mapName);
        sb.append(", x=").append(this.x);
        sb.append(", y=").append(this.y);
        sb.append(", name=").append(this.name);
        sb.append(", icon=").append(this.icon);
        sb.append(", skills=").append(this.skills);
        sb.append(", type=").append(this.type);
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
                    RenwuMonster other = (RenwuMonster)that;
                    if (this.getId() == null) {
                        if (other.getId() != null) {
                            break label113;
                        }
                    } else if (!this.getId().equals(other.getId())) {
                        break label113;
                    }

                    if (this.getMapName() == null) {
                        if (other.getMapName() != null) {
                            break label113;
                        }
                    } else if (!this.getMapName().equals(other.getMapName())) {
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

                    if (this.getName() == null) {
                        if (other.getName() != null) {
                            break label113;
                        }
                    } else if (!this.getName().equals(other.getName())) {
                        break label113;
                    }

                    if (this.getIcon() == null) {
                        if (other.getIcon() != null) {
                            break label113;
                        }
                    } else if (!this.getIcon().equals(other.getIcon())) {
                        break label113;
                    }

                    if (this.getSkills() == null) {
                        if (other.getSkills() != null) {
                            break label113;
                        }
                    } else if (!this.getSkills().equals(other.getSkills())) {
                        break label113;
                    }

                    if (this.getType() == null) {
                        if (other.getType() != null) {
                            break label113;
                        }
                    } else if (!this.getType().equals(other.getType())) {
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
        result = 31 * result + (this.getMapName() == null ? 0 : this.getMapName().hashCode());
        result = 31 * result + (this.getX() == null ? 0 : this.getX().hashCode());
        result = 31 * result + (this.getY() == null ? 0 : this.getY().hashCode());
        result = 31 * result + (this.getName() == null ? 0 : this.getName().hashCode());
        result = 31 * result + (this.getIcon() == null ? 0 : this.getIcon().hashCode());
        result = 31 * result + (this.getSkills() == null ? 0 : this.getSkills().hashCode());
        result = 31 * result + (this.getType() == null ? 0 : this.getType().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        return result;
    }

    public RenwuMonster clone() throws CloneNotSupportedException {
        return (RenwuMonster)super.clone();
    }

    static {
        IS_DELETED = RenwuMonster.Deleted.IS_DELETED.value();
        NOT_DELETED = RenwuMonster.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        mapName("map_name", "mapName", "VARCHAR", false),
        x("x", "x", "INTEGER", false),
        y("y", "y", "INTEGER", false),
        name("name", "name", "VARCHAR", true),
        icon("icon", "icon", "INTEGER", false),
        skills("skills", "skills", "VARCHAR", false),
        type("type", "type", "INTEGER", true),
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

        public static RenwuMonster.Column[] excludes(RenwuMonster.Column... excludes) {
            ArrayList<RenwuMonster.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (RenwuMonster.Column[])columns.toArray(new RenwuMonster.Column[0]);
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
