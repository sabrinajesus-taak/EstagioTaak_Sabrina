public class OrderHandler extends TriggerHandler {
    
    private List<Order> newRecords;
    private List<Order> oldRecords;
    private Map<Id, Order> newRecordsMap;
    private Map<Id, Order> oldRecordsMap;
    
    public OrderHandler() {
        super('OrderHandler');
        this.newRecords = (List<Order>) Trigger.new;
        this.oldRecords = (List<Order>) Trigger.old;
        this.newRecordsMap = (Map<Id, Order>) Trigger.newMap;
        this.oldRecordsMap = (Map<Id, Order>) Trigger.oldMap;
    }
    
    public override void beforeInsert() {
        setDefaultStatus();
    }
    
    public override void beforeUpdate(){
        validateOrderItems();
        checkActiveOrder();
        //ainda preciso do checkActive order? atualiza ele para os novos status
    }
    
    public override void afterUpdate() {
        sendOfOrders();
        // checkActiveOrder();
        itemsRecalculation();
    }
    
    public override void beforeDelete() {
        checkActiveOrder();
    }
    
    private void setDefaultStatus() {
        
        for(Order iOrder : newRecords) {
            
            if(String.isBlank(iOrder.Status)) {
                iOrder.Status = 'New';
            }
        }
    }
    
    //metodo para bloquear a mudança de CD/Endereço/Data/Conta se o pedido estiver ativo.
    public void checkActiveOrder() {
        
        if(Trigger.isInsert){
            return;
        }
        
        if(TriggerHandler.isBypassed('OrderHandler')){
            return;
        }
        
        for(Order iOrder : newRecords){
            
            Order oldOrder = oldRecordsMap.get(iOrder.Id);
            
            if(oldOrder == null){
                continue;
            }

            if(oldOrder.Status == 'New'){
                continue;
            }
            
            //variavel for status update only
             Boolean onlyStatusChanged =

            iOrder.AccountId == oldOrder.AccountId &&
            iOrder.Pricebook2Id == oldOrder.Pricebook2Id &&
            iOrder.DeliveryDate__c == oldOrder.DeliveryDate__c &&
            iOrder.PaymentCondition__c == oldOrder.PaymentCondition__c &&
            iOrder.DistributionCenter__c == oldOrder.DistributionCenter__c &&
            iOrder.AccountAddress__c == oldOrder.AccountAddress__c &&
            iOrder.EffectiveDate == oldOrder.EffectiveDate;

            if(!onlyStatusChanged){
                 iOrder.addError('Só é possível editar pedidos com status "New".');
            }
        }
    }
    
    //metodo para recalculcar com nova localização
    private void itemsRecalculation() {
        Set<Id> ordersToRecalculate = new Set<Id>();
        
        for (Order iOrder : newRecords) {
            Order oldOrder = oldRecordsMap.get(iOrder.Id);
            
            if (iOrder.City__c != oldOrder.City__c ||
                iOrder.State__c != oldOrder.State__c ||
            iOrder.Country__c != oldOrder.Country__c) {
                ordersToRecalculate.add(iOrder.Id);
            }
        }
        
        if (!ordersToRecalculate.isEmpty()) {
            List<OrderItem> items = OrderItemSelector.getByOrderIds(ordersToRecalculate);
            
            if (!items.isEmpty()) {
                update items;
            }
        }
    }
    
    //method to send orders to Livia
    private void sendOfOrders(){
        List<Id> ordersToSend = new List<Id>();
        
        for (Order iOrder : newRecords) {
            Order oldOrder = oldRecordsMap.get(iOrder.Id);
            
            if (iOrder.Status == 'Approved' && oldOrder.Status != 'Approved') {
                ordersToSend.add(iOrder.Id);
            }
        }
        
        if (!ordersToSend.isEmpty()) {
            CalloutOrderFuture.sendOrders(ordersToSend);
        }
    }
    
    // private void validateStatusOrders() {
    //     for(Order iOrder : newRecords){
    //         Order oldOrder = oldRecordsMap.get(iOrder.Id);
            
    //         //se new for o anterior, o proximo e apenas pendding approval...
            
    //         if(iOrder.Status != oldOrder.Status){
    //                 if(oldOrder.status != 'New' || iOrder.Status != 'PendingApproval'){
    //                         iOrder.Status.addError('A única mudança de status permitida é de Novo para Em aprovação.');
    //                 }
    //         }
    //     }
    // }
    
    private void validateOrderItems(){
        List<Id> ordersIds = new List<Id>();
        
        for (Order iOrder : newRecords) {
            Order oldOrder = oldRecordsMap.get(iOrder.Id);
            
            if (iOrder.Status == 'PendingApproval' && oldOrder.Status != 'PendingApproval') {
                ordersIds.add(iOrder.Id);
            }
        }
        
        if(ordersIds.isEmpty()) return;
        
        Set<Id> ordersWithItems = new Set<Id>();
        
        for(OrderItem item : [
        SELECT Id, OrderId
        FROM OrderItem
        WHERE OrderId IN :ordersIds]) {
            ordersWithItems.add(item.OrderId);
        }
        for (Order iOrder : newRecords){
            if(ordersIds.contains(iOrder.Id) && !ordersWithItems.contains(iOrder.Id)){
                iOrder.Status.addError('O PEDIDO precisa possuir pelo menos um produto.');
            }
        }
        
    }
}