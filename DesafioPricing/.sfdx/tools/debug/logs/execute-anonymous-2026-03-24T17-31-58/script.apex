// 1. Setup de Dados (IDs da sua Org)
Id idProd = [SELECT Id FROM Product2 WHERE Name = 'Colheitadeira S700' LIMIT 1].Id;
Id idHiera = [SELECT Id, ProductHierarchy__c FROM Product2 WHERE Name = 'Colheitadeira S700' LIMIT 1].ProductHierarchy__c;
Id idCid = [SELECT Id FROM City__c WHERE Name = 'São Bernardo Do Campo' LIMIT 1].Id;
Id idEst = [SELECT Id FROM State__c WHERE Name = 'São Paulo' LIMIT 1].Id;
Id idPais = [SELECT Id FROM Country__c WHERE Name = 'Brasil' LIMIT 1].Id;
Id idCD = [SELECT Id FROM DistributionCenter__c LIMIT 1].Id;

// Limpeza para o teste ser puro
delete [SELECT Id FROM Freight__c WHERE (Product__c = :idProd OR ProductHierarchy__c = :idHiera) AND Status__c = 'Approved'];

List<Freight__c> fretesEscada = new List<Freight__c>();

// Nível 1: Produto + Cidade (Sempre enviando Estado e CD para satisfazer a Validation Rule)
fretesEscada.add(new Freight__c(Product__c=idProd, City__c=idCid, State__c=idEst, DistributionCenter__c=idCD, FreightValue__c=100, Status__c='Approved'));

// Nível 2: Produto + Estado
fretesEscada.add(new Freight__c(Product__c=idProd, State__c=idEst, DistributionCenter__c=idCD, FreightValue__c=200, Status__c='Approved'));

// Nível 3: Produto + País
fretesEscada.add(new Freight__c(Product__c=idProd, Country__c=idPais, State__c=idEst, DistributionCenter__c=idCD, FreightValue__c=300, Status__c='Approved'));

// Nível 4: Hierarquia + Cidade
fretesEscada.add(new Freight__c(ProductHierarchy__c=idHiera, City__c=idCid, State__c=idEst, DistributionCenter__c=idCD, FreightValue__c=400, Status__c='Approved'));

// Nível 5: Hierarquia + Estado
fretesEscada.add(new Freight__c(ProductHierarchy__c=idHiera, State__c=idEst, DistributionCenter__c=idCD, FreightValue__c=500, Status__c='Approved'));

// Nível 6: Hierarquia + País
fretesEscada.add(new Freight__c(ProductHierarchy__c=idHiera, Country__c=idPais, State__c=idEst, DistributionCenter__c=idCD, FreightValue__c=600, Status__c='Approved'));

insert fretesEscada;


System.debug('🧪 --- TESTE DOS 6 NÍVEIS --- 🧪');
System.debug('O resultado esperado é R$ 100,00 (Nível 1 - Mais específico)');

// Simulação da busca (Igual à sua Trigger)
// Aqui você valida se o seu map e seus IFs estão pegando o freteEscada[0]
// Rode e verifique o valor atribuído ao item no final.