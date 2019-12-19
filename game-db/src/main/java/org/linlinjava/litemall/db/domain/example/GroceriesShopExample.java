//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.GroceriesShop.Column;
import org.linlinjava.litemall.db.domain.GroceriesShop.Deleted;

public class GroceriesShopExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<GroceriesShopExample.Criteria> oredCriteria = new ArrayList();

    public GroceriesShopExample() {
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

    public List<GroceriesShopExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(GroceriesShopExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public GroceriesShopExample.Criteria or() {
        GroceriesShopExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public GroceriesShopExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public GroceriesShopExample orderBy(String... orderByClauses) {
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

    public GroceriesShopExample.Criteria createCriteria() {
        GroceriesShopExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected GroceriesShopExample.Criteria createCriteriaInternal() {
        GroceriesShopExample.Criteria criteria = new GroceriesShopExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static GroceriesShopExample.Criteria newAndCreateCriteria() {
        GroceriesShopExample example = new GroceriesShopExample();
        return example.createCriteria();
    }

    public GroceriesShopExample when(boolean condition, GroceriesShopExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public GroceriesShopExample when(boolean condition, GroceriesShopExample.IExampleWhen then, GroceriesShopExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(GroceriesShopExample example);
    }

    public interface ICriteriaWhen {
        void criteria(GroceriesShopExample.Criteria criteria);
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

    public static class Criteria extends GroceriesShopExample.GeneratedCriteria {
        private GroceriesShopExample example;

        protected Criteria(GroceriesShopExample example) {
            this.example = example;
        }

        public GroceriesShopExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public GroceriesShopExample.Criteria andIf(boolean ifAdd, GroceriesShopExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public GroceriesShopExample.Criteria when(boolean condition, GroceriesShopExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public GroceriesShopExample.Criteria when(boolean condition, GroceriesShopExample.ICriteriaWhen then, GroceriesShopExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public GroceriesShopExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            GroceriesShopExample.Criteria add(GroceriesShopExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<GroceriesShopExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<GroceriesShopExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<GroceriesShopExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new GroceriesShopExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new GroceriesShopExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new GroceriesShopExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public GroceriesShopExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andGoodsNoIsNull() {
            this.addCriterion("goods_no is null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andGoodsNoIsNotNull() {
            this.addCriterion("goods_no is not null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andGoodsNoEqualTo(Integer value) {
            this.addCriterion("goods_no =", value, "goodsNo");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andGoodsNoEqualToColumn(Column column) {
            this.addCriterion("goods_no = " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andGoodsNoNotEqualTo(Integer value) {
            this.addCriterion("goods_no <>", value, "goodsNo");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andGoodsNoNotEqualToColumn(Column column) {
            this.addCriterion("goods_no <> " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andGoodsNoGreaterThan(Integer value) {
            this.addCriterion("goods_no >", value, "goodsNo");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andGoodsNoGreaterThanColumn(Column column) {
            this.addCriterion("goods_no > " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andGoodsNoGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("goods_no >=", value, "goodsNo");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andGoodsNoGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("goods_no >= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andGoodsNoLessThan(Integer value) {
            this.addCriterion("goods_no <", value, "goodsNo");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andGoodsNoLessThanColumn(Column column) {
            this.addCriterion("goods_no < " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andGoodsNoLessThanOrEqualTo(Integer value) {
            this.addCriterion("goods_no <=", value, "goodsNo");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andGoodsNoLessThanOrEqualToColumn(Column column) {
            this.addCriterion("goods_no <= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andGoodsNoIn(List<Integer> values) {
            this.addCriterion("goods_no in", values, "goodsNo");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andGoodsNoNotIn(List<Integer> values) {
            this.addCriterion("goods_no not in", values, "goodsNo");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andGoodsNoBetween(Integer value1, Integer value2) {
            this.addCriterion("goods_no between", value1, value2, "goodsNo");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andGoodsNoNotBetween(Integer value1, Integer value2) {
            this.addCriterion("goods_no not between", value1, value2, "goodsNo");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andPayTypeIsNull() {
            this.addCriterion("pay_type is null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andPayTypeIsNotNull() {
            this.addCriterion("pay_type is not null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andPayTypeEqualTo(Integer value) {
            this.addCriterion("pay_type =", value, "payType");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andPayTypeEqualToColumn(Column column) {
            this.addCriterion("pay_type = " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andPayTypeNotEqualTo(Integer value) {
            this.addCriterion("pay_type <>", value, "payType");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andPayTypeNotEqualToColumn(Column column) {
            this.addCriterion("pay_type <> " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andPayTypeGreaterThan(Integer value) {
            this.addCriterion("pay_type >", value, "payType");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andPayTypeGreaterThanColumn(Column column) {
            this.addCriterion("pay_type > " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andPayTypeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("pay_type >=", value, "payType");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andPayTypeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("pay_type >= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andPayTypeLessThan(Integer value) {
            this.addCriterion("pay_type <", value, "payType");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andPayTypeLessThanColumn(Column column) {
            this.addCriterion("pay_type < " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andPayTypeLessThanOrEqualTo(Integer value) {
            this.addCriterion("pay_type <=", value, "payType");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andPayTypeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("pay_type <= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andPayTypeIn(List<Integer> values) {
            this.addCriterion("pay_type in", values, "payType");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andPayTypeNotIn(List<Integer> values) {
            this.addCriterion("pay_type not in", values, "payType");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andPayTypeBetween(Integer value1, Integer value2) {
            this.addCriterion("pay_type between", value1, value2, "payType");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andPayTypeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("pay_type not between", value1, value2, "payType");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andValueIsNull() {
            this.addCriterion("`value` is null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andValueIsNotNull() {
            this.addCriterion("`value` is not null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andValueEqualTo(Integer value) {
            this.addCriterion("`value` =", value, "value");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andValueEqualToColumn(Column column) {
            this.addCriterion("`value` = " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andValueNotEqualTo(Integer value) {
            this.addCriterion("`value` <>", value, "value");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andValueNotEqualToColumn(Column column) {
            this.addCriterion("`value` <> " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andValueGreaterThan(Integer value) {
            this.addCriterion("`value` >", value, "value");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andValueGreaterThanColumn(Column column) {
            this.addCriterion("`value` > " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andValueGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`value` >=", value, "value");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andValueGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`value` >= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andValueLessThan(Integer value) {
            this.addCriterion("`value` <", value, "value");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andValueLessThanColumn(Column column) {
            this.addCriterion("`value` < " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andValueLessThanOrEqualTo(Integer value) {
            this.addCriterion("`value` <=", value, "value");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andValueLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`value` <= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andValueIn(List<Integer> values) {
            this.addCriterion("`value` in", values, "value");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andValueNotIn(List<Integer> values) {
            this.addCriterion("`value` not in", values, "value");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andValueBetween(Integer value1, Integer value2) {
            this.addCriterion("`value` between", value1, value2, "value");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andValueNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`value` not between", value1, value2, "value");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andLevelIsNull() {
            this.addCriterion("`level` is null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andLevelIsNotNull() {
            this.addCriterion("`level` is not null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andLevelEqualTo(Integer value) {
            this.addCriterion("`level` =", value, "level");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andLevelEqualToColumn(Column column) {
            this.addCriterion("`level` = " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andLevelNotEqualTo(Integer value) {
            this.addCriterion("`level` <>", value, "level");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andLevelNotEqualToColumn(Column column) {
            this.addCriterion("`level` <> " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andLevelGreaterThan(Integer value) {
            this.addCriterion("`level` >", value, "level");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andLevelGreaterThanColumn(Column column) {
            this.addCriterion("`level` > " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andLevelGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`level` >=", value, "level");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andLevelGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`level` >= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andLevelLessThan(Integer value) {
            this.addCriterion("`level` <", value, "level");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andLevelLessThanColumn(Column column) {
            this.addCriterion("`level` < " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andLevelLessThanOrEqualTo(Integer value) {
            this.addCriterion("`level` <=", value, "level");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andLevelLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`level` <= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andLevelIn(List<Integer> values) {
            this.addCriterion("`level` in", values, "level");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andLevelNotIn(List<Integer> values) {
            this.addCriterion("`level` not in", values, "level");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andLevelBetween(Integer value1, Integer value2) {
            this.addCriterion("`level` between", value1, value2, "level");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andLevelNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`level` not between", value1, value2, "level");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andTypeIsNull() {
            this.addCriterion("`type` is null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andTypeIsNotNull() {
            this.addCriterion("`type` is not null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andTypeEqualTo(Integer value) {
            this.addCriterion("`type` =", value, "type");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andTypeEqualToColumn(Column column) {
            this.addCriterion("`type` = " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andTypeNotEqualTo(Integer value) {
            this.addCriterion("`type` <>", value, "type");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andTypeNotEqualToColumn(Column column) {
            this.addCriterion("`type` <> " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andTypeGreaterThan(Integer value) {
            this.addCriterion("`type` >", value, "type");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andTypeGreaterThanColumn(Column column) {
            this.addCriterion("`type` > " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andTypeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`type` >=", value, "type");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andTypeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` >= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andTypeLessThan(Integer value) {
            this.addCriterion("`type` <", value, "type");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andTypeLessThanColumn(Column column) {
            this.addCriterion("`type` < " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andTypeLessThanOrEqualTo(Integer value) {
            this.addCriterion("`type` <=", value, "type");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andTypeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` <= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andTypeIn(List<Integer> values) {
            this.addCriterion("`type` in", values, "type");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andTypeNotIn(List<Integer> values) {
            this.addCriterion("`type` not in", values, "type");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andTypeBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` between", value1, value2, "type");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andTypeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` not between", value1, value2, "type");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andItemcountIsNull() {
            this.addCriterion("itemCount is null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andItemcountIsNotNull() {
            this.addCriterion("itemCount is not null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andItemcountEqualTo(Integer value) {
            this.addCriterion("itemCount =", value, "itemcount");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andItemcountEqualToColumn(Column column) {
            this.addCriterion("itemCount = " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andItemcountNotEqualTo(Integer value) {
            this.addCriterion("itemCount <>", value, "itemcount");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andItemcountNotEqualToColumn(Column column) {
            this.addCriterion("itemCount <> " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andItemcountGreaterThan(Integer value) {
            this.addCriterion("itemCount >", value, "itemcount");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andItemcountGreaterThanColumn(Column column) {
            this.addCriterion("itemCount > " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andItemcountGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("itemCount >=", value, "itemcount");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andItemcountGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("itemCount >= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andItemcountLessThan(Integer value) {
            this.addCriterion("itemCount <", value, "itemcount");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andItemcountLessThanColumn(Column column) {
            this.addCriterion("itemCount < " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andItemcountLessThanOrEqualTo(Integer value) {
            this.addCriterion("itemCount <=", value, "itemcount");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andItemcountLessThanOrEqualToColumn(Column column) {
            this.addCriterion("itemCount <= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andItemcountIn(List<Integer> values) {
            this.addCriterion("itemCount in", values, "itemcount");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andItemcountNotIn(List<Integer> values) {
            this.addCriterion("itemCount not in", values, "itemcount");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andItemcountBetween(Integer value1, Integer value2) {
            this.addCriterion("itemCount between", value1, value2, "itemcount");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andItemcountNotBetween(Integer value1, Integer value2) {
            this.addCriterion("itemCount not between", value1, value2, "itemcount");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (GroceriesShopExample.Criteria)this;
        }

        public GroceriesShopExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (GroceriesShopExample.Criteria)this;
        }
    }
}
