//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.CreepsStore.Column;
import org.linlinjava.litemall.db.domain.CreepsStore.Deleted;

public class CreepsStoreExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<CreepsStoreExample.Criteria> oredCriteria = new ArrayList();

    public CreepsStoreExample() {
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

    public List<CreepsStoreExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(CreepsStoreExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public CreepsStoreExample.Criteria or() {
        CreepsStoreExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public CreepsStoreExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public CreepsStoreExample orderBy(String... orderByClauses) {
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

    public CreepsStoreExample.Criteria createCriteria() {
        CreepsStoreExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected CreepsStoreExample.Criteria createCriteriaInternal() {
        CreepsStoreExample.Criteria criteria = new CreepsStoreExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static CreepsStoreExample.Criteria newAndCreateCriteria() {
        CreepsStoreExample example = new CreepsStoreExample();
        return example.createCriteria();
    }

    public CreepsStoreExample when(boolean condition, CreepsStoreExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public CreepsStoreExample when(boolean condition, CreepsStoreExample.IExampleWhen then, CreepsStoreExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(CreepsStoreExample example);
    }

    public interface ICriteriaWhen {
        void criteria(CreepsStoreExample.Criteria criteria);
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

    public static class Criteria extends CreepsStoreExample.GeneratedCriteria {
        private CreepsStoreExample example;

        protected Criteria(CreepsStoreExample example) {
            this.example = example;
        }

        public CreepsStoreExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public CreepsStoreExample.Criteria andIf(boolean ifAdd, CreepsStoreExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public CreepsStoreExample.Criteria when(boolean condition, CreepsStoreExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public CreepsStoreExample.Criteria when(boolean condition, CreepsStoreExample.ICriteriaWhen then, CreepsStoreExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public CreepsStoreExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            CreepsStoreExample.Criteria add(CreepsStoreExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<CreepsStoreExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<CreepsStoreExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<CreepsStoreExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new CreepsStoreExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new CreepsStoreExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new CreepsStoreExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public CreepsStoreExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andPriceIsNull() {
            this.addCriterion("price is null");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andPriceIsNotNull() {
            this.addCriterion("price is not null");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andPriceEqualTo(Integer value) {
            this.addCriterion("price =", value, "price");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andPriceEqualToColumn(Column column) {
            this.addCriterion("price = " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andPriceNotEqualTo(Integer value) {
            this.addCriterion("price <>", value, "price");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andPriceNotEqualToColumn(Column column) {
            this.addCriterion("price <> " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andPriceGreaterThan(Integer value) {
            this.addCriterion("price >", value, "price");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andPriceGreaterThanColumn(Column column) {
            this.addCriterion("price > " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andPriceGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("price >=", value, "price");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andPriceGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("price >= " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andPriceLessThan(Integer value) {
            this.addCriterion("price <", value, "price");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andPriceLessThanColumn(Column column) {
            this.addCriterion("price < " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andPriceLessThanOrEqualTo(Integer value) {
            this.addCriterion("price <=", value, "price");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andPriceLessThanOrEqualToColumn(Column column) {
            this.addCriterion("price <= " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andPriceIn(List<Integer> values) {
            this.addCriterion("price in", values, "price");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andPriceNotIn(List<Integer> values) {
            this.addCriterion("price not in", values, "price");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andPriceBetween(Integer value1, Integer value2) {
            this.addCriterion("price between", value1, value2, "price");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andPriceNotBetween(Integer value1, Integer value2) {
            this.addCriterion("price not between", value1, value2, "price");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (CreepsStoreExample.Criteria)this;
        }

        public CreepsStoreExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (CreepsStoreExample.Criteria)this;
        }
    }
}
