List<Product2> produtos = new List<Product2>();

for (Integer i = 0; i < 10; i++) {
    produtos.add(new Product2 (
        Name = 'Produto teste' + i,
        IsActive = true
    ));
}

insert produtos; //para disparar a trigger


Integer contaEntradas = [SELECT COUNT() FROM PricebookEntry WHERE Product2Id IN :produtos];
System.debug('Quantidade de entradas criadas: ' + contaEntradas);

List<PricebookEntry> entradas = [SELECT Id, Product2.Name, UnitPrice, CurrencyIsoCode 
                                FROM PricebookEntry 
                                WHERE Product2Id IN :produtos];

if(entradas.isEmpty()) {
    System.debug('ERRO: Nenhuma entrada de catálogo foi encontrada para esses produtos.');
} else {
    for(PricebookEntry pbe : entradas) {
        System.debug('Produto: ' + pbe.Product2.Name + ' | Moeda: ' + pbe.CurrencyIsoCode);
    }
}

System.debug('Teste');