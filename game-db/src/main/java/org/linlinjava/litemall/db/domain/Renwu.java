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

public class Renwu implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private String uncontent;
    private String npcName;
    private String currentTask;
    private String showName;
    private String taskPrompt;
    private String reward;
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

    public Renwu() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getUncontent() {
        return this.uncontent;
    }

    public void setUncontent(String uncontent) {
        this.uncontent = uncontent;
    }

    public String getNpcName() {
        return this.npcName;
    }

    public void setNpcName(String npcName) {
        this.npcName = npcName;
    }

    public String getCurrentTask() {
        return this.currentTask;
    }

    public void setCurrentTask(String currentTask) {
        this.currentTask = currentTask;
    }

    public String getShowName() {
        return this.showName;
    }

    public void setShowName(String showName) {
        this.showName = showName;
    }

    public String getTaskPrompt() {
        return this.taskPrompt;
    }

    public void setTaskPrompt(String taskPrompt) {
        this.taskPrompt = taskPrompt;
    }

    public String getReward() {
        return this.reward;
    }

    public void setReward(String reward) {
        this.reward = reward;
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
        this.setDeleted(deleted ? Renwu.Deleted.IS_DELETED.value() : Renwu.Deleted.NOT_DELETED.value());
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
        sb.append(", uncontent=").append(this.uncontent);
        sb.append(", npcName=").append(this.npcName);
        sb.append(", currentTask=").append(this.currentTask);
        sb.append(", showName=").append(this.showName);
        sb.append(", taskPrompt=").append(this.taskPrompt);
        sb.append(", reward=").append(this.reward);
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
            label112: {
                Renwu other = (Renwu)that;
                if (this.getId() == null) {
                    if (other.getId() != null) {
                        break label112;
                    }
                } else if (!this.getId().equals(other.getId())) {
                    break label112;
                }

                if (this.getUncontent() == null) {
                    if (other.getUncontent() != null) {
                        break label112;
                    }
                } else if (!this.getUncontent().equals(other.getUncontent())) {
                    break label112;
                }

                if (this.getNpcName() == null) {
                    if (other.getNpcName() != null) {
                        break label112;
                    }
                } else if (!this.getNpcName().equals(other.getNpcName())) {
                    break label112;
                }

                if (this.getCurrentTask() == null) {
                    if (other.getCurrentTask() != null) {
                        break label112;
                    }
                } else if (!this.getCurrentTask().equals(other.getCurrentTask())) {
                    break label112;
                }

                if (this.getShowName() == null) {
                    if (other.getShowName() != null) {
                        break label112;
                    }
                } else if (!this.getShowName().equals(other.getShowName())) {
                    break label112;
                }

                if (this.getTaskPrompt() == null) {
                    if (other.getTaskPrompt() != null) {
                        break label112;
                    }
                } else if (!this.getTaskPrompt().equals(other.getTaskPrompt())) {
                    break label112;
                }

                if (this.getReward() == null) {
                    if (other.getReward() != null) {
                        break label112;
                    }
                } else if (!this.getReward().equals(other.getReward())) {
                    break label112;
                }

                if (this.getAddTime() == null) {
                    if (other.getAddTime() != null) {
                        break label112;
                    }
                } else if (!this.getAddTime().equals(other.getAddTime())) {
                    break label112;
                }

                if (this.getUpdateTime() == null) {
                    if (other.getUpdateTime() != null) {
                        break label112;
                    }
                } else if (!this.getUpdateTime().equals(other.getUpdateTime())) {
                    break label112;
                }

                if (this.getDeleted() == null) {
                    if (other.getDeleted() != null) {
                        break label112;
                    }
                } else if (!this.getDeleted().equals(other.getDeleted())) {
                    break label112;
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
        result = 31 * result + (this.getUncontent() == null ? 0 : this.getUncontent().hashCode());
        result = 31 * result + (this.getNpcName() == null ? 0 : this.getNpcName().hashCode());
        result = 31 * result + (this.getCurrentTask() == null ? 0 : this.getCurrentTask().hashCode());
        result = 31 * result + (this.getShowName() == null ? 0 : this.getShowName().hashCode());
        result = 31 * result + (this.getTaskPrompt() == null ? 0 : this.getTaskPrompt().hashCode());
        result = 31 * result + (this.getReward() == null ? 0 : this.getReward().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        return result;
    }

    public Renwu clone() throws CloneNotSupportedException {
        return (Renwu)super.clone();
    }

    static {
        IS_DELETED = Renwu.Deleted.IS_DELETED.value();
        NOT_DELETED = Renwu.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        uncontent("uncontent", "uncontent", "VARCHAR", false),
        npcName("npc_name", "npcName", "VARCHAR", false),
        currentTask("current_task", "currentTask", "VARCHAR", false),
        showName("show_name", "showName", "VARCHAR", false),
        taskPrompt("task_prompt", "taskPrompt", "VARCHAR", false),
        reward("reward", "reward", "VARCHAR", false),
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

        public static Renwu.Column[] excludes(Renwu.Column... excludes) {
            ArrayList<Renwu.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (Renwu.Column[])columns.toArray(new Renwu.Column[0]);
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
