<template>
  <v-container fluid grid-list-md>
    <v-card>
      <v-card-text>
        <h1>Eventos</h1>
        <v-timeline align-top dense>

          <v-timeline-item small icon="fa-leaf" color="pink" v-for="logEntry in log">
            <log-entry :logEntry="logEntry"></log-entry>
          </v-timeline-item>

        </v-timeline>
      </v-card-text>
    </v-card>
  </v-container>
</template>

<script>

import LogEntry from '@/components/LogEntry'

export default {
  name: 'log',
  props: ['log'],
  components: {
    LogEntry
  }
}

</script> 
