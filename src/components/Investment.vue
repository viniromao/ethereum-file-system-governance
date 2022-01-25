<template>
  <div id="investment-page">
      Quantia para investir em Wei: <input v-model="this.investmentValue" />
      <button @clock="invest(this.investmentValue)">Investir</button>
  </div>
</template>

<script>
export default {
    name: 'Investment',
    props: {
        msg: String
    },
    data () {
        return {
            investmentValue: 0
        }
    },
    methods: {
        async invest(amount) {
             await contractInstance.methods.getBalance().call();
        }
    }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
#investment-page{
    background-color: burlywood;
}
</style>
