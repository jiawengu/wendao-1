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

public class Skilldata implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private String pid;
    private String skillName;
    private Integer skillLevel;
    private Integer skillMubiao;
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

    public Skilldata() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getPid() {
        return this.pid;
    }

    public void setPid(String pid) {
        this.pid = pid;
    }

    public String getSkillName() {
        return this.skillName;
    }

    public void setSkillName(String skillName) {
        this.skillName = skillName;
    }

    public Integer getSkillLevel() {
        return this.skillLevel;
    }

    public void setSkillLevel(Integer skillLevel) {
        this.skillLevel = skillLevel;
    }

    public Integer getSkillMubiao() {
        return this.skillMubiao;
    }

    public void setSkillMubiao(Integer skillMubiao) {
        this.skillMubiao = skillMubiao;
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
        this.setDeleted(deleted ? Skilldata.Deleted.IS_DELETED.value() : Skilldata.Deleted.NOT_DELETED.value());
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
        sb.append(", pid=").append(this.pid);
        sb.append(", skillName=").append(this.skillName);
        sb.append(", skillLevel=").append(this.skillLevel);
        sb.append(", skillMubiao=").append(this.skillMubiao);
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
            label97: {
                label89: {
                    Skilldata other = (Skilldata)that;
                    if (this.getId() == null) {
                        if (other.getId() != null) {
                            break label89;
                        }
                    } else if (!this.getId().equals(other.getId())) {
                        break label89;
                    }

                    if (this.getPid() == null) {
                        if (other.getPid() != null) {
                            break label89;
                        }
                    } else if (!this.getPid().equals(other.getPid())) {
                        break label89;
                    }

                    if (this.getSkillName() == null) {
                        if (other.getSkillName() != null) {
                            break label89;
                        }
                    } else if (!this.getSkillName().equals(other.getSkillName())) {
                        break label89;
                    }

                    if (this.getSkillLevel() == null) {
                        if (other.getSkillLevel() != null) {
                            break label89;
                        }
                    } else if (!this.getSkillLevel().equals(other.getSkillLevel())) {
                        break label89;
                    }

                    if (this.getSkillMubiao() == null) {
                        if (other.getSkillMubiao() != null) {
                            break label89;
                        }
                    } else if (!this.getSkillMubiao().equals(other.getSkillMubiao())) {
                        break label89;
                    }

                    if (this.getAddTime() == null) {
                        if (other.getAddTime() != null) {
                            break label89;
                        }
                    } else if (!this.getAddTime().equals(other.getAddTime())) {
                        break label89;
                    }

                    if (this.getUpdateTime() == null) {
                        if (other.getUpdateTime() != null) {
                            break label89;
                        }
                    } else if (!this.getUpdateTime().equals(other.getUpdateTime())) {
                        break label89;
                    }

                    if (this.getDeleted() == null) {
                        if (other.getDeleted() == null) {
                            break label97;
                        }
                    } else if (this.getDeleted().equals(other.getDeleted())) {
                        break label97;
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
        result = 31 * result + (this.getPid() == null ? 0 : this.getPid().hashCode());
        result = 31 * result + (this.getSkillName() == null ? 0 : this.getSkillName().hashCode());
        result = 31 * result + (this.getSkillLevel() == null ? 0 : this.getSkillLevel().hashCode());
        result = 31 * result + (this.getSkillMubiao() == null ? 0 : this.getSkillMubiao().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        return result;
    }

    public Skilldata clone() throws CloneNotSupportedException {
        return (Skilldata)super.clone();
    }

    static {
        IS_DELETED = Skilldata.Deleted.IS_DELETED.value();
        NOT_DELETED = Skilldata.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        pid("pid", "pid", "VARCHAR", false),
        skillName("skill_name", "skillName", "VARCHAR", false),
        skillLevel("skill_level", "skillLevel", "INTEGER", false),
        skillMubiao("skill_mubiao", "skillMubiao", "INTEGER", false),
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

        public static Skilldata.Column[] excludes(Skilldata.Column... excludes) {
            ArrayList<Skilldata.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (Skilldata.Column[])columns.toArray(new Skilldata.Column[0]);
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
