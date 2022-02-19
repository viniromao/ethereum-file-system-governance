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
        Líder: {{leader}} is Líder 
    </div>
    <div v-if="fetchData != false && projects.length > 0" id="project-page">
        <div v-for="(project, index) in projects" :key="index" id="card">
            <p>Descrição do projeto: {{project.description}}</p>
            <p>Beneficiado: {{project.targetReciever}}</p>
            <p>Valor em Wei: {{project.value}}</p>
            <button @click="approveProject(index)">Aprovar</button>
            <button v-if="isLeader" @click="finalizeProject(index)">Finalizar</button>
        </div>
    </div>
</template>

<script>
import web3 from "../ethereum/web3.js"

export default {
    name: 'Investment',
    props: ['contractInstance'],
    async created() {
        this.leader = await this.contractInstance.methods.leader().call();

        const accounts = await web3.eth.getAccounts();
        this.account = await accounts[0];

        await this.getProjects().then(console.log(this.projects));
    },
    data () {
        return {
            leader: null,
            account: null,
            address: null,
            value: null,
            description: null,
            errorMessage: "",
            projects: [],
            fetchData: false
        }
    },
    methods: {
        async createProject() {
            console.log("Instância para criar o projeto")
            await this.contractInstance.methods.createProject(this.value, this.address, this.description).send({
                from: this.account
            }).then(()=> console.log("criado com sucesso")).catch((err)=> console.log(err))
        },
        async getProjects() {
            let project;

            for (let index = 0; ; index++) {
                project = await this.contractInstance.methods.projects(index).call();

                if (project) {
                    if (project.targetReciever) {
                        if (project.targetReciever != "0x0000000000000000000000000000000000000000") {
                            console.log(project);
                        } else {
                            break;
                        }
                    }
                }
                this.projects.push(project);
            }         
            this.fetchData = true;
        },
        async approveProject(index) {

            console.log(this.projects[index])
            await this.contractInstance.methods.approveProject(index).send({
                value: "1000",
                from: this.account
            }).then((res) => console.log(res)).catch((err)=>console.log(err));
        },
        async finalizeProject(index) {

            console.log(this.projects[index])
            await this.contractInstance.methods.finalizeProject(index).send({
                value: "1000",
                from: this.account
            }).then((res) => console.log(res)).catch((err)=>console.log(err));
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
    margin: 20px 0;
    padding: 20px;
}
</style>
