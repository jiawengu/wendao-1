//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Experience.Column;
import org.linlinjava.litemall.db.domain.Experience.Deleted;

public class ExperienceExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<ExperienceExample.Criteria> oredCriteria = new ArrayList();

    public ExperienceExample() {
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

    public List<ExperienceExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(ExperienceExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public ExperienceExample.Criteria or() {
        ExperienceExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public ExperienceExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public ExperienceExample orderBy(String... orderByClauses) {
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

    public ExperienceExample.Criteria createCriteria() {
        ExperienceExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected ExperienceExample.Criteria createCriteriaInternal() {
        ExperienceExample.Criteria criteria = new ExperienceExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static ExperienceExample.Criteria newAndCreateCriteria() {
        ExperienceExample example = new ExperienceExample();
        return example.createCriteria();
    }

    public ExperienceExample when(boolean condition, ExperienceExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public ExperienceExample when(boolean condition, ExperienceExample.IExampleWhen then, ExperienceExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(ExperienceExample example);
    }

    public interface ICriteriaWhen {
        void criteria(ExperienceExample.Criteria criteria);
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

    public static class Criteria extends ExperienceExample.GeneratedCriteria {
        private ExperienceExample example;

        protected Criteria(ExperienceExample example) {
            this.example = example;
        }

        public ExperienceExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public ExperienceExample.Criteria andIf(boolean ifAdd, ExperienceExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public ExperienceExample.Criteria when(boolean condition, ExperienceExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public ExperienceExample.Criteria when(boolean condition, ExperienceExample.ICriteriaWhen then, ExperienceExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public ExperienceExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            ExperienceExample.Criteria add(ExperienceExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<ExperienceExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<ExperienceExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<ExperienceExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new ExperienceExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new ExperienceExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new ExperienceExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public ExperienceExample.Criteria andAttribIsNull() {
            this.addCriterion("attrib is null");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAttribIsNotNull() {
            this.addCriterion("attrib is not null");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAttribEqualTo(Integer value) {
            this.addCriterion("attrib =", value, "attrib");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAttribEqualToColumn(Column column) {
            this.addCriterion("attrib = " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAttribNotEqualTo(Integer value) {
            this.addCriterion("attrib <>", value, "attrib");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAttribNotEqualToColumn(Column column) {
            this.addCriterion("attrib <> " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAttribGreaterThan(Integer value) {
            this.addCriterion("attrib >", value, "attrib");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAttribGreaterThanColumn(Column column) {
            this.addCriterion("attrib > " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAttribGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("attrib >=", value, "attrib");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAttribGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("attrib >= " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAttribLessThan(Integer value) {
            this.addCriterion("attrib <", value, "attrib");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAttribLessThanColumn(Column column) {
            this.addCriterion("attrib < " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAttribLessThanOrEqualTo(Integer value) {
            this.addCriterion("attrib <=", value, "attrib");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAttribLessThanOrEqualToColumn(Column column) {
            this.addCriterion("attrib <= " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAttribIn(List<Integer> values) {
            this.addCriterion("attrib in", values, "attrib");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAttribNotIn(List<Integer> values) {
            this.addCriterion("attrib not in", values, "attrib");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAttribBetween(Integer value1, Integer value2) {
            this.addCriterion("attrib between", value1, value2, "attrib");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAttribNotBetween(Integer value1, Integer value2) {
            this.addCriterion("attrib not between", value1, value2, "attrib");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andMaxLevelIsNull() {
            this.addCriterion("max_level is null");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andMaxLevelIsNotNull() {
            this.addCriterion("max_level is not null");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andMaxLevelEqualTo(Integer value) {
            this.addCriterion("max_level =", value, "maxLevel");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andMaxLevelEqualToColumn(Column column) {
            this.addCriterion("max_level = " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andMaxLevelNotEqualTo(Integer value) {
            this.addCriterion("max_level <>", value, "maxLevel");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andMaxLevelNotEqualToColumn(Column column) {
            this.addCriterion("max_level <> " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andMaxLevelGreaterThan(Integer value) {
            this.addCriterion("max_level >", value, "maxLevel");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andMaxLevelGreaterThanColumn(Column column) {
            this.addCriterion("max_level > " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andMaxLevelGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("max_level >=", value, "maxLevel");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andMaxLevelGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("max_level >= " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andMaxLevelLessThan(Integer value) {
            this.addCriterion("max_level <", value, "maxLevel");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andMaxLevelLessThanColumn(Column column) {
            this.addCriterion("max_level < " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andMaxLevelLessThanOrEqualTo(Integer value) {
            this.addCriterion("max_level <=", value, "maxLevel");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andMaxLevelLessThanOrEqualToColumn(Column column) {
            this.addCriterion("max_level <= " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andMaxLevelIn(List<Integer> values) {
            this.addCriterion("max_level in", values, "maxLevel");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andMaxLevelNotIn(List<Integer> values) {
            this.addCriterion("max_level not in", values, "maxLevel");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andMaxLevelBetween(Integer value1, Integer value2) {
            this.addCriterion("max_level between", value1, value2, "maxLevel");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andMaxLevelNotBetween(Integer value1, Integer value2) {
            this.addCriterion("max_level not between", value1, value2, "maxLevel");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (ExperienceExample.Criteria)this;
        }

        public ExperienceExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (ExperienceExample.Criteria)this;
        }
    }
}
