//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain.example;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.db.domain.ShowTasks.Column;
import org.linlinjava.litemall.db.domain.ShowTasks.Deleted;

public class ShowTasksExample {
    protected String orderByClause;
    protected boolean distinct;
    protected List<ShowTasksExample.Criteria> oredCriteria = new ArrayList();

    public ShowTasksExample() {
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

    public List<ShowTasksExample.Criteria> getOredCriteria() {
        return this.oredCriteria;
    }

    public void or(ShowTasksExample.Criteria criteria) {
        this.oredCriteria.add(criteria);
    }

    public ShowTasksExample.Criteria or() {
        ShowTasksExample.Criteria criteria = this.createCriteriaInternal();
        this.oredCriteria.add(criteria);
        return criteria;
    }

    public ShowTasksExample orderBy(String orderByClause) {
        this.setOrderByClause(orderByClause);
        return this;
    }

    public ShowTasksExample orderBy(String... orderByClauses) {
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

    public ShowTasksExample.Criteria createCriteria() {
        ShowTasksExample.Criteria criteria = this.createCriteriaInternal();
        if (this.oredCriteria.size() == 0) {
            this.oredCriteria.add(criteria);
        }

        return criteria;
    }

    protected ShowTasksExample.Criteria createCriteriaInternal() {
        ShowTasksExample.Criteria criteria = new ShowTasksExample.Criteria(this);
        return criteria;
    }

    public void clear() {
        this.oredCriteria.clear();
        this.orderByClause = null;
        this.distinct = false;
    }

    public static ShowTasksExample.Criteria newAndCreateCriteria() {
        ShowTasksExample example = new ShowTasksExample();
        return example.createCriteria();
    }

    public ShowTasksExample when(boolean condition, ShowTasksExample.IExampleWhen then) {
        if (condition) {
            then.example(this);
        }

        return this;
    }

    public ShowTasksExample when(boolean condition, ShowTasksExample.IExampleWhen then, ShowTasksExample.IExampleWhen otherwise) {
        if (condition) {
            then.example(this);
        } else {
            otherwise.example(this);
        }

        return this;
    }

    public interface IExampleWhen {
        void example(ShowTasksExample example);
    }

    public interface ICriteriaWhen {
        void criteria(ShowTasksExample.Criteria criteria);
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

    public static class Criteria extends ShowTasksExample.GeneratedCriteria {
        private ShowTasksExample example;

        protected Criteria(ShowTasksExample example) {
            this.example = example;
        }

        public ShowTasksExample example() {
            return this.example;
        }

        /** @deprecated */
        @Deprecated
        public ShowTasksExample.Criteria andIf(boolean ifAdd, ShowTasksExample.Criteria.ICriteriaAdd add) {
            if (ifAdd) {
                add.add(this);
            }

            return this;
        }

        public ShowTasksExample.Criteria when(boolean condition, ShowTasksExample.ICriteriaWhen then) {
            if (condition) {
                then.criteria(this);
            }

            return this;
        }

        public ShowTasksExample.Criteria when(boolean condition, ShowTasksExample.ICriteriaWhen then, ShowTasksExample.ICriteriaWhen otherwise) {
            if (condition) {
                then.criteria(this);
            } else {
                otherwise.criteria(this);
            }

            return this;
        }

        public ShowTasksExample.Criteria andLogicalDeleted(boolean deleted) {
            return deleted ? this.andDeletedEqualTo(Deleted.IS_DELETED.value()) : this.andDeletedNotEqualTo(Deleted.IS_DELETED.value());
        }

        /** @deprecated */
        @Deprecated
        public interface ICriteriaAdd {
            ShowTasksExample.Criteria add(ShowTasksExample.Criteria add);
        }
    }

    protected abstract static class GeneratedCriteria {
        protected List<ShowTasksExample.Criterion> criteria = new ArrayList();

        protected GeneratedCriteria() {
        }

        public boolean isValid() {
            return this.criteria.size() > 0;
        }

        public List<ShowTasksExample.Criterion> getAllCriteria() {
            return this.criteria;
        }

        public List<ShowTasksExample.Criterion> getCriteria() {
            return this.criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            } else {
                this.criteria.add(new ShowTasksExample.Criterion(condition));
            }
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            } else {
                this.criteria.add(new ShowTasksExample.Criterion(condition, value));
            }
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 != null && value2 != null) {
                this.criteria.add(new ShowTasksExample.Criterion(condition, value1, value2));
            } else {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
        }

        public ShowTasksExample.Criteria andIdIsNull() {
            this.addCriterion("id is null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andIdIsNotNull() {
            this.addCriterion("id is not null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andIdEqualTo(Integer value) {
            this.addCriterion("id =", value, "id");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andIdEqualToColumn(Column column) {
            this.addCriterion("id = " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andIdNotEqualTo(Integer value) {
            this.addCriterion("id <>", value, "id");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andIdNotEqualToColumn(Column column) {
            this.addCriterion("id <> " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andIdGreaterThan(Integer value) {
            this.addCriterion("id >", value, "id");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andIdGreaterThanColumn(Column column) {
            this.addCriterion("id > " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andIdGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("id >=", value, "id");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andIdGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("id >= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andIdLessThan(Integer value) {
            this.addCriterion("id <", value, "id");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andIdLessThanColumn(Column column) {
            this.addCriterion("id < " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andIdLessThanOrEqualTo(Integer value) {
            this.addCriterion("id <=", value, "id");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andIdLessThanOrEqualToColumn(Column column) {
            this.addCriterion("id <= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andIdIn(List<Integer> values) {
            this.addCriterion("id in", values, "id");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andIdNotIn(List<Integer> values) {
            this.addCriterion("id not in", values, "id");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andIdBetween(Integer value1, Integer value2) {
            this.addCriterion("id between", value1, value2, "id");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andIdNotBetween(Integer value1, Integer value2) {
            this.addCriterion("id not between", value1, value2, "id");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeIsNull() {
            this.addCriterion("task_type is null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeIsNotNull() {
            this.addCriterion("task_type is not null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeEqualTo(String value) {
            this.addCriterion("task_type =", value, "taskType");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeEqualToColumn(Column column) {
            this.addCriterion("task_type = " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeNotEqualTo(String value) {
            this.addCriterion("task_type <>", value, "taskType");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeNotEqualToColumn(Column column) {
            this.addCriterion("task_type <> " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeGreaterThan(String value) {
            this.addCriterion("task_type >", value, "taskType");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeGreaterThanColumn(Column column) {
            this.addCriterion("task_type > " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeGreaterThanOrEqualTo(String value) {
            this.addCriterion("task_type >=", value, "taskType");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("task_type >= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeLessThan(String value) {
            this.addCriterion("task_type <", value, "taskType");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeLessThanColumn(Column column) {
            this.addCriterion("task_type < " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeLessThanOrEqualTo(String value) {
            this.addCriterion("task_type <=", value, "taskType");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("task_type <= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeLike(String value) {
            this.addCriterion("task_type like", value, "taskType");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeNotLike(String value) {
            this.addCriterion("task_type not like", value, "taskType");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeIn(List<String> values) {
            this.addCriterion("task_type in", values, "taskType");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeNotIn(List<String> values) {
            this.addCriterion("task_type not in", values, "taskType");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeBetween(String value1, String value2) {
            this.addCriterion("task_type between", value1, value2, "taskType");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskTypeNotBetween(String value1, String value2) {
            this.addCriterion("task_type not between", value1, value2, "taskType");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescIsNull() {
            this.addCriterion("task_desc is null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescIsNotNull() {
            this.addCriterion("task_desc is not null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescEqualTo(String value) {
            this.addCriterion("task_desc =", value, "taskDesc");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescEqualToColumn(Column column) {
            this.addCriterion("task_desc = " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescNotEqualTo(String value) {
            this.addCriterion("task_desc <>", value, "taskDesc");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescNotEqualToColumn(Column column) {
            this.addCriterion("task_desc <> " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescGreaterThan(String value) {
            this.addCriterion("task_desc >", value, "taskDesc");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescGreaterThanColumn(Column column) {
            this.addCriterion("task_desc > " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescGreaterThanOrEqualTo(String value) {
            this.addCriterion("task_desc >=", value, "taskDesc");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("task_desc >= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescLessThan(String value) {
            this.addCriterion("task_desc <", value, "taskDesc");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescLessThanColumn(Column column) {
            this.addCriterion("task_desc < " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescLessThanOrEqualTo(String value) {
            this.addCriterion("task_desc <=", value, "taskDesc");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescLessThanOrEqualToColumn(Column column) {
            this.addCriterion("task_desc <= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescLike(String value) {
            this.addCriterion("task_desc like", value, "taskDesc");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescNotLike(String value) {
            this.addCriterion("task_desc not like", value, "taskDesc");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescIn(List<String> values) {
            this.addCriterion("task_desc in", values, "taskDesc");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescNotIn(List<String> values) {
            this.addCriterion("task_desc not in", values, "taskDesc");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescBetween(String value1, String value2) {
            this.addCriterion("task_desc between", value1, value2, "taskDesc");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskDescNotBetween(String value1, String value2) {
            this.addCriterion("task_desc not between", value1, value2, "taskDesc");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptIsNull() {
            this.addCriterion("task_prompt is null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptIsNotNull() {
            this.addCriterion("task_prompt is not null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptEqualTo(String value) {
            this.addCriterion("task_prompt =", value, "taskPrompt");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptEqualToColumn(Column column) {
            this.addCriterion("task_prompt = " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptNotEqualTo(String value) {
            this.addCriterion("task_prompt <>", value, "taskPrompt");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptNotEqualToColumn(Column column) {
            this.addCriterion("task_prompt <> " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptGreaterThan(String value) {
            this.addCriterion("task_prompt >", value, "taskPrompt");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptGreaterThanColumn(Column column) {
            this.addCriterion("task_prompt > " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptGreaterThanOrEqualTo(String value) {
            this.addCriterion("task_prompt >=", value, "taskPrompt");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("task_prompt >= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptLessThan(String value) {
            this.addCriterion("task_prompt <", value, "taskPrompt");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptLessThanColumn(Column column) {
            this.addCriterion("task_prompt < " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptLessThanOrEqualTo(String value) {
            this.addCriterion("task_prompt <=", value, "taskPrompt");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptLessThanOrEqualToColumn(Column column) {
            this.addCriterion("task_prompt <= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptLike(String value) {
            this.addCriterion("task_prompt like", value, "taskPrompt");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptNotLike(String value) {
            this.addCriterion("task_prompt not like", value, "taskPrompt");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptIn(List<String> values) {
            this.addCriterion("task_prompt in", values, "taskPrompt");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptNotIn(List<String> values) {
            this.addCriterion("task_prompt not in", values, "taskPrompt");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptBetween(String value1, String value2) {
            this.addCriterion("task_prompt between", value1, value2, "taskPrompt");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskPromptNotBetween(String value1, String value2) {
            this.addCriterion("task_prompt not between", value1, value2, "taskPrompt");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRefreshIsNull() {
            this.addCriterion("refresh is null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRefreshIsNotNull() {
            this.addCriterion("refresh is not null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRefreshEqualTo(Integer value) {
            this.addCriterion("refresh =", value, "refresh");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRefreshEqualToColumn(Column column) {
            this.addCriterion("refresh = " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRefreshNotEqualTo(Integer value) {
            this.addCriterion("refresh <>", value, "refresh");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRefreshNotEqualToColumn(Column column) {
            this.addCriterion("refresh <> " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRefreshGreaterThan(Integer value) {
            this.addCriterion("refresh >", value, "refresh");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRefreshGreaterThanColumn(Column column) {
            this.addCriterion("refresh > " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRefreshGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("refresh >=", value, "refresh");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRefreshGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("refresh >= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRefreshLessThan(Integer value) {
            this.addCriterion("refresh <", value, "refresh");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRefreshLessThanColumn(Column column) {
            this.addCriterion("refresh < " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRefreshLessThanOrEqualTo(Integer value) {
            this.addCriterion("refresh <=", value, "refresh");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRefreshLessThanOrEqualToColumn(Column column) {
            this.addCriterion("refresh <= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRefreshIn(List<Integer> values) {
            this.addCriterion("refresh in", values, "refresh");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRefreshNotIn(List<Integer> values) {
            this.addCriterion("refresh not in", values, "refresh");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRefreshBetween(Integer value1, Integer value2) {
            this.addCriterion("refresh between", value1, value2, "refresh");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRefreshNotBetween(Integer value1, Integer value2) {
            this.addCriterion("refresh not between", value1, value2, "refresh");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskEndTimeIsNull() {
            this.addCriterion("task_end_time is null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskEndTimeIsNotNull() {
            this.addCriterion("task_end_time is not null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskEndTimeEqualTo(Integer value) {
            this.addCriterion("task_end_time =", value, "taskEndTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskEndTimeEqualToColumn(Column column) {
            this.addCriterion("task_end_time = " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskEndTimeNotEqualTo(Integer value) {
            this.addCriterion("task_end_time <>", value, "taskEndTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskEndTimeNotEqualToColumn(Column column) {
            this.addCriterion("task_end_time <> " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskEndTimeGreaterThan(Integer value) {
            this.addCriterion("task_end_time >", value, "taskEndTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskEndTimeGreaterThanColumn(Column column) {
            this.addCriterion("task_end_time > " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskEndTimeGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("task_end_time >=", value, "taskEndTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskEndTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("task_end_time >= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskEndTimeLessThan(Integer value) {
            this.addCriterion("task_end_time <", value, "taskEndTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskEndTimeLessThanColumn(Column column) {
            this.addCriterion("task_end_time < " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskEndTimeLessThanOrEqualTo(Integer value) {
            this.addCriterion("task_end_time <=", value, "taskEndTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskEndTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("task_end_time <= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskEndTimeIn(List<Integer> values) {
            this.addCriterion("task_end_time in", values, "taskEndTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskEndTimeNotIn(List<Integer> values) {
            this.addCriterion("task_end_time not in", values, "taskEndTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskEndTimeBetween(Integer value1, Integer value2) {
            this.addCriterion("task_end_time between", value1, value2, "taskEndTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTaskEndTimeNotBetween(Integer value1, Integer value2) {
            this.addCriterion("task_end_time not between", value1, value2, "taskEndTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAttribIsNull() {
            this.addCriterion("attrib is null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAttribIsNotNull() {
            this.addCriterion("attrib is not null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAttribEqualTo(Integer value) {
            this.addCriterion("attrib =", value, "attrib");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAttribEqualToColumn(Column column) {
            this.addCriterion("attrib = " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAttribNotEqualTo(Integer value) {
            this.addCriterion("attrib <>", value, "attrib");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAttribNotEqualToColumn(Column column) {
            this.addCriterion("attrib <> " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAttribGreaterThan(Integer value) {
            this.addCriterion("attrib >", value, "attrib");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAttribGreaterThanColumn(Column column) {
            this.addCriterion("attrib > " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAttribGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("attrib >=", value, "attrib");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAttribGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("attrib >= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAttribLessThan(Integer value) {
            this.addCriterion("attrib <", value, "attrib");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAttribLessThanColumn(Column column) {
            this.addCriterion("attrib < " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAttribLessThanOrEqualTo(Integer value) {
            this.addCriterion("attrib <=", value, "attrib");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAttribLessThanOrEqualToColumn(Column column) {
            this.addCriterion("attrib <= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAttribIn(List<Integer> values) {
            this.addCriterion("attrib in", values, "attrib");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAttribNotIn(List<Integer> values) {
            this.addCriterion("attrib not in", values, "attrib");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAttribBetween(Integer value1, Integer value2) {
            this.addCriterion("attrib between", value1, value2, "attrib");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAttribNotBetween(Integer value1, Integer value2) {
            this.addCriterion("attrib not between", value1, value2, "attrib");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardIsNull() {
            this.addCriterion("reward is null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardIsNotNull() {
            this.addCriterion("reward is not null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardEqualTo(String value) {
            this.addCriterion("reward =", value, "reward");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardEqualToColumn(Column column) {
            this.addCriterion("reward = " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardNotEqualTo(String value) {
            this.addCriterion("reward <>", value, "reward");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardNotEqualToColumn(Column column) {
            this.addCriterion("reward <> " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardGreaterThan(String value) {
            this.addCriterion("reward >", value, "reward");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardGreaterThanColumn(Column column) {
            this.addCriterion("reward > " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardGreaterThanOrEqualTo(String value) {
            this.addCriterion("reward >=", value, "reward");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("reward >= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardLessThan(String value) {
            this.addCriterion("reward <", value, "reward");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardLessThanColumn(Column column) {
            this.addCriterion("reward < " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardLessThanOrEqualTo(String value) {
            this.addCriterion("reward <=", value, "reward");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardLessThanOrEqualToColumn(Column column) {
            this.addCriterion("reward <= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardLike(String value) {
            this.addCriterion("reward like", value, "reward");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardNotLike(String value) {
            this.addCriterion("reward not like", value, "reward");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardIn(List<String> values) {
            this.addCriterion("reward in", values, "reward");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardNotIn(List<String> values) {
            this.addCriterion("reward not in", values, "reward");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardBetween(String value1, String value2) {
            this.addCriterion("reward between", value1, value2, "reward");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andRewardNotBetween(String value1, String value2) {
            this.addCriterion("reward not between", value1, value2, "reward");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameIsNull() {
            this.addCriterion("show_name is null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameIsNotNull() {
            this.addCriterion("show_name is not null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameEqualTo(String value) {
            this.addCriterion("show_name =", value, "showName");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameEqualToColumn(Column column) {
            this.addCriterion("show_name = " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameNotEqualTo(String value) {
            this.addCriterion("show_name <>", value, "showName");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameNotEqualToColumn(Column column) {
            this.addCriterion("show_name <> " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameGreaterThan(String value) {
            this.addCriterion("show_name >", value, "showName");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameGreaterThanColumn(Column column) {
            this.addCriterion("show_name > " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameGreaterThanOrEqualTo(String value) {
            this.addCriterion("show_name >=", value, "showName");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("show_name >= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameLessThan(String value) {
            this.addCriterion("show_name <", value, "showName");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameLessThanColumn(Column column) {
            this.addCriterion("show_name < " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameLessThanOrEqualTo(String value) {
            this.addCriterion("show_name <=", value, "showName");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameLessThanOrEqualToColumn(Column column) {
            this.addCriterion("show_name <= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameLike(String value) {
            this.addCriterion("show_name like", value, "showName");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameNotLike(String value) {
            this.addCriterion("show_name not like", value, "showName");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameIn(List<String> values) {
            this.addCriterion("show_name in", values, "showName");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameNotIn(List<String> values) {
            this.addCriterion("show_name not in", values, "showName");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameBetween(String value1, String value2) {
            this.addCriterion("show_name between", value1, value2, "showName");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andShowNameNotBetween(String value1, String value2) {
            this.addCriterion("show_name not between", value1, value2, "showName");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaIsNull() {
            this.addCriterion("tasktask_extra_para is null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaIsNotNull() {
            this.addCriterion("tasktask_extra_para is not null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaEqualTo(String value) {
            this.addCriterion("tasktask_extra_para =", value, "tasktaskExtraPara");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaEqualToColumn(Column column) {
            this.addCriterion("tasktask_extra_para = " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaNotEqualTo(String value) {
            this.addCriterion("tasktask_extra_para <>", value, "tasktaskExtraPara");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaNotEqualToColumn(Column column) {
            this.addCriterion("tasktask_extra_para <> " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaGreaterThan(String value) {
            this.addCriterion("tasktask_extra_para >", value, "tasktaskExtraPara");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaGreaterThanColumn(Column column) {
            this.addCriterion("tasktask_extra_para > " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaGreaterThanOrEqualTo(String value) {
            this.addCriterion("tasktask_extra_para >=", value, "tasktaskExtraPara");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("tasktask_extra_para >= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaLessThan(String value) {
            this.addCriterion("tasktask_extra_para <", value, "tasktaskExtraPara");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaLessThanColumn(Column column) {
            this.addCriterion("tasktask_extra_para < " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaLessThanOrEqualTo(String value) {
            this.addCriterion("tasktask_extra_para <=", value, "tasktaskExtraPara");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaLessThanOrEqualToColumn(Column column) {
            this.addCriterion("tasktask_extra_para <= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaLike(String value) {
            this.addCriterion("tasktask_extra_para like", value, "tasktaskExtraPara");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaNotLike(String value) {
            this.addCriterion("tasktask_extra_para not like", value, "tasktaskExtraPara");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaIn(List<String> values) {
            this.addCriterion("tasktask_extra_para in", values, "tasktaskExtraPara");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaNotIn(List<String> values) {
            this.addCriterion("tasktask_extra_para not in", values, "tasktaskExtraPara");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaBetween(String value1, String value2) {
            this.addCriterion("tasktask_extra_para between", value1, value2, "tasktaskExtraPara");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskExtraParaNotBetween(String value1, String value2) {
            this.addCriterion("tasktask_extra_para not between", value1, value2, "tasktaskExtraPara");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskStateIsNull() {
            this.addCriterion("tasktask_state is null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskStateIsNotNull() {
            this.addCriterion("tasktask_state is not null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskStateEqualTo(Integer value) {
            this.addCriterion("tasktask_state =", value, "tasktaskState");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskStateEqualToColumn(Column column) {
            this.addCriterion("tasktask_state = " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskStateNotEqualTo(Integer value) {
            this.addCriterion("tasktask_state <>", value, "tasktaskState");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskStateNotEqualToColumn(Column column) {
            this.addCriterion("tasktask_state <> " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskStateGreaterThan(Integer value) {
            this.addCriterion("tasktask_state >", value, "tasktaskState");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskStateGreaterThanColumn(Column column) {
            this.addCriterion("tasktask_state > " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskStateGreaterThanOrEqualTo(Integer value) {
            this.addCriterion("tasktask_state >=", value, "tasktaskState");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskStateGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("tasktask_state >= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskStateLessThan(Integer value) {
            this.addCriterion("tasktask_state <", value, "tasktaskState");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskStateLessThanColumn(Column column) {
            this.addCriterion("tasktask_state < " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskStateLessThanOrEqualTo(Integer value) {
            this.addCriterion("tasktask_state <=", value, "tasktaskState");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskStateLessThanOrEqualToColumn(Column column) {
            this.addCriterion("tasktask_state <= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskStateIn(List<Integer> values) {
            this.addCriterion("tasktask_state in", values, "tasktaskState");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskStateNotIn(List<Integer> values) {
            this.addCriterion("tasktask_state not in", values, "tasktaskState");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskStateBetween(Integer value1, Integer value2) {
            this.addCriterion("tasktask_state between", value1, value2, "tasktaskState");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andTasktaskStateNotBetween(Integer value1, Integer value2) {
            this.addCriterion("tasktask_state not between", value1, value2, "tasktaskState");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAddTimeIsNull() {
            this.addCriterion("add_time is null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAddTimeIsNotNull() {
            this.addCriterion("add_time is not null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAddTimeEqualTo(LocalDateTime value) {
            this.addCriterion("add_time =", value, "addTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAddTimeEqualToColumn(Column column) {
            this.addCriterion("add_time = " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAddTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <>", value, "addTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAddTimeNotEqualToColumn(Column column) {
            this.addCriterion("add_time <> " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAddTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("add_time >", value, "addTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAddTimeGreaterThanColumn(Column column) {
            this.addCriterion("add_time > " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAddTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time >=", value, "addTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAddTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time >= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAddTimeLessThan(LocalDateTime value) {
            this.addCriterion("add_time <", value, "addTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAddTimeLessThanColumn(Column column) {
            this.addCriterion("add_time < " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAddTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("add_time <=", value, "addTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAddTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("add_time <= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAddTimeIn(List<LocalDateTime> values) {
            this.addCriterion("add_time in", values, "addTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAddTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("add_time not in", values, "addTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAddTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time between", value1, value2, "addTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andAddTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("add_time not between", value1, value2, "addTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andUpdateTimeIsNull() {
            this.addCriterion("update_time is null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andUpdateTimeIsNotNull() {
            this.addCriterion("update_time is not null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andUpdateTimeEqualTo(LocalDateTime value) {
            this.addCriterion("update_time =", value, "updateTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andUpdateTimeEqualToColumn(Column column) {
            this.addCriterion("update_time = " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andUpdateTimeNotEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <>", value, "updateTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andUpdateTimeNotEqualToColumn(Column column) {
            this.addCriterion("update_time <> " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andUpdateTimeGreaterThan(LocalDateTime value) {
            this.addCriterion("update_time >", value, "updateTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andUpdateTimeGreaterThanColumn(Column column) {
            this.addCriterion("update_time > " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andUpdateTimeGreaterThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time >=", value, "updateTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andUpdateTimeGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time >= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andUpdateTimeLessThan(LocalDateTime value) {
            this.addCriterion("update_time <", value, "updateTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andUpdateTimeLessThanColumn(Column column) {
            this.addCriterion("update_time < " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andUpdateTimeLessThanOrEqualTo(LocalDateTime value) {
            this.addCriterion("update_time <=", value, "updateTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andUpdateTimeLessThanOrEqualToColumn(Column column) {
            this.addCriterion("update_time <= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andUpdateTimeIn(List<LocalDateTime> values) {
            this.addCriterion("update_time in", values, "updateTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andUpdateTimeNotIn(List<LocalDateTime> values) {
            this.addCriterion("update_time not in", values, "updateTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andUpdateTimeBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time between", value1, value2, "updateTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andUpdateTimeNotBetween(LocalDateTime value1, LocalDateTime value2) {
            this.addCriterion("update_time not between", value1, value2, "updateTime");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andDeletedIsNull() {
            this.addCriterion("deleted is null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andDeletedIsNotNull() {
            this.addCriterion("deleted is not null");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andDeletedEqualTo(Boolean value) {
            this.addCriterion("deleted =", value, "deleted");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andDeletedEqualToColumn(Column column) {
            this.addCriterion("deleted = " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andDeletedNotEqualTo(Boolean value) {
            this.addCriterion("deleted <>", value, "deleted");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andDeletedNotEqualToColumn(Column column) {
            this.addCriterion("deleted <> " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andDeletedGreaterThan(Boolean value) {
            this.addCriterion("deleted >", value, "deleted");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andDeletedGreaterThanColumn(Column column) {
            this.addCriterion("deleted > " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andDeletedGreaterThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted >=", value, "deleted");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andDeletedGreaterThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted >= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andDeletedLessThan(Boolean value) {
            this.addCriterion("deleted <", value, "deleted");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andDeletedLessThanColumn(Column column) {
            this.addCriterion("deleted < " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andDeletedLessThanOrEqualTo(Boolean value) {
            this.addCriterion("deleted <=", value, "deleted");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andDeletedLessThanOrEqualToColumn(Column column) {
            this.addCriterion("deleted <= " + column.getEscapedColumnName());
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andDeletedIn(List<Boolean> values) {
            this.addCriterion("deleted in", values, "deleted");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andDeletedNotIn(List<Boolean> values) {
            this.addCriterion("deleted not in", values, "deleted");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andDeletedBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted between", value1, value2, "deleted");
            return (ShowTasksExample.Criteria)this;
        }

        public ShowTasksExample.Criteria andDeletedNotBetween(Boolean value1, Boolean value2) {
            this.addCriterion("deleted not between", value1, value2, "deleted");
            return (ShowTasksExample.Criteria)this;
        }
    }
}
