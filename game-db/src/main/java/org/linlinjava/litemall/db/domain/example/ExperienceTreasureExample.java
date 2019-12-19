//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.ExperienceTreasure.Column;
import org.linlinjava.litemall.db.domain.ExperienceTreasure.Deleted;

public class ExperienceTreasureExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<ExperienceTreasureExample.Criteria> oredCriteria = new ArrayList();

    public ExperienceTreasureExample() {
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

    public List<ExperienceTreasureExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(ExperienceTreasureExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public ExperienceTreasureExample.Criteria or() {
        ExperienceTreasureExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public ExperienceTreasureExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public ExperienceTreasureExample orderBy(String... orderByClauses) {
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

    public ExperienceTreasureExample.Criteria createCriteria() {
        ExperienceTreasureExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected ExperienceTreasureExample.Criteria createCriteriaInternal() {
        ExperienceTreasureExample.Criteria criteria = new ExperienceTreasureExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static ExperienceTreasureExample.Criteria newAndCreateCriteria() {
        ExperienceTreasureExample example = new ExperienceTreasureExample();
        return example.createCriteria();
    }

    public ExperienceTreasureExample when(boolean condition, ExperienceTreasureExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public ExperienceTreasureExample when(boolean condition, ExperienceTreasureExample.IExampleWhen then, ExperienceTreasureExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(ExperienceTreasureExample example);
    }

    public interface ICriteriaWhen {
        void criteria(ExperienceTreasureExample.Criteria criteria);
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

    public static class Criteria extends ExperienceTreasureExample.GeneratedCriteria {
        private ExperienceTreasureExample example;

        protected Criteria(ExperienceTreasureExample example) {
            this.example = example;
        }

        public ExperienceTreasureExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public ExperienceTreasureExample.Criteria andIf(boolean ifAdd, ExperienceTreasureExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public ExperienceTreasureExample.Criteria when(boolean condition, ExperienceTreasureExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public ExperienceTreasureExample.Criteria when(boolean condition, ExperienceTreasureExample.ICriteriaWhen then, ExperienceTreasureExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public ExperienceTreasureExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            ExperienceTreasureExample.Criteria add(ExperienceTreasureExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<ExperienceTreasureExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<ExperienceTreasureExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<ExperienceTreasureExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new ExperienceTreasureExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new ExperienceTreasureExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new ExperienceTreasureExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public ExperienceTreasureExample.Criteria andAttribIsNull() {
            this.addCriterion("attrib is null");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAttribIsNotNull() {
            this.addCriterion("attrib is not null");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAttribEqualTo(Integer value) {
            this.addCriterion("attrib =", value, "attrib");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAttribEqualToColumn(Column column) {
            this.addCriterion("attrib = " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAttribNotEqualTo(Integer value) {
            this.addCriterion("attrib <>", value, "attrib");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAttribNotEqualToColumn(Column column) {
            this.addCriterion("attrib <> " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAttribGreaterThan(Integer value) {
            this.addCriterion("attrib >", value, "attrib");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAttribGreaterThanColumn(Column column) {
            this.addCriterion("attrib > " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAttribGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("attrib >=", value, "attrib");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAttribGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("attrib >= " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAttribLessThan(Integer value) {
            this.addCriterion("attrib <", value, "attrib");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAttribLessThanColumn(Column column) {
            this.addCriterion("attrib < " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAttribLessThanOrEqualTo(Integer value) {
            this.addCriterion("attrib <=", value, "attrib");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAttribLessThanOrEqualToColumn(Column column) {
            this.addCriterion("attrib <= " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAttribIn(List<Integer> values) {
            this.addCriterion("attrib in", values, "attrib");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAttribNotIn(List<Integer> values) {
            this.addCriterion("attrib not in", values, "attrib");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAttribBetween(Integer value1, Integer value2) {
            this.addCriterion("attrib between", value1, value2, "attrib");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAttribNotBetween(Integer value1, Integer value2) {
            this.addCriterion("attrib not between", value1, value2, "attrib");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andMaxLevelIsNull() {
            this.addCriterion("max_level is null");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andMaxLevelIsNotNull() {
            this.addCriterion("max_level is not null");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andMaxLevelEqualTo(Integer value) {
            this.addCriterion("max_level =", value, "maxLevel");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andMaxLevelEqualToColumn(Column column) {
            this.addCriterion("max_level = " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andMaxLevelNotEqualTo(Integer value) {
            this.addCriterion("max_level <>", value, "maxLevel");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andMaxLevelNotEqualToColumn(Column column) {
            this.addCriterion("max_level <> " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andMaxLevelGreaterThan(Integer value) {
            this.addCriterion("max_level >", value, "maxLevel");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andMaxLevelGreaterThanColumn(Column column) {
            this.addCriterion("max_level > " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andMaxLevelGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("max_level >=", value, "maxLevel");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andMaxLevelGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("max_level >= " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andMaxLevelLessThan(Integer value) {
            this.addCriterion("max_level <", value, "maxLevel");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andMaxLevelLessThanColumn(Column column) {
            this.addCriterion("max_level < " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andMaxLevelLessThanOrEqualTo(Integer value) {
            this.addCriterion("max_level <=", value, "maxLevel");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andMaxLevelLessThanOrEqualToColumn(Column column) {
            this.addCriterion("max_level <= " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andMaxLevelIn(List<Integer> values) {
            this.addCriterion("max_level in", values, "maxLevel");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andMaxLevelNotIn(List<Integer> values) {
            this.addCriterion("max_level not in", values, "maxLevel");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andMaxLevelBetween(Integer value1, Integer value2) {
            this.addCriterion("max_level between", value1, value2, "maxLevel");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andMaxLevelNotBetween(Integer value1, Integer value2) {
            this.addCriterion("max_level not between", value1, value2, "maxLevel");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (ExperienceTreasureExample.Criteria)this;
        }

        public ExperienceTreasureExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (ExperienceTreasureExample.Criteria)this;
        }
    }
}
