//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.data.game;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.DefaultResourceLoader;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;

public class PetAndHelpSkillUtils {
    private static String skillJson = null;
    private static ResourceLoader resourceLoader = new DefaultResourceLoader();
    private static final Logger log = LoggerFactory.getLogger(PetAndHelpSkillUtils.class);

    public PetAndHelpSkillUtils() {
    }

    public static int getMaxSkill(int attrib) {
        int maxSkill = (int)((double)attrib * 1.6D);
        return maxSkill;
    }

    public static List<JSONObject> getNomelSkills(int pet, int pMetal, int attrib, boolean isMagic) throws JSONException {
        return getNomelSkills(pet, pMetal, attrib, isMagic, "");
    }

    public static List<JSONObject> getSkills(int pMetal, int level, String skill_value) throws JSONException {
        if (skillJson == null) {
            BufferedReader br = getResFile();
            StringBuilder strb = new StringBuilder();
            br.lines().forEach((f) -> {
                strb.append(f);
            });
            skillJson = strb.toString();
        }

        JSONArray jsonArray = new JSONArray(skillJson);
        List<JSONObject> result = new ArrayList<>();
        if(null == skill_value || skill_value.isEmpty()){
            return result;

        }
        for(int i = 0; i < jsonArray.length(); ++i) {
            JSONObject jsonObject = jsonArray.optJSONObject(i);
            int metal = jsonObject.optInt("metal");
            String skillType = jsonObject.optString("skillType");
            String skillName = jsonObject.optString("skillName");
            int skillIndex = jsonObject.optInt("skillIndex");
            if (skill_value.contains(skillName) && pMetal == metal) {
                int[] skillNum_round = skillNum(jsonObject, getMaxSkill(level));
                jsonObject.put("skillNum", skillNum_round[0]);
                jsonObject.put("skillRound", skillNum_round[1]);
                jsonObject.put("skillLevel", getMaxSkill(level));
                jsonObject.remove("skillUse");
                jsonObject = appendBP(jsonObject, skillType, skillIndex, level);

                result.add(jsonObject);
            }
        }

        return result;
    }

