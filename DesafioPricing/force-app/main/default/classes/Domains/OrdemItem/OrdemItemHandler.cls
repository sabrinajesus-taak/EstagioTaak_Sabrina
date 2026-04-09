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
        for(OrderItem item : newRecords) {
            if (item.OrderId != null) {
                setOrderIds.add(item.OrderId);
                // Preenchendo o mapa de itens por pedido
                if(!itemsByOrderId.containsKey(item.OrderId)) itemsByOrderId.put(item.OrderId, new List<OrderItem>());
                itemsByOrderId.get(item.OrderId).add(item);
            }
            if (item.Product2Id != null) setProductIds.add(item.Product2Id);
        }
        
        //Busca e organização da Margem -----------------------------------------------------------------
        Map<Id, Order> mapOrders = new Map<Id, Order>([
            SELECT Id, DistributionCenter__c, State__c, City__c, Country__c, AccountId
            FROM Order
            WHERE Id IN :setOrderIds
        ]);
        
        for(Order o : mapOrders.values()) setAccountIds.add(o.AccountId);
        
        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, AccountGroup__c FROM Account WHERE Id IN :setAccountIds]);
        
        Map<Id, Product2> mapProducts = new Map<Id, Product2>([
            SELECT Id, ProductionCost__c, ProductHierarchy__c
            FROM Product2
            WHERE Id IN :setProductIds
        ]);
        
        // Busca todas as margens possíveis (Produtos e Hierarquias)
        List<Margem__c> listMargins = [
            SELECT Product__c, ProductHierarchy__c, Account__c, AccountGroup__c, City__c, State__c, Country__c, MarginValuePercent__c 
            FROM Margem__c 
            WHERE Status__c = 'Approved' 
        ];
        
        // Mapa de Margem usando a chave de 18 níveis
        Map<String, Margem__c> mapMargin = new Map<String, Margem__c>();
        for(Margem__c m : listMargins) {
            String p = (m.Product__c != null) ? String.valueOf(m.Product__c) : (m.ProductHierarchy__c != null ? String.valueOf(m.ProductHierarchy__c) : '');
            String a = (m.Account__c != null) ? String.valueOf(m.Account__c) : (m.AccountGroup__c != null ? String.valueOf(m.AccountGroup__c) : '');
            String l = (m.City__c != null) ? String.valueOf(m.City__c) : (m.State__c != null ? String.valueOf(m.State__c) : (m.Country__c != null ? String.valueOf(m.Country__c) : ''));
            
            // Use String.valueOf para evitar problemas no tamanho do ID
            String compositeKey = p + '_' + a + '_' + l;
            mapMargin.put(compositeKey, m);
            System.debug('MAPA MARGEM - Chave Gerada: ' + compositeKey);
        }
        
        //busca e organização do IMPOSTO----------------------------------------------------------------
        List<Tax__c> listTaxes = [
            SELECT Product__c, State__c, DistributionCenter__c, TaxRate__c
            FROM Tax__c
            WHERE Status__c = 'Approved'
        ];
        
        Map<String, Tax__c> mapTaxByCompositeKey = new Map<String, Tax__c>();
        for (Tax__c t : listTaxes) {
            String key = String.valueOf(t.Product__c) +
                String.valueOf(t.DistributionCenter__c) +
                String.valueOf(t.State__c);
            mapTaxByCompositeKey.put(key, t);
        }
        
        //Organização do Frete ------------------------------------------------------------
        List<Freight__c> listFreights = [
            SELECT Product__c, City__c, State__c, Country__c, DistributionCenter__c, FreightValue__c, ProductHierarchy__c
            FROM Freight__c
            WHERE Status__c = 'Approved' 
        ];
        
        Map<String, Freight__c> mapFreight = new Map<String, Freight__c>();
        for(Freight__c f : listFreights) {
            String quem = (f.Product__c != null) ? String.valueOf(f.Product__c) : (f.ProductHierarchy__c != null ? String.valueOf(f.ProductHierarchy__c) : '');
            String onde = (f.City__c != null) ? String.valueOf(f.City__c) : (f.State__c != null ? String.valueOf(f.State__c) : (f.Country__c != null ? String.valueOf(f.Country__c) : ''));
            
            String key = quem + '_' + onde;
            
            mapFreight.put(key, f);
            System.debug('MAPA FRETE - Chave Gerada: ' + key);
        }
        
        // Segundo loop: Buscando os dados dos maps (Cálculo Final)
        for(OrderItem item : newRecords) {
            Order pedido = mapOrders.get(item.OrderId);
            Product2 produto = mapProducts.get(item.Product2Id);
            Account cliente = (pedido != null) ? mapAccounts.get(pedido.AccountId) : null;
            
            
            //criterio de aceite - pricing venda 04
            if(item.Quantity <= 0 || item.UnitPrice <= 0) {
                item.addError('Não é possível cadastrar produtos do pedido com quantidade ou preço zerados.');
                continue;
            }
            
            
            if(pedido != null && produto != null) {
                //imposto
                String keyOrderItemImposto = String.valueOf(item.Product2Id) +
                    String.valueOf(pedido.DistributionCenter__c) +
                    String.valueOf(pedido.State__c);
                
                Tax__c impostoEncontrado = mapTaxByCompositeKey.get(keyOrderItemImposto);
                
                item.TaxPercentage__c = (impostoEncontrado != null) ? impostoEncontrado.TaxRate__C : 0;
                
                // Busca da Margem com especificidade
                Margem__c margem = PricingService.findMargin(item, pedido, mapMargin, produto.ProductHierarchy__c, cliente);
                item.MarginPercentage__c = (margem != null) ? margem.MarginValuePercent__c : 0;
                
                // Busca do Frete com especificidade
                item.FreightValue__c = PricingService.findFreightValue(item, pedido, mapFreight, produto.ProductHierarchy__c);
                
                // Cálculo matemático do Preço Unitário
                Decimal custoUnitario = (produto.ProductionCost__c != null) ? produto.ProductionCost__c : 0;
                
                // Cálculo final
                PricingService.calculateFinalPrice(item, item.FreightValue__c, margem, item.TaxPercentage__c, custoUnitario);
            }
        }
    }
    
    private void checkDuplicateProducts(){
        Set<Id> setOrderIds = new Set<Id>();
        Set<Id> setProductIds = new Set<Id>();
        
        for(OrderItem ot : newRecords) {
            setOrderIds.add(ot.OrderId);
            setProductIds.add(ot.Product2Id);
        }
        
        List<OrderItem> existingItens = [
        SELECT Id, OrderId, Product2Id
        FROM OrderItem
        WHERE OrderId IN :setOrderIds
        AND Product2Id IN :setProductIds
        ];
        
        Set<String> comparacao = new Set<String>();
        for(OrderItem it : existingItens) {
            comparacao.add(it.OrderId + '-' + it.Product2Id);
        }
        
        for(OrderItem newItem : newRecords){
            String keyCombo = newItem.OrderId + '-' + newItem.Product2Id;
            
            if(comparacao.contains(keyCombo)) {
                newItem.addError('Este produto já foi adicionado a este pedido. Altere a quantidade do item existente.');
            } else {
                // Adiciona ao set para evitar que duas linhas iguais no mesmo INSERT passem
                comparacao.add(keyCombo);
            }
        }
    }
    
    
    //criação do metodo para critério 06 do pedido de venda
    //impede mudar produto, qtd e preco
    private void checkActiveOrderItem() {
        List<OrderItem> listaParaValidar;
        Set<Id> idOrders = new Set<Id>();
        Map<Id, Order> idMapOrders = new Map<Id, Order>();
        
        if (Trigger.isDelete) {
            listaParaValidar = oldRecords; //usa os registros antigos
        } else {
            listaParaValidar = newRecords; //se não estuver deletando usa os novos
        }
        
        for (OrderItem ot: listaParaValidar) {
            idOrders.add(ot.OrderId);
        }
        
        List<Order> listOrder = [
            SELECT Id, Status
            FROM Order
            WHERE Id IN :idOrders
        ];
        for(Order o: listOrder) idMapOrders.put(o.Id, o);
        
        for(OrderItem ot: listaParaValidar) {
            Order pedido = idMapOrders.get(ot.OrderId);
            if(pedido != null && pedido.Status != 'Draft') {
                ot.addError('Não é possivel fazer qualquer alteração dos ITENS após o pedido ser marcado como Ativo');
                //metodo nativo que cancela a operação e coloca mensagem de erro na tela do usuario.
            }
        }
        
    }
}