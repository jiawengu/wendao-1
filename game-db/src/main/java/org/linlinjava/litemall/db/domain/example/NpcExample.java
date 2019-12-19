//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Npc.Column;
import org.linlinjava.litemall.db.domain.Npc.Deleted;

public class NpcExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<NpcExample.Criteria> oredCriteria = new ArrayList();

    public NpcExample() {
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

    public List<NpcExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(NpcExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public NpcExample.Criteria or() {
        NpcExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public NpcExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public NpcExample orderBy(String... orderByClauses) {
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

    public NpcExample.Criteria createCriteria() {
        NpcExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected NpcExample.Criteria createCriteriaInternal() {
        NpcExample.Criteria criteria = new NpcExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static NpcExample.Criteria newAndCreateCriteria() {
        NpcExample example = new NpcExample();
        return example.createCriteria();
    }

    public NpcExample when(boolean condition, NpcExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public NpcExample when(boolean condition, NpcExample.IExampleWhen then, NpcExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(NpcExample example);
    }

    public interface ICriteriaWhen {
        void criteria(NpcExample.Criteria criteria);
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

    public static class Criteria extends NpcExample.GeneratedCriteria {
        private NpcExample example;

        protected Criteria(NpcExample example) {
            this.example = example;
        }

        public NpcExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public NpcExample.Criteria andIf(boolean ifAdd, NpcExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public NpcExample.Criteria when(boolean condition, NpcExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public NpcExample.Criteria when(boolean condition, NpcExample.ICriteriaWhen then, NpcExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public NpcExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            NpcExample.Criteria add(NpcExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<NpcExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<NpcExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<NpcExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new NpcExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new NpcExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new NpcExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public NpcExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIconIsNull() {
            this.addCriterion("icon is null");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIconIsNotNull() {
            this.addCriterion("icon is not null");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIconEqualTo(Integer value) {
            this.addCriterion("icon =", value, "icon");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIconEqualToColumn(Column column) {
            this.addCriterion("icon = " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIconNotEqualTo(Integer value) {
            this.addCriterion("icon <>", value, "icon");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIconNotEqualToColumn(Column column) {
            this.addCriterion("icon <> " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIconGreaterThan(Integer value) {
            this.addCriterion("icon >", value, "icon");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIconGreaterThanColumn(Column column) {
            this.addCriterion("icon > " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIconGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("icon >=", value, "icon");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIconGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("icon >= " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIconLessThan(Integer value) {
            this.addCriterion("icon <", value, "icon");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIconLessThanColumn(Column column) {
            this.addCriterion("icon < " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIconLessThanOrEqualTo(Integer value) {
            this.addCriterion("icon <=", value, "icon");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIconLessThanOrEqualToColumn(Column column) {
            this.addCriterion("icon <= " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIconIn(List<Integer> values) {
            this.addCriterion("icon in", values, "icon");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIconNotIn(List<Integer> values) {
            this.addCriterion("icon not in", values, "icon");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIconBetween(Integer value1, Integer value2) {
            this.addCriterion("icon between", value1, value2, "icon");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andIconNotBetween(Integer value1, Integer value2) {
            this.addCriterion("icon not between", value1, value2, "icon");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andXIsNull() {
            this.addCriterion("x is null");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andXIsNotNull() {
            this.addCriterion("x is not null");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andXEqualTo(Integer value) {
            this.addCriterion("x =", value, "x");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andXEqualToColumn(Column column) {
            this.addCriterion("x = " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andXNotEqualTo(Integer value) {
            this.addCriterion("x <>", value, "x");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andXNotEqualToColumn(Column column) {
            this.addCriterion("x <> " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andXGreaterThan(Integer value) {
            this.addCriterion("x >", value, "x");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andXGreaterThanColumn(Column column) {
            this.addCriterion("x > " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andXGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("x >=", value, "x");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andXGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("x >= " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andXLessThan(Integer value) {
            this.addCriterion("x <", value, "x");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andXLessThanColumn(Column column) {
            this.addCriterion("x < " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andXLessThanOrEqualTo(Integer value) {
            this.addCriterion("x <=", value, "x");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andXLessThanOrEqualToColumn(Column column) {
            this.addCriterion("x <= " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andXIn(List<Integer> values) {
            this.addCriterion("x in", values, "x");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andXNotIn(List<Integer> values) {
            this.addCriterion("x not in", values, "x");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andXBetween(Integer value1, Integer value2) {
            this.addCriterion("x between", value1, value2, "x");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andXNotBetween(Integer value1, Integer value2) {
            this.addCriterion("x not between", value1, value2, "x");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andYIsNull() {
            this.addCriterion("y is null");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andYIsNotNull() {
            this.addCriterion("y is not null");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andYEqualTo(Integer value) {
            this.addCriterion("y =", value, "y");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andYEqualToColumn(Column column) {
            this.addCriterion("y = " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andYNotEqualTo(Integer value) {
            this.addCriterion("y <>", value, "y");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andYNotEqualToColumn(Column column) {
            this.addCriterion("y <> " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andYGreaterThan(Integer value) {
            this.addCriterion("y >", value, "y");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andYGreaterThanColumn(Column column) {
            this.addCriterion("y > " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andYGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("y >=", value, "y");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andYGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("y >= " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andYLessThan(Integer value) {
            this.addCriterion("y <", value, "y");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andYLessThanColumn(Column column) {
            this.addCriterion("y < " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andYLessThanOrEqualTo(Integer value) {
            this.addCriterion("y <=", value, "y");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andYLessThanOrEqualToColumn(Column column) {
            this.addCriterion("y <= " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andYIn(List<Integer> values) {
            this.addCriterion("y in", values, "y");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andYNotIn(List<Integer> values) {
            this.addCriterion("y not in", values, "y");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andYBetween(Integer value1, Integer value2) {
            this.addCriterion("y between", value1, value2, "y");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andYNotBetween(Integer value1, Integer value2) {
            this.addCriterion("y not between", value1, value2, "y");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andMapIdIsNull() {
            this.addCriterion("map_id is null");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andMapIdIsNotNull() {
            this.addCriterion("map_id is not null");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andMapIdEqualTo(Integer value) {
            this.addCriterion("map_id =", value, "mapId");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andMapIdEqualToColumn(Column column) {
            this.addCriterion("map_id = " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andMapIdNotEqualTo(Integer value) {
            this.addCriterion("map_id <>", value, "mapId");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andMapIdNotEqualToColumn(Column column) {
            this.addCriterion("map_id <> " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andMapIdGreaterThan(Integer value) {
            this.addCriterion("map_id >", value, "mapId");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andMapIdGreaterThanColumn(Column column) {
            this.addCriterion("map_id > " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andMapIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("map_id >=", value, "mapId");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andMapIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("map_id >= " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andMapIdLessThan(Integer value) {
            this.addCriterion("map_id <", value, "mapId");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andMapIdLessThanColumn(Column column) {
            this.addCriterion("map_id < " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andMapIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("map_id <=", value, "mapId");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andMapIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("map_id <= " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andMapIdIn(List<Integer> values) {
            this.addCriterion("map_id in", values, "mapId");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andMapIdNotIn(List<Integer> values) {
            this.addCriterion("map_id not in", values, "mapId");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andMapIdBetween(Integer value1, Integer value2) {
            this.addCriterion("map_id between", value1, value2, "mapId");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andMapIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("map_id not between", value1, value2, "mapId");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (NpcExample.Criteria)this;
        }

        public NpcExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (NpcExample.Criteria)this;
        }
    }
}
