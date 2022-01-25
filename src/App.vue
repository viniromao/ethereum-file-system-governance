<template>
  <div id="app">
    <div id="header">Interface Gráfica Contrato Inteligente</div>
    <div id="body">
      <div id="side-menu">
        <button @click="contribute">
          Contribua
        </button>
        <button>
          Eleições
        </button>
        <button>
          Investir
        </button>
        <button>
          Criar Projeto
        </button>
        <button>
          Fechar Mês
        </button>
        <button>
          Fechar Mês
        </button>
      </div>
      <div id="main-page">
        <span>Seja bem-vindo ao painel de controle de governança!</span>
        <span>Síndico atual: {{ leader }}</span>
        <span>Balanço do contrato em Wei: {{ balance }}</span>
        <span id="error">{{ errorMessage }}</span>
      </div>
    </div>
  </div>
</template>

<script>
import contractObject from "./ethereum/contractObject.json"
import web3 from "./ethereum/web3.js"

const contractInstance = new web3.eth.Contract(
    contractObject.interface,
    contractObject.address
  );

export default {
  name: 'App',
  async beforeMount() {
    this.accounts = await web3.eth.getAccounts();
    this.balance = await contractInstance.methods.getBalance().call();
  },
  components: {
    // HelloWorld
  },
  data () {
    return {
      accounts: "Carregando...",
      balance: "Carregando...",
      errorMessage: ""
    }
  },
  methods: {
    async contribute() {
      
      // this.message = "COMPUTANDO"
      // this.message = await contractInstance.methods.getBalance().call();
      try {
      const leader = await contractInstance.methods.payContribution().send({ 
        value: "1000",
        from: this.accounts[0]}
      );
      console.log(leader)
        } catch (err) {
          this.errorMessage = "Ocorreu um erro na transação com a seguinte mensagem: " + err.message;
          console.log(err);
          }

    },
    async getContributors() {
      contractInstance.methods.getBalance().call().then(console.log)
    }
  }
}
</script>

<style>
body {
  margin: 0;
}

#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  display: flex;
  flex-direction: column;
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
}

#side-menu {
  padding: 0 30px 0 10px;
  display: flex;
  flex-direction: column;
}

#main-page {
  display: flex;
  flex-direction: column;
}

#error{
  color:brown;  
}

button {
  cursor: pointer;
  background-color: rgb(192, 192, 192);
  border: 2px black solid;
  padding: 15px;
  margin: 5px;
}


</style>
