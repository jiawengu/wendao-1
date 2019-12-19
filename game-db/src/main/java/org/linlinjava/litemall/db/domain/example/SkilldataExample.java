//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Skilldata.Column;
import org.linlinjava.litemall.db.domain.Skilldata.Deleted;

public class SkilldataExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<SkilldataExample.Criteria> oredCriteria = new ArrayList();

    public SkilldataExample() {
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

    public List<SkilldataExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(SkilldataExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public SkilldataExample.Criteria or() {
        SkilldataExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public SkilldataExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public SkilldataExample orderBy(String... orderByClauses) {
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

    public SkilldataExample.Criteria createCriteria() {
        SkilldataExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected SkilldataExample.Criteria createCriteriaInternal() {
        SkilldataExample.Criteria criteria = new SkilldataExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static SkilldataExample.Criteria newAndCreateCriteria() {
        SkilldataExample example = new SkilldataExample();
        return example.createCriteria();
    }

    public SkilldataExample when(boolean condition, SkilldataExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public SkilldataExample when(boolean condition, SkilldataExample.IExampleWhen then, SkilldataExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(SkilldataExample example);
    }

    public interface ICriteriaWhen {
        void criteria(SkilldataExample.Criteria criteria);
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

    public static class Criteria extends SkilldataExample.GeneratedCriteria {
        private SkilldataExample example;

        protected Criteria(SkilldataExample example) {
            this.example = example;
        }

        public SkilldataExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public SkilldataExample.Criteria andIf(boolean ifAdd, SkilldataExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public SkilldataExample.Criteria when(boolean condition, SkilldataExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public SkilldataExample.Criteria when(boolean condition, SkilldataExample.ICriteriaWhen then, SkilldataExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public SkilldataExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            SkilldataExample.Criteria add(SkilldataExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<SkilldataExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<SkilldataExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<SkilldataExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new SkilldataExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new SkilldataExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new SkilldataExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public SkilldataExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidIsNull() {
            this.addCriterion("pid is null");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidIsNotNull() {
            this.addCriterion("pid is not null");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidEqualTo(String value) {
            this.addCriterion("pid =", value, "pid");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidEqualToColumn(Column column) {
            this.addCriterion("pid = " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidNotEqualTo(String value) {
            this.addCriterion("pid <>", value, "pid");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidNotEqualToColumn(Column column) {
            this.addCriterion("pid <> " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidGreaterThan(String value) {
            this.addCriterion("pid >", value, "pid");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidGreaterThanColumn(Column column) {
            this.addCriterion("pid > " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidGreaterThanOrEqualTo(String value) {
            this.addCriterion("pid >=", value, "pid");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("pid >= " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidLessThan(String value) {
            this.addCriterion("pid <", value, "pid");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidLessThanColumn(Column column) {
            this.addCriterion("pid < " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidLessThanOrEqualTo(String value) {
            this.addCriterion("pid <=", value, "pid");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidLessThanOrEqualToColumn(Column column) {
            this.addCriterion("pid <= " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidLike(String value) {
            this.addCriterion("pid like", value, "pid");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidNotLike(String value) {
            this.addCriterion("pid not like", value, "pid");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidIn(List<String> values) {
            this.addCriterion("pid in", values, "pid");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidNotIn(List<String> values) {
            this.addCriterion("pid not in", values, "pid");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidBetween(String value1, String value2) {
            this.addCriterion("pid between", value1, value2, "pid");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andPidNotBetween(String value1, String value2) {
            this.addCriterion("pid not between", value1, value2, "pid");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameIsNull() {
            this.addCriterion("skill_name is null");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameIsNotNull() {
            this.addCriterion("skill_name is not null");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameEqualTo(String value) {
            this.addCriterion("skill_name =", value, "skillName");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameEqualToColumn(Column column) {
            this.addCriterion("skill_name = " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameNotEqualTo(String value) {
            this.addCriterion("skill_name <>", value, "skillName");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameNotEqualToColumn(Column column) {
            this.addCriterion("skill_name <> " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameGreaterThan(String value) {
            this.addCriterion("skill_name >", value, "skillName");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameGreaterThanColumn(Column column) {
            this.addCriterion("skill_name > " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("skill_name >=", value, "skillName");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_name >= " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameLessThan(String value) {
            this.addCriterion("skill_name <", value, "skillName");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameLessThanColumn(Column column) {
            this.addCriterion("skill_name < " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameLessThanOrEqualTo(String value) {
            this.addCriterion("skill_name <=", value, "skillName");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_name <= " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameLike(String value) {
            this.addCriterion("skill_name like", value, "skillName");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameNotLike(String value) {
            this.addCriterion("skill_name not like", value, "skillName");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameIn(List<String> values) {
            this.addCriterion("skill_name in", values, "skillName");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameNotIn(List<String> values) {
            this.addCriterion("skill_name not in", values, "skillName");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameBetween(String value1, String value2) {
            this.addCriterion("skill_name between", value1, value2, "skillName");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillNameNotBetween(String value1, String value2) {
            this.addCriterion("skill_name not between", value1, value2, "skillName");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillLevelIsNull() {
            this.addCriterion("skill_level is null");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillLevelIsNotNull() {
            this.addCriterion("skill_level is not null");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillLevelEqualTo(Integer value) {
            this.addCriterion("skill_level =", value, "skillLevel");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillLevelEqualToColumn(Column column) {
            this.addCriterion("skill_level = " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillLevelNotEqualTo(Integer value) {
            this.addCriterion("skill_level <>", value, "skillLevel");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillLevelNotEqualToColumn(Column column) {
            this.addCriterion("skill_level <> " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillLevelGreaterThan(Integer value) {
            this.addCriterion("skill_level >", value, "skillLevel");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillLevelGreaterThanColumn(Column column) {
            this.addCriterion("skill_level > " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillLevelGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("skill_level >=", value, "skillLevel");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillLevelGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_level >= " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillLevelLessThan(Integer value) {
            this.addCriterion("skill_level <", value, "skillLevel");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillLevelLessThanColumn(Column column) {
            this.addCriterion("skill_level < " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillLevelLessThanOrEqualTo(Integer value) {
            this.addCriterion("skill_level <=", value, "skillLevel");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillLevelLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_level <= " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillLevelIn(List<Integer> values) {
            this.addCriterion("skill_level in", values, "skillLevel");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillLevelNotIn(List<Integer> values) {
            this.addCriterion("skill_level not in", values, "skillLevel");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillLevelBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_level between", value1, value2, "skillLevel");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillLevelNotBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_level not between", value1, value2, "skillLevel");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillMubiaoIsNull() {
            this.addCriterion("skill_mubiao is null");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillMubiaoIsNotNull() {
            this.addCriterion("skill_mubiao is not null");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillMubiaoEqualTo(Integer value) {
            this.addCriterion("skill_mubiao =", value, "skillMubiao");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillMubiaoEqualToColumn(Column column) {
            this.addCriterion("skill_mubiao = " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillMubiaoNotEqualTo(Integer value) {
            this.addCriterion("skill_mubiao <>", value, "skillMubiao");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillMubiaoNotEqualToColumn(Column column) {
            this.addCriterion("skill_mubiao <> " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillMubiaoGreaterThan(Integer value) {
            this.addCriterion("skill_mubiao >", value, "skillMubiao");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillMubiaoGreaterThanColumn(Column column) {
            this.addCriterion("skill_mubiao > " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillMubiaoGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("skill_mubiao >=", value, "skillMubiao");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillMubiaoGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_mubiao >= " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillMubiaoLessThan(Integer value) {
            this.addCriterion("skill_mubiao <", value, "skillMubiao");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillMubiaoLessThanColumn(Column column) {
            this.addCriterion("skill_mubiao < " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillMubiaoLessThanOrEqualTo(Integer value) {
            this.addCriterion("skill_mubiao <=", value, "skillMubiao");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillMubiaoLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skill_mubiao <= " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillMubiaoIn(List<Integer> values) {
            this.addCriterion("skill_mubiao in", values, "skillMubiao");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillMubiaoNotIn(List<Integer> values) {
            this.addCriterion("skill_mubiao not in", values, "skillMubiao");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillMubiaoBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_mubiao between", value1, value2, "skillMubiao");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andSkillMubiaoNotBetween(Integer value1, Integer value2) {
            this.addCriterion("skill_mubiao not between", value1, value2, "skillMubiao");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (SkilldataExample.Criteria)this;
        }

        public SkilldataExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (SkilldataExample.Criteria)this;
        }
    }
}
