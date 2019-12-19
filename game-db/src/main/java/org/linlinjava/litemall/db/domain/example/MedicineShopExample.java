//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.MedicineShop.Column;
import org.linlinjava.litemall.db.domain.MedicineShop.Deleted;

public class MedicineShopExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<MedicineShopExample.Criteria> oredCriteria = new ArrayList();

    public MedicineShopExample() {
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

    public List<MedicineShopExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(MedicineShopExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public MedicineShopExample.Criteria or() {
        MedicineShopExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public MedicineShopExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public MedicineShopExample orderBy(String... orderByClauses) {
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

    public MedicineShopExample.Criteria createCriteria() {
        MedicineShopExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected MedicineShopExample.Criteria createCriteriaInternal() {
        MedicineShopExample.Criteria criteria = new MedicineShopExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static MedicineShopExample.Criteria newAndCreateCriteria() {
        MedicineShopExample example = new MedicineShopExample();
        return example.createCriteria();
    }

    public MedicineShopExample when(boolean condition, MedicineShopExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public MedicineShopExample when(boolean condition, MedicineShopExample.IExampleWhen then, MedicineShopExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(MedicineShopExample example);
    }

    public interface ICriteriaWhen {
        void criteria(MedicineShopExample.Criteria criteria);
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

    public static class Criteria extends MedicineShopExample.GeneratedCriteria {
        private MedicineShopExample example;

        protected Criteria(MedicineShopExample example) {
            this.example = example;
        }

        public MedicineShopExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public MedicineShopExample.Criteria andIf(boolean ifAdd, MedicineShopExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public MedicineShopExample.Criteria when(boolean condition, MedicineShopExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public MedicineShopExample.Criteria when(boolean condition, MedicineShopExample.ICriteriaWhen then, MedicineShopExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public MedicineShopExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            MedicineShopExample.Criteria add(MedicineShopExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<MedicineShopExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<MedicineShopExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<MedicineShopExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new MedicineShopExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new MedicineShopExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new MedicineShopExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public MedicineShopExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andGoodsNoIsNull() {
            this.addCriterion("goods_no is null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andGoodsNoIsNotNull() {
            this.addCriterion("goods_no is not null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andGoodsNoEqualTo(Integer value) {
            this.addCriterion("goods_no =", value, "goodsNo");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andGoodsNoEqualToColumn(Column column) {
            this.addCriterion("goods_no = " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andGoodsNoNotEqualTo(Integer value) {
            this.addCriterion("goods_no <>", value, "goodsNo");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andGoodsNoNotEqualToColumn(Column column) {
            this.addCriterion("goods_no <> " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andGoodsNoGreaterThan(Integer value) {
            this.addCriterion("goods_no >", value, "goodsNo");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andGoodsNoGreaterThanColumn(Column column) {
            this.addCriterion("goods_no > " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andGoodsNoGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("goods_no >=", value, "goodsNo");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andGoodsNoGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("goods_no >= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andGoodsNoLessThan(Integer value) {
            this.addCriterion("goods_no <", value, "goodsNo");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andGoodsNoLessThanColumn(Column column) {
            this.addCriterion("goods_no < " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andGoodsNoLessThanOrEqualTo(Integer value) {
            this.addCriterion("goods_no <=", value, "goodsNo");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andGoodsNoLessThanOrEqualToColumn(Column column) {
            this.addCriterion("goods_no <= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andGoodsNoIn(List<Integer> values) {
            this.addCriterion("goods_no in", values, "goodsNo");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andGoodsNoNotIn(List<Integer> values) {
            this.addCriterion("goods_no not in", values, "goodsNo");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andGoodsNoBetween(Integer value1, Integer value2) {
            this.addCriterion("goods_no between", value1, value2, "goodsNo");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andGoodsNoNotBetween(Integer value1, Integer value2) {
            this.addCriterion("goods_no not between", value1, value2, "goodsNo");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andPayTypeIsNull() {
            this.addCriterion("pay_type is null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andPayTypeIsNotNull() {
            this.addCriterion("pay_type is not null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andPayTypeEqualTo(Integer value) {
            this.addCriterion("pay_type =", value, "payType");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andPayTypeEqualToColumn(Column column) {
            this.addCriterion("pay_type = " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andPayTypeNotEqualTo(Integer value) {
            this.addCriterion("pay_type <>", value, "payType");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andPayTypeNotEqualToColumn(Column column) {
            this.addCriterion("pay_type <> " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andPayTypeGreaterThan(Integer value) {
            this.addCriterion("pay_type >", value, "payType");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andPayTypeGreaterThanColumn(Column column) {
            this.addCriterion("pay_type > " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andPayTypeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("pay_type >=", value, "payType");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andPayTypeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("pay_type >= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andPayTypeLessThan(Integer value) {
            this.addCriterion("pay_type <", value, "payType");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andPayTypeLessThanColumn(Column column) {
            this.addCriterion("pay_type < " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andPayTypeLessThanOrEqualTo(Integer value) {
            this.addCriterion("pay_type <=", value, "payType");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andPayTypeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("pay_type <= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andPayTypeIn(List<Integer> values) {
            this.addCriterion("pay_type in", values, "payType");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andPayTypeNotIn(List<Integer> values) {
            this.addCriterion("pay_type not in", values, "payType");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andPayTypeBetween(Integer value1, Integer value2) {
            this.addCriterion("pay_type between", value1, value2, "payType");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andPayTypeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("pay_type not between", value1, value2, "payType");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andValueIsNull() {
            this.addCriterion("`value` is null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andValueIsNotNull() {
            this.addCriterion("`value` is not null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andValueEqualTo(Integer value) {
            this.addCriterion("`value` =", value, "value");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andValueEqualToColumn(Column column) {
            this.addCriterion("`value` = " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andValueNotEqualTo(Integer value) {
            this.addCriterion("`value` <>", value, "value");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andValueNotEqualToColumn(Column column) {
            this.addCriterion("`value` <> " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andValueGreaterThan(Integer value) {
            this.addCriterion("`value` >", value, "value");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andValueGreaterThanColumn(Column column) {
            this.addCriterion("`value` > " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andValueGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`value` >=", value, "value");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andValueGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`value` >= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andValueLessThan(Integer value) {
            this.addCriterion("`value` <", value, "value");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andValueLessThanColumn(Column column) {
            this.addCriterion("`value` < " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andValueLessThanOrEqualTo(Integer value) {
            this.addCriterion("`value` <=", value, "value");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andValueLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`value` <= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andValueIn(List<Integer> values) {
            this.addCriterion("`value` in", values, "value");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andValueNotIn(List<Integer> values) {
            this.addCriterion("`value` not in", values, "value");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andValueBetween(Integer value1, Integer value2) {
            this.addCriterion("`value` between", value1, value2, "value");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andValueNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`value` not between", value1, value2, "value");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andLevelIsNull() {
            this.addCriterion("`level` is null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andLevelIsNotNull() {
            this.addCriterion("`level` is not null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andLevelEqualTo(Integer value) {
            this.addCriterion("`level` =", value, "level");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andLevelEqualToColumn(Column column) {
            this.addCriterion("`level` = " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andLevelNotEqualTo(Integer value) {
            this.addCriterion("`level` <>", value, "level");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andLevelNotEqualToColumn(Column column) {
            this.addCriterion("`level` <> " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andLevelGreaterThan(Integer value) {
            this.addCriterion("`level` >", value, "level");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andLevelGreaterThanColumn(Column column) {
            this.addCriterion("`level` > " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andLevelGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`level` >=", value, "level");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andLevelGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`level` >= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andLevelLessThan(Integer value) {
            this.addCriterion("`level` <", value, "level");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andLevelLessThanColumn(Column column) {
            this.addCriterion("`level` < " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andLevelLessThanOrEqualTo(Integer value) {
            this.addCriterion("`level` <=", value, "level");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andLevelLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`level` <= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andLevelIn(List<Integer> values) {
            this.addCriterion("`level` in", values, "level");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andLevelNotIn(List<Integer> values) {
            this.addCriterion("`level` not in", values, "level");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andLevelBetween(Integer value1, Integer value2) {
            this.addCriterion("`level` between", value1, value2, "level");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andLevelNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`level` not between", value1, value2, "level");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andTypeIsNull() {
            this.addCriterion("`type` is null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andTypeIsNotNull() {
            this.addCriterion("`type` is not null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andTypeEqualTo(Integer value) {
            this.addCriterion("`type` =", value, "type");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andTypeEqualToColumn(Column column) {
            this.addCriterion("`type` = " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andTypeNotEqualTo(Integer value) {
            this.addCriterion("`type` <>", value, "type");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andTypeNotEqualToColumn(Column column) {
            this.addCriterion("`type` <> " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andTypeGreaterThan(Integer value) {
            this.addCriterion("`type` >", value, "type");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andTypeGreaterThanColumn(Column column) {
            this.addCriterion("`type` > " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andTypeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`type` >=", value, "type");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andTypeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` >= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andTypeLessThan(Integer value) {
            this.addCriterion("`type` <", value, "type");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andTypeLessThanColumn(Column column) {
            this.addCriterion("`type` < " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andTypeLessThanOrEqualTo(Integer value) {
            this.addCriterion("`type` <=", value, "type");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andTypeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` <= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andTypeIn(List<Integer> values) {
            this.addCriterion("`type` in", values, "type");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andTypeNotIn(List<Integer> values) {
            this.addCriterion("`type` not in", values, "type");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andTypeBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` between", value1, value2, "type");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andTypeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` not between", value1, value2, "type");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andItemcountIsNull() {
            this.addCriterion("itemCount is null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andItemcountIsNotNull() {
            this.addCriterion("itemCount is not null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andItemcountEqualTo(Integer value) {
            this.addCriterion("itemCount =", value, "itemcount");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andItemcountEqualToColumn(Column column) {
            this.addCriterion("itemCount = " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andItemcountNotEqualTo(Integer value) {
            this.addCriterion("itemCount <>", value, "itemcount");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andItemcountNotEqualToColumn(Column column) {
            this.addCriterion("itemCount <> " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andItemcountGreaterThan(Integer value) {
            this.addCriterion("itemCount >", value, "itemcount");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andItemcountGreaterThanColumn(Column column) {
            this.addCriterion("itemCount > " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andItemcountGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("itemCount >=", value, "itemcount");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andItemcountGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("itemCount >= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andItemcountLessThan(Integer value) {
            this.addCriterion("itemCount <", value, "itemcount");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andItemcountLessThanColumn(Column column) {
            this.addCriterion("itemCount < " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andItemcountLessThanOrEqualTo(Integer value) {
            this.addCriterion("itemCount <=", value, "itemcount");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andItemcountLessThanOrEqualToColumn(Column column) {
            this.addCriterion("itemCount <= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andItemcountIn(List<Integer> values) {
            this.addCriterion("itemCount in", values, "itemcount");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andItemcountNotIn(List<Integer> values) {
            this.addCriterion("itemCount not in", values, "itemcount");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andItemcountBetween(Integer value1, Integer value2) {
            this.addCriterion("itemCount between", value1, value2, "itemcount");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andItemcountNotBetween(Integer value1, Integer value2) {
            this.addCriterion("itemCount not between", value1, value2, "itemcount");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (MedicineShopExample.Criteria)this;
        }

        public MedicineShopExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (MedicineShopExample.Criteria)this;
        }
    }
}