    /**
     *
     * @param pet 类型 宠物：1，守护：2
     * @param pMetal    金木水火土
     * @param attrib    等级
     * @param isMagic   是否是魔法
     * @param skill_value
     * @return
     * @throws JSONException
     */
    public static List<JSONObject> getNomelSkills(int pet, int pMetal, int attrib, boolean isMagic, String skill_value) throws JSONException {
        if (skillJson == null) {
            BufferedReader br = getResFile();
            StringBuilder strb = new StringBuilder();
            br.lines().forEach((f) -> {
                strb.append(f);
            });
            skillJson = strb.toString();
        }

        JSONArray jsonArray = new JSONArray(skillJson);
        int[] sh_gj = new int[]{1, 19, 32, 50, 100};
        int sh_gj_count = 0;

        for(int i = sh_gj.length - 1; i >= 0; --i) {
            if (attrib >= sh_gj[i]) {
                sh_gj_count = i + 1;
                break;
            }
        }

        int[] sh_fz = new int[]{1, 1, 1, 50, 100};
        int sh_fz_count = 0;

        for(int i = sh_fz.length - 1; i >= 0; --i) {
            if (attrib >= sh_fz[i]) {
                sh_fz_count = i + 1;
                break;
            }
        }


        int[] pet_gj = new int[]{20, 40, 60};
        List<Integer> pet_gj_counts = new ArrayList();

        int i;
        for(i = pet_gj.length - 1; i >= 0; --i) {
            if (attrib >= pet_gj[i]) {
                if (i == 2) {
                    pet_gj_counts.add(1);
                    pet_gj_counts.add(2);
                    pet_gj_counts.add(4);
                } else if (i == 1) {
                    pet_gj_counts.add(1);
                    pet_gj_counts.add(2);
                } else {
                    pet_gj_counts.add(1);
                }
                break;
            }
        }

        List<JSONObject> sh_gj_list = new ArrayList();
        List<JSONObject> sh_fz_list = new ArrayList();
        List<JSONObject> pet_gj_list = new ArrayList();

        JSONObject jsonObject;
        int metal;
        String skillType;
        int skillIndex;
        int[] skillNum_round;
        if (pet == 2 && (null == skill_value || skill_value.isEmpty())) {//守护
            for(i = 0; i < jsonArray.length(); ++i) {
                jsonObject = jsonArray.optJSONObject(i);
                metal = jsonObject.optInt("metal");
                skillType = jsonObject.optString("skillType");
                skillIndex = jsonObject.optInt("skillIndex");
                if (skillType.contentEquals("FS") && pMetal == metal && (pMetal == 1 || pMetal == 2 || pMetal == 3) && skillIndex <= sh_gj_count) {
                    skillNum_round = skillNum(jsonObject, getMaxSkill(attrib));
                    jsonObject.put("skillNum", skillNum_round[0]);
                    jsonObject.put("skillRound", skillNum_round[1]);
                    jsonObject.put("skillLevel", getMaxSkill(attrib));
                    jsonObject.remove("skillUse");
                    jsonObject = appendBP(jsonObject, skillType, skillIndex, attrib);
                    sh_gj_list.add(jsonObject);
                } else if (skillType.contentEquals("WS") && pMetal == metal && (pMetal == 4 || pMetal == 5) && skillIndex <= sh_gj_count) {
                    skillNum_round = skillNum(jsonObject, getMaxSkill(attrib));
                    jsonObject.put("skillNum", skillNum_round[0]);
                    jsonObject.put("skillRound", skillNum_round[1]);
                    jsonObject.put("skillLevel", getMaxSkill(attrib));
                    jsonObject.remove("skillUse");
                    jsonObject = appendBP(jsonObject, skillType, skillIndex, attrib);
                    sh_gj_list.add(jsonObject);
                } else if (skillType.contentEquals("FZ") && pMetal == metal && skillIndex <= sh_fz_count) {
                    skillNum_round = skillNum(jsonObject, getMaxSkill(attrib));
                    jsonObject.put("skillNum", skillNum_round[0]);
                    jsonObject.put("skillRound", skillNum_round[1]);
                    jsonObject.put("skillLevel", getMaxSkill(attrib));
                    jsonObject.remove("skillUse");
                    jsonObject = appendBP(jsonObject, skillType, skillIndex, attrib);
                    sh_fz_list.add(jsonObject);
                }
            }

            sh_gj_list.addAll(sh_fz_list);
            return sh_gj_list;
        } else if (pet == 1 && isMagic && (null == skill_value || skill_value.isEmpty())) {//宠物
            for(i = 0; i < jsonArray.length(); ++i) {
                jsonObject = jsonArray.optJSONObject(i);
                metal = jsonObject.optInt("metal");
                skillType = jsonObject.optString("skillType");
                skillIndex = jsonObject.optInt("skillIndex");
                if (pet_gj_counts.contains(skillIndex) && skillType.contentEquals("FS") && pMetal == metal) {
                    skillNum_round = skillNum(jsonObject, getMaxSkill(attrib));
                    jsonObject.put("skillNum", skillNum_round[0]);
                    jsonObject.put("skillRound", skillNum_round[1]);
                    jsonObject.put("skillLevel", getMaxSkill(attrib));
                    jsonObject.remove("skillUse");
                    jsonObject.remove("skillRound");
                    jsonObject = appendBP(jsonObject, skillType, skillIndex, attrib);
                    pet_gj_list.add(jsonObject);
                }
            }

            return pet_gj_list;
        } else if (null != skill_value && !skill_value.isEmpty()) {
            for(i = 0; i < jsonArray.length(); ++i) {
                jsonObject = jsonArray.optJSONObject(i);
                metal = jsonObject.optInt("metal");
                skillType = jsonObject.optString("skillType");
                skillIndex = jsonObject.optInt("skillIndex");
                String skillType_skillIndex = String.format("%s_%d", skillType, skillIndex);
                if (skill_value.contains(skillType_skillIndex) && pMetal == metal) {
                   skillNum_round = skillNum(jsonObject, getMaxSkill(attrib));
                    jsonObject.put("skillNum", skillNum_round[0]);
                    jsonObject.put("skillRound", skillNum_round[1]);
                    jsonObject.put("skillLevel", getMaxSkill(attrib));
                    jsonObject.remove("skillUse");
                    jsonObject = appendBP(jsonObject, skillType, skillIndex, attrib);
                    if (skillIndex == 5) {
                        if (sh_gj_count >= 5) {
                            pet_gj_list.add(jsonObject);
                        }
                    } else {
                        pet_gj_list.add(jsonObject);
                    }
                }
            }

            return pet_gj_list;
        } else {
            return sh_gj_list;
        }
    }

