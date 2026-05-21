// 1. Criar os Produtos (se ainda não existirem)
List<Product2> prods = new List<Product2>();
prods.add(new Product2(Name = 'Colheitadeira S700', ProductionCost__c = 50000, UniqueCode__c = 'PROD_S700'));
prods.add(new Product2(Name = 'Trator 7J', ProductionCost__c = 30000, UniqueCode__c = 'PROD_7J'));
upsert prods UniqueCode__c;

// 1. Pegar IDs que já existem na sua Org (Ajuste se os nomes forem diferentes)
Id idS700 = [SELECT Id FROM Product2 WHERE Name = 'Colheitadeira S700' LIMIT 1].Id;
Id idCidadeSP = [SELECT Id FROM City__c WHERE Name = 'São Bernardo Do Campo' LIMIT 1].Id; // Ajuste o nome da cidade se precisar
Id idCD = [SELECT Id FROM DistributionCenter__c LIMIT 1].Id; // Pega qualquer CD para o teste
Id idEstado = [SELECT Id FROM State__c WHERE Name = 'São Paulo' LIMIT 1].Id;

// 2. Criar a lista para tentar inserir dois registros "gêmeos"
List<Freight__c> fretesParaTestar = new List<Freight__c>();

// Frete A
fretesParaTestar.add(new Freight__c(
    Product__c = idS700,
    City__c = idCidadeSP,
    State__c = idEstado,
    DistributionCenter__c = idCD,
    FreightValue__c = 500.00,
    Status__c = 'Approved'
));

// Frete B (Exatamente igual ao A - O "Vilão" da duplicidade)
fretesParaTestar.add(new Freight__c(
    Product__c = idS700,
    City__c = idCidadeSP,
    State__c = idEstado,
    DistributionCenter__c = idCD,
    FreightValue__c = 999.00, // Valor diferente, mas a CHAVE (Prod + Cidade) é a mesma
    Status__c = 'Approved'
));

try {
    // Tentativa de inserção em lote
    insert fretesParaTestar;
    System.debug('✅ Erro: O sistema permitiu duplicidade! Verifique o Flow e o campo Unique.');
} catch (Exception e) {
    System.debug('🛡️ SUCESSO! O Salesforce barrou a duplicidade. Erro: ' + e.getMessage());
}