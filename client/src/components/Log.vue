<template>
  <v-container fluid grid-list-md>
    <v-card>
      <v-card-text>
        <h1>Eventos</h1>
        <v-timeline align-top dense>

          <v-timeline-item small icon="fa-leaf" color="pink" v-for="logEntry in log">
            <v-layout pt-3>
              <v-flex xs3>
                {{logEntry.created_at}}
              </v-flex>
              <v-flex xs4>
                <strong>{{logEntry.message}}</strong>
              </v-flex>
            </v-layout>
          </v-timeline-item>

        </v-timeline>
      </v-card-text>
    </v-card>
  </v-container>
</template>

<script>

export default {
  name: 'log',
  props: ['log']
}

</script> 
