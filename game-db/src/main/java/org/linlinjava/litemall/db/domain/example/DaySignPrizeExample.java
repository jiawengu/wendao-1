//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.DaySignPrize.Column;
import org.linlinjava.litemall.db.domain.DaySignPrize.Deleted;

public class DaySignPrizeExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<DaySignPrizeExample.Criteria> oredCriteria = new ArrayList();

    public DaySignPrizeExample() {
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

    public List<DaySignPrizeExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(DaySignPrizeExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public DaySignPrizeExample.Criteria or() {
        DaySignPrizeExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public DaySignPrizeExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public DaySignPrizeExample orderBy(String... orderByClauses) {
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

    public DaySignPrizeExample.Criteria createCriteria() {
        DaySignPrizeExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected DaySignPrizeExample.Criteria createCriteriaInternal() {
        DaySignPrizeExample.Criteria criteria = new DaySignPrizeExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static DaySignPrizeExample.Criteria newAndCreateCriteria() {
        DaySignPrizeExample example = new DaySignPrizeExample();
        return example.createCriteria();
    }

    public DaySignPrizeExample when(boolean condition, DaySignPrizeExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public DaySignPrizeExample when(boolean condition, DaySignPrizeExample.IExampleWhen then, DaySignPrizeExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(DaySignPrizeExample example);
    }

    public interface ICriteriaWhen {
        void criteria(DaySignPrizeExample.Criteria criteria);
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

    public static class Criteria extends DaySignPrizeExample.GeneratedCriteria {
        private DaySignPrizeExample example;

        protected Criteria(DaySignPrizeExample example) {
            this.example = example;
        }

        public DaySignPrizeExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public DaySignPrizeExample.Criteria andIf(boolean ifAdd, DaySignPrizeExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public DaySignPrizeExample.Criteria when(boolean condition, DaySignPrizeExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public DaySignPrizeExample.Criteria when(boolean condition, DaySignPrizeExample.ICriteriaWhen then, DaySignPrizeExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public DaySignPrizeExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            DaySignPrizeExample.Criteria add(DaySignPrizeExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<DaySignPrizeExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<DaySignPrizeExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<DaySignPrizeExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new DaySignPrizeExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new DaySignPrizeExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new DaySignPrizeExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public DaySignPrizeExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIndexIsNull() {
            this.addCriterion("`index` is null");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIndexIsNotNull() {
            this.addCriterion("`index` is not null");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIndexEqualTo(Integer value) {
            this.addCriterion("`index` =", value, "index");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIndexEqualToColumn(Column column) {
            this.addCriterion("`index` = " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIndexNotEqualTo(Integer value) {
            this.addCriterion("`index` <>", value, "index");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIndexNotEqualToColumn(Column column) {
            this.addCriterion("`index` <> " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIndexGreaterThan(Integer value) {
            this.addCriterion("`index` >", value, "index");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIndexGreaterThanColumn(Column column) {
            this.addCriterion("`index` > " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIndexGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`index` >=", value, "index");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIndexGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`index` >= " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIndexLessThan(Integer value) {
            this.addCriterion("`index` <", value, "index");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIndexLessThanColumn(Column column) {
            this.addCriterion("`index` < " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIndexLessThanOrEqualTo(Integer value) {
            this.addCriterion("`index` <=", value, "index");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIndexLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`index` <= " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIndexIn(List<Integer> values) {
            this.addCriterion("`index` in", values, "index");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIndexNotIn(List<Integer> values) {
            this.addCriterion("`index` not in", values, "index");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIndexBetween(Integer value1, Integer value2) {
            this.addCriterion("`index` between", value1, value2, "index");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andIndexNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`index` not between", value1, value2, "index");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (DaySignPrizeExample.Criteria)this;
        }

        public DaySignPrizeExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (DaySignPrizeExample.Criteria)this;
        }
    }
}
