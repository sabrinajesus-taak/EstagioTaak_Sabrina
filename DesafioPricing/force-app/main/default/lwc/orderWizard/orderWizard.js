import { LightningElement, track } from 'lwc';
import getClients from '@salesforce/apex/OrderDataService.getClients';
import getAddresses from '@salesforce/apex/OrderDataService.getAddresses';
import getPaymentConditions from '@salesforce/apex/OrderDataService.getPaymentConditions';
import getPricebooks from '@salesforce/apex/OrderDataService.getPricebooks';
import getDistributionCenters from '@salesforce/apex/OrderDataService.getDistributionCenters';
import createOrder from '@salesforce/apex/OrderDataService.createOrder';
import getAllProducts from '@salesforce/apex/OrderDataService.getAllProducts';
import getOrderItemsPricing from '@salesforce/apex/OrderDataService.getOrderItemsPricing';


export default class OrderWizard extends LightningElement {
    
    @track step = 1; 

    @track createdOrderId = null;
    
    @track formData = {
        clientId: null,
        addressId: null,
        distributionCenterId: null,
        paymentConditionId: null,
        pricebookId: null,
        freightType: null,
        observations: null,
        deliveryDate: null,
        startDate: null
    };

    @track pricingInformation = [];
    
    clientOptions = [];
    addressOptions = [];
    distributionsCentersOptions = [];
    paymentConditionOptions = [];
    pricebooksOptions = [];
    freightTypeOptions = [
        { label: 'CIF', value: 'CIF' },
        { label: 'FOB', value: 'FOB' }
    ];

// ========== ETAPA 2: CARRINHO E PRODUTOS ==========
    
    @track searchTerm = '';           
    @track allProducts = [];          
    @track orderItems = [];           
    @track showCart = false;          
    
    get filteredProducts() {
        if (!this.searchTerm || this.searchTerm.trim() === '') {
            return this.allProducts;
        }
        
        const searchLower = this.searchTerm.toLowerCase().trim();
        return this.allProducts.filter(product => 
            product.name.toLowerCase().includes(searchLower) ||
            (product.code && product.code.toLowerCase().includes(searchLower))
        );
    }
    
    get cartItemCount() {
        return this.orderItems.length;
    }
    
    get totalOrderValue() {
        return this.orderItems.reduce((sum, item) => {
            return sum + (item.quantity * item.unitPrice);
        }, 0);
    }

    // getters
    get isStep1() {
        return this.step === 1;
    }
    
    get isStep2() {
        return this.step === 2;
    }
    
    get isStep3() {
        return this.step === 3;
    }

    get isStep4() {
        return this.step === 4;
    }

    get isClientDisabled() {
        return !this.formData.clientId;
    }


    connectedCallback() {
        this.loadInitialData();
    }
    
    // Agrupa os carregamentos iniciais
    async loadInitialData() {
        try {
            await Promise.all([
                this.loadClients(),
                this.loadPaymentConditions(),
                this.loadPricebooks(),
                this.loadDistributionCenters()
            ]);
        } catch (error) {
            console.error('Erro ao carregar dados iniciais:', error);
        }
    }
    
    // BUSCA DE DADOS 
    async loadClients() {
        try {
            this.clientOptions = await getClients();
            console.log('Clientes carregados:', this.clientOptions);
        } catch (error) {
            console.error('Erro ao carregar clientes:', error);
        }
    }
    
    async loadAddresses(clientId) {
        try {
            this.addressOptions = await getAddresses({ accountId: clientId });
            console.log('Endereços carregados:', this.addressOptions);
        } catch (error) {
            console.error('Erro ao carregar endereços:', error);
        }
    }

    async loadDistributionCenters() {
        try {
            this.distributionsCentersOptions = await getDistributionCenters();
            console.log('Centros de Distribuição carregados:', this.distributionsCentersOptions);
        } catch (error) {
            console.error('Erro ao carregar os Centros de Distribuição:', error);
        }
    }

