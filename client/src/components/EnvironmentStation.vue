<template>
  <div>
    <v-icon color="white">fa-thermometer-half</v-icon>
    <span class="white--text">{{environment.temperature}}º</span>

    <v-icon color="white">fa-tint</v-icon>
    <span class="white--text">{{environment.humidity}}%</span>

    <v-btn icon dark :to="{ name: 'configuration'}">
      <v-icon>fa-cog</v-icon>
    </v-btn>
  </div>
</template>

<script>

import axios from 'axios'

export default {
  name: 'environment-station',
  data: function() {
    return {
      environment: {},
      polling: null
    }
  },
  methods: {
    pollData() {
      axios
        .get('http://localhost:4567/api/environment-station')
        .then(response => (this.environment = response.data))
    },

    setTimer() {
      this.polling = setInterval(this.pollData, 10000)
    }
  },
  mounted() {
    this.pollData()
    this.setTimer()
  },

  beforeDestroy() {
    clearInterval(this.polling)
  }
}
</script>
