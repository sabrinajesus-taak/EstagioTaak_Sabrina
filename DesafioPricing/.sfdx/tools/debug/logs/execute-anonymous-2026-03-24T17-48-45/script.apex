Id idP = [SELECT Id FROM Product2 WHERE Name = 'Colheitadeira S700' LIMIT 1].Id;
Id idC = [SELECT Id FROM City__c WHERE Name = 'São Bernardo Do Campo' LIMIT 1].Id;
Id idE = [SELECT Id FROM State__c WHERE Name = 'São Paulo' LIMIT 1].Id;
Id idPa = [SELECT Id FROM Country__c WHERE Name = 'Brasil' LIMIT 1].Id;
Id idD = [SELECT Id FROM DistributionCenter__c LIMIT 1].Id;
// Pegando o outro estado para não dar duplicidade na chave do Flow
Id idOutroE = [SELECT Id FROM State__c WHERE Name != 'São Paulo' LIMIT 1].Id; 

delete [SELECT Id FROM Freight__c WHERE Product__c = :idP];

// 1. Cidade (Chave: Prod_SBC)
Freight__c fCid = new Freight__c(Product__c=idP, City__c=idC, State__c=idE, DistributionCenter__c=idD, FreightValue__c=450, Status__c='Approved'); 
// 2. Estado (Chave: Prod_SP)
Freight__c fEst = new Freight__c(Product__c=idP, State__c=idE, DistributionCenter__c=idD, FreightValue__c=1200, Status__c='Approved'); 
// 3. País (Chave: Prod_PR - Usando PR para o Flow entender que é outra rota)
Freight__c fPai = new Freight__c(Product__c=idP, Country__c=idPa, State__c=idOutroE, DistributionCenter__c=idD, FreightValue__c=2500, Status__c='Approved'); 

insert new List<Freight__c>{fCid, fEst, fPai};

System.debug('>>> BUSCA 1 (ESPECÍFICO): R$ ' + [SELECT FreightValue__c FROM Freight__c WHERE Id = :fCid.Id].FreightValue__c);

delete fCid;
System.debug('>>> BUSCA 2 (MÉDIO): R$ ' + [SELECT FreightValue__c FROM Freight__c WHERE Id = :fEst.Id].FreightValue__c);

delete fEst;
System.debug('>>> BUSCA 3 (GERAL): R$ ' + [SELECT FreightValue__c FROM Freight__c WHERE Id = :fPai.Id].FreightValue__c);