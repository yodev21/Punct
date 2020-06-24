import router from '@/router/index.js'

import {
  CREATE,
  DESTROY,
  POST,
  DELETE
} from '../mutation-types'

export default {
  namespaced: true,
  state: {
    // tenant: '',
    // userId: '',
    // token: ''
    // isLoggedIn: false
  },
  mutations: {
    // [CREATE](state) {
      // state.tenant = ''
      // state.token = data.token
      // state.userId = data.user_id
      // state.isLoggedIn = true
    // },
    // [DESTROY](state) {
      // state.tenant = ''
      // state.userId = ''
      // state.token = ''
      // state.isLoggedIn = false
    // }
  },
  actions: {
    [CREATE]({ dispatch }, data) {
      dispatch(
        'http/' + POST,
        { url: 'auth', data },
        { root: true }
      ).then( () => { router.push('/') })
       .catch(err => err)
    },
    [DESTROY]({ commit, dispatch }, data) {
      dispatch(
        'http/' + DELETE,
        { url: 'auth', data },
        { root: true }
      ).then(res => commit(CREATE, res.data))
       .catch(err => err)
        // logout anyway ...
      //  .finally(res => commit(DESTROY))
    }
  }
}
