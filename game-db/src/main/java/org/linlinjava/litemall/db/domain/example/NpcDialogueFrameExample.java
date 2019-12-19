//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.NpcDialogueFrame.Column;
import org.linlinjava.litemall.db.domain.NpcDialogueFrame.Deleted;

public class NpcDialogueFrameExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<NpcDialogueFrameExample.Criteria> oredCriteria = new ArrayList();

    public NpcDialogueFrameExample() {
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

    public List<NpcDialogueFrameExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(NpcDialogueFrameExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public NpcDialogueFrameExample.Criteria or() {
        NpcDialogueFrameExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public NpcDialogueFrameExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public NpcDialogueFrameExample orderBy(String... orderByClauses) {
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

    public NpcDialogueFrameExample.Criteria createCriteria() {
        NpcDialogueFrameExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected NpcDialogueFrameExample.Criteria createCriteriaInternal() {
        NpcDialogueFrameExample.Criteria criteria = new NpcDialogueFrameExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static NpcDialogueFrameExample.Criteria newAndCreateCriteria() {
        NpcDialogueFrameExample example = new NpcDialogueFrameExample();
        return example.createCriteria();
    }

    public NpcDialogueFrameExample when(boolean condition, NpcDialogueFrameExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public NpcDialogueFrameExample when(boolean condition, NpcDialogueFrameExample.IExampleWhen then, NpcDialogueFrameExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(NpcDialogueFrameExample example);
    }

    public interface ICriteriaWhen {
        void criteria(NpcDialogueFrameExample.Criteria criteria);
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

    public static class Criteria extends NpcDialogueFrameExample.GeneratedCriteria {
        private NpcDialogueFrameExample example;

        protected Criteria(NpcDialogueFrameExample example) {
            this.example = example;
        }

        public NpcDialogueFrameExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public NpcDialogueFrameExample.Criteria andIf(boolean ifAdd, NpcDialogueFrameExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public NpcDialogueFrameExample.Criteria when(boolean condition, NpcDialogueFrameExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public NpcDialogueFrameExample.Criteria when(boolean condition, NpcDialogueFrameExample.ICriteriaWhen then, NpcDialogueFrameExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public NpcDialogueFrameExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            NpcDialogueFrameExample.Criteria add(NpcDialogueFrameExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<NpcDialogueFrameExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<NpcDialogueFrameExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<NpcDialogueFrameExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new NpcDialogueFrameExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new NpcDialogueFrameExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new NpcDialogueFrameExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public NpcDialogueFrameExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPortraitIsNull() {
            this.addCriterion("portrait is null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPortraitIsNotNull() {
            this.addCriterion("portrait is not null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPortraitEqualTo(Integer value) {
            this.addCriterion("portrait =", value, "portrait");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPortraitEqualToColumn(Column column) {
            this.addCriterion("portrait = " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPortraitNotEqualTo(Integer value) {
            this.addCriterion("portrait <>", value, "portrait");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPortraitNotEqualToColumn(Column column) {
            this.addCriterion("portrait <> " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPortraitGreaterThan(Integer value) {
            this.addCriterion("portrait >", value, "portrait");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPortraitGreaterThanColumn(Column column) {
            this.addCriterion("portrait > " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPortraitGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("portrait >=", value, "portrait");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPortraitGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("portrait >= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPortraitLessThan(Integer value) {
            this.addCriterion("portrait <", value, "portrait");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPortraitLessThanColumn(Column column) {
            this.addCriterion("portrait < " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPortraitLessThanOrEqualTo(Integer value) {
            this.addCriterion("portrait <=", value, "portrait");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPortraitLessThanOrEqualToColumn(Column column) {
            this.addCriterion("portrait <= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPortraitIn(List<Integer> values) {
            this.addCriterion("portrait in", values, "portrait");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPortraitNotIn(List<Integer> values) {
            this.addCriterion("portrait not in", values, "portrait");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPortraitBetween(Integer value1, Integer value2) {
            this.addCriterion("portrait between", value1, value2, "portrait");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPortraitNotBetween(Integer value1, Integer value2) {
            this.addCriterion("portrait not between", value1, value2, "portrait");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPicNoIsNull() {
            this.addCriterion("pic_no is null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPicNoIsNotNull() {
            this.addCriterion("pic_no is not null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPicNoEqualTo(Integer value) {
            this.addCriterion("pic_no =", value, "picNo");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPicNoEqualToColumn(Column column) {
            this.addCriterion("pic_no = " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPicNoNotEqualTo(Integer value) {
            this.addCriterion("pic_no <>", value, "picNo");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPicNoNotEqualToColumn(Column column) {
            this.addCriterion("pic_no <> " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPicNoGreaterThan(Integer value) {
            this.addCriterion("pic_no >", value, "picNo");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPicNoGreaterThanColumn(Column column) {
            this.addCriterion("pic_no > " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPicNoGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("pic_no >=", value, "picNo");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPicNoGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("pic_no >= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPicNoLessThan(Integer value) {
            this.addCriterion("pic_no <", value, "picNo");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPicNoLessThanColumn(Column column) {
            this.addCriterion("pic_no < " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPicNoLessThanOrEqualTo(Integer value) {
            this.addCriterion("pic_no <=", value, "picNo");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPicNoLessThanOrEqualToColumn(Column column) {
            this.addCriterion("pic_no <= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPicNoIn(List<Integer> values) {
            this.addCriterion("pic_no in", values, "picNo");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPicNoNotIn(List<Integer> values) {
            this.addCriterion("pic_no not in", values, "picNo");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPicNoBetween(Integer value1, Integer value2) {
            this.addCriterion("pic_no between", value1, value2, "picNo");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andPicNoNotBetween(Integer value1, Integer value2) {
            this.addCriterion("pic_no not between", value1, value2, "picNo");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentIsNull() {
            this.addCriterion("content is null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentIsNotNull() {
            this.addCriterion("content is not null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentEqualTo(String value) {
            this.addCriterion("content =", value, "content");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentEqualToColumn(Column column) {
            this.addCriterion("content = " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentNotEqualTo(String value) {
            this.addCriterion("content <>", value, "content");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentNotEqualToColumn(Column column) {
            this.addCriterion("content <> " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentGreaterThan(String value) {
            this.addCriterion("content >", value, "content");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentGreaterThanColumn(Column column) {
            this.addCriterion("content > " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentGreaterThanOrEqualTo(String value) {
            this.addCriterion("content >=", value, "content");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("content >= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentLessThan(String value) {
            this.addCriterion("content <", value, "content");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentLessThanColumn(Column column) {
            this.addCriterion("content < " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentLessThanOrEqualTo(String value) {
            this.addCriterion("content <=", value, "content");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentLessThanOrEqualToColumn(Column column) {
            this.addCriterion("content <= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentLike(String value) {
            this.addCriterion("content like", value, "content");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentNotLike(String value) {
            this.addCriterion("content not like", value, "content");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentIn(List<String> values) {
            this.addCriterion("content in", values, "content");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentNotIn(List<String> values) {
            this.addCriterion("content not in", values, "content");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentBetween(String value1, String value2) {
            this.addCriterion("content between", value1, value2, "content");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andContentNotBetween(String value1, String value2) {
            this.addCriterion("content not between", value1, value2, "content");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyIsNull() {
            this.addCriterion("secret_key is null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyIsNotNull() {
            this.addCriterion("secret_key is not null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyEqualTo(String value) {
            this.addCriterion("secret_key =", value, "secretKey");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyEqualToColumn(Column column) {
            this.addCriterion("secret_key = " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyNotEqualTo(String value) {
            this.addCriterion("secret_key <>", value, "secretKey");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyNotEqualToColumn(Column column) {
            this.addCriterion("secret_key <> " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyGreaterThan(String value) {
            this.addCriterion("secret_key >", value, "secretKey");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyGreaterThanColumn(Column column) {
            this.addCriterion("secret_key > " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyGreaterThanOrEqualTo(String value) {
            this.addCriterion("secret_key >=", value, "secretKey");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("secret_key >= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyLessThan(String value) {
            this.addCriterion("secret_key <", value, "secretKey");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyLessThanColumn(Column column) {
            this.addCriterion("secret_key < " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyLessThanOrEqualTo(String value) {
            this.addCriterion("secret_key <=", value, "secretKey");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyLessThanOrEqualToColumn(Column column) {
            this.addCriterion("secret_key <= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyLike(String value) {
            this.addCriterion("secret_key like", value, "secretKey");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyNotLike(String value) {
            this.addCriterion("secret_key not like", value, "secretKey");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyIn(List<String> values) {
            this.addCriterion("secret_key in", values, "secretKey");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyNotIn(List<String> values) {
            this.addCriterion("secret_key not in", values, "secretKey");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyBetween(String value1, String value2) {
            this.addCriterion("secret_key between", value1, value2, "secretKey");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andSecretKeyNotBetween(String value1, String value2) {
            this.addCriterion("secret_key not between", value1, value2, "secretKey");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameIsNull() {
            this.addCriterion("`name` is null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameIsNotNull() {
            this.addCriterion("`name` is not null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameEqualTo(String value) {
            this.addCriterion("`name` =", value, "name");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameEqualToColumn(Column column) {
            this.addCriterion("`name` = " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameNotEqualTo(String value) {
            this.addCriterion("`name` <>", value, "name");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameNotEqualToColumn(Column column) {
            this.addCriterion("`name` <> " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameGreaterThan(String value) {
            this.addCriterion("`name` >", value, "name");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameGreaterThanColumn(Column column) {
            this.addCriterion("`name` > " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("`name` >=", value, "name");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` >= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameLessThan(String value) {
            this.addCriterion("`name` <", value, "name");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameLessThanColumn(Column column) {
            this.addCriterion("`name` < " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameLessThanOrEqualTo(String value) {
            this.addCriterion("`name` <=", value, "name");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`name` <= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameLike(String value) {
            this.addCriterion("`name` like", value, "name");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameNotLike(String value) {
            this.addCriterion("`name` not like", value, "name");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameIn(List<String> values) {
            this.addCriterion("`name` in", values, "name");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameNotIn(List<String> values) {
            this.addCriterion("`name` not in", values, "name");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameBetween(String value1, String value2) {
            this.addCriterion("`name` between", value1, value2, "name");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNameNotBetween(String value1, String value2) {
            this.addCriterion("`name` not between", value1, value2, "name");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAttribIsNull() {
            this.addCriterion("attrib is null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAttribIsNotNull() {
            this.addCriterion("attrib is not null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAttribEqualTo(Integer value) {
            this.addCriterion("attrib =", value, "attrib");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAttribEqualToColumn(Column column) {
            this.addCriterion("attrib = " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAttribNotEqualTo(Integer value) {
            this.addCriterion("attrib <>", value, "attrib");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAttribNotEqualToColumn(Column column) {
            this.addCriterion("attrib <> " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAttribGreaterThan(Integer value) {
            this.addCriterion("attrib >", value, "attrib");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAttribGreaterThanColumn(Column column) {
            this.addCriterion("attrib > " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAttribGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("attrib >=", value, "attrib");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAttribGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("attrib >= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAttribLessThan(Integer value) {
            this.addCriterion("attrib <", value, "attrib");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAttribLessThanColumn(Column column) {
            this.addCriterion("attrib < " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAttribLessThanOrEqualTo(Integer value) {
            this.addCriterion("attrib <=", value, "attrib");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAttribLessThanOrEqualToColumn(Column column) {
            this.addCriterion("attrib <= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAttribIn(List<Integer> values) {
            this.addCriterion("attrib in", values, "attrib");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAttribNotIn(List<Integer> values) {
            this.addCriterion("attrib not in", values, "attrib");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAttribBetween(Integer value1, Integer value2) {
            this.addCriterion("attrib between", value1, value2, "attrib");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAttribNotBetween(Integer value1, Integer value2) {
            this.addCriterion("attrib not between", value1, value2, "attrib");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimesIsNull() {
            this.addCriterion("update_times is null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimesIsNotNull() {
            this.addCriterion("update_times is not null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimesEqualTo(LocalDateTime value) {
            this.addCriterion("update_times =", value, "updateTimes");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimesEqualToColumn(Column column) {
            this.addCriterion("update_times = " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimesNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_times <>", value, "updateTimes");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimesNotEqualToColumn(Column column) {
            this.addCriterion("update_times <> " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimesGreaterThan(LocalDateTime value) {
            this.addCriterion("update_times >", value, "updateTimes");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimesGreaterThanColumn(Column column) {
            this.addCriterion("update_times > " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimesGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_times >=", value, "updateTimes");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimesGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_times >= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimesLessThan(LocalDateTime value) {
            this.addCriterion("update_times <", value, "updateTimes");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimesLessThanColumn(Column column) {
            this.addCriterion("update_times < " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimesLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_times <=", value, "updateTimes");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimesLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_times <= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimesIn(List<LocalDateTime> values) {
            this.addCriterion("update_times in", values, "updateTimes");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimesNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_times not in", values, "updateTimes");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimesBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_times between", value1, value2, "updateTimes");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimesNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_times not between", value1, value2, "updateTimes");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdnameIsNull() {
            this.addCriterion("idname is null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdnameIsNotNull() {
            this.addCriterion("idname is not null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdnameEqualTo(Integer value) {
            this.addCriterion("idname =", value, "idname");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdnameEqualToColumn(Column column) {
            this.addCriterion("idname = " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdnameNotEqualTo(Integer value) {
            this.addCriterion("idname <>", value, "idname");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdnameNotEqualToColumn(Column column) {
            this.addCriterion("idname <> " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdnameGreaterThan(Integer value) {
            this.addCriterion("idname >", value, "idname");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdnameGreaterThanColumn(Column column) {
            this.addCriterion("idname > " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdnameGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("idname >=", value, "idname");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdnameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("idname >= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdnameLessThan(Integer value) {
            this.addCriterion("idname <", value, "idname");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdnameLessThanColumn(Column column) {
            this.addCriterion("idname < " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdnameLessThanOrEqualTo(Integer value) {
            this.addCriterion("idname <=", value, "idname");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdnameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("idname <= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdnameIn(List<Integer> values) {
            this.addCriterion("idname in", values, "idname");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdnameNotIn(List<Integer> values) {
            this.addCriterion("idname not in", values, "idname");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdnameBetween(Integer value1, Integer value2) {
            this.addCriterion("idname between", value1, value2, "idname");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andIdnameNotBetween(Integer value1, Integer value2) {
            this.addCriterion("idname not between", value1, value2, "idname");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextIsNull() {
            this.addCriterion("`next` is null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextIsNotNull() {
            this.addCriterion("`next` is not null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextEqualTo(String value) {
            this.addCriterion("`next` =", value, "next");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextEqualToColumn(Column column) {
            this.addCriterion("`next` = " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextNotEqualTo(String value) {
            this.addCriterion("`next` <>", value, "next");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextNotEqualToColumn(Column column) {
            this.addCriterion("`next` <> " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextGreaterThan(String value) {
            this.addCriterion("`next` >", value, "next");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextGreaterThanColumn(Column column) {
            this.addCriterion("`next` > " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextGreaterThanOrEqualTo(String value) {
            this.addCriterion("`next` >=", value, "next");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("`next` >= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextLessThan(String value) {
            this.addCriterion("`next` <", value, "next");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextLessThanColumn(Column column) {
            this.addCriterion("`next` < " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextLessThanOrEqualTo(String value) {
            this.addCriterion("`next` <=", value, "next");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextLessThanOrEqualToColumn(Column column) {
            this.addCriterion("`next` <= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextLike(String value) {
            this.addCriterion("`next` like", value, "next");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextNotLike(String value) {
            this.addCriterion("`next` not like", value, "next");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextIn(List<String> values) {
            this.addCriterion("`next` in", values, "next");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextNotIn(List<String> values) {
            this.addCriterion("`next` not in", values, "next");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextBetween(String value1, String value2) {
            this.addCriterion("`next` between", value1, value2, "next");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andNextNotBetween(String value1, String value2) {
            this.addCriterion("`next` not between", value1, value2, "next");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskIsNull() {
            this.addCriterion("current_task is null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskIsNotNull() {
            this.addCriterion("current_task is not null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskEqualTo(String value) {
            this.addCriterion("current_task =", value, "currentTask");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskEqualToColumn(Column column) {
            this.addCriterion("current_task = " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskNotEqualTo(String value) {
            this.addCriterion("current_task <>", value, "currentTask");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskNotEqualToColumn(Column column) {
            this.addCriterion("current_task <> " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskGreaterThan(String value) {
            this.addCriterion("current_task >", value, "currentTask");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskGreaterThanColumn(Column column) {
            this.addCriterion("current_task > " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskGreaterThanOrEqualTo(String value) {
            this.addCriterion("current_task >=", value, "currentTask");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("current_task >= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskLessThan(String value) {
            this.addCriterion("current_task <", value, "currentTask");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskLessThanColumn(Column column) {
            this.addCriterion("current_task < " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskLessThanOrEqualTo(String value) {
            this.addCriterion("current_task <=", value, "currentTask");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskLessThanOrEqualToColumn(Column column) {
            this.addCriterion("current_task <= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskLike(String value) {
            this.addCriterion("current_task like", value, "currentTask");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskNotLike(String value) {
            this.addCriterion("current_task not like", value, "currentTask");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskIn(List<String> values) {
            this.addCriterion("current_task in", values, "currentTask");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskNotIn(List<String> values) {
            this.addCriterion("current_task not in", values, "currentTask");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskBetween(String value1, String value2) {
            this.addCriterion("current_task between", value1, value2, "currentTask");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andCurrentTaskNotBetween(String value1, String value2) {
            this.addCriterion("current_task not between", value1, value2, "currentTask");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentIsNull() {
            this.addCriterion("uncontent is null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentIsNotNull() {
            this.addCriterion("uncontent is not null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentEqualTo(String value) {
            this.addCriterion("uncontent =", value, "uncontent");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentEqualToColumn(Column column) {
            this.addCriterion("uncontent = " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentNotEqualTo(String value) {
            this.addCriterion("uncontent <>", value, "uncontent");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentNotEqualToColumn(Column column) {
            this.addCriterion("uncontent <> " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentGreaterThan(String value) {
            this.addCriterion("uncontent >", value, "uncontent");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentGreaterThanColumn(Column column) {
            this.addCriterion("uncontent > " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentGreaterThanOrEqualTo(String value) {
            this.addCriterion("uncontent >=", value, "uncontent");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("uncontent >= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentLessThan(String value) {
            this.addCriterion("uncontent <", value, "uncontent");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentLessThanColumn(Column column) {
            this.addCriterion("uncontent < " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentLessThanOrEqualTo(String value) {
            this.addCriterion("uncontent <=", value, "uncontent");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentLessThanOrEqualToColumn(Column column) {
            this.addCriterion("uncontent <= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentLike(String value) {
            this.addCriterion("uncontent like", value, "uncontent");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentNotLike(String value) {
            this.addCriterion("uncontent not like", value, "uncontent");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentIn(List<String> values) {
            this.addCriterion("uncontent in", values, "uncontent");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentNotIn(List<String> values) {
            this.addCriterion("uncontent not in", values, "uncontent");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentBetween(String value1, String value2) {
            this.addCriterion("uncontent between", value1, value2, "uncontent");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andUncontentNotBetween(String value1, String value2) {
            this.addCriterion("uncontent not between", value1, value2, "uncontent");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiIsNull() {
            this.addCriterion("zhuangbei is null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiIsNotNull() {
            this.addCriterion("zhuangbei is not null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiEqualTo(String value) {
            this.addCriterion("zhuangbei =", value, "zhuangbei");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiEqualToColumn(Column column) {
            this.addCriterion("zhuangbei = " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiNotEqualTo(String value) {
            this.addCriterion("zhuangbei <>", value, "zhuangbei");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiNotEqualToColumn(Column column) {
            this.addCriterion("zhuangbei <> " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiGreaterThan(String value) {
            this.addCriterion("zhuangbei >", value, "zhuangbei");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiGreaterThanColumn(Column column) {
            this.addCriterion("zhuangbei > " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiGreaterThanOrEqualTo(String value) {
            this.addCriterion("zhuangbei >=", value, "zhuangbei");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("zhuangbei >= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiLessThan(String value) {
            this.addCriterion("zhuangbei <", value, "zhuangbei");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiLessThanColumn(Column column) {
            this.addCriterion("zhuangbei < " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiLessThanOrEqualTo(String value) {
            this.addCriterion("zhuangbei <=", value, "zhuangbei");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiLessThanOrEqualToColumn(Column column) {
            this.addCriterion("zhuangbei <= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiLike(String value) {
            this.addCriterion("zhuangbei like", value, "zhuangbei");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiNotLike(String value) {
            this.addCriterion("zhuangbei not like", value, "zhuangbei");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiIn(List<String> values) {
            this.addCriterion("zhuangbei in", values, "zhuangbei");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiNotIn(List<String> values) {
            this.addCriterion("zhuangbei not in", values, "zhuangbei");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiBetween(String value1, String value2) {
            this.addCriterion("zhuangbei between", value1, value2, "zhuangbei");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andZhuangbeiNotBetween(String value1, String value2) {
            this.addCriterion("zhuangbei not between", value1, value2, "zhuangbei");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andJingyanIsNull() {
            this.addCriterion("jingyan is null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andJingyanIsNotNull() {
            this.addCriterion("jingyan is not null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andJingyanEqualTo(Integer value) {
            this.addCriterion("jingyan =", value, "jingyan");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andJingyanEqualToColumn(Column column) {
            this.addCriterion("jingyan = " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andJingyanNotEqualTo(Integer value) {
            this.addCriterion("jingyan <>", value, "jingyan");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andJingyanNotEqualToColumn(Column column) {
            this.addCriterion("jingyan <> " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andJingyanGreaterThan(Integer value) {
            this.addCriterion("jingyan >", value, "jingyan");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andJingyanGreaterThanColumn(Column column) {
            this.addCriterion("jingyan > " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andJingyanGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("jingyan >=", value, "jingyan");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andJingyanGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("jingyan >= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andJingyanLessThan(Integer value) {
            this.addCriterion("jingyan <", value, "jingyan");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andJingyanLessThanColumn(Column column) {
            this.addCriterion("jingyan < " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andJingyanLessThanOrEqualTo(Integer value) {
            this.addCriterion("jingyan <=", value, "jingyan");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andJingyanLessThanOrEqualToColumn(Column column) {
            this.addCriterion("jingyan <= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andJingyanIn(List<Integer> values) {
            this.addCriterion("jingyan in", values, "jingyan");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andJingyanNotIn(List<Integer> values) {
            this.addCriterion("jingyan not in", values, "jingyan");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andJingyanBetween(Integer value1, Integer value2) {
            this.addCriterion("jingyan between", value1, value2, "jingyan");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andJingyanNotBetween(Integer value1, Integer value2) {
            this.addCriterion("jingyan not between", value1, value2, "jingyan");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andMoneyIsNull() {
            this.addCriterion("money is null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andMoneyIsNotNull() {
            this.addCriterion("money is not null");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andMoneyEqualTo(Integer value) {
            this.addCriterion("money =", value, "money");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andMoneyEqualToColumn(Column column) {
            this.addCriterion("money = " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andMoneyNotEqualTo(Integer value) {
            this.addCriterion("money <>", value, "money");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andMoneyNotEqualToColumn(Column column) {
            this.addCriterion("money <> " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andMoneyGreaterThan(Integer value) {
            this.addCriterion("money >", value, "money");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andMoneyGreaterThanColumn(Column column) {
            this.addCriterion("money > " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andMoneyGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("money >=", value, "money");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andMoneyGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("money >= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andMoneyLessThan(Integer value) {
            this.addCriterion("money <", value, "money");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andMoneyLessThanColumn(Column column) {
            this.addCriterion("money < " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andMoneyLessThanOrEqualTo(Integer value) {
            this.addCriterion("money <=", value, "money");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andMoneyLessThanOrEqualToColumn(Column column) {
            this.addCriterion("money <= " + column.getEscapedColumnName());
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andMoneyIn(List<Integer> values) {
            this.addCriterion("money in", values, "money");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andMoneyNotIn(List<Integer> values) {
            this.addCriterion("money not in", values, "money");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andMoneyBetween(Integer value1, Integer value2) {
            this.addCriterion("money between", value1, value2, "money");
            return (NpcDialogueFrameExample.Criteria)this;
        }

        public NpcDialogueFrameExample.Criteria andMoneyNotBetween(Integer value1, Integer value2) {
            this.addCriterion("money not between", value1, value2, "money");
            return (NpcDialogueFrameExample.Criteria)this;
        }
    }
}
