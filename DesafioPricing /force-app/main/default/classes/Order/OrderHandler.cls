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
    
    public override void beforeUpdate(){
        checkActiveOrder();
    }
    
    public override void beforeDelete() {
        checkActiveOrder();
    }
    
    //metodo para bloquear a mudança de CD/Endereço/Data/Conta se o pedido estiver ativo.
    public void checkActiveOrder() {
        List<Order> listaParaValidar;
        
        if (Trigger.isDelete) {
            listaParaValidar = oldRecords; //usa os registros antigos
        } else {
            listaParaValidar = newRecords; //se não estuver deletando usa os novos
        }
        
        
        for(Order pedido: listaParaValidar) {
            //recupera a versão anterior para verificação
            Order pedidoAntigo = (oldRecordsMap != null) ? oldRecordsMap.get(pedido.Id) : null;
            
            //identifica o status de origem
            String validacaoStatus = (pedidoAntigo != null) ? pedidoAntigo.Status : pedido.Status;
            
            if (validacaoStatus != 'Draft') {
                pedido.addError('Não é possivel fazer qualquer atualização do PEDIDO após este pedido estar Ativo.');
            }  
        }
    }
}