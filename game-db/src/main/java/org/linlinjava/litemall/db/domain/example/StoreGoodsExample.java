//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.StoreGoods.Column;
import org.linlinjava.litemall.db.domain.StoreGoods.Deleted;

public class StoreGoodsExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<StoreGoodsExample.Criteria> oredCriteria = new ArrayList();

    public StoreGoodsExample() {
    }

    public void setOrderByClause(String orderByClause) {
        this.orderByClause = orderByClause;
    }

    public String getOrderByClause() {
        return this.orderByClause;
    }

    public void setDistinct(boolean distinct) {
        this.distinct = distinct;
    }

    public boolean isDistinct() {
        return this.distinct;
    }

    public List<StoreGoodsExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(StoreGoodsExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public StoreGoodsExample.Criteria or() {
        StoreGoodsExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public StoreGoodsExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public StoreGoodsExample orderBy(String... orderByClauses) {
        StringBuffer sb = new StringBuffer();

        for(int i = 0; i < orderByClauses.length; ++i) {
            sb.append(orderByClauses[i]);
            if (i < orderByClauses.length - 1) {
                sb.append(" , ");
            }
        }

        this.setOrderByClause(sb.toString());
        return this;
    }

    public StoreGoodsExample.Criteria createCriteria() {
        StoreGoodsExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected StoreGoodsExample.Criteria createCriteriaInternal() {
        StoreGoodsExample.Criteria criteria = new StoreGoodsExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static StoreGoodsExample.Criteria newAndCreateCriteria() {
        StoreGoodsExample example = new StoreGoodsExample();
        return example.createCriteria();
    }

    public StoreGoodsExample when(boolean condition, StoreGoodsExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public StoreGoodsExample when(boolean condition, StoreGoodsExample.IExampleWhen then, StoreGoodsExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(StoreGoodsExample example);
    }

    public interface ICriteriaWhen {
        void criteria(StoreGoodsExample.Criteria criteria);
    }

    public static class Criterion {
        private String condition;
        private Object value;
        private Object secondValue;
        private boolean noValue;
        private boolean singleValue;
        private boolean betweenValue;
        private boolean listValue;
        private String typeHandler;

        public String getCondition() {
            return this.condition;
        }

        public Object getValue() {
            return this.value;
        }

        public Object getSecondValue() {
            return this.secondValue;
        }

        public boolean isNoValue() {
            return this.noValue;
        }

        public boolean isSingleValue() {
            return this.singleValue;
        }

        public boolean isBetweenValue() {
            return this.betweenValue;
        }

        public boolean isListValue() {
            return this.listValue;
        }

        public String getTypeHandler() {
            return this.typeHandler;
        }

        protected Criterion(String condition) {
            this.condition = condition;
            this.typeHandler = null;
            this.noValue = true;
        }

        protected Criterion(String condition, Object value, String typeHandler) {
            this.condition = condition;
            this.value = value;
            this.typeHandler = typeHandler;
            if (value instanceof List) {
                this.listValue = true;
            } else {
                this.singleValue = true;
            }

        }

        protected Criterion(String condition, Object value) {
            this(condition, value, (String)null);
        }

        protected Criterion(String condition, Object value, Object secondValue, String typeHandler) {
            this.condition = condition;
            this.value = value;
            this.secondValue = secondValue;
            this.typeHandler = typeHandler;
            this.betweenValue = true;
        }

        protected Criterion(String condition, Object value, Object secondValue) {
            this(condition, value, secondValue, (String)null);
        }
    }

    public static class Criteria extends StoreGoodsExample.GeneratedCriteria {
        private StoreGoodsExample example;

        protected Criteria(StoreGoodsExample example) {
            this.example = example;
        }

        public StoreGoodsExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public StoreGoodsExample.Criteria andIf(boolean ifAdd, StoreGoodsExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public StoreGoodsExample.Criteria when(boolean condition, StoreGoodsExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public StoreGoodsExample.Criteria when(boolean condition, StoreGoodsExample.ICriteriaWhen then, StoreGoodsExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public StoreGoodsExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            StoreGoodsExample.Criteria add(StoreGoodsExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<StoreGoodsExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<StoreGoodsExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<StoreGoodsExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new StoreGoodsExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new StoreGoodsExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new StoreGoodsExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public StoreGoodsExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeIsNull() {
            this.addCriterion("barcode is null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeIsNotNull() {
            this.addCriterion("barcode is not null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeEqualTo(String value) {
            this.addCriterion("barcode =", value, "barcode");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeEqualToColumn(Column column) {
            this.addCriterion("barcode = " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeNotEqualTo(String value) {
            this.addCriterion("barcode <>", value, "barcode");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeNotEqualToColumn(Column column) {
            this.addCriterion("barcode <> " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeGreaterThan(String value) {
            this.addCriterion("barcode >", value, "barcode");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeGreaterThanColumn(Column column) {
            this.addCriterion("barcode > " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeGreaterThanOrEqualTo(String value) {
            this.addCriterion("barcode >=", value, "barcode");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("barcode >= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeLessThan(String value) {
            this.addCriterion("barcode <", value, "barcode");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeLessThanColumn(Column column) {
            this.addCriterion("barcode < " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeLessThanOrEqualTo(String value) {
            this.addCriterion("barcode <=", value, "barcode");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("barcode <= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeLike(String value) {
            this.addCriterion("barcode like", value, "barcode");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeNotLike(String value) {
            this.addCriterion("barcode not like", value, "barcode");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeIn(List<String> values) {
            this.addCriterion("barcode in", values, "barcode");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeNotIn(List<String> values) {
            this.addCriterion("barcode not in", values, "barcode");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeBetween(String value1, String value2) {
            this.addCriterion("barcode between", value1, value2, "barcode");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andBarcodeNotBetween(String value1, String value2) {
            this.addCriterion("barcode not between", value1, value2, "barcode");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andForSaleIsNull() {
            this.addCriterion("for_sale is null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andForSaleIsNotNull() {
            this.addCriterion("for_sale is not null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andForSaleEqualTo(Integer value) {
            this.addCriterion("for_sale =", value, "forSale");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andForSaleEqualToColumn(Column column) {
            this.addCriterion("for_sale = " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andForSaleNotEqualTo(Integer value) {
            this.addCriterion("for_sale <>", value, "forSale");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andForSaleNotEqualToColumn(Column column) {
            this.addCriterion("for_sale <> " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andForSaleGreaterThan(Integer value) {
            this.addCriterion("for_sale >", value, "forSale");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andForSaleGreaterThanColumn(Column column) {
            this.addCriterion("for_sale > " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andForSaleGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("for_sale >=", value, "forSale");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andForSaleGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("for_sale >= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andForSaleLessThan(Integer value) {
            this.addCriterion("for_sale <", value, "forSale");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andForSaleLessThanColumn(Column column) {
            this.addCriterion("for_sale < " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andForSaleLessThanOrEqualTo(Integer value) {
            this.addCriterion("for_sale <=", value, "forSale");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andForSaleLessThanOrEqualToColumn(Column column) {
            this.addCriterion("for_sale <= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andForSaleIn(List<Integer> values) {
            this.addCriterion("for_sale in", values, "forSale");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andForSaleNotIn(List<Integer> values) {
            this.addCriterion("for_sale not in", values, "forSale");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andForSaleBetween(Integer value1, Integer value2) {
            this.addCriterion("for_sale between", value1, value2, "forSale");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andForSaleNotBetween(Integer value1, Integer value2) {
            this.addCriterion("for_sale not between", value1, value2, "forSale");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andShowPosIsNull() {
            this.addCriterion("show_pos is null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andShowPosIsNotNull() {
            this.addCriterion("show_pos is not null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andShowPosEqualTo(Integer value) {
            this.addCriterion("show_pos =", value, "showPos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andShowPosEqualToColumn(Column column) {
            this.addCriterion("show_pos = " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andShowPosNotEqualTo(Integer value) {
            this.addCriterion("show_pos <>", value, "showPos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andShowPosNotEqualToColumn(Column column) {
            this.addCriterion("show_pos <> " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andShowPosGreaterThan(Integer value) {
            this.addCriterion("show_pos >", value, "showPos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andShowPosGreaterThanColumn(Column column) {
            this.addCriterion("show_pos > " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andShowPosGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("show_pos >=", value, "showPos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andShowPosGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("show_pos >= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andShowPosLessThan(Integer value) {
            this.addCriterion("show_pos <", value, "showPos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andShowPosLessThanColumn(Column column) {
            this.addCriterion("show_pos < " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andShowPosLessThanOrEqualTo(Integer value) {
            this.addCriterion("show_pos <=", value, "showPos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andShowPosLessThanOrEqualToColumn(Column column) {
            this.addCriterion("show_pos <= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andShowPosIn(List<Integer> values) {
            this.addCriterion("show_pos in", values, "showPos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andShowPosNotIn(List<Integer> values) {
            this.addCriterion("show_pos not in", values, "showPos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andShowPosBetween(Integer value1, Integer value2) {
            this.addCriterion("show_pos between", value1, value2, "showPos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andShowPosNotBetween(Integer value1, Integer value2) {
            this.addCriterion("show_pos not between", value1, value2, "showPos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRposIsNull() {
            this.addCriterion("rpos is null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRposIsNotNull() {
            this.addCriterion("rpos is not null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRposEqualTo(Integer value) {
            this.addCriterion("rpos =", value, "rpos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRposEqualToColumn(Column column) {
            this.addCriterion("rpos = " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRposNotEqualTo(Integer value) {
            this.addCriterion("rpos <>", value, "rpos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRposNotEqualToColumn(Column column) {
            this.addCriterion("rpos <> " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRposGreaterThan(Integer value) {
            this.addCriterion("rpos >", value, "rpos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRposGreaterThanColumn(Column column) {
            this.addCriterion("rpos > " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRposGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("rpos >=", value, "rpos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRposGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("rpos >= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRposLessThan(Integer value) {
            this.addCriterion("rpos <", value, "rpos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRposLessThanColumn(Column column) {
            this.addCriterion("rpos < " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRposLessThanOrEqualTo(Integer value) {
            this.addCriterion("rpos <=", value, "rpos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRposLessThanOrEqualToColumn(Column column) {
            this.addCriterion("rpos <= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRposIn(List<Integer> values) {
            this.addCriterion("rpos in", values, "rpos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRposNotIn(List<Integer> values) {
            this.addCriterion("rpos not in", values, "rpos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRposBetween(Integer value1, Integer value2) {
            this.addCriterion("rpos between", value1, value2, "rpos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRposNotBetween(Integer value1, Integer value2) {
            this.addCriterion("rpos not between", value1, value2, "rpos");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andSaleQuotaIsNull() {
            this.addCriterion("sale_quota is null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andSaleQuotaIsNotNull() {
            this.addCriterion("sale_quota is not null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andSaleQuotaEqualTo(Integer value) {
            this.addCriterion("sale_quota =", value, "saleQuota");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andSaleQuotaEqualToColumn(Column column) {
            this.addCriterion("sale_quota = " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andSaleQuotaNotEqualTo(Integer value) {
            this.addCriterion("sale_quota <>", value, "saleQuota");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andSaleQuotaNotEqualToColumn(Column column) {
            this.addCriterion("sale_quota <> " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andSaleQuotaGreaterThan(Integer value) {
            this.addCriterion("sale_quota >", value, "saleQuota");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andSaleQuotaGreaterThanColumn(Column column) {
            this.addCriterion("sale_quota > " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andSaleQuotaGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("sale_quota >=", value, "saleQuota");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andSaleQuotaGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("sale_quota >= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andSaleQuotaLessThan(Integer value) {
            this.addCriterion("sale_quota <", value, "saleQuota");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andSaleQuotaLessThanColumn(Column column) {
            this.addCriterion("sale_quota < " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andSaleQuotaLessThanOrEqualTo(Integer value) {
            this.addCriterion("sale_quota <=", value, "saleQuota");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andSaleQuotaLessThanOrEqualToColumn(Column column) {
            this.addCriterion("sale_quota <= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andSaleQuotaIn(List<Integer> values) {
            this.addCriterion("sale_quota in", values, "saleQuota");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andSaleQuotaNotIn(List<Integer> values) {
            this.addCriterion("sale_quota not in", values, "saleQuota");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andSaleQuotaBetween(Integer value1, Integer value2) {
            this.addCriterion("sale_quota between", value1, value2, "saleQuota");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andSaleQuotaNotBetween(Integer value1, Integer value2) {
            this.addCriterion("sale_quota not between", value1, value2, "saleQuota");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRecommendIsNull() {
            this.addCriterion("recommend is null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRecommendIsNotNull() {
            this.addCriterion("recommend is not null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRecommendEqualTo(Integer value) {
            this.addCriterion("recommend =", value, "recommend");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRecommendEqualToColumn(Column column) {
            this.addCriterion("recommend = " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRecommendNotEqualTo(Integer value) {
            this.addCriterion("recommend <>", value, "recommend");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRecommendNotEqualToColumn(Column column) {
            this.addCriterion("recommend <> " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRecommendGreaterThan(Integer value) {
            this.addCriterion("recommend >", value, "recommend");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRecommendGreaterThanColumn(Column column) {
            this.addCriterion("recommend > " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRecommendGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("recommend >=", value, "recommend");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRecommendGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("recommend >= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRecommendLessThan(Integer value) {
            this.addCriterion("recommend <", value, "recommend");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRecommendLessThanColumn(Column column) {
            this.addCriterion("recommend < " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRecommendLessThanOrEqualTo(Integer value) {
            this.addCriterion("recommend <=", value, "recommend");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRecommendLessThanOrEqualToColumn(Column column) {
            this.addCriterion("recommend <= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRecommendIn(List<Integer> values) {
            this.addCriterion("recommend in", values, "recommend");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRecommendNotIn(List<Integer> values) {
            this.addCriterion("recommend not in", values, "recommend");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRecommendBetween(Integer value1, Integer value2) {
            this.addCriterion("recommend between", value1, value2, "recommend");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andRecommendNotBetween(Integer value1, Integer value2) {
            this.addCriterion("recommend not between", value1, value2, "recommend");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andCoinIsNull() {
            this.addCriterion("coin is null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andCoinIsNotNull() {
            this.addCriterion("coin is not null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andCoinEqualTo(Integer value) {
            this.addCriterion("coin =", value, "coin");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andCoinEqualToColumn(Column column) {
            this.addCriterion("coin = " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andCoinNotEqualTo(Integer value) {
            this.addCriterion("coin <>", value, "coin");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andCoinNotEqualToColumn(Column column) {
            this.addCriterion("coin <> " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andCoinGreaterThan(Integer value) {
            this.addCriterion("coin >", value, "coin");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andCoinGreaterThanColumn(Column column) {
            this.addCriterion("coin > " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andCoinGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("coin >=", value, "coin");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andCoinGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("coin >= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andCoinLessThan(Integer value) {
            this.addCriterion("coin <", value, "coin");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andCoinLessThanColumn(Column column) {
            this.addCriterion("coin < " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andCoinLessThanOrEqualTo(Integer value) {
            this.addCriterion("coin <=", value, "coin");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andCoinLessThanOrEqualToColumn(Column column) {
            this.addCriterion("coin <= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andCoinIn(List<Integer> values) {
            this.addCriterion("coin in", values, "coin");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andCoinNotIn(List<Integer> values) {
            this.addCriterion("coin not in", values, "coin");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andCoinBetween(Integer value1, Integer value2) {
            this.addCriterion("coin between", value1, value2, "coin");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andCoinNotBetween(Integer value1, Integer value2) {
            this.addCriterion("coin not between", value1, value2, "coin");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDiscountIsNull() {
            this.addCriterion("discount is null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDiscountIsNotNull() {
            this.addCriterion("discount is not null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDiscountEqualTo(Integer value) {
            this.addCriterion("discount =", value, "discount");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDiscountEqualToColumn(Column column) {
            this.addCriterion("discount = " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDiscountNotEqualTo(Integer value) {
            this.addCriterion("discount <>", value, "discount");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDiscountNotEqualToColumn(Column column) {
            this.addCriterion("discount <> " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDiscountGreaterThan(Integer value) {
            this.addCriterion("discount >", value, "discount");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDiscountGreaterThanColumn(Column column) {
            this.addCriterion("discount > " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDiscountGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("discount >=", value, "discount");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDiscountGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("discount >= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDiscountLessThan(Integer value) {
            this.addCriterion("discount <", value, "discount");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDiscountLessThanColumn(Column column) {
            this.addCriterion("discount < " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDiscountLessThanOrEqualTo(Integer value) {
            this.addCriterion("discount <=", value, "discount");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDiscountLessThanOrEqualToColumn(Column column) {
            this.addCriterion("discount <= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDiscountIn(List<Integer> values) {
            this.addCriterion("discount in", values, "discount");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDiscountNotIn(List<Integer> values) {
            this.addCriterion("discount not in", values, "discount");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDiscountBetween(Integer value1, Integer value2) {
            this.addCriterion("discount between", value1, value2, "discount");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDiscountNotBetween(Integer value1, Integer value2) {
            this.addCriterion("discount not between", value1, value2, "discount");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andTypeIsNull() {
            this.addCriterion("`type` is null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andTypeIsNotNull() {
            this.addCriterion("`type` is not null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andTypeEqualTo(Integer value) {
            this.addCriterion("`type` =", value, "type");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andTypeEqualToColumn(Column column) {
            this.addCriterion("`type` = " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andTypeNotEqualTo(Integer value) {
            this.addCriterion("`type` <>", value, "type");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andTypeNotEqualToColumn(Column column) {
            this.addCriterion("`type` <> " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andTypeGreaterThan(Integer value) {
            this.addCriterion("`type` >", value, "type");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andTypeGreaterThanColumn(Column column) {
            this.addCriterion("`type` > " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andTypeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`type` >=", value, "type");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andTypeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` >= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andTypeLessThan(Integer value) {
            this.addCriterion("`type` <", value, "type");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andTypeLessThanColumn(Column column) {
            this.addCriterion("`type` < " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andTypeLessThanOrEqualTo(Integer value) {
            this.addCriterion("`type` <=", value, "type");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andTypeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` <= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andTypeIn(List<Integer> values) {
            this.addCriterion("`type` in", values, "type");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andTypeNotIn(List<Integer> values) {
            this.addCriterion("`type` not in", values, "type");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andTypeBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` between", value1, value2, "type");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andTypeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` not between", value1, value2, "type");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andQuotaLimitIsNull() {
            this.addCriterion("quota_limit is null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andQuotaLimitIsNotNull() {
            this.addCriterion("quota_limit is not null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andQuotaLimitEqualTo(Integer value) {
            this.addCriterion("quota_limit =", value, "quotaLimit");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andQuotaLimitEqualToColumn(Column column) {
            this.addCriterion("quota_limit = " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andQuotaLimitNotEqualTo(Integer value) {
            this.addCriterion("quota_limit <>", value, "quotaLimit");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andQuotaLimitNotEqualToColumn(Column column) {
            this.addCriterion("quota_limit <> " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andQuotaLimitGreaterThan(Integer value) {
            this.addCriterion("quota_limit >", value, "quotaLimit");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andQuotaLimitGreaterThanColumn(Column column) {
            this.addCriterion("quota_limit > " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andQuotaLimitGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("quota_limit >=", value, "quotaLimit");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andQuotaLimitGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("quota_limit >= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andQuotaLimitLessThan(Integer value) {
            this.addCriterion("quota_limit <", value, "quotaLimit");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andQuotaLimitLessThanColumn(Column column) {
            this.addCriterion("quota_limit < " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andQuotaLimitLessThanOrEqualTo(Integer value) {
            this.addCriterion("quota_limit <=", value, "quotaLimit");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andQuotaLimitLessThanOrEqualToColumn(Column column) {
            this.addCriterion("quota_limit <= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andQuotaLimitIn(List<Integer> values) {
            this.addCriterion("quota_limit in", values, "quotaLimit");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andQuotaLimitNotIn(List<Integer> values) {
            this.addCriterion("quota_limit not in", values, "quotaLimit");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andQuotaLimitBetween(Integer value1, Integer value2) {
            this.addCriterion("quota_limit between", value1, value2, "quotaLimit");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andQuotaLimitNotBetween(Integer value1, Integer value2) {
            this.addCriterion("quota_limit not between", value1, value2, "quotaLimit");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andMustVipIsNull() {
            this.addCriterion("must_vip is null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andMustVipIsNotNull() {
            this.addCriterion("must_vip is not null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andMustVipEqualTo(Integer value) {
            this.addCriterion("must_vip =", value, "mustVip");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andMustVipEqualToColumn(Column column) {
            this.addCriterion("must_vip = " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andMustVipNotEqualTo(Integer value) {
            this.addCriterion("must_vip <>", value, "mustVip");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andMustVipNotEqualToColumn(Column column) {
            this.addCriterion("must_vip <> " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andMustVipGreaterThan(Integer value) {
            this.addCriterion("must_vip >", value, "mustVip");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andMustVipGreaterThanColumn(Column column) {
            this.addCriterion("must_vip > " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andMustVipGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("must_vip >=", value, "mustVip");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andMustVipGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("must_vip >= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andMustVipLessThan(Integer value) {
            this.addCriterion("must_vip <", value, "mustVip");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andMustVipLessThanColumn(Column column) {
            this.addCriterion("must_vip < " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andMustVipLessThanOrEqualTo(Integer value) {
            this.addCriterion("must_vip <=", value, "mustVip");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andMustVipLessThanOrEqualToColumn(Column column) {
            this.addCriterion("must_vip <= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andMustVipIn(List<Integer> values) {
            this.addCriterion("must_vip in", values, "mustVip");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andMustVipNotIn(List<Integer> values) {
            this.addCriterion("must_vip not in", values, "mustVip");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andMustVipBetween(Integer value1, Integer value2) {
            this.addCriterion("must_vip between", value1, value2, "mustVip");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andMustVipNotBetween(Integer value1, Integer value2) {
            this.addCriterion("must_vip not between", value1, value2, "mustVip");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIsGiftIsNull() {
            this.addCriterion("is_gift is null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIsGiftIsNotNull() {
            this.addCriterion("is_gift is not null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIsGiftEqualTo(Integer value) {
            this.addCriterion("is_gift =", value, "isGift");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIsGiftEqualToColumn(Column column) {
            this.addCriterion("is_gift = " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIsGiftNotEqualTo(Integer value) {
            this.addCriterion("is_gift <>", value, "isGift");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIsGiftNotEqualToColumn(Column column) {
            this.addCriterion("is_gift <> " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIsGiftGreaterThan(Integer value) {
            this.addCriterion("is_gift >", value, "isGift");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIsGiftGreaterThanColumn(Column column) {
            this.addCriterion("is_gift > " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIsGiftGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("is_gift >=", value, "isGift");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIsGiftGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("is_gift >= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIsGiftLessThan(Integer value) {
            this.addCriterion("is_gift <", value, "isGift");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIsGiftLessThanColumn(Column column) {
            this.addCriterion("is_gift < " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIsGiftLessThanOrEqualTo(Integer value) {
            this.addCriterion("is_gift <=", value, "isGift");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIsGiftLessThanOrEqualToColumn(Column column) {
            this.addCriterion("is_gift <= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIsGiftIn(List<Integer> values) {
            this.addCriterion("is_gift in", values, "isGift");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIsGiftNotIn(List<Integer> values) {
            this.addCriterion("is_gift not in", values, "isGift");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIsGiftBetween(Integer value1, Integer value2) {
            this.addCriterion("is_gift between", value1, value2, "isGift");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andIsGiftNotBetween(Integer value1, Integer value2) {
            this.addCriterion("is_gift not between", value1, value2, "isGift");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andFollowPetTypeIsNull() {
            this.addCriterion("follow_pet_type is null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andFollowPetTypeIsNotNull() {
            this.addCriterion("follow_pet_type is not null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andFollowPetTypeEqualTo(Integer value) {
            this.addCriterion("follow_pet_type =", value, "followPetType");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andFollowPetTypeEqualToColumn(Column column) {
            this.addCriterion("follow_pet_type = " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andFollowPetTypeNotEqualTo(Integer value) {
            this.addCriterion("follow_pet_type <>", value, "followPetType");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andFollowPetTypeNotEqualToColumn(Column column) {
            this.addCriterion("follow_pet_type <> " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andFollowPetTypeGreaterThan(Integer value) {
            this.addCriterion("follow_pet_type >", value, "followPetType");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andFollowPetTypeGreaterThanColumn(Column column) {
            this.addCriterion("follow_pet_type > " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andFollowPetTypeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("follow_pet_type >=", value, "followPetType");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andFollowPetTypeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("follow_pet_type >= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andFollowPetTypeLessThan(Integer value) {
            this.addCriterion("follow_pet_type <", value, "followPetType");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andFollowPetTypeLessThanColumn(Column column) {
            this.addCriterion("follow_pet_type < " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andFollowPetTypeLessThanOrEqualTo(Integer value) {
            this.addCriterion("follow_pet_type <=", value, "followPetType");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andFollowPetTypeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("follow_pet_type <= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andFollowPetTypeIn(List<Integer> values) {
            this.addCriterion("follow_pet_type in", values, "followPetType");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andFollowPetTypeNotIn(List<Integer> values) {
            this.addCriterion("follow_pet_type not in", values, "followPetType");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andFollowPetTypeBetween(Integer value1, Integer value2) {
            this.addCriterion("follow_pet_type between", value1, value2, "followPetType");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andFollowPetTypeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("follow_pet_type not between", value1, value2, "followPetType");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (StoreGoodsExample.Criteria)this;
        }

        public StoreGoodsExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (StoreGoodsExample.Criteria)this;
        }
    }
}
