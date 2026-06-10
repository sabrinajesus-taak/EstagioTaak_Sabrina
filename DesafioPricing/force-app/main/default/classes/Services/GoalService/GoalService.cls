public class GoalService {
    
    public String buildKey(Id sellerId, Id referenceId) {
        return String.valueOf(sellerId) + '-' + String.valueOf(referenceId);
    }
    
    public List<GoalItem__c> calculateRealizedValue(List<GoalItem__c> goalItems){
        
        Set<Id> sellerIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> hierarchyIds = new Set<Id>();
        Set<Id> paymentConditionIds = new Set<Id>();
        
        Map<String, Decimal> sellerAndProduct = new Map<String, Decimal>();
        Map<String, Decimal> sellerAndHierarchy = new Map<String, Decimal>();
        Map<String, Decimal> sellerAndPaymentCondition = new Map<String, Decimal>();
        Map<String, Decimal> sellerTotalSales = new Map<String, Decimal>();
        
        Map<String, Decimal> sellerAndProductNegotiated = new Map<String, Decimal>();
        Map<String, Decimal> sellerAndHierarchyNegotiated = new Map<String, Decimal>();
        Map<String, Decimal> sellerAndPaymentConditionNegotiated = new Map<String, Decimal>();
        Map<String, Decimal> sellerTotalSalesNegotiated = new Map<String, Decimal>();
        
        List<GoalItem__c> changedGoalItems = new List<GoalItem__c>();
        
        for (GoalItem__c iGoalItem : goalItems) {
            
            if(iGoalItem.Goal__r.User__c != null){
                sellerIds.add(iGoalItem.Goal__r.User__c);
            }
            
            if(iGoalItem.Product__c != null){
                productIds.add(iGoalItem.Product__c);
            }
            
            if(iGoalItem.ProductHierarchy__c != null){
                hierarchyIds.add(iGoalItem.ProductHierarchy__c);
            }
            
            if(iGoalItem.PaymentCondition__c != null){
                paymentConditionIds.add(iGoalItem.PaymentCondition__c);
            }
        }
        
        List<Order> orders = [
            SELECT Id, Status, OwnerId
            FROM Order
            WHERE OwnerId IN :sellerIds];
        
        Set<Id> orderIds = new Set<Id>();
        Set<Id> orderIdsApproved = new Set<Id>();
        
        for(Order iOrder : orders){
            if(iOrder.Status == 'Integrated') {
                orderIdsApproved.add(iOrder.Id);
            }
            orderIds.add(iOrder.Id);
        }
        
        List<OrderItem> orderItems = [SELECT Id, OrderId, Product2Id, FinalTotal__c, Order.OwnerId, Product2.ProductHierarchy__c, Order.PaymentCondition__c FROM OrderItem WHERE OrderId IN :orderIds];
        System.debug(orderItems);
        
        //------------------------------------------------------------------------------------------------
        
        String keyUser;
        String keyUserProduct;
        String keyUserProductFamily;
        String keyUserPaymentCondition;
        
        Decimal currentUser;
        Decimal currentValueProduct;
        Decimal currentValueProductFamily;
        Decimal currentValuePaymentCondition;
        
        for(OrderItem oi : orderItems){
            System.debug(
                'OrderItem=' + oi.Id +
                ' Product=' + oi.Product2Id +
                ' FinalTotal=' + oi.FinalTotal__c +
                ' Hierarchy=' + oi.Product2.ProductHierarchy__c +
                ' Payment=' + oi.Order.PaymentCondition__c
                );
        }
        
        for(OrderItem iOrderItem : orderItems) {
            
            Boolean isIntegrated = orderIdsApproved.contains(iOrderItem.OrderId);
            Decimal itemValue = iOrderItem.FinalTotal__c == null ? 0 : iOrderItem.FinalTotal__c;
            
            keyUser = String.valueOf(iOrderItem.Order.OwnerId);
            keyUserProduct = buildKey(iOrderItem.Order.OwnerId, iOrderItem.Product2Id);
            keyUserProductFamily = buildKey(iOrderItem.Order.OwnerId, iOrderItem.Product2.ProductHierarchy__c);
            keyUserPaymentCondition = buildKey(iOrderItem.Order.OwnerId, iOrderItem.Order.PaymentCondition__c);
            
            if(isIntegrated) {
                
                System.debug('Pedidos Integrados');
                
                if(sellerTotalSales.containsKey(keyUser)) {
                    
                    currentUser = sellerTotalSales.get(keyUser);
                    sellerTotalSales.put(keyUser, (currentUser + itemValue));
                    
                    System.debug('keyUser=' + keyUser);
                    System.debug('currentUser=' + currentUser);
                    System.debug('FinalTotal=' + itemValue);
                    
                } else{
                    sellerTotalSales.put(keyUser, itemValue);
                }
                
                if(sellerAndProduct.containsKey(keyUserProduct)) {
                    
                    currentValueProduct = sellerAndProduct.get(keyUserProduct);
                    sellerAndProduct.put(keyUserProduct, (currentValueProduct + itemValue));
                    
                    System.debug('keyUser=' + keyUser);
                    System.debug('currentUser=' + currentUser);
                    System.debug('FinalTotal=' + itemValue);
                    
                } else{
                    sellerAndProduct.put(keyUserProduct, itemValue);
                }
                
                if(sellerAndHierarchy.containsKey(keyUserProductFamily)) {
                    
                    currentValueProductFamily = sellerAndHierarchy.get(keyUserProductFamily);
                    sellerAndHierarchy.put(keyUserProductFamily, (currentValueProductFamily + itemValue));
                    
                    System.debug('keyUser=' + keyUser);
                    System.debug('currentUser=' + currentUser);
                    System.debug('FinalTotal=' + itemValue);
                    
                } else{
                    sellerAndHierarchy.put(keyUserProductFamily, itemValue);
                }
                
                if(sellerAndPaymentCondition.containsKey(keyUserPaymentCondition)) {
                    
                    currentValuePaymentCondition = sellerAndPaymentCondition.get(keyUserPaymentCondition);
                    sellerAndPaymentCondition.put(keyUserPaymentCondition, (currentValuePaymentCondition + itemValue));
                    
                    System.debug('keyUser=' + keyUser);
                    System.debug('currentUser=' + currentUser);
                    System.debug('FinalTotal=' + itemValue);
                    
                } else{
                    sellerAndPaymentCondition.put(keyUserPaymentCondition, itemValue);
                }
                
            } else {
                System.debug('Pedidos não integrados');
                
                
                if(sellerTotalSalesNegotiated.containsKey(keyUser)) {
                    
                    currentUser = sellerTotalSalesNegotiated.get(keyUser);
                    sellerTotalSalesNegotiated.put(keyUser, (currentUser + itemValue));
                    
                    System.debug('keyUser=' + keyUser);
                    System.debug('currentUser=' + currentUser);
                    System.debug('FinalTotal=' + itemValue);
                    
                } else{
                    sellerTotalSalesNegotiated.put(keyUser, itemValue);
                }
                
                if(sellerAndProductNegotiated.containsKey(keyUserProduct)) {
                    
                    currentValueProduct = sellerAndProductNegotiated.get(keyUserProduct);
                    sellerAndProductNegotiated.put(keyUserProduct, (currentValueProduct + itemValue));
                    
                    System.debug('keyUser=' + keyUser);
                    System.debug('currentUser=' + currentUser);
                    System.debug('FinalTotal=' + itemValue);
                    
                } else{
                    sellerAndProductNegotiated.put(keyUserProduct, itemValue);
                }
                
                if(sellerAndHierarchyNegotiated.containsKey(keyUserProductFamily)) {
                    
                    currentValueProductFamily = sellerAndHierarchyNegotiated.get(keyUserProductFamily);
                    sellerAndHierarchyNegotiated.put(keyUserProductFamily, (currentValueProductFamily + itemValue));
                    
                    System.debug('keyUser=' + keyUser);
                    System.debug('currentUser=' + currentUser);
                    System.debug('FinalTotal=' + itemValue);
                    
                } else{
                    sellerAndHierarchyNegotiated.put(keyUserProductFamily, itemValue);
                }
                
                if(sellerAndPaymentConditionNegotiated.containsKey(keyUserPaymentCondition)) {
                    
                    currentValuePaymentCondition = sellerAndPaymentConditionNegotiated.get(keyUserPaymentCondition);
                    sellerAndPaymentConditionNegotiated.put(keyUserPaymentCondition, (currentValuePaymentCondition + itemValue));
                    
                    System.debug('keyUser=' + keyUser);
                    System.debug('currentUser=' + currentUser);
                    System.debug('FinalTotal=' + itemValue);
                    
                } else{
                    sellerAndPaymentConditionNegotiated.put(keyUserPaymentCondition, itemValue);
                }
                
            }
            
        }
        
        //----------------------------------------------------------------------------------------------
        
        String keyUserGoal;
        for(GoalItem__c iGoalItem : goalItems) {
            
            String recordTypeName = iGoalItem.RecordType.Name;
            
            switch on recordTypeName {
                
                
                when 'Product'{
                    System.debug('Entrou no product');
                    keyUserGoal = buildKey(iGoalItem.Goal__r.User__c, iGoalItem.Product__c);
                    
                    if(sellerAndProduct.containsKey(keyUserGoal)) {
                        iGoalItem.RealizedValue__c = sellerAndProduct.get(keyUserGoal);
                    } else {
                        iGoalItem.RealizedValue__c = 0;
                    }
                    
                    if(sellerAndProductNegotiated.containsKey(keyUserGoal)) {
                        iGoalItem.NegotiatedValue__c = sellerAndProductNegotiated.get(keyUserGoal);
                    } else {
                        iGoalItem.NegotiatedValue__c = 0;
                    }
                    changedGoalItems.add(iGoalItem);
                    
                }
                
                when 'ProductFamily' {
                    System.debug('Entrou no family');
                    keyUserGoal = buildKey(iGoalItem.Goal__r.User__c, iGoalItem.ProductHierarchy__c);
                    
                    if(sellerAndHierarchy.containsKey(keyUserGoal)) {
                        iGoalItem.RealizedValue__c = sellerAndHierarchy.get(keyUserGoal);
                    } else {
                        iGoalItem.RealizedValue__c = 0;
                    }
                    
                    if(sellerAndHierarchyNegotiated.containsKey(keyUserGoal)) {
                        iGoalItem.NegotiatedValue__c = sellerAndHierarchyNegotiated.get(keyUserGoal);
                    } else {
                        iGoalItem.NegotiatedValue__c = 0;
                    }
                    changedGoalItems.add(iGoalItem);
                    
                }
                
                when 'Performance' {
                    System.debug('Entrou no performance');
                    
                    keyUserGoal = String.valueOf(iGoalItem.Goal__r.User__c);
                    
                    if(sellerTotalSales.containsKey(keyUserGoal)) {
                        iGoalItem.RealizedValue__c = sellerTotalSales.get(keyUserGoal);
                    } else {
                        iGoalItem.RealizedValue__c = 0;
                    }
                    
                    if(sellerTotalSalesNegotiated.containsKey(keyUserGoal)) {
                        iGoalItem.NegotiatedValue__c = sellerTotalSalesNegotiated.get(keyUserGoal);
                    } else {
                        iGoalItem.NegotiatedValue__c = 0;
                    }
                    changedGoalItems.add(iGoalItem);
                    
                }
                
                when 'PaymentCondition' {
                    System.debug('Entrou no payment');
                    keyUserGoal = buildKey(iGoalItem.Goal__r.User__c, iGoalItem.PaymentCondition__c);
                    
                    if(sellerAndPaymentCondition.containsKey(keyUserGoal)) {
                        iGoalItem.RealizedValue__c = sellerAndPaymentCondition.get(keyUserGoal);
                    } else {
                        iGoalItem.RealizedValue__c = 0;
                    }
                    
                    if(sellerAndPaymentConditionNegotiated.containsKey(keyUserGoal)) {
                        iGoalItem.NegotiatedValue__c = sellerAndPaymentConditionNegotiated.get(keyUserGoal);
                    } else {
                        iGoalItem.NegotiatedValue__c = 0;
                    }
                    changedGoalItems.add(iGoalItem);
                }
            }
        }
        
        calculateSalesValue(sellerTotalSales, goalItems);

        return changedGoalItems;
    }
    
    
    public void calculateAchievedPercentage(List<GoalItem__c> goalItems) {
        
        for(GoalItem__c iGoalItem : goalItems) {
            if(iGoalItem.RealizedValue__c >= iGoalItem.ValueGoal__c) {
                iGoalItem.AchievedPercentage__c = iGoalItem.GoalCommissionPercentage__c;
            } else {
                iGoalItem.AchievedPercentage__c = 0;
            }
        }
    }

    public void calculateSalesValue(Map<String, Decimal> sellerTotalSales, List<GoalItem__c> goalItems){

        Set<Id> goalIds = new Set<Id>();
        List<Goal__c> changedGoals = new List<Goal__c>();

        for(GoalItem__c iGoalItem : goalItems) {
            if(!goalIds.contains(iGoalItem.Goal__c)) {
                goalIds.add(iGoalItem.Goal__c);
            }
        }

        List<Goal__c> goals = [SELECT Id, User__c, SalesValue__c FROM Goal__c WHERE Id IN :goalIds];

        for(Goal__c iGoal : goals) {
            Id user = iGoal.User__c;
            if(sellerTotalSales.containsKey(String.valueOf(user))){
                iGoal.SalesValue__c = iGoal.SalesValue__c != null ? sellerTotalSales.get(String.valueOf(user)) : 0;
                changedGoals.add(iGoal);
            }
        }

        update changedGoals;

    }
    
    public void updateGoalItems(List<GoalItem__c> goalItems) {
        update goalItems;
    }
    
    
}