    async loadPaymentConditions() {
        try {
            this.paymentConditionOptions = await getPaymentConditions();
            console.log('Condições de Pagamento carregadas:', this.paymentConditionOptions);
        } catch (error) {
            console.error('Erro ao carregar condições de pagamento:', error);
        }
    }

    async loadPricebooks() {
        try{
            this.pricebooksOptions = await getPricebooks();
            console.log('Pricebooks carregados: ', this.pricebooksOptions);
        } catch (error) {
            console.log('Erro ao carregar pricebooks: ', error);
        }
    }

    async loadAllProductsFromPricebook() {
        try {
            if (!this.formData.pricebookId) {
                return;
            }
            
            this.allProducts = await getAllProducts({
                pricebookId: this.formData.pricebookId
            });
            
            console.log('Todos os produtos carregados:', this.allProducts);
            
        } catch (error) {
            console.error('Erro ao carregar produtos:', error);
        }
    }

    async loadPricingInformation() {
        try {
            const result = await getOrderItemsPricing({orderId: this.createdOrderId});
            this.pricingInformation = result;
            // console.log(result);
        } catch(error) {
            console.error('Erro ao buscar os dados do pricing', error);
        }
    }
    
    // ========== HANDLERS - Quando usuário interage ==========
    
    handleClientChange(event) {
        const selectedValue = event.detail.value;
        this.formData.clientId = selectedValue;
        this.formData.addressId = null; 
        this.addressOptions = []; 
        
        if (selectedValue) {
            this.loadAddresses(selectedValue);
        }
    }
    
    handleAddressChange(event) {
        this.formData.addressId = event.detail.value;
    }
    
    handlePaymentChange(event) {
        this.formData.paymentConditionId = event.detail.value;
    }

    handleDistributionCenterChange(event) {
        this.formData.distributionCenterId = event.detail.value;
    }

    handlePricebookChange(event) {
        this.formData.pricebookId = event.detail.value;
    }

    handleDeliveryDateChange(event) {
        this.formData.deliveryDate = event.detail.value;
    }

    handleStartDateChange(event) {
        this.formData.startDate = event.detail.value;
    }

    handleFreightTypeChange(event) {
        this.formData.freightType = event.detail.value;

        console.log('>>>>>FreightType', this.formData.freightType);
    }
// ========== ETAPA 2: BUSCA DE PRODUTOS ==========

    async handleSearch() {
        if (!this.formData.pricebookId) {
            alert('Selecione um Catálogo de Preços antes de pesquisar!');
            return;
        }
        console.log('Filtrando produtos...');
    }
    
    handleSearchChange(event) {
        this.searchTerm = event.detail.value;
    }
    
    // ========== ETAPA 2: CARRINHO - ADICIONAR ==========
    
    addToCart(event) {

        try {
            const productId = event.target.dataset.productId;
            const productName = event.target.dataset.productName;
            const listPrice = parseFloat(event.target.dataset.price);
            const pricebookEntryId = event.target.dataset.pricebookEntryId;

            const existingItem = this.orderItems.find(item => {
                return item.productId === productId;
            });

            if(existingItem){
                existingItem.quantity += 1;
                return;
            }
        
            
            // ID temporário (será ID real quando salvar no SF)
            const tempId = 'temp_' + Date.now() + '_' + Math.random().toString(36);
            
            const newOrderItem = {
                tempId: tempId,
                productId: productId,
                productName: productName,
                pricebookEntryId: pricebookEntryId,
                listPrice: listPrice,
                quantity: 1,
                unitPrice: listPrice          
            };
            
            this.orderItems = [...this.orderItems, newOrderItem];
            
        } catch (error) {
            console.error('Erro ao adicionar ao carrinho:', error);
        }
    }
    
    // ========== ETAPA 2: CARRINHO - ABRIR/FECHAR ==========
    
    openCart() {
        this.showCart = true;
    }
    
    closeCart() {
        this.showCart = false;
    }

    // ========== ETAPA 2: CARRINHO - EVITAR FECHAR ==========
    preventClose(event){
        event.stopPropagation();
    }
        
    // ========== ETAPA 2: CARRINHO - EDITAR ITEM ==========

