<template>
  <div id="investment-page">
      <div id="is-investor" v-if="!isInvestor">
        <h1>Investir</h1>
        <p style="margin-bottom: 30px">
            Nesta seção você pode investir no contrato para aumentar sua liquidez, além 
            de contribuir com este projeto você pode obter rendimentos de acordo com o 
            aumento do montante total que no momento está em {{balance}} Wei.
        </p>
        <div style="margin-bottom: 40px" id="input-group">
            Quantia para investir em Wei: <input v-model="investmentValue" />
        </div>
        <button @click="invest(investmentValue)">Investir</button>
      </div>
      <div id="is-not-investor" v-else>
        <p>Você já apoia este projeto, será que é o momento para realizar o faturamento do investimento?</p>
        <p>Faturamento: {{potentialProfit}} Wei</p>
        <button @click="getProfit()">Recolher Investimento</button>
      </div>
  </div>
</template>

<script>
import axios from 'axios';
import web3 from "../ethereum/web3.js"

const DEFAULT_ADDRESS = "0x0000000000000000000000000000000000000000";

export default {
    name: 'Investment',
    props: ['contractInstance', 'balance'],
    async mounted() {

        const accounts = await web3.eth.getAccounts();
        this.account = await accounts[0];

        this.backerInfo = await this.contractInstance.methods.getBackerInfo().call({
            from: this.account
        })
    },
    data () {
        return {
            backerInfo: {},
            investmentValue: null,
            potentialProfit: 0
        }
    },
    methods: {
        async invest(amount) {
            if (amount == null || amount < 0) {
                return;
            }

            console.log("Pedido de investimento feito");
            await this.contractInstance.methods.invest(amount).send({ 
                value: Number(amount) + 200,
                from: this.account
            })

            console.log("Pedido concluído");

            this.backerInfo = await this.contractInstance.methods.getBackerInfo().call({
                    from: this.account
            })

            this.getPotentialProfit()
        },
        async getProfit() {
            const balance = await this.contractInstance.methods.getBalance().call(); 

            const response = await axios.post('http://localhost:9000/governance/investment-profit', {
                "current_balance": balance,
                "balance_at_investment_date":this.backerInfo.balance,
                "amount_invested": this.backerInfo.amountInvested
            })

            console.log("Retornando " + Number(response.data.total_profit) + " em rendimentos")
            this.contractInstance.methods.endInvestment(response.data.total_profit).send({
                from: this.account,
                gas: "50000"
            }).then(() => {
                console.log("Faturamento realizado")
            })
        },
        async getPotentialProfit() {
            const balance = await this.contractInstance.methods.getBalance().call(); 

            const response = await axios.post('http://localhost:9000/governance/investment-profit', {
                "current_balance": balance,
                "balance_at_investment_date":this.backerInfo.balance,
                "amount_invested": this.backerInfo.amountInvested
            })

            this.potentialProfit = response.data.total_profit;
        }
    },
    computed: {
        isInvestor: function () {
            return this.backerInfo[2] != DEFAULT_ADDRESS;  
        },
    } 
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
#investment-page{
    font-weight: bolder;
    color: white;
    display:flex;
    flex-direction: column;
    align-items: center;
    padding: 30px;
    background-color: rgb(4, 19, 59);
    border-radius: 10px;
    max-width: 400px;
}

#input-group {
    display: flex;
    flex-direction: line;
    justify-content: space-evenly;
    align-items: center;
}

#is-investor {
    display:flex;
    flex-direction: column;
    align-items: center;
}

#is-not-investor {
    display:flex;
    flex-direction: column;
    align-items: center;
}
</style>