    private static JSONObject appendBP(JSONObject jsonObject, String skillType, int skillIndex, int attrib) throws JSONException {
        int[] bp = getBlueAndPoints(skillType, skillIndex, attrib);
        jsonObject.put("skillBlue", bp[0]);
        jsonObject.put("skillPoint", bp[1]);
        return jsonObject;
    }

    private static int[] getBlueAndPoints(String skillType, int skillIndex, int attrib) {
        int[] bp = new int[]{1, 1};
        if (attrib == 1) {
            return bp;
        } else {
            if (skillType.contentEquals("WS")) {
                bp[0] = (int)((double)attrib * 17.5D);
                bp[1] = attrib * attrib * 60;
            } else {
                Hashtable<String, Double> addHashtable = new Hashtable();
                addHashtable.put("FS", 0.0D);
                addHashtable.put("ZA", 0.3D);
                addHashtable.put("FZ", 0.4D);
                addHashtable.put("BD", 0.5D);
                Double add = (Double)addHashtable.get(skillType);
                if (null == add) {
                    add = 0.0D;
                }

                switch(skillIndex) {
                    case 1:
                        bp[0] = (int)((double)attrib * (10.7D + add));
                        bp[1] = (int)((double)(attrib * attrib) * (15.7D + add));
                        break;
                    case 2:
                        bp[0] = (int)((double)attrib * (13.5D + add));
                        bp[1] = (int)((double)(attrib * attrib) * (14.0D + add));
                        break;
                    case 3:
                        bp[0] = (int)((double)attrib * (15.5D + add));
                        bp[1] = (int)((double)(attrib * attrib) * (22.0D + add));
                        break;
                    case 4:
                        bp[0] = (int)((double)attrib * (25.0D + add));
                        bp[1] = (int)((double)(attrib * attrib) * (33.0D + add));
                        break;
                    case 5:
                        bp[0] = (int)((double)attrib * (28.0D + add));
                        bp[1] = (int)((double)(attrib * attrib) * (43.0D + add));
                }
            }

            return bp;
        }
    }

    /**
     * 根据等级获取skillNum和skillRound
     * @param skillObject
     * @param skill
     * @return
     */
    public static int[] skillNum(JSONObject skillObject, int skill) {
        JSONArray jsonArray = skillObject.optJSONArray("skillUse");
        JSONArray jsonArrayRound = skillObject.optJSONArray("skillRound");
        int[] num_round = new int[2];
        if (null == jsonArray || jsonArray.length() == 0) {
            num_round[0] = 1;
        }

        if (null == jsonArrayRound || jsonArrayRound.length() == 0) {
            num_round[1] = 1;
        }

        int i;
        JSONObject jsonObject;
        int skillLevelMin;
        int skillLevel;
        int skillRound;
        if (num_round[0] == 0) {
            for(i = 0; i < jsonArray.length(); ++i) {
                jsonObject = jsonArray.optJSONObject(i);
                skillLevelMin = jsonObject.optInt("skillLevelMin");
                skillLevel = jsonObject.optInt("skillLevel");
                skillRound = jsonObject.optInt("skillNum");
                if (skill >= skillLevelMin && skill <= skillLevel) {
                    num_round[0] = skillRound;
                }
            }
        }

        if (num_round[0] == 0) {
            num_round[0] = 1;
        }

        if (num_round[1] == 0) {
            for(i = 0; i < jsonArrayRound.length(); ++i) {
                jsonObject = jsonArrayRound.optJSONObject(i);
                skillLevelMin = jsonObject.optInt("skillLevelMin");
                skillLevel = jsonObject.optInt("skillLevel");
                skillRound = jsonObject.optInt("skillRound");
                if (skill >= skillLevelMin && skill <= skillLevel) {
                    num_round[1] = skillRound;
                }
            }
        }

        if (num_round[1] == 0) {
            num_round[1] = 1;
        }

        return num_round;
    }

    private static BufferedReader getResFile() {
        Resource resource = resourceLoader.getResource("classpath:static/user_skill.json");
        BufferedReader br = null;

        try {
            InputStream inputStream = resource.getInputStream();
            InputStreamReader fr = new InputStreamReader(inputStream);
            br = new BufferedReader(fr);
        } catch (IOException var4) {
            log.error("", var4);
        }

        return br;
    }

