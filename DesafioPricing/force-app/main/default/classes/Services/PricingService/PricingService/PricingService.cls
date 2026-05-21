public class PricingService {
    
    public static void calculateFinalPrice(OrderItem orderItem, Decimal freightValueEntered, Margem__c margem, Decimal taxPercentEntered, Decimal unitCost) {
        Decimal margemPercent = (margem != null && margem.MarginValuePercent__c != null) ? margem.MarginValuePercent__c : 0;
        Decimal taxPercent = (taxPercentEntered != null) ? taxPercentEntered : 0;
        Decimal productionCost = (unitCost != null) ? unitCost : 0;
        Decimal freightValue = (freightValueEntered != null) ? freightValueEntered : 0;
        
        //preco base
        Decimal basePrice = productionCost + freightValue;
        
        //preco sem margem
        Decimal priceWithoutMargin = basePrice * (1 + (taxPercent / 100));
        
        //preco final
        Decimal calculatedPrice = priceWithoutMargin * (1 + (margemPercent / 100));
        
        // preenchimento
        orderItem.ProductionCost__c = productionCost;   
        orderItem.MarginPercentage__c = margemPercent;
        orderItem.FreightValue__c = freightValue;
        orderItem.TaxPercentage__c = taxPercent;
        orderItem.PriceWithoutMargin__c = priceWithoutMargin; // preco sem margem
        orderItem.FinalPrice__c = calculatedPrice; // preco final, orderItem pedido 

        //garante q o unitPrice não seja null
        Decimal unitPriceEntered = (orderItem.UnitPrice != null) ? orderItem.UnitPrice : 0;
        
        // D. Cálculo do Desconto (Percent)
        if (calculatedPrice > 0) {
            orderItem.DiscountPercentage__c = (calculatedPrice - unitPriceEntered) / calculatedPrice;
            orderItem.DiscountValue__c = calculatedPrice - unitPriceEntered;
        }
        
        orderItem.UnitPrice = orderItem.FinalPrice__c;
    }
}




