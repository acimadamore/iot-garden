import Vue from 'vue'
import Router from 'vue-router'

import Home                      from './views/Home.vue'
import Configuration             from './views/Configuration.vue'
import WaterStationConfiguration from './views/WaterStationConfiguration.vue'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'home',
      component: Home
    },
    {
      path: '/configuration',
      name: 'configuration',
      component: Configuration
    },
    {
      path: '/stations/:id/configuration',
      name: 'water_station_configuration',
      component: WaterStationConfiguration,
      props: true
      // route level code-splitting
      // this generates a separate chunk (about.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      //component: () => import(/* webpackChunkName: "about" */ './views/About.vue')
    },
  ]
})
