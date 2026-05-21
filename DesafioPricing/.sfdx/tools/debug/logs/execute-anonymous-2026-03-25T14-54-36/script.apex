// 1. DADOS DO PEDIDO
Order ped = [SELECT Id, DistributionCenter__c, City__c, AccountId FROM Order WHERE OrderNumber = '00000100' LIMIT 1];
OrderItem item = [SELECT Id, Product2Id FROM OrderItem WHERE OrderId = :ped.Id LIMIT 1];

// 2. LIMPEZA TOTAL
delete [SELECT Id FROM Margem__c WHERE Product__c = :item.Product2Id];

// 3. CRIA A MARGEM (Apenas com o que você REALMENTE tem)
Margem__c m1 = new Margem__c();
m1.Product__c = item.Product2Id;
m1.Account__c = ped.AccountId; // Incluí a conta por via das dúvidas
m1.DistributionCenter__c = ped.DistributionCenter__c;
m1.City__c = ped.City__c;
m1.MarginValuePercent__c = 45;
m1.Status__c = 'Approved'; // Verifique se no seu objeto é 'Approved' ou 'Aprovado'
insert m1;

// 4. VERIFICAÇÃO MANUAL (O SELECT que a Trigger deveria fazer)
Margem__c conferencia = [SELECT Id, Product__c, City__c, DistributionCenter__c, Status__c 
                         FROM Margem__c WHERE Id = :m1.Id];

System.debug('--- 🔍 CONFERINDO A MARGEM CRIADA ---');
System.debug('Produto na Margem: ' + conferencia.Product__c);
System.debug('Cidade na Margem: ' + conferencia.City__c);
System.debug('Status na Margem: ' + conferencia.Status__c);

// 5. UPDATE PARA TESTAR A TRIGGER
update item;

// 6. RESULTADO
OrderItem res = [SELECT MarginPercentage__c, UnitPrice FROM OrderItem WHERE Id = :item.Id];
System.debug('--- 🏆 RESULTADO FINAL ---');
System.debug('Margem no Item: ' + res.MarginPercentage__c + '%');