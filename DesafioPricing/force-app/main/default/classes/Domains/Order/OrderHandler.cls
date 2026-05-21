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
        validateStatusOrders();
        validateOrderItems();
        checkActiveOrder();
        //ainda preciso do checkActive order? atualiza ele para os novos status
    }
    
    public override void afterUpdate() {
        sendOfOrders();
        checkActiveOrder();
        itemsRecalculation();
    }
    
    public override void beforeDelete() {
        checkActiveOrder();
    }
    
    private void setDefaultStatus() {
        
        for(Order iOrder : newRecords) {
            
            if(String.isBlank(iOrder.Status)) {
                iOrder.Status = 'Novo';
            }
        }
    }
    
    //metodo para bloquear a mudança de CD/Endereço/Data/Conta se o pedido estiver ativo.
    public void checkActiveOrder() {
        List<Order> listToValidate;
        
        if (Trigger.isDelete) {
            listToValidate = oldRecords; //usa os registros antigos
        } else {
            listToValidate = newRecords; //se não estuver deletando usa os novos
        }
        
        
        for(Order iOrder: listToValidate) {
            //recupera a versão anterior para verificação
            Order oldOrder = (oldRecordsMap != null) ? oldRecordsMap.get(iOrder.Id) : null;
            
            //identifica o status de origem
            String validationStatus = (oldOrder != null) ? oldOrder.Status : iOrder.Status;
            
            if (validationStatus != 'Aprovado') {
                        iOrder.addError('Não é possivel fazer qualquer atualização do PEDIDO após este pedido ser aprovado.');
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
            
            if (iOrder.Status == 'Em aprovação' && oldOrder.Status != 'Em aprovação') {
                ordersToSend.add(iOrder.Id);
            }
        }
        
        if (!ordersToSend.isEmpty()) {
            CalloutOrderFuture.sendOrders(ordersToSend);
        }
    }
    
    private void validateStatusOrders() {
        for(Order iOrder : newRecords){
            Order oldOrder = oldRecordsMap.get(iOrder.Id);
            
            if(iOrder.Status != oldOrder.Status){
                if(oldOrder.status != 'Novo' || iOrder.Status != 'Em aprovação'){
                    iOrder.Status.addError('A única mudança de status permitida é de Novo para Em aprovação.');
                }
            }
        }
    }
    
    private void validateOrderItems(){
        List<Id> ordersIds = new List<Id>();
        
        for (Order iOrder : newRecords) {
            Order oldOrder = oldRecordsMap.get(iOrder.Id);
            
            if (iOrder.Status == 'Em aprovação' && oldOrder.Status != 'Em aprovação') {
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
                iOrder.Status.addError('O produto precisa possuir pelo menos um produto.');
            }
        }
        
    }
}