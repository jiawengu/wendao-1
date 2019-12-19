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

public class PackModification implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private String alias;
    private String fasionType;
    private String str;
    private String type;
    private Integer foodNum;
    private Integer goodsPrice;
    private Integer sex;
    private Integer position;
    private Integer category;
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

    public PackModification() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getAlias() {
        return this.alias;
    }

    public void setAlias(String alias) {
        this.alias = alias;
    }

    public String getFasionType() {
        return this.fasionType;
    }

    public void setFasionType(String fasionType) {
        this.fasionType = fasionType;
    }

    public String getStr() {
        return this.str;
    }

    public void setStr(String str) {
        this.str = str;
    }

    public String getType() {
        return this.type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Integer getFoodNum() {
        return this.foodNum;
    }

    public void setFoodNum(Integer foodNum) {
        this.foodNum = foodNum;
    }

    public Integer getGoodsPrice() {
        return this.goodsPrice;
    }

    public void setGoodsPrice(Integer goodsPrice) {
        this.goodsPrice = goodsPrice;
    }

    public Integer getSex() {
        return this.sex;
    }

    public void setSex(Integer sex) {
        this.sex = sex;
    }

    public Integer getPosition() {
        return this.position;
    }

    public void setPosition(Integer position) {
        this.position = position;
    }

    public Integer getCategory() {
        return this.category;
    }

    public void setCategory(Integer category) {
        this.category = category;
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
        this.setDeleted(deleted ? PackModification.Deleted.IS_DELETED.value() : PackModification.Deleted.NOT_DELETED.value());
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
        sb.append(", alias=").append(this.alias);
        sb.append(", fasionType=").append(this.fasionType);
        sb.append(", str=").append(this.str);
        sb.append(", type=").append(this.type);
        sb.append(", foodNum=").append(this.foodNum);
        sb.append(", goodsPrice=").append(this.goodsPrice);
        sb.append(", sex=").append(this.sex);
        sb.append(", position=").append(this.position);
        sb.append(", category=").append(this.category);
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
                    PackModification other = (PackModification)that;
                    if (this.getId() == null) {
                        if (other.getId() != null) {
                            break label129;
                        }
                    } else if (!this.getId().equals(other.getId())) {
                        break label129;
                    }

                    if (this.getAlias() == null) {
                        if (other.getAlias() != null) {
                            break label129;
                        }
                    } else if (!this.getAlias().equals(other.getAlias())) {
                        break label129;
                    }

                    if (this.getFasionType() == null) {
                        if (other.getFasionType() != null) {
                            break label129;
                        }
                    } else if (!this.getFasionType().equals(other.getFasionType())) {
                        break label129;
                    }

                    if (this.getStr() == null) {
                        if (other.getStr() != null) {
                            break label129;
                        }
                    } else if (!this.getStr().equals(other.getStr())) {
                        break label129;
                    }

                    if (this.getType() == null) {
                        if (other.getType() != null) {
                            break label129;
                        }
                    } else if (!this.getType().equals(other.getType())) {
                        break label129;
                    }

                    if (this.getFoodNum() == null) {
                        if (other.getFoodNum() != null) {
                            break label129;
                        }
                    } else if (!this.getFoodNum().equals(other.getFoodNum())) {
                        break label129;
                    }

                    if (this.getGoodsPrice() == null) {
                        if (other.getGoodsPrice() != null) {
                            break label129;
                        }
                    } else if (!this.getGoodsPrice().equals(other.getGoodsPrice())) {
                        break label129;
                    }

                    if (this.getSex() == null) {
                        if (other.getSex() != null) {
                            break label129;
                        }
                    } else if (!this.getSex().equals(other.getSex())) {
                        break label129;
                    }

                    if (this.getPosition() == null) {
                        if (other.getPosition() != null) {
                            break label129;
                        }
                    } else if (!this.getPosition().equals(other.getPosition())) {
                        break label129;
                    }

                    if (this.getCategory() == null) {
                        if (other.getCategory() != null) {
                            break label129;
                        }
                    } else if (!this.getCategory().equals(other.getCategory())) {
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
        result = 31 * result + (this.getAlias() == null ? 0 : this.getAlias().hashCode());
        result = 31 * result + (this.getFasionType() == null ? 0 : this.getFasionType().hashCode());
        result = 31 * result + (this.getStr() == null ? 0 : this.getStr().hashCode());
        result = 31 * result + (this.getType() == null ? 0 : this.getType().hashCode());
        result = 31 * result + (this.getFoodNum() == null ? 0 : this.getFoodNum().hashCode());
        result = 31 * result + (this.getGoodsPrice() == null ? 0 : this.getGoodsPrice().hashCode());
        result = 31 * result + (this.getSex() == null ? 0 : this.getSex().hashCode());
        result = 31 * result + (this.getPosition() == null ? 0 : this.getPosition().hashCode());
        result = 31 * result + (this.getCategory() == null ? 0 : this.getCategory().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        return result;
    }

    public PackModification clone() throws CloneNotSupportedException {
        return (PackModification)super.clone();
    }

    static {
        IS_DELETED = PackModification.Deleted.IS_DELETED.value();
        NOT_DELETED = PackModification.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        alias("alias", "alias", "VARCHAR", true),
        fasionType("fasion_type", "fasionType", "VARCHAR", false),
        str("str", "str", "VARCHAR", false),
        type("type", "type", "VARCHAR", true),
        foodNum("food_num", "foodNum", "INTEGER", false),
        goodsPrice("goods_price", "goodsPrice", "INTEGER", false),
        sex("sex", "sex", "INTEGER", false),
        position("position", "position", "INTEGER", true),
        category("category", "category", "INTEGER", false),
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

        public static PackModification.Column[] excludes(PackModification.Column... excludes) {
            ArrayList<PackModification.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (PackModification.Column[])columns.toArray(new PackModification.Column[0]);
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
