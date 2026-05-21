// 1. PEGA OS IDS REAIS DO SEU PEDIDO (Direto da fonte)
Order ped = [SELECT Id, DistributionCenter__c, City__c FROM Order WHERE OrderNumber = '00000100' LIMIT 1];
OrderItem item = [SELECT Id, Product2Id FROM OrderItem WHERE OrderId = :ped.Id LIMIT 1];

// 2. LIMPA TUDO PARA NÃO TER RUÍDO
delete [SELECT Id FROM Margem__c WHERE Product__c = :item.Product2Id];

// 3. CRIA A MARGEM COPIANDO OS IDS DO PEDIDO (O "DNA" idêntico)
Margem__c m1 = new Margem__c();
m1.Product__c = item.Product2Id;
m1.DistributionCenter__c = ped.DistributionCenter__c; // ID EXATO DO PEDIDO
m1.City__c = ped.City__c;                             // ID EXATO DO PEDIDO
m1.MarginValuePercent__c = 45;
m1.Status__c = 'Approved';
insert m1;

// 4. DÁ O "UPDATE" PARA DISPARAR A TRIGGER
update item;

// 5. O VEREDITO
OrderItem res = [SELECT MarginPercentage__c, UnitPrice FROM OrderItem WHERE Id = :item.Id];
System.debug('--- 🧐 ANALISANDO OS IDS ---');
System.debug('ID do CD no Pedido: ' + ped.DistributionCenter__c);
System.debug('ID da Cidade no Pedido: ' + ped.City__c);
System.debug('RESULTADO FINAL - Margem: ' + res.MarginPercentage__c + '%');