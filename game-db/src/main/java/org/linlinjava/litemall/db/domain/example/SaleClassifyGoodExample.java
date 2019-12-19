//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.SaleClassifyGood.Column;
import org.linlinjava.litemall.db.domain.SaleClassifyGood.Deleted;

public class SaleClassifyGoodExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<SaleClassifyGoodExample.Criteria> oredCriteria = new ArrayList();

    public SaleClassifyGoodExample() {
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

    public List<SaleClassifyGoodExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(SaleClassifyGoodExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public SaleClassifyGoodExample.Criteria or() {
        SaleClassifyGoodExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public SaleClassifyGoodExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public SaleClassifyGoodExample orderBy(String... orderByClauses) {
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

    public SaleClassifyGoodExample.Criteria createCriteria() {
        SaleClassifyGoodExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected SaleClassifyGoodExample.Criteria createCriteriaInternal() {
        SaleClassifyGoodExample.Criteria criteria = new SaleClassifyGoodExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static SaleClassifyGoodExample.Criteria newAndCreateCriteria() {
        SaleClassifyGoodExample example = new SaleClassifyGoodExample();
        return example.createCriteria();
    }

    public SaleClassifyGoodExample when(boolean condition, SaleClassifyGoodExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public SaleClassifyGoodExample when(boolean condition, SaleClassifyGoodExample.IExampleWhen then, SaleClassifyGoodExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(SaleClassifyGoodExample example);
    }

    public interface ICriteriaWhen {
        void criteria(SaleClassifyGoodExample.Criteria criteria);
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

    public static class Criteria extends SaleClassifyGoodExample.GeneratedCriteria {
        private SaleClassifyGoodExample example;

        protected Criteria(SaleClassifyGoodExample example) {
            this.example = example;
        }

        public SaleClassifyGoodExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public SaleClassifyGoodExample.Criteria andIf(boolean ifAdd, SaleClassifyGoodExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public SaleClassifyGoodExample.Criteria when(boolean condition, SaleClassifyGoodExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public SaleClassifyGoodExample.Criteria when(boolean condition, SaleClassifyGoodExample.ICriteriaWhen then, SaleClassifyGoodExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public SaleClassifyGoodExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            SaleClassifyGoodExample.Criteria add(SaleClassifyGoodExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<SaleClassifyGoodExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<SaleClassifyGoodExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<SaleClassifyGoodExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new SaleClassifyGoodExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new SaleClassifyGoodExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new SaleClassifyGoodExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public SaleClassifyGoodExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameIsNull() {
            this.addCriterion("pname is null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameIsNotNull() {
            this.addCriterion("pname is not null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameEqualTo(String value) {
            this.addCriterion("pname =", value, "pname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameEqualToColumn(Column column) {
            this.addCriterion("pname = " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameNotEqualTo(String value) {
            this.addCriterion("pname <>", value, "pname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameNotEqualToColumn(Column column) {
            this.addCriterion("pname <> " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameGreaterThan(String value) {
            this.addCriterion("pname >", value, "pname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameGreaterThanColumn(Column column) {
            this.addCriterion("pname > " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameGreaterThanOrEqualTo(String value) {
            this.addCriterion("pname >=", value, "pname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("pname >= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameLessThan(String value) {
            this.addCriterion("pname <", value, "pname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameLessThanColumn(Column column) {
            this.addCriterion("pname < " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameLessThanOrEqualTo(String value) {
            this.addCriterion("pname <=", value, "pname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("pname <= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameLike(String value) {
            this.addCriterion("pname like", value, "pname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameNotLike(String value) {
            this.addCriterion("pname not like", value, "pname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameIn(List<String> values) {
            this.addCriterion("pname in", values, "pname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameNotIn(List<String> values) {
            this.addCriterion("pname not in", values, "pname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameBetween(String value1, String value2) {
            this.addCriterion("pname between", value1, value2, "pname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPnameNotBetween(String value1, String value2) {
            this.addCriterion("pname not between", value1, value2, "pname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameIsNull() {
            this.addCriterion("cname is null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameIsNotNull() {
            this.addCriterion("cname is not null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameEqualTo(String value) {
            this.addCriterion("cname =", value, "cname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameEqualToColumn(Column column) {
            this.addCriterion("cname = " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameNotEqualTo(String value) {
            this.addCriterion("cname <>", value, "cname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameNotEqualToColumn(Column column) {
            this.addCriterion("cname <> " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameGreaterThan(String value) {
            this.addCriterion("cname >", value, "cname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameGreaterThanColumn(Column column) {
            this.addCriterion("cname > " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameGreaterThanOrEqualTo(String value) {
            this.addCriterion("cname >=", value, "cname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("cname >= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameLessThan(String value) {
            this.addCriterion("cname <", value, "cname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameLessThanColumn(Column column) {
            this.addCriterion("cname < " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameLessThanOrEqualTo(String value) {
            this.addCriterion("cname <=", value, "cname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("cname <= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameLike(String value) {
            this.addCriterion("cname like", value, "cname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameNotLike(String value) {
            this.addCriterion("cname not like", value, "cname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameIn(List<String> values) {
            this.addCriterion("cname in", values, "cname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameNotIn(List<String> values) {
            this.addCriterion("cname not in", values, "cname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameBetween(String value1, String value2) {
            this.addCriterion("cname between", value1, value2, "cname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andCnameNotBetween(String value1, String value2) {
            this.addCriterion("cname not between", value1, value2, "cname");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribIsNull() {
            this.addCriterion("attrib is null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribIsNotNull() {
            this.addCriterion("attrib is not null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribEqualTo(String value) {
            this.addCriterion("attrib =", value, "attrib");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribEqualToColumn(Column column) {
            this.addCriterion("attrib = " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribNotEqualTo(String value) {
            this.addCriterion("attrib <>", value, "attrib");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribNotEqualToColumn(Column column) {
            this.addCriterion("attrib <> " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribGreaterThan(String value) {
            this.addCriterion("attrib >", value, "attrib");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribGreaterThanColumn(Column column) {
            this.addCriterion("attrib > " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribGreaterThanOrEqualTo(String value) {
            this.addCriterion("attrib >=", value, "attrib");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("attrib >= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribLessThan(String value) {
            this.addCriterion("attrib <", value, "attrib");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribLessThanColumn(Column column) {
            this.addCriterion("attrib < " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribLessThanOrEqualTo(String value) {
            this.addCriterion("attrib <=", value, "attrib");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribLessThanOrEqualToColumn(Column column) {
            this.addCriterion("attrib <= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribLike(String value) {
            this.addCriterion("attrib like", value, "attrib");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribNotLike(String value) {
            this.addCriterion("attrib not like", value, "attrib");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribIn(List<String> values) {
            this.addCriterion("attrib in", values, "attrib");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribNotIn(List<String> values) {
            this.addCriterion("attrib not in", values, "attrib");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribBetween(String value1, String value2) {
            this.addCriterion("attrib between", value1, value2, "attrib");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAttribNotBetween(String value1, String value2) {
            this.addCriterion("attrib not between", value1, value2, "attrib");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIconIsNull() {
            this.addCriterion("icon is null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIconIsNotNull() {
            this.addCriterion("icon is not null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIconEqualTo(Integer value) {
            this.addCriterion("icon =", value, "icon");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIconEqualToColumn(Column column) {
            this.addCriterion("icon = " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIconNotEqualTo(Integer value) {
            this.addCriterion("icon <>", value, "icon");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIconNotEqualToColumn(Column column) {
            this.addCriterion("icon <> " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIconGreaterThan(Integer value) {
            this.addCriterion("icon >", value, "icon");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIconGreaterThanColumn(Column column) {
            this.addCriterion("icon > " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIconGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("icon >=", value, "icon");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIconGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("icon >= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIconLessThan(Integer value) {
            this.addCriterion("icon <", value, "icon");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIconLessThanColumn(Column column) {
            this.addCriterion("icon < " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIconLessThanOrEqualTo(Integer value) {
            this.addCriterion("icon <=", value, "icon");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIconLessThanOrEqualToColumn(Column column) {
            this.addCriterion("icon <= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIconIn(List<Integer> values) {
            this.addCriterion("icon in", values, "icon");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIconNotIn(List<Integer> values) {
            this.addCriterion("icon not in", values, "icon");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIconBetween(Integer value1, Integer value2) {
            this.addCriterion("icon between", value1, value2, "icon");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andIconNotBetween(Integer value1, Integer value2) {
            this.addCriterion("icon not between", value1, value2, "icon");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrIsNull() {
            this.addCriterion("str is null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrIsNotNull() {
            this.addCriterion("str is not null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrEqualTo(String value) {
            this.addCriterion("str =", value, "str");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrEqualToColumn(Column column) {
            this.addCriterion("str = " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrNotEqualTo(String value) {
            this.addCriterion("str <>", value, "str");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrNotEqualToColumn(Column column) {
            this.addCriterion("str <> " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrGreaterThan(String value) {
            this.addCriterion("str >", value, "str");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrGreaterThanColumn(Column column) {
            this.addCriterion("str > " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrGreaterThanOrEqualTo(String value) {
            this.addCriterion("str >=", value, "str");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("str >= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrLessThan(String value) {
            this.addCriterion("str <", value, "str");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrLessThanColumn(Column column) {
            this.addCriterion("str < " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrLessThanOrEqualTo(String value) {
            this.addCriterion("str <=", value, "str");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrLessThanOrEqualToColumn(Column column) {
            this.addCriterion("str <= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrLike(String value) {
            this.addCriterion("str like", value, "str");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrNotLike(String value) {
            this.addCriterion("str not like", value, "str");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrIn(List<String> values) {
            this.addCriterion("str in", values, "str");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrNotIn(List<String> values) {
            this.addCriterion("str not in", values, "str");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrBetween(String value1, String value2) {
            this.addCriterion("str between", value1, value2, "str");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andStrNotBetween(String value1, String value2) {
            this.addCriterion("str not between", value1, value2, "str");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPriceIsNull() {
            this.addCriterion("price is null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPriceIsNotNull() {
            this.addCriterion("price is not null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPriceEqualTo(Integer value) {
            this.addCriterion("price =", value, "price");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPriceEqualToColumn(Column column) {
            this.addCriterion("price = " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPriceNotEqualTo(Integer value) {
            this.addCriterion("price <>", value, "price");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPriceNotEqualToColumn(Column column) {
            this.addCriterion("price <> " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPriceGreaterThan(Integer value) {
            this.addCriterion("price >", value, "price");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPriceGreaterThanColumn(Column column) {
            this.addCriterion("price > " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPriceGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("price >=", value, "price");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPriceGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("price >= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPriceLessThan(Integer value) {
            this.addCriterion("price <", value, "price");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPriceLessThanColumn(Column column) {
            this.addCriterion("price < " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPriceLessThanOrEqualTo(Integer value) {
            this.addCriterion("price <=", value, "price");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPriceLessThanOrEqualToColumn(Column column) {
            this.addCriterion("price <= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPriceIn(List<Integer> values) {
            this.addCriterion("price in", values, "price");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPriceNotIn(List<Integer> values) {
            this.addCriterion("price not in", values, "price");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPriceBetween(Integer value1, Integer value2) {
            this.addCriterion("price between", value1, value2, "price");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andPriceNotBetween(Integer value1, Integer value2) {
            this.addCriterion("price not between", value1, value2, "price");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeIsNull() {
            this.addCriterion("compose is null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeIsNotNull() {
            this.addCriterion("compose is not null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeEqualTo(String value) {
            this.addCriterion("compose =", value, "compose");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeEqualToColumn(Column column) {
            this.addCriterion("compose = " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeNotEqualTo(String value) {
            this.addCriterion("compose <>", value, "compose");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeNotEqualToColumn(Column column) {
            this.addCriterion("compose <> " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeGreaterThan(String value) {
            this.addCriterion("compose >", value, "compose");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeGreaterThanColumn(Column column) {
            this.addCriterion("compose > " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeGreaterThanOrEqualTo(String value) {
            this.addCriterion("compose >=", value, "compose");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("compose >= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeLessThan(String value) {
            this.addCriterion("compose <", value, "compose");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeLessThanColumn(Column column) {
            this.addCriterion("compose < " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeLessThanOrEqualTo(String value) {
            this.addCriterion("compose <=", value, "compose");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("compose <= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeLike(String value) {
            this.addCriterion("compose like", value, "compose");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeNotLike(String value) {
            this.addCriterion("compose not like", value, "compose");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeIn(List<String> values) {
            this.addCriterion("compose in", values, "compose");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeNotIn(List<String> values) {
            this.addCriterion("compose not in", values, "compose");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeBetween(String value1, String value2) {
            this.addCriterion("compose between", value1, value2, "compose");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andComposeNotBetween(String value1, String value2) {
            this.addCriterion("compose not between", value1, value2, "compose");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (SaleClassifyGoodExample.Criteria)this;
        }

        public SaleClassifyGoodExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (SaleClassifyGoodExample.Criteria)this;
        }
    }
}
