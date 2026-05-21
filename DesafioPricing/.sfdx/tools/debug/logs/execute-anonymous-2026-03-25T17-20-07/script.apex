// 1. SETUP: Identificar o Pedido e o Item
Order ped = [SELECT Id, City__c, State__c, DistributionCenter__c FROM Order WHERE OrderNumber = '00000100' LIMIT 1];
OrderItem item = [SELECT Id, Product2Id FROM OrderItem WHERE OrderId = :ped.Id LIMIT 1];

// 2. LIMPEZA E CRIAÇÃO DE DOIS NÍVEIS DE FRETE
delete [SELECT Id FROM Freight__c WHERE Product__c = :item.Product2Id];

// Nível 1: Frete por CIDADE (Mais específico - R$ 500)
Freight__c freteCidade = new Freight__c(
    Product__c = item.Product2Id,
    City__c = ped.City__c,
    DistributionCenter__c = ped.DistributionCenter__c,
    FreightValue__c = 500.00,
    Status__c = 'Approved'
);

// Nível 2: Frete por ESTADO (Mais genérico - R$ 1200)
Freight__c freteEstado = new Freight__c(
    Product__c = item.Product2Id,
    State__c = ped.State__c,
    DistributionCenter__c = ped.DistributionCenter__c,
    FreightValue__c = 1200.00,
    Status__c = 'Approved'
);

insert new List<Freight__c>{freteCidade, freteEstado};

// --- TESTE 1: BUSCA POR CIDADE ---
update item;
OrderItem res1 = [SELECT FreightValue__c FROM OrderItem WHERE Id = :item.Id];
System.debug('--- TESTE 1 (MAIS ESPECÍFICO) ---');
System.debug('FRETE ENCONTRADO (CIDADE): R$ ' + res1.FreightValue__c);

// --- TESTE 2: REMOVE A CIDADE E TESTA A HIERARQUIA (ESTADO) ---
delete freteCidade; 
update item; // A Trigger tem que recalcular e achar o de R$ 1200 agora!

OrderItem res2 = [SELECT FreightValue__c FROM OrderItem WHERE Id = :item.Id];
System.debug('--- TESTE 2 (HIERARQUIA / ESTADO) ---');
System.debug('FRETE ENCONTRADO APÓS DELETE: R$ ' + res2.FreightValue__c);