Id idP = [SELECT Id FROM Product2 WHERE Name = 'Colheitadeira S700' LIMIT 1].Id;
Id idC = [SELECT Id FROM City__c WHERE Name = 'São Bernardo Do Campo' LIMIT 1].Id;
Id idE = [SELECT Id FROM State__c WHERE Name = 'São Paulo' LIMIT 1].Id;
Id idPa = [SELECT Id FROM Country__c WHERE Name = 'Brasil' LIMIT 1].Id;
Id idD = [SELECT Id FROM DistributionCenter__c LIMIT 1].Id;

delete [SELECT Id FROM Freight__c WHERE Product__c = :idP];

// Criando os registros
Freight__c fCid = new Freight__c(Product__c=idP, City__c=idC, State__c=idE, DistributionCenter__c=idD, FreightValue__c=450, Status__c='Approved'); //cidade
Freight__c fEst = new Freight__c(Product__c=idP, State__c=idE, DistributionCenter__c=idD, FreightValue__c=1200, Status__c='Approved'); //estado
Freight__c fPai = new Freight__c(Product__c=idP, Country__c=idPa, State__c=idE, DistributionCenter__c=idD, FreightValue__c=2500, Status__c='Approved'); //pais
insert new List<Freight__c>{fCid, fEst, fPai};

// --- TESTE 1: PRIORIDADE MÁXIMA ---
System.debug('>>> BUSCA 1 (CIDADE): R$ ' + [SELECT FreightValue__c FROM Freight__c WHERE Product__c=:idP AND City__c=:idC LIMIT 1].FreightValue__c);

// --- TESTE 2: REMOVE CIDADE, SOBRA ESTADO E PAÍS ---
delete fCid;
System.debug('>>> BUSCA 2 (ESTADO VS PAÍS): R$ ' + [SELECT FreightValue__c FROM Freight__c WHERE Product__c=:idP AND State__c=:idE AND City__c=null LIMIT 1].FreightValue__c);

// --- TESTE 3: REMOVE ESTADO, SOBRA SÓ PAÍS ---
delete fEst;
System.debug('>>> BUSCA 3 (NÍVEL GERAL): R$ ' + [SELECT FreightValue__c FROM Freight__c WHERE Product__c=:idP AND Country__c=:idPa AND State__c=:idE LIMIT 1].FreightValue__c);