    updateItemQuantity(event) {
        const tempId = event.target.dataset.tempId;
        const newQuantity = parseInt(event.target.value);
        
        // Validação: Quantidade deve ser maior que zero
        if (newQuantity <= 0) {
            alert('Quantidade deve ser maior que zero');
            return;
        }
        
        this.orderItems = this.orderItems.map(item => {
            if (item.tempId === tempId) {
                return {
                    ...item,
                    quantity: newQuantity
                };
            }
            return item;
        });
    }

    updateItemPrice(event) {
        const tempId = event.target.dataset.tempId;
        const newPrice = parseFloat(event.target.value);
        
        const item = this.orderItems.find(i => i.tempId === tempId);
        
        // Validação: Preço praticado NÃO pode ser maior que preço de lista
        if (newPrice > item.listPrice) {
            alert(`Preço praticado não pode ser maior que R$ ${item.listPrice}`);
            return;
        }
        
        // Validação: Preço deve ser maior que zero
        if (newPrice <= 0) {
            alert('Preço deve ser maior que zero');
            return;
        }
        
        this.orderItems = this.orderItems.map(orderItem => {
            if (orderItem.tempId === tempId) {
                return {
                    ...orderItem,
                    unitPrice: newPrice
                };
            }
            return orderItem;
        });
    }
    
    // ========== ETAPA 2: CARRINHO - REMOVER ITEM ==========
    
    removeFromCart(event) {
        const tempId = event.target.dataset.tempId;
        this.orderItems = this.orderItems.filter(item => item.tempId !== tempId);
    }
    
    // ========== VALIDAÇÃO E AVANÇO - ETAPA 1 ==========
    
    handleAdvanceStep1() {
        // Valida campos obrigatórios
        if (!this.formData.clientId) {
            alert('Selecione um cliente!');
            return;
        }
        if (!this.formData.addressId) {
            alert('Selecione um endereço!');
            return;
        }
        if (!this.formData.distributionCenterId) {
            alert('Selecione um Centro de Distribuição!');
            return;
        }
        if (!this.formData.paymentConditionId) {
            alert('Selecione uma condição de pagamento!');
            return;
        }
        if(!this.formData.pricebookId) {
            alert('Selecione um Catálogo!');
            return;
        }
        if (!this.formData.deliveryDate) {
            alert('Selecione a data do pedido!');
            return;
        }
        if (!this.formData.startDate) {
            alert('Selecione a data de início!');
            return;
        }
        if (!this.formData.freightType) {
            alert('Selecione o tipo de frete!');
            return;
        }

        console.log('Dados da etapa 1:', this.formData);
        this.loadAllProductsFromPricebook(); // Carrega todos os produtos
        this.step = 2; // Avança pra etapa 2
    }

    // ========== VALIDAÇÃO E AVANÇO - ETAPA 2 ==========
    
    handleAdvance() {
        if (this.step === 1) {
            this.handleAdvanceStep1();
        } else if (this.step === 2) {
            this.handleAdvanceStep2();
        }
    }
    
    handleAdvanceStep2() {
        if (this.orderItems.length === 0) {
            alert('Adicione pelo menos um produto ao carrinho!');
            return;
        }
        
        console.log('Itens do pedido:', this.orderItems);
        this.step = 3;
    }
    
    
    // ========== VOLTAR ==========
    
    handleBack() {
        if (this.step > 1) {
            this.step = this.step - 1;
        }
    }

    // ========== ETAPA 3: RESUMO ==========

    get step1Class() {
        return this.step >= 1 ? 'step active' : 'step';
    }

    get step2Class() {
        return this.step >= 2 ? 'step active' : 'step';
    }

    get step3Class() {
        return this.step >= 3 ? 'step active' : 'step';
    }

    // Getters para exibir nomes (em vez de IDs)
    get clientNameDisplay() {
        const client = this.clientOptions.find(cliente => cliente.value === this.formData.clientId);
        return client ? client.label : 'Não selecionado';
    }

    get addressDisplay() {
        const address = this.addressOptions.find(address => address.value === this.formData.addressId);
        return address ? address.label : 'Não selecionado';
    }

