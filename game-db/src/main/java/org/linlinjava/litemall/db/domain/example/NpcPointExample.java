//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.NpcPoint.Column;
import org.linlinjava.litemall.db.domain.NpcPoint.Deleted;

public class NpcPointExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<NpcPointExample.Criteria> oredCriteria = new ArrayList();

    public NpcPointExample() {
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

    public List<NpcPointExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(NpcPointExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public NpcPointExample.Criteria or() {
        NpcPointExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public NpcPointExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public NpcPointExample orderBy(String... orderByClauses) {
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

    public NpcPointExample.Criteria createCriteria() {
        NpcPointExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected NpcPointExample.Criteria createCriteriaInternal() {
        NpcPointExample.Criteria criteria = new NpcPointExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static NpcPointExample.Criteria newAndCreateCriteria() {
        NpcPointExample example = new NpcPointExample();
        return example.createCriteria();
    }

    public NpcPointExample when(boolean condition, NpcPointExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public NpcPointExample when(boolean condition, NpcPointExample.IExampleWhen then, NpcPointExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(NpcPointExample example);
    }

    public interface ICriteriaWhen {
        void criteria(NpcPointExample.Criteria criteria);
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

    public static class Criteria extends NpcPointExample.GeneratedCriteria {
        private NpcPointExample example;

        protected Criteria(NpcPointExample example) {
            this.example = example;
        }

        public NpcPointExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public NpcPointExample.Criteria andIf(boolean ifAdd, NpcPointExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public NpcPointExample.Criteria when(boolean condition, NpcPointExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public NpcPointExample.Criteria when(boolean condition, NpcPointExample.ICriteriaWhen then, NpcPointExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public NpcPointExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            NpcPointExample.Criteria add(NpcPointExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<NpcPointExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<NpcPointExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<NpcPointExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new NpcPointExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new NpcPointExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new NpcPointExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public NpcPointExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameIsNull() {
            this.addCriterion("mapname is null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameIsNotNull() {
            this.addCriterion("mapname is not null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameEqualTo(String value) {
            this.addCriterion("mapname =", value, "mapname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameEqualToColumn(Column column) {
            this.addCriterion("mapname = " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameNotEqualTo(String value) {
            this.addCriterion("mapname <>", value, "mapname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameNotEqualToColumn(Column column) {
            this.addCriterion("mapname <> " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameGreaterThan(String value) {
            this.addCriterion("mapname >", value, "mapname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameGreaterThanColumn(Column column) {
            this.addCriterion("mapname > " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameGreaterThanOrEqualTo(String value) {
            this.addCriterion("mapname >=", value, "mapname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("mapname >= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameLessThan(String value) {
            this.addCriterion("mapname <", value, "mapname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameLessThanColumn(Column column) {
            this.addCriterion("mapname < " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameLessThanOrEqualTo(String value) {
            this.addCriterion("mapname <=", value, "mapname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("mapname <= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameLike(String value) {
            this.addCriterion("mapname like", value, "mapname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameNotLike(String value) {
            this.addCriterion("mapname not like", value, "mapname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameIn(List<String> values) {
            this.addCriterion("mapname in", values, "mapname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameNotIn(List<String> values) {
            this.addCriterion("mapname not in", values, "mapname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameBetween(String value1, String value2) {
            this.addCriterion("mapname between", value1, value2, "mapname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andMapnameNotBetween(String value1, String value2) {
            this.addCriterion("mapname not between", value1, value2, "mapname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameIsNull() {
            this.addCriterion("doorname is null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameIsNotNull() {
            this.addCriterion("doorname is not null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameEqualTo(String value) {
            this.addCriterion("doorname =", value, "doorname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameEqualToColumn(Column column) {
            this.addCriterion("doorname = " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameNotEqualTo(String value) {
            this.addCriterion("doorname <>", value, "doorname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameNotEqualToColumn(Column column) {
            this.addCriterion("doorname <> " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameGreaterThan(String value) {
            this.addCriterion("doorname >", value, "doorname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameGreaterThanColumn(Column column) {
            this.addCriterion("doorname > " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameGreaterThanOrEqualTo(String value) {
            this.addCriterion("doorname >=", value, "doorname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("doorname >= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameLessThan(String value) {
            this.addCriterion("doorname <", value, "doorname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameLessThanColumn(Column column) {
            this.addCriterion("doorname < " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameLessThanOrEqualTo(String value) {
            this.addCriterion("doorname <=", value, "doorname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("doorname <= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameLike(String value) {
            this.addCriterion("doorname like", value, "doorname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameNotLike(String value) {
            this.addCriterion("doorname not like", value, "doorname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameIn(List<String> values) {
            this.addCriterion("doorname in", values, "doorname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameNotIn(List<String> values) {
            this.addCriterion("doorname not in", values, "doorname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameBetween(String value1, String value2) {
            this.addCriterion("doorname between", value1, value2, "doorname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDoornameNotBetween(String value1, String value2) {
            this.addCriterion("doorname not between", value1, value2, "doorname");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andXIsNull() {
            this.addCriterion("x is null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andXIsNotNull() {
            this.addCriterion("x is not null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andXEqualTo(Integer value) {
            this.addCriterion("x =", value, "x");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andXEqualToColumn(Column column) {
            this.addCriterion("x = " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andXNotEqualTo(Integer value) {
            this.addCriterion("x <>", value, "x");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andXNotEqualToColumn(Column column) {
            this.addCriterion("x <> " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andXGreaterThan(Integer value) {
            this.addCriterion("x >", value, "x");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andXGreaterThanColumn(Column column) {
            this.addCriterion("x > " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andXGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("x >=", value, "x");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andXGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("x >= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andXLessThan(Integer value) {
            this.addCriterion("x <", value, "x");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andXLessThanColumn(Column column) {
            this.addCriterion("x < " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andXLessThanOrEqualTo(Integer value) {
            this.addCriterion("x <=", value, "x");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andXLessThanOrEqualToColumn(Column column) {
            this.addCriterion("x <= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andXIn(List<Integer> values) {
            this.addCriterion("x in", values, "x");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andXNotIn(List<Integer> values) {
            this.addCriterion("x not in", values, "x");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andXBetween(Integer value1, Integer value2) {
            this.addCriterion("x between", value1, value2, "x");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andXNotBetween(Integer value1, Integer value2) {
            this.addCriterion("x not between", value1, value2, "x");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andYIsNull() {
            this.addCriterion("y is null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andYIsNotNull() {
            this.addCriterion("y is not null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andYEqualTo(Integer value) {
            this.addCriterion("y =", value, "y");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andYEqualToColumn(Column column) {
            this.addCriterion("y = " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andYNotEqualTo(Integer value) {
            this.addCriterion("y <>", value, "y");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andYNotEqualToColumn(Column column) {
            this.addCriterion("y <> " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andYGreaterThan(Integer value) {
            this.addCriterion("y >", value, "y");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andYGreaterThanColumn(Column column) {
            this.addCriterion("y > " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andYGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("y >=", value, "y");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andYGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("y >= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andYLessThan(Integer value) {
            this.addCriterion("y <", value, "y");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andYLessThanColumn(Column column) {
            this.addCriterion("y < " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andYLessThanOrEqualTo(Integer value) {
            this.addCriterion("y <=", value, "y");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andYLessThanOrEqualToColumn(Column column) {
            this.addCriterion("y <= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andYIn(List<Integer> values) {
            this.addCriterion("y in", values, "y");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andYNotIn(List<Integer> values) {
            this.addCriterion("y not in", values, "y");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andYBetween(Integer value1, Integer value2) {
            this.addCriterion("y between", value1, value2, "y");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andYNotBetween(Integer value1, Integer value2) {
            this.addCriterion("y not between", value1, value2, "y");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andZIsNull() {
            this.addCriterion("z is null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andZIsNotNull() {
            this.addCriterion("z is not null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andZEqualTo(Integer value) {
            this.addCriterion("z =", value, "z");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andZEqualToColumn(Column column) {
            this.addCriterion("z = " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andZNotEqualTo(Integer value) {
            this.addCriterion("z <>", value, "z");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andZNotEqualToColumn(Column column) {
            this.addCriterion("z <> " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andZGreaterThan(Integer value) {
            this.addCriterion("z >", value, "z");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andZGreaterThanColumn(Column column) {
            this.addCriterion("z > " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andZGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("z >=", value, "z");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andZGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("z >= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andZLessThan(Integer value) {
            this.addCriterion("z <", value, "z");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andZLessThanColumn(Column column) {
            this.addCriterion("z < " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andZLessThanOrEqualTo(Integer value) {
            this.addCriterion("z <=", value, "z");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andZLessThanOrEqualToColumn(Column column) {
            this.addCriterion("z <= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andZIn(List<Integer> values) {
            this.addCriterion("z in", values, "z");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andZNotIn(List<Integer> values) {
            this.addCriterion("z not in", values, "z");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andZBetween(Integer value1, Integer value2) {
            this.addCriterion("z between", value1, value2, "z");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andZNotBetween(Integer value1, Integer value2) {
            this.addCriterion("z not between", value1, value2, "z");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInxIsNull() {
            this.addCriterion("inx is null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInxIsNotNull() {
            this.addCriterion("inx is not null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInxEqualTo(Integer value) {
            this.addCriterion("inx =", value, "inx");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInxEqualToColumn(Column column) {
            this.addCriterion("inx = " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInxNotEqualTo(Integer value) {
            this.addCriterion("inx <>", value, "inx");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInxNotEqualToColumn(Column column) {
            this.addCriterion("inx <> " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInxGreaterThan(Integer value) {
            this.addCriterion("inx >", value, "inx");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInxGreaterThanColumn(Column column) {
            this.addCriterion("inx > " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInxGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("inx >=", value, "inx");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInxGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("inx >= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInxLessThan(Integer value) {
            this.addCriterion("inx <", value, "inx");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInxLessThanColumn(Column column) {
            this.addCriterion("inx < " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInxLessThanOrEqualTo(Integer value) {
            this.addCriterion("inx <=", value, "inx");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInxLessThanOrEqualToColumn(Column column) {
            this.addCriterion("inx <= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInxIn(List<Integer> values) {
            this.addCriterion("inx in", values, "inx");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInxNotIn(List<Integer> values) {
            this.addCriterion("inx not in", values, "inx");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInxBetween(Integer value1, Integer value2) {
            this.addCriterion("inx between", value1, value2, "inx");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInxNotBetween(Integer value1, Integer value2) {
            this.addCriterion("inx not between", value1, value2, "inx");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInyIsNull() {
            this.addCriterion("iny is null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInyIsNotNull() {
            this.addCriterion("iny is not null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInyEqualTo(Integer value) {
            this.addCriterion("iny =", value, "iny");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInyEqualToColumn(Column column) {
            this.addCriterion("iny = " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInyNotEqualTo(Integer value) {
            this.addCriterion("iny <>", value, "iny");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInyNotEqualToColumn(Column column) {
            this.addCriterion("iny <> " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInyGreaterThan(Integer value) {
            this.addCriterion("iny >", value, "iny");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInyGreaterThanColumn(Column column) {
            this.addCriterion("iny > " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInyGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("iny >=", value, "iny");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInyGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("iny >= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInyLessThan(Integer value) {
            this.addCriterion("iny <", value, "iny");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInyLessThanColumn(Column column) {
            this.addCriterion("iny < " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInyLessThanOrEqualTo(Integer value) {
            this.addCriterion("iny <=", value, "iny");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInyLessThanOrEqualToColumn(Column column) {
            this.addCriterion("iny <= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInyIn(List<Integer> values) {
            this.addCriterion("iny in", values, "iny");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInyNotIn(List<Integer> values) {
            this.addCriterion("iny not in", values, "iny");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInyBetween(Integer value1, Integer value2) {
            this.addCriterion("iny between", value1, value2, "iny");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andInyNotBetween(Integer value1, Integer value2) {
            this.addCriterion("iny not between", value1, value2, "iny");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (NpcPointExample.Criteria)this;
        }

        public NpcPointExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (NpcPointExample.Criteria)this;
        }
    }
}
