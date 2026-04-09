public with sharing class TemplateDefaultFields {
    public interface FieldDefaults {
        Map<String, Object> getFieldDefaults(Decimal countSObjectCreated);
    }

    // Minimal defaults for this repository demo tests.
    //=> liga uma chave a um valor (exclusivo do apex)
    //Map<nomeApi, valoresOBJ>
    public class LeadDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'FirstName' => 'Intern',
                'LastName' => 'Demo ' + countSObjectCreated,
                'Company' => 'Taak Routter'
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
                'LastName' => 'C' + countSObjectCreated
            };
        }
    }

    public class ProductHierarchyDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Hierarquia Teste' + countSObjectCreated,
                'Code__c' => 'H' + countSObjectCreated
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

    public class Product2Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Trator Teste' + countSObjectCreated,
                'UniqueCode__c' => 'TRT ' + countSObjectCreated,
                'ProductionCost__c' => '300000',
                'IsActive' => true
            };
        }
    }

    public class ImpostoDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'FirstName' => 'Intern',
                'LastName' => 'Demo ' + countSObjectCreated,
                'Company' => 'Taak Routter'
            };
        }
    }


}