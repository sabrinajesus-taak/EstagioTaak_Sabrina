// 1. Criar os Produtos (se ainda não existirem)
List<Product2> prods = new List<Product2>();
prods.add(new Product2(Name = 'Colheitadeira S700', ProductionCost__c = 50000, UniqueCode__c = 'PROD_S700'));
prods.add(new Product2(Name = 'Trator 7J', ProductionCost__c = 30000, UniqueCode__c = 'PROD_7J'));
upsert prods UniqueCode__c;

// 2. Pegar os IDs dos Produtos e de um CD/Estado (Ajuste os IDs conforme sua Org)
Id idS700 = [SELECT Id FROM Product2 WHERE Name = 'Colheitadeira S700' LIMIT 1].Id;
Id idTrator = [SELECT Id FROM Product2 WHERE Name = 'Trator 7J' LIMIT 1].Id;

// 3. Criar a lista de Impostos para teste
List<Tax__c> impostosParaInserir = new List<Tax__c>();

// Imposto 1: Colheitadeira em SP
impostosParaInserir.add(new Tax__c(
    Product__c = idS700,
    State__c = 'a04g8000000QmaTAAS', // <-- COLOQUE O ID DO REGISTRO DE ESTADO AQUI
    DistributionCenter__c = 'a04g8000000QmaTAAS', // <-- COLOQUE O ID DO REGISTRO DE CD AQUI
    TaxRate__c = 12.0,
    Status__c = 'Aprovado'
));

// Imposto 2: Trator em SP
impostosParaInserir.add(new Tax__c(
    Product__c = idTrator,
    State__c = 'a04g8000000QmaTAAS', 
    DistributionCenter__c = 'a04g8000000QmaTAAS',
    TaxRate__c = 8.0,
    Status__c = 'Aprovado'
));

try {
    insert impostosParaInserir;
    System.debug('✅ Sucesso: Impostos criados! O Flow preencheu o TaxCode automaticamente.');
} catch (Exception e) {
    System.debug('❌ Erro de Duplicidade ou Validação: ' + e.getMessage());
}