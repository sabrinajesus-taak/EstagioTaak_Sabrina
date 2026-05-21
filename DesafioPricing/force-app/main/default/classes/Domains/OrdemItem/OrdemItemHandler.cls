public class OrdemItemHandler extends TriggerHandler {
    
    private List<OrderItem> newRecords;
    private List<OrderItem> oldRecords;
    private Map<Id, OrderItem> newRecordsMap;
    private Map<Id, OrderItem> oldRecordsMap;
    
    // Construtor seguindo o padrão do Framework
    public OrdemItemHandler() {
        super('OrderItemHandler');
        this.newRecords = (List<OrderItem>) Trigger.new;
        this.oldRecords = (List<OrderItem>) Trigger.old;
        this.newRecordsMap = (Map<Id, OrderItem>) Trigger.newMap;
        this.oldRecordsMap = (Map<Id, OrderItem>) Trigger.oldMap;
    }
    
    
    public override void beforeInsert() {
        checkActiveOrderItem();
        executePricingLogic();
        checkDuplicateProducts();
    }
    
    //recalcula o preço se o pedido estiver ativo
    public override void beforeUpdate() {
        checkActiveOrderItem();
        executePricingLogic();
    }
    
    public override void beforeDelete() {
        checkActiveOrderItem();
    }
    
    
    private void executePricingLogic() {
        //Ids para usar nas SOQL
        Set<Id> setOrderIds = new Set<Id>();
        Set<Id> setProductIds = new Set<Id>();
        Set<Id> setAccountIds = new Set<Id>(); // Set para buscar dados do Cliente (Grupo)
        
        //coleção para agrupar itens dos respectivos pedidos
        Map<Id, List<OrderItem>> itemsByOrderId = new Map<Id, List<OrderItem>>();
        
        // Primeiro loop: Coleta dos IDs básicos que o OrderItem já possui
        for(OrderItem iOrderItem : newRecords) {
            if (iOrderItem.OrderId != null) {
                setOrderIds.add(iOrderItem.OrderId);
                // Preenchendo o mapa de itens por pedido
                if(!itemsByOrderId.containsKey(iOrderItem.OrderId)) itemsByOrderId.put(iOrderItem.OrderId, new List<OrderItem>());
                itemsByOrderId.get(iOrderItem.OrderId).add(iOrderItem);
            }
            if (iOrderItem.Product2Id != null) setProductIds.add(iOrderItem.Product2Id);
        }
        
        //Busca e organização da Margem -----------------------------------------------------------------
        Map<Id, Order> mapOrders = OrderSelector.getOrdersByIds(setOrderIds);
        
        for(Order iOrder : mapOrders.values()) setAccountIds.add(iOrder.AccountId);
        
        Map<Id, Account> mapAccounts = AccountSelector.getAccountByIds(setAccountIds);
        
        Map<Id, Product2> mapProducts = ProductSelector.getProductByIds(setProductIds);
        
        // Busca todas as margens possíveis (Produtos e Hierarquias)
        List<Margem__c> listMargins = MargemSelector.getMargemApproved();
        
        // Mapa de Margem usando a chave de 18 níveis
        Map<String, Margem__c> mapMargin = new Map<String, Margem__c>();
        for(Margem__c iMargem : listMargins) {
            String produtoOrHierarchy = (iMargem.Product__c != null) ? String.valueOf(iMargem.Product__c) : (iMargem.ProductHierarchy__c != null ? String.valueOf(iMargem.ProductHierarchy__c) : '');
            String accountOrAccountGroup = (iMargem.Account__c != null) ? String.valueOf(iMargem.Account__c) : (iMargem.AccountGroup__c != null ? String.valueOf(iMargem.AccountGroup__c) : '');
            String location = (iMargem.City__c != null) ? String.valueOf(iMargem.City__c) : (iMargem.State__c != null ? String.valueOf(iMargem.State__c) : (iMargem.Country__c != null ? String.valueOf(iMargem.Country__c) : ''));
            
            // Use String.valueOf para evitar problemas no tamanho do ID
            String compositeKey = produtoOrHierarchy + '_' + accountOrAccountGroup + '_' + location;
            mapMargin.put(compositeKey, iMargem);
            System.debug('MAPA MARGEM - Chave Gerada: ' + compositeKey);
        }
        
        //busca e organização do IMPOSTO----------------------------------------------------------------
        List<Tax__c> listTaxes = TaxSelector.getTaxApproved();
        
        Map<String, Tax__c> mapTaxByCompositeKey = new Map<String, Tax__c>();
        for (Tax__c iTax : listTaxes) {
            String key = String.valueOf(iTax.Product__c) +
                String.valueOf(iTax.DistributionCenter__c) +
                String.valueOf(iTax.State__c);
            mapTaxByCompositeKey.put(key, iTax);
        }
        
        //Organização do Frete ------------------------------------------------------------
        List<Freight__c> listFreights = FreightSelector.getFreightApproved();
        
        Map<String, Freight__c> mapFreight = new Map<String, Freight__c>();
        for(Freight__c iFreight : listFreights) {
            String productOrHierarchy = (iFreight.Product__c != null) ? String.valueOf(iFreight.Product__c) : (iFreight.ProductHierarchy__c != null ? String.valueOf(iFreight.ProductHierarchy__c) : '');
            String location = (iFreight.City__c != null) ? String.valueOf(iFreight.City__c) : (iFreight.State__c != null ? String.valueOf(iFreight.State__c) : (iFreight.Country__c != null ? String.valueOf(iFreight.Country__c) : ''));
            
            String key = productOrHierarchy + '_' + location;
            
            mapFreight.put(key, iFreight);
            System.debug('MAPA FRETE - Chave Gerada: ' + key);
        }
        
        // Segundo loop: Buscando os dados dos maps (Cálculo Final)
        for(OrderItem iOrderItem : newRecords) {
            Order order = mapOrders.get(iOrderItem.OrderId);
            Product2 product = mapProducts.get(iOrderItem.Product2Id);
            Account custumer = (order != null) ? mapAccounts.get(order.AccountId) : null;
            
            
            //criterio de aceite - pricing venda 04
            if(iOrderItem.Quantity <= 0 || iOrderItem.UnitPrice <= 0) {
                iOrderItem.addError('Não é possível cadastrar produtos do pedido com quantidade ou preço zerados.');
                continue;
            }
            
            
            if(order != null && product != null) {
                //imposto
                String keyOrderItemTax = String.valueOf(iOrderItem.Product2Id) +
                    String.valueOf(order.DistributionCenter__c) +
                    String.valueOf(order.State__c);
                
                Tax__c taxFound = mapTaxByCompositeKey.get(keyOrderItemTax);
                
                iOrderItem.TaxPercentage__c = (taxFound != null) ? taxFound.TaxRate__C : 0;
                
                // Busca da Margem com especificidade
                Margem__c margem = MarginService.findMargin(iOrderItem, order, mapMargin, product.ProductHierarchy__c, custumer);
                iOrderItem.MarginPercentage__c = (margem != null) ? margem.MarginValuePercent__c : 0;
                
                // Busca do Frete com especificidade
                iOrderItem.FreightValue__c = FreightService.findFreight(iOrderItem, order, mapFreight, product.ProductHierarchy__c);
                
                // Cálculo matemático do Preço Unitário
                Decimal unitCost = (product.ProductionCost__c != null) ? product.ProductionCost__c : 0;
                
                if(unitCost <= 0 || iOrderItem.FreightValue__c == null || taxFound == null || margem == null || iOrderItem.MarginPercentage__c <= 0) {
                    iOrderItem.addError('Não está autorizada a venda deste produto devido a falta de parâmetros, entre em contato com o time de pricing.');
                    continue; // Pula para o próximo iOrderItem sem calcular
                }
                
                // Cálculo final
                PricingService.calculateFinalPrice(iOrderItem, iOrderItem.FreightValue__c, margem, iOrderItem.TaxPercentage__c, unitCost);
            }
        }
    }
    
    private void checkDuplicateProducts(){
        Set<Id> setOrderIds = new Set<Id>();
        Set<Id> setProductIds = new Set<Id>();
        
        for(OrderItem iOrderItem : newRecords) {
            setOrderIds.add(iOrderItem.OrderId);
            setProductIds.add(iOrderItem.Product2Id);
        }
        
        List<OrderItem> existingItens = OrderItemSelector.getOrderItemByIds(setOrderIds, setProductIds);
        
        Set<String> comparison = new Set<String>();
        for(OrderItem iOrderItem : existingItens) {
            comparison.add(iOrderItem.OrderId + '-' + iOrderItem.Product2Id);
        }
        
        for(OrderItem newIOrderItem : newRecords){
            String keyCombo = newIOrderItem.OrderId + '-' + newIOrderItem.Product2Id;
            
            if(comparison.contains(keyCombo)) {
                newIOrderItem.addError('Este produto já foi adicionado a este pedido. Altere a quantidade do item existente.');
            } else {
                // Adiciona ao set para evitar que duas linhas iguais no mesmo INSERT passem
                comparison.add(keyCombo);
            }
        }
    }
    
    
    //criação do metodo para critério 06 do pedido de venda
    //impede mudar produto, qtd e preco
    private void checkActiveOrderItem() {
        List<OrderItem> listToValidate;
        Set<Id> idOrders = new Set<Id>();
        Map<Id, Order> idMapOrders = new Map<Id, Order>();
        
        if (Trigger.isDelete) {
            listToValidate = oldRecords; //usa os registros antigos
        } else {
            listToValidate = newRecords; //se não estuver deletando usa os novos
        }
        
        for (OrderItem iOrderItem: listToValidate) {
            idOrders.add(iOrderItem.OrderId);
        }
        
        idMapOrders = OrderSelector.getOrdersByIds(idOrders);
        
        for(OrderItem iOrderItem: listToValidate) {
            Order order = idMapOrders.get(iOrderItem.OrderId);
            if(order.Status == 'Aprovado') {
                iOrderItem.addError('Não é possivel fazer qualquer alteração dos ITENS após o pedido ser marcado como Ativo.');
                //metodo nativo que cancela a operação e coloca mensagem de erro na tela do usuario.
            }
        }
        
    }
}