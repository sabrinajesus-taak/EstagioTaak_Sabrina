Id idProduto = [SELECT Id FROM Product2 WHERE Name = 'Colheitadeira S700' LIMIT 1].Id;
Id idCidade = [SELECT Id FROM City__c WHERE Name = 'São Bernardo Do Campo' LIMIT 1].Id;


Margem__c margem1 = new Margem__c(Product__c=idProduto, City__c=idCidade, MarginValuePercent__c=10, Status__c='Approved');
insert margem1;

try {
    Margem__c margem2 = new Margem__c(Product__c=idProduto, City__c=idCidade, MarginValuePercent__c=20, Status__c='Approved');
    insert margem2;
    System.debug('Criou duplicado');
} catch (Exception e) {
    System.debug('Não teve duplicidade' + e.getMessage());
}