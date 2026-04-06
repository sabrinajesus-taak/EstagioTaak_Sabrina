public class PricingService {
    
    //Frete - Especificações (Produto > Hierarquia | Cidade > Estado > Pais)
    public static Decimal findFreightValue(OrderItem item, Order pedido, Map<String, Freight__c> mapFrete, Id h) {
        Id p = item.Product2Id; //produto
        Id c = pedido.City__c; //cidade
        Id e = pedido.State__c; //estado
        Id pa = pedido.Country__c; //pais
        
        if (mapFrete.containsKey(p + '_' + c)) return mapFrete.get(p + '_' + c).FreightValue__c;
        if (mapFrete.containsKey(p + '_' + e)) return mapFrete.get(p + '_' + e).FreightValue__c;
        if (mapFrete.containsKey(p + '_' + pa)) return mapFrete.get(p + '_' + pa).FreightValue__c;
        if (mapFrete.containsKey(h + '_' + c)) return mapFrete.get(h + '_' + c).FreightValue__c;
        if (mapFrete.containsKey(h + '_' + e)) return mapFrete.get(h + '_' + e).FreightValue__c;
        if (mapFrete.containsKey(h + '_' + pa)) return mapFrete.get(h + '_' + pa).FreightValue__c;
        
        return 0;
    }
    
    //Margem - Especificações (Produto > Hierarquia | Cliente > Grupo de Contas | cidade> estado > País)
    public static Margem__c findMargin(OrderItem item, Order pedido, Map<String, Margem__c> mapMargin, Id h, Account cliente) {
        Id p = item.Product2Id; //produto
        Id a = pedido.AccountId; //account
        Id g = cliente.AccountGroup__c; //grupo e contas
        Id c = pedido.City__c; //cidade
        Id e = pedido.State__c; //estado
        Id pa = pedido.Country__c; //pais
        
        
        if (mapMargin.containsKey(p + '_' + a + '_' + c)) return mapMargin.get(p + '_' + a + '_' + c);
        if (mapMargin.containsKey(p + '_' + a + '_' + e)) return mapMargin.get(p + '_' + a + '_' + e);
        if (mapMargin.containsKey(p + '_' + a + '_' + pa)) return mapMargin.get(p + '_' + a + '_' + pa);
        if (mapMargin.containsKey(p + '_' + g + '_' + c)) return mapMargin.get(p + '_' + g + '_' + c);
        if (mapMargin.containsKey(p + '_' + g + '_' + e)) return mapMargin.get(p + '_' + g + '_' + e);
        if (mapMargin.containsKey(p + '_' + g + '_' + pa)) return mapMargin.get(p + '_' + g + '_' + pa);
        
        if (mapMargin.containsKey(h + '_' + a + '_' + c)) return mapMargin.get(h + '_' + a + '_' + c);
        if (mapMargin.containsKey(h + '_' + a + '_' + e)) return mapMargin.get(h + '_' + a + '_' + e);
        if (mapMargin.containsKey(h + '_' + a + '_' + pa)) return mapMargin.get(h + '_' + a + '_' + pa);
        if (mapMargin.containsKey(h + '_' + g + '_' + c)) return mapMargin.get(h + '_' + g + '_' + c);
        if (mapMargin.containsKey(h + '_' + g + '_' + e)) return mapMargin.get(h + '_' + g + '_' + e);
        if (mapMargin.containsKey(h + '_' + g + '_' + pa)) return mapMargin.get(h + '_' + g + '_' + pa);
        
        return new Margem__c(MarginValuePercent__c = 0);
    }
    
    public static void calculateFinalPrice(OrderItem item, Decimal frete, Margem__c margem, Decimal impostoPercent, Decimal custo) {
        Decimal mPerc = (margem != null && margem.MarginValuePercent__c != null) ? margem.MarginValuePercent__c : 0;
        Decimal iPerc = (impostoPercent != null) ? impostoPercent : 0;
        Decimal custoProd = (custo != null) ? custo : 0;
        Decimal freteVal = (frete != null) ? frete : 0;
        
        //preco base
        Decimal precoBase = custoProd + freteVal;
        
        //preco sem margem
        Decimal precoSemMargem = precoBase * (1 + (iPerc / 100));
        
        //preco final
        Decimal precoCalculado = precoSemMargem * (1 + (mPerc / 100));
        
        // preenchimento
        item.ProductionCost__c = custoProd;   
        item.MarginPercentage__c = mPerc;
        item.FreightValue__c = freteVal;
        item.TaxPercentage__c = iPerc;
        item.PriceWithoutMargin__c = precoSemMargem; // preco sem margem
        item.FinalPrice__c = precoCalculado; // preco final, item pedido 

        //garante q o unitPrice não seja null
        Decimal unitPriceDigitado = (item.UnitPrice != null) ? item.UnitPrice : 0;
        
        // D. Cálculo do Desconto (Percent)
        if (precoCalculado > 0) {
            item.DiscountPercentage__c = (precoCalculado - unitPriceDigitado) / precoCalculado;
            item.DiscountValue__c = precoCalculado - unitPriceDigitado;
        }
        
        item.UnitPrice = item.FinalPrice__c;
    }
}