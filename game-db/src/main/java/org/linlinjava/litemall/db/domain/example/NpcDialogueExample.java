//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.NpcDialogue.Column;
import org.linlinjava.litemall.db.domain.NpcDialogue.Deleted;

public class NpcDialogueExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<NpcDialogueExample.Criteria> oredCriteria = new ArrayList();

    public NpcDialogueExample() {
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

    public List<NpcDialogueExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(NpcDialogueExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public NpcDialogueExample.Criteria or() {
        NpcDialogueExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public NpcDialogueExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public NpcDialogueExample orderBy(String... orderByClauses) {
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

    public NpcDialogueExample.Criteria createCriteria() {
        NpcDialogueExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected NpcDialogueExample.Criteria createCriteriaInternal() {
        NpcDialogueExample.Criteria criteria = new NpcDialogueExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static NpcDialogueExample.Criteria newAndCreateCriteria() {
        NpcDialogueExample example = new NpcDialogueExample();
        return example.createCriteria();
    }

    public NpcDialogueExample when(boolean condition, NpcDialogueExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public NpcDialogueExample when(boolean condition, NpcDialogueExample.IExampleWhen then, NpcDialogueExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(NpcDialogueExample example);
    }

    public interface ICriteriaWhen {
        void criteria(NpcDialogueExample.Criteria criteria);
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

    public static class Criteria extends NpcDialogueExample.GeneratedCriteria {
        private NpcDialogueExample example;

        protected Criteria(NpcDialogueExample example) {
            this.example = example;
        }

        public NpcDialogueExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public NpcDialogueExample.Criteria andIf(boolean ifAdd, NpcDialogueExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public NpcDialogueExample.Criteria when(boolean condition, NpcDialogueExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public NpcDialogueExample.Criteria when(boolean condition, NpcDialogueExample.ICriteriaWhen then, NpcDialogueExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public NpcDialogueExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            NpcDialogueExample.Criteria add(NpcDialogueExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<NpcDialogueExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<NpcDialogueExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<NpcDialogueExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new NpcDialogueExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new NpcDialogueExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new NpcDialogueExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public NpcDialogueExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPortranitIsNull() {
            this.addCriterion("portranit is null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPortranitIsNotNull() {
            this.addCriterion("portranit is not null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPortranitEqualTo(Integer value) {
            this.addCriterion("portranit =", value, "portranit");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPortranitEqualToColumn(Column column) {
            this.addCriterion("portranit = " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPortranitNotEqualTo(Integer value) {
            this.addCriterion("portranit <>", value, "portranit");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPortranitNotEqualToColumn(Column column) {
            this.addCriterion("portranit <> " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPortranitGreaterThan(Integer value) {
            this.addCriterion("portranit >", value, "portranit");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPortranitGreaterThanColumn(Column column) {
            this.addCriterion("portranit > " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPortranitGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("portranit >=", value, "portranit");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPortranitGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("portranit >= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPortranitLessThan(Integer value) {
            this.addCriterion("portranit <", value, "portranit");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPortranitLessThanColumn(Column column) {
            this.addCriterion("portranit < " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPortranitLessThanOrEqualTo(Integer value) {
            this.addCriterion("portranit <=", value, "portranit");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPortranitLessThanOrEqualToColumn(Column column) {
            this.addCriterion("portranit <= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPortranitIn(List<Integer> values) {
            this.addCriterion("portranit in", values, "portranit");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPortranitNotIn(List<Integer> values) {
            this.addCriterion("portranit not in", values, "portranit");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPortranitBetween(Integer value1, Integer value2) {
            this.addCriterion("portranit between", value1, value2, "portranit");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPortranitNotBetween(Integer value1, Integer value2) {
            this.addCriterion("portranit not between", value1, value2, "portranit");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPicNoIsNull() {
            this.addCriterion("pic_no is null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPicNoIsNotNull() {
            this.addCriterion("pic_no is not null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPicNoEqualTo(Integer value) {
            this.addCriterion("pic_no =", value, "picNo");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPicNoEqualToColumn(Column column) {
            this.addCriterion("pic_no = " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPicNoNotEqualTo(Integer value) {
            this.addCriterion("pic_no <>", value, "picNo");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPicNoNotEqualToColumn(Column column) {
            this.addCriterion("pic_no <> " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPicNoGreaterThan(Integer value) {
            this.addCriterion("pic_no >", value, "picNo");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPicNoGreaterThanColumn(Column column) {
            this.addCriterion("pic_no > " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPicNoGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("pic_no >=", value, "picNo");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPicNoGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("pic_no >= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPicNoLessThan(Integer value) {
            this.addCriterion("pic_no <", value, "picNo");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPicNoLessThanColumn(Column column) {
            this.addCriterion("pic_no < " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPicNoLessThanOrEqualTo(Integer value) {
            this.addCriterion("pic_no <=", value, "picNo");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPicNoLessThanOrEqualToColumn(Column column) {
            this.addCriterion("pic_no <= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPicNoIn(List<Integer> values) {
            this.addCriterion("pic_no in", values, "picNo");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPicNoNotIn(List<Integer> values) {
            this.addCriterion("pic_no not in", values, "picNo");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPicNoBetween(Integer value1, Integer value2) {
            this.addCriterion("pic_no between", value1, value2, "picNo");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPicNoNotBetween(Integer value1, Integer value2) {
            this.addCriterion("pic_no not between", value1, value2, "picNo");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentIsNull() {
            this.addCriterion("content is null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentIsNotNull() {
            this.addCriterion("content is not null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentEqualTo(String value) {
            this.addCriterion("content =", value, "content");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentEqualToColumn(Column column) {
            this.addCriterion("content = " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentNotEqualTo(String value) {
            this.addCriterion("content <>", value, "content");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentNotEqualToColumn(Column column) {
            this.addCriterion("content <> " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentGreaterThan(String value) {
            this.addCriterion("content >", value, "content");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentGreaterThanColumn(Column column) {
            this.addCriterion("content > " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentGreaterThanOrEqualTo(String value) {
            this.addCriterion("content >=", value, "content");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("content >= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentLessThan(String value) {
            this.addCriterion("content <", value, "content");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentLessThanColumn(Column column) {
            this.addCriterion("content < " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentLessThanOrEqualTo(String value) {
            this.addCriterion("content <=", value, "content");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentLessThanOrEqualToColumn(Column column) {
            this.addCriterion("content <= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentLike(String value) {
            this.addCriterion("content like", value, "content");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentNotLike(String value) {
            this.addCriterion("content not like", value, "content");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentIn(List<String> values) {
            this.addCriterion("content in", values, "content");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentNotIn(List<String> values) {
            this.addCriterion("content not in", values, "content");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentBetween(String value1, String value2) {
            this.addCriterion("content between", value1, value2, "content");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andContentNotBetween(String value1, String value2) {
            this.addCriterion("content not between", value1, value2, "content");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsconmleteIsNull() {
            this.addCriterion("isconmlete is null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsconmleteIsNotNull() {
            this.addCriterion("isconmlete is not null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsconmleteEqualTo(Integer value) {
            this.addCriterion("isconmlete =", value, "isconmlete");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsconmleteEqualToColumn(Column column) {
            this.addCriterion("isconmlete = " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsconmleteNotEqualTo(Integer value) {
            this.addCriterion("isconmlete <>", value, "isconmlete");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsconmleteNotEqualToColumn(Column column) {
            this.addCriterion("isconmlete <> " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsconmleteGreaterThan(Integer value) {
            this.addCriterion("isconmlete >", value, "isconmlete");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsconmleteGreaterThanColumn(Column column) {
            this.addCriterion("isconmlete > " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsconmleteGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("isconmlete >=", value, "isconmlete");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsconmleteGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("isconmlete >= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsconmleteLessThan(Integer value) {
            this.addCriterion("isconmlete <", value, "isconmlete");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsconmleteLessThanColumn(Column column) {
            this.addCriterion("isconmlete < " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsconmleteLessThanOrEqualTo(Integer value) {
            this.addCriterion("isconmlete <=", value, "isconmlete");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsconmleteLessThanOrEqualToColumn(Column column) {
            this.addCriterion("isconmlete <= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsconmleteIn(List<Integer> values) {
            this.addCriterion("isconmlete in", values, "isconmlete");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsconmleteNotIn(List<Integer> values) {
            this.addCriterion("isconmlete not in", values, "isconmlete");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsconmleteBetween(Integer value1, Integer value2) {
            this.addCriterion("isconmlete between", value1, value2, "isconmlete");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsconmleteNotBetween(Integer value1, Integer value2) {
            this.addCriterion("isconmlete not between", value1, value2, "isconmlete");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsincombatIsNull() {
            this.addCriterion("isincombat is null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsincombatIsNotNull() {
            this.addCriterion("isincombat is not null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsincombatEqualTo(Integer value) {
            this.addCriterion("isincombat =", value, "isincombat");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsincombatEqualToColumn(Column column) {
            this.addCriterion("isincombat = " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsincombatNotEqualTo(Integer value) {
            this.addCriterion("isincombat <>", value, "isincombat");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsincombatNotEqualToColumn(Column column) {
            this.addCriterion("isincombat <> " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsincombatGreaterThan(Integer value) {
            this.addCriterion("isincombat >", value, "isincombat");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsincombatGreaterThanColumn(Column column) {
            this.addCriterion("isincombat > " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsincombatGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("isincombat >=", value, "isincombat");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsincombatGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("isincombat >= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsincombatLessThan(Integer value) {
            this.addCriterion("isincombat <", value, "isincombat");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsincombatLessThanColumn(Column column) {
            this.addCriterion("isincombat < " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsincombatLessThanOrEqualTo(Integer value) {
            this.addCriterion("isincombat <=", value, "isincombat");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsincombatLessThanOrEqualToColumn(Column column) {
            this.addCriterion("isincombat <= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsincombatIn(List<Integer> values) {
            this.addCriterion("isincombat in", values, "isincombat");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsincombatNotIn(List<Integer> values) {
            this.addCriterion("isincombat not in", values, "isincombat");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsincombatBetween(Integer value1, Integer value2) {
            this.addCriterion("isincombat between", value1, value2, "isincombat");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIsincombatNotBetween(Integer value1, Integer value2) {
            this.addCriterion("isincombat not between", value1, value2, "isincombat");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPalytimeIsNull() {
            this.addCriterion("palytime is null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPalytimeIsNotNull() {
            this.addCriterion("palytime is not null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPalytimeEqualTo(Integer value) {
            this.addCriterion("palytime =", value, "palytime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPalytimeEqualToColumn(Column column) {
            this.addCriterion("palytime = " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPalytimeNotEqualTo(Integer value) {
            this.addCriterion("palytime <>", value, "palytime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPalytimeNotEqualToColumn(Column column) {
            this.addCriterion("palytime <> " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPalytimeGreaterThan(Integer value) {
            this.addCriterion("palytime >", value, "palytime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPalytimeGreaterThanColumn(Column column) {
            this.addCriterion("palytime > " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPalytimeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("palytime >=", value, "palytime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPalytimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("palytime >= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPalytimeLessThan(Integer value) {
            this.addCriterion("palytime <", value, "palytime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPalytimeLessThanColumn(Column column) {
            this.addCriterion("palytime < " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPalytimeLessThanOrEqualTo(Integer value) {
            this.addCriterion("palytime <=", value, "palytime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPalytimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("palytime <= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPalytimeIn(List<Integer> values) {
            this.addCriterion("palytime in", values, "palytime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPalytimeNotIn(List<Integer> values) {
            this.addCriterion("palytime not in", values, "palytime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPalytimeBetween(Integer value1, Integer value2) {
            this.addCriterion("palytime between", value1, value2, "palytime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andPalytimeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("palytime not between", value1, value2, "palytime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeIsNull() {
            this.addCriterion("task_type is null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeIsNotNull() {
            this.addCriterion("task_type is not null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeEqualTo(String value) {
            this.addCriterion("task_type =", value, "taskType");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeEqualToColumn(Column column) {
            this.addCriterion("task_type = " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeNotEqualTo(String value) {
            this.addCriterion("task_type <>", value, "taskType");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeNotEqualToColumn(Column column) {
            this.addCriterion("task_type <> " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeGreaterThan(String value) {
            this.addCriterion("task_type >", value, "taskType");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeGreaterThanColumn(Column column) {
            this.addCriterion("task_type > " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeGreaterThanOrEqualTo(String value) {
            this.addCriterion("task_type >=", value, "taskType");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("task_type >= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeLessThan(String value) {
            this.addCriterion("task_type <", value, "taskType");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeLessThanColumn(Column column) {
            this.addCriterion("task_type < " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeLessThanOrEqualTo(String value) {
            this.addCriterion("task_type <=", value, "taskType");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("task_type <= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeLike(String value) {
            this.addCriterion("task_type like", value, "taskType");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeNotLike(String value) {
            this.addCriterion("task_type not like", value, "taskType");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeIn(List<String> values) {
            this.addCriterion("task_type in", values, "taskType");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeNotIn(List<String> values) {
            this.addCriterion("task_type not in", values, "taskType");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeBetween(String value1, String value2) {
            this.addCriterion("task_type between", value1, value2, "taskType");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andTaskTypeNotBetween(String value1, String value2) {
            this.addCriterion("task_type not between", value1, value2, "taskType");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameIsNull() {
            this.addCriterion("idname is null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameIsNotNull() {
            this.addCriterion("idname is not null");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameEqualTo(String value) {
            this.addCriterion("idname =", value, "idname");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameEqualToColumn(Column column) {
            this.addCriterion("idname = " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameNotEqualTo(String value) {
            this.addCriterion("idname <>", value, "idname");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameNotEqualToColumn(Column column) {
            this.addCriterion("idname <> " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameGreaterThan(String value) {
            this.addCriterion("idname >", value, "idname");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameGreaterThanColumn(Column column) {
            this.addCriterion("idname > " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameGreaterThanOrEqualTo(String value) {
            this.addCriterion("idname >=", value, "idname");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("idname >= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameLessThan(String value) {
            this.addCriterion("idname <", value, "idname");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameLessThanColumn(Column column) {
            this.addCriterion("idname < " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameLessThanOrEqualTo(String value) {
            this.addCriterion("idname <=", value, "idname");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("idname <= " + column.getEscapedColumnName());
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameLike(String value) {
            this.addCriterion("idname like", value, "idname");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameNotLike(String value) {
            this.addCriterion("idname not like", value, "idname");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameIn(List<String> values) {
            this.addCriterion("idname in", values, "idname");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameNotIn(List<String> values) {
            this.addCriterion("idname not in", values, "idname");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameBetween(String value1, String value2) {
            this.addCriterion("idname between", value1, value2, "idname");
            return (NpcDialogueExample.Criteria)this;
        }

        public NpcDialogueExample.Criteria andIdnameNotBetween(String value1, String value2) {
            this.addCriterion("idname not between", value1, value2, "idname");
            return (NpcDialogueExample.Criteria)this;
        }
    }
}
