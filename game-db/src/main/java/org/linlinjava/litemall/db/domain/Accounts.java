//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.db.domain;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import org.springframework.format.annotation.DateTimeFormat;

public class Accounts implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private String name;
    private String keyword;
    private String password;
    private String token;
    @JsonDeserialize(
            using = LocalDateTimeDeserializer.class
    )
    @JsonSerialize(
            using = LocalDateTimeSerializer.class
    )
    @DateTimeFormat(
            pattern = "yyyy-MM-dd HH:mm:ss"
    )
    private LocalDateTime addTime;
    @JsonDeserialize(
            using = LocalDateTimeDeserializer.class
    )
    @JsonSerialize(
            using = LocalDateTimeSerializer.class
    )
    @DateTimeFormat(
            pattern = "yyyy-MM-dd HH:mm:ss"
    )
    private LocalDateTime updateTime;
    private Boolean deleted;
    private Integer chongzhijifen;
    private Integer chongzhiyuanbao;
    private String yaoqingma;
    private Integer block;
    private String code;
    private static final long serialVersionUID = 1L;

    public Accounts() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getKeyword() {
        return this.keyword;
    }

    public void setKeyword(String keyword) {
        this.keyword = keyword;
    }

    public String getPassword() {
        return this.password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getToken() {
        return this.token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public LocalDateTime getAddTime() {
        return this.addTime;
    }

    public void setAddTime(LocalDateTime addTime) {
        this.addTime = addTime;
    }

    public LocalDateTime getUpdateTime() {
        return this.updateTime;
    }

    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }

    public void andLogicalDeleted(boolean deleted) {
        this.setDeleted(deleted ? Accounts.Deleted.IS_DELETED.value() : Accounts.Deleted.NOT_DELETED.value());
    }

    public Boolean getDeleted() {
        return this.deleted;
    }

    public void setDeleted(Boolean deleted) {
        this.deleted = deleted;
    }

    public Integer getChongzhijifen() {
        return this.chongzhijifen;
    }

    public void setChongzhijifen(Integer chongzhijifen) {
        this.chongzhijifen = chongzhijifen;
    }

    public Integer getChongzhiyuanbao() {
        return this.chongzhiyuanbao;
    }

    public void setChongzhiyuanbao(Integer chongzhiyuanbao) {
        this.chongzhiyuanbao = chongzhiyuanbao;
    }

    public String getYaoqingma() {
        return this.yaoqingma;
    }

    public void setYaoqingma(String yaoqingma) {
        this.yaoqingma = yaoqingma;
    }

    public Integer getBlock() {
        return this.block;
    }

    public void setBlock(Integer block) {
        this.block = block;
    }

    public String getCode() {
        return this.code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(this.getClass().getSimpleName());
        sb.append(" [");
        sb.append("Hash = ").append(this.hashCode());
        sb.append(", IS_DELETED=").append(IS_DELETED);
        sb.append(", NOT_DELETED=").append(NOT_DELETED);
        sb.append(", id=").append(this.id);
        sb.append(", name=").append(this.name);
        sb.append(", keyword=").append(this.keyword);
        sb.append(", password=").append(this.password);
        sb.append(", token=").append(this.token);
        sb.append(", addTime=").append(this.addTime);
        sb.append(", updateTime=").append(this.updateTime);
        sb.append(", deleted=").append(this.deleted);
        sb.append(", chongzhijifen=").append(this.chongzhijifen);
        sb.append(", chongzhiyuanbao=").append(this.chongzhiyuanbao);
        sb.append(", yaoqingma=").append(this.yaoqingma);
        sb.append(", block=").append(this.block);
        sb.append(", code=").append(this.code);
        sb.append("]");
        return sb.toString();
    }

    public boolean equals(Object that) {
        if (this == that) {
            return true;
        } else if (that == null) {
            return false;
        } else if (this.getClass() != that.getClass()) {
            return false;
        } else {
            boolean var10000;
            label137: {
                label129: {
                    Accounts other = (Accounts)that;
                    if (this.getId() == null) {
                        if (other.getId() != null) {
                            break label129;
                        }
                    } else if (!this.getId().equals(other.getId())) {
                        break label129;
                    }

                    if (this.getName() == null) {
                        if (other.getName() != null) {
                            break label129;
                        }
                    } else if (!this.getName().equals(other.getName())) {
                        break label129;
                    }

                    if (this.getKeyword() == null) {
                        if (other.getKeyword() != null) {
                            break label129;
                        }
                    } else if (!this.getKeyword().equals(other.getKeyword())) {
                        break label129;
                    }

                    if (this.getPassword() == null) {
                        if (other.getPassword() != null) {
                            break label129;
                        }
                    } else if (!this.getPassword().equals(other.getPassword())) {
                        break label129;
                    }

                    if (this.getToken() == null) {
                        if (other.getToken() != null) {
                            break label129;
                        }
                    } else if (!this.getToken().equals(other.getToken())) {
                        break label129;
                    }

                    if (this.getAddTime() == null) {
                        if (other.getAddTime() != null) {
                            break label129;
                        }
                    } else if (!this.getAddTime().equals(other.getAddTime())) {
                        break label129;
                    }

                    if (this.getUpdateTime() == null) {
                        if (other.getUpdateTime() != null) {
                            break label129;
                        }
                    } else if (!this.getUpdateTime().equals(other.getUpdateTime())) {
                        break label129;
                    }

                    if (this.getDeleted() == null) {
                        if (other.getDeleted() != null) {
                            break label129;
                        }
                    } else if (!this.getDeleted().equals(other.getDeleted())) {
                        break label129;
                    }

                    if (this.getChongzhijifen() == null) {
                        if (other.getChongzhijifen() != null) {
                            break label129;
                        }
                    } else if (!this.getChongzhijifen().equals(other.getChongzhijifen())) {
                        break label129;
                    }

                    if (this.getChongzhiyuanbao() == null) {
                        if (other.getChongzhiyuanbao() != null) {
                            break label129;
                        }
                    } else if (!this.getChongzhiyuanbao().equals(other.getChongzhiyuanbao())) {
                        break label129;
                    }

                    if (this.getYaoqingma() == null) {
                        if (other.getYaoqingma() != null) {
                            break label129;
                        }
                    } else if (!this.getYaoqingma().equals(other.getYaoqingma())) {
                        break label129;
                    }

                    if (this.getBlock() == null) {
                        if (other.getBlock() != null) {
                            break label129;
                        }
                    } else if (!this.getBlock().equals(other.getBlock())) {
                        break label129;
                    }

                    if (this.getCode() == null) {
                        if (other.getCode() == null) {
                            break label137;
                        }
                    } else if (this.getCode().equals(other.getCode())) {
                        break label137;
                    }
                }

                var10000 = false;
                return var10000;
            }

            var10000 = true;
            return var10000;
        }
    }

    public int hashCode() {

        int result = 1;
         result = 31 * result + (this.getId() == null ? 0 : this.getId().hashCode());
        result = 31 * result + (this.getName() == null ? 0 : this.getName().hashCode());
        result = 31 * result + (this.getKeyword() == null ? 0 : this.getKeyword().hashCode());
        result = 31 * result + (this.getPassword() == null ? 0 : this.getPassword().hashCode());
        result = 31 * result + (this.getToken() == null ? 0 : this.getToken().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        result = 31 * result + (this.getChongzhijifen() == null ? 0 : this.getChongzhijifen().hashCode());
        result = 31 * result + (this.getChongzhiyuanbao() == null ? 0 : this.getChongzhiyuanbao().hashCode());
        result = 31 * result + (this.getYaoqingma() == null ? 0 : this.getYaoqingma().hashCode());
        result = 31 * result + (this.getBlock() == null ? 0 : this.getBlock().hashCode());
        result = 31 * result + (this.getCode() == null ? 0 : this.getCode().hashCode());
        return result;
    }

    public Accounts clone() throws CloneNotSupportedException {
        return (Accounts)super.clone();
    }

    static {
        IS_DELETED = Accounts.Deleted.IS_DELETED.value();
        NOT_DELETED = Accounts.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        name("name", "name", "VARCHAR", true),
        keyword("keyword", "keyword", "VARCHAR", false),
        password("password", "password", "VARCHAR", true),
        token("token", "token", "VARCHAR", false),
        addTime("add_time", "addTime", "TIMESTAMP", false),
        updateTime("update_time", "updateTime", "TIMESTAMP", false),
        deleted("deleted", "deleted", "BIT", false),
        chongzhijifen("chongzhijifen", "chongzhijifen", "INTEGER", false),
        chongzhiyuanbao("chongzhiyuanbao", "chongzhiyuanbao", "INTEGER", false),
        yaoqingma("yaoqingma", "yaoqingma", "VARCHAR", false),
        block("block", "block", "INTEGER", false),
        code("code", "code", "VARCHAR", false);

        private static final String BEGINNING_DELIMITER = "`";
        private static final String ENDING_DELIMITER = "`";
        private final String column;
        private final boolean isColumnNameDelimited;
        private final String javaProperty;
        private final String jdbcType;

        public String value() {
            return this.column;
        }

        public String getValue() {
            return this.column;
        }

        public String getJavaProperty() {
            return this.javaProperty;
        }

        public String getJdbcType() {
            return this.jdbcType;
        }

        private Column(String column, String javaProperty, String jdbcType, boolean isColumnNameDelimited) {
            this.column = column;
            this.javaProperty = javaProperty;
            this.jdbcType = jdbcType;
            this.isColumnNameDelimited = isColumnNameDelimited;
        }

        public String desc() {
            return this.getEscapedColumnName() + " DESC";
        }

        public String asc() {
            return this.getEscapedColumnName() + " ASC";
        }

        public static Accounts.Column[] excludes(Accounts.Column... excludes) {
            ArrayList<Accounts.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (Accounts.Column[])columns.toArray(new Accounts.Column[0]);
        }

        public String getEscapedColumnName() {
            return this.isColumnNameDelimited ? "`" + this.column + "`" : this.column;
        }
    }

    public static enum Deleted {
        NOT_DELETED(new Boolean("0"), "未删除"),
        IS_DELETED(new Boolean("1"), "已删除");

        private final Boolean value;
        private final String name;

        private Deleted(Boolean value, String name) {
            this.value = value;
            this.name = name;
        }

        public Boolean getValue() {
            return this.value;
        }

        public Boolean value() {
            return this.value;
        }

        public String getName() {
            return this.name;
        }
    }
}
