<template>
    <div id="project-page">
        <h2>Criar Projeto</h2>
        <div id="card">
            <h3>Criar novo projeto</h3>
            <textarea v-model="description" type="text-box" placeholder="Descrição" />
            <input v-model="address" type="text" placeholder="Endereço do Beneficiado (Ethereum)">
            <input v-model="value" type="text" placeholder="Valor em Wei">
            <button @click="createProject()">Criar</button>
            <div id="error">{{errorMessage}}</div>
        </div>
    </div>
    <div v-if="fetchData != false && projects.length > 0" id="project-page">
        <div v-for="(project, index) in projects" :key="index" id="card">
            <span> {{project.description}}</span>
            <p>Beneficiado: </p>
            <span id="beneficiado">{{project.targetReciever}}</span>
            <p>Valor em Wei: {{project.value}}</p>
            <p>Votos:</p>
            <span>
                <span class="green">{{project.approvalCount}}</span> X <span class="red">{{project.denialCount}}</span>
            </span>
            <span>
                <button @click="approveProject(index)">Aprovar</button>
                <button @click="denialProject(index)">Reprovar</button>
            </span>
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
        this.approvers = await this.contractInstance.methods.projects(0).call();
        console.log(this.contractInstance)

        console.log(this.approvers)
        const accounts = await web3.eth.getAccounts();
        this.account = await accounts[0];

        await this.getProjects().then(console.log(this.projects));
    },
    data () {
        return {
            leader: null,
            approvers: null,
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
         async createProject() {
            console.log("Instância para criar o projeto")
            await this.contractInstance.methods.createProject(this.value, this.address, this.description).send({
                from: this.account})
            .then(()=> {
                document.location.reload(true);
                console.log("criado com sucesso")})
            .catch((err)=> console.log(err))
        },
        async approveProject(index) {
            console.log(index)
            console.log(this.projects[index])
            await this.contractInstance.methods.approveProject(index).send({
                from: this.account
            }).then((res) => console.log(res)).catch((err)=>console.log(err));
        },
          async denialProject(index) {
            console.log(index)
            console.log(this.projects[index])
            await this.contractInstance.methods.denialProject(index).send({
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

#beneficiado {
    font-size: small;
    background-color: black;
}

.green{
    color: greenyellow;
}

.red {
    color: red;
}
</style>
