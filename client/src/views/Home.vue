<template>
  <div class="home">
    <v-container fluid grid-list-md>
      <v-layout row wrap>
        <water-station v-for="station in stations" :key="station.uid" :station="station"></water-station>
      </v-layout>

    </v-container>

    <v-btn absolute dark fab right color="red darken-1" @click="power">
      <v-icon style="height:auto;">fa-power-off</v-icon>
    </v-btn>
    
    <log :log="log"></log>


  </div>
</template>

<script>

// @ is an alias to /src
import WaterStation from '@/components/WaterStation.vue'
import Log          from '@/components/Log.vue'

import axios        from 'axios'


export default {
  name: 'home',
  data: function() {
    return {
      isTurnedOn: false,
      polling: null,
      stations: [],
      log: []
    }
  },
  components: {
    WaterStation,
    Log
  },

  mounted() {
    this.pollData()
    this.setTimer()
  },

  methods: {
    pollData() {
      axios
        .get('http://localhost:4567/api/water-stations')
        .then(response => (this.stations = response.data))

      axios
        .get('http://localhost:4567/api/system/log')
        .then(response => (this.log = response.data))
    },

    setTimer() {
      this.polling = setInterval(this.pollData, 10000)
    },

    power(){
      if(this.isTurnedOn){
        axios
          .post('http://localhost:4567/api/system/turn-off')
          .then(response => (this.isTurnedOn = false))
      }
      else{
        axios
          .post('http://localhost:4567/api/system/turn-on')
          .then(response => (this.isTurnedOn = true))
      }
    }
  },

  beforeDestroy() {
    clearInterval(this.polling)
  }
}
</script>
