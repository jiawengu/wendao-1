//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Shuxingduiying.Column;
import org.linlinjava.litemall.db.domain.Shuxingduiying.Deleted;

public class ShuxingduiyingExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<ShuxingduiyingExample.Criteria> oredCriteria = new ArrayList();

    public ShuxingduiyingExample() {
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

    public List<ShuxingduiyingExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(ShuxingduiyingExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public ShuxingduiyingExample.Criteria or() {
        ShuxingduiyingExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public ShuxingduiyingExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public ShuxingduiyingExample orderBy(String... orderByClauses) {
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

    public ShuxingduiyingExample.Criteria createCriteria() {
        ShuxingduiyingExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected ShuxingduiyingExample.Criteria createCriteriaInternal() {
        ShuxingduiyingExample.Criteria criteria = new ShuxingduiyingExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static ShuxingduiyingExample.Criteria newAndCreateCriteria() {
        ShuxingduiyingExample example = new ShuxingduiyingExample();
        return example.createCriteria();
    }

    public ShuxingduiyingExample when(boolean condition, ShuxingduiyingExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public ShuxingduiyingExample when(boolean condition, ShuxingduiyingExample.IExampleWhen then, ShuxingduiyingExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(ShuxingduiyingExample example);
    }

    public interface ICriteriaWhen {
        void criteria(ShuxingduiyingExample.Criteria criteria);
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

    public static class Criteria extends ShuxingduiyingExample.GeneratedCriteria {
        private ShuxingduiyingExample example;

        protected Criteria(ShuxingduiyingExample example) {
            this.example = example;
        }

        public ShuxingduiyingExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public ShuxingduiyingExample.Criteria andIf(boolean ifAdd, ShuxingduiyingExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public ShuxingduiyingExample.Criteria when(boolean condition, ShuxingduiyingExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public ShuxingduiyingExample.Criteria when(boolean condition, ShuxingduiyingExample.ICriteriaWhen then, ShuxingduiyingExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public ShuxingduiyingExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            ShuxingduiyingExample.Criteria add(ShuxingduiyingExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<ShuxingduiyingExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<ShuxingduiyingExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<ShuxingduiyingExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new ShuxingduiyingExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new ShuxingduiyingExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new ShuxingduiyingExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public ShuxingduiyingExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenIsNull() {
            this.addCriterion("yingwen is null");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenIsNotNull() {
            this.addCriterion("yingwen is not null");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenEqualTo(String value) {
            this.addCriterion("yingwen =", value, "yingwen");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenEqualToColumn(Column column) {
            this.addCriterion("yingwen = " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenNotEqualTo(String value) {
            this.addCriterion("yingwen <>", value, "yingwen");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenNotEqualToColumn(Column column) {
            this.addCriterion("yingwen <> " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenGreaterThan(String value) {
            this.addCriterion("yingwen >", value, "yingwen");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenGreaterThanColumn(Column column) {
            this.addCriterion("yingwen > " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenGreaterThanOrEqualTo(String value) {
            this.addCriterion("yingwen >=", value, "yingwen");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("yingwen >= " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenLessThan(String value) {
            this.addCriterion("yingwen <", value, "yingwen");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenLessThanColumn(Column column) {
            this.addCriterion("yingwen < " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenLessThanOrEqualTo(String value) {
            this.addCriterion("yingwen <=", value, "yingwen");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenLessThanOrEqualToColumn(Column column) {
            this.addCriterion("yingwen <= " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenLike(String value) {
            this.addCriterion("yingwen like", value, "yingwen");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenNotLike(String value) {
            this.addCriterion("yingwen not like", value, "yingwen");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenIn(List<String> values) {
            this.addCriterion("yingwen in", values, "yingwen");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenNotIn(List<String> values) {
            this.addCriterion("yingwen not in", values, "yingwen");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenBetween(String value1, String value2) {
            this.addCriterion("yingwen between", value1, value2, "yingwen");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andYingwenNotBetween(String value1, String value2) {
            this.addCriterion("yingwen not between", value1, value2, "yingwen");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (ShuxingduiyingExample.Criteria)this;
        }

        public ShuxingduiyingExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (ShuxingduiyingExample.Criteria)this;
        }
    }
}
