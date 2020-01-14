package org.linlinjava.litemall.db.task;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TaskChain {
    private List<TaskVO> taskList;

    private Integer chainId;

    public boolean isCompleted(int taskId) {
        return taskList.get(taskList.size() - 1).getTaskId() == taskId;
    }

    public TaskVO getTask(Integer taskId) {
        for (TaskVO taskVO : taskList) {
            if (taskVO.getTaskId().equals(taskId)) {
                return taskVO;
            }
        }

        return null;
    }

    public TaskVO getFirstTask() {
        return taskList.get(0);
    }

    public TaskVO getNextTask(Integer taskId) {
        int index = 0;

        for (TaskVO taskVO : taskList) {
            if (taskVO.getTaskId().equals(taskId)) {
                if (index == taskList.size() - 1) {
                    return null;
                } else {
                    return taskList.get(index + 1);
                }
            }
            index += 1;
        }

        return null;
    }
}
