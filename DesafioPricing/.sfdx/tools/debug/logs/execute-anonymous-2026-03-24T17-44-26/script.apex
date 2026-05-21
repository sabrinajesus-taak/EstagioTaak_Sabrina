Id idP = [SELECT Id FROM Product2 WHERE Name = 'Colheitadeira S700' LIMIT 1].Id;
Id idC = [SELECT Id FROM City__c WHERE Name = 'São Bernardo Do Campo' LIMIT 1].Id;
Id idE = [SELECT Id FROM State__c WHERE Name = 'São Paulo' LIMIT 1].Id;
Id idD = [SELECT Id FROM DistributionCenter__c LIMIT 1].Id;

delete [SELECT Id FROM Freight__c WHERE Product__c = :idP];

Freight__c f1 = new Freight__c(Product__c=idP, City__c=idC, State__c=idE, DistributionCenter__c=idD, FreightValue__c=450, Status__c='Approved');
Freight__c f2 = new Freight__c(Product__c=idP, State__c=idE, DistributionCenter__c=idD, FreightValue__c=1200, Status__c='Approved');
insert new List<Freight__c>{f1, f2};

// --- TESTE 1: BUSCA ESPECÍFICA ---
Freight__c res1 = [SELECT FreightValue__c FROM Freight__c WHERE Product__c = :idP AND City__c = :idC LIMIT 1];
System.debug('>>> VALOR ENCONTRADO (CIDADE): R$ ' + res1.FreightValue__c);

// --- SIMULAÇÃO DE FALLBACK ---
delete f1; 

// --- TESTE 2: BUSCA APÓS EXCLUSÃO ---
Freight__c res2 = [SELECT FreightValue__c FROM Freight__c WHERE Product__c = :idP AND State__c = :idE LIMIT 1];
System.debug('>>> VALOR ENCONTRADO (ESTADO): R$ ' + res2.FreightValue__c);