// Busca o item que você acabou de criar manualmente
OrderItem result = [SELECT MarginPercentage__c, UnitPrice, FreightValue__c, Product2.Name 
                   FROM OrderItem 
                   ORDER BY CreatedDate DESC LIMIT 1];

System.debug('--- 🏆 DESAFIO CONCLUÍDO COM SUCESSO ---');
System.debug('Produto testado: ' + result.Product2.Name);
System.debug('Margem aplicada: ' + result.MarginPercentage__c + '%');
System.debug('Frete calculado: R$ ' + result.FreightValue__c);
System.debug('Preço Final (PricingService): R$ ' + result.UnitPrice);