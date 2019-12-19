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

public class Pets implements Cloneable, Serializable {
    public static final Boolean IS_DELETED;
    public static final Boolean NOT_DELETED;
    private Integer id;
    private String ownerid;
    private String petid;
    private String nickname;
    private String name;
    private Integer horsetype;
    private Integer type;
    private Integer level;
    private Integer liliang;
    private Integer minjie;
    private Integer lingli;
    private Integer tili;
    private Integer dianhualx;
    private Integer dianhuazd;
    private Integer dianhuazx;
    private Integer yuhualx;
    private Integer yuhuazd;
    private Integer yuhuazx;
    private Integer cwjyzx;
    private Integer cwjyzd;
    private Integer feisheng;
    private Integer fsudu;
    private Integer qhcwWg;
    private Integer qhcwFg;
    private Integer cwXiangxing;
    private Integer cwWuxue;
    private String cwIcon;
    private Integer cwXinfa;
    private Integer cwQinmi;
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
    private static final long serialVersionUID = 1L;

    public Pets() {
    }

    public Integer getId() {
        return this.id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getOwnerid() {
        return this.ownerid;
    }

    public void setOwnerid(String ownerid) {
        this.ownerid = ownerid;
    }

    public String getPetid() {
        return this.petid;
    }

    public void setPetid(String petid) {
        this.petid = petid;
    }

    public String getNickname() {
        return this.nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getHorsetype() {
        return this.horsetype;
    }

    public void setHorsetype(Integer horsetype) {
        this.horsetype = horsetype;
    }

    public Integer getType() {
        return this.type;
    }

    public void setType(Integer type) {
        this.type = type;
    }

    public Integer getLevel() {
        return this.level;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }

    public Integer getLiliang() {
        return this.liliang;
    }

    public void setLiliang(Integer liliang) {
        this.liliang = liliang;
    }

    public Integer getMinjie() {
        return this.minjie;
    }

    public void setMinjie(Integer minjie) {
        this.minjie = minjie;
    }

    public Integer getLingli() {
        return this.lingli;
    }

    public void setLingli(Integer lingli) {
        this.lingli = lingli;
    }

    public Integer getTili() {
        return this.tili;
    }

    public void setTili(Integer tili) {
        this.tili = tili;
    }

    public Integer getDianhualx() {
        return this.dianhualx;
    }

    public void setDianhualx(Integer dianhualx) {
        this.dianhualx = dianhualx;
    }

    public Integer getDianhuazd() {
        return this.dianhuazd;
    }

    public void setDianhuazd(Integer dianhuazd) {
        this.dianhuazd = dianhuazd;
    }

    public Integer getDianhuazx() {
        return this.dianhuazx;
    }

    public void setDianhuazx(Integer dianhuazx) {
        this.dianhuazx = dianhuazx;
    }

    public Integer getYuhualx() {
        return this.yuhualx;
    }

    public void setYuhualx(Integer yuhualx) {
        this.yuhualx = yuhualx;
    }

    public Integer getYuhuazd() {
        return this.yuhuazd;
    }

    public void setYuhuazd(Integer yuhuazd) {
        this.yuhuazd = yuhuazd;
    }

    public Integer getYuhuazx() {
        return this.yuhuazx;
    }

    public void setYuhuazx(Integer yuhuazx) {
        this.yuhuazx = yuhuazx;
    }

    public Integer getCwjyzx() {
        return this.cwjyzx;
    }

    public void setCwjyzx(Integer cwjyzx) {
        this.cwjyzx = cwjyzx;
    }

    public Integer getCwjyzd() {
        return this.cwjyzd;
    }

    public void setCwjyzd(Integer cwjyzd) {
        this.cwjyzd = cwjyzd;
    }

    public Integer getFeisheng() {
        return this.feisheng;
    }

    public void setFeisheng(Integer feisheng) {
        this.feisheng = feisheng;
    }

    public Integer getFsudu() {
        return this.fsudu;
    }

    public void setFsudu(Integer fsudu) {
        this.fsudu = fsudu;
    }

    public Integer getQhcwWg() {
        return this.qhcwWg;
    }

    public void setQhcwWg(Integer qhcwWg) {
        this.qhcwWg = qhcwWg;
    }

    public Integer getQhcwFg() {
        return this.qhcwFg;
    }

    public void setQhcwFg(Integer qhcwFg) {
        this.qhcwFg = qhcwFg;
    }

    public Integer getCwXiangxing() {
        return this.cwXiangxing;
    }

    public void setCwXiangxing(Integer cwXiangxing) {
        this.cwXiangxing = cwXiangxing;
    }

    public Integer getCwWuxue() {
        return this.cwWuxue;
    }

    public void setCwWuxue(Integer cwWuxue) {
        this.cwWuxue = cwWuxue;
    }

    public String getCwIcon() {
        return this.cwIcon;
    }

    public void setCwIcon(String cwIcon) {
        this.cwIcon = cwIcon;
    }

    public Integer getCwXinfa() {
        return this.cwXinfa;
    }

    public void setCwXinfa(Integer cwXinfa) {
        this.cwXinfa = cwXinfa;
    }

    public Integer getCwQinmi() {
        return this.cwQinmi;
    }

    public void setCwQinmi(Integer cwQinmi) {
        this.cwQinmi = cwQinmi;
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
        this.setDeleted(deleted ? Pets.Deleted.IS_DELETED.value() : Pets.Deleted.NOT_DELETED.value());
    }

    public Boolean getDeleted() {
        return this.deleted;
    }

    public void setDeleted(Boolean deleted) {
        this.deleted = deleted;
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(this.getClass().getSimpleName());
        sb.append(" [");
        sb.append("Hash = ").append(this.hashCode());
        sb.append(", IS_DELETED=").append(IS_DELETED);
        sb.append(", NOT_DELETED=").append(NOT_DELETED);
        sb.append(", id=").append(this.id);
        sb.append(", ownerid=").append(this.ownerid);
        sb.append(", petid=").append(this.petid);
        sb.append(", nickname=").append(this.nickname);
        sb.append(", name=").append(this.name);
        sb.append(", horsetype=").append(this.horsetype);
        sb.append(", type=").append(this.type);
        sb.append(", level=").append(this.level);
        sb.append(", liliang=").append(this.liliang);
        sb.append(", minjie=").append(this.minjie);
        sb.append(", lingli=").append(this.lingli);
        sb.append(", tili=").append(this.tili);
        sb.append(", dianhualx=").append(this.dianhualx);
        sb.append(", dianhuazd=").append(this.dianhuazd);
        sb.append(", dianhuazx=").append(this.dianhuazx);
        sb.append(", yuhualx=").append(this.yuhualx);
        sb.append(", yuhuazd=").append(this.yuhuazd);
        sb.append(", yuhuazx=").append(this.yuhuazx);
        sb.append(", cwjyzx=").append(this.cwjyzx);
        sb.append(", cwjyzd=").append(this.cwjyzd);
        sb.append(", feisheng=").append(this.feisheng);
        sb.append(", fsudu=").append(this.fsudu);
        sb.append(", qhcwWg=").append(this.qhcwWg);
        sb.append(", qhcwFg=").append(this.qhcwFg);
        sb.append(", cwXiangxing=").append(this.cwXiangxing);
        sb.append(", cwWuxue=").append(this.cwWuxue);
        sb.append(", cwIcon=").append(this.cwIcon);
        sb.append(", cwXinfa=").append(this.cwXinfa);
        sb.append(", cwQinmi=").append(this.cwQinmi);
        sb.append(", addTime=").append(this.addTime);
        sb.append(", updateTime=").append(this.updateTime);
        sb.append(", deleted=").append(this.deleted);
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
            label289: {
                label281: {
                    Pets other = (Pets)that;
                    if (this.getId() == null) {
                        if (other.getId() != null) {
                            break label281;
                        }
                    } else if (!this.getId().equals(other.getId())) {
                        break label281;
                    }

                    if (this.getOwnerid() == null) {
                        if (other.getOwnerid() != null) {
                            break label281;
                        }
                    } else if (!this.getOwnerid().equals(other.getOwnerid())) {
                        break label281;
                    }

                    if (this.getPetid() == null) {
                        if (other.getPetid() != null) {
                            break label281;
                        }
                    } else if (!this.getPetid().equals(other.getPetid())) {
                        break label281;
                    }

                    if (this.getNickname() == null) {
                        if (other.getNickname() != null) {
                            break label281;
                        }
                    } else if (!this.getNickname().equals(other.getNickname())) {
                        break label281;
                    }

                    if (this.getName() == null) {
                        if (other.getName() != null) {
                            break label281;
                        }
                    } else if (!this.getName().equals(other.getName())) {
                        break label281;
                    }

                    if (this.getHorsetype() == null) {
                        if (other.getHorsetype() != null) {
                            break label281;
                        }
                    } else if (!this.getHorsetype().equals(other.getHorsetype())) {
                        break label281;
                    }

                    if (this.getType() == null) {
                        if (other.getType() != null) {
                            break label281;
                        }
                    } else if (!this.getType().equals(other.getType())) {
                        break label281;
                    }

                    if (this.getLevel() == null) {
                        if (other.getLevel() != null) {
                            break label281;
                        }
                    } else if (!this.getLevel().equals(other.getLevel())) {
                        break label281;
                    }

                    if (this.getLiliang() == null) {
                        if (other.getLiliang() != null) {
                            break label281;
                        }
                    } else if (!this.getLiliang().equals(other.getLiliang())) {
                        break label281;
                    }

                    if (this.getMinjie() == null) {
                        if (other.getMinjie() != null) {
                            break label281;
                        }
                    } else if (!this.getMinjie().equals(other.getMinjie())) {
                        break label281;
                    }

                    if (this.getLingli() == null) {
                        if (other.getLingli() != null) {
                            break label281;
                        }
                    } else if (!this.getLingli().equals(other.getLingli())) {
                        break label281;
                    }

                    if (this.getTili() == null) {
                        if (other.getTili() != null) {
                            break label281;
                        }
                    } else if (!this.getTili().equals(other.getTili())) {
                        break label281;
                    }

                    if (this.getDianhualx() == null) {
                        if (other.getDianhualx() != null) {
                            break label281;
                        }
                    } else if (!this.getDianhualx().equals(other.getDianhualx())) {
                        break label281;
                    }

                    if (this.getDianhuazd() == null) {
                        if (other.getDianhuazd() != null) {
                            break label281;
                        }
                    } else if (!this.getDianhuazd().equals(other.getDianhuazd())) {
                        break label281;
                    }

                    if (this.getDianhuazx() == null) {
                        if (other.getDianhuazx() != null) {
                            break label281;
                        }
                    } else if (!this.getDianhuazx().equals(other.getDianhuazx())) {
                        break label281;
                    }

                    if (this.getYuhualx() == null) {
                        if (other.getYuhualx() != null) {
                            break label281;
                        }
                    } else if (!this.getYuhualx().equals(other.getYuhualx())) {
                        break label281;
                    }

                    if (this.getYuhuazd() == null) {
                        if (other.getYuhuazd() != null) {
                            break label281;
                        }
                    } else if (!this.getYuhuazd().equals(other.getYuhuazd())) {
                        break label281;
                    }

                    if (this.getYuhuazx() == null) {
                        if (other.getYuhuazx() != null) {
                            break label281;
                        }
                    } else if (!this.getYuhuazx().equals(other.getYuhuazx())) {
                        break label281;
                    }

                    if (this.getCwjyzx() == null) {
                        if (other.getCwjyzx() != null) {
                            break label281;
                        }
                    } else if (!this.getCwjyzx().equals(other.getCwjyzx())) {
                        break label281;
                    }

                    if (this.getCwjyzd() == null) {
                        if (other.getCwjyzd() != null) {
                            break label281;
                        }
                    } else if (!this.getCwjyzd().equals(other.getCwjyzd())) {
                        break label281;
                    }

                    if (this.getFeisheng() == null) {
                        if (other.getFeisheng() != null) {
                            break label281;
                        }
                    } else if (!this.getFeisheng().equals(other.getFeisheng())) {
                        break label281;
                    }

                    if (this.getFsudu() == null) {
                        if (other.getFsudu() != null) {
                            break label281;
                        }
                    } else if (!this.getFsudu().equals(other.getFsudu())) {
                        break label281;
                    }

                    if (this.getQhcwWg() == null) {
                        if (other.getQhcwWg() != null) {
                            break label281;
                        }
                    } else if (!this.getQhcwWg().equals(other.getQhcwWg())) {
                        break label281;
                    }

                    if (this.getQhcwFg() == null) {
                        if (other.getQhcwFg() != null) {
                            break label281;
                        }
                    } else if (!this.getQhcwFg().equals(other.getQhcwFg())) {
                        break label281;
                    }

                    if (this.getCwXiangxing() == null) {
                        if (other.getCwXiangxing() != null) {
                            break label281;
                        }
                    } else if (!this.getCwXiangxing().equals(other.getCwXiangxing())) {
                        break label281;
                    }

                    if (this.getCwWuxue() == null) {
                        if (other.getCwWuxue() != null) {
                            break label281;
                        }
                    } else if (!this.getCwWuxue().equals(other.getCwWuxue())) {
                        break label281;
                    }

                    if (this.getCwIcon() == null) {
                        if (other.getCwIcon() != null) {
                            break label281;
                        }
                    } else if (!this.getCwIcon().equals(other.getCwIcon())) {
                        break label281;
                    }

                    if (this.getCwXinfa() == null) {
                        if (other.getCwXinfa() != null) {
                            break label281;
                        }
                    } else if (!this.getCwXinfa().equals(other.getCwXinfa())) {
                        break label281;
                    }

                    if (this.getCwQinmi() == null) {
                        if (other.getCwQinmi() != null) {
                            break label281;
                        }
                    } else if (!this.getCwQinmi().equals(other.getCwQinmi())) {
                        break label281;
                    }

                    if (this.getAddTime() == null) {
                        if (other.getAddTime() != null) {
                            break label281;
                        }
                    } else if (!this.getAddTime().equals(other.getAddTime())) {
                        break label281;
                    }

                    if (this.getUpdateTime() == null) {
                        if (other.getUpdateTime() != null) {
                            break label281;
                        }
                    } else if (!this.getUpdateTime().equals(other.getUpdateTime())) {
                        break label281;
                    }

                    if (this.getDeleted() == null) {
                        if (other.getDeleted() == null) {
                            break label289;
                        }
                    } else if (this.getDeleted().equals(other.getDeleted())) {
                        break label289;
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
        result = 31 * result + (this.getOwnerid() == null ? 0 : this.getOwnerid().hashCode());
        result = 31 * result + (this.getPetid() == null ? 0 : this.getPetid().hashCode());
        result = 31 * result + (this.getNickname() == null ? 0 : this.getNickname().hashCode());
        result = 31 * result + (this.getName() == null ? 0 : this.getName().hashCode());
        result = 31 * result + (this.getHorsetype() == null ? 0 : this.getHorsetype().hashCode());
        result = 31 * result + (this.getType() == null ? 0 : this.getType().hashCode());
        result = 31 * result + (this.getLevel() == null ? 0 : this.getLevel().hashCode());
        result = 31 * result + (this.getLiliang() == null ? 0 : this.getLiliang().hashCode());
        result = 31 * result + (this.getMinjie() == null ? 0 : this.getMinjie().hashCode());
        result = 31 * result + (this.getLingli() == null ? 0 : this.getLingli().hashCode());
        result = 31 * result + (this.getTili() == null ? 0 : this.getTili().hashCode());
        result = 31 * result + (this.getDianhualx() == null ? 0 : this.getDianhualx().hashCode());
        result = 31 * result + (this.getDianhuazd() == null ? 0 : this.getDianhuazd().hashCode());
        result = 31 * result + (this.getDianhuazx() == null ? 0 : this.getDianhuazx().hashCode());
        result = 31 * result + (this.getYuhualx() == null ? 0 : this.getYuhualx().hashCode());
        result = 31 * result + (this.getYuhuazd() == null ? 0 : this.getYuhuazd().hashCode());
        result = 31 * result + (this.getYuhuazx() == null ? 0 : this.getYuhuazx().hashCode());
        result = 31 * result + (this.getCwjyzx() == null ? 0 : this.getCwjyzx().hashCode());
        result = 31 * result + (this.getCwjyzd() == null ? 0 : this.getCwjyzd().hashCode());
        result = 31 * result + (this.getFeisheng() == null ? 0 : this.getFeisheng().hashCode());
        result = 31 * result + (this.getFsudu() == null ? 0 : this.getFsudu().hashCode());
        result = 31 * result + (this.getQhcwWg() == null ? 0 : this.getQhcwWg().hashCode());
        result = 31 * result + (this.getQhcwFg() == null ? 0 : this.getQhcwFg().hashCode());
        result = 31 * result + (this.getCwXiangxing() == null ? 0 : this.getCwXiangxing().hashCode());
        result = 31 * result + (this.getCwWuxue() == null ? 0 : this.getCwWuxue().hashCode());
        result = 31 * result + (this.getCwIcon() == null ? 0 : this.getCwIcon().hashCode());
        result = 31 * result + (this.getCwXinfa() == null ? 0 : this.getCwXinfa().hashCode());
        result = 31 * result + (this.getCwQinmi() == null ? 0 : this.getCwQinmi().hashCode());
        result = 31 * result + (this.getAddTime() == null ? 0 : this.getAddTime().hashCode());
        result = 31 * result + (this.getUpdateTime() == null ? 0 : this.getUpdateTime().hashCode());
        result = 31 * result + (this.getDeleted() == null ? 0 : this.getDeleted().hashCode());
        return result;
    }

    public Pets clone() throws CloneNotSupportedException {
        return (Pets)super.clone();
    }

    static {
        IS_DELETED = Pets.Deleted.IS_DELETED.value();
        NOT_DELETED = Pets.Deleted.NOT_DELETED.value();
    }

    public static enum Column {
        id("id", "id", "INTEGER", false),
        ownerid("ownerid", "ownerid", "VARCHAR", false),
        petid("petid", "petid", "VARCHAR", false),
        nickname("nickname", "nickname", "VARCHAR", false),
        name("name", "name", "VARCHAR", true),
        horsetype("horsetype", "horsetype", "INTEGER", false),
        type("type", "type", "INTEGER", true),
        level("level", "level", "INTEGER", true),
        liliang("liliang", "liliang", "INTEGER", false),
        minjie("minjie", "minjie", "INTEGER", false),
        lingli("lingli", "lingli", "INTEGER", false),
        tili("tili", "tili", "INTEGER", false),
        dianhualx("dianhualx", "dianhualx", "INTEGER", false),
        dianhuazd("dianhuazd", "dianhuazd", "INTEGER", false),
        dianhuazx("dianhuazx", "dianhuazx", "INTEGER", false),
        yuhualx("yuhualx", "yuhualx", "INTEGER", false),
        yuhuazd("yuhuazd", "yuhuazd", "INTEGER", false),
        yuhuazx("yuhuazx", "yuhuazx", "INTEGER", false),
        cwjyzx("cwjyzx", "cwjyzx", "INTEGER", false),
        cwjyzd("cwjyzd", "cwjyzd", "INTEGER", false),
        feisheng("feisheng", "feisheng", "INTEGER", false),
        fsudu("fsudu", "fsudu", "INTEGER", false),
        qhcwWg("qhcw_wg", "qhcwWg", "INTEGER", false),
        qhcwFg("qhcw_fg", "qhcwFg", "INTEGER", false),
        cwXiangxing("cw_xiangxing", "cwXiangxing", "INTEGER", false),
        cwWuxue("cw_wuxue", "cwWuxue", "INTEGER", false),
        cwIcon("cw_icon", "cwIcon", "VARCHAR", false),
        cwXinfa("cw_xinfa", "cwXinfa", "INTEGER", false),
        cwQinmi("cw_qinmi", "cwQinmi", "INTEGER", false),
        addTime("add_time", "addTime", "TIMESTAMP", false),
        updateTime("update_time", "updateTime", "TIMESTAMP", false),
        deleted("deleted", "deleted", "BIT", false);

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

        public static Pets.Column[] excludes(Pets.Column... excludes) {
            ArrayList<Pets.Column> columns = new ArrayList(Arrays.asList(values()));
            if (excludes != null && excludes.length > 0) {
                columns.removeAll(new ArrayList(Arrays.asList(excludes)));
            }

            return (Pets.Column[])columns.toArray(new Pets.Column[0]);
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
