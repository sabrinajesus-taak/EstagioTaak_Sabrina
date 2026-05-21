// 1. Pega a tabela Standard real da sua Org
Id standardPBId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;

// 2. Pega o preço da Colheitadeira que você acabou de criar
PricebookEntry pbe = [SELECT Id, UnitPrice, Product2Id FROM PricebookEntry 
                      WHERE Product2.Name LIKE '%Colheitadeira%' 
                      AND Pricebook2Id = :standardPBId AND IsActive = true LIMIT 1];

// 3. Pega o seu pedido e ATUALIZA ele para usar a tabela certa
Order ped = [SELECT Id, Pricebook2Id FROM Order WHERE OrderNumber = '00000100' LIMIT 1];
ped.Pricebook2Id = standardPBId;
update ped; // Agora o Pedido e o Produto estão na mesma "família"

// 4. Insere o item direto
OrderItem finalItem = new OrderItem(
    OrderId = ped.Id,
    Product2Id = pbe.Product2Id,
    PricebookEntryId = pbe.Id,
    Quantity = 1,
    UnitPrice = pbe.UnitPrice
);

insert finalItem;

// 5. O GRAN FINALE: Ver o resultado calculado pela sua Trigger!
OrderItem result = [SELECT MarginPercentage__c, UnitPrice, FreightValue__c FROM OrderItem WHERE Id = :finalItem.Id];

System.debug('--- 🏆 FINALMENTE, SABRINA! VOCÊ VENCEU! ---');
System.debug('Margem calculada: ' + result.MarginPercentage__c + '%');
System.debug('Preço final: R$ ' + result.UnitPrice);