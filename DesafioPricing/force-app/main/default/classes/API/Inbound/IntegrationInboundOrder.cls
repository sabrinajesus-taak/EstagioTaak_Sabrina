@RestResource(urlMapping='/upsertOrder/*')
global with sharing class IntegrationInboundOrder {
    /**
     * FactoryDataIntegration Class => Valida campos obrigatórios e converte request para objeto
     * IntegrationUtils Class => Faz o dml dos registros (Upsert)
     * deletedOrderItem method => true => Apaga o OrderItem, false => Marca o OrderItem como deletado (Campo Boolean)
     */
    @HttpPost
    global static void upsertOrder(List<DataIntegrationFields.OrderINData> orderRequestList) {
        SavePoint savePoint = Database.setSavePoint();
        RestResponse response = RestContext.response;
        
        List<Order> orderToUpsertList = new List<Order>();
        String orderExternalIds = '';
        Map<String, String> orderExternalIdToOrderItem = new Map<String, String>();
        List<DataIntegrationFields.ResponseParent> orderResponseList = new List<DataIntegrationFields.ResponseParent>();
        Map<String, List<DataIntegrationFields.Response>> orderItemResponseList = new Map<String, List<DataIntegrationFields.Response>>();
        List<DataIntegrationFields.OrderItemINData> orderItemToUpsertList = new List<DataIntegrationFields.OrderItemINData>();
        String integrationLogId;
        
        try {
            orderItemToUpsertList = fillOrderItemListToUpsert(orderRequestList, orderExternalIdToOrderItem);
            
            orderExternalIds = FactoryDataIntegration.convertSObject(
                new Order(), 'IN', orderRequestList, orderResponseList, orderToUpsertList
                );
            
            IntegrationUtils.upsertRecords(
                Database.upsert(orderToUpsertList, Order.Fields.ExternalId__c, false), orderResponseList, orderToUpsertList, Order.Fields.ExternalId__c
                );
            
            Boolean hasDeleted = deletedOrderItem(orderItemToUpsertList, false);
            
            if (!orderItemToUpsertList.isEmpty()) {
                upsertOrderItem(orderItemToUpsertList, orderExternalIdToOrderItem, orderItemResponseList);
            }
            
            Boolean hasAnyError = false;
            if (!orderItemResponseList.isEmpty()) {
                hasAnyError = fillResponseList(orderResponseList, orderItemResponseList);
            }
            
            Integer statusCode = hasAnyError ? 400 : 200;
            if (!Test.isRunningTest()) {
                response.responseBody = Blob.valueOf(JSON.serialize(orderResponseList));
                response.statusCode = statusCode;
            }
            
            String errorMessage = hasAnyError ? getErrors(orderResponseList) : '';
            List<String> externalIdsList = new List<String>();
            if (String.isNotBlank(orderExternalIds)) {
                externalIdsList = orderExternalIds.split(', ');
            }
            integrationLogId = IntegrationLog.createLog(
                'Order',
            externalIdsList,
            'Inbound',
            JSON.serialize(orderRequestList),
            JSON.serialize(orderResponseList),
            errorMessage,
            System.Url.getOrgDomainUrl().toExternalForm() + '/services/apexrest/upsertOrder/*',
            statusCode,
            hasAnyError,
            hasDeleted,
            orderToUpsertList.isEmpty() ? null : orderToUpsertList[0].Id
                );
        }
        catch (Exception ex) {
            System.debug('Do Post Exception => ' + ex.getMessage() + ' - ' + ex.getStackTraceString());
            Database.rollback(savePoint);
            response.responseBody = Blob.valueOf(ex.getMessage());
            response.statusCode = 400;
        }
        
        if (!String.isBlank(integrationLogId)) {
            updateOrderWithIntegrationLogId(orderToUpsertList, integrationLogId, 'IN');
        }
    }
    
    public static List<DataIntegrationFields.OrderItemINData> fillOrderItemListToUpsert(
        List<DataIntegrationFields.OrderINData> orderRequestList, Map<String, String> orderExternalIdToOrderItemMap
    ) {
        List<DataIntegrationFields.OrderItemINData> orderItemToUpsertList = new List<DataIntegrationFields.OrderItemINData>();
        
        for (DataIntegrationFields.OrderINData order : orderRequestList){
            if (order.orderItemList != null) {
                for (DataIntegrationFields.OrderItemINData orderItemData : order.orderItemList) {
                    orderExternalIdToOrderItemMap.put(orderItemData.externalId, order.externalId);
                    orderItemData.orderExternalId = order.externalId;
                }
                
                orderItemToUpsertList.addAll(order.orderItemList);
            }
        }
        
        return orderItemToUpsertList;
    }
    
    public static void upsertOrderItem(
        List<DataIntegrationFields.OrderItemINData> orderItemRequestList, Map<String, String> orderExternalIdToOrderItem,
    Map<String, List<DataIntegrationFields.Response>> orderItemResponseList
    ) {
        List<OrderItem> orderItemToUpsertList = new List<OrderItem>();
        
        FactoryDataIntegration.convertSObjectChild(
            new OrderItem(), 'IN', orderItemRequestList, orderItemResponseList, orderItemToUpsertList
            );
        
        IntegrationUtils.upsertChildRecords(
            Database.upsert(orderItemToUpsertList, OrderItem.Fields.ExternalId__c, false),
        orderItemResponseList,
        orderItemToUpsertList,
        orderExternalIdToOrderItem,
        OrderItem.Fields.ExternalId__c
            );
    }
    
    public static Boolean deletedOrderItem(List<DataIntegrationFields.OrderItemINData> orderItemRequestList, Boolean willDeleted) {
        List<OrderItem> deleteOrderItemList = new List<OrderItem>();
        List<OrderItem> updateOrderItemList = new List<OrderItem>();
        Set<String> orderItemExternalIdSet = new Set<String>();
        Set<String> orderExternalIdSet = new Set<String>();
        
        for (DataIntegrationFields.OrderItemINData orderItemData : orderItemRequestList) {
            orderItemExternalIdSet.add(orderItemData.externalId);
            orderExternalIdSet.add(orderItemData.orderExternalId);
        }
        
        for (OrderItem orderItem : [
			SELECT Id, DeletedProduct__c
			  FROM OrderItem
			 WHERE ExternalId__c NOT IN: orderItemExternalIdSet
			   AND Order.ExternalId__c IN: orderExternalIdSet
			   AND DeletedProduct__c = false
		]) {
            if (willDeleted) deleteOrderItemList.add(orderItem);
            else {
                orderItem.DeletedProduct__c = true;
                updateOrderItemList.add(orderItem);
            }
        }
        
        if (!deleteOrderItemList.isEmpty()) delete deleteOrderItemList;
        if (!updateOrderItemList.isEmpty()) update updateOrderItemList;
        
        return (!deleteOrderItemList.isEmpty() || !updateOrderItemList.isEmpty());
    }
    
    public static Boolean fillResponseList(
        List<DataIntegrationFields.ResponseParent> orderResponseList,
    Map<String, List<DataIntegrationFields.Response>> orderItemResponseList
    ) {
        Boolean hasAnyError = false;
        
        for (DataIntegrationFields.ResponseParent response : orderResponseList) {
            response.items = new List<DataIntegrationFields.Response>();
            
            if (orderItemResponseList.containsKey(response.externalId)) {
                response.items.addAll(orderItemResponseList.get(response.externalId));
            }
            else if (orderItemResponseList.containsKey(response.salesforceId))
                response.items.addAll(orderItemResponseList.get(response.salesforceId));
            
            if (response.hasError) hasAnyError = true;
            else {
                for (DataIntegrationFields.Response responseItems : response.items) {
                    if (responseItems.hasError) {
                        hasAnyError = true;
                        break;
                    }
                }
            }
        }
        
        return hasAnyError;
    }
    
    public static String getErrors(List<DataIntegrationFields.ResponseParent> orderResponseList) {
        String errorMessage = '';
        
        for (DataIntegrationFields.ResponseParent orderResponse : orderResponseList) {
            Boolean hasError = false;
            String currentErrorMessage = '';
            
            if (orderResponse.hasError) {
                errorMessage += orderResponse.errorMessage + '. ';
            }
            
            for (DataIntegrationFields.Response item : orderResponse.items) {
                if (item.hasError) {
                    errorMessage += item.errorMessage + '. ';
                    currentErrorMessage += item.errorMessage + '. ';
                    hasError = true;
                }
            }
            
            orderResponse.hasError = hasError;
            orderResponse.errorMessage = orderResponse.errorMessage == null ?
                currentErrorMessage :
                orderResponse.errorMessage + '. ' + currentErrorMessage;
        }
        
        return errorMessage;
    }
    
    public static void updateOrderWithIntegrationLogId(List<Order> orderList, String integrationLogId, String integrationType) {
        try {
            List<Order> orderUpdateList = new List<Order>();
            
            // PASSO 1: Setar apenas o lookup
            for (Order order : orderList) {
                if (integrationType == 'IN') {
                    order.IntegrationLogInbound__c = integrationLogId;
                } else {
                    order.IntegrationLogOutbound__c = integrationLogId;
                }
                orderUpdateList.add(order);
            }
            
            if (!orderUpdateList.isEmpty()) update orderUpdateList;
            
            // PASSO 2: REQUERY para obter o Status__c do IntegrationLog
            IntegrationLog__c logQuery = [
            SELECT Status__c 
            FROM IntegrationLog__c 
            WHERE Id = :integrationLogId 
            LIMIT 1
        ];
            
            System.debug('IntegrationLog Status: ' + logQuery.Status__c);
            
            // PASSO 3: Atualizar Status da Order baseado no Status do Log
            List<Order> orderStatusUpdateList = new List<Order>();
            for (Order order : orderList) {
                Order updateOrder = new Order(Id = order.Id);
                
                if (logQuery.Status__c == 'Error') {
                    updateOrder.Status = 'IntegrationError';
                } else {
                    updateOrder.Status = 'Integrated';
                }
                
                orderStatusUpdateList.add(updateOrder);
            }
            
            if (!orderStatusUpdateList.isEmpty()) update orderStatusUpdateList;
            
        } catch (Exception ex) {
            System.debug(ex.getMessage() + ' - ' + ex.getStackTraceString());
            throw ex;  
        }
    }
    
    public class CustomException extends Exception {}
}