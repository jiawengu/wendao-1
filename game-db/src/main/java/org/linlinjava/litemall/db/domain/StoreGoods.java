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

public class StoreGoods implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private String name;
    private String barcode;
    private Integer forSale;
    private Integer showPos;
    private Integer rpos;
    private Integer saleQuota;
    private Integer recommend;
    private Integer coin;
    private Integer discount;
    private Integer type;
    private Integer quotaLimit;
    private Integer mustVip;
    private Integer isGift;
    private Integer followPetType;
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

    public StoreGoods() {
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

    public String getBarcode() {
        return this.barcode;
    }

    public void setBarcode(String barcode) {
        this.barcode = barcode;
    }

    public Integer getForSale() {
        return this.forSale;
    }

    public void setForSale(Integer forSale) {
        this.forSale = forSale;
    }

    public Integer getShowPos() {
        return this.showPos;
    }

    public void setShowPos(Integer showPos) {
        this.showPos = showPos;
    }

    public Integer getRpos() {
        return this.rpos;
    }

    public void setRpos(Integer rpos) {
        this.rpos = rpos;
    }

    public Integer getSaleQuota() {
        return this.saleQuota;
    }

    public void setSaleQuota(Integer saleQuota) {
        this.saleQuota = saleQuota;
    }

    public Integer getRecommend() {
        return this.recommend;
    }

    public void setRecommend(Integer recommend) {
        this.recommend = recommend;
    }

    public Integer getCoin() {
        return this.coin;
    }

    public void setCoin(Integer coin) {
        this.coin = coin;
    }

    public Integer getDiscount() {
        return this.discount;
    }

    public void setDiscount(Integer discount) {
        this.discount = discount;
    }

    public Integer getType() {
        return this.type;
    }

    public void setType(Integer type) {
        this.type = type;
    }

    public Integer getQuotaLimit() {
        return this.quotaLimit;
    }

    public void setQuotaLimit(Integer quotaLimit) {
        this.quotaLimit = quotaLimit;
    }

    public Integer getMustVip() {
        return this.mustVip;
    }

    public void setMustVip(Integer mustVip) {
        this.mustVip = mustVip;
    }

    public Integer getIsGift() {
        return this.isGift;
    }

    public void setIsGift(Integer isGift) {
        this.isGift = isGift;
    }

    public Integer getFollowPetType() {
        return this.followPetType;
    }

    public void setFollowPetType(Integer followPetType) {
        this.followPetType = followPetType;
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
        this.setDeleted(deleted ? StoreGoods.Deleted.IS_DELETED.value() : StoreGoods.Deleted.NOT_DELETED.value());
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
        sb.append(", name=").append(this.name);
        sb.append(", barcode=").append(this.barcode);
        sb.append(", forSale=").append(this.forSale);
        sb.append(", showPos=").append(this.showPos);
        sb.append(", rpos=").append(this.rpos);
        sb.append(", saleQuota=").append(this.saleQuota);
        sb.append(", recommend=").append(this.recommend);
        sb.append(", coin=").append(this.coin);
        sb.append(", discount=").append(this.discount);
        sb.append(", type=").append(this.type);
        sb.append(", quotaLimit=").append(this.quotaLimit);
        sb.append(", mustVip=").append(this.mustVip);
        sb.append(", isGift=").append(this.isGift);
        sb.append(", followPetType=").append(this.followPetType);
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
            label176: {
                StoreGoods other = (StoreGoods)that;
                if (this.getId() == null) {
                    if (other.getId() != null) {
                        break label176;
                    }
                } else if (!this.getId().equals(other.getId())) {
                    break label176;
                }

                if (this.getName() == null) {
                    if (other.getName() != null) {
                        break label176;
                    }
                } else if (!this.getName().equals(other.getName())) {
                    break label176;
                }

                if (this.getBarcode() == null) {
                    if (other.getBarcode() != null) {
                        break label176;
                    }
                } else if (!this.getBarcode().equals(other.getBarcode())) {
                    break label176;
                }

                if (this.getForSale() == null) {
                    if (other.getForSale() != null) {
                        break label176;
                    }
                } else if (!this.getForSale().equals(other.getForSale())) {
                    break label176;
                }

                if (this.getShowPos() == null) {
                    if (other.getShowPos() != null) {
                        break label176;
                    }
                } else if (!this.getShowPos().equals(other.getShowPos())) {
                    break label176;
                }

                if (this.getRpos() == null) {
                    if (other.getRpos() != null) {
                        break label176;
                    }
                } else if (!this.getRpos().equals(other.getRpos())) {
                    break label176;
                }

                if (this.getSaleQuota() == null) {
                    if (other.getSaleQuota() != null) {
                        break label176;
                    }
                } else if (!this.getSaleQuota().equals(other.getSaleQuota())) {
                    break label176;
                }

                if (this.getRecommend() == null) {
                    if (other.getRecommend() != null) {
                        break label176;
                    }
                } else if (!this.getRecommend().equals(other.getRecommend())) {
                    break label176;
                }

                if (this.getCoin() == null) {
                    if (other.getCoin() != null) {
                        break label176;
                    }
                } else if (!this.getCoin().equals(other.getCoin())) {
                    break label176;
                }

                if (this.getDiscount() == null) {
                    if (other.getDiscount() != null) {
                        break label176;
                    }
                } else if (!this.getDiscount().equals(other.getDiscount())) {
                    break label176;
                }

                if (this.getType() == null) {
                    if (other.getType() != null) {
                        break label176;
                    }
                } else if (!this.getType().equals(other.getType())) {
                    break label176;
                }

                if (this.getQuotaLimit() == null) {
                    if (other.getQuotaLimit() != null) {
                        break label176;
                    }
                } else if (!this.getQuotaLimit().equals(other.getQuotaLimit())) {
                    break label176;
                }

                if (this.getMustVip() == null) {
                    if (other.getMustVip() != null) {
                        break label176;
                    }
                } else if (!this.getMustVip().equals(other.getMustVip())) {
                    break label176;
                }

                if (this.getIsGift() == null) {
                    if (other.getIsGift() != null) {
                        break label176;
                    }
                } else if (!this.getIsGift().equals(other.getIsGift())) {
                    break label176;
                }

                if (this.getFollowPetType() == null) {
                    if (other.getFollowPetType() != null) {
                        break label176;
                    }
                } else if (!this.getFollowPetType().equals(other.getFollowPetType())) {
                    break label176;
                }

                if (this.getAddTime() == null) {
                    if (other.getAddTime() != null) {
                        break label176;
                    }
                } else if (!this.getAddTime().equals(other.getAddTime())) {
                    break label176;
                }

                if (this.getUpdateTime() == null) {
                    if (other.getUpdateTime() != null) {
                        break label176;
                    }
                } else if (!this.getUpdateTime().equals(other.getUpdateTime())) {
                    break label176;
                }

                if (this.getDeleted() == null) {
                    if (other.getDeleted() != null) {
                        break label176;
                    }
                } else if (!this.getDeleted().equals(other.getDeleted())) {
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
        result = 31 * result + (this.getName() == null ? 0 : this.getName().hashCode());
        result = 31 * result + (this.getBarcode() == null ? 0 : this.getBarcode().hashCode());
        result = 31 * result + (this.getForSale() == null ? 0 : this.getForSale().hashCode());
        result = 31 * result + (this.getShowPos() == null ? 0 : this.getShowPos().hashCode());
        result = 31 * result + (this.getRpos() == null ? 0 : this.getRpos().hashCode());
        result = 31 * result + (this.getSaleQuota() == null ? 0 : this.getSaleQuota().hashCode());
        result = 31 * result + (this.getRecommend() == null ? 0 : this.getRecommend().hashCode());
        result = 31 * result + (this.getCoin() == null ? 0 : this.getCoin().hashCode());
        result = 31 * result + (this.getDiscount() == null ? 0 : this.getDiscount().hashCode());
        result = 31 * result + (this.getType() == null ? 0 : this.getType().hashCode());
        result = 31 * result + (this.getQuotaLimit() == null ? 0 : this.getQuotaLimit().hashCode());
        result = 31 * result + (this.getMustVip() == null ? 0 : this.getMustVip().hashCode());
        result = 31 * result + (this.getIsGift() == null ? 0 : this.getIsGift().hashCode());
        result = 31 * result + (this.getFollowPetType() == null ? 0 : this.getFollowPetType().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        return result;
    }

    public StoreGoods clone() throws CloneNotSupportedException {
        return (StoreGoods)super.clone();
    }

    static {
        IS_DELETED = StoreGoods.Deleted.IS_DELETED.value();
        NOT_DELETED = StoreGoods.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        name("name", "name", "VARCHAR", true),
        barcode("barcode", "barcode", "VARCHAR", false),
        forSale("for_sale", "forSale", "INTEGER", false),
        showPos("show_pos", "showPos", "INTEGER", false),
        rpos("rpos", "rpos", "INTEGER", false),
        saleQuota("sale_quota", "saleQuota", "INTEGER", false),
        recommend("recommend", "recommend", "INTEGER", false),
        coin("coin", "coin", "INTEGER", false),
        discount("discount", "discount", "INTEGER", false),
        type("type", "type", "INTEGER", true),
        quotaLimit("quota_limit", "quotaLimit", "INTEGER", false),
        mustVip("must_vip", "mustVip", "INTEGER", false),
        isGift("is_gift", "isGift", "INTEGER", false),
        followPetType("follow_pet_type", "followPetType", "INTEGER", false),
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

        public static StoreGoods.Column[] excludes(StoreGoods.Column... excludes) {
            ArrayList<StoreGoods.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (StoreGoods.Column[])columns.toArray(new StoreGoods.Column[0]);
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
