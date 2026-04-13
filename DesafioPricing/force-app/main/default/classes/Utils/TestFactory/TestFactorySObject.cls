public class TestFactorySObject {
    private static TestFactorySObject testFactorySObject;
    private static Decimal countSObjectCreated = 0; //gera nomes diferentes
    
    public static TestFactorySObject getInstance() {
        if (testFactorySObject == null) {
            testFactorySObject = new TestFactorySObject();
        }
        return testFactorySObject;
    }
    
    @TestVisible
    private static void validateSObject(SObject sObj) {
        if (sObj == null) {
            throw new TestFactoryException('SObject cannot be null');
        }
    }
    
    private static void addFieldDefaults(SObject sObj, Map<String, Object> defaultFields) {
        for (String fieldApiName : defaultFields.keySet()) {
            if (sObj.get(fieldApiName) == null) {
                sObj.put(fieldApiName, defaultFields.get(fieldApiName));
            }
        }
    }
    
    public SObject createSObject(SObject sObj) {
        validateSObject(sObj);
        
        String objectName = String.valueOf(sObj.getSObjectType());
        if (objectName == 'Contract') {
            objectName = 'ContractStandard';
        }
        
        String defaultClassName =
            'TemplateDefaultFields.' + objectName.replaceAll('__c|__mdt|__|_', '') + 'Defaults';
        
        return dispatchSObjectCreation(sObj, defaultClassName);
    }
    
    @TestVisible
    private SObject dispatchSObjectCreation(SObject sObj, String defaultClassName) {
        //Type.forName cria uma nova instancia sem o uso de new
        Type t = Type.forName(defaultClassName);
        if (t == null) {
            throw new TestFactoryException(
                'Invalid defaults class. Missing class: ' + defaultClassName
                );
        }
        
        TemplateDefaultFields.FieldDefaults defaults =
            (TemplateDefaultFields.FieldDefaults) t.newInstance();
        addFieldDefaults(sObj, defaults.getFieldDefaults(countSObjectCreated));
        countSObjectCreated++;
        
        return sObj;
    }
    
    public class TestFactoryException extends Exception {
    }
    
    public static void createPrincingScenario(){
        TestFactorySObject factory = new TestFactorySObject();
        
        AccountGroup__c acg = (AccountGroup__c) factory.createSObject(new AccountGroup__c());
        insert acg;
        
        Account acc = (Account) factory.createSObject(new Account());
        acc.AccountGroup__c = acg.Id;
        insert acc;
        
        Country__c pais = (Country__c) factory.createSObject(new Country__c());
        insert pais;
        
        State__c estado1 = (State__c) factory.createSObject(new State__c());
        estado1.Country__c = pais.Id;
        insert estado1;
        
        City__c cidade = (City__c) factory.createSObject(new City__c());
        cidade.State__c = estado1.Id;
        insert cidade;
        
        DistributionCenter__c dc = (DistributionCenter__c) factory.createSObject(new DistributionCenter__c());
        dc.City__c = cidade.Id;
        dc.State__c = estado1.Id;
        dc.Country__c = pais.Id;
        insert dc;
        
        ProductHierarchy__c productH = (ProductHierarchy__c) factory.createSObject(new ProductHierarchy__c());
        insert productH;
        
        Product2 produto = (Product2) factory.createSObject(new Product2());
        produto.ProductHierarchy__c = productH.Id;
        insert produto;
        
        Tax__c imposto = (Tax__c) factory.createSObject(new Tax__c());
        imposto.DistributionCenter__c = dc.Id;
        imposto.Product__c = produto.Id;
        imposto.State__c = estado1.Id;
        imposto.Status__c = 'Approved';
        imposto.TaxRate__c = 10.0;
        insert imposto;
        
        Id stdPricebookId = Test.getStandardPricebookId();
        
        Order pedido = new Order(
            AccountId = acc.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = stdPricebookId,
        DistributionCenter__c = dc.Id,
        State__c = estado1.Id,
        City__c = cidade.Id,
        Country__c = pais.Id
            );
        insert pedido;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = stdPricebookId,
        Product2Id = produto.Id,
        UnitPrice = 1000,
        IsActive = true
            );
        insert pbe;
    }
    
    public static void createOrderItemScenario(){
        TestFactorySObject factory = new TestFactorySObject();
        
        AccountGroup__c acg = (AccountGroup__c) factory.createSObject(new AccountGroup__c());
        insert acg;
        
        Account acc = (Account) factory.createSObject(new Account());
        acc.AccountGroup__c = acg.Id;
        insert acc;
        
        Country__c pais = (Country__c) factory.createSObject(new Country__c());
        insert pais;
        
        State__c estado1 = (State__c) factory.createSObject(new State__c());
        estado1.Country__c = pais.Id;
        insert estado1;
        
        City__c cidade = (City__c) factory.createSObject(new City__c());
        cidade.State__c = estado1.Id;
        insert cidade;
        
        DistributionCenter__c dc = (DistributionCenter__c) factory.createSObject(new DistributionCenter__c());
        dc.City__c = cidade.Id;
        dc.State__c = estado1.Id;
        dc.Country__c = pais.Id;
        insert dc;
        
        ProductHierarchy__c productH = (ProductHierarchy__c) factory.createSObject(new ProductHierarchy__c());
        insert productH;
        
        Product2 produto = (Product2) factory.createSObject(new Product2());
        produto.ProductHierarchy__c = productH.Id;
        insert produto;
        
        Tax__c imposto = (Tax__c) factory.createSObject(new Tax__c());
        imposto.DistributionCenter__c = dc.Id;
        imposto.Product__c = produto.Id;
        imposto.State__c = estado1.Id;
        imposto.Status__c = 'Approved';
        imposto.TaxRate__c = 10.0;
        insert imposto;
        
        Freight__c frete = (Freight__c) factory.createSObject(new Freight__c());
        frete.Product__c = produto.Id;
        frete.State__c = estado1.Id;
        frete.DistributionCenter__c = dc.Id;
        frete.Status__c = 'Approved';
        frete.FreightValue__c = 700.0;
        insert frete;
        
        Margem__c margem = (Margem__c) factory.createSObject(new Margem__c());
        margem.Product__c = produto.Id;
        margem.Account__c = acc.Id;
        margem.State__c = estado1.Id;
        margem.DistributionCenter__c = dc.Id;
        margem.Status__c = 'Approved';
        margem.MarginValuePercent__c = 15.0;
        insert margem;
        
        Id stdPricebookId = Test.getStandardPricebookId();
        
        Order pedido = new Order(
            AccountId = acc.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = stdPricebookId,
        DistributionCenter__c = dc.Id,
        State__c = estado1.Id,
        City__c = cidade.Id,
        Country__c = pais.Id
            );
        insert pedido;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = stdPricebookId,
        Product2Id = produto.Id,
        UnitPrice = 1000,
        IsActive = true
            );
        insert pbe;
    }
    
}