    public static JSONObject jsonArray(int skillNo) {
        StringBuilder leixing;
        if (skillJson == null) {
            BufferedReader br = getResFile();
            leixing = new StringBuilder();
            StringBuilder finalLeixing = leixing;
            br.lines().forEach((f) -> {
                finalLeixing.append(f);
            });
            skillJson = leixing.toString();
        }

        JSONArray jsonArray = new JSONArray(skillJson);
        leixing = null;

        String skill_attrib = null;

        for(int i = 0; i < jsonArray.length(); ++i) {
            JSONObject jsonObject = jsonArray.optJSONObject(i);
            int no = jsonObject.optInt("skillNo");
            if (no == skillNo) {
                String leixing2 = jsonObject.optString("skillType");
                int skillIndex = jsonObject.optInt("skillIndex");
                skill_attrib = jsonObject.optString("skill_attrib");
                return jsonObject;
            }
        }

        return null;
    }

    public int skillNummax(int skillNo, int skill) {
        JSONObject skillObject = jsonArray(skillNo);
        JSONArray jsonArray = skillObject.optJSONArray("skillUse");
        if (null != jsonArray && jsonArray.length() != 0) {
            for(int i = 0; i < jsonArray.length(); ++i) {
                JSONObject jsonObject = jsonArray.optJSONObject(i);
                int skillLevelMin = jsonObject.optInt("skillLevelMin");
                int skillLevel = jsonObject.optInt("skillLevel");
                int skillNum = jsonObject.optInt("skillNum");
                if (skill >= skillLevelMin && skill <= skillLevel) {
                    return skillNum;
                }
            }

            return 1;
        } else {
            return 1;
        }
    }

    public int[] getBlueAndPointsLan(int skillNo, int attrib) {
        if (skillJson == null) {
            BufferedReader br = getResFile();
            StringBuilder strb = new StringBuilder();
            br.lines().forEach((f) -> {
                strb.append(f);
            });
            skillJson = strb.toString();
        }

        JSONArray jsonArray = new JSONArray(skillJson);
        String leixing = null;
        int skillIndex = 0;

        for(int i = 0; i < jsonArray.length(); ++i) {
            JSONObject jsonObject = jsonArray.optJSONObject(i);
            int no = jsonObject.optInt("skillNo");
            if (no == skillNo) {
                leixing = jsonObject.optString("skillType");
                skillIndex = jsonObject.optInt("skillIndex");
                break;
            }
        }

        int[] bp = new int[]{1, 1};
        if (attrib == 1) {
            return bp;
        } else {
            if (leixing.contentEquals("WS")) {
                bp[0] = (int)((double)attrib * 17.5D);
                bp[1] = attrib * attrib * 60;
            } else {
                Hashtable<String, Double> addHashtable = new Hashtable();
                addHashtable.put("FS", 0.0D);
                addHashtable.put("ZA", 0.3D);
                addHashtable.put("FZ", 0.4D);
                addHashtable.put("BD", 0.5D);
                Double add = (Double)addHashtable.get(leixing);
                if (null == add) {
                    add = 0.0D;
                }

                switch(skillIndex) {
                    case 1:
                        bp[0] = (int)((double)attrib * (10.7D + add));
                        bp[1] = (int)((double)(attrib * attrib) * (15.7D + add));
                        break;
                    case 2:
                        bp[0] = (int)((double)attrib * (13.5D + add));
                        bp[1] = (int)((double)(attrib * attrib) * (14.0D + add));
                        break;
                    case 3:
                        bp[0] = (int)((double)attrib * (15.5D + add));
                        bp[1] = (int)((double)(attrib * attrib) * (22.0D + add));
                        break;
                    case 4:
                        bp[0] = (int)((double)attrib * (25.0D + add));
                        bp[1] = (int)((double)(attrib * attrib) * (33.0D + add));
                        break;
                    case 5:
                        bp[0] = (int)((double)attrib * (28.0D + add));
                        bp[1] = (int)((double)(attrib * attrib) * (43.0D + add));
                }

                if (leixing.contentEquals("BD")) {
                    bp[1] = attrib * 70000 + 140000;
                }
            }

            return bp;
        }
    }
}
