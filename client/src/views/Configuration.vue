 
<template>
  <div class="configuration">
    <form>
      <v-text-field
        v-model.number="normalHumidity"
        label="Normal Humidity"
        required
      ></v-text-field>

      <v-text-field
        v-model.number="highTemperature"
        label="High Temperature"
        required
      ></v-text-field>

      <v-text-field
        v-model.number="maxTemperature"
        label="Very High Temperature"
        required
      ></v-text-field>


      <v-btn @click="submit">Save</v-btn>
      <v-btn @click="cancel">Cancel</v-btn>
    </form>
  </div>
</template>

<script>

// @ is an alias to /src
import axios        from 'axios'

export default {
  name: 'configuration',
  data: function() {
    return {
      normalHumidity: 0,
      highTemperature: 0,
      maxTemperature: 0
    }
  },

  mounted() {
    axios
      .get('http://localhost:4567/api/environment-station')
      .then((response) => {
        this.normalHumidity  = response.data["normal_humidity"]
        this.highTemperature = response.data["high_temperature"]
        this.maxTemperature  = response.data["max_temperature"]
      })
  }, 

  methods: {
    cancel(){
      this.$router.push('/')
    },
    submit(){
      axios.post('http://localhost:4567/api/environment-station', {
        normal_humidity:  this.normalHumidity,
        high_temperature: this.highTemperature,
        max_temperature:  this.maxTemperature
      })
      .then(response => this.$router.push('/'))
    }
  }
}
</script>
