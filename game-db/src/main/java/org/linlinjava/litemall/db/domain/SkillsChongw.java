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

public class SkillsChongw implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private String ownerid;
    private String skllCwid;
    private String skillIdHex;
    private String skillName;
    private Integer skillReqMenpai;
    private Integer skillLevel;
    private Integer skillMubiao;
    private String tianshuId;
    private String tianshuName;
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

    public SkillsChongw() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getOwnerid() {
        return this.ownerid;
    }

    public void setOwnerid(String ownerid) {
        this.ownerid = ownerid;
    }

    public String getSkllCwid() {
        return this.skllCwid;
    }

    public void setSkllCwid(String skllCwid) {
        this.skllCwid = skllCwid;
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

    public String getTianshuId() {
        return this.tianshuId;
    }

    public void setTianshuId(String tianshuId) {
        this.tianshuId = tianshuId;
    }

    public String getTianshuName() {
        return this.tianshuName;
    }

    public void setTianshuName(String tianshuName) {
        this.tianshuName = tianshuName;
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
        this.setDeleted(deleted ? SkillsChongw.Deleted.IS_DELETED.value() : SkillsChongw.Deleted.NOT_DELETED.value());
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
        sb.append(", ownerid=").append(this.ownerid);
        sb.append(", skllCwid=").append(this.skllCwid);
        sb.append(", skillIdHex=").append(this.skillIdHex);
        sb.append(", skillName=").append(this.skillName);
        sb.append(", skillReqMenpai=").append(this.skillReqMenpai);
        sb.append(", skillLevel=").append(this.skillLevel);
        sb.append(", skillMubiao=").append(this.skillMubiao);
        sb.append(", tianshuId=").append(this.tianshuId);
        sb.append(", tianshuName=").append(this.tianshuName);
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
            label137: {
                label129: {
                    SkillsChongw other = (SkillsChongw)that;
                    if (this.getId() == null) {
                        if (other.getId() != null) {
                            break label129;
                        }
                    } else if (!this.getId().equals(other.getId())) {
                        break label129;
                    }

                    if (this.getOwnerid() == null) {
                        if (other.getOwnerid() != null) {
                            break label129;
                        }
                    } else if (!this.getOwnerid().equals(other.getOwnerid())) {
                        break label129;
                    }

                    if (this.getSkllCwid() == null) {
                        if (other.getSkllCwid() != null) {
                            break label129;
                        }
                    } else if (!this.getSkllCwid().equals(other.getSkllCwid())) {
                        break label129;
                    }

                    if (this.getSkillIdHex() == null) {
                        if (other.getSkillIdHex() != null) {
                            break label129;
                        }
                    } else if (!this.getSkillIdHex().equals(other.getSkillIdHex())) {
                        break label129;
                    }

                    if (this.getSkillName() == null) {
                        if (other.getSkillName() != null) {
                            break label129;
                        }
                    } else if (!this.getSkillName().equals(other.getSkillName())) {
                        break label129;
                    }

                    if (this.getSkillReqMenpai() == null) {
                        if (other.getSkillReqMenpai() != null) {
                            break label129;
                        }
                    } else if (!this.getSkillReqMenpai().equals(other.getSkillReqMenpai())) {
                        break label129;
                    }

                    if (this.getSkillLevel() == null) {
                        if (other.getSkillLevel() != null) {
                            break label129;
                        }
                    } else if (!this.getSkillLevel().equals(other.getSkillLevel())) {
                        break label129;
                    }

                    if (this.getSkillMubiao() == null) {
                        if (other.getSkillMubiao() != null) {
                            break label129;
                        }
                    } else if (!this.getSkillMubiao().equals(other.getSkillMubiao())) {
                        break label129;
                    }

                    if (this.getTianshuId() == null) {
                        if (other.getTianshuId() != null) {
                            break label129;
                        }
                    } else if (!this.getTianshuId().equals(other.getTianshuId())) {
                        break label129;
                    }

                    if (this.getTianshuName() == null) {
                        if (other.getTianshuName() != null) {
                            break label129;
                        }
                    } else if (!this.getTianshuName().equals(other.getTianshuName())) {
                        break label129;
                    }

                    if (this.getAddTime() == null) {
                        if (other.getAddTime() != null) {
                            break label129;
                        }
                    } else if (!this.getAddTime().equals(other.getAddTime())) {
                        break label129;
                    }

                    if (this.getUpdateTime() == null) {
                        if (other.getUpdateTime() != null) {
                            break label129;
                        }
                    } else if (!this.getUpdateTime().equals(other.getUpdateTime())) {
                        break label129;
                    }

                    if (this.getDeleted() == null) {
                        if (other.getDeleted() == null) {
                            break label137;
                        }
                    } else if (this.getDeleted().equals(other.getDeleted())) {
                        break label137;
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
        result = 31 * result + (this.getOwnerid() == null ? 0 : this.getOwnerid().hashCode());
        result = 31 * result + (this.getSkllCwid() == null ? 0 : this.getSkllCwid().hashCode());
        result = 31 * result + (this.getSkillIdHex() == null ? 0 : this.getSkillIdHex().hashCode());
        result = 31 * result + (this.getSkillName() == null ? 0 : this.getSkillName().hashCode());
        result = 31 * result + (this.getSkillReqMenpai() == null ? 0 : this.getSkillReqMenpai().hashCode());
        result = 31 * result + (this.getSkillLevel() == null ? 0 : this.getSkillLevel().hashCode());
        result = 31 * result + (this.getSkillMubiao() == null ? 0 : this.getSkillMubiao().hashCode());
        result = 31 * result + (this.getTianshuId() == null ? 0 : this.getTianshuId().hashCode());
        result = 31 * result + (this.getTianshuName() == null ? 0 : this.getTianshuName().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        return result;
    }

    public SkillsChongw clone() throws CloneNotSupportedException {
        return (SkillsChongw)super.clone();
    }

    static {
        IS_DELETED = SkillsChongw.Deleted.IS_DELETED.value();
        NOT_DELETED = SkillsChongw.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        ownerid("ownerid", "ownerid", "VARCHAR", false),
        skllCwid("skll_cwid", "skllCwid", "VARCHAR", false),
        skillIdHex("skill_id_hex", "skillIdHex", "VARCHAR", false),
        skillName("skill_name", "skillName", "VARCHAR", false),
        skillReqMenpai("skill_req_menpai", "skillReqMenpai", "INTEGER", false),
        skillLevel("skill_level", "skillLevel", "INTEGER", false),
        skillMubiao("skill_mubiao", "skillMubiao", "INTEGER", false),
        tianshuId("tianshu_id", "tianshuId", "VARCHAR", false),
        tianshuName("tianshu_name", "tianshuName", "VARCHAR", false),
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

        public static SkillsChongw.Column[] excludes(SkillsChongw.Column... excludes) {
            ArrayList<SkillsChongw.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (SkillsChongw.Column[])columns.toArray(new SkillsChongw.Column[0]);
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
