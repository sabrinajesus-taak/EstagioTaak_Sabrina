// 1. CARREGAR CONTEXTO DO PEDIDO
Order ped = [SELECT Id, AccountId, City__c, State__c, DistributionCenter__c 
             FROM Order WHERE OrderNumber = '00000100' LIMIT 1];

OrderItem item = [SELECT Id, Product2Id FROM OrderItem 
                 WHERE OrderId = :ped.Id AND Product2.Name LIKE '%Colheitadeira%' LIMIT 1];

// 2. PREPARAR CENÁRIO DE PRICING (LIMPANDO DADOS ANTIGOS)
delete [SELECT Id FROM Margem__c WHERE Product__c = :item.Product2Id];
delete [SELECT Id FROM Freight__c WHERE Product__c = :item.Product2Id];

// 3. INSERIR PARÂMETROS (ISSO VALIDA OS SEUS "IFS" E REGRAS DE NEGÓCIO)
insert new Margem__c(
    Product__c = item.Product2Id,
    Account__c = ped.AccountId,
    City__c = ped.City__c,
    State__c = ped.State__c,
    DistributionCenter__c = ped.DistributionCenter__c,
    MarginValuePercent__c = 45,
    Status__c = 'Approved'
);

insert new Freight__c(
    Product__c = item.Product2Id,
    State__c = ped.State__c,
    City__c = ped.City__c,
    DistributionCenter__c = ped.DistributionCenter__c,
    FreightValue__c = 50.00,
    Status__c = 'Approved'
);

// 4. EXECUÇÃO DO CÁLCULO VIA TRIGGER
update item;

// 5. EXIBIÇÃO DOS RESULTADOS PARA AUDITORIA
OrderItem res = [SELECT MarginPercentage__c, FreightValue__c, UnitPrice FROM OrderItem WHERE Id = :item.Id];

System.debug('--- RELATÓRIO DE AUDITORIA DE PREÇO ---');
System.debug('MARGEM IDENTIFICADA: ' + res.MarginPercentage__c + '%');
System.debug('FRETE IDENTIFICADO: R$ ' + res.FreightValue__c);
System.debug('VALOR UNITÁRIO FINAL: R$ ' + res.UnitPrice);