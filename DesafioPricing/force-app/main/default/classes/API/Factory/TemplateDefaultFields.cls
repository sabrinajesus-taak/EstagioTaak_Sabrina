public with sharing class TemplateDefaultFields {
	public interface FieldDefaults {
		Map<String, Object> getFieldDefaults(Decimal countSObjectCreated);
	}

	public class UserDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'ExternalId__c' => '10' + countSObjectCreated,
				'Username' => 'test' + Datetime.now().getTime() +'@test.com',
				'LastName' => 'inquima',
				'Email' => 'inquima@inquima.com',
				'Alias' => 'inquima',
				'CommunityNickname' => 'inquima',
				'TimeZoneSidKey' => 'America/Sao_Paulo',
				'LocaleSidKey' => 'pt_BR',
				'EmailEncodingKey' => 'ISO-8859-1',
				'LanguageLocaleKey' => 'pt_BR'
			};
		}
	}

    public class CountryDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'País Teste' + countSObjectCreated,
                'CountryCode__c' => 'P' + countSObjectCreated
            };
        }
    }
    
    public class StateDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Estado Teste' + countSObjectCreated,
                'StateCode__c' => 'E' + countSObjectCreated
            };
        }
    }
    
    public class CityDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Cidade Teste' + countSObjectCreated,
                'CityCode__c' => 'C' + countSObjectCreated
            };
        }
    }
    
    public class DistributionCenterDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Centro de Distribuição Teste' + countSObjectCreated,
                'DistributionCenterCode__c' => 'DC' + countSObjectCreated
            };
        }
    }
    
    //---------------------------------------------------
    
    public class ProductHierarchyDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Hierarquia Teste' + countSObjectCreated,
                'Code__c' => 'H' + countSObjectCreated
            };
        }
    }
    
    public class Product2Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Trator Teste' + countSObjectCreated,
                'UniqueCode__c' => 'TRT ' + countSObjectCreated,
                'ProductionCost__c' => 300000,
                'IsActive' => true
            };
        }
    }
    
    //------------------------------------------
    
    public class TaxDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Imposto Teste' + countSObjectCreated,
                'TaxCode__c' => 'IP' + countSObjectCreated
            };
        }
    }
    
    public class FreightDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Frete Teste' + countSObjectCreated,
                'FreightCode__c' => 'F' + countSObjectCreated
            };
        }
    }
    
    public class MargemDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Margem Teste' + countSObjectCreated,
                'MargemCode__c' => 'M' + countSObjectCreated
            };
        }
    }
    
    //-----------------------------------------------------
    
    public class AccountDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            // Vamos criar um CNPJ fictício: 12.345.678/0001- e o final muda com o contador
            // Usamos String.valueOf(countSObjectCreated).leftPad(2, '0') para garantir 2 dígitos no final
            String finalDoCnpj = String.valueOf(countSObjectCreated.intValue()).leftPad(2, '0');
            
            return new Map<String, Object>{
                'Name' => 'Conta Teste' + countSObjectCreated,
                'CNPJ__c' => '12.345.678/0001-' + finalDoCnpj // Fica formatado e único
            };
        }
    }
    
    public class AccountGroupDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Grupo de Conta Teste' + countSObjectCreated,
                'AccountGroupCode__c' => 'ACG' + countSObjectCreated
            };
        }
    }
    
    //-----------------------------------------------------
    
    
    public class PricebookEntryDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'IsActive' => true
            };
        }
    }

	public class IntegrationSettingDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'IntegrationSettingName',
				'Method__c' => 'POST',
				'Endpoint__c' => 'Endpoint',
				'User__c' => UserInfo.getUserName(),
				'Password__c' => UserInfo.getUserName(),
				'Timeout__c' => 110000,
				'AccessToken__c' => 'AccessToken' + String.valueOf(Datetime.now()),
				'ClientId__c' => String.valueOf(Datetime.now()),
				'ClientSecret__c' => UserInfo.getUserName() + String.valueOf(Datetime.now()),
				'EndpointAccessToken__c' => 'EndpointAccessToken',
				'AccessTokenTime__c' => 360000,
				'LastAccessTokenTime__c' => Decimal.valueOf(Datetime.now().getTime())
			};
		}
	}
}
