//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Pets.Column;
import org.linlinjava.litemall.db.domain.Pets.Deleted;

public class PetsExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<PetsExample.Criteria> oredCriteria = new ArrayList();

    public PetsExample() {
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

    public List<PetsExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(PetsExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public PetsExample.Criteria or() {
        PetsExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public PetsExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public PetsExample orderBy(String... orderByClauses) {
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

    public PetsExample.Criteria createCriteria() {
        PetsExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected PetsExample.Criteria createCriteriaInternal() {
        PetsExample.Criteria criteria = new PetsExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static PetsExample.Criteria newAndCreateCriteria() {
        PetsExample example = new PetsExample();
        return example.createCriteria();
    }

    public PetsExample when(boolean condition, PetsExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public PetsExample when(boolean condition, PetsExample.IExampleWhen then, PetsExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(PetsExample example);
    }

    public interface ICriteriaWhen {
        void criteria(PetsExample.Criteria criteria);
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

    public static class Criteria extends PetsExample.GeneratedCriteria {
        private PetsExample example;

        protected Criteria(PetsExample example) {
            this.example = example;
        }

        public PetsExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public PetsExample.Criteria andIf(boolean ifAdd, PetsExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public PetsExample.Criteria when(boolean condition, PetsExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public PetsExample.Criteria when(boolean condition, PetsExample.ICriteriaWhen then, PetsExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public PetsExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            PetsExample.Criteria add(PetsExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<PetsExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<PetsExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<PetsExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new PetsExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new PetsExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new PetsExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public PetsExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridIsNull() {
            this.addCriterion("ownerid is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridIsNotNull() {
            this.addCriterion("ownerid is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridEqualTo(String value) {
            this.addCriterion("ownerid =", value, "ownerid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridEqualToColumn(Column column) {
            this.addCriterion("ownerid = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridNotEqualTo(String value) {
            this.addCriterion("ownerid <>", value, "ownerid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridNotEqualToColumn(Column column) {
            this.addCriterion("ownerid <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridGreaterThan(String value) {
            this.addCriterion("ownerid >", value, "ownerid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridGreaterThanColumn(Column column) {
            this.addCriterion("ownerid > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridGreaterThanOrEqualTo(String value) {
            this.addCriterion("ownerid >=", value, "ownerid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("ownerid >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridLessThan(String value) {
            this.addCriterion("ownerid <", value, "ownerid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridLessThanColumn(Column column) {
            this.addCriterion("ownerid < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridLessThanOrEqualTo(String value) {
            this.addCriterion("ownerid <=", value, "ownerid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridLessThanOrEqualToColumn(Column column) {
            this.addCriterion("ownerid <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridLike(String value) {
            this.addCriterion("ownerid like", value, "ownerid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridNotLike(String value) {
            this.addCriterion("ownerid not like", value, "ownerid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridIn(List<String> values) {
            this.addCriterion("ownerid in", values, "ownerid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridNotIn(List<String> values) {
            this.addCriterion("ownerid not in", values, "ownerid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridBetween(String value1, String value2) {
            this.addCriterion("ownerid between", value1, value2, "ownerid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andOwneridNotBetween(String value1, String value2) {
            this.addCriterion("ownerid not between", value1, value2, "ownerid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidIsNull() {
            this.addCriterion("petid is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidIsNotNull() {
            this.addCriterion("petid is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidEqualTo(String value) {
            this.addCriterion("petid =", value, "petid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidEqualToColumn(Column column) {
            this.addCriterion("petid = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidNotEqualTo(String value) {
            this.addCriterion("petid <>", value, "petid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidNotEqualToColumn(Column column) {
            this.addCriterion("petid <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidGreaterThan(String value) {
            this.addCriterion("petid >", value, "petid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidGreaterThanColumn(Column column) {
            this.addCriterion("petid > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidGreaterThanOrEqualTo(String value) {
            this.addCriterion("petid >=", value, "petid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("petid >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidLessThan(String value) {
            this.addCriterion("petid <", value, "petid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidLessThanColumn(Column column) {
            this.addCriterion("petid < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidLessThanOrEqualTo(String value) {
            this.addCriterion("petid <=", value, "petid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidLessThanOrEqualToColumn(Column column) {
            this.addCriterion("petid <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidLike(String value) {
            this.addCriterion("petid like", value, "petid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidNotLike(String value) {
            this.addCriterion("petid not like", value, "petid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidIn(List<String> values) {
            this.addCriterion("petid in", values, "petid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidNotIn(List<String> values) {
            this.addCriterion("petid not in", values, "petid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidBetween(String value1, String value2) {
            this.addCriterion("petid between", value1, value2, "petid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andPetidNotBetween(String value1, String value2) {
            this.addCriterion("petid not between", value1, value2, "petid");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameIsNull() {
            this.addCriterion("nickname is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameIsNotNull() {
            this.addCriterion("nickname is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameEqualTo(String value) {
            this.addCriterion("nickname =", value, "nickname");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameEqualToColumn(Column column) {
            this.addCriterion("nickname = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameNotEqualTo(String value) {
            this.addCriterion("nickname <>", value, "nickname");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameNotEqualToColumn(Column column) {
            this.addCriterion("nickname <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameGreaterThan(String value) {
            this.addCriterion("nickname >", value, "nickname");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameGreaterThanColumn(Column column) {
            this.addCriterion("nickname > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameGreaterThanOrEqualTo(String value) {
            this.addCriterion("nickname >=", value, "nickname");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("nickname >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameLessThan(String value) {
            this.addCriterion("nickname <", value, "nickname");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameLessThanColumn(Column column) {
            this.addCriterion("nickname < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameLessThanOrEqualTo(String value) {
            this.addCriterion("nickname <=", value, "nickname");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("nickname <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameLike(String value) {
            this.addCriterion("nickname like", value, "nickname");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameNotLike(String value) {
            this.addCriterion("nickname not like", value, "nickname");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameIn(List<String> values) {
            this.addCriterion("nickname in", values, "nickname");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameNotIn(List<String> values) {
            this.addCriterion("nickname not in", values, "nickname");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameBetween(String value1, String value2) {
            this.addCriterion("nickname between", value1, value2, "nickname");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNicknameNotBetween(String value1, String value2) {
            this.addCriterion("nickname not between", value1, value2, "nickname");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andHorsetypeIsNull() {
            this.addCriterion("horsetype is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andHorsetypeIsNotNull() {
            this.addCriterion("horsetype is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andHorsetypeEqualTo(Integer value) {
            this.addCriterion("horsetype =", value, "horsetype");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andHorsetypeEqualToColumn(Column column) {
            this.addCriterion("horsetype = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andHorsetypeNotEqualTo(Integer value) {
            this.addCriterion("horsetype <>", value, "horsetype");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andHorsetypeNotEqualToColumn(Column column) {
            this.addCriterion("horsetype <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andHorsetypeGreaterThan(Integer value) {
            this.addCriterion("horsetype >", value, "horsetype");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andHorsetypeGreaterThanColumn(Column column) {
            this.addCriterion("horsetype > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andHorsetypeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("horsetype >=", value, "horsetype");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andHorsetypeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("horsetype >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andHorsetypeLessThan(Integer value) {
            this.addCriterion("horsetype <", value, "horsetype");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andHorsetypeLessThanColumn(Column column) {
            this.addCriterion("horsetype < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andHorsetypeLessThanOrEqualTo(Integer value) {
            this.addCriterion("horsetype <=", value, "horsetype");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andHorsetypeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("horsetype <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andHorsetypeIn(List<Integer> values) {
            this.addCriterion("horsetype in", values, "horsetype");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andHorsetypeNotIn(List<Integer> values) {
            this.addCriterion("horsetype not in", values, "horsetype");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andHorsetypeBetween(Integer value1, Integer value2) {
            this.addCriterion("horsetype between", value1, value2, "horsetype");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andHorsetypeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("horsetype not between", value1, value2, "horsetype");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTypeIsNull() {
            this.addCriterion("`type` is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTypeIsNotNull() {
            this.addCriterion("`type` is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTypeEqualTo(Integer value) {
            this.addCriterion("`type` =", value, "type");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTypeEqualToColumn(Column column) {
            this.addCriterion("`type` = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTypeNotEqualTo(Integer value) {
            this.addCriterion("`type` <>", value, "type");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTypeNotEqualToColumn(Column column) {
            this.addCriterion("`type` <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTypeGreaterThan(Integer value) {
            this.addCriterion("`type` >", value, "type");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTypeGreaterThanColumn(Column column) {
            this.addCriterion("`type` > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTypeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`type` >=", value, "type");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTypeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTypeLessThan(Integer value) {
            this.addCriterion("`type` <", value, "type");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTypeLessThanColumn(Column column) {
            this.addCriterion("`type` < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTypeLessThanOrEqualTo(Integer value) {
            this.addCriterion("`type` <=", value, "type");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTypeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`type` <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTypeIn(List<Integer> values) {
            this.addCriterion("`type` in", values, "type");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTypeNotIn(List<Integer> values) {
            this.addCriterion("`type` not in", values, "type");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTypeBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` between", value1, value2, "type");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTypeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`type` not between", value1, value2, "type");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLevelIsNull() {
            this.addCriterion("`level` is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLevelIsNotNull() {
            this.addCriterion("`level` is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLevelEqualTo(Integer value) {
            this.addCriterion("`level` =", value, "level");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLevelEqualToColumn(Column column) {
            this.addCriterion("`level` = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLevelNotEqualTo(Integer value) {
            this.addCriterion("`level` <>", value, "level");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLevelNotEqualToColumn(Column column) {
            this.addCriterion("`level` <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLevelGreaterThan(Integer value) {
            this.addCriterion("`level` >", value, "level");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLevelGreaterThanColumn(Column column) {
            this.addCriterion("`level` > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLevelGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("`level` >=", value, "level");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLevelGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`level` >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLevelLessThan(Integer value) {
            this.addCriterion("`level` <", value, "level");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLevelLessThanColumn(Column column) {
            this.addCriterion("`level` < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLevelLessThanOrEqualTo(Integer value) {
            this.addCriterion("`level` <=", value, "level");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLevelLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`level` <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLevelIn(List<Integer> values) {
            this.addCriterion("`level` in", values, "level");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLevelNotIn(List<Integer> values) {
            this.addCriterion("`level` not in", values, "level");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLevelBetween(Integer value1, Integer value2) {
            this.addCriterion("`level` between", value1, value2, "level");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLevelNotBetween(Integer value1, Integer value2) {
            this.addCriterion("`level` not between", value1, value2, "level");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLiliangIsNull() {
            this.addCriterion("liliang is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLiliangIsNotNull() {
            this.addCriterion("liliang is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLiliangEqualTo(Integer value) {
            this.addCriterion("liliang =", value, "liliang");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLiliangEqualToColumn(Column column) {
            this.addCriterion("liliang = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLiliangNotEqualTo(Integer value) {
            this.addCriterion("liliang <>", value, "liliang");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLiliangNotEqualToColumn(Column column) {
            this.addCriterion("liliang <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLiliangGreaterThan(Integer value) {
            this.addCriterion("liliang >", value, "liliang");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLiliangGreaterThanColumn(Column column) {
            this.addCriterion("liliang > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLiliangGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("liliang >=", value, "liliang");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLiliangGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("liliang >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLiliangLessThan(Integer value) {
            this.addCriterion("liliang <", value, "liliang");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLiliangLessThanColumn(Column column) {
            this.addCriterion("liliang < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLiliangLessThanOrEqualTo(Integer value) {
            this.addCriterion("liliang <=", value, "liliang");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLiliangLessThanOrEqualToColumn(Column column) {
            this.addCriterion("liliang <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLiliangIn(List<Integer> values) {
            this.addCriterion("liliang in", values, "liliang");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLiliangNotIn(List<Integer> values) {
            this.addCriterion("liliang not in", values, "liliang");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLiliangBetween(Integer value1, Integer value2) {
            this.addCriterion("liliang between", value1, value2, "liliang");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLiliangNotBetween(Integer value1, Integer value2) {
            this.addCriterion("liliang not between", value1, value2, "liliang");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andMinjieIsNull() {
            this.addCriterion("minjie is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andMinjieIsNotNull() {
            this.addCriterion("minjie is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andMinjieEqualTo(Integer value) {
            this.addCriterion("minjie =", value, "minjie");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andMinjieEqualToColumn(Column column) {
            this.addCriterion("minjie = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andMinjieNotEqualTo(Integer value) {
            this.addCriterion("minjie <>", value, "minjie");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andMinjieNotEqualToColumn(Column column) {
            this.addCriterion("minjie <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andMinjieGreaterThan(Integer value) {
            this.addCriterion("minjie >", value, "minjie");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andMinjieGreaterThanColumn(Column column) {
            this.addCriterion("minjie > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andMinjieGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("minjie >=", value, "minjie");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andMinjieGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("minjie >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andMinjieLessThan(Integer value) {
            this.addCriterion("minjie <", value, "minjie");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andMinjieLessThanColumn(Column column) {
            this.addCriterion("minjie < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andMinjieLessThanOrEqualTo(Integer value) {
            this.addCriterion("minjie <=", value, "minjie");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andMinjieLessThanOrEqualToColumn(Column column) {
            this.addCriterion("minjie <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andMinjieIn(List<Integer> values) {
            this.addCriterion("minjie in", values, "minjie");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andMinjieNotIn(List<Integer> values) {
            this.addCriterion("minjie not in", values, "minjie");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andMinjieBetween(Integer value1, Integer value2) {
            this.addCriterion("minjie between", value1, value2, "minjie");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andMinjieNotBetween(Integer value1, Integer value2) {
            this.addCriterion("minjie not between", value1, value2, "minjie");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLingliIsNull() {
            this.addCriterion("lingli is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLingliIsNotNull() {
            this.addCriterion("lingli is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLingliEqualTo(Integer value) {
            this.addCriterion("lingli =", value, "lingli");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLingliEqualToColumn(Column column) {
            this.addCriterion("lingli = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLingliNotEqualTo(Integer value) {
            this.addCriterion("lingli <>", value, "lingli");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLingliNotEqualToColumn(Column column) {
            this.addCriterion("lingli <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLingliGreaterThan(Integer value) {
            this.addCriterion("lingli >", value, "lingli");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLingliGreaterThanColumn(Column column) {
            this.addCriterion("lingli > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLingliGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("lingli >=", value, "lingli");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLingliGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("lingli >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLingliLessThan(Integer value) {
            this.addCriterion("lingli <", value, "lingli");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLingliLessThanColumn(Column column) {
            this.addCriterion("lingli < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLingliLessThanOrEqualTo(Integer value) {
            this.addCriterion("lingli <=", value, "lingli");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLingliLessThanOrEqualToColumn(Column column) {
            this.addCriterion("lingli <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLingliIn(List<Integer> values) {
            this.addCriterion("lingli in", values, "lingli");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLingliNotIn(List<Integer> values) {
            this.addCriterion("lingli not in", values, "lingli");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLingliBetween(Integer value1, Integer value2) {
            this.addCriterion("lingli between", value1, value2, "lingli");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andLingliNotBetween(Integer value1, Integer value2) {
            this.addCriterion("lingli not between", value1, value2, "lingli");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTiliIsNull() {
            this.addCriterion("tili is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTiliIsNotNull() {
            this.addCriterion("tili is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTiliEqualTo(Integer value) {
            this.addCriterion("tili =", value, "tili");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTiliEqualToColumn(Column column) {
            this.addCriterion("tili = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTiliNotEqualTo(Integer value) {
            this.addCriterion("tili <>", value, "tili");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTiliNotEqualToColumn(Column column) {
            this.addCriterion("tili <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTiliGreaterThan(Integer value) {
            this.addCriterion("tili >", value, "tili");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTiliGreaterThanColumn(Column column) {
            this.addCriterion("tili > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTiliGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("tili >=", value, "tili");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTiliGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("tili >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTiliLessThan(Integer value) {
            this.addCriterion("tili <", value, "tili");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTiliLessThanColumn(Column column) {
            this.addCriterion("tili < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTiliLessThanOrEqualTo(Integer value) {
            this.addCriterion("tili <=", value, "tili");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTiliLessThanOrEqualToColumn(Column column) {
            this.addCriterion("tili <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTiliIn(List<Integer> values) {
            this.addCriterion("tili in", values, "tili");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTiliNotIn(List<Integer> values) {
            this.addCriterion("tili not in", values, "tili");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTiliBetween(Integer value1, Integer value2) {
            this.addCriterion("tili between", value1, value2, "tili");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andTiliNotBetween(Integer value1, Integer value2) {
            this.addCriterion("tili not between", value1, value2, "tili");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhualxIsNull() {
            this.addCriterion("dianhualx is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhualxIsNotNull() {
            this.addCriterion("dianhualx is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhualxEqualTo(Integer value) {
            this.addCriterion("dianhualx =", value, "dianhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhualxEqualToColumn(Column column) {
            this.addCriterion("dianhualx = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhualxNotEqualTo(Integer value) {
            this.addCriterion("dianhualx <>", value, "dianhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhualxNotEqualToColumn(Column column) {
            this.addCriterion("dianhualx <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhualxGreaterThan(Integer value) {
            this.addCriterion("dianhualx >", value, "dianhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhualxGreaterThanColumn(Column column) {
            this.addCriterion("dianhualx > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhualxGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("dianhualx >=", value, "dianhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhualxGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("dianhualx >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhualxLessThan(Integer value) {
            this.addCriterion("dianhualx <", value, "dianhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhualxLessThanColumn(Column column) {
            this.addCriterion("dianhualx < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhualxLessThanOrEqualTo(Integer value) {
            this.addCriterion("dianhualx <=", value, "dianhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhualxLessThanOrEqualToColumn(Column column) {
            this.addCriterion("dianhualx <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhualxIn(List<Integer> values) {
            this.addCriterion("dianhualx in", values, "dianhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhualxNotIn(List<Integer> values) {
            this.addCriterion("dianhualx not in", values, "dianhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhualxBetween(Integer value1, Integer value2) {
            this.addCriterion("dianhualx between", value1, value2, "dianhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhualxNotBetween(Integer value1, Integer value2) {
            this.addCriterion("dianhualx not between", value1, value2, "dianhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazdIsNull() {
            this.addCriterion("dianhuazd is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazdIsNotNull() {
            this.addCriterion("dianhuazd is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazdEqualTo(Integer value) {
            this.addCriterion("dianhuazd =", value, "dianhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazdEqualToColumn(Column column) {
            this.addCriterion("dianhuazd = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazdNotEqualTo(Integer value) {
            this.addCriterion("dianhuazd <>", value, "dianhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazdNotEqualToColumn(Column column) {
            this.addCriterion("dianhuazd <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazdGreaterThan(Integer value) {
            this.addCriterion("dianhuazd >", value, "dianhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazdGreaterThanColumn(Column column) {
            this.addCriterion("dianhuazd > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("dianhuazd >=", value, "dianhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("dianhuazd >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazdLessThan(Integer value) {
            this.addCriterion("dianhuazd <", value, "dianhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazdLessThanColumn(Column column) {
            this.addCriterion("dianhuazd < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazdLessThanOrEqualTo(Integer value) {
            this.addCriterion("dianhuazd <=", value, "dianhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("dianhuazd <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazdIn(List<Integer> values) {
            this.addCriterion("dianhuazd in", values, "dianhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazdNotIn(List<Integer> values) {
            this.addCriterion("dianhuazd not in", values, "dianhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazdBetween(Integer value1, Integer value2) {
            this.addCriterion("dianhuazd between", value1, value2, "dianhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("dianhuazd not between", value1, value2, "dianhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazxIsNull() {
            this.addCriterion("dianhuazx is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazxIsNotNull() {
            this.addCriterion("dianhuazx is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazxEqualTo(Integer value) {
            this.addCriterion("dianhuazx =", value, "dianhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazxEqualToColumn(Column column) {
            this.addCriterion("dianhuazx = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazxNotEqualTo(Integer value) {
            this.addCriterion("dianhuazx <>", value, "dianhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazxNotEqualToColumn(Column column) {
            this.addCriterion("dianhuazx <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazxGreaterThan(Integer value) {
            this.addCriterion("dianhuazx >", value, "dianhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazxGreaterThanColumn(Column column) {
            this.addCriterion("dianhuazx > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazxGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("dianhuazx >=", value, "dianhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazxGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("dianhuazx >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazxLessThan(Integer value) {
            this.addCriterion("dianhuazx <", value, "dianhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazxLessThanColumn(Column column) {
            this.addCriterion("dianhuazx < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazxLessThanOrEqualTo(Integer value) {
            this.addCriterion("dianhuazx <=", value, "dianhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazxLessThanOrEqualToColumn(Column column) {
            this.addCriterion("dianhuazx <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazxIn(List<Integer> values) {
            this.addCriterion("dianhuazx in", values, "dianhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazxNotIn(List<Integer> values) {
            this.addCriterion("dianhuazx not in", values, "dianhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazxBetween(Integer value1, Integer value2) {
            this.addCriterion("dianhuazx between", value1, value2, "dianhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDianhuazxNotBetween(Integer value1, Integer value2) {
            this.addCriterion("dianhuazx not between", value1, value2, "dianhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhualxIsNull() {
            this.addCriterion("yuhualx is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhualxIsNotNull() {
            this.addCriterion("yuhualx is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhualxEqualTo(Integer value) {
            this.addCriterion("yuhualx =", value, "yuhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhualxEqualToColumn(Column column) {
            this.addCriterion("yuhualx = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhualxNotEqualTo(Integer value) {
            this.addCriterion("yuhualx <>", value, "yuhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhualxNotEqualToColumn(Column column) {
            this.addCriterion("yuhualx <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhualxGreaterThan(Integer value) {
            this.addCriterion("yuhualx >", value, "yuhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhualxGreaterThanColumn(Column column) {
            this.addCriterion("yuhualx > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhualxGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("yuhualx >=", value, "yuhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhualxGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("yuhualx >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhualxLessThan(Integer value) {
            this.addCriterion("yuhualx <", value, "yuhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhualxLessThanColumn(Column column) {
            this.addCriterion("yuhualx < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhualxLessThanOrEqualTo(Integer value) {
            this.addCriterion("yuhualx <=", value, "yuhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhualxLessThanOrEqualToColumn(Column column) {
            this.addCriterion("yuhualx <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhualxIn(List<Integer> values) {
            this.addCriterion("yuhualx in", values, "yuhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhualxNotIn(List<Integer> values) {
            this.addCriterion("yuhualx not in", values, "yuhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhualxBetween(Integer value1, Integer value2) {
            this.addCriterion("yuhualx between", value1, value2, "yuhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhualxNotBetween(Integer value1, Integer value2) {
            this.addCriterion("yuhualx not between", value1, value2, "yuhualx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazdIsNull() {
            this.addCriterion("yuhuazd is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazdIsNotNull() {
            this.addCriterion("yuhuazd is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazdEqualTo(Integer value) {
            this.addCriterion("yuhuazd =", value, "yuhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazdEqualToColumn(Column column) {
            this.addCriterion("yuhuazd = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazdNotEqualTo(Integer value) {
            this.addCriterion("yuhuazd <>", value, "yuhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazdNotEqualToColumn(Column column) {
            this.addCriterion("yuhuazd <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazdGreaterThan(Integer value) {
            this.addCriterion("yuhuazd >", value, "yuhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazdGreaterThanColumn(Column column) {
            this.addCriterion("yuhuazd > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("yuhuazd >=", value, "yuhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("yuhuazd >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazdLessThan(Integer value) {
            this.addCriterion("yuhuazd <", value, "yuhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazdLessThanColumn(Column column) {
            this.addCriterion("yuhuazd < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazdLessThanOrEqualTo(Integer value) {
            this.addCriterion("yuhuazd <=", value, "yuhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("yuhuazd <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazdIn(List<Integer> values) {
            this.addCriterion("yuhuazd in", values, "yuhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazdNotIn(List<Integer> values) {
            this.addCriterion("yuhuazd not in", values, "yuhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazdBetween(Integer value1, Integer value2) {
            this.addCriterion("yuhuazd between", value1, value2, "yuhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("yuhuazd not between", value1, value2, "yuhuazd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazxIsNull() {
            this.addCriterion("yuhuazx is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazxIsNotNull() {
            this.addCriterion("yuhuazx is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazxEqualTo(Integer value) {
            this.addCriterion("yuhuazx =", value, "yuhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazxEqualToColumn(Column column) {
            this.addCriterion("yuhuazx = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazxNotEqualTo(Integer value) {
            this.addCriterion("yuhuazx <>", value, "yuhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazxNotEqualToColumn(Column column) {
            this.addCriterion("yuhuazx <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazxGreaterThan(Integer value) {
            this.addCriterion("yuhuazx >", value, "yuhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazxGreaterThanColumn(Column column) {
            this.addCriterion("yuhuazx > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazxGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("yuhuazx >=", value, "yuhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazxGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("yuhuazx >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazxLessThan(Integer value) {
            this.addCriterion("yuhuazx <", value, "yuhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazxLessThanColumn(Column column) {
            this.addCriterion("yuhuazx < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazxLessThanOrEqualTo(Integer value) {
            this.addCriterion("yuhuazx <=", value, "yuhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazxLessThanOrEqualToColumn(Column column) {
            this.addCriterion("yuhuazx <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazxIn(List<Integer> values) {
            this.addCriterion("yuhuazx in", values, "yuhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazxNotIn(List<Integer> values) {
            this.addCriterion("yuhuazx not in", values, "yuhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazxBetween(Integer value1, Integer value2) {
            this.addCriterion("yuhuazx between", value1, value2, "yuhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andYuhuazxNotBetween(Integer value1, Integer value2) {
            this.addCriterion("yuhuazx not between", value1, value2, "yuhuazx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzxIsNull() {
            this.addCriterion("cwjyzx is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzxIsNotNull() {
            this.addCriterion("cwjyzx is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzxEqualTo(Integer value) {
            this.addCriterion("cwjyzx =", value, "cwjyzx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzxEqualToColumn(Column column) {
            this.addCriterion("cwjyzx = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzxNotEqualTo(Integer value) {
            this.addCriterion("cwjyzx <>", value, "cwjyzx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzxNotEqualToColumn(Column column) {
            this.addCriterion("cwjyzx <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzxGreaterThan(Integer value) {
            this.addCriterion("cwjyzx >", value, "cwjyzx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzxGreaterThanColumn(Column column) {
            this.addCriterion("cwjyzx > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzxGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("cwjyzx >=", value, "cwjyzx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzxGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("cwjyzx >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzxLessThan(Integer value) {
            this.addCriterion("cwjyzx <", value, "cwjyzx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzxLessThanColumn(Column column) {
            this.addCriterion("cwjyzx < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzxLessThanOrEqualTo(Integer value) {
            this.addCriterion("cwjyzx <=", value, "cwjyzx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzxLessThanOrEqualToColumn(Column column) {
            this.addCriterion("cwjyzx <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzxIn(List<Integer> values) {
            this.addCriterion("cwjyzx in", values, "cwjyzx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzxNotIn(List<Integer> values) {
            this.addCriterion("cwjyzx not in", values, "cwjyzx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzxBetween(Integer value1, Integer value2) {
            this.addCriterion("cwjyzx between", value1, value2, "cwjyzx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzxNotBetween(Integer value1, Integer value2) {
            this.addCriterion("cwjyzx not between", value1, value2, "cwjyzx");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzdIsNull() {
            this.addCriterion("cwjyzd is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzdIsNotNull() {
            this.addCriterion("cwjyzd is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzdEqualTo(Integer value) {
            this.addCriterion("cwjyzd =", value, "cwjyzd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzdEqualToColumn(Column column) {
            this.addCriterion("cwjyzd = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzdNotEqualTo(Integer value) {
            this.addCriterion("cwjyzd <>", value, "cwjyzd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzdNotEqualToColumn(Column column) {
            this.addCriterion("cwjyzd <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzdGreaterThan(Integer value) {
            this.addCriterion("cwjyzd >", value, "cwjyzd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzdGreaterThanColumn(Column column) {
            this.addCriterion("cwjyzd > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("cwjyzd >=", value, "cwjyzd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("cwjyzd >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzdLessThan(Integer value) {
            this.addCriterion("cwjyzd <", value, "cwjyzd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzdLessThanColumn(Column column) {
            this.addCriterion("cwjyzd < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzdLessThanOrEqualTo(Integer value) {
            this.addCriterion("cwjyzd <=", value, "cwjyzd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("cwjyzd <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzdIn(List<Integer> values) {
            this.addCriterion("cwjyzd in", values, "cwjyzd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzdNotIn(List<Integer> values) {
            this.addCriterion("cwjyzd not in", values, "cwjyzd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzdBetween(Integer value1, Integer value2) {
            this.addCriterion("cwjyzd between", value1, value2, "cwjyzd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwjyzdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("cwjyzd not between", value1, value2, "cwjyzd");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFeishengIsNull() {
            this.addCriterion("feisheng is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFeishengIsNotNull() {
            this.addCriterion("feisheng is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFeishengEqualTo(Integer value) {
            this.addCriterion("feisheng =", value, "feisheng");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFeishengEqualToColumn(Column column) {
            this.addCriterion("feisheng = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFeishengNotEqualTo(Integer value) {
            this.addCriterion("feisheng <>", value, "feisheng");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFeishengNotEqualToColumn(Column column) {
            this.addCriterion("feisheng <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFeishengGreaterThan(Integer value) {
            this.addCriterion("feisheng >", value, "feisheng");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFeishengGreaterThanColumn(Column column) {
            this.addCriterion("feisheng > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFeishengGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("feisheng >=", value, "feisheng");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFeishengGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("feisheng >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFeishengLessThan(Integer value) {
            this.addCriterion("feisheng <", value, "feisheng");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFeishengLessThanColumn(Column column) {
            this.addCriterion("feisheng < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFeishengLessThanOrEqualTo(Integer value) {
            this.addCriterion("feisheng <=", value, "feisheng");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFeishengLessThanOrEqualToColumn(Column column) {
            this.addCriterion("feisheng <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFeishengIn(List<Integer> values) {
            this.addCriterion("feisheng in", values, "feisheng");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFeishengNotIn(List<Integer> values) {
            this.addCriterion("feisheng not in", values, "feisheng");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFeishengBetween(Integer value1, Integer value2) {
            this.addCriterion("feisheng between", value1, value2, "feisheng");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFeishengNotBetween(Integer value1, Integer value2) {
            this.addCriterion("feisheng not between", value1, value2, "feisheng");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFsuduIsNull() {
            this.addCriterion("fsudu is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFsuduIsNotNull() {
            this.addCriterion("fsudu is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFsuduEqualTo(Integer value) {
            this.addCriterion("fsudu =", value, "fsudu");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFsuduEqualToColumn(Column column) {
            this.addCriterion("fsudu = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFsuduNotEqualTo(Integer value) {
            this.addCriterion("fsudu <>", value, "fsudu");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFsuduNotEqualToColumn(Column column) {
            this.addCriterion("fsudu <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFsuduGreaterThan(Integer value) {
            this.addCriterion("fsudu >", value, "fsudu");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFsuduGreaterThanColumn(Column column) {
            this.addCriterion("fsudu > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFsuduGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("fsudu >=", value, "fsudu");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFsuduGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("fsudu >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFsuduLessThan(Integer value) {
            this.addCriterion("fsudu <", value, "fsudu");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFsuduLessThanColumn(Column column) {
            this.addCriterion("fsudu < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFsuduLessThanOrEqualTo(Integer value) {
            this.addCriterion("fsudu <=", value, "fsudu");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFsuduLessThanOrEqualToColumn(Column column) {
            this.addCriterion("fsudu <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFsuduIn(List<Integer> values) {
            this.addCriterion("fsudu in", values, "fsudu");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFsuduNotIn(List<Integer> values) {
            this.addCriterion("fsudu not in", values, "fsudu");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFsuduBetween(Integer value1, Integer value2) {
            this.addCriterion("fsudu between", value1, value2, "fsudu");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andFsuduNotBetween(Integer value1, Integer value2) {
            this.addCriterion("fsudu not between", value1, value2, "fsudu");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwWgIsNull() {
            this.addCriterion("qhcw_wg is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwWgIsNotNull() {
            this.addCriterion("qhcw_wg is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwWgEqualTo(Integer value) {
            this.addCriterion("qhcw_wg =", value, "qhcwWg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwWgEqualToColumn(Column column) {
            this.addCriterion("qhcw_wg = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwWgNotEqualTo(Integer value) {
            this.addCriterion("qhcw_wg <>", value, "qhcwWg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwWgNotEqualToColumn(Column column) {
            this.addCriterion("qhcw_wg <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwWgGreaterThan(Integer value) {
            this.addCriterion("qhcw_wg >", value, "qhcwWg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwWgGreaterThanColumn(Column column) {
            this.addCriterion("qhcw_wg > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwWgGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("qhcw_wg >=", value, "qhcwWg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwWgGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("qhcw_wg >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwWgLessThan(Integer value) {
            this.addCriterion("qhcw_wg <", value, "qhcwWg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwWgLessThanColumn(Column column) {
            this.addCriterion("qhcw_wg < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwWgLessThanOrEqualTo(Integer value) {
            this.addCriterion("qhcw_wg <=", value, "qhcwWg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwWgLessThanOrEqualToColumn(Column column) {
            this.addCriterion("qhcw_wg <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwWgIn(List<Integer> values) {
            this.addCriterion("qhcw_wg in", values, "qhcwWg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwWgNotIn(List<Integer> values) {
            this.addCriterion("qhcw_wg not in", values, "qhcwWg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwWgBetween(Integer value1, Integer value2) {
            this.addCriterion("qhcw_wg between", value1, value2, "qhcwWg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwWgNotBetween(Integer value1, Integer value2) {
            this.addCriterion("qhcw_wg not between", value1, value2, "qhcwWg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwFgIsNull() {
            this.addCriterion("qhcw_fg is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwFgIsNotNull() {
            this.addCriterion("qhcw_fg is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwFgEqualTo(Integer value) {
            this.addCriterion("qhcw_fg =", value, "qhcwFg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwFgEqualToColumn(Column column) {
            this.addCriterion("qhcw_fg = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwFgNotEqualTo(Integer value) {
            this.addCriterion("qhcw_fg <>", value, "qhcwFg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwFgNotEqualToColumn(Column column) {
            this.addCriterion("qhcw_fg <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwFgGreaterThan(Integer value) {
            this.addCriterion("qhcw_fg >", value, "qhcwFg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwFgGreaterThanColumn(Column column) {
            this.addCriterion("qhcw_fg > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwFgGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("qhcw_fg >=", value, "qhcwFg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwFgGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("qhcw_fg >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwFgLessThan(Integer value) {
            this.addCriterion("qhcw_fg <", value, "qhcwFg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwFgLessThanColumn(Column column) {
            this.addCriterion("qhcw_fg < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwFgLessThanOrEqualTo(Integer value) {
            this.addCriterion("qhcw_fg <=", value, "qhcwFg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwFgLessThanOrEqualToColumn(Column column) {
            this.addCriterion("qhcw_fg <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwFgIn(List<Integer> values) {
            this.addCriterion("qhcw_fg in", values, "qhcwFg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwFgNotIn(List<Integer> values) {
            this.addCriterion("qhcw_fg not in", values, "qhcwFg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwFgBetween(Integer value1, Integer value2) {
            this.addCriterion("qhcw_fg between", value1, value2, "qhcwFg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andQhcwFgNotBetween(Integer value1, Integer value2) {
            this.addCriterion("qhcw_fg not between", value1, value2, "qhcwFg");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXiangxingIsNull() {
            this.addCriterion("cw_xiangxing is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXiangxingIsNotNull() {
            this.addCriterion("cw_xiangxing is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXiangxingEqualTo(Integer value) {
            this.addCriterion("cw_xiangxing =", value, "cwXiangxing");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXiangxingEqualToColumn(Column column) {
            this.addCriterion("cw_xiangxing = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXiangxingNotEqualTo(Integer value) {
            this.addCriterion("cw_xiangxing <>", value, "cwXiangxing");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXiangxingNotEqualToColumn(Column column) {
            this.addCriterion("cw_xiangxing <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXiangxingGreaterThan(Integer value) {
            this.addCriterion("cw_xiangxing >", value, "cwXiangxing");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXiangxingGreaterThanColumn(Column column) {
            this.addCriterion("cw_xiangxing > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXiangxingGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("cw_xiangxing >=", value, "cwXiangxing");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXiangxingGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("cw_xiangxing >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXiangxingLessThan(Integer value) {
            this.addCriterion("cw_xiangxing <", value, "cwXiangxing");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXiangxingLessThanColumn(Column column) {
            this.addCriterion("cw_xiangxing < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXiangxingLessThanOrEqualTo(Integer value) {
            this.addCriterion("cw_xiangxing <=", value, "cwXiangxing");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXiangxingLessThanOrEqualToColumn(Column column) {
            this.addCriterion("cw_xiangxing <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXiangxingIn(List<Integer> values) {
            this.addCriterion("cw_xiangxing in", values, "cwXiangxing");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXiangxingNotIn(List<Integer> values) {
            this.addCriterion("cw_xiangxing not in", values, "cwXiangxing");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXiangxingBetween(Integer value1, Integer value2) {
            this.addCriterion("cw_xiangxing between", value1, value2, "cwXiangxing");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXiangxingNotBetween(Integer value1, Integer value2) {
            this.addCriterion("cw_xiangxing not between", value1, value2, "cwXiangxing");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwWuxueIsNull() {
            this.addCriterion("cw_wuxue is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwWuxueIsNotNull() {
            this.addCriterion("cw_wuxue is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwWuxueEqualTo(Integer value) {
            this.addCriterion("cw_wuxue =", value, "cwWuxue");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwWuxueEqualToColumn(Column column) {
            this.addCriterion("cw_wuxue = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwWuxueNotEqualTo(Integer value) {
            this.addCriterion("cw_wuxue <>", value, "cwWuxue");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwWuxueNotEqualToColumn(Column column) {
            this.addCriterion("cw_wuxue <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwWuxueGreaterThan(Integer value) {
            this.addCriterion("cw_wuxue >", value, "cwWuxue");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwWuxueGreaterThanColumn(Column column) {
            this.addCriterion("cw_wuxue > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwWuxueGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("cw_wuxue >=", value, "cwWuxue");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwWuxueGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("cw_wuxue >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwWuxueLessThan(Integer value) {
            this.addCriterion("cw_wuxue <", value, "cwWuxue");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwWuxueLessThanColumn(Column column) {
            this.addCriterion("cw_wuxue < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwWuxueLessThanOrEqualTo(Integer value) {
            this.addCriterion("cw_wuxue <=", value, "cwWuxue");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwWuxueLessThanOrEqualToColumn(Column column) {
            this.addCriterion("cw_wuxue <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwWuxueIn(List<Integer> values) {
            this.addCriterion("cw_wuxue in", values, "cwWuxue");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwWuxueNotIn(List<Integer> values) {
            this.addCriterion("cw_wuxue not in", values, "cwWuxue");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwWuxueBetween(Integer value1, Integer value2) {
            this.addCriterion("cw_wuxue between", value1, value2, "cwWuxue");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwWuxueNotBetween(Integer value1, Integer value2) {
            this.addCriterion("cw_wuxue not between", value1, value2, "cwWuxue");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconIsNull() {
            this.addCriterion("cw_icon is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconIsNotNull() {
            this.addCriterion("cw_icon is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconEqualTo(String value) {
            this.addCriterion("cw_icon =", value, "cwIcon");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconEqualToColumn(Column column) {
            this.addCriterion("cw_icon = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconNotEqualTo(String value) {
            this.addCriterion("cw_icon <>", value, "cwIcon");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconNotEqualToColumn(Column column) {
            this.addCriterion("cw_icon <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconGreaterThan(String value) {
            this.addCriterion("cw_icon >", value, "cwIcon");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconGreaterThanColumn(Column column) {
            this.addCriterion("cw_icon > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconGreaterThanOrEqualTo(String value) {
            this.addCriterion("cw_icon >=", value, "cwIcon");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("cw_icon >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconLessThan(String value) {
            this.addCriterion("cw_icon <", value, "cwIcon");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconLessThanColumn(Column column) {
            this.addCriterion("cw_icon < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconLessThanOrEqualTo(String value) {
            this.addCriterion("cw_icon <=", value, "cwIcon");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconLessThanOrEqualToColumn(Column column) {
            this.addCriterion("cw_icon <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconLike(String value) {
            this.addCriterion("cw_icon like", value, "cwIcon");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconNotLike(String value) {
            this.addCriterion("cw_icon not like", value, "cwIcon");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconIn(List<String> values) {
            this.addCriterion("cw_icon in", values, "cwIcon");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconNotIn(List<String> values) {
            this.addCriterion("cw_icon not in", values, "cwIcon");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconBetween(String value1, String value2) {
            this.addCriterion("cw_icon between", value1, value2, "cwIcon");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwIconNotBetween(String value1, String value2) {
            this.addCriterion("cw_icon not between", value1, value2, "cwIcon");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXinfaIsNull() {
            this.addCriterion("cw_xinfa is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXinfaIsNotNull() {
            this.addCriterion("cw_xinfa is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXinfaEqualTo(Integer value) {
            this.addCriterion("cw_xinfa =", value, "cwXinfa");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXinfaEqualToColumn(Column column) {
            this.addCriterion("cw_xinfa = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXinfaNotEqualTo(Integer value) {
            this.addCriterion("cw_xinfa <>", value, "cwXinfa");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXinfaNotEqualToColumn(Column column) {
            this.addCriterion("cw_xinfa <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXinfaGreaterThan(Integer value) {
            this.addCriterion("cw_xinfa >", value, "cwXinfa");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXinfaGreaterThanColumn(Column column) {
            this.addCriterion("cw_xinfa > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXinfaGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("cw_xinfa >=", value, "cwXinfa");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXinfaGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("cw_xinfa >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXinfaLessThan(Integer value) {
            this.addCriterion("cw_xinfa <", value, "cwXinfa");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXinfaLessThanColumn(Column column) {
            this.addCriterion("cw_xinfa < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXinfaLessThanOrEqualTo(Integer value) {
            this.addCriterion("cw_xinfa <=", value, "cwXinfa");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXinfaLessThanOrEqualToColumn(Column column) {
            this.addCriterion("cw_xinfa <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXinfaIn(List<Integer> values) {
            this.addCriterion("cw_xinfa in", values, "cwXinfa");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXinfaNotIn(List<Integer> values) {
            this.addCriterion("cw_xinfa not in", values, "cwXinfa");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXinfaBetween(Integer value1, Integer value2) {
            this.addCriterion("cw_xinfa between", value1, value2, "cwXinfa");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwXinfaNotBetween(Integer value1, Integer value2) {
            this.addCriterion("cw_xinfa not between", value1, value2, "cwXinfa");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwQinmiIsNull() {
            this.addCriterion("cw_qinmi is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwQinmiIsNotNull() {
            this.addCriterion("cw_qinmi is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwQinmiEqualTo(Integer value) {
            this.addCriterion("cw_qinmi =", value, "cwQinmi");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwQinmiEqualToColumn(Column column) {
            this.addCriterion("cw_qinmi = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwQinmiNotEqualTo(Integer value) {
            this.addCriterion("cw_qinmi <>", value, "cwQinmi");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwQinmiNotEqualToColumn(Column column) {
            this.addCriterion("cw_qinmi <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwQinmiGreaterThan(Integer value) {
            this.addCriterion("cw_qinmi >", value, "cwQinmi");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwQinmiGreaterThanColumn(Column column) {
            this.addCriterion("cw_qinmi > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwQinmiGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("cw_qinmi >=", value, "cwQinmi");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwQinmiGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("cw_qinmi >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwQinmiLessThan(Integer value) {
            this.addCriterion("cw_qinmi <", value, "cwQinmi");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwQinmiLessThanColumn(Column column) {
            this.addCriterion("cw_qinmi < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwQinmiLessThanOrEqualTo(Integer value) {
            this.addCriterion("cw_qinmi <=", value, "cwQinmi");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwQinmiLessThanOrEqualToColumn(Column column) {
            this.addCriterion("cw_qinmi <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwQinmiIn(List<Integer> values) {
            this.addCriterion("cw_qinmi in", values, "cwQinmi");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwQinmiNotIn(List<Integer> values) {
            this.addCriterion("cw_qinmi not in", values, "cwQinmi");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwQinmiBetween(Integer value1, Integer value2) {
            this.addCriterion("cw_qinmi between", value1, value2, "cwQinmi");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andCwQinmiNotBetween(Integer value1, Integer value2) {
            this.addCriterion("cw_qinmi not between", value1, value2, "cwQinmi");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (PetsExample.Criteria)this;
        }

        public PetsExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (PetsExample.Criteria)this;
        }
    }
}
