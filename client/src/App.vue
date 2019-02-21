<!--<template>
  <div id="app">
    <div id="nav">
      <router-link to="/">Home</router-link>
      <router-link :to="{ name: 'configuration'}">Configuration</router-link>
      <router-link :to="{ name: 'water_station_configuration', params: { id: 1 }}">Station 1 Conf</router-link>
      <router-link :to="{ name: 'water_station_configuration', params: { id: 2 }}">Station 2 Conf</router-link>
    </div>
    <router-view/>
  </div>
</template>-->

<template>
  <v-app id="app">
    <v-toolbar app color="light-green lighten-1">
      <v-toolbar-side-icon><v-icon color="white">fa-leaf</v-icon></v-toolbar-side-icon>

      <v-toolbar-title class="white--text">IoT Garden</v-toolbar-title>

      <v-spacer></v-spacer>

      <environment-station></environment-station>
    </v-toolbar>

    <v-content>
      <v-container>
        <router-view></router-view>
      </v-container>
    </v-content>

    <v-footer app></v-footer>
  </v-app>
</template>


<script>

// @ is an alias to /src
import EnvironmentStation from '@/components/EnvironmentStation.vue'

export default {
  components: {
    EnvironmentStation
  }
}
</script>