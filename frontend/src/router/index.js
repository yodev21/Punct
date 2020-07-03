import Vue from 'vue'
import VueRouter from 'vue-router'
import Home from '../views/Home.vue'
import Store from '@/store/index.js'
import { SET_NAME } from '@/store/mutation-types'

Vue.use(VueRouter)

  const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/archives',
    name: 'Archives',
    component: () => import('../views/Archives.vue')
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue'),
    meta: {
      isPublic: true
    }
  }
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

router.beforeEach((to, from, next) => {
  if (!from.name) {
    Store.dispatch(`auth/${SET_NAME}`).then(() => {
      next()
    })
  } else {
    next()
  }
})

router.beforeResolve((to, from, next) => {
  let userName = Store.state.auth.userName
  if (to.name === 'Login' && userName) {
    next('/') // ログイン済み
  } else if (to.meta.isPublic || userName) {
    next()
  } else {
    next('/login')
  }
})

export default router
