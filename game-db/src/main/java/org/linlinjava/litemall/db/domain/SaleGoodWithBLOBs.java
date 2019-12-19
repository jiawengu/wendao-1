//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;

public class SaleGoodWithBLOBs extends SaleGood implements Cloneable, Serializable {
    private String goods;
    private String pet;
    private static final long serialVersionUID = 1L;

    public SaleGoodWithBLOBs() {
    }

    public String getGoods() {
        return this.goods;
    }

    public void setGoods(String goods) {
        this.goods = goods;
    }

    public String getPet() {
        return this.pet;
    }

    public void setPet(String pet) {
        this.pet = pet;
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(this.getClass().getSimpleName());
        sb.append(" [");
        sb.append("Hash = ").append(this.hashCode());
        sb.append(", goods=").append(this.goods);
        sb.append(", pet=").append(this.pet);
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
            label153: {
                label145: {
                    SaleGoodWithBLOBs other = (SaleGoodWithBLOBs)that;
                    if (this.getId() == null) {
                        if (other.getId() != null) {
                            break label145;
                        }
                    } else if (!this.getId().equals(other.getId())) {
                        break label145;
                    }

                    if (this.getGoodsId() == null) {
                        if (other.getGoodsId() != null) {
                            break label145;
                        }
                    } else if (!this.getGoodsId().equals(other.getGoodsId())) {
                        break label145;
                    }

                    if (this.getName() == null) {
                        if (other.getName() != null) {
                            break label145;
                        }
                    } else if (!this.getName().equals(other.getName())) {
                        break label145;
                    }

                    if (this.getStartTime() == null) {
                        if (other.getStartTime() != null) {
                            break label145;
                        }
                    } else if (!this.getStartTime().equals(other.getStartTime())) {
                        break label145;
                    }

                    if (this.getEndTime() == null) {
                        if (other.getEndTime() != null) {
                            break label145;
                        }
                    } else if (!this.getEndTime().equals(other.getEndTime())) {
                        break label145;
                    }

                    if (this.getPrice() == null) {
                        if (other.getPrice() != null) {
                            break label145;
                        }
                    } else if (!this.getPrice().equals(other.getPrice())) {
                        break label145;
                    }

                    if (this.getReqLevel() == null) {
                        if (other.getReqLevel() != null) {
                            break label145;
                        }
                    } else if (!this.getReqLevel().equals(other.getReqLevel())) {
                        break label145;
                    }

                    if (this.getOwnerUuid() == null) {
                        if (other.getOwnerUuid() != null) {
                            break label145;
                        }
                    } else if (!this.getOwnerUuid().equals(other.getOwnerUuid())) {
                        break label145;
                    }

                    if (this.getStr() == null) {
                        if (other.getStr() != null) {
                            break label145;
                        }
                    } else if (!this.getStr().equals(other.getStr())) {
                        break label145;
                    }

                    if (this.getAddTime() == null) {
                        if (other.getAddTime() != null) {
                            break label145;
                        }
                    } else if (!this.getAddTime().equals(other.getAddTime())) {
                        break label145;
                    }

                    if (this.getUpdateTime() == null) {
                        if (other.getUpdateTime() != null) {
                            break label145;
                        }
                    } else if (!this.getUpdateTime().equals(other.getUpdateTime())) {
                        break label145;
                    }

                    if (this.getDeleted() == null) {
                        if (other.getDeleted() != null) {
                            break label145;
                        }
                    } else if (!this.getDeleted().equals(other.getDeleted())) {
                        break label145;
                    }

                    if (this.getPos() == null) {
                        if (other.getPos() != null) {
                            break label145;
                        }
                    } else if (!this.getPos().equals(other.getPos())) {
                        break label145;
                    }

                    if (this.getGoods() == null) {
                        if (other.getGoods() != null) {
                            break label145;
                        }
                    } else if (!this.getGoods().equals(other.getGoods())) {
                        break label145;
                    }

                    if (this.getPet() == null) {
                        if (other.getPet() == null) {
                            break label153;
                        }
                    } else if (this.getPet().equals(other.getPet())) {
                        break label153;
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
        result = 31 * result + (this.getPos() == null ? 0 : this.getPos().hashCode());
        result = 31 * result + (this.getGoods() == null ? 0 : this.getGoods().hashCode());
        result = 31 * result + (this.getPet() == null ? 0 : this.getPet().hashCode());
        return result;
    }

    public SaleGoodWithBLOBs clone() throws CloneNotSupportedException {
        return (SaleGoodWithBLOBs)super.clone();
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
        pos("pos", "pos", "INTEGER", false),
        goods("goods", "goods", "LONGVARCHAR", false),
        pet("pet", "pet", "LONGVARCHAR", false);

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

        public static SaleGoodWithBLOBs.Column[] excludes(SaleGoodWithBLOBs.Column... excludes) {
            ArrayList<SaleGoodWithBLOBs.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (SaleGoodWithBLOBs.Column[])columns.toArray(new SaleGoodWithBLOBs.Column[0]);
        }

        public String getEscapedColumnName() {
            return this.isColumnNameDelimited ? "`" + this.column + "`" : this.column;
        }
    }
}
