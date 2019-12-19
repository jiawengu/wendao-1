//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Map.Column;
import org.linlinjava.litemall.db.domain.Map.Deleted;

public class MapExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<MapExample.Criteria> oredCriteria = new ArrayList();

    public MapExample() {
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

    public List<MapExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(MapExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public MapExample.Criteria or() {
        MapExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public MapExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public MapExample orderBy(String... orderByClauses) {
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

    public MapExample.Criteria createCriteria() {
        MapExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected MapExample.Criteria createCriteriaInternal() {
        MapExample.Criteria criteria = new MapExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static MapExample.Criteria newAndCreateCriteria() {
        MapExample example = new MapExample();
        return example.createCriteria();
    }

    public MapExample when(boolean condition, MapExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public MapExample when(boolean condition, MapExample.IExampleWhen then, MapExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(MapExample example);
    }

    public interface ICriteriaWhen {
        void criteria(MapExample.Criteria criteria);
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

    public static class Criteria extends MapExample.GeneratedCriteria {
        private MapExample example;

        protected Criteria(MapExample example) {
            this.example = example;
        }

        public MapExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public MapExample.Criteria andIf(boolean ifAdd, MapExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public MapExample.Criteria when(boolean condition, MapExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public MapExample.Criteria when(boolean condition, MapExample.ICriteriaWhen then, MapExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public MapExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            MapExample.Criteria add(MapExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<MapExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<MapExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<MapExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new MapExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new MapExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new MapExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public MapExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMapIdIsNull() {
            this.addCriterion("map_id is null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMapIdIsNotNull() {
            this.addCriterion("map_id is not null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMapIdEqualTo(Integer value) {
            this.addCriterion("map_id =", value, "mapId");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMapIdEqualToColumn(Column column) {
            this.addCriterion("map_id = " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMapIdNotEqualTo(Integer value) {
            this.addCriterion("map_id <>", value, "mapId");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMapIdNotEqualToColumn(Column column) {
            this.addCriterion("map_id <> " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMapIdGreaterThan(Integer value) {
            this.addCriterion("map_id >", value, "mapId");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMapIdGreaterThanColumn(Column column) {
            this.addCriterion("map_id > " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMapIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("map_id >=", value, "mapId");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMapIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("map_id >= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMapIdLessThan(Integer value) {
            this.addCriterion("map_id <", value, "mapId");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMapIdLessThanColumn(Column column) {
            this.addCriterion("map_id < " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMapIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("map_id <=", value, "mapId");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMapIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("map_id <= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMapIdIn(List<Integer> values) {
            this.addCriterion("map_id in", values, "mapId");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMapIdNotIn(List<Integer> values) {
            this.addCriterion("map_id not in", values, "mapId");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMapIdBetween(Integer value1, Integer value2) {
            this.addCriterion("map_id between", value1, value2, "mapId");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMapIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("map_id not between", value1, value2, "mapId");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andXIsNull() {
            this.addCriterion("x is null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andXIsNotNull() {
            this.addCriterion("x is not null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andXEqualTo(Integer value) {
            this.addCriterion("x =", value, "x");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andXEqualToColumn(Column column) {
            this.addCriterion("x = " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andXNotEqualTo(Integer value) {
            this.addCriterion("x <>", value, "x");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andXNotEqualToColumn(Column column) {
            this.addCriterion("x <> " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andXGreaterThan(Integer value) {
            this.addCriterion("x >", value, "x");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andXGreaterThanColumn(Column column) {
            this.addCriterion("x > " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andXGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("x >=", value, "x");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andXGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("x >= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andXLessThan(Integer value) {
            this.addCriterion("x <", value, "x");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andXLessThanColumn(Column column) {
            this.addCriterion("x < " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andXLessThanOrEqualTo(Integer value) {
            this.addCriterion("x <=", value, "x");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andXLessThanOrEqualToColumn(Column column) {
            this.addCriterion("x <= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andXIn(List<Integer> values) {
            this.addCriterion("x in", values, "x");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andXNotIn(List<Integer> values) {
            this.addCriterion("x not in", values, "x");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andXBetween(Integer value1, Integer value2) {
            this.addCriterion("x between", value1, value2, "x");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andXNotBetween(Integer value1, Integer value2) {
            this.addCriterion("x not between", value1, value2, "x");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andYIsNull() {
            this.addCriterion("y is null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andYIsNotNull() {
            this.addCriterion("y is not null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andYEqualTo(Integer value) {
            this.addCriterion("y =", value, "y");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andYEqualToColumn(Column column) {
            this.addCriterion("y = " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andYNotEqualTo(Integer value) {
            this.addCriterion("y <>", value, "y");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andYNotEqualToColumn(Column column) {
            this.addCriterion("y <> " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andYGreaterThan(Integer value) {
            this.addCriterion("y >", value, "y");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andYGreaterThanColumn(Column column) {
            this.addCriterion("y > " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andYGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("y >=", value, "y");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andYGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("y >= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andYLessThan(Integer value) {
            this.addCriterion("y <", value, "y");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andYLessThanColumn(Column column) {
            this.addCriterion("y < " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andYLessThanOrEqualTo(Integer value) {
            this.addCriterion("y <=", value, "y");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andYLessThanOrEqualToColumn(Column column) {
            this.addCriterion("y <= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andYIn(List<Integer> values) {
            this.addCriterion("y in", values, "y");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andYNotIn(List<Integer> values) {
            this.addCriterion("y not in", values, "y");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andYBetween(Integer value1, Integer value2) {
            this.addCriterion("y between", value1, value2, "y");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andYNotBetween(Integer value1, Integer value2) {
            this.addCriterion("y not between", value1, value2, "y");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconIsNull() {
            this.addCriterion("icon is null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconIsNotNull() {
            this.addCriterion("icon is not null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconEqualTo(String value) {
            this.addCriterion("icon =", value, "icon");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconEqualToColumn(Column column) {
            this.addCriterion("icon = " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconNotEqualTo(String value) {
            this.addCriterion("icon <>", value, "icon");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconNotEqualToColumn(Column column) {
            this.addCriterion("icon <> " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconGreaterThan(String value) {
            this.addCriterion("icon >", value, "icon");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconGreaterThanColumn(Column column) {
            this.addCriterion("icon > " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconGreaterThanOrEqualTo(String value) {
            this.addCriterion("icon >=", value, "icon");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("icon >= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconLessThan(String value) {
            this.addCriterion("icon <", value, "icon");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconLessThanColumn(Column column) {
            this.addCriterion("icon < " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconLessThanOrEqualTo(String value) {
            this.addCriterion("icon <=", value, "icon");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconLessThanOrEqualToColumn(Column column) {
            this.addCriterion("icon <= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconLike(String value) {
            this.addCriterion("icon like", value, "icon");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconNotLike(String value) {
            this.addCriterion("icon not like", value, "icon");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconIn(List<String> values) {
            this.addCriterion("icon in", values, "icon");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconNotIn(List<String> values) {
            this.addCriterion("icon not in", values, "icon");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconBetween(String value1, String value2) {
            this.addCriterion("icon between", value1, value2, "icon");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andIconNotBetween(String value1, String value2) {
            this.addCriterion("icon not between", value1, value2, "icon");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMonsterLevelIsNull() {
            this.addCriterion("monster_level is null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMonsterLevelIsNotNull() {
            this.addCriterion("monster_level is not null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMonsterLevelEqualTo(Integer value) {
            this.addCriterion("monster_level =", value, "monsterLevel");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMonsterLevelEqualToColumn(Column column) {
            this.addCriterion("monster_level = " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMonsterLevelNotEqualTo(Integer value) {
            this.addCriterion("monster_level <>", value, "monsterLevel");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMonsterLevelNotEqualToColumn(Column column) {
            this.addCriterion("monster_level <> " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMonsterLevelGreaterThan(Integer value) {
            this.addCriterion("monster_level >", value, "monsterLevel");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMonsterLevelGreaterThanColumn(Column column) {
            this.addCriterion("monster_level > " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMonsterLevelGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("monster_level >=", value, "monsterLevel");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMonsterLevelGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("monster_level >= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMonsterLevelLessThan(Integer value) {
            this.addCriterion("monster_level <", value, "monsterLevel");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMonsterLevelLessThanColumn(Column column) {
            this.addCriterion("monster_level < " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMonsterLevelLessThanOrEqualTo(Integer value) {
            this.addCriterion("monster_level <=", value, "monsterLevel");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMonsterLevelLessThanOrEqualToColumn(Column column) {
            this.addCriterion("monster_level <= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMonsterLevelIn(List<Integer> values) {
            this.addCriterion("monster_level in", values, "monsterLevel");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMonsterLevelNotIn(List<Integer> values) {
            this.addCriterion("monster_level not in", values, "monsterLevel");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMonsterLevelBetween(Integer value1, Integer value2) {
            this.addCriterion("monster_level between", value1, value2, "monsterLevel");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andMonsterLevelNotBetween(Integer value1, Integer value2) {
            this.addCriterion("monster_level not between", value1, value2, "monsterLevel");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (MapExample.Criteria)this;
        }

        public MapExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (MapExample.Criteria)this;
        }
    }
}
