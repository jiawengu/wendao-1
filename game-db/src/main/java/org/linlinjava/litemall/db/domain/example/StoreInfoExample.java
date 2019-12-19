//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.StoreInfo.Column;
import org.linlinjava.litemall.db.domain.StoreInfo.Deleted;

public class StoreInfoExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<StoreInfoExample.Criteria> oredCriteria = new ArrayList();

    public StoreInfoExample() {
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

    public List<StoreInfoExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(StoreInfoExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public StoreInfoExample.Criteria or() {
        StoreInfoExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public StoreInfoExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public StoreInfoExample orderBy(String... orderByClauses) {
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

    public StoreInfoExample.Criteria createCriteria() {
        StoreInfoExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected StoreInfoExample.Criteria createCriteriaInternal() {
        StoreInfoExample.Criteria criteria = new StoreInfoExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static StoreInfoExample.Criteria newAndCreateCriteria() {
        StoreInfoExample example = new StoreInfoExample();
        return example.createCriteria();
    }

    public StoreInfoExample when(boolean condition, StoreInfoExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public StoreInfoExample when(boolean condition, StoreInfoExample.IExampleWhen then, StoreInfoExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(StoreInfoExample example);
    }

    public interface ICriteriaWhen {
        void criteria(StoreInfoExample.Criteria criteria);
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

    public static class Criteria extends StoreInfoExample.GeneratedCriteria {
        private StoreInfoExample example;

        protected Criteria(StoreInfoExample example) {
            this.example = example;
        }

        public StoreInfoExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public StoreInfoExample.Criteria andIf(boolean ifAdd, StoreInfoExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public StoreInfoExample.Criteria when(boolean condition, StoreInfoExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public StoreInfoExample.Criteria when(boolean condition, StoreInfoExample.ICriteriaWhen then, StoreInfoExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public StoreInfoExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            StoreInfoExample.Criteria add(StoreInfoExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<StoreInfoExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<StoreInfoExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<StoreInfoExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new StoreInfoExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new StoreInfoExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new StoreInfoExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public StoreInfoExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityIsNull() {
            this.addCriterion("quality is null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityIsNotNull() {
            this.addCriterion("quality is not null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityEqualTo(String value) {
            this.addCriterion("quality =", value, "quality");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityEqualToColumn(Column column) {
            this.addCriterion("quality = " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityNotEqualTo(String value) {
            this.addCriterion("quality <>", value, "quality");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityNotEqualToColumn(Column column) {
            this.addCriterion("quality <> " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityGreaterThan(String value) {
            this.addCriterion("quality >", value, "quality");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityGreaterThanColumn(Column column) {
            this.addCriterion("quality > " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityGreaterThanOrEqualTo(String value) {
            this.addCriterion("quality >=", value, "quality");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("quality >= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityLessThan(String value) {
            this.addCriterion("quality <", value, "quality");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityLessThanColumn(Column column) {
            this.addCriterion("quality < " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityLessThanOrEqualTo(String value) {
            this.addCriterion("quality <=", value, "quality");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityLessThanOrEqualToColumn(Column column) {
            this.addCriterion("quality <= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityLike(String value) {
            this.addCriterion("quality like", value, "quality");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityNotLike(String value) {
            this.addCriterion("quality not like", value, "quality");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityIn(List<String> values) {
            this.addCriterion("quality in", values, "quality");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityNotIn(List<String> values) {
            this.addCriterion("quality not in", values, "quality");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityBetween(String value1, String value2) {
            this.addCriterion("quality between", value1, value2, "quality");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andQualityNotBetween(String value1, String value2) {
            this.addCriterion("quality not between", value1, value2, "quality");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andValueIsNull() {
            this.addCriterion("`value` is null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andValueIsNotNull() {
            this.addCriterion("`value` is not null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andValueEqualTo(Integer value) {
            this.addCriterion("`value` =", value, "value");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andValueEqualToColumn(Column column) {
            this.addCriterion("`value` = " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andValueNotEqualTo(Integer value) {
            this.addCriterion("`value` <>", value, "value");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andValueNotEqualToColumn(Column column) {
            this.addCriterion("`value` <> " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andValueGreaterThan(Integer value) {
            this.addCriterion("`value` >", value, "value");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andValueGreaterThanColumn(Column column) {
            this.addCriterion("`value` > " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andValueGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`value` >=", value, "value");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andValueGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`value` >= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andValueLessThan(Integer value) {
            this.addCriterion("`value` <", value, "value");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andValueLessThanColumn(Column column) {
            this.addCriterion("`value` < " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andValueLessThanOrEqualTo(Integer value) {
            this.addCriterion("`value` <=", value, "value");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andValueLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`value` <= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andValueIn(List<Integer> values) {
            this.addCriterion("`value` in", values, "value");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andValueNotIn(List<Integer> values) {
            this.addCriterion("`value` not in", values, "value");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andValueBetween(Integer value1, Integer value2) {
            this.addCriterion("`value` between", value1, value2, "value");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andValueNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`value` not between", value1, value2, "value");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTypeIsNull() {
            this.addCriterion("`type` is null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTypeIsNotNull() {
            this.addCriterion("`type` is not null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTypeEqualTo(Integer value) {
            this.addCriterion("`type` =", value, "type");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTypeEqualToColumn(Column column) {
            this.addCriterion("`type` = " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTypeNotEqualTo(Integer value) {
            this.addCriterion("`type` <>", value, "type");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTypeNotEqualToColumn(Column column) {
            this.addCriterion("`type` <> " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTypeGreaterThan(Integer value) {
            this.addCriterion("`type` >", value, "type");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTypeGreaterThanColumn(Column column) {
            this.addCriterion("`type` > " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTypeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`type` >=", value, "type");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTypeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` >= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTypeLessThan(Integer value) {
            this.addCriterion("`type` <", value, "type");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTypeLessThanColumn(Column column) {
            this.addCriterion("`type` < " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTypeLessThanOrEqualTo(Integer value) {
            this.addCriterion("`type` <=", value, "type");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTypeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` <= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTypeIn(List<Integer> values) {
            this.addCriterion("`type` in", values, "type");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTypeNotIn(List<Integer> values) {
            this.addCriterion("`type` not in", values, "type");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTypeBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` between", value1, value2, "type");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTypeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` not between", value1, value2, "type");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTotalScoreIsNull() {
            this.addCriterion("total_score is null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTotalScoreIsNotNull() {
            this.addCriterion("total_score is not null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTotalScoreEqualTo(Integer value) {
            this.addCriterion("total_score =", value, "totalScore");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTotalScoreEqualToColumn(Column column) {
            this.addCriterion("total_score = " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTotalScoreNotEqualTo(Integer value) {
            this.addCriterion("total_score <>", value, "totalScore");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTotalScoreNotEqualToColumn(Column column) {
            this.addCriterion("total_score <> " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTotalScoreGreaterThan(Integer value) {
            this.addCriterion("total_score >", value, "totalScore");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTotalScoreGreaterThanColumn(Column column) {
            this.addCriterion("total_score > " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTotalScoreGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("total_score >=", value, "totalScore");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTotalScoreGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("total_score >= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTotalScoreLessThan(Integer value) {
            this.addCriterion("total_score <", value, "totalScore");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTotalScoreLessThanColumn(Column column) {
            this.addCriterion("total_score < " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTotalScoreLessThanOrEqualTo(Integer value) {
            this.addCriterion("total_score <=", value, "totalScore");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTotalScoreLessThanOrEqualToColumn(Column column) {
            this.addCriterion("total_score <= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTotalScoreIn(List<Integer> values) {
            this.addCriterion("total_score in", values, "totalScore");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTotalScoreNotIn(List<Integer> values) {
            this.addCriterion("total_score not in", values, "totalScore");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTotalScoreBetween(Integer value1, Integer value2) {
            this.addCriterion("total_score between", value1, value2, "totalScore");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andTotalScoreNotBetween(Integer value1, Integer value2) {
            this.addCriterion("total_score not between", value1, value2, "totalScore");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRecognizeRecognizedIsNull() {
            this.addCriterion("recognize_recognized is null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRecognizeRecognizedIsNotNull() {
            this.addCriterion("recognize_recognized is not null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRecognizeRecognizedEqualTo(Integer value) {
            this.addCriterion("recognize_recognized =", value, "recognizeRecognized");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRecognizeRecognizedEqualToColumn(Column column) {
            this.addCriterion("recognize_recognized = " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRecognizeRecognizedNotEqualTo(Integer value) {
            this.addCriterion("recognize_recognized <>", value, "recognizeRecognized");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRecognizeRecognizedNotEqualToColumn(Column column) {
            this.addCriterion("recognize_recognized <> " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRecognizeRecognizedGreaterThan(Integer value) {
            this.addCriterion("recognize_recognized >", value, "recognizeRecognized");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRecognizeRecognizedGreaterThanColumn(Column column) {
            this.addCriterion("recognize_recognized > " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRecognizeRecognizedGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("recognize_recognized >=", value, "recognizeRecognized");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRecognizeRecognizedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("recognize_recognized >= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRecognizeRecognizedLessThan(Integer value) {
            this.addCriterion("recognize_recognized <", value, "recognizeRecognized");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRecognizeRecognizedLessThanColumn(Column column) {
            this.addCriterion("recognize_recognized < " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRecognizeRecognizedLessThanOrEqualTo(Integer value) {
            this.addCriterion("recognize_recognized <=", value, "recognizeRecognized");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRecognizeRecognizedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("recognize_recognized <= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRecognizeRecognizedIn(List<Integer> values) {
            this.addCriterion("recognize_recognized in", values, "recognizeRecognized");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRecognizeRecognizedNotIn(List<Integer> values) {
            this.addCriterion("recognize_recognized not in", values, "recognizeRecognized");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRecognizeRecognizedBetween(Integer value1, Integer value2) {
            this.addCriterion("recognize_recognized between", value1, value2, "recognizeRecognized");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRecognizeRecognizedNotBetween(Integer value1, Integer value2) {
            this.addCriterion("recognize_recognized not between", value1, value2, "recognizeRecognized");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRebuildLevelIsNull() {
            this.addCriterion("rebuild_level is null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRebuildLevelIsNotNull() {
            this.addCriterion("rebuild_level is not null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRebuildLevelEqualTo(Integer value) {
            this.addCriterion("rebuild_level =", value, "rebuildLevel");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRebuildLevelEqualToColumn(Column column) {
            this.addCriterion("rebuild_level = " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRebuildLevelNotEqualTo(Integer value) {
            this.addCriterion("rebuild_level <>", value, "rebuildLevel");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRebuildLevelNotEqualToColumn(Column column) {
            this.addCriterion("rebuild_level <> " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRebuildLevelGreaterThan(Integer value) {
            this.addCriterion("rebuild_level >", value, "rebuildLevel");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRebuildLevelGreaterThanColumn(Column column) {
            this.addCriterion("rebuild_level > " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRebuildLevelGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("rebuild_level >=", value, "rebuildLevel");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRebuildLevelGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("rebuild_level >= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRebuildLevelLessThan(Integer value) {
            this.addCriterion("rebuild_level <", value, "rebuildLevel");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRebuildLevelLessThanColumn(Column column) {
            this.addCriterion("rebuild_level < " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRebuildLevelLessThanOrEqualTo(Integer value) {
            this.addCriterion("rebuild_level <=", value, "rebuildLevel");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRebuildLevelLessThanOrEqualToColumn(Column column) {
            this.addCriterion("rebuild_level <= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRebuildLevelIn(List<Integer> values) {
            this.addCriterion("rebuild_level in", values, "rebuildLevel");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRebuildLevelNotIn(List<Integer> values) {
            this.addCriterion("rebuild_level not in", values, "rebuildLevel");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRebuildLevelBetween(Integer value1, Integer value2) {
            this.addCriterion("rebuild_level between", value1, value2, "rebuildLevel");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andRebuildLevelNotBetween(Integer value1, Integer value2) {
            this.addCriterion("rebuild_level not between", value1, value2, "rebuildLevel");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andSilverCoinIsNull() {
            this.addCriterion("silver_coin is null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andSilverCoinIsNotNull() {
            this.addCriterion("silver_coin is not null");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andSilverCoinEqualTo(Integer value) {
            this.addCriterion("silver_coin =", value, "silverCoin");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andSilverCoinEqualToColumn(Column column) {
            this.addCriterion("silver_coin = " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andSilverCoinNotEqualTo(Integer value) {
            this.addCriterion("silver_coin <>", value, "silverCoin");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andSilverCoinNotEqualToColumn(Column column) {
            this.addCriterion("silver_coin <> " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andSilverCoinGreaterThan(Integer value) {
            this.addCriterion("silver_coin >", value, "silverCoin");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andSilverCoinGreaterThanColumn(Column column) {
            this.addCriterion("silver_coin > " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andSilverCoinGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("silver_coin >=", value, "silverCoin");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andSilverCoinGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("silver_coin >= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andSilverCoinLessThan(Integer value) {
            this.addCriterion("silver_coin <", value, "silverCoin");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andSilverCoinLessThanColumn(Column column) {
            this.addCriterion("silver_coin < " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andSilverCoinLessThanOrEqualTo(Integer value) {
            this.addCriterion("silver_coin <=", value, "silverCoin");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andSilverCoinLessThanOrEqualToColumn(Column column) {
            this.addCriterion("silver_coin <= " + column.getEscapedColumnName());
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andSilverCoinIn(List<Integer> values) {
            this.addCriterion("silver_coin in", values, "silverCoin");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andSilverCoinNotIn(List<Integer> values) {
            this.addCriterion("silver_coin not in", values, "silverCoin");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andSilverCoinBetween(Integer value1, Integer value2) {
            this.addCriterion("silver_coin between", value1, value2, "silverCoin");
            return (StoreInfoExample.Criteria)this;
        }

        public StoreInfoExample.Criteria andSilverCoinNotBetween(Integer value1, Integer value2) {
            this.addCriterion("silver_coin not between", value1, value2, "silverCoin");
            return (StoreInfoExample.Criteria)this;
        }
    }
}
