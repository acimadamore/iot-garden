<template>
  <v-flex xs6 md6>
        <v-card
      class="mx-auto"
      color="light-green lighten-1"
      dark
    >
      <v-card-title>
        <v-icon
          large
          left
        >
          fa-seedling
        </v-icon>
        <span class="title font-weight-light">{{station.name}}</span>
      </v-card-title>

      <v-card-text class="headline font-weight-bold">
        <v-container>
          <v-layout row wrap align-center>
            <v-flex xs6>
              <v-progress-circular color="white" size="150" :value="station.soil_humidity">
                {{station.soil_humidity}}%
              </v-progress-circular>
            </v-flex>
          </v-layout>
        </v-container>
      </v-card-text>

      <v-card-actions>
        <v-btn icon @click="water">
          <v-icon color="white">fa-cloud-showers-heavy</v-icon>
        </v-btn>

        <v-btn icon :to="{ name: 'water_station_configuration', params: { id: station.uid }}">
          <v-icon color="white">fa-cog</v-icon>
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-flex>
</template>

<script>

import axios from 'axios'

export default {
  name: 'water-station',
  props: ['station'],
  methods: {
    water() {
      axios.get(`http://localhost:8080/api/water-stations/${this.station.uid}/water`)

      alert(`${this.station.name} watered!`)
    }
  }
}

</script>