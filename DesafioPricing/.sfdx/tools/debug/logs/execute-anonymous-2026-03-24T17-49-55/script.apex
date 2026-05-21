// 1. SETUP DE DADOS
Id idP = [SELECT Id FROM Product2 WHERE Name = 'Colheitadeira S700' LIMIT 1].Id;
Id idC = [SELECT Id FROM City__c WHERE Name = 'São Bernardo Do Campo' LIMIT 1].Id;
Id idE = [SELECT Id FROM State__c WHERE Name = 'São Paulo' LIMIT 1].Id;
Id idPa = [SELECT Id FROM Country__c WHERE Name = 'Brasil' LIMIT 1].Id;
Id idD = [SELECT Id FROM DistributionCenter__c LIMIT 1].Id;

// Garantia do segundo estado para o teste de País
Id idOutroE;
List<State__c> outros = [SELECT Id FROM State__c WHERE Name != 'São Paulo' LIMIT 1];
if(outros.isEmpty()) {
    State__c novoEst = new State__c(Name = 'Paraná', StateCode__c = 'PR', Country__c = idPa); // Use o ID do país aqui
    insert novoEst;
    idOutroE = novoEst.Id;
} else {
    idOutroE = outros[0].Id;
}

// 2. LIMPEZA
delete [SELECT Id FROM Freight__c WHERE Product__c = :idP];

// 3. CRIAÇÃO DOS NÍVEIS
Freight__c fCid = new Freight__c(Product__c=idP, City__c=idC, State__c=idE, DistributionCenter__c=idD, FreightValue__c=450, Status__c='Approved'); 
Freight__c fEst = new Freight__c(Product__c=idP, State__c=idE, DistributionCenter__c=idD, FreightValue__c=1200, Status__c='Approved'); 
Freight__c fPai = new Freight__c(Product__c=idP, Country__c=idPa, State__c=idOutroE, DistributionCenter__c=idD, FreightValue__c=2500, Status__c='Approved'); 
insert new List<Freight__c>{fCid, fEst, fPai};

// 4. RESULTADOS (O que você vai mostrar no Log)
System.debug('>>> BUSCA 1 (CIDADE): R$ ' + fCid.FreightValue__c);
delete fCid;
System.debug('>>> BUSCA 2 (ESTADO): R$ ' + fEst.FreightValue__c);
delete fEst;
System.debug('>>> BUSCA 3 (PAÍS): R$ ' + fPai.FreightValue__c);