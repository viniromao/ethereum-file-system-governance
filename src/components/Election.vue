<template>
    <div id="project-page">
        <h1>Eleições</h1>
      
        <button @click="callElection()">Iniciar Eleição</button>
        <button @click="candidate()">Canditatar-se</button>
        <div id="card">
            <input v-model="address">
            <button @click="vote()">Votar</button>
        </div>
        <button @click="endElection()">Computar Eleição</button>
    </div>
</template>

<script>
import web3 from "../ethereum/web3.js"

export default {
    name: 'Election',
    props: ['contractInstance'],
    async created() {
        this.leader = await this.contractInstance.methods.leader().call();

        const accounts = await web3.eth.getAccounts();
        this.account = await accounts[0];

    },
    data () {
        return {
            leader: null,
            account: null,
            address: null,
            value: null,
            errorMessage: ""
        }
    },
    methods: {
        async callElection() {
           await this.contractInstance.methods.holdElection.call({
                from: this.account
            });
           console.log("Election called")
        },
        async candidate() {
            await this.contractInstance.methods.candidate.call({
                from: this.account
            });
            console.log("Candidate called")
        },
        async vote() {
            console.log("Voto para:" + this.address)
            await this.contractInstance.methods.vote(this.address).send({
                from: this.account,
                value: "1000"
            });
            console.log("Vote called")
        },
        async endElection() {
            await this.contractInstance.methods.endElection.call({
                from: this.account
            });
            console.log("Election ended")
        },
    },
    computed: {
        isLeader: function () {
            return  this.leader == this.account;
        }
    } 
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
#project-page{
    font-weight: bolder;
    color: white;
    display:flex;
    flex-direction: column;
    align-items: center;
    padding: 30px;
    background-color: rgb(4, 19, 59);
    border-radius: 10px;
    max-width: 400px;
    margin: 20px 0
}

#card{
    font-weight: bolder;
    color: white;
    display:flex;
    flex-direction: column;
    align-items: center;
    background-color: rgb(170, 170, 170);
    border-radius: 10px;
    max-width: 400px;
    padding: 20px;
}
</style>
