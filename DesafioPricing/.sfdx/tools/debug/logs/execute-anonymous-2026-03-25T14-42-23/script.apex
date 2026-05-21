// 1. Pega o preço que você acabou de salvar
PricebookEntry pbe = [SELECT Id, UnitPrice, Product2Id FROM PricebookEntry 
                      WHERE Product2.Name LIKE '%Colheitadeira%' 
                      AND Pricebook2.IsStandard = true LIMIT 1];

// 2. Pega o seu pedido
Order ped = [SELECT Id, Pricebook2Id FROM Order WHERE OrderNumber = '00000100' LIMIT 1];

// 3. Insere o item direto no banco (sem usar a tela de busca do Salesforce)
OrderItem finalItem = new OrderItem(
    OrderId = ped.Id,
    Product2Id = pbe.Product2Id,
    PricebookEntryId = pbe.Id,
    Quantity = 1,
    UnitPrice = pbe.UnitPrice
);

insert finalItem;

System.debug('--- ✅ CONSEGUIMOS, SABRINA! O item foi inserido e a Trigger rodou! ---');