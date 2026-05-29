public with sharing class OrderIntegrationController {
    
    @AuraEnabled
    public static String sendOrder(Id orderId){
        try{
            List<String> ids = new List<String>{String.valueOf(orderId)};
            
            DataIntegrationFields.CalloutResponse response =
                CalloutOrder.executeCalloutOrder(ids);
            
            return response.hasError ? 'Erro na integração' : 'Pedido Integrado';
            
        } catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
}