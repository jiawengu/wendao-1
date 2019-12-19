//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Choujiang.Column;
import org.linlinjava.litemall.db.domain.Choujiang.Deleted;

public class ChoujiangExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<ChoujiangExample.Criteria> oredCriteria = new ArrayList();

    public ChoujiangExample() {
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

    public List<ChoujiangExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(ChoujiangExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public ChoujiangExample.Criteria or() {
        ChoujiangExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public ChoujiangExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public ChoujiangExample orderBy(String... orderByClauses) {
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

    public ChoujiangExample.Criteria createCriteria() {
        ChoujiangExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected ChoujiangExample.Criteria createCriteriaInternal() {
        ChoujiangExample.Criteria criteria = new ChoujiangExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static ChoujiangExample.Criteria newAndCreateCriteria() {
        ChoujiangExample example = new ChoujiangExample();
        return example.createCriteria();
    }

    public ChoujiangExample when(boolean condition, ChoujiangExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public ChoujiangExample when(boolean condition, ChoujiangExample.IExampleWhen then, ChoujiangExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(ChoujiangExample example);
    }

    public interface ICriteriaWhen {
        void criteria(ChoujiangExample.Criteria criteria);
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

    public static class Criteria extends ChoujiangExample.GeneratedCriteria {
        private ChoujiangExample example;

        protected Criteria(ChoujiangExample example) {
            this.example = example;
        }

        public ChoujiangExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public ChoujiangExample.Criteria andIf(boolean ifAdd, ChoujiangExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public ChoujiangExample.Criteria when(boolean condition, ChoujiangExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public ChoujiangExample.Criteria when(boolean condition, ChoujiangExample.ICriteriaWhen then, ChoujiangExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public ChoujiangExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            ChoujiangExample.Criteria add(ChoujiangExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<ChoujiangExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<ChoujiangExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<ChoujiangExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new ChoujiangExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new ChoujiangExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new ChoujiangExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public ChoujiangExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNoIsNull() {
            this.addCriterion("`no` is null");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNoIsNotNull() {
            this.addCriterion("`no` is not null");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNoEqualTo(Integer value) {
            this.addCriterion("`no` =", value, "no");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNoEqualToColumn(Column column) {
            this.addCriterion("`no` = " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNoNotEqualTo(Integer value) {
            this.addCriterion("`no` <>", value, "no");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNoNotEqualToColumn(Column column) {
            this.addCriterion("`no` <> " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNoGreaterThan(Integer value) {
            this.addCriterion("`no` >", value, "no");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNoGreaterThanColumn(Column column) {
            this.addCriterion("`no` > " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNoGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`no` >=", value, "no");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNoGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`no` >= " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNoLessThan(Integer value) {
            this.addCriterion("`no` <", value, "no");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNoLessThanColumn(Column column) {
            this.addCriterion("`no` < " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNoLessThanOrEqualTo(Integer value) {
            this.addCriterion("`no` <=", value, "no");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNoLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`no` <= " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNoIn(List<Integer> values) {
            this.addCriterion("`no` in", values, "no");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNoNotIn(List<Integer> values) {
            this.addCriterion("`no` not in", values, "no");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNoBetween(Integer value1, Integer value2) {
            this.addCriterion("`no` between", value1, value2, "no");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNoNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`no` not between", value1, value2, "no");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescIsNull() {
            this.addCriterion("`desc` is null");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescIsNotNull() {
            this.addCriterion("`desc` is not null");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescEqualTo(String value) {
            this.addCriterion("`desc` =", value, "desc");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescEqualToColumn(Column column) {
            this.addCriterion("`desc` = " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescNotEqualTo(String value) {
            this.addCriterion("`desc` <>", value, "desc");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescNotEqualToColumn(Column column) {
            this.addCriterion("`desc` <> " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescGreaterThan(String value) {
            this.addCriterion("`desc` >", value, "desc");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescGreaterThanColumn(Column column) {
            this.addCriterion("`desc` > " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescGreaterThanOrEqualTo(String value) {
            this.addCriterion("`desc` >=", value, "desc");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`desc` >= " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescLessThan(String value) {
            this.addCriterion("`desc` <", value, "desc");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescLessThanColumn(Column column) {
            this.addCriterion("`desc` < " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescLessThanOrEqualTo(String value) {
            this.addCriterion("`desc` <=", value, "desc");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`desc` <= " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescLike(String value) {
            this.addCriterion("`desc` like", value, "desc");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescNotLike(String value) {
            this.addCriterion("`desc` not like", value, "desc");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescIn(List<String> values) {
            this.addCriterion("`desc` in", values, "desc");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescNotIn(List<String> values) {
            this.addCriterion("`desc` not in", values, "desc");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescBetween(String value1, String value2) {
            this.addCriterion("`desc` between", value1, value2, "desc");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDescNotBetween(String value1, String value2) {
            this.addCriterion("`desc` not between", value1, value2, "desc");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andLevelIsNull() {
            this.addCriterion("`level` is null");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andLevelIsNotNull() {
            this.addCriterion("`level` is not null");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andLevelEqualTo(Integer value) {
            this.addCriterion("`level` =", value, "level");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andLevelEqualToColumn(Column column) {
            this.addCriterion("`level` = " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andLevelNotEqualTo(Integer value) {
            this.addCriterion("`level` <>", value, "level");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andLevelNotEqualToColumn(Column column) {
            this.addCriterion("`level` <> " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andLevelGreaterThan(Integer value) {
            this.addCriterion("`level` >", value, "level");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andLevelGreaterThanColumn(Column column) {
            this.addCriterion("`level` > " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andLevelGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`level` >=", value, "level");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andLevelGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`level` >= " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andLevelLessThan(Integer value) {
            this.addCriterion("`level` <", value, "level");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andLevelLessThanColumn(Column column) {
            this.addCriterion("`level` < " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andLevelLessThanOrEqualTo(Integer value) {
            this.addCriterion("`level` <=", value, "level");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andLevelLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`level` <= " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andLevelIn(List<Integer> values) {
            this.addCriterion("`level` in", values, "level");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andLevelNotIn(List<Integer> values) {
            this.addCriterion("`level` not in", values, "level");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andLevelBetween(Integer value1, Integer value2) {
            this.addCriterion("`level` between", value1, value2, "level");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andLevelNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`level` not between", value1, value2, "level");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (ChoujiangExample.Criteria)this;
        }

        public ChoujiangExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (ChoujiangExample.Criteria)this;
        }
    }
}
