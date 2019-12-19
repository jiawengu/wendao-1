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

public class SaleGood implements Cloneable, Serializable, Comparable<SaleGood> {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private String goodsId;
    private String name;
    private Integer startTime;
    private Integer endTime;
    private Integer price;
    private Integer reqLevel;
    private String ownerUuid;
    private String str;
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
    private String pet;
    private Integer pos;
    private Integer ispet;
    private Integer level;
    private String goods;
    private static final long serialVersionUID = 1L;

    public SaleGood() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getGoodsId() {
        return this.goodsId;
    }

    public void setGoodsId(String goodsId) {
        this.goodsId = goodsId;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getStartTime() {
        return this.startTime;
    }

    public void setStartTime(Integer startTime) {
        this.startTime = startTime;
    }

    public Integer getEndTime() {
        return this.endTime;
    }

    public void setEndTime(Integer endTime) {
        this.endTime = endTime;
    }

    public Integer getPrice() {
        return this.price;
    }

    public void setPrice(Integer price) {
        this.price = price;
    }

    public Integer getReqLevel() {
        return this.reqLevel;
    }

    public void setReqLevel(Integer reqLevel) {
        this.reqLevel = reqLevel;
    }

    public String getOwnerUuid() {
        return this.ownerUuid;
    }

    public void setOwnerUuid(String ownerUuid) {
        this.ownerUuid = ownerUuid;
    }

    public String getStr() {
        return this.str;
    }

    public void setStr(String str) {
        this.str = str;
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
        this.setDeleted(deleted ? SaleGood.Deleted.IS_DELETED.value() : SaleGood.Deleted.NOT_DELETED.value());
    }

    public Boolean getDeleted() {
        return this.deleted;
    }

    public void setDeleted(Boolean deleted) {
        this.deleted = deleted;
    }

    public String getPet() {
        return this.pet;
    }

    public void setPet(String pet) {
        this.pet = pet;
    }

    public Integer getPos() {
        return this.pos;
    }

    public void setPos(Integer pos) {
        this.pos = pos;
    }

    public Integer getIspet() {
        return this.ispet;
    }

    public void setIspet(Integer ispet) {
        this.ispet = ispet;
    }

    public Integer getLevel() {
        return this.level;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }

    public String getGoods() {
        return this.goods;
    }

    public void setGoods(String goods) {
        this.goods = goods;
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(this.getClass().getSimpleName());
        sb.append(" [");
        sb.append("Hash = ").append(this.hashCode());
        sb.append(", IS_DELETED=").append(IS_DELETED);
        sb.append(", NOT_DELETED=").append(NOT_DELETED);
        sb.append(", id=").append(this.id);
        sb.append(", goodsId=").append(this.goodsId);
        sb.append(", name=").append(this.name);
        sb.append(", startTime=").append(this.startTime);
        sb.append(", endTime=").append(this.endTime);
        sb.append(", price=").append(this.price);
        sb.append(", reqLevel=").append(this.reqLevel);
        sb.append(", ownerUuid=").append(this.ownerUuid);
        sb.append(", str=").append(this.str);
        sb.append(", addTime=").append(this.addTime);
        sb.append(", updateTime=").append(this.updateTime);
        sb.append(", deleted=").append(this.deleted);
        sb.append(", pet=").append(this.pet);
        sb.append(", pos=").append(this.pos);
        sb.append(", ispet=").append(this.ispet);
        sb.append(", level=").append(this.level);
        sb.append(", goods=").append(this.goods);
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
            label169: {
                label161: {
                    SaleGood other = (SaleGood)that;
                    if (this.getId() == null) {
                        if (other.getId() != null) {
                            break label161;
                        }
                    } else if (!this.getId().equals(other.getId())) {
                        break label161;
                    }

                    if (this.getGoodsId() == null) {
                        if (other.getGoodsId() != null) {
                            break label161;
                        }
                    } else if (!this.getGoodsId().equals(other.getGoodsId())) {
                        break label161;
                    }

                    if (this.getName() == null) {
                        if (other.getName() != null) {
                            break label161;
                        }
                    } else if (!this.getName().equals(other.getName())) {
                        break label161;
                    }

                    if (this.getStartTime() == null) {
                        if (other.getStartTime() != null) {
                            break label161;
                        }
                    } else if (!this.getStartTime().equals(other.getStartTime())) {
                        break label161;
                    }

                    if (this.getEndTime() == null) {
                        if (other.getEndTime() != null) {
                            break label161;
                        }
                    } else if (!this.getEndTime().equals(other.getEndTime())) {
                        break label161;
                    }

                    if (this.getPrice() == null) {
                        if (other.getPrice() != null) {
                            break label161;
                        }
                    } else if (!this.getPrice().equals(other.getPrice())) {
                        break label161;
                    }

                    if (this.getReqLevel() == null) {
                        if (other.getReqLevel() != null) {
                            break label161;
                        }
                    } else if (!this.getReqLevel().equals(other.getReqLevel())) {
                        break label161;
                    }

                    if (this.getOwnerUuid() == null) {
                        if (other.getOwnerUuid() != null) {
                            break label161;
                        }
                    } else if (!this.getOwnerUuid().equals(other.getOwnerUuid())) {
                        break label161;
                    }

                    if (this.getStr() == null) {
                        if (other.getStr() != null) {
                            break label161;
                        }
                    } else if (!this.getStr().equals(other.getStr())) {
                        break label161;
                    }

                    if (this.getAddTime() == null) {
                        if (other.getAddTime() != null) {
                            break label161;
                        }
                    } else if (!this.getAddTime().equals(other.getAddTime())) {
                        break label161;
                    }

                    if (this.getUpdateTime() == null) {
                        if (other.getUpdateTime() != null) {
                            break label161;
                        }
                    } else if (!this.getUpdateTime().equals(other.getUpdateTime())) {
                        break label161;
                    }

                    if (this.getDeleted() == null) {
                        if (other.getDeleted() != null) {
                            break label161;
                        }
                    } else if (!this.getDeleted().equals(other.getDeleted())) {
                        break label161;
                    }

                    if (this.getPet() == null) {
                        if (other.getPet() != null) {
                            break label161;
                        }
                    } else if (!this.getPet().equals(other.getPet())) {
                        break label161;
                    }

                    if (this.getPos() == null) {
                        if (other.getPos() != null) {
                            break label161;
                        }
                    } else if (!this.getPos().equals(other.getPos())) {
                        break label161;
                    }

                    if (this.getIspet() == null) {
                        if (other.getIspet() != null) {
                            break label161;
                        }
                    } else if (!this.getIspet().equals(other.getIspet())) {
                        break label161;
                    }

                    if (this.getLevel() == null) {
                        if (other.getLevel() != null) {
                            break label161;
                        }
                    } else if (!this.getLevel().equals(other.getLevel())) {
                        break label161;
                    }

                    if (this.getGoods() == null) {
                        if (other.getGoods() == null) {
                            break label169;
                        }
                    } else if (this.getGoods().equals(other.getGoods())) {
                        break label169;
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
        result = 31 * result + (this.getGoodsId() == null ? 0 : this.getGoodsId().hashCode());
        result = 31 * result + (this.getName() == null ? 0 : this.getName().hashCode());
        result = 31 * result + (this.getStartTime() == null ? 0 : this.getStartTime().hashCode());
        result = 31 * result + (this.getEndTime() == null ? 0 : this.getEndTime().hashCode());
        result = 31 * result + (this.getPrice() == null ? 0 : this.getPrice().hashCode());
        result = 31 * result + (this.getReqLevel() == null ? 0 : this.getReqLevel().hashCode());
        result = 31 * result + (this.getOwnerUuid() == null ? 0 : this.getOwnerUuid().hashCode());
        result = 31 * result + (this.getStr() == null ? 0 : this.getStr().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        result = 31 * result + (this.getPet() == null ? 0 : this.getPet().hashCode());
        result = 31 * result + (this.getPos() == null ? 0 : this.getPos().hashCode());
        result = 31 * result + (this.getIspet() == null ? 0 : this.getIspet().hashCode());
        result = 31 * result + (this.getLevel() == null ? 0 : this.getLevel().hashCode());
        result = 31 * result + (this.getGoods() == null ? 0 : this.getGoods().hashCode());
        return result;
    }

    public SaleGood clone() throws CloneNotSupportedException {
        return (SaleGood)super.clone();
    }

    public int compareTo(SaleGood o) {
        return this.getPrice().compareTo(o.getPrice());
    }

    static {
        IS_DELETED = SaleGood.Deleted.IS_DELETED.value();
        NOT_DELETED = SaleGood.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        goodsId("goods_id", "goodsId", "VARCHAR", false),
        name("name", "name", "VARCHAR", true),
        startTime("start_time", "startTime", "INTEGER", false),
        endTime("end_time", "endTime", "INTEGER", false),
        price("price", "price", "INTEGER", false),
        reqLevel("req_level", "reqLevel", "INTEGER", false),
        ownerUuid("owner_uuid", "ownerUuid", "VARCHAR", false),
        str("str", "str", "VARCHAR", false),
        addTime("add_time", "addTime", "TIMESTAMP", false),
        updateTime("update_time", "updateTime", "TIMESTAMP", false),
        deleted("deleted", "deleted", "BIT", false),
        pet("pet", "pet", "VARCHAR", false),
        pos("pos", "pos", "INTEGER", false),
        ispet("ispet", "ispet", "INTEGER", false),
        level("level", "level", "INTEGER", true),
        goods("goods", "goods", "LONGVARCHAR", false);

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

        public static SaleGood.Column[] excludes(SaleGood.Column... excludes) {
            ArrayList<SaleGood.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (SaleGood.Column[])columns.toArray(new SaleGood.Column[0]);
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