    get distributionCenterDisplay() {
        const distributionCenter = this.distributionsCentersOptions.find(distribution => distribution.value === this.formData.distributionCenterId);
        return distributionCenter ? distributionCenter.label : 'Não selecionado';
    }

    get paymentConditionDisplay() {
        const payment = this.paymentConditionOptions.find(payment => payment.value === this.formData.paymentConditionId);
        return payment ? payment.label : 'Não selecionado';
    }

    get pricebookDisplay() {
        const pricebook = this.pricebooksOptions.find(pricebook => pricebook.value === this.formData.pricebookId);
        return pricebook ? pricebook.label : 'Não selecionado';
    }

    get deliveryDateDisplay() {
        if (!this.formData.deliveryDate) {
            return 'Não selecionada';
        }

        return new Date(this.formData.deliveryDate)
            .toLocaleDateString('pt-BR');
    }

    get startDateDisplay() {
        if (!this.formData.startDate) {
            return 'Não selecionada';
        }

        return new Date(this.formData.startDate)
            .toLocaleDateString('pt-BR');
    }

    get freightTypeDisplay() {
        const freightType = this.freightTypeOptions.find(freightType => freightType.value === this.formData.freightType);
        return freightType ? freightType.label :  'Não selecionado';
    } 

    get totalOrderValueDisplay(){
        return this.totalOrderValue.toLocaleString('pt-BR', {minimumFractionDigits:2, maximumFractionDigits:2});
    }

    // Calcula o total de um item (quantidade × preço praticado)
    calculatedTotal(quantity, unitPrice) {
        return (quantity * unitPrice).toFixed(2);
    }

    // Handler para observações
    handleObservationsChange(event) {
        this.formData.observations = event.detail.value;
    }

    get pricingInformationWithFormattedDiscount() {
        return this.pricingInformation.map(item => ({
            ...item,
            DiscountPercentage__c: parseFloat((item.DiscountPercentage__c * 100).toFixed(2))
        }));
    }

    // ========== SALVAR PEDIDO - ETAPA 3 ==========

    @track isSaving = false;

    async handleSaveOrder() {

        try {

            // Verificando o total do pedido
            const orderTotal = parseFloat(this.totalOrderValue);

            // Validação: valor mínimo
            if (orderTotal < 3000) {
                alert('O valor do pedido deve ser no mínimo R$ 3.000,00');
                return;
            }

            this.isSaving = true;

            // Prepara os dados para enviar
            const orderData = {
                accountId: this.formData.clientId,
                addressId: this.formData.addressId,
                distributionCenterId: this.formData.distributionCenterId,
                paymentConditionId: this.formData.paymentConditionId,
                pricebookId: this.formData.pricebookId,
                observations: this.formData.observations,
                orderItems: this.orderItems,
                deliveryDate: this.formData.deliveryDate,
                startDate: this.formData.startDate,
                freightType: this.formData.freightType
            };

            console.log('Objeto completo:', JSON.stringify(orderData));

            const result = await createOrder({
                orderDataJSON: JSON.stringify(orderData)
            });
            
            if (result) {
                this.createdOrderId = result;
                await this.loadPricingInformation();
                this.step = 4;
            }

        } catch (error) {

            alert('Erro ao salvar o pedido. Tente novamente.');

            console.log('ERRO:', error);

        } finally {

            console.log('FINALIZANDO HANDLE SAVE ORDER');

            this.isSaving = false;
        }
    }

    //BOTÃO CRIAR NOVO PEDIDO
    handleNewOrder(){
        this.resetForm();
        this.step = 1;
    }

    //RESETA FORMULARIO PARA NOVO PEDIDO
    resetForm(){

        this.formData = {

            clientId:null,
            addressId:null,
            distributionCenterId:null,
            paymentConditionId:null,
            pricebookId:null,
            freightType: null,
            observations:null,
            deliveryDate: null,
            startDate: null

        };

        this.addressOptions = [];

        this.orderItems = [];

        this.allProducts = [];

        this.searchTerm = '';

        this.showCart = false;

        this.createdOrderId = null;

    }
}