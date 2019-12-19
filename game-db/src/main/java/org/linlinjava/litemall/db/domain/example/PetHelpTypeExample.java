//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.PetHelpType.Column;
import org.linlinjava.litemall.db.domain.PetHelpType.Deleted;

public class PetHelpTypeExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<PetHelpTypeExample.Criteria> oredCriteria = new ArrayList();

    public PetHelpTypeExample() {
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

    public List<PetHelpTypeExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(PetHelpTypeExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public PetHelpTypeExample.Criteria or() {
        PetHelpTypeExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public PetHelpTypeExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public PetHelpTypeExample orderBy(String... orderByClauses) {
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

    public PetHelpTypeExample.Criteria createCriteria() {
        PetHelpTypeExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected PetHelpTypeExample.Criteria createCriteriaInternal() {
        PetHelpTypeExample.Criteria criteria = new PetHelpTypeExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static PetHelpTypeExample.Criteria newAndCreateCriteria() {
        PetHelpTypeExample example = new PetHelpTypeExample();
        return example.createCriteria();
    }

    public PetHelpTypeExample when(boolean condition, PetHelpTypeExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public PetHelpTypeExample when(boolean condition, PetHelpTypeExample.IExampleWhen then, PetHelpTypeExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(PetHelpTypeExample example);
    }

    public interface ICriteriaWhen {
        void criteria(PetHelpTypeExample.Criteria criteria);
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

    public static class Criteria extends PetHelpTypeExample.GeneratedCriteria {
        private PetHelpTypeExample example;

        protected Criteria(PetHelpTypeExample example) {
            this.example = example;
        }

        public PetHelpTypeExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public PetHelpTypeExample.Criteria andIf(boolean ifAdd, PetHelpTypeExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public PetHelpTypeExample.Criteria when(boolean condition, PetHelpTypeExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public PetHelpTypeExample.Criteria when(boolean condition, PetHelpTypeExample.ICriteriaWhen then, PetHelpTypeExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public PetHelpTypeExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            PetHelpTypeExample.Criteria add(PetHelpTypeExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<PetHelpTypeExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<PetHelpTypeExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<PetHelpTypeExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new PetHelpTypeExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new PetHelpTypeExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new PetHelpTypeExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public PetHelpTypeExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andTypeIsNull() {
            this.addCriterion("`type` is null");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andTypeIsNotNull() {
            this.addCriterion("`type` is not null");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andTypeEqualTo(Integer value) {
            this.addCriterion("`type` =", value, "type");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andTypeEqualToColumn(Column column) {
            this.addCriterion("`type` = " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andTypeNotEqualTo(Integer value) {
            this.addCriterion("`type` <>", value, "type");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andTypeNotEqualToColumn(Column column) {
            this.addCriterion("`type` <> " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andTypeGreaterThan(Integer value) {
            this.addCriterion("`type` >", value, "type");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andTypeGreaterThanColumn(Column column) {
            this.addCriterion("`type` > " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andTypeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`type` >=", value, "type");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andTypeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` >= " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andTypeLessThan(Integer value) {
            this.addCriterion("`type` <", value, "type");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andTypeLessThanColumn(Column column) {
            this.addCriterion("`type` < " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andTypeLessThanOrEqualTo(Integer value) {
            this.addCriterion("`type` <=", value, "type");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andTypeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` <= " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andTypeIn(List<Integer> values) {
            this.addCriterion("`type` in", values, "type");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andTypeNotIn(List<Integer> values) {
            this.addCriterion("`type` not in", values, "type");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andTypeBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` between", value1, value2, "type");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andTypeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` not between", value1, value2, "type");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andQualityIsNull() {
            this.addCriterion("quality is null");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andQualityIsNotNull() {
            this.addCriterion("quality is not null");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andQualityEqualTo(Integer value) {
            this.addCriterion("quality =", value, "quality");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andQualityEqualToColumn(Column column) {
            this.addCriterion("quality = " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andQualityNotEqualTo(Integer value) {
            this.addCriterion("quality <>", value, "quality");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andQualityNotEqualToColumn(Column column) {
            this.addCriterion("quality <> " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andQualityGreaterThan(Integer value) {
            this.addCriterion("quality >", value, "quality");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andQualityGreaterThanColumn(Column column) {
            this.addCriterion("quality > " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andQualityGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("quality >=", value, "quality");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andQualityGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("quality >= " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andQualityLessThan(Integer value) {
            this.addCriterion("quality <", value, "quality");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andQualityLessThanColumn(Column column) {
            this.addCriterion("quality < " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andQualityLessThanOrEqualTo(Integer value) {
            this.addCriterion("quality <=", value, "quality");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andQualityLessThanOrEqualToColumn(Column column) {
            this.addCriterion("quality <= " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andQualityIn(List<Integer> values) {
            this.addCriterion("quality in", values, "quality");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andQualityNotIn(List<Integer> values) {
            this.addCriterion("quality not in", values, "quality");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andQualityBetween(Integer value1, Integer value2) {
            this.addCriterion("quality between", value1, value2, "quality");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andQualityNotBetween(Integer value1, Integer value2) {
            this.addCriterion("quality not between", value1, value2, "quality");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andMoneyIsNull() {
            this.addCriterion("money is null");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andMoneyIsNotNull() {
            this.addCriterion("money is not null");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andMoneyEqualTo(Integer value) {
            this.addCriterion("money =", value, "money");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andMoneyEqualToColumn(Column column) {
            this.addCriterion("money = " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andMoneyNotEqualTo(Integer value) {
            this.addCriterion("money <>", value, "money");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andMoneyNotEqualToColumn(Column column) {
            this.addCriterion("money <> " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andMoneyGreaterThan(Integer value) {
            this.addCriterion("money >", value, "money");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andMoneyGreaterThanColumn(Column column) {
            this.addCriterion("money > " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andMoneyGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("money >=", value, "money");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andMoneyGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("money >= " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andMoneyLessThan(Integer value) {
            this.addCriterion("money <", value, "money");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andMoneyLessThanColumn(Column column) {
            this.addCriterion("money < " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andMoneyLessThanOrEqualTo(Integer value) {
            this.addCriterion("money <=", value, "money");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andMoneyLessThanOrEqualToColumn(Column column) {
            this.addCriterion("money <= " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andMoneyIn(List<Integer> values) {
            this.addCriterion("money in", values, "money");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andMoneyNotIn(List<Integer> values) {
            this.addCriterion("money not in", values, "money");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andMoneyBetween(Integer value1, Integer value2) {
            this.addCriterion("money between", value1, value2, "money");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andMoneyNotBetween(Integer value1, Integer value2) {
            this.addCriterion("money not between", value1, value2, "money");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andPolarIsNull() {
            this.addCriterion("polar is null");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andPolarIsNotNull() {
            this.addCriterion("polar is not null");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andPolarEqualTo(Integer value) {
            this.addCriterion("polar =", value, "polar");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andPolarEqualToColumn(Column column) {
            this.addCriterion("polar = " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andPolarNotEqualTo(Integer value) {
            this.addCriterion("polar <>", value, "polar");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andPolarNotEqualToColumn(Column column) {
            this.addCriterion("polar <> " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andPolarGreaterThan(Integer value) {
            this.addCriterion("polar >", value, "polar");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andPolarGreaterThanColumn(Column column) {
            this.addCriterion("polar > " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andPolarGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("polar >=", value, "polar");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andPolarGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("polar >= " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andPolarLessThan(Integer value) {
            this.addCriterion("polar <", value, "polar");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andPolarLessThanColumn(Column column) {
            this.addCriterion("polar < " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andPolarLessThanOrEqualTo(Integer value) {
            this.addCriterion("polar <=", value, "polar");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andPolarLessThanOrEqualToColumn(Column column) {
            this.addCriterion("polar <= " + column.getEscapedColumnName());
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andPolarIn(List<Integer> values) {
            this.addCriterion("polar in", values, "polar");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andPolarNotIn(List<Integer> values) {
            this.addCriterion("polar not in", values, "polar");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andPolarBetween(Integer value1, Integer value2) {
            this.addCriterion("polar between", value1, value2, "polar");
            return (PetHelpTypeExample.Criteria)this;
        }

        public PetHelpTypeExample.Criteria andPolarNotBetween(Integer value1, Integer value2) {
            this.addCriterion("polar not between", value1, value2, "polar");
            return (PetHelpTypeExample.Criteria)this;
        }
    }
}
