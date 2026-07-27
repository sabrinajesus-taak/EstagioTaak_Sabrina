import searchFaq from '@salesforce/apex/FaqController.searchFaq';
import { LightningElement } from 'lwc';
export default class Faq extends LightningElement {
        termo;
        faqs;
        currentPage = 1;
        currentPage2 = this.currentPage + 1;
        pageSize = 4;
        totalPages = 0;
        paginatedQuestions = [];
        introducao = true;
        pesquisa = false;
        mensagemNaoEncontrada = false;

        handleKeyDown(event) {
                if (event.key === 'Enter') {
                this.getQuestions(event);
                }
        }

        async getQuestions (event) {
        console.log("getQuestion");
        this.termo = event.target.value;
        this.faqs = await searchFaq({ termo: this.termo });
        this.totalPages = Math.ceil(this.faqs.length / this.pageSize);
        this.updatePaginated();
        console.log(this.termo);

        if(this.faqs.length === 0) {

                await new Promise(resolve => setTimeout(resolve, 1000));
                this.introducao = false;
                this.pesquisa = false;
                this.mensagemNaoEncontrada = true;

        } else{

                await new Promise(resolve => setTimeout(resolve, 1000));
                this.introducao = false;
                this.pesquisa = true;
                this.mensagemNaoEncontrada = false;
        } 

        }

        async handleVerMais(){
                await new Promise(resolve => setTimeout(resolve, 1000));
                this.introducao = false;
                this.pesquisa = true;
                this.mensagemNaoEncontrada = false;
        }

        updatePaginated() {
                const start = (this.currentPage - 1) * this.pageSize;
                const end = start + this.pageSize;
                this.paginatedQuestions = this.faqs.slice(start, end);
        }

        async handlePrevious() {
                if (this.currentPage > 1) {
                        this.currentPage--; 
                        this.currentPage2--;
                        await new Promise(resolve => setTimeout(resolve, 1000));
                        this.updatePaginated();
                }
        }

        async handleNext() {
                if (this.currentPage < this.totalPages) {
                        this.currentPage++;
                        this.currentPage2++;
                        await new Promise(resolve => setTimeout(resolve, 1000));
                        this.updatePaginated();
                }
        }


        // async connectedCallback() {
        //         let result = await searchFaq({termo : 'a'});

        //         console.log('result ==> ' + JSON.stringify(result));
        // }

        

}