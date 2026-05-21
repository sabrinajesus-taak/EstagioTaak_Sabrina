// 1. Setup de Dados Básicos
Id idProd = [SELECT Id FROM Product2 WHERE Name = 'Colheitadeira S700' LIMIT 1].Id;
Id idHiera = [SELECT Id, ProductHierarchy__c FROM Product2 WHERE Name = 'Colheitadeira S700' LIMIT 1].ProductHierarchy__c;
Id idCid = [SELECT Id FROM City__c WHERE Name = 'São Bernardo Do Campo' LIMIT 1].Id;
Id idEstSP = [SELECT Id FROM State__c WHERE Name = 'São Paulo' LIMIT 1].Id;
Id idPais = [SELECT Id FROM Country__c WHERE Name = 'Brasil' LIMIT 1].Id;
Id idCD = [SELECT Id FROM DistributionCenter__c LIMIT 1].Id;

// 2. Garantir que temos um SEGUNDO estado para não dar duplicidade no Flow
State__c outroEstado;
List<State__c> estadosExistentes = [SELECT Id FROM State__c WHERE Name = 'Paraná' LIMIT 1];

if(estadosExistentes.isEmpty()) {
    outroEstado = new State__c(Name = 'Paraná', StateCode__c = 'PR', Country__c = 'Brasil'); // Ajuste o campo Sigla__c se o nome for outro
    insert outroEstado;
} else {
    outroEstado = estadosExistentes[0];
}
Id idEstPR = outroEstado.Id;

// 3. Limpeza de fretes antigos para o teste ser limpo
delete [SELECT Id FROM Freight__c WHERE (Product__c = :idProd OR ProductHierarchy__c = :idHiera)];

// 4. Criação da Escada de 6 Níveis
List<Freight__c> fretesEscada = new List<Freight__c>();

// Nível 1: Produto + Cidade (Usa SP)
fretesEscada.add(new Freight__c(Product__c=idProd, City__c=idCid, State__c=idEstSP, DistributionCenter__c=idCD, FreightValue__c=100, Status__c='Approved'));

// Nível 2: Produto + Estado (Usa SP)
fretesEscada.add(new Freight__c(Product__c=idProd, State__c=idEstSP, DistributionCenter__c=idCD, FreightValue__c=200, Status__c='Approved'));

// Nível 3: Produto + País (Usa PR para a chave do Flow ser diferente do Nível 2)
fretesEscada.add(new Freight__c(Product__c=idProd, Country__c=idPais, State__c=idEstPR, DistributionCenter__c=idCD, FreightValue__c=300, Status__c='Approved'));

// Nível 4: Hierarquia + Cidade (Usa SP)
fretesEscada.add(new Freight__c(ProductHierarchy__c=idHiera, City__c=idCid, State__c=idEstSP, DistributionCenter__c=idCD, FreightValue__c=400, Status__c='Approved'));

// Nível 5: Hierarquia + Estado (Usa SP)
fretesEscada.add(new Freight__c(ProductHierarchy__c=idHiera, State__c=idEstSP, DistributionCenter__c=idCD, FreightValue__c=500, Status__c='Approved'));

// Nível 6: Hierarquia + País (Usa PR)
fretesEscada.add(new Freight__c(ProductHierarchy__c=idHiera, Country__c=idPais, State__c=idEstPR, DistributionCenter__c=idCD, FreightValue__c=600, Status__c='Approved'));

insert fretesEscada;

System.debug('✅ SUCESSO: Todos os 6 níveis de frete foram criados!');
System.debug('ID do Estado criado/usado: ' + idEstPR);