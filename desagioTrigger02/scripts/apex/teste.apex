List<Product2> produtos = new List<Product2>();

for (Integer i = 0; i < 10; i++) {
    produtos.add(new Product2 (
        Name = 'Produto teste' + i,
        IsActive = true
    ));
}

insert produtos; //para disparar a trigger


List<PricebookEntry> entradas = [SELECT Id, Product2.Name, UnitPrice, CurrencyIsoCode 
                                 FROM PricebookEntry 
                                 WHERE Product2Id IN :produtos];

System.debug('--- RESULTADO DO TESTE ---');
System.debug('Produtos inseridos: ' + produtos.size());
System.debug('Entradas de preço criadas: ' + entradas.size());

if(entradas.isEmpty()) {
    System.debug('ERRO: O Handler não criou as entradas. Verifique se a Trigger está ativa!');
} else {
    for(PricebookEntry pbe : entradas) {
        System.debug('Sucesso -> Produto: ' + pbe.Product2.Name + 
                     ' | Moeda: ' + pbe.CurrencyIsoCode + 
                     ' | Preço: ' + pbe.UnitPrice);
    }
}

System.debug('--- FIM DO TESTE ---');