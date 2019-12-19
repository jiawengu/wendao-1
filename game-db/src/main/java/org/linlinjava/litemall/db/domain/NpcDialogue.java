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

public class NpcDialogue implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private String name;
    private Integer portranit;
    private Integer picNo;
    private String content;
    private Integer isconmlete;
    private Integer isincombat;
    private Integer palytime;
    private String taskType;
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
    private String idname;
    private static final long serialVersionUID = 1L;

    public NpcDialogue() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getPortranit() {
        return this.portranit;
    }

    public void setPortranit(Integer portranit) {
        this.portranit = portranit;
    }

    public Integer getPicNo() {
        return this.picNo;
    }

    public void setPicNo(Integer picNo) {
        this.picNo = picNo;
    }

    public String getContent() {
        return this.content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Integer getIsconmlete() {
        return this.isconmlete;
    }

    public void setIsconmlete(Integer isconmlete) {
        this.isconmlete = isconmlete;
    }

    public Integer getIsincombat() {
        return this.isincombat;
    }

    public void setIsincombat(Integer isincombat) {
        this.isincombat = isincombat;
    }

    public Integer getPalytime() {
        return this.palytime;
    }

    public void setPalytime(Integer palytime) {
        this.palytime = palytime;
    }

    public String getTaskType() {
        return this.taskType;
    }

    public void setTaskType(String taskType) {
        this.taskType = taskType;
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
        this.setDeleted(deleted ? NpcDialogue.Deleted.IS_DELETED.value() : NpcDialogue.Deleted.NOT_DELETED.value());
    }

    public Boolean getDeleted() {
        return this.deleted;
    }

    public void setDeleted(Boolean deleted) {
        this.deleted = deleted;
    }

    public String getIdname() {
        return this.idname;
    }

    public void setIdname(String idname) {
        this.idname = idname;
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(this.getClass().getSimpleName());
        sb.append(" [");
        sb.append("Hash = ").append(this.hashCode());
        sb.append(", IS_DELETED=").append(IS_DELETED);
        sb.append(", NOT_DELETED=").append(NOT_DELETED);
        sb.append(", id=").append(this.id);
        sb.append(", name=").append(this.name);
        sb.append(", portranit=").append(this.portranit);
        sb.append(", picNo=").append(this.picNo);
        sb.append(", content=").append(this.content);
        sb.append(", isconmlete=").append(this.isconmlete);
        sb.append(", isincombat=").append(this.isincombat);
        sb.append(", palytime=").append(this.palytime);
        sb.append(", taskType=").append(this.taskType);
        sb.append(", addTime=").append(this.addTime);
        sb.append(", updateTime=").append(this.updateTime);
        sb.append(", deleted=").append(this.deleted);
        sb.append(", idname=").append(this.idname);
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
                    NpcDialogue other = (NpcDialogue)that;
                    if (this.getId() == null) {
                        if (other.getId() != null) {
                            break label129;
                        }
                    } else if (!this.getId().equals(other.getId())) {
                        break label129;
                    }

                    if (this.getName() == null) {
                        if (other.getName() != null) {
                            break label129;
                        }
                    } else if (!this.getName().equals(other.getName())) {
                        break label129;
                    }

                    if (this.getPortranit() == null) {
                        if (other.getPortranit() != null) {
                            break label129;
                        }
                    } else if (!this.getPortranit().equals(other.getPortranit())) {
                        break label129;
                    }

                    if (this.getPicNo() == null) {
                        if (other.getPicNo() != null) {
                            break label129;
                        }
                    } else if (!this.getPicNo().equals(other.getPicNo())) {
                        break label129;
                    }

                    if (this.getContent() == null) {
                        if (other.getContent() != null) {
                            break label129;
                        }
                    } else if (!this.getContent().equals(other.getContent())) {
                        break label129;
                    }

                    if (this.getIsconmlete() == null) {
                        if (other.getIsconmlete() != null) {
                            break label129;
                        }
                    } else if (!this.getIsconmlete().equals(other.getIsconmlete())) {
                        break label129;
                    }

                    if (this.getIsincombat() == null) {
                        if (other.getIsincombat() != null) {
                            break label129;
                        }
                    } else if (!this.getIsincombat().equals(other.getIsincombat())) {
                        break label129;
                    }

                    if (this.getPalytime() == null) {
                        if (other.getPalytime() != null) {
                            break label129;
                        }
                    } else if (!this.getPalytime().equals(other.getPalytime())) {
                        break label129;
                    }

                    if (this.getTaskType() == null) {
                        if (other.getTaskType() != null) {
                            break label129;
                        }
                    } else if (!this.getTaskType().equals(other.getTaskType())) {
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
                        if (other.getDeleted() != null) {
                            break label129;
                        }
                    } else if (!this.getDeleted().equals(other.getDeleted())) {
                        break label129;
                    }

                    if (this.getIdname() == null) {
                        if (other.getIdname() == null) {
                            break label137;
                        }
                    } else if (this.getIdname().equals(other.getIdname())) {
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
        result = 31 * result + (this.getName() == null ? 0 : this.getName().hashCode());
        result = 31 * result + (this.getPortranit() == null ? 0 : this.getPortranit().hashCode());
        result = 31 * result + (this.getPicNo() == null ? 0 : this.getPicNo().hashCode());
        result = 31 * result + (this.getContent() == null ? 0 : this.getContent().hashCode());
        result = 31 * result + (this.getIsconmlete() == null ? 0 : this.getIsconmlete().hashCode());
        result = 31 * result + (this.getIsincombat() == null ? 0 : this.getIsincombat().hashCode());
        result = 31 * result + (this.getPalytime() == null ? 0 : this.getPalytime().hashCode());
        result = 31 * result + (this.getTaskType() == null ? 0 : this.getTaskType().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        result = 31 * result + (this.getIdname() == null ? 0 : this.getIdname().hashCode());
        return result;
    }

    public NpcDialogue clone() throws CloneNotSupportedException {
        return (NpcDialogue)super.clone();
    }

    static {
        IS_DELETED = NpcDialogue.Deleted.IS_DELETED.value();
        NOT_DELETED = NpcDialogue.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        name("name", "name", "VARCHAR", true),
        portranit("portranit", "portranit", "INTEGER", false),
        picNo("pic_no", "picNo", "INTEGER", false),
        content("content", "content", "VARCHAR", false),
        isconmlete("isconmlete", "isconmlete", "INTEGER", false),
        isincombat("isincombat", "isincombat", "INTEGER", false),
        palytime("palytime", "palytime", "INTEGER", false),
        taskType("task_type", "taskType", "VARCHAR", false),
        addTime("add_time", "addTime", "TIMESTAMP", false),
        updateTime("update_time", "updateTime", "TIMESTAMP", false),
        deleted("deleted", "deleted", "BIT", false),
        idname("idname", "idname", "VARCHAR", false);

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

        public static NpcDialogue.Column[] excludes(NpcDialogue.Column... excludes) {
            ArrayList<NpcDialogue.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (NpcDialogue.Column[])columns.toArray(new NpcDialogue.Column[0]);
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
