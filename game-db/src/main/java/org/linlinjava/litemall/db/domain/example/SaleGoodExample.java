//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.SaleGood.Column;
import org.linlinjava.litemall.db.domain.SaleGood.Deleted;

public class SaleGoodExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<SaleGoodExample.Criteria> oredCriteria = new ArrayList();

    public SaleGoodExample() {
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

    public List<SaleGoodExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(SaleGoodExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public SaleGoodExample.Criteria or() {
        SaleGoodExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public SaleGoodExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public SaleGoodExample orderBy(String... orderByClauses) {
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

    public SaleGoodExample.Criteria createCriteria() {
        SaleGoodExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected SaleGoodExample.Criteria createCriteriaInternal() {
        SaleGoodExample.Criteria criteria = new SaleGoodExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static SaleGoodExample.Criteria newAndCreateCriteria() {
        SaleGoodExample example = new SaleGoodExample();
        return example.createCriteria();
    }

    public SaleGoodExample when(boolean condition, SaleGoodExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public SaleGoodExample when(boolean condition, SaleGoodExample.IExampleWhen then, SaleGoodExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(SaleGoodExample example);
    }

    public interface ICriteriaWhen {
        void criteria(SaleGoodExample.Criteria criteria);
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

    public static class Criteria extends SaleGoodExample.GeneratedCriteria {
        private SaleGoodExample example;

        protected Criteria(SaleGoodExample example) {
            this.example = example;
        }

        public SaleGoodExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public SaleGoodExample.Criteria andIf(boolean ifAdd, SaleGoodExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public SaleGoodExample.Criteria when(boolean condition, SaleGoodExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public SaleGoodExample.Criteria when(boolean condition, SaleGoodExample.ICriteriaWhen then, SaleGoodExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public SaleGoodExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            SaleGoodExample.Criteria add(SaleGoodExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<SaleGoodExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<SaleGoodExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<SaleGoodExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new SaleGoodExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new SaleGoodExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new SaleGoodExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public SaleGoodExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdIsNull() {
            this.addCriterion("goods_id is null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdIsNotNull() {
            this.addCriterion("goods_id is not null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdEqualTo(String value) {
            this.addCriterion("goods_id =", value, "goodsId");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdEqualToColumn(Column column) {
            this.addCriterion("goods_id = " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdNotEqualTo(String value) {
            this.addCriterion("goods_id <>", value, "goodsId");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdNotEqualToColumn(Column column) {
            this.addCriterion("goods_id <> " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdGreaterThan(String value) {
            this.addCriterion("goods_id >", value, "goodsId");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdGreaterThanColumn(Column column) {
            this.addCriterion("goods_id > " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdGreaterThanOrEqualTo(String value) {
            this.addCriterion("goods_id >=", value, "goodsId");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("goods_id >= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdLessThan(String value) {
            this.addCriterion("goods_id <", value, "goodsId");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdLessThanColumn(Column column) {
            this.addCriterion("goods_id < " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdLessThanOrEqualTo(String value) {
            this.addCriterion("goods_id <=", value, "goodsId");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("goods_id <= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdLike(String value) {
            this.addCriterion("goods_id like", value, "goodsId");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdNotLike(String value) {
            this.addCriterion("goods_id not like", value, "goodsId");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdIn(List<String> values) {
            this.addCriterion("goods_id in", values, "goodsId");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdNotIn(List<String> values) {
            this.addCriterion("goods_id not in", values, "goodsId");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdBetween(String value1, String value2) {
            this.addCriterion("goods_id between", value1, value2, "goodsId");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andGoodsIdNotBetween(String value1, String value2) {
            this.addCriterion("goods_id not between", value1, value2, "goodsId");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStartTimeIsNull() {
            this.addCriterion("start_time is null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStartTimeIsNotNull() {
            this.addCriterion("start_time is not null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStartTimeEqualTo(Integer value) {
            this.addCriterion("start_time =", value, "startTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStartTimeEqualToColumn(Column column) {
            this.addCriterion("start_time = " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStartTimeNotEqualTo(Integer value) {
            this.addCriterion("start_time <>", value, "startTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStartTimeNotEqualToColumn(Column column) {
            this.addCriterion("start_time <> " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStartTimeGreaterThan(Integer value) {
            this.addCriterion("start_time >", value, "startTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStartTimeGreaterThanColumn(Column column) {
            this.addCriterion("start_time > " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStartTimeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("start_time >=", value, "startTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStartTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("start_time >= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStartTimeLessThan(Integer value) {
            this.addCriterion("start_time <", value, "startTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStartTimeLessThanColumn(Column column) {
            this.addCriterion("start_time < " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStartTimeLessThanOrEqualTo(Integer value) {
            this.addCriterion("start_time <=", value, "startTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStartTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("start_time <= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStartTimeIn(List<Integer> values) {
            this.addCriterion("start_time in", values, "startTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStartTimeNotIn(List<Integer> values) {
            this.addCriterion("start_time not in", values, "startTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStartTimeBetween(Integer value1, Integer value2) {
            this.addCriterion("start_time between", value1, value2, "startTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStartTimeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("start_time not between", value1, value2, "startTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andEndTimeIsNull() {
            this.addCriterion("end_time is null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andEndTimeIsNotNull() {
            this.addCriterion("end_time is not null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andEndTimeEqualTo(Integer value) {
            this.addCriterion("end_time =", value, "endTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andEndTimeEqualToColumn(Column column) {
            this.addCriterion("end_time = " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andEndTimeNotEqualTo(Integer value) {
            this.addCriterion("end_time <>", value, "endTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andEndTimeNotEqualToColumn(Column column) {
            this.addCriterion("end_time <> " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andEndTimeGreaterThan(Integer value) {
            this.addCriterion("end_time >", value, "endTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andEndTimeGreaterThanColumn(Column column) {
            this.addCriterion("end_time > " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andEndTimeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("end_time >=", value, "endTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andEndTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("end_time >= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andEndTimeLessThan(Integer value) {
            this.addCriterion("end_time <", value, "endTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andEndTimeLessThanColumn(Column column) {
            this.addCriterion("end_time < " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andEndTimeLessThanOrEqualTo(Integer value) {
            this.addCriterion("end_time <=", value, "endTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andEndTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("end_time <= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andEndTimeIn(List<Integer> values) {
            this.addCriterion("end_time in", values, "endTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andEndTimeNotIn(List<Integer> values) {
            this.addCriterion("end_time not in", values, "endTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andEndTimeBetween(Integer value1, Integer value2) {
            this.addCriterion("end_time between", value1, value2, "endTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andEndTimeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("end_time not between", value1, value2, "endTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPriceIsNull() {
            this.addCriterion("price is null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPriceIsNotNull() {
            this.addCriterion("price is not null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPriceEqualTo(Integer value) {
            this.addCriterion("price =", value, "price");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPriceEqualToColumn(Column column) {
            this.addCriterion("price = " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPriceNotEqualTo(Integer value) {
            this.addCriterion("price <>", value, "price");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPriceNotEqualToColumn(Column column) {
            this.addCriterion("price <> " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPriceGreaterThan(Integer value) {
            this.addCriterion("price >", value, "price");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPriceGreaterThanColumn(Column column) {
            this.addCriterion("price > " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPriceGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("price >=", value, "price");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPriceGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("price >= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPriceLessThan(Integer value) {
            this.addCriterion("price <", value, "price");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPriceLessThanColumn(Column column) {
            this.addCriterion("price < " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPriceLessThanOrEqualTo(Integer value) {
            this.addCriterion("price <=", value, "price");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPriceLessThanOrEqualToColumn(Column column) {
            this.addCriterion("price <= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPriceIn(List<Integer> values) {
            this.addCriterion("price in", values, "price");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPriceNotIn(List<Integer> values) {
            this.addCriterion("price not in", values, "price");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPriceBetween(Integer value1, Integer value2) {
            this.addCriterion("price between", value1, value2, "price");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPriceNotBetween(Integer value1, Integer value2) {
            this.addCriterion("price not between", value1, value2, "price");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andReqLevelIsNull() {
            this.addCriterion("req_level is null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andReqLevelIsNotNull() {
            this.addCriterion("req_level is not null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andReqLevelEqualTo(Integer value) {
            this.addCriterion("req_level =", value, "reqLevel");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andReqLevelEqualToColumn(Column column) {
            this.addCriterion("req_level = " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andReqLevelNotEqualTo(Integer value) {
            this.addCriterion("req_level <>", value, "reqLevel");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andReqLevelNotEqualToColumn(Column column) {
            this.addCriterion("req_level <> " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andReqLevelGreaterThan(Integer value) {
            this.addCriterion("req_level >", value, "reqLevel");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andReqLevelGreaterThanColumn(Column column) {
            this.addCriterion("req_level > " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andReqLevelGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("req_level >=", value, "reqLevel");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andReqLevelGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("req_level >= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andReqLevelLessThan(Integer value) {
            this.addCriterion("req_level <", value, "reqLevel");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andReqLevelLessThanColumn(Column column) {
            this.addCriterion("req_level < " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andReqLevelLessThanOrEqualTo(Integer value) {
            this.addCriterion("req_level <=", value, "reqLevel");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andReqLevelLessThanOrEqualToColumn(Column column) {
            this.addCriterion("req_level <= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andReqLevelIn(List<Integer> values) {
            this.addCriterion("req_level in", values, "reqLevel");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andReqLevelNotIn(List<Integer> values) {
            this.addCriterion("req_level not in", values, "reqLevel");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andReqLevelBetween(Integer value1, Integer value2) {
            this.addCriterion("req_level between", value1, value2, "reqLevel");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andReqLevelNotBetween(Integer value1, Integer value2) {
            this.addCriterion("req_level not between", value1, value2, "reqLevel");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidIsNull() {
            this.addCriterion("owner_uuid is null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidIsNotNull() {
            this.addCriterion("owner_uuid is not null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidEqualTo(String value) {
            this.addCriterion("owner_uuid =", value, "ownerUuid");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidEqualToColumn(Column column) {
            this.addCriterion("owner_uuid = " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidNotEqualTo(String value) {
            this.addCriterion("owner_uuid <>", value, "ownerUuid");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidNotEqualToColumn(Column column) {
            this.addCriterion("owner_uuid <> " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidGreaterThan(String value) {
            this.addCriterion("owner_uuid >", value, "ownerUuid");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidGreaterThanColumn(Column column) {
            this.addCriterion("owner_uuid > " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidGreaterThanOrEqualTo(String value) {
            this.addCriterion("owner_uuid >=", value, "ownerUuid");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("owner_uuid >= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidLessThan(String value) {
            this.addCriterion("owner_uuid <", value, "ownerUuid");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidLessThanColumn(Column column) {
            this.addCriterion("owner_uuid < " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidLessThanOrEqualTo(String value) {
            this.addCriterion("owner_uuid <=", value, "ownerUuid");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidLessThanOrEqualToColumn(Column column) {
            this.addCriterion("owner_uuid <= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidLike(String value) {
            this.addCriterion("owner_uuid like", value, "ownerUuid");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidNotLike(String value) {
            this.addCriterion("owner_uuid not like", value, "ownerUuid");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidIn(List<String> values) {
            this.addCriterion("owner_uuid in", values, "ownerUuid");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidNotIn(List<String> values) {
            this.addCriterion("owner_uuid not in", values, "ownerUuid");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidBetween(String value1, String value2) {
            this.addCriterion("owner_uuid between", value1, value2, "ownerUuid");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andOwnerUuidNotBetween(String value1, String value2) {
            this.addCriterion("owner_uuid not between", value1, value2, "ownerUuid");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrIsNull() {
            this.addCriterion("str is null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrIsNotNull() {
            this.addCriterion("str is not null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrEqualTo(String value) {
            this.addCriterion("str =", value, "str");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrEqualToColumn(Column column) {
            this.addCriterion("str = " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrNotEqualTo(String value) {
            this.addCriterion("str <>", value, "str");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrNotEqualToColumn(Column column) {
            this.addCriterion("str <> " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrGreaterThan(String value) {
            this.addCriterion("str >", value, "str");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrGreaterThanColumn(Column column) {
            this.addCriterion("str > " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrGreaterThanOrEqualTo(String value) {
            this.addCriterion("str >=", value, "str");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("str >= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrLessThan(String value) {
            this.addCriterion("str <", value, "str");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrLessThanColumn(Column column) {
            this.addCriterion("str < " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrLessThanOrEqualTo(String value) {
            this.addCriterion("str <=", value, "str");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrLessThanOrEqualToColumn(Column column) {
            this.addCriterion("str <= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrLike(String value) {
            this.addCriterion("str like", value, "str");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrNotLike(String value) {
            this.addCriterion("str not like", value, "str");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrIn(List<String> values) {
            this.addCriterion("str in", values, "str");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrNotIn(List<String> values) {
            this.addCriterion("str not in", values, "str");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrBetween(String value1, String value2) {
            this.addCriterion("str between", value1, value2, "str");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andStrNotBetween(String value1, String value2) {
            this.addCriterion("str not between", value1, value2, "str");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetIsNull() {
            this.addCriterion("pet is null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetIsNotNull() {
            this.addCriterion("pet is not null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetEqualTo(String value) {
            this.addCriterion("pet =", value, "pet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetEqualToColumn(Column column) {
            this.addCriterion("pet = " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetNotEqualTo(String value) {
            this.addCriterion("pet <>", value, "pet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetNotEqualToColumn(Column column) {
            this.addCriterion("pet <> " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetGreaterThan(String value) {
            this.addCriterion("pet >", value, "pet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetGreaterThanColumn(Column column) {
            this.addCriterion("pet > " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetGreaterThanOrEqualTo(String value) {
            this.addCriterion("pet >=", value, "pet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("pet >= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetLessThan(String value) {
            this.addCriterion("pet <", value, "pet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetLessThanColumn(Column column) {
            this.addCriterion("pet < " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetLessThanOrEqualTo(String value) {
            this.addCriterion("pet <=", value, "pet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetLessThanOrEqualToColumn(Column column) {
            this.addCriterion("pet <= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetLike(String value) {
            this.addCriterion("pet like", value, "pet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetNotLike(String value) {
            this.addCriterion("pet not like", value, "pet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetIn(List<String> values) {
            this.addCriterion("pet in", values, "pet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetNotIn(List<String> values) {
            this.addCriterion("pet not in", values, "pet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetBetween(String value1, String value2) {
            this.addCriterion("pet between", value1, value2, "pet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPetNotBetween(String value1, String value2) {
            this.addCriterion("pet not between", value1, value2, "pet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPosIsNull() {
            this.addCriterion("pos is null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPosIsNotNull() {
            this.addCriterion("pos is not null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPosEqualTo(Integer value) {
            this.addCriterion("pos =", value, "pos");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPosEqualToColumn(Column column) {
            this.addCriterion("pos = " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPosNotEqualTo(Integer value) {
            this.addCriterion("pos <>", value, "pos");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPosNotEqualToColumn(Column column) {
            this.addCriterion("pos <> " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPosGreaterThan(Integer value) {
            this.addCriterion("pos >", value, "pos");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPosGreaterThanColumn(Column column) {
            this.addCriterion("pos > " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPosGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("pos >=", value, "pos");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPosGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("pos >= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPosLessThan(Integer value) {
            this.addCriterion("pos <", value, "pos");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPosLessThanColumn(Column column) {
            this.addCriterion("pos < " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPosLessThanOrEqualTo(Integer value) {
            this.addCriterion("pos <=", value, "pos");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPosLessThanOrEqualToColumn(Column column) {
            this.addCriterion("pos <= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPosIn(List<Integer> values) {
            this.addCriterion("pos in", values, "pos");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPosNotIn(List<Integer> values) {
            this.addCriterion("pos not in", values, "pos");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPosBetween(Integer value1, Integer value2) {
            this.addCriterion("pos between", value1, value2, "pos");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andPosNotBetween(Integer value1, Integer value2) {
            this.addCriterion("pos not between", value1, value2, "pos");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIspetIsNull() {
            this.addCriterion("ispet is null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIspetIsNotNull() {
            this.addCriterion("ispet is not null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIspetEqualTo(Integer value) {
            this.addCriterion("ispet =", value, "ispet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIspetEqualToColumn(Column column) {
            this.addCriterion("ispet = " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIspetNotEqualTo(Integer value) {
            this.addCriterion("ispet <>", value, "ispet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIspetNotEqualToColumn(Column column) {
            this.addCriterion("ispet <> " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIspetGreaterThan(Integer value) {
            this.addCriterion("ispet >", value, "ispet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIspetGreaterThanColumn(Column column) {
            this.addCriterion("ispet > " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIspetGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("ispet >=", value, "ispet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIspetGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("ispet >= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIspetLessThan(Integer value) {
            this.addCriterion("ispet <", value, "ispet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIspetLessThanColumn(Column column) {
            this.addCriterion("ispet < " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIspetLessThanOrEqualTo(Integer value) {
            this.addCriterion("ispet <=", value, "ispet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIspetLessThanOrEqualToColumn(Column column) {
            this.addCriterion("ispet <= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIspetIn(List<Integer> values) {
            this.addCriterion("ispet in", values, "ispet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIspetNotIn(List<Integer> values) {
            this.addCriterion("ispet not in", values, "ispet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIspetBetween(Integer value1, Integer value2) {
            this.addCriterion("ispet between", value1, value2, "ispet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andIspetNotBetween(Integer value1, Integer value2) {
            this.addCriterion("ispet not between", value1, value2, "ispet");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andLevelIsNull() {
            this.addCriterion("`level` is null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andLevelIsNotNull() {
            this.addCriterion("`level` is not null");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andLevelEqualTo(Integer value) {
            this.addCriterion("`level` =", value, "level");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andLevelEqualToColumn(Column column) {
            this.addCriterion("`level` = " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andLevelNotEqualTo(Integer value) {
            this.addCriterion("`level` <>", value, "level");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andLevelNotEqualToColumn(Column column) {
            this.addCriterion("`level` <> " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andLevelGreaterThan(Integer value) {
            this.addCriterion("`level` >", value, "level");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andLevelGreaterThanColumn(Column column) {
            this.addCriterion("`level` > " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andLevelGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`level` >=", value, "level");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andLevelGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`level` >= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andLevelLessThan(Integer value) {
            this.addCriterion("`level` <", value, "level");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andLevelLessThanColumn(Column column) {
            this.addCriterion("`level` < " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andLevelLessThanOrEqualTo(Integer value) {
            this.addCriterion("`level` <=", value, "level");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andLevelLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`level` <= " + column.getEscapedColumnName());
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andLevelIn(List<Integer> values) {
            this.addCriterion("`level` in", values, "level");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andLevelNotIn(List<Integer> values) {
            this.addCriterion("`level` not in", values, "level");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andLevelBetween(Integer value1, Integer value2) {
            this.addCriterion("`level` between", value1, value2, "level");
            return (SaleGoodExample.Criteria)this;
        }

        public SaleGoodExample.Criteria andLevelNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`level` not between", value1, value2, "level");
            return (SaleGoodExample.Criteria)this;
        }
    }
}
