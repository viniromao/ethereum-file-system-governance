<template>

  <div id="app">
    <!-- <div id="body"> -->
    <div id="header">
      <span id="header-element">Seja bem-vindo ao painel de controle de governança!</span> 
      <span id="header-element">Balanço do contrato em Wei: {{ balance }}</span>
        <!-- <span id="error">{{ errorMessage }}</span> -->
      <span id="header-element">Conta conectada: {{ account }}</span>
    </div>

    <div id="side-menu">
      <button v-show="!isContributor" @click="contribute">Contribua</button>
      <div v-show="isContributor">Você é um contibridor dessa organização!</div>
    </div>

    <div id="projects-menu">
      <Project :contractInstance="contractInstance" />
    </div>
   
    <div id="projects-menu">
      <Investment :contractInstance="contractInstance" :balance="balance" />
    </div>
       
    <div id="projects-menu">
      <Election :contractInstance="contractInstance" />
    </div>

       
    
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
      isContributor: false,
      leader: null
    }
  },
  methods: {
    async contribute() {
        console.log("calling transaction contribute()")

         this.contractInstance.methods.payContribution().send({ 
          value: "100000",
          from: this.account
        })    
        .then(msg => {
          document.location.reload(true);
          console.log("successfull transaction: " + msg)
        })
        .catch(err => console.log(err))
    },
    async getContributors() {
      this.contractInstance.methods.getBalance().call().then(console.log)
    },
    async closeMonth() {
      await this.contractInstance.methods.closeMonth().send({
        from: this.account,
        value: "10000"
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
}

#app {
  font-weight: bold;
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  display: flex;
  flex-direction: row;
  justify-content: flex-start;
 
  min-height: 100vh;
  flex-wrap: wrap;
}

#header {
  height: 50px;
  width: 100%;
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: space-between;
  font-size: 15px;
  border-bottom: 2px solid black;
}

#body{
  display: flex;
  flex-direction: line;
  justify-content: flex-start;
  flex-wrap: wrap;
}

#side-menu {
  width: 200px;
  height: 100vh;
  display: flex;
  flex-direction: column;
}

#projects-menu {
  width: 500px;
  height: 100vh;
  display: flex;
  flex-direction: column;
  padding: 10px;
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
  background-color: rgb(243, 243, 243);
  border: 2px rgb(0, 0, 0) solid;
  padding: 15px 60px;
  margin: 5px;
  border-radius: 2px;
}

button:hover{
  background-color: rgb(185, 185, 185);
}

button:active {
    transform: translate(1px, -1px);
}

input {
  border-radius: 3px;
  border: none;
  padding: 5px;
  outline: none;
  margin: 5px;
  font-weight: bolder;
}

textarea {
  border-radius: 3px;
  border: none;
  padding: 5px;
  outline: none;
  margin: 5px;
  font-weight: bolder;
  width: 400px;
  height: 100px;
}

#component {
  margin: 20px;
}

#project-page {
    font-weight: bolder;
    color: white;
    display:flex;
    flex-direction: column;
    align-items: center;
    padding: 30px;
    background-color: rgb(0, 0, 0);
    border-radius: 3px;
    margin-bottom: 10px;
}

#card{
    font-weight: bolder;
    color: white;
    display:flex;
    flex-direction: column;
    align-items: center;
    background-color: rgb(46, 46, 46);
    border-radius: 10px;
    max-width: 400px;
    padding: 20px;
    margin-bottom: 10px;
}

</style>
