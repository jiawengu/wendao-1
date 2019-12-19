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

public class StoreInfo implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private String quality;
    private Integer value;
    private Integer type;
    private String name;
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
    private Integer totalScore;
    private Integer recognizeRecognized;
    private Integer rebuildLevel;
    private Integer silverCoin;
    private static final long serialVersionUID = 1L;

    public StoreInfo() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getQuality() {
        return this.quality;
    }

    public void setQuality(String quality) {
        this.quality = quality;
    }

    public Integer getValue() {
        return this.value;
    }

    public void setValue(Integer value) {
        this.value = value;
    }

    public Integer getType() {
        return this.type;
    }

    public void setType(Integer type) {
        this.type = type;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;
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
        this.setDeleted(deleted ? StoreInfo.Deleted.IS_DELETED.value() : StoreInfo.Deleted.NOT_DELETED.value());
    }

    public Boolean getDeleted() {
        return this.deleted;
    }

    public void setDeleted(Boolean deleted) {
        this.deleted = deleted;
    }

    public Integer getTotalScore() {
        return this.totalScore;
    }

    public void setTotalScore(Integer totalScore) {
        this.totalScore = totalScore;
    }

    public Integer getRecognizeRecognized() {
        return this.recognizeRecognized;
    }

    public void setRecognizeRecognized(Integer recognizeRecognized) {
        this.recognizeRecognized = recognizeRecognized;
    }

    public Integer getRebuildLevel() {
        return this.rebuildLevel;
    }

    public void setRebuildLevel(Integer rebuildLevel) {
        this.rebuildLevel = rebuildLevel;
    }

    public Integer getSilverCoin() {
        return this.silverCoin;
    }

    public void setSilverCoin(Integer silverCoin) {
        this.silverCoin = silverCoin;
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(this.getClass().getSimpleName());
        sb.append(" [");
        sb.append("Hash = ").append(this.hashCode());
        sb.append(", IS_DELETED=").append(IS_DELETED);
        sb.append(", NOT_DELETED=").append(NOT_DELETED);
        sb.append(", id=").append(this.id);
        sb.append(", quality=").append(this.quality);
        sb.append(", value=").append(this.value);
        sb.append(", type=").append(this.type);
        sb.append(", name=").append(this.name);
        sb.append(", addTime=").append(this.addTime);
        sb.append(", updateTime=").append(this.updateTime);
        sb.append(", deleted=").append(this.deleted);
        sb.append(", totalScore=").append(this.totalScore);
        sb.append(", recognizeRecognized=").append(this.recognizeRecognized);
        sb.append(", rebuildLevel=").append(this.rebuildLevel);
        sb.append(", silverCoin=").append(this.silverCoin);
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
                    StoreInfo other = (StoreInfo)that;
                    if (this.getId() == null) {
                        if (other.getId() != null) {
                            break label121;
                        }
                    } else if (!this.getId().equals(other.getId())) {
                        break label121;
                    }

                    if (this.getQuality() == null) {
                        if (other.getQuality() != null) {
                            break label121;
                        }
                    } else if (!this.getQuality().equals(other.getQuality())) {
                        break label121;
                    }

                    if (this.getValue() == null) {
                        if (other.getValue() != null) {
                            break label121;
                        }
                    } else if (!this.getValue().equals(other.getValue())) {
                        break label121;
                    }

                    if (this.getType() == null) {
                        if (other.getType() != null) {
                            break label121;
                        }
                    } else if (!this.getType().equals(other.getType())) {
                        break label121;
                    }

                    if (this.getName() == null) {
                        if (other.getName() != null) {
                            break label121;
                        }
                    } else if (!this.getName().equals(other.getName())) {
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
                        if (other.getDeleted() != null) {
                            break label121;
                        }
                    } else if (!this.getDeleted().equals(other.getDeleted())) {
                        break label121;
                    }

                    if (this.getTotalScore() == null) {
                        if (other.getTotalScore() != null) {
                            break label121;
                        }
                    } else if (!this.getTotalScore().equals(other.getTotalScore())) {
                        break label121;
                    }

                    if (this.getRecognizeRecognized() == null) {
                        if (other.getRecognizeRecognized() != null) {
                            break label121;
                        }
                    } else if (!this.getRecognizeRecognized().equals(other.getRecognizeRecognized())) {
                        break label121;
                    }

                    if (this.getRebuildLevel() == null) {
                        if (other.getRebuildLevel() != null) {
                            break label121;
                        }
                    } else if (!this.getRebuildLevel().equals(other.getRebuildLevel())) {
                        break label121;
                    }

                    if (this.getSilverCoin() == null) {
                        if (other.getSilverCoin() == null) {
                            break label129;
                        }
                    } else if (this.getSilverCoin().equals(other.getSilverCoin())) {
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
        result = 31 * result + (this.getQuality() == null ? 0 : this.getQuality().hashCode());
        result = 31 * result + (this.getValue() == null ? 0 : this.getValue().hashCode());
        result = 31 * result + (this.getType() == null ? 0 : this.getType().hashCode());
        result = 31 * result + (this.getName() == null ? 0 : this.getName().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        result = 31 * result + (this.getTotalScore() == null ? 0 : this.getTotalScore().hashCode());
        result = 31 * result + (this.getRecognizeRecognized() == null ? 0 : this.getRecognizeRecognized().hashCode());
        result = 31 * result + (this.getRebuildLevel() == null ? 0 : this.getRebuildLevel().hashCode());
        result = 31 * result + (this.getSilverCoin() == null ? 0 : this.getSilverCoin().hashCode());
        return result;
    }

    public StoreInfo clone() throws CloneNotSupportedException {
        return (StoreInfo)super.clone();
    }

    static {
        IS_DELETED = StoreInfo.Deleted.IS_DELETED.value();
        NOT_DELETED = StoreInfo.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        quality("quality", "quality", "VARCHAR", false),
        value("value", "value", "INTEGER", true),
        type("type", "type", "INTEGER", true),
        name("name", "name", "VARCHAR", true),
        addTime("add_time", "addTime", "TIMESTAMP", false),
        updateTime("update_time", "updateTime", "TIMESTAMP", false),
        deleted("deleted", "deleted", "BIT", false),
        totalScore("total_score", "totalScore", "INTEGER", false),
        recognizeRecognized("recognize_recognized", "recognizeRecognized", "INTEGER", false),
        rebuildLevel("rebuild_level", "rebuildLevel", "INTEGER", false),
        silverCoin("silver_coin", "silverCoin", "INTEGER", false);

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

        public static StoreInfo.Column[] excludes(StoreInfo.Column... excludes) {
            ArrayList<StoreInfo.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (StoreInfo.Column[])columns.toArray(new StoreInfo.Column[0]);
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
