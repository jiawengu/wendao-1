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

public class Skills implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private String skillIdHex;
    private String skillName;
    private Integer skillReqMenpai;
    private Integer skillType;
    private Integer skillTypeLevel;
    private Integer skillMagic;
    private Integer skillReqLevel;
    private String skillContext;
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

    public Skills() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getSkillIdHex() {
        return this.skillIdHex;
    }

    public void setSkillIdHex(String skillIdHex) {
        this.skillIdHex = skillIdHex;
    }

    public String getSkillName() {
        return this.skillName;
    }

    public void setSkillName(String skillName) {
        this.skillName = skillName;
    }

    public Integer getSkillReqMenpai() {
        return this.skillReqMenpai;
    }

    public void setSkillReqMenpai(Integer skillReqMenpai) {
        this.skillReqMenpai = skillReqMenpai;
    }

    public Integer getSkillType() {
        return this.skillType;
    }

    public void setSkillType(Integer skillType) {
        this.skillType = skillType;
    }

    public Integer getSkillTypeLevel() {
        return this.skillTypeLevel;
    }

    public void setSkillTypeLevel(Integer skillTypeLevel) {
        this.skillTypeLevel = skillTypeLevel;
    }

    public Integer getSkillMagic() {
        return this.skillMagic;
    }

    public void setSkillMagic(Integer skillMagic) {
        this.skillMagic = skillMagic;
    }

    public Integer getSkillReqLevel() {
        return this.skillReqLevel;
    }

    public void setSkillReqLevel(Integer skillReqLevel) {
        this.skillReqLevel = skillReqLevel;
    }

    public String getSkillContext() {
        return this.skillContext;
    }

    public void setSkillContext(String skillContext) {
        this.skillContext = skillContext;
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
        this.setDeleted(deleted ? Skills.Deleted.IS_DELETED.value() : Skills.Deleted.NOT_DELETED.value());
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
        sb.append(", skillIdHex=").append(this.skillIdHex);
        sb.append(", skillName=").append(this.skillName);
        sb.append(", skillReqMenpai=").append(this.skillReqMenpai);
        sb.append(", skillType=").append(this.skillType);
        sb.append(", skillTypeLevel=").append(this.skillTypeLevel);
        sb.append(", skillMagic=").append(this.skillMagic);
        sb.append(", skillReqLevel=").append(this.skillReqLevel);
        sb.append(", skillContext=").append(this.skillContext);
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
            label129: {
                label121: {
                    Skills other = (Skills)that;
                    if (this.getId() == null) {
                        if (other.getId() != null) {
                            break label121;
                        }
                    } else if (!this.getId().equals(other.getId())) {
                        break label121;
                    }

                    if (this.getSkillIdHex() == null) {
                        if (other.getSkillIdHex() != null) {
                            break label121;
                        }
                    } else if (!this.getSkillIdHex().equals(other.getSkillIdHex())) {
                        break label121;
                    }

                    if (this.getSkillName() == null) {
                        if (other.getSkillName() != null) {
                            break label121;
                        }
                    } else if (!this.getSkillName().equals(other.getSkillName())) {
                        break label121;
                    }

                    if (this.getSkillReqMenpai() == null) {
                        if (other.getSkillReqMenpai() != null) {
                            break label121;
                        }
                    } else if (!this.getSkillReqMenpai().equals(other.getSkillReqMenpai())) {
                        break label121;
                    }

                    if (this.getSkillType() == null) {
                        if (other.getSkillType() != null) {
                            break label121;
                        }
                    } else if (!this.getSkillType().equals(other.getSkillType())) {
                        break label121;
                    }

                    if (this.getSkillTypeLevel() == null) {
                        if (other.getSkillTypeLevel() != null) {
                            break label121;
                        }
                    } else if (!this.getSkillTypeLevel().equals(other.getSkillTypeLevel())) {
                        break label121;
                    }

                    if (this.getSkillMagic() == null) {
                        if (other.getSkillMagic() != null) {
                            break label121;
                        }
                    } else if (!this.getSkillMagic().equals(other.getSkillMagic())) {
                        break label121;
                    }

                    if (this.getSkillReqLevel() == null) {
                        if (other.getSkillReqLevel() != null) {
                            break label121;
                        }
                    } else if (!this.getSkillReqLevel().equals(other.getSkillReqLevel())) {
                        break label121;
                    }

                    if (this.getSkillContext() == null) {
                        if (other.getSkillContext() != null) {
                            break label121;
                        }
                    } else if (!this.getSkillContext().equals(other.getSkillContext())) {
                        break label121;
                    }

                    if (this.getAddTime() == null) {
                        if (other.getAddTime() != null) {
                            break label121;
                        }
                    } else if (!this.getAddTime().equals(other.getAddTime())) {
                        break label121;
                    }

                    if (this.getUpdateTime() == null) {
                        if (other.getUpdateTime() != null) {
                            break label121;
                        }
                    } else if (!this.getUpdateTime().equals(other.getUpdateTime())) {
                        break label121;
                    }

                    if (this.getDeleted() == null) {
                        if (other.getDeleted() == null) {
                            break label129;
                        }
                    } else if (this.getDeleted().equals(other.getDeleted())) {
                        break label129;
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
        result = 31 * result + (this.getSkillIdHex() == null ? 0 : this.getSkillIdHex().hashCode());
        result = 31 * result + (this.getSkillName() == null ? 0 : this.getSkillName().hashCode());
        result = 31 * result + (this.getSkillReqMenpai() == null ? 0 : this.getSkillReqMenpai().hashCode());
        result = 31 * result + (this.getSkillType() == null ? 0 : this.getSkillType().hashCode());
        result = 31 * result + (this.getSkillTypeLevel() == null ? 0 : this.getSkillTypeLevel().hashCode());
        result = 31 * result + (this.getSkillMagic() == null ? 0 : this.getSkillMagic().hashCode());
        result = 31 * result + (this.getSkillReqLevel() == null ? 0 : this.getSkillReqLevel().hashCode());
        result = 31 * result + (this.getSkillContext() == null ? 0 : this.getSkillContext().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        return result;
    }

    public Skills clone() throws CloneNotSupportedException {
        return (Skills)super.clone();
    }

    static {
        IS_DELETED = Skills.Deleted.IS_DELETED.value();
        NOT_DELETED = Skills.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        skillIdHex("skill_id_hex", "skillIdHex", "VARCHAR", false),
        skillName("skill_name", "skillName", "VARCHAR", false),
        skillReqMenpai("skill_req_menpai", "skillReqMenpai", "INTEGER", false),
        skillType("skill_type", "skillType", "INTEGER", false),
        skillTypeLevel("skill_type_level", "skillTypeLevel", "INTEGER", false),
        skillMagic("skill_magic", "skillMagic", "INTEGER", false),
        skillReqLevel("skill_req_level", "skillReqLevel", "INTEGER", false),
        skillContext("skill_context", "skillContext", "VARCHAR", false),
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

        public static Skills.Column[] excludes(Skills.Column... excludes) {
            ArrayList<Skills.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (Skills.Column[])columns.toArray(new Skills.Column[0]);
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
