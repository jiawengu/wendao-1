//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.SkillMonster.Column;
import org.linlinjava.litemall.db.domain.SkillMonster.Deleted;

public class SkillMonsterExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<SkillMonsterExample.Criteria> oredCriteria = new ArrayList();

    public SkillMonsterExample() {
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

    public List<SkillMonsterExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(SkillMonsterExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public SkillMonsterExample.Criteria or() {
        SkillMonsterExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public SkillMonsterExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public SkillMonsterExample orderBy(String... orderByClauses) {
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

    public SkillMonsterExample.Criteria createCriteria() {
        SkillMonsterExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected SkillMonsterExample.Criteria createCriteriaInternal() {
        SkillMonsterExample.Criteria criteria = new SkillMonsterExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static SkillMonsterExample.Criteria newAndCreateCriteria() {
        SkillMonsterExample example = new SkillMonsterExample();
        return example.createCriteria();
    }

    public SkillMonsterExample when(boolean condition, SkillMonsterExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public SkillMonsterExample when(boolean condition, SkillMonsterExample.IExampleWhen then, SkillMonsterExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(SkillMonsterExample example);
    }

    public interface ICriteriaWhen {
        void criteria(SkillMonsterExample.Criteria criteria);
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

    public static class Criteria extends SkillMonsterExample.GeneratedCriteria {
        private SkillMonsterExample example;

        protected Criteria(SkillMonsterExample example) {
            this.example = example;
        }

        public SkillMonsterExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public SkillMonsterExample.Criteria andIf(boolean ifAdd, SkillMonsterExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public SkillMonsterExample.Criteria when(boolean condition, SkillMonsterExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public SkillMonsterExample.Criteria when(boolean condition, SkillMonsterExample.ICriteriaWhen then, SkillMonsterExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public SkillMonsterExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            SkillMonsterExample.Criteria add(SkillMonsterExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<SkillMonsterExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<SkillMonsterExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<SkillMonsterExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new SkillMonsterExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new SkillMonsterExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new SkillMonsterExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public SkillMonsterExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsIsNull() {
            this.addCriterion("skills is null");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsIsNotNull() {
            this.addCriterion("skills is not null");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsEqualTo(String value) {
            this.addCriterion("skills =", value, "skills");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsEqualToColumn(Column column) {
            this.addCriterion("skills = " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsNotEqualTo(String value) {
            this.addCriterion("skills <>", value, "skills");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsNotEqualToColumn(Column column) {
            this.addCriterion("skills <> " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsGreaterThan(String value) {
            this.addCriterion("skills >", value, "skills");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsGreaterThanColumn(Column column) {
            this.addCriterion("skills > " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsGreaterThanOrEqualTo(String value) {
            this.addCriterion("skills >=", value, "skills");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skills >= " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsLessThan(String value) {
            this.addCriterion("skills <", value, "skills");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsLessThanColumn(Column column) {
            this.addCriterion("skills < " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsLessThanOrEqualTo(String value) {
            this.addCriterion("skills <=", value, "skills");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skills <= " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsLike(String value) {
            this.addCriterion("skills like", value, "skills");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsNotLike(String value) {
            this.addCriterion("skills not like", value, "skills");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsIn(List<String> values) {
            this.addCriterion("skills in", values, "skills");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsNotIn(List<String> values) {
            this.addCriterion("skills not in", values, "skills");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsBetween(String value1, String value2) {
            this.addCriterion("skills between", value1, value2, "skills");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andSkillsNotBetween(String value1, String value2) {
            this.addCriterion("skills not between", value1, value2, "skills");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andTypeIsNull() {
            this.addCriterion("`type` is null");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andTypeIsNotNull() {
            this.addCriterion("`type` is not null");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andTypeEqualTo(Integer value) {
            this.addCriterion("`type` =", value, "type");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andTypeEqualToColumn(Column column) {
            this.addCriterion("`type` = " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andTypeNotEqualTo(Integer value) {
            this.addCriterion("`type` <>", value, "type");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andTypeNotEqualToColumn(Column column) {
            this.addCriterion("`type` <> " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andTypeGreaterThan(Integer value) {
            this.addCriterion("`type` >", value, "type");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andTypeGreaterThanColumn(Column column) {
            this.addCriterion("`type` > " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andTypeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`type` >=", value, "type");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andTypeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` >= " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andTypeLessThan(Integer value) {
            this.addCriterion("`type` <", value, "type");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andTypeLessThanColumn(Column column) {
            this.addCriterion("`type` < " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andTypeLessThanOrEqualTo(Integer value) {
            this.addCriterion("`type` <=", value, "type");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andTypeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` <= " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andTypeIn(List<Integer> values) {
            this.addCriterion("`type` in", values, "type");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andTypeNotIn(List<Integer> values) {
            this.addCriterion("`type` not in", values, "type");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andTypeBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` between", value1, value2, "type");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andTypeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` not between", value1, value2, "type");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (SkillMonsterExample.Criteria)this;
        }

        public SkillMonsterExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (SkillMonsterExample.Criteria)this;
        }
    }
}
