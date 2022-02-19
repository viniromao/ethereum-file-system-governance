<template>
  <div id="app">
    <!-- <div id="header">Interface Gráfica Contrato Inteligente</div> -->
    <!-- <div id="body"> -->
      <div id="side-menu">
        <button @click="contribute">
          Contribua
        </button>
        <button v-if="isLeader" @click="closeMonth">
          Fechar Mês
        </button>
        {{isContributor}}
      </div>
      <!-- <div id="main-page">  -->
        <div>
           <Investment :contractInstance="contractInstance" :balance="balance" />
        </div>
        <div>
          <Project :contractInstance="contractInstance" />
        </div>
        <div>
          <Election :contractInstance="contractInstance" />
        </div>

       
        <!-- <span>Seja bem-vindo ao painel de controle de governança!</span>
        <span>Balanço do contrato em Wei: {{ balance }}</span>
        <span id="error">{{ errorMessage }}</span>
        <span>Account connected: {{ account }}</span> -->
     <!-- </div> -->
    <!-- </div> -->
  </div>
</template>

<script>
import Investment from './components/Investment.vue';
import Project from './components/Project.vue';
import Election from './components/Election.vue';
import contractObject from "./ethereum/contractObject.json"
import web3 from "./ethereum/web3.js"

export default {
  name: 'App',
  async beforeCreate() {

    const accounts = await web3.eth.getAccounts();
    this.account = await accounts[0];

    this.leader = await this.contractInstance.methods.leader().call();

    this.balance = await this.contractInstance.methods.getBalance().call();

    this.getIsContributor();
  },
  components: {
    Investment,
    Project,
    Election
  },
  data () {
    return {
      account: "Carregando...",
      balance: "Carregando...",
      errorMessage: "",
      contractInstance: new web3.eth.Contract(
        contractObject.interface,
        contractObject.address
      ),
      isContributor: "Carregando...",
      leader: null
    }
  },
  methods: {
    async contribute() {
      try {
        const leader = await this.contractInstance.methods.payContribution().send({ 
          value: "1000",
          from: this.account
        });
        console.log(leader);
      } catch (err) {
        this.errorMessage = "Ocorreu um erro na transação com a seguinte mensagem: " + err.message;
        console.log(err);
      }
    },
    async getContributors() {
      this.contractInstance.methods.getBalance().call().then(console.log)
    },
    async closeMonth() {
      await this.contractInstance.methods.closeMonth().send({
        from: this.account,
        value: "1000"
      })
      console.log("closemonth called")
    },
    async getIsContributor() {
      console.log("is contributor called")
      this.isContributor = await this.contractInstance.methods.isContributor().call({
        from: this.account
      })
      console.log(this.isContributor)
    }
  },
  computed: {
    isLeader: function () {
        return  this.leader == this.account;
    }
  }
}
</script>

<style>
body {
  margin: 0;
  background-image: linear-gradient(to bottom right, rgb(36, 13, 165), rgb(255, 0, 221));
}

#app {
  font-weight: bold;
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  max-height: 100vh;
  min-height: 100vh;
  flex-wrap: wrap;
  padding:30px;
}

#header {
  height: 100px;
  width: 100%;
  display: flex;
  flex-direction: line;
  align-items: center;
  justify-content: center;
  font-size: 25px;
  font-weight: bolder;
  border-bottom: 2px solid black;
  margin-bottom: 30px;
}

#body{
  display: flex;
  flex-direction: line;
  justify-content: flex-start;
  flex-wrap: wrap;
}

#side-menu {
  width: 200px;
  padding: 0 30px 0 10px;
  display: flex;
  flex-direction: column;
}

#main-page {
  display: flex;
  flex-direction: column;
  flex-wrap: wrap;
}

#error{
  color:brown;  
}

button {
  cursor: pointer;
  font-weight: bold;
  font-size: 15px;
  background-color: rgb(212, 238, 245);
  border: 2px rgb(255, 255, 255) solid;
  padding: 15px 60px;
  margin: 5px;
  border-radius: 10px;
}

button:hover{
  background-color: rgb(185, 185, 185);
}

button:active {
    transform: translate(1px, -1px);
}

input {
  border-radius: 10px;
  border: none;
  padding: 5px;
  outline: none;
  margin: 5px;
  font-weight: bolder;
}

textarea {
  border-radius: 10px;
  border: none;
  padding: 5px;
  outline: none;
  margin: 5px;
  font-weight: bolder;
}

#component {
  margin: 20px;
}


</style>
