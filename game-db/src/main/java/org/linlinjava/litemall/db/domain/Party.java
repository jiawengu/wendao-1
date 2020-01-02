package org.linlinjava.litemall.db.domain;

public class Party {
    private Integer id;

    private String name;

    private String announce;

    private String member;

    private Integer level;

    private Integer construction;

    private String creator;

    public Party(Integer id, String name, String announce, String member, Integer level, Integer construction, String creator) {
        this.id = id;
        this.name = name;
        this.announce = announce;
        this.member = member;
        this.level = level;
        this.construction = construction;
        this.creator = creator;
    }

    public Party() {
        super();
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name == null ? null : name.trim();
    }

    public String getAnnounce() {
        return announce;
    }

    public void setAnnounce(String announce) {
        this.announce = announce == null ? null : announce.trim();
    }

    public String getMember() {
        return member;
    }

    public void setMember(String member) {
        this.member = member == null ? null : member.trim();
    }

    public Integer getLevel() {
        return level;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }

    public Integer getConstruction() {
        return construction;
    }

    public void setConstruction(Integer construction) {
        this.construction = construction;
    }

    public String getCreator() {
        return creator;
    }

    public void setCreator(String creator) {
        this.creator = creator == null ? null : creator.trim();
    }
}