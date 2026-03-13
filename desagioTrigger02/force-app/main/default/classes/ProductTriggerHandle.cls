public with sharing class ProductTriggerHandle {
    //não é obrigatório ter contrutor ou atributos
    
    //o campo que liga a moeda ao PricebookEntry se chama CurrencyIsoCode
    
    public static void createStandardPricebookEntries (List<Product2> newProducts) {
        List<Pricebook2> havePricebook = new List<Pricebook2>([SELECT Id FROM Pricebook2 WHERE IsStandard = true]); //isStandard - saber se está ativa

        List<CurrencyType> haveCurrency = new List<CurrencyType>([SELECT IsoCode FROM CurrencyType WHERE IsActive = true]);
    
        List<PricebookEntry> newPricebook = new List<PricebookEntry>();
        
        for(Product2 p: newProducts) {
            for (CurrencyType moeda: haveCurrency) {
                //criando o registro
                PricebookEntry pb = new PricebookEntry(); //precisa estar em produto e catalogo
                
                //é orbigatório preencher os campos
                pb.Product2Id = p.Id; //liga com o produto do loop
                pb.Pricebook2Id = havePricebook[0].Id;//qual é o catalogo? ao q pertence? - pega exatamente o pricebook padrão
                pb.UnitPrice = 0;
                pb.IsActive = true;
                
                pb.CurrencyIsoCode = moeda.IsoCode;
                
                //adicionar a lista para subir tudo de uma vez
                newPricebook.add(pb);
            }
        }

        insert newPricebook;
    }
}