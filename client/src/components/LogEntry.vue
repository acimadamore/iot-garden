 <template>
    <v-layout pt-3>
      <v-flex xs2>
        {{formattedCreatedAt}}
      </v-flex>
      <v-flex xs3>
        <strong>{{logEntry.message}}</strong>
      </v-flex>
    </v-layout>
 </template>
 
<script>

import moment from 'moment'

 export default {
   name: 'log-entry', 
   props: ['logEntry'],
   computed: {
      formattedCreatedAt(){
        return moment.utc(this.logEntry.created_at, 'YYYY-MM-DD HH:mm:ss').format('DD/MM/YYYY HH:mm:ss')
      }
   }
 }
</script>
 