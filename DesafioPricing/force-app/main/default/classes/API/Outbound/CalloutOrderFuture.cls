public class CalloutOrderFuture {
    //o @future dis para executar separado da trigger, 
    //o callout=true diz que o metodo pode fazer chamadas externas, ou seja, callouts
    @future(callout=true)
    public static void sendOrders(List<String> orderIds) {
        CalloutOrder.executeCalloutOrder(orderIds);
    }
}