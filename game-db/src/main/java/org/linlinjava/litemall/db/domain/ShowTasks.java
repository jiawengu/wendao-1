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

public class ShowTasks implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private String taskType;
    private String taskDesc;
    private String taskPrompt;
    private Integer refresh;
    private Integer taskEndTime;
    private Integer attrib;
    private String reward;
    private String showName;
    private String tasktaskExtraPara;
    private Integer tasktaskState;
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

    public ShowTasks() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getTaskType() {
        return this.taskType;
    }

    public void setTaskType(String taskType) {
        this.taskType = taskType;
    }

    public String getTaskDesc() {
        return this.taskDesc;
    }

    public void setTaskDesc(String taskDesc) {
        this.taskDesc = taskDesc;
    }

    public String getTaskPrompt() {
        return this.taskPrompt;
    }

    public void setTaskPrompt(String taskPrompt) {
        this.taskPrompt = taskPrompt;
    }

    public Integer getRefresh() {
        return this.refresh;
    }

    public void setRefresh(Integer refresh) {
        this.refresh = refresh;
    }

    public Integer getTaskEndTime() {
        return this.taskEndTime;
    }

    public void setTaskEndTime(Integer taskEndTime) {
        this.taskEndTime = taskEndTime;
    }

    public Integer getAttrib() {
        return this.attrib;
    }

    public void setAttrib(Integer attrib) {
        this.attrib = attrib;
    }

    public String getReward() {
        return this.reward;
    }

    public void setReward(String reward) {
        this.reward = reward;
    }

    public String getShowName() {
        return this.showName;
    }

    public void setShowName(String showName) {
        this.showName = showName;
    }

    public String getTasktaskExtraPara() {
        return this.tasktaskExtraPara;
    }

    public void setTasktaskExtraPara(String tasktaskExtraPara) {
        this.tasktaskExtraPara = tasktaskExtraPara;
    }

    public Integer getTasktaskState() {
        return this.tasktaskState;
    }

    public void setTasktaskState(Integer tasktaskState) {
        this.tasktaskState = tasktaskState;
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
        this.setDeleted(deleted ? ShowTasks.Deleted.IS_DELETED.value() : ShowTasks.Deleted.NOT_DELETED.value());
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
        sb.append(", taskType=").append(this.taskType);
        sb.append(", taskDesc=").append(this.taskDesc);
        sb.append(", taskPrompt=").append(this.taskPrompt);
        sb.append(", refresh=").append(this.refresh);
        sb.append(", taskEndTime=").append(this.taskEndTime);
        sb.append(", attrib=").append(this.attrib);
        sb.append(", reward=").append(this.reward);
        sb.append(", showName=").append(this.showName);
        sb.append(", tasktaskExtraPara=").append(this.tasktaskExtraPara);
        sb.append(", tasktaskState=").append(this.tasktaskState);
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
            label144: {
                ShowTasks other = (ShowTasks)that;
                if (this.getId() == null) {
                    if (other.getId() != null) {
                        break label144;
                    }
                } else if (!this.getId().equals(other.getId())) {
                    break label144;
                }

                if (this.getTaskType() == null) {
                    if (other.getTaskType() != null) {
                        break label144;
                    }
                } else if (!this.getTaskType().equals(other.getTaskType())) {
                    break label144;
                }

                if (this.getTaskDesc() == null) {
                    if (other.getTaskDesc() != null) {
                        break label144;
                    }
                } else if (!this.getTaskDesc().equals(other.getTaskDesc())) {
                    break label144;
                }

                if (this.getTaskPrompt() == null) {
                    if (other.getTaskPrompt() != null) {
                        break label144;
                    }
                } else if (!this.getTaskPrompt().equals(other.getTaskPrompt())) {
                    break label144;
                }

                if (this.getRefresh() == null) {
                    if (other.getRefresh() != null) {
                        break label144;
                    }
                } else if (!this.getRefresh().equals(other.getRefresh())) {
                    break label144;
                }

                if (this.getTaskEndTime() == null) {
                    if (other.getTaskEndTime() != null) {
                        break label144;
                    }
                } else if (!this.getTaskEndTime().equals(other.getTaskEndTime())) {
                    break label144;
                }

                if (this.getAttrib() == null) {
                    if (other.getAttrib() != null) {
                        break label144;
                    }
                } else if (!this.getAttrib().equals(other.getAttrib())) {
                    break label144;
                }

                if (this.getReward() == null) {
                    if (other.getReward() != null) {
                        break label144;
                    }
                } else if (!this.getReward().equals(other.getReward())) {
                    break label144;
                }

                if (this.getShowName() == null) {
                    if (other.getShowName() != null) {
                        break label144;
                    }
                } else if (!this.getShowName().equals(other.getShowName())) {
                    break label144;
                }

                if (this.getTasktaskExtraPara() == null) {
                    if (other.getTasktaskExtraPara() != null) {
                        break label144;
                    }
                } else if (!this.getTasktaskExtraPara().equals(other.getTasktaskExtraPara())) {
                    break label144;
                }

                if (this.getTasktaskState() == null) {
                    if (other.getTasktaskState() != null) {
                        break label144;
                    }
                } else if (!this.getTasktaskState().equals(other.getTasktaskState())) {
                    break label144;
                }

                if (this.getAddTime() == null) {
                    if (other.getAddTime() != null) {
                        break label144;
                    }
                } else if (!this.getAddTime().equals(other.getAddTime())) {
                    break label144;
                }

                if (this.getUpdateTime() == null) {
                    if (other.getUpdateTime() != null) {
                        break label144;
                    }
                } else if (!this.getUpdateTime().equals(other.getUpdateTime())) {
                    break label144;
                }

                if (this.getDeleted() == null) {
                    if (other.getDeleted() != null) {
                        break label144;
                    }
                } else if (!this.getDeleted().equals(other.getDeleted())) {
                    break label144;
                }

                var10000 = true;
                return var10000;
            }

            var10000 = false;
            return var10000;
        }
    }

    public int hashCode() {
        int result = 1;
     result = 31 * result + (this.getId() == null ? 0 : this.getId().hashCode());
        result = 31 * result + (this.getTaskType() == null ? 0 : this.getTaskType().hashCode());
        result = 31 * result + (this.getTaskDesc() == null ? 0 : this.getTaskDesc().hashCode());
        result = 31 * result + (this.getTaskPrompt() == null ? 0 : this.getTaskPrompt().hashCode());
        result = 31 * result + (this.getRefresh() == null ? 0 : this.getRefresh().hashCode());
        result = 31 * result + (this.getTaskEndTime() == null ? 0 : this.getTaskEndTime().hashCode());
        result = 31 * result + (this.getAttrib() == null ? 0 : this.getAttrib().hashCode());
        result = 31 * result + (this.getReward() == null ? 0 : this.getReward().hashCode());
        result = 31 * result + (this.getShowName() == null ? 0 : this.getShowName().hashCode());
        result = 31 * result + (this.getTasktaskExtraPara() == null ? 0 : this.getTasktaskExtraPara().hashCode());
        result = 31 * result + (this.getTasktaskState() == null ? 0 : this.getTasktaskState().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        return result;
    }

    public ShowTasks clone() throws CloneNotSupportedException {
        return (ShowTasks)super.clone();
    }

    static {
        IS_DELETED = ShowTasks.Deleted.IS_DELETED.value();
        NOT_DELETED = ShowTasks.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        taskType("task_type", "taskType", "VARCHAR", false),
        taskDesc("task_desc", "taskDesc", "VARCHAR", false),
        taskPrompt("task_prompt", "taskPrompt", "VARCHAR", false),
        refresh("refresh", "refresh", "INTEGER", false),
        taskEndTime("task_end_time", "taskEndTime", "INTEGER", false),
        attrib("attrib", "attrib", "INTEGER", false),
        reward("reward", "reward", "VARCHAR", false),
        showName("show_name", "showName", "VARCHAR", false),
        tasktaskExtraPara("tasktask_extra_para", "tasktaskExtraPara", "VARCHAR", false),
        tasktaskState("tasktask_state", "tasktaskState", "INTEGER", false),
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

        public static ShowTasks.Column[] excludes(ShowTasks.Column... excludes) {
            ArrayList<ShowTasks.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (ShowTasks.Column[])columns.toArray(new ShowTasks.Column[0]);
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
