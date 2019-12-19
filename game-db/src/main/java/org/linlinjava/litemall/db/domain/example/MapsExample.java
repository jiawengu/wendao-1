//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Maps.Column;
import org.linlinjava.litemall.db.domain.Maps.Deleted;

public class MapsExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<MapsExample.Criteria> oredCriteria = new ArrayList();

    public MapsExample() {
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

    public List<MapsExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(MapsExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public MapsExample.Criteria or() {
        MapsExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public MapsExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public MapsExample orderBy(String... orderByClauses) {
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

    public MapsExample.Criteria createCriteria() {
        MapsExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected MapsExample.Criteria createCriteriaInternal() {
        MapsExample.Criteria criteria = new MapsExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static MapsExample.Criteria newAndCreateCriteria() {
        MapsExample example = new MapsExample();
        return example.createCriteria();
    }

    public MapsExample when(boolean condition, MapsExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public MapsExample when(boolean condition, MapsExample.IExampleWhen then, MapsExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(MapsExample example);
    }

    public interface ICriteriaWhen {
        void criteria(MapsExample.Criteria criteria);
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

    public static class Criteria extends MapsExample.GeneratedCriteria {
        private MapsExample example;

        protected Criteria(MapsExample example) {
            this.example = example;
        }

        public MapsExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public MapsExample.Criteria andIf(boolean ifAdd, MapsExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public MapsExample.Criteria when(boolean condition, MapsExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public MapsExample.Criteria when(boolean condition, MapsExample.ICriteriaWhen then, MapsExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public MapsExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            MapsExample.Criteria add(MapsExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<MapsExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<MapsExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<MapsExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new MapsExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new MapsExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new MapsExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public MapsExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andTypeIsNull() {
            this.addCriterion("`type` is null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andTypeIsNotNull() {
            this.addCriterion("`type` is not null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andTypeEqualTo(Integer value) {
            this.addCriterion("`type` =", value, "type");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andTypeEqualToColumn(Column column) {
            this.addCriterion("`type` = " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andTypeNotEqualTo(Integer value) {
            this.addCriterion("`type` <>", value, "type");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andTypeNotEqualToColumn(Column column) {
            this.addCriterion("`type` <> " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andTypeGreaterThan(Integer value) {
            this.addCriterion("`type` >", value, "type");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andTypeGreaterThanColumn(Column column) {
            this.addCriterion("`type` > " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andTypeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`type` >=", value, "type");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andTypeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` >= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andTypeLessThan(Integer value) {
            this.addCriterion("`type` <", value, "type");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andTypeLessThanColumn(Column column) {
            this.addCriterion("`type` < " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andTypeLessThanOrEqualTo(Integer value) {
            this.addCriterion("`type` <=", value, "type");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andTypeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` <= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andTypeIn(List<Integer> values) {
            this.addCriterion("`type` in", values, "type");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andTypeNotIn(List<Integer> values) {
            this.addCriterion("`type` not in", values, "type");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andTypeBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` between", value1, value2, "type");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andTypeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` not between", value1, value2, "type");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andMapIsNull() {
            this.addCriterion("`map` is null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andMapIsNotNull() {
            this.addCriterion("`map` is not null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andMapEqualTo(Integer value) {
            this.addCriterion("`map` =", value, "map");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andMapEqualToColumn(Column column) {
            this.addCriterion("`map` = " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andMapNotEqualTo(Integer value) {
            this.addCriterion("`map` <>", value, "map");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andMapNotEqualToColumn(Column column) {
            this.addCriterion("`map` <> " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andMapGreaterThan(Integer value) {
            this.addCriterion("`map` >", value, "map");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andMapGreaterThanColumn(Column column) {
            this.addCriterion("`map` > " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andMapGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`map` >=", value, "map");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andMapGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`map` >= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andMapLessThan(Integer value) {
            this.addCriterion("`map` <", value, "map");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andMapLessThanColumn(Column column) {
            this.addCriterion("`map` < " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andMapLessThanOrEqualTo(Integer value) {
            this.addCriterion("`map` <=", value, "map");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andMapLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`map` <= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andMapIn(List<Integer> values) {
            this.addCriterion("`map` in", values, "map");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andMapNotIn(List<Integer> values) {
            this.addCriterion("`map` not in", values, "map");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andMapBetween(Integer value1, Integer value2) {
            this.addCriterion("`map` between", value1, value2, "map");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andMapNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`map` not between", value1, value2, "map");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDirIsNull() {
            this.addCriterion("dir is null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDirIsNotNull() {
            this.addCriterion("dir is not null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDirEqualTo(Float value) {
            this.addCriterion("dir =", value, "dir");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDirEqualToColumn(Column column) {
            this.addCriterion("dir = " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDirNotEqualTo(Float value) {
            this.addCriterion("dir <>", value, "dir");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDirNotEqualToColumn(Column column) {
            this.addCriterion("dir <> " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDirGreaterThan(Float value) {
            this.addCriterion("dir >", value, "dir");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDirGreaterThanColumn(Column column) {
            this.addCriterion("dir > " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDirGreaterThanOrEqualTo(Float value) {
            this.addCriterion("dir >=", value, "dir");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDirGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("dir >= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDirLessThan(Float value) {
            this.addCriterion("dir <", value, "dir");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDirLessThanColumn(Column column) {
            this.addCriterion("dir < " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDirLessThanOrEqualTo(Float value) {
            this.addCriterion("dir <=", value, "dir");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDirLessThanOrEqualToColumn(Column column) {
            this.addCriterion("dir <= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDirIn(List<Float> values) {
            this.addCriterion("dir in", values, "dir");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDirNotIn(List<Float> values) {
            this.addCriterion("dir not in", values, "dir");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDirBetween(Float value1, Float value2) {
            this.addCriterion("dir between", value1, value2, "dir");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDirNotBetween(Float value1, Float value2) {
            this.addCriterion("dir not between", value1, value2, "dir");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andXIsNull() {
            this.addCriterion("x is null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andXIsNotNull() {
            this.addCriterion("x is not null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andXEqualTo(Float value) {
            this.addCriterion("x =", value, "x");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andXEqualToColumn(Column column) {
            this.addCriterion("x = " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andXNotEqualTo(Float value) {
            this.addCriterion("x <>", value, "x");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andXNotEqualToColumn(Column column) {
            this.addCriterion("x <> " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andXGreaterThan(Float value) {
            this.addCriterion("x >", value, "x");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andXGreaterThanColumn(Column column) {
            this.addCriterion("x > " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andXGreaterThanOrEqualTo(Float value) {
            this.addCriterion("x >=", value, "x");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andXGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("x >= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andXLessThan(Float value) {
            this.addCriterion("x <", value, "x");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andXLessThanColumn(Column column) {
            this.addCriterion("x < " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andXLessThanOrEqualTo(Float value) {
            this.addCriterion("x <=", value, "x");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andXLessThanOrEqualToColumn(Column column) {
            this.addCriterion("x <= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andXIn(List<Float> values) {
            this.addCriterion("x in", values, "x");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andXNotIn(List<Float> values) {
            this.addCriterion("x not in", values, "x");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andXBetween(Float value1, Float value2) {
            this.addCriterion("x between", value1, value2, "x");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andXNotBetween(Float value1, Float value2) {
            this.addCriterion("x not between", value1, value2, "x");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andYIsNull() {
            this.addCriterion("y is null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andYIsNotNull() {
            this.addCriterion("y is not null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andYEqualTo(Float value) {
            this.addCriterion("y =", value, "y");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andYEqualToColumn(Column column) {
            this.addCriterion("y = " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andYNotEqualTo(Float value) {
            this.addCriterion("y <>", value, "y");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andYNotEqualToColumn(Column column) {
            this.addCriterion("y <> " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andYGreaterThan(Float value) {
            this.addCriterion("y >", value, "y");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andYGreaterThanColumn(Column column) {
            this.addCriterion("y > " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andYGreaterThanOrEqualTo(Float value) {
            this.addCriterion("y >=", value, "y");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andYGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("y >= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andYLessThan(Float value) {
            this.addCriterion("y <", value, "y");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andYLessThanColumn(Column column) {
            this.addCriterion("y < " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andYLessThanOrEqualTo(Float value) {
            this.addCriterion("y <=", value, "y");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andYLessThanOrEqualToColumn(Column column) {
            this.addCriterion("y <= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andYIn(List<Float> values) {
            this.addCriterion("y in", values, "y");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andYNotIn(List<Float> values) {
            this.addCriterion("y not in", values, "y");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andYBetween(Float value1, Float value2) {
            this.addCriterion("y between", value1, value2, "y");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andYNotBetween(Float value1, Float value2) {
            this.addCriterion("y not between", value1, value2, "y");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (MapsExample.Criteria)this;
        }

        public MapsExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (MapsExample.Criteria)this;
        }
    }
}
