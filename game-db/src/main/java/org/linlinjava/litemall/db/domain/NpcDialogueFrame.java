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

public class NpcDialogueFrame implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private Integer portrait;
    private Integer picNo;
    private String content;
    private String secretKey;
    private String name;
    private Integer attrib;
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
    private LocalDateTime updateTimes;
    private Boolean deleted;
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
    private Integer idname;
    private String next;
    private String currentTask;
    private String uncontent;
    private String zhuangbei;
    private Integer jingyan;
    private Integer money;
    private static final long serialVersionUID = 1L;

    public NpcDialogueFrame() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getPortrait() {
        return this.portrait;
    }

    public void setPortrait(Integer portrait) {
        this.portrait = portrait;
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

    public String getSecretKey() {
        return this.secretKey;
    }

    public void setSecretKey(String secretKey) {
        this.secretKey = secretKey;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getAttrib() {
        return this.attrib;
    }

    public void setAttrib(Integer attrib) {
        this.attrib = attrib;
    }

    public LocalDateTime getAddTime() {
        return this.addTime;
    }

    public void setAddTime(LocalDateTime addTime) {
        this.addTime = addTime;
    }

    public LocalDateTime getUpdateTimes() {
        return this.updateTimes;
    }

    public void setUpdateTimes(LocalDateTime updateTimes) {
        this.updateTimes = updateTimes;
    }

    public void andLogicalDeleted(boolean deleted) {
        this.setDeleted(deleted ? NpcDialogueFrame.Deleted.IS_DELETED.value() : NpcDialogueFrame.Deleted.NOT_DELETED.value());
    }

    public Boolean getDeleted() {
        return this.deleted;
    }

    public void setDeleted(Boolean deleted) {
        this.deleted = deleted;
    }

    public LocalDateTime getUpdateTime() {
        return this.updateTime;
    }

    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }

    public Integer getIdname() {
        return this.idname;
    }

    public void setIdname(Integer idname) {
        this.idname = idname;
    }

    public String getNext() {
        return this.next;
    }

    public void setNext(String next) {
        this.next = next;
    }

    public String getCurrentTask() {
        return this.currentTask;
    }

    public void setCurrentTask(String currentTask) {
        this.currentTask = currentTask;
    }

    public String getUncontent() {
        return this.uncontent;
    }

    public void setUncontent(String uncontent) {
        this.uncontent = uncontent;
    }

    public String getZhuangbei() {
        return this.zhuangbei;
    }

    public void setZhuangbei(String zhuangbei) {
        this.zhuangbei = zhuangbei;
    }

    public Integer getJingyan() {
        return this.jingyan;
    }

    public void setJingyan(Integer jingyan) {
        this.jingyan = jingyan;
    }

    public Integer getMoney() {
        return this.money;
    }

    public void setMoney(Integer money) {
        this.money = money;
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(this.getClass().getSimpleName());
        sb.append(" [");
        sb.append("Hash = ").append(this.hashCode());
        sb.append(", IS_DELETED=").append(IS_DELETED);
        sb.append(", NOT_DELETED=").append(NOT_DELETED);
        sb.append(", id=").append(this.id);
        sb.append(", portrait=").append(this.portrait);
        sb.append(", picNo=").append(this.picNo);
        sb.append(", content=").append(this.content);
        sb.append(", secretKey=").append(this.secretKey);
        sb.append(", name=").append(this.name);
        sb.append(", attrib=").append(this.attrib);
        sb.append(", addTime=").append(this.addTime);
        sb.append(", updateTimes=").append(this.updateTimes);
        sb.append(", deleted=").append(this.deleted);
        sb.append(", updateTime=").append(this.updateTime);
        sb.append(", idname=").append(this.idname);
        sb.append(", next=").append(this.next);
        sb.append(", currentTask=").append(this.currentTask);
        sb.append(", uncontent=").append(this.uncontent);
        sb.append(", zhuangbei=").append(this.zhuangbei);
        sb.append(", jingyan=").append(this.jingyan);
        sb.append(", money=").append(this.money);
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
            label176: {
                NpcDialogueFrame other = (NpcDialogueFrame)that;
                if (this.getId() == null) {
                    if (other.getId() != null) {
                        break label176;
                    }
                } else if (!this.getId().equals(other.getId())) {
                    break label176;
                }

                if (this.getPortrait() == null) {
                    if (other.getPortrait() != null) {
                        break label176;
                    }
                } else if (!this.getPortrait().equals(other.getPortrait())) {
                    break label176;
                }

                if (this.getPicNo() == null) {
                    if (other.getPicNo() != null) {
                        break label176;
                    }
                } else if (!this.getPicNo().equals(other.getPicNo())) {
                    break label176;
                }

                if (this.getContent() == null) {
                    if (other.getContent() != null) {
                        break label176;
                    }
                } else if (!this.getContent().equals(other.getContent())) {
                    break label176;
                }

                if (this.getSecretKey() == null) {
                    if (other.getSecretKey() != null) {
                        break label176;
                    }
                } else if (!this.getSecretKey().equals(other.getSecretKey())) {
                    break label176;
                }

                if (this.getName() == null) {
                    if (other.getName() != null) {
                        break label176;
                    }
                } else if (!this.getName().equals(other.getName())) {
                    break label176;
                }

                if (this.getAttrib() == null) {
                    if (other.getAttrib() != null) {
                        break label176;
                    }
                } else if (!this.getAttrib().equals(other.getAttrib())) {
                    break label176;
                }

                if (this.getAddTime() == null) {
                    if (other.getAddTime() != null) {
                        break label176;
                    }
                } else if (!this.getAddTime().equals(other.getAddTime())) {
                    break label176;
                }

                if (this.getUpdateTimes() == null) {
                    if (other.getUpdateTimes() != null) {
                        break label176;
                    }
                } else if (!this.getUpdateTimes().equals(other.getUpdateTimes())) {
                    break label176;
                }

                if (this.getDeleted() == null) {
                    if (other.getDeleted() != null) {
                        break label176;
                    }
                } else if (!this.getDeleted().equals(other.getDeleted())) {
                    break label176;
                }

                if (this.getUpdateTime() == null) {
                    if (other.getUpdateTime() != null) {
                        break label176;
                    }
                } else if (!this.getUpdateTime().equals(other.getUpdateTime())) {
                    break label176;
                }

                if (this.getIdname() == null) {
                    if (other.getIdname() != null) {
                        break label176;
                    }
                } else if (!this.getIdname().equals(other.getIdname())) {
                    break label176;
                }

                if (this.getNext() == null) {
                    if (other.getNext() != null) {
                        break label176;
                    }
                } else if (!this.getNext().equals(other.getNext())) {
                    break label176;
                }

                if (this.getCurrentTask() == null) {
                    if (other.getCurrentTask() != null) {
                        break label176;
                    }
                } else if (!this.getCurrentTask().equals(other.getCurrentTask())) {
                    break label176;
                }

                if (this.getUncontent() == null) {
                    if (other.getUncontent() != null) {
                        break label176;
                    }
                } else if (!this.getUncontent().equals(other.getUncontent())) {
                    break label176;
                }

                if (this.getZhuangbei() == null) {
                    if (other.getZhuangbei() != null) {
                        break label176;
                    }
                } else if (!this.getZhuangbei().equals(other.getZhuangbei())) {
                    break label176;
                }

                if (this.getJingyan() == null) {
                    if (other.getJingyan() != null) {
                        break label176;
                    }
                } else if (!this.getJingyan().equals(other.getJingyan())) {
                    break label176;
                }

                if (this.getMoney() == null) {
                    if (other.getMoney() != null) {
                        break label176;
                    }
                } else if (!this.getMoney().equals(other.getMoney())) {
                    break label176;
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
        result = 31 * result + (this.getPortrait() == null ? 0 : this.getPortrait().hashCode());
        result = 31 * result + (this.getPicNo() == null ? 0 : this.getPicNo().hashCode());
        result = 31 * result + (this.getContent() == null ? 0 : this.getContent().hashCode());
        result = 31 * result + (this.getSecretKey() == null ? 0 : this.getSecretKey().hashCode());
        result = 31 * result + (this.getName() == null ? 0 : this.getName().hashCode());
        result = 31 * result + (this.getAttrib() == null ? 0 : this.getAttrib().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTimes() == null ? 0 : this.getUpdateTimes().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getIdname() == null ? 0 : this.getIdname().hashCode());
        result = 31 * result + (this.getNext() == null ? 0 : this.getNext().hashCode());
        result = 31 * result + (this.getCurrentTask() == null ? 0 : this.getCurrentTask().hashCode());
        result = 31 * result + (this.getUncontent() == null ? 0 : this.getUncontent().hashCode());
        result = 31 * result + (this.getZhuangbei() == null ? 0 : this.getZhuangbei().hashCode());
        result = 31 * result + (this.getJingyan() == null ? 0 : this.getJingyan().hashCode());
        result = 31 * result + (this.getMoney() == null ? 0 : this.getMoney().hashCode());
        return result;
    }

    public NpcDialogueFrame clone() throws CloneNotSupportedException {
        return (NpcDialogueFrame)super.clone();
    }

    static {
        IS_DELETED = NpcDialogueFrame.Deleted.IS_DELETED.value();
        NOT_DELETED = NpcDialogueFrame.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        portrait("portrait", "portrait", "INTEGER", false),
        picNo("pic_no", "picNo", "INTEGER", false),
        content("content", "content", "VARCHAR", false),
        secretKey("secret_key", "secretKey", "VARCHAR", false),
        name("name", "name", "VARCHAR", true),
        attrib("attrib", "attrib", "INTEGER", false),
        addTime("add_time", "addTime", "TIMESTAMP", false),
        updateTimes("update_times", "updateTimes", "TIMESTAMP", false),
        deleted("deleted", "deleted", "BIT", false),
        updateTime("update_time", "updateTime", "TIMESTAMP", false),
        idname("idname", "idname", "INTEGER", false),
        next("next", "next", "VARCHAR", true),
        currentTask("current_task", "currentTask", "VARCHAR", false),
        uncontent("uncontent", "uncontent", "VARCHAR", false),
        zhuangbei("zhuangbei", "zhuangbei", "VARCHAR", false),
        jingyan("jingyan", "jingyan", "INTEGER", false),
        money("money", "money", "INTEGER", false);

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

        public static NpcDialogueFrame.Column[] excludes(NpcDialogueFrame.Column... excludes) {
            ArrayList<NpcDialogueFrame.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (NpcDialogueFrame.Column[])columns.toArray(new NpcDialogueFrame.Column[0]);
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
