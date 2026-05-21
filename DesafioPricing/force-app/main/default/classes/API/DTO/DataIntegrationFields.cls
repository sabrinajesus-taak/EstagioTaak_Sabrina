global with sharing class DataIntegrationFields {
	public interface FieldData {
		List<String> getRequiredFields();
		String getFieldKey();
		String getFieldId();
		String getExternalId();
		SObject deserialize();
	}

	public interface FieldDataChild {
		List<String> getRequiredFields();
		String getFieldId();
		String getFieldExternal();
		String getParentId();
		String getParentKey();
		SObject deserialize();
	}

	//ou faço um select ou faço addres.City__c se ele mandar o obj inteiro
	global class OrderINData implements FieldData { // extends OrderBase
		public String externalId;
		public String status;
		public Date effectiveDate;
		public Date deliveryDate;
		public String shippingType;
		public String accountExternalId;
		public String pricebook2ExternalId;
		public String distributionCenter;
		public String cityExternalId;
		public String stateExternalId;
		public String countryExternalId;
		public String paymentTerms;

		public List<OrderItemINData> orderItemList {get; set;}

		public Order deserialize() {
			return new Order(
				ExternalId__c	= this.externalId,
				Status			= this.status,
				EffectiveDate	= this.effectiveDate,
				DeliveryDate__c	= this.deliveryDate,
				FreightType__c	= this.shippingType,
				Account			= new Account(ExternalId__c = this.accountExternalId),
				Pricebook2		= new Pricebook2(ExternalId__c = this.pricebook2ExternalId),
				DistributionCenter__r = new DistributionCenter__c(ExternalId__c = this.distributionCenter),
				City__r         = new City__c(ExternalId__c = this.cityExternalId),
				State__r        = new State__c(ExternalId__c = this.stateExternalId),
				Country__r      = new Country__c(ExternalId__c = this.countryExternalId),
				PaymentCondition__r = new PaymentCondition__c(ExternalId__c = this.paymentTerms)
			);
		}

		public List<String> getRequiredFields() {
			return new List<String>{
				'ExternalId__c',
				'EffectiveDate',
				'Status'
			};
		}
		public List<String> getRequiredLookups() {
			return new List<String>{
				'AccountId',
				'Pricebook2Id'
			};
		}

		public String getFieldKey() {
			return 'ExternalId__c';
		}
		public String getFieldId() {
			return 'Id';
		}
		public String getExternalId() {
			return this.externalId;
		}
	}
	global class OrderItemINData implements FieldDataChild { // extends OrderItemBase
		public String id;
		public String externalId;
		public Decimal quantity;
		public Decimal unitPrice;
		public String orderExternalId;
		public String productExternalId;
		public String pricebookEntryExternalId;

		public OrderItem deserialize() {
			OrderItem orderItem = new OrderItem(
				ExternalId__c	= this.externalId,
				Quantity		= this.quantity,
				UnitPrice		= this.unitPrice
			);

			if (this.id == null || this.id == '') {
				orderItem.Order				= new Order(ExternalId__c = this.orderExternalId);
				orderItem.Product2			= new Product2(ExternalId__c = this.productExternalId);
				orderItem.PricebookEntry	= new PricebookEntry(ExternalId__c = this.pricebookEntryExternalId);
			}
			else orderItem.Id = this.id;

			return orderItem;
		}

		public List<String> getRequiredFields() {
			return new List<String>{
				'UnitPrice',
				'Quantity',
				'ExternalId__c'
			};
		}
		public List<String> getRequiredLookups() {
			return new List<String>{
				'OrderId',
				'Product2Id',
				'PricebookEntryId'
			};
		}

		public String getFieldId() {
			return 'Id';
		}
		public String getFieldExternal() {
			return 'ExternalId__c';
		}
		public String getParentId() {
			return 'OrderId';
		}
		public String getParentKey() {
			return this.orderExternalId;
		}
	}

	global virtual class Response {
		public String salesforceId;
		public String externalId;
		public String sobjectType;
		public Boolean hasError;
		public String errorMessage;

		public void success(String salesforceId, String externalId, String sobjectType){
			this.salesforceId	= salesforceId;
			this.externalId		= externalId;
			this.sobjectType	= sobjectType;
			this.hasError		= false;
		}

		public void error(String externalId, String errorMessage, String sobjectType){
			this.externalId		= externalId;
			this.sobjectType	= sobjectType;
			this.hasError		= true;
			this.errorMessage	= errorMessage;
		}

		public void error(String salesforceId, String externalId, String errorMessage, String sobjectType){
			this.salesforceId	= salesforceId;
			this.externalId		= externalId;
			this.sobjectType	= sobjectType;
			this.hasError		= true;
			this.errorMessage	= errorMessage;
		}
	}
	global class ResponseParent extends Response {
		public List<DataIntegrationFields.Response> items;
	}

	public class CalloutResponse {
		public Boolean hasError;
		public String errorMessage;

		public ResponseParametersWrapper parsedResponse;
		public List<ResponseParametersWrapper> parsedResponses;

		public CalloutResponse(String errorMessage) {
			this.hasError = true;
			this.errorMessage = errorMessage;
		}
		public CalloutResponse(ResponseParametersWrapper response, Boolean hasError) {
			this.hasError = hasError;
			this.errorMessage = '';
			this.parsedResponse = response;
		}
		public CalloutResponse(List<ResponseParametersWrapper> responseList, Boolean hasError) {
			this.hasError = hasError;
			this.errorMessage = '';
			this.parsedResponses = responseList;
		}
	}

	public class ResponseParametersWrapper { // Adaptar Esta Class Para os Campos que Virá de Resposta da Integração OUT
		public Boolean hasError;
		public String errorMessage;
		public String salesforceId;
		public String externalId;
		public String sobjectType;

		public List<ResponseParametersWrapper> items;
	}

	public class RequestList { // Alterar o Nome das Variaveis Se Necessário
		List<OrderParameters> orderRequestList;

		public RequestList(List<DataIntegrationFields.OrderParameters> orderRequestList) {
			this.orderRequestList = orderRequestList;
		}
	}

	//configurar para p da livia
	public class OrderParameters {
		public String externalId;
		public String status;
		public Date effectiveDate;
		public Date deliveryDate;
		public String accountExternalId;
		public String pricebook2ExternalId;
		public String paymentTerms;
		public String distributionCenter;
		public String shippingType;
		public String address;
		public String billingAddressId;

		public OrderItemParameters[] orderItemList;

		public OrderParameters(Order order) {
			this.externalId = order.ExternalId__c;
			this.status = order.Status;
			this.effectiveDate = order.EffectiveDate;
			this.deliveryDate = order.DeliveryDate__c;
			this.accountExternalId = order.Account.ExternalId__c;
			this.pricebook2ExternalId = order.Pricebook2.ExternalId__c;
			this.paymentTerms = order.PaymentCondition__r.ExternalId__c;
			this.distributionCenter = order.DistributionCenter__r.ExternalId__c;
			this.shippingType = 'CIF';
			this.address = order.AccountAddress__r.ExternalId__c;
			this.billingAddressId = order.AccountAddress__r.ExternalId__c;

			this.orderItemList = new List<OrderItemParameters>();

			for (OrderItem orderItem : Order.OrderItems)
				orderItemList.add(new OrderItemParameters(orderItem));
		}
	}

	public class OrderItemParameters {
		public String externalId;
		public Decimal quantity;
		public Decimal unitPrice;
		public String orderExternalId;
		public String productExternalId;
		public String pricebookEntryExternalId;

		public OrderItemParameters(OrderItem orderItem) {
			this.externalId = orderItem.ExternalId__c;
			this.quantity = orderItem.Quantity;
			this.unitPrice = orderItem.UnitPrice;
			this.orderExternalId = orderItem.Order.ExternalId__c;
			this.productExternalId = orderItem.Product2.ExternalId__c;
			this.pricebookEntryExternalId = orderItem.PricebookEntry.ExternalId__c;
		}
	}

	public class ResponseAccessToken {
		public String access_token;
		public String error;
		public String error_description;
	}
}
