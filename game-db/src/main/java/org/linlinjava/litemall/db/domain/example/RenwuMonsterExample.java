//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.RenwuMonster.Column;
import org.linlinjava.litemall.db.domain.RenwuMonster.Deleted;

public class RenwuMonsterExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<RenwuMonsterExample.Criteria> oredCriteria = new ArrayList();

    public RenwuMonsterExample() {
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

    public List<RenwuMonsterExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(RenwuMonsterExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public RenwuMonsterExample.Criteria or() {
        RenwuMonsterExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public RenwuMonsterExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public RenwuMonsterExample orderBy(String... orderByClauses) {
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

    public RenwuMonsterExample.Criteria createCriteria() {
        RenwuMonsterExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected RenwuMonsterExample.Criteria createCriteriaInternal() {
        RenwuMonsterExample.Criteria criteria = new RenwuMonsterExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static RenwuMonsterExample.Criteria newAndCreateCriteria() {
        RenwuMonsterExample example = new RenwuMonsterExample();
        return example.createCriteria();
    }

    public RenwuMonsterExample when(boolean condition, RenwuMonsterExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public RenwuMonsterExample when(boolean condition, RenwuMonsterExample.IExampleWhen then, RenwuMonsterExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(RenwuMonsterExample example);
    }

    public interface ICriteriaWhen {
        void criteria(RenwuMonsterExample.Criteria criteria);
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

    public static class Criteria extends RenwuMonsterExample.GeneratedCriteria {
        private RenwuMonsterExample example;

        protected Criteria(RenwuMonsterExample example) {
            this.example = example;
        }

        public RenwuMonsterExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public RenwuMonsterExample.Criteria andIf(boolean ifAdd, RenwuMonsterExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public RenwuMonsterExample.Criteria when(boolean condition, RenwuMonsterExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public RenwuMonsterExample.Criteria when(boolean condition, RenwuMonsterExample.ICriteriaWhen then, RenwuMonsterExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public RenwuMonsterExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            RenwuMonsterExample.Criteria add(RenwuMonsterExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<RenwuMonsterExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<RenwuMonsterExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<RenwuMonsterExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new RenwuMonsterExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new RenwuMonsterExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new RenwuMonsterExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public RenwuMonsterExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameIsNull() {
            this.addCriterion("map_name is null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameIsNotNull() {
            this.addCriterion("map_name is not null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameEqualTo(String value) {
            this.addCriterion("map_name =", value, "mapName");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameEqualToColumn(Column column) {
            this.addCriterion("map_name = " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameNotEqualTo(String value) {
            this.addCriterion("map_name <>", value, "mapName");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameNotEqualToColumn(Column column) {
            this.addCriterion("map_name <> " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameGreaterThan(String value) {
            this.addCriterion("map_name >", value, "mapName");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameGreaterThanColumn(Column column) {
            this.addCriterion("map_name > " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("map_name >=", value, "mapName");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("map_name >= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameLessThan(String value) {
            this.addCriterion("map_name <", value, "mapName");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameLessThanColumn(Column column) {
            this.addCriterion("map_name < " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameLessThanOrEqualTo(String value) {
            this.addCriterion("map_name <=", value, "mapName");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("map_name <= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameLike(String value) {
            this.addCriterion("map_name like", value, "mapName");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameNotLike(String value) {
            this.addCriterion("map_name not like", value, "mapName");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameIn(List<String> values) {
            this.addCriterion("map_name in", values, "mapName");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameNotIn(List<String> values) {
            this.addCriterion("map_name not in", values, "mapName");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameBetween(String value1, String value2) {
            this.addCriterion("map_name between", value1, value2, "mapName");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andMapNameNotBetween(String value1, String value2) {
            this.addCriterion("map_name not between", value1, value2, "mapName");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andXIsNull() {
            this.addCriterion("x is null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andXIsNotNull() {
            this.addCriterion("x is not null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andXEqualTo(Integer value) {
            this.addCriterion("x =", value, "x");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andXEqualToColumn(Column column) {
            this.addCriterion("x = " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andXNotEqualTo(Integer value) {
            this.addCriterion("x <>", value, "x");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andXNotEqualToColumn(Column column) {
            this.addCriterion("x <> " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andXGreaterThan(Integer value) {
            this.addCriterion("x >", value, "x");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andXGreaterThanColumn(Column column) {
            this.addCriterion("x > " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andXGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("x >=", value, "x");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andXGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("x >= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andXLessThan(Integer value) {
            this.addCriterion("x <", value, "x");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andXLessThanColumn(Column column) {
            this.addCriterion("x < " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andXLessThanOrEqualTo(Integer value) {
            this.addCriterion("x <=", value, "x");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andXLessThanOrEqualToColumn(Column column) {
            this.addCriterion("x <= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andXIn(List<Integer> values) {
            this.addCriterion("x in", values, "x");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andXNotIn(List<Integer> values) {
            this.addCriterion("x not in", values, "x");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andXBetween(Integer value1, Integer value2) {
            this.addCriterion("x between", value1, value2, "x");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andXNotBetween(Integer value1, Integer value2) {
            this.addCriterion("x not between", value1, value2, "x");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andYIsNull() {
            this.addCriterion("y is null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andYIsNotNull() {
            this.addCriterion("y is not null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andYEqualTo(Integer value) {
            this.addCriterion("y =", value, "y");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andYEqualToColumn(Column column) {
            this.addCriterion("y = " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andYNotEqualTo(Integer value) {
            this.addCriterion("y <>", value, "y");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andYNotEqualToColumn(Column column) {
            this.addCriterion("y <> " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andYGreaterThan(Integer value) {
            this.addCriterion("y >", value, "y");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andYGreaterThanColumn(Column column) {
            this.addCriterion("y > " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andYGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("y >=", value, "y");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andYGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("y >= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andYLessThan(Integer value) {
            this.addCriterion("y <", value, "y");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andYLessThanColumn(Column column) {
            this.addCriterion("y < " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andYLessThanOrEqualTo(Integer value) {
            this.addCriterion("y <=", value, "y");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andYLessThanOrEqualToColumn(Column column) {
            this.addCriterion("y <= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andYIn(List<Integer> values) {
            this.addCriterion("y in", values, "y");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andYNotIn(List<Integer> values) {
            this.addCriterion("y not in", values, "y");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andYBetween(Integer value1, Integer value2) {
            this.addCriterion("y between", value1, value2, "y");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andYNotBetween(Integer value1, Integer value2) {
            this.addCriterion("y not between", value1, value2, "y");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIconIsNull() {
            this.addCriterion("icon is null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIconIsNotNull() {
            this.addCriterion("icon is not null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIconEqualTo(Integer value) {
            this.addCriterion("icon =", value, "icon");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIconEqualToColumn(Column column) {
            this.addCriterion("icon = " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIconNotEqualTo(Integer value) {
            this.addCriterion("icon <>", value, "icon");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIconNotEqualToColumn(Column column) {
            this.addCriterion("icon <> " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIconGreaterThan(Integer value) {
            this.addCriterion("icon >", value, "icon");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIconGreaterThanColumn(Column column) {
            this.addCriterion("icon > " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIconGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("icon >=", value, "icon");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIconGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("icon >= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIconLessThan(Integer value) {
            this.addCriterion("icon <", value, "icon");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIconLessThanColumn(Column column) {
            this.addCriterion("icon < " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIconLessThanOrEqualTo(Integer value) {
            this.addCriterion("icon <=", value, "icon");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIconLessThanOrEqualToColumn(Column column) {
            this.addCriterion("icon <= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIconIn(List<Integer> values) {
            this.addCriterion("icon in", values, "icon");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIconNotIn(List<Integer> values) {
            this.addCriterion("icon not in", values, "icon");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIconBetween(Integer value1, Integer value2) {
            this.addCriterion("icon between", value1, value2, "icon");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andIconNotBetween(Integer value1, Integer value2) {
            this.addCriterion("icon not between", value1, value2, "icon");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsIsNull() {
            this.addCriterion("skills is null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsIsNotNull() {
            this.addCriterion("skills is not null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsEqualTo(String value) {
            this.addCriterion("skills =", value, "skills");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsEqualToColumn(Column column) {
            this.addCriterion("skills = " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsNotEqualTo(String value) {
            this.addCriterion("skills <>", value, "skills");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsNotEqualToColumn(Column column) {
            this.addCriterion("skills <> " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsGreaterThan(String value) {
            this.addCriterion("skills >", value, "skills");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsGreaterThanColumn(Column column) {
            this.addCriterion("skills > " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsGreaterThanOrEqualTo(String value) {
            this.addCriterion("skills >=", value, "skills");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("skills >= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsLessThan(String value) {
            this.addCriterion("skills <", value, "skills");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsLessThanColumn(Column column) {
            this.addCriterion("skills < " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsLessThanOrEqualTo(String value) {
            this.addCriterion("skills <=", value, "skills");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsLessThanOrEqualToColumn(Column column) {
            this.addCriterion("skills <= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsLike(String value) {
            this.addCriterion("skills like", value, "skills");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsNotLike(String value) {
            this.addCriterion("skills not like", value, "skills");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsIn(List<String> values) {
            this.addCriterion("skills in", values, "skills");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsNotIn(List<String> values) {
            this.addCriterion("skills not in", values, "skills");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsBetween(String value1, String value2) {
            this.addCriterion("skills between", value1, value2, "skills");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andSkillsNotBetween(String value1, String value2) {
            this.addCriterion("skills not between", value1, value2, "skills");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andTypeIsNull() {
            this.addCriterion("`type` is null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andTypeIsNotNull() {
            this.addCriterion("`type` is not null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andTypeEqualTo(Integer value) {
            this.addCriterion("`type` =", value, "type");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andTypeEqualToColumn(Column column) {
            this.addCriterion("`type` = " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andTypeNotEqualTo(Integer value) {
            this.addCriterion("`type` <>", value, "type");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andTypeNotEqualToColumn(Column column) {
            this.addCriterion("`type` <> " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andTypeGreaterThan(Integer value) {
            this.addCriterion("`type` >", value, "type");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andTypeGreaterThanColumn(Column column) {
            this.addCriterion("`type` > " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andTypeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`type` >=", value, "type");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andTypeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` >= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andTypeLessThan(Integer value) {
            this.addCriterion("`type` <", value, "type");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andTypeLessThanColumn(Column column) {
            this.addCriterion("`type` < " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andTypeLessThanOrEqualTo(Integer value) {
            this.addCriterion("`type` <=", value, "type");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andTypeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` <= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andTypeIn(List<Integer> values) {
            this.addCriterion("`type` in", values, "type");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andTypeNotIn(List<Integer> values) {
            this.addCriterion("`type` not in", values, "type");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andTypeBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` between", value1, value2, "type");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andTypeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` not between", value1, value2, "type");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (RenwuMonsterExample.Criteria)this;
        }

        public RenwuMonsterExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (RenwuMonsterExample.Criteria)this;
        }
    }
}
