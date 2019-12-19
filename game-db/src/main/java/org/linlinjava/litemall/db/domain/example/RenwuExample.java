//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.Renwu.Column;
import org.linlinjava.litemall.db.domain.Renwu.Deleted;

public class RenwuExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<RenwuExample.Criteria> oredCriteria = new ArrayList();

    public RenwuExample() {
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

    public List<RenwuExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(RenwuExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public RenwuExample.Criteria or() {
        RenwuExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public RenwuExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public RenwuExample orderBy(String... orderByClauses) {
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

    public RenwuExample.Criteria createCriteria() {
        RenwuExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected RenwuExample.Criteria createCriteriaInternal() {
        RenwuExample.Criteria criteria = new RenwuExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static RenwuExample.Criteria newAndCreateCriteria() {
        RenwuExample example = new RenwuExample();
        return example.createCriteria();
    }

    public RenwuExample when(boolean condition, RenwuExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public RenwuExample when(boolean condition, RenwuExample.IExampleWhen then, RenwuExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(RenwuExample example);
    }

    public interface ICriteriaWhen {
        void criteria(RenwuExample.Criteria criteria);
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

    public static class Criteria extends RenwuExample.GeneratedCriteria {
        private RenwuExample example;

        protected Criteria(RenwuExample example) {
            this.example = example;
        }

        public RenwuExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public RenwuExample.Criteria andIf(boolean ifAdd, RenwuExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public RenwuExample.Criteria when(boolean condition, RenwuExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public RenwuExample.Criteria when(boolean condition, RenwuExample.ICriteriaWhen then, RenwuExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public RenwuExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            RenwuExample.Criteria add(RenwuExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<RenwuExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<RenwuExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<RenwuExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new RenwuExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new RenwuExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new RenwuExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public RenwuExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentIsNull() {
            this.addCriterion("uncontent is null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentIsNotNull() {
            this.addCriterion("uncontent is not null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentEqualTo(String value) {
            this.addCriterion("uncontent =", value, "uncontent");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentEqualToColumn(Column column) {
            this.addCriterion("uncontent = " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentNotEqualTo(String value) {
            this.addCriterion("uncontent <>", value, "uncontent");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentNotEqualToColumn(Column column) {
            this.addCriterion("uncontent <> " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentGreaterThan(String value) {
            this.addCriterion("uncontent >", value, "uncontent");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentGreaterThanColumn(Column column) {
            this.addCriterion("uncontent > " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentGreaterThanOrEqualTo(String value) {
            this.addCriterion("uncontent >=", value, "uncontent");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("uncontent >= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentLessThan(String value) {
            this.addCriterion("uncontent <", value, "uncontent");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentLessThanColumn(Column column) {
            this.addCriterion("uncontent < " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentLessThanOrEqualTo(String value) {
            this.addCriterion("uncontent <=", value, "uncontent");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentLessThanOrEqualToColumn(Column column) {
            this.addCriterion("uncontent <= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentLike(String value) {
            this.addCriterion("uncontent like", value, "uncontent");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentNotLike(String value) {
            this.addCriterion("uncontent not like", value, "uncontent");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentIn(List<String> values) {
            this.addCriterion("uncontent in", values, "uncontent");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentNotIn(List<String> values) {
            this.addCriterion("uncontent not in", values, "uncontent");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentBetween(String value1, String value2) {
            this.addCriterion("uncontent between", value1, value2, "uncontent");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUncontentNotBetween(String value1, String value2) {
            this.addCriterion("uncontent not between", value1, value2, "uncontent");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameIsNull() {
            this.addCriterion("npc_name is null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameIsNotNull() {
            this.addCriterion("npc_name is not null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameEqualTo(String value) {
            this.addCriterion("npc_name =", value, "npcName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameEqualToColumn(Column column) {
            this.addCriterion("npc_name = " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameNotEqualTo(String value) {
            this.addCriterion("npc_name <>", value, "npcName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameNotEqualToColumn(Column column) {
            this.addCriterion("npc_name <> " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameGreaterThan(String value) {
            this.addCriterion("npc_name >", value, "npcName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameGreaterThanColumn(Column column) {
            this.addCriterion("npc_name > " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("npc_name >=", value, "npcName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("npc_name >= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameLessThan(String value) {
            this.addCriterion("npc_name <", value, "npcName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameLessThanColumn(Column column) {
            this.addCriterion("npc_name < " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameLessThanOrEqualTo(String value) {
            this.addCriterion("npc_name <=", value, "npcName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("npc_name <= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameLike(String value) {
            this.addCriterion("npc_name like", value, "npcName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameNotLike(String value) {
            this.addCriterion("npc_name not like", value, "npcName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameIn(List<String> values) {
            this.addCriterion("npc_name in", values, "npcName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameNotIn(List<String> values) {
            this.addCriterion("npc_name not in", values, "npcName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameBetween(String value1, String value2) {
            this.addCriterion("npc_name between", value1, value2, "npcName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andNpcNameNotBetween(String value1, String value2) {
            this.addCriterion("npc_name not between", value1, value2, "npcName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskIsNull() {
            this.addCriterion("current_task is null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskIsNotNull() {
            this.addCriterion("current_task is not null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskEqualTo(String value) {
            this.addCriterion("current_task =", value, "currentTask");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskEqualToColumn(Column column) {
            this.addCriterion("current_task = " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskNotEqualTo(String value) {
            this.addCriterion("current_task <>", value, "currentTask");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskNotEqualToColumn(Column column) {
            this.addCriterion("current_task <> " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskGreaterThan(String value) {
            this.addCriterion("current_task >", value, "currentTask");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskGreaterThanColumn(Column column) {
            this.addCriterion("current_task > " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskGreaterThanOrEqualTo(String value) {
            this.addCriterion("current_task >=", value, "currentTask");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("current_task >= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskLessThan(String value) {
            this.addCriterion("current_task <", value, "currentTask");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskLessThanColumn(Column column) {
            this.addCriterion("current_task < " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskLessThanOrEqualTo(String value) {
            this.addCriterion("current_task <=", value, "currentTask");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskLessThanOrEqualToColumn(Column column) {
            this.addCriterion("current_task <= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskLike(String value) {
            this.addCriterion("current_task like", value, "currentTask");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskNotLike(String value) {
            this.addCriterion("current_task not like", value, "currentTask");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskIn(List<String> values) {
            this.addCriterion("current_task in", values, "currentTask");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskNotIn(List<String> values) {
            this.addCriterion("current_task not in", values, "currentTask");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskBetween(String value1, String value2) {
            this.addCriterion("current_task between", value1, value2, "currentTask");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andCurrentTaskNotBetween(String value1, String value2) {
            this.addCriterion("current_task not between", value1, value2, "currentTask");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameIsNull() {
            this.addCriterion("show_name is null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameIsNotNull() {
            this.addCriterion("show_name is not null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameEqualTo(String value) {
            this.addCriterion("show_name =", value, "showName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameEqualToColumn(Column column) {
            this.addCriterion("show_name = " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameNotEqualTo(String value) {
            this.addCriterion("show_name <>", value, "showName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameNotEqualToColumn(Column column) {
            this.addCriterion("show_name <> " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameGreaterThan(String value) {
            this.addCriterion("show_name >", value, "showName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameGreaterThanColumn(Column column) {
            this.addCriterion("show_name > " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("show_name >=", value, "showName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("show_name >= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameLessThan(String value) {
            this.addCriterion("show_name <", value, "showName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameLessThanColumn(Column column) {
            this.addCriterion("show_name < " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameLessThanOrEqualTo(String value) {
            this.addCriterion("show_name <=", value, "showName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("show_name <= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameLike(String value) {
            this.addCriterion("show_name like", value, "showName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameNotLike(String value) {
            this.addCriterion("show_name not like", value, "showName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameIn(List<String> values) {
            this.addCriterion("show_name in", values, "showName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameNotIn(List<String> values) {
            this.addCriterion("show_name not in", values, "showName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameBetween(String value1, String value2) {
            this.addCriterion("show_name between", value1, value2, "showName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andShowNameNotBetween(String value1, String value2) {
            this.addCriterion("show_name not between", value1, value2, "showName");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptIsNull() {
            this.addCriterion("task_prompt is null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptIsNotNull() {
            this.addCriterion("task_prompt is not null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptEqualTo(String value) {
            this.addCriterion("task_prompt =", value, "taskPrompt");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptEqualToColumn(Column column) {
            this.addCriterion("task_prompt = " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptNotEqualTo(String value) {
            this.addCriterion("task_prompt <>", value, "taskPrompt");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptNotEqualToColumn(Column column) {
            this.addCriterion("task_prompt <> " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptGreaterThan(String value) {
            this.addCriterion("task_prompt >", value, "taskPrompt");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptGreaterThanColumn(Column column) {
            this.addCriterion("task_prompt > " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptGreaterThanOrEqualTo(String value) {
            this.addCriterion("task_prompt >=", value, "taskPrompt");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("task_prompt >= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptLessThan(String value) {
            this.addCriterion("task_prompt <", value, "taskPrompt");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptLessThanColumn(Column column) {
            this.addCriterion("task_prompt < " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptLessThanOrEqualTo(String value) {
            this.addCriterion("task_prompt <=", value, "taskPrompt");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptLessThanOrEqualToColumn(Column column) {
            this.addCriterion("task_prompt <= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptLike(String value) {
            this.addCriterion("task_prompt like", value, "taskPrompt");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptNotLike(String value) {
            this.addCriterion("task_prompt not like", value, "taskPrompt");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptIn(List<String> values) {
            this.addCriterion("task_prompt in", values, "taskPrompt");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptNotIn(List<String> values) {
            this.addCriterion("task_prompt not in", values, "taskPrompt");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptBetween(String value1, String value2) {
            this.addCriterion("task_prompt between", value1, value2, "taskPrompt");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andTaskPromptNotBetween(String value1, String value2) {
            this.addCriterion("task_prompt not between", value1, value2, "taskPrompt");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardIsNull() {
            this.addCriterion("reward is null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardIsNotNull() {
            this.addCriterion("reward is not null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardEqualTo(String value) {
            this.addCriterion("reward =", value, "reward");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardEqualToColumn(Column column) {
            this.addCriterion("reward = " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardNotEqualTo(String value) {
            this.addCriterion("reward <>", value, "reward");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardNotEqualToColumn(Column column) {
            this.addCriterion("reward <> " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardGreaterThan(String value) {
            this.addCriterion("reward >", value, "reward");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardGreaterThanColumn(Column column) {
            this.addCriterion("reward > " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardGreaterThanOrEqualTo(String value) {
            this.addCriterion("reward >=", value, "reward");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("reward >= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardLessThan(String value) {
            this.addCriterion("reward <", value, "reward");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardLessThanColumn(Column column) {
            this.addCriterion("reward < " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardLessThanOrEqualTo(String value) {
            this.addCriterion("reward <=", value, "reward");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardLessThanOrEqualToColumn(Column column) {
            this.addCriterion("reward <= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardLike(String value) {
            this.addCriterion("reward like", value, "reward");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardNotLike(String value) {
            this.addCriterion("reward not like", value, "reward");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardIn(List<String> values) {
            this.addCriterion("reward in", values, "reward");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardNotIn(List<String> values) {
            this.addCriterion("reward not in", values, "reward");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardBetween(String value1, String value2) {
            this.addCriterion("reward between", value1, value2, "reward");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andRewardNotBetween(String value1, String value2) {
            this.addCriterion("reward not between", value1, value2, "reward");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (RenwuExample.Criteria)this;
        }

        public RenwuExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (RenwuExample.Criteria)this;
        }
    }
}
