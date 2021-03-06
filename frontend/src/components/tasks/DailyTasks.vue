<template>
  <div class="task-board">
    <div class="task-board__header">
      <h2 class="task-board__heading">{{ dateString }}</h2>
      <span v-if="totalTime">{{ totalTime }}</span>
    </div>
    <div class="task-board__body">
      <draggable
        tag="ul"
        group="TASKS"
        :list="taskList"
        :animation="200"
        @end="onDragEnd"
        :data-date="separatedDate"
        handle=".handle"
      >
        <li
          v-for="task of taskList"
          :key="task.id"
          :data-task_id="task.id"
          class="task-board__li"
        >
          <div v-if="onUpdatedTaskId !== task.id" class="task-board__with-icon">
            <div @click="openUpdateForm(task.id)" class="task-board__task  handle" :class="{ todayTask: forToday }">
              <p class="task-board__p">
                {{ task.content }}
                <span class="task-board__time">{{ taskTimes(task) }}分</span>
              </p>
            </div>
            <div v-if="forToday" v-show="draggingId !== task.id" class="task-board__with-icon--left">
              <a :class="{ disabled: !!currentTask }" href="Javascript:void(0)" @click="upload(task)">
                <i class="el-icon-upload2"></i>
              </a>
            </div>
          </div>
          <TaskForm
            v-else
            :formIsOpen="true"
            :taskId="task.id"
            :taskContent="task.content"
            :taskExpectedTime="toMinutes(task.expected_time)"
            :taskElapsedTime="0"
            :isNewTask="false"
            ref="updateForm"
            @close-form="closeForm"
            @update-task="updateTask($event, task.id)"
          ></TaskForm>
        </li>
      </draggable>
      <a @click="openForm" v-show="!newFormIsOpen" href="Javascript:void(0)" class="task-board__add">
        <i class="el-icon-plus"></i>
        タスクを追加
      </a>
      <TaskForm
        :formIsOpen="newFormIsOpen"
        taskContent=""
        :taskExpectedTime="0"
        :taskElapsedTime="0"
        :isNewTask="true"
        ref="newForm"
        @close-form="closeForm"
        @add-task="addTask"
      ></TaskForm>
    </div>
  </div>
</template>

<script>
import draggable from 'vuedraggable'
import { mapGetters, mapActions } from 'vuex'
import TaskForm from '@/components/TaskForm.vue'
import {
  ADD_NEW_TASK,
  UPDATE_TASK_CONTENT,
  UPDATE_TASK_ORDER,
  START_TASK,
} from '@/store/mutation-types'

export default {
  name: 'DailyTasks',
  data() {
    return {
      newFormIsOpen: false,
      onUpdatedTaskId: '',
      draggingId: null,
      taskList: []
    }
  },
  props: {
    date: Object,
    forToday: Boolean
  },
  components: {
    draggable,
    TaskForm
  },
  computed: {
    ...mapGetters('daily', ['dailyTasks', 'currentTask']),
    computedTasks() {
      return this.dailyTasks(this.date)
    },
    dateString() {
      return this.date.format('M/D(ddd)')
    },
    separatedDate() {
      return this.date.format('YYYY-MM-DD')
    },
    totalTime() {
      let times = this.computedTasks.map(task => task.expected_time)
      if (!times.length) return null;
      let total = times.reduce((prev, current) => prev + current)
      let m = this.toMinutes(total)
      let h = Math.floor(m / 60)
      m -= h * 60
      let hString = h ? `${h}時間` : ''
      return `${hString}${m}分`
    }
  },
  methods: {
    ...mapActions('daily', [ADD_NEW_TASK, UPDATE_TASK_CONTENT, UPDATE_TASK_ORDER, START_TASK]),
    toMinutes(time) {
      return Math.ceil(time / (1000 * 60))
    },
    taskTimes(task) {
      let elapsed = task.elapsed_time
      let elapsedString = (elapsed ? `${this.toMinutes(elapsed)}/` : '')
      return `${elapsedString}${this.toMinutes(task.expected_time)}`
    },
    closeForm() {
      this.newFormIsOpen = false
      let self = this
      setTimeout(() => self.onUpdatedTaskId = '')
    },
    openForm() {
      this.newFormIsOpen = true
      let self = this
      setTimeout(() => self.$refs.newForm.focusForm())
    },
    openUpdateForm(taskId) {
      this.onUpdatedTaskId = taskId
      let self = this
      setTimeout(() => self.$refs.updateForm[0].focusForm())
    },
    addTask(e) {
      let tasks = this.computedTasks
      let newOrder = tasks.length
      let newTask = {
        content: e.content,
        expected_time: e.expected_time,
        is_completed: false,
        elapsed_time: 0,
        date: this.separatedDate,
        order: newOrder
      }
      this[ADD_NEW_TASK](newTask)
      this.$refs.newForm.focusForm()
    },
    updateTask(e, task_id) {
      let payload = { id: task_id, task: e }
      this[UPDATE_TASK_CONTENT](payload)
      this.closeForm()
    },
    onDragEnd(e) {
      let taskId = Number.parseInt(e.clone.dataset.task_id)
      this.draggingId = taskId // ドラッグ後に一瞬現れるアイコン対策

      let toCompleted = (e.to.dataset.completed ? true : false)
      let payload = {
        fromDate: e.from.dataset.date,
        toDate: e.to.dataset.date,
        oldIndex: e.oldIndex,
        newIndex: e.newIndex,
        fromCompleted: false,
        toCompleted,
        taskId
      }

      if (e.to.dataset.working) {
        let self = this
        setTimeout(() => {
          self.draggingId = null
        }, 1000)
      } else {
        this[UPDATE_TASK_ORDER](payload).then(() => {
          this.draggingId = null
        })
      }
    },
    async upload(task) {
      if (this.currentTask) return false;

      let taskId = task.id
      let payload = {
        fromDate: task.date,
        oldIndex: task.order,
        newIndex: 0,
        fromCompleted: false,
        toCompleted: false,
        taskId,
        isCurrent: true
      }
      await this[START_TASK]({ taskId })
      this[UPDATE_TASK_ORDER](payload)
    },
  },
  watch: {
    computedTasks: {
      immediate: true,
      handler(tasks) {
        this.taskList = tasks
      }
    }
  }
}
</script>

<style scoped lang="scss">
</style>
