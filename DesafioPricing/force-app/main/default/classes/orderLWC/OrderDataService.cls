public with sharing class OrderDataService {
    
    //CLIENTES
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getClients() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        
        try {
            // Busca contas (clientes)
            List<Account> accounts = [
                SELECT Id, Name 
                FROM Account 
                WHERE IsDeleted = false
            ];
            
            // Formata no padrão que o combobox espera
            for (Account account : accounts) {
                Map<String, String> option = new Map<String, String>();
                option.put('label', account.Name);
                option.put('value', account.Id);
                options.add(option);
            }
            
        } catch (Exception e) {
            System.debug('Erro ao buscar clientes: ' + e.getMessage());
        }
        
        return options;
    }
    
    // ENDEREÇOS
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getAddresses(String accountId) {
        List<Map<String, String>> options = new List<Map<String, String>>();
        
        try {
            // Busca a conta com seus dados
            List<AccountAdd__c> addresses = [
                SELECT Id, Name, Street__c, District__c, PostalCode__c
                FROM AccountAdd__c 
                WHERE Account__c = :accountId
            ];
            
            for (AccountAdd__c address : addresses) {
                Map<String, String> option = new Map<String, String>();
                String fullAddress = address.Name +
                    (address.Street__c != null ? ', ' + address.Street__c : '') +
                    (address.District__c != null ? ' - ' + address.District__c : '') +
                    (address.PostalCode__c != null ? ' - ' + address.PostalCode__c : '');
                
                option.put('label', fullAddress);
                option.put('value', address.Id);
                options.add(option);
            }
            
        } catch (Exception e) {
            System.debug('Erro ao buscar endereços: ' + e.getMessage());
        }
        
        return options;
    }
    
    // PAGAMENTO
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPaymentConditions() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        
        try {
            List<PaymentCondition__c> conditions = [
                SELECT Id, Name 
                FROM PaymentCondition__c 
                WHERE IsDeleted = false
            ];
            
            for (PaymentCondition__c condition : conditions) {
                Map<String, String> option = new Map<String, String>();
                option.put('label', condition.Name);
                option.put('value', condition.Id);
                options.add(option);
            }
            
        } catch (Exception e) {
            System.debug('Erro ao buscar condições de pagamento: ' + e.getMessage());
        }
        
        return options;
    }
    
    //PRICE BOOK
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getPricebooks() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        
        try {
            List<Pricebook2> pricebooks = [
                SELECT Id, Name
                FROM Pricebook2
                WHERE IsDeleted = false
                AND IsActive = true
            ];
            
            for (Pricebook2 pricebook : pricebooks) {
                Map<String, String> option = new Map<String, String>();
                option.put('label', pricebook.Name);
                option.put('value', pricebook.Id);
                options.add(option);
            }
            
        } catch (Exception e) {
            System.debug('Erro ao buscar os pricebooks entry: ' + e.getMessage());
        }
        
        return options;
    }
    
    // BUSCAR PRODUTOS COM FILTRO
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getProducts(String searchTerm, String pricebookId) {
        List<Map<String, Object>> products = new List<Map<String, Object>>();
        
        try {
            // Constrói a query dinamicamente com o termo de busca
            String searchPattern = '%' + searchTerm + '%';
            
            // Busca produtos que correspondem ao nome ou código
            List<PricebookEntry> entries = [
            SELECT Id, Product2Id, Product2.Name, Product2.UniqueCode__c, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = :pricebookId
            AND IsActive = true
            AND (Product2.Name LIKE :searchPattern 
                 OR Product2.UniqueCode__c LIKE :searchPattern)
        ];
            
            // Formata os dados
            for (PricebookEntry entry : entries) {
                Map<String, Object> product = new Map<String, Object>();
                product.put('id', entry.Product2Id);
                product.put('name', entry.Product2.Name);
                product.put('code', entry.Product2.UniqueCode__c);
                product.put('listPrice', entry.UnitPrice);
                product.put('pricebookEntryId', entry.Id);
                products.add(product);
            }
            
        } catch (Exception e) {
            System.debug('Erro ao buscar produtos: ' + e.getMessage());
        }
        
        return products;
    }

    // BUSCAR TODOS OS PRODUTOS DO PRICEBOOK
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getAllProducts(String pricebookId) {
        List<Map<String, Object>> products = new List<Map<String, Object>>();
        
        try {
            // Busca TODOS os produtos do pricebook
            List<PricebookEntry> entries = [
                SELECT Id, Product2Id, Product2.Name, Product2.UniqueCode__c, UnitPrice
                FROM PricebookEntry
                WHERE Pricebook2Id = :pricebookId
                AND IsActive = true
                ORDER BY Product2.Name ASC
                LIMIT 500
            ];
            
            // Formata os dados
            for (PricebookEntry entry : entries) {
                Map<String, Object> product = new Map<String, Object>();
                product.put('id', entry.Product2Id);
                product.put('name', entry.Product2.Name);
                product.put('code', entry.Product2.UniqueCode__c);
                product.put('listPrice', entry.UnitPrice);
                product.put('pricebookEntryId', entry.Id);
                products.add(product);
            }
            
        } catch (Exception e) {
            System.debug('Erro ao buscar todos os produtos: ' + e.getMessage());
        }
        
        return products;
    }

    @AuraEnabled (cacheable=true)
    public static List<Map<String, String>> getDistributionCenters() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        
        try {
            List<DistributionCenter__c> distributions = [
                SELECT Id, Name 
                FROM DistributionCenter__c
                WHERE IsDeleted = false
            ];
            
            for (DistributionCenter__c distribution : distributions) {
                Map<String, String> option = new Map<String, String>();
                option.put('label', distribution.Name);
                option.put('value', distribution.Id);
                options.add(option);
            }
            
        } catch (Exception e) {
            System.debug('Erro ao buscar os centros de distribuição: ' + e.getMessage());
        }
        
        return options;
    }

    // ========== CRIAR PEDIDO ==========
    @AuraEnabled
    public static String createOrder(String orderDataJSON) {
        try {
            // Desserializa os dados JSON
            Map<String, Object> orderData = (Map<String, Object>) JSON.deserializeUntyped(orderDataJSON);
            
            // Extrai os dados
            String accountId = (String) orderData.get('accountId');
            String addressId = (String) orderData.get('addressId');
            String distributionCenterId = (String) orderData.get('distributionCenterId');
            String paymentConditionId = (String) orderData.get('paymentConditionId');
            String pricebookId = (String) orderData.get('pricebookId');
            String observations = (String) orderData.get('observations');
            Date deliveryDate = Date.valueOf( (String) orderData.get('deliveryDate'));
            Date startDate = Date.valueOf( (String) orderData.get('startDate'));
            String freightType = (String) orderData.get('freightType');
            List<Object> itemsData = (List<Object>) orderData.get('orderItems');

            AccountAdd__c address = [
                SELECT Id, City__c, State__c, Country__c
                FROM AccountAdd__c
                WHERE Id = :addressId
                LIMIT 1
            ];
            
            // Cria o Order
            Order newOrder = new Order();
            newOrder.AccountId = accountId;
            newOrder.Pricebook2Id = pricebookId;
            newOrder.Status = 'New';
            newOrder.EffectiveDate = Date.today();
            newOrder.Description = observations;
            newOrder.AccountAddress__c = addressId;
            newOrder.DistributionCenter__c = distributionCenterId;
            newOrder.PaymentCondition__c = paymentConditionId;
            newOrder.Country__c = address.Country__c;
            newOrder.State__c = address.State__c;
            newOrder.City__c = address.City__c;
            newOrder.DeliveryDate__c = deliveryDate;
            newOrder.EffectiveDate = startDate;
            newOrder.FreightType__c = freightType;
            
            insert newOrder;
            
            // Cria os OrderItems
            List<OrderItem> orderItems = new List<OrderItem>();
            
            for (Object itemObj : itemsData) {
                Map<String, Object> item = (Map<String, Object>) itemObj;
                
                String productId = (String) item.get('productId');
                String pricebookEntryId = (String) item.get('pricebookEntryId');
                Integer quantity = Integer.valueOf(item.get('quantity'));
                Decimal unitPrice = Decimal.valueOf(String.valueOf(item.get('unitPrice')));
                
                OrderItem orderItem = new OrderItem();
                orderItem.OrderId = newOrder.Id;
                orderItem.Product2Id = productId;
                orderItem.PricebookEntryId = pricebookEntryId;
                orderItem.Quantity = quantity;
                orderItem.UnitPrice = unitPrice;
                
                orderItems.add(orderItem);
            }
            
            insert orderItems;
            
            System.debug('Pedido criado com sucesso: ' + newOrder.Id);
            
            return newOrder.Id;
            
        } catch (Exception e) {
            System.debug('Erro ao criar pedido: ' + e.getMessage());
            throw new AuraHandledException('Erro ao criar pedido: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderItemsPricing(Id orderId) {

        return [
            SELECT Id,
                Product2.Name,
                MarginPercentage__c,
                FreightValue__c,
                TaxPercentage__c,
                DiscountPercentage__c
            FROM OrderItem
            WHERE OrderId = :orderId
        ];

    }
}