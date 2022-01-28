<template>
  <div v-if="isLeader" id="project-page">
      <h1>Painel do Líder</h1>
      <div id="card">
            <h3>Criar novo projeto</h3>
            <textarea v-model="description" type="text-box" placeholder="Descrição" />
            <input v-model="address" type="text" placeholder="Endereço do Beneficiado (Ethereum)">
            <input v-model="value" type="text" placeholder="Valor em Wei">
            <button @click="createProject()">Criar</button>
            <div id="error">{{errorMessage}}</div>
      </div>
      <div id="card">
            <h3>Criar novo projeto</h3>
            <textarea v-model="description" type="text-box" placeholder="Descrição" />
            <input v-model="address" type="text" placeholder="Endereço do Beneficiado (Ethereum)">
            <input v-model="value" type="text" placeholder="Valor em Wei">
            <button @click="createProject()">Criar</button>
            <div id="error">{{errorMessage}}</div>
      </div>
     Líder: {{leader}} is Líder 
  </div>
</template>

<script>
import web3 from "../ethereum/web3.js"

export default {
    name: 'Investment',
    props: ['contractInstance'],
    async mounted() {
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
            description: null,
            errorMessage: ""
        }
    },
    methods: {
        async createProject() {
            console.log("Instância para criar o projeto")
            await this.contractInstance.methods.createProject(this.value, this.address, this.description).send({
                from: this.account
            }).then(()=> console.log("criado com sucesso")).catch((err)=> console.log(err))
        }
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
    width: 80%;
    color: white;
    display:flex;
    flex-direction: column;
    align-items: center;
    background-color: rgb(170, 170, 170);
    border-radius: 10px;
    max-width: 400px;
    margin: 20px 0
}
</style>
