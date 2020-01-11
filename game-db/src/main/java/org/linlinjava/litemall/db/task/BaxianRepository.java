package org.linlinjava.litemall.db.task;

import com.alibaba.fastjson.JSON;
import com.google.common.collect.Maps;
import org.apache.commons.io.FileUtils;
import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.db.service.base.BaseMapService;
import org.linlinjava.litemall.db.service.base.BaseNpcService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.util.ResourceUtils;
import reactor.util.function.Tuple2;

import javax.annotation.PostConstruct;
import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@Repository
public class BaxianRepository {
    private static final Logger logger = LoggerFactory.getLogger(BaxianRepository.class);

    private Map<Integer, TaskChain> taskChainMap = Maps.newHashMap();

    @Autowired
    private BaseMapService mapService;

    @Autowired
    private BaseNpcService npcService;

    @PostConstruct
    private void init() {
        try {
            File jsonFile = ResourceUtils.getFile("classpath:data/baxian.json");
            String json = FileUtils.readFileToString(jsonFile, "UTF-8");
            List<TaskChain> taskChainList = JSON.parseArray(json, TaskChain.class);
            for (TaskChain taskChain : taskChainList) {
                for (TaskVO taskVO : taskChain.getTaskList()) {
                    taskVO.setChainId(taskChain.getChainId());
                    Integer npcId = taskVO.getNpcId();
                    Npc npc = npcService.findById(npcId);
                    if (npc != null) {
                        taskVO.setMapId(npc.getMapId());
                        taskVO.setNpcX(npc.getX());
                        taskVO.setNpcY(npc.getY());
                        List<org.linlinjava.litemall.db.domain.Map> mapList = mapService.findByMapId(npc.getMapId());
                        if (mapList.size() != 0) {
                            taskVO.setMapName(mapList.get(0).getName());
                        }
                    }
                }
                taskChainMap.put(taskChain.getChainId(), taskChain);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        logger.info(taskChainMap.toString());
    }

    public TaskVO getChainAndTaskIdByNpcId(int npcId) {
        for (Integer chainId : taskChainMap.keySet()) {
            TaskChain taskChain = taskChainMap.get(chainId);
            for (TaskVO taskVO : taskChain.getTaskList()) {
                if (taskVO.getNpcId().equals(npcId)) {
                    return taskVO;
                }
            }
        }
        return null;
    }

    public TaskVO getNextTask(Integer chainId, Integer taskId) {
        TaskChain taskChain = taskChainMap.getOrDefault(chainId, null);
        if (taskChain == null) return null;
        if (taskId == null) {
            return taskChain.getFirstTask();
        } else {
            return taskChain.getNextTask(taskId);
        }
    }

    public TaskVO getTask(Integer chainId, Integer taskId) {
        TaskChain taskChain = taskChainMap.getOrDefault(chainId, null);
        if (taskChain == null) return null;
        if (taskId != null) {
            return taskChain.getTask(taskId);
        }
        return null;
    }
}
