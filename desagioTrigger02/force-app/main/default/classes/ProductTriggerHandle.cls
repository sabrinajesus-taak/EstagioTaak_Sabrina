/**
 * @description Handler para o desafio02 de Trigger do Programa de Estágio Taak
 * @author Sabrina de Jesus Braz
 */
public class ProductTriggerHandle extends TriggerHandler {
    private List<Product2> newRecords;
    private List<Product2> oldRecords;
    private Map<Id, Product2> newRecordsMap;
    private Map<Id, Product2> oldRecordsMap;
    
    public ProductTriggerHandle() {
        super('ProductTriggerHandler');
        this.newRecords = (List<Product2>) Trigger.new;
        this.oldRecords = (List<Product2>) Trigger.old;
        this.newRecordsMap = (Map<Id, Product2>) Trigger.newMap;
        this.oldRecordsMap = (Map<Id, Product2>) Trigger.oldMap;
    }

    /* === EVENTOS DA TRIGGER === */

    public override void beforeInsert() {
        // Implementar lógica antes de inserir
    }

    public override void beforeUpdate() {
        // Implementar lógica antes de atualizar
    }

    public override void beforeDelete() {
        // Implementar lógica antes de deletar
    }

    public override void afterInsert() { // Chamada do método do desafio
        createStandardPricebookEntries();
    }

    public override void afterUpdate() {
        // Implementar lógica após atualizar
    }

    public override void afterDelete() {
        // Implementar lógica após deletar
    }

    public override void afterUndelete() {
        // Implementar lógica após recuperar da lixeira
    }

    /* === LÓGICA DE NEGÓCIO === */

    private void createStandardPricebookEntries() {
        // isStandard - saber se está ativa
        List<Pricebook2> havePricebook = new List<Pricebook2>([SELECT Id FROM Pricebook2 WHERE IsStandard = true]); 
        
        List<CurrencyType> haveCurrency = new List<CurrencyType>([SELECT IsoCode FROM CurrencyType WHERE IsActive = true]);
        
        List<PricebookEntry> newPricebook = new List<PricebookEntry>();
        
        // Verificação de segurança para o catálogo
        if(havePricebook.isEmpty()) { return; }

        // Percorrendo os produtos recebidos pela trigger (this.newRecords)
        for(Product2 p : this.newRecords) {
            for (CurrencyType moeda : haveCurrency) {
                // criando o registro
                // precisa estar em produto e catalogo
                PricebookEntry pb = new PricebookEntry(); 
                
                // é obrigatório preencher os campos
                pb.Product2Id = p.Id; // liga com o produto do loop
                pb.Pricebook2Id = havePricebook[0].Id; // qual é o catalogo? ao q pertence? - pega exatamente o pricebook padrão
                pb.UnitPrice = 0;
                pb.IsActive = true;
                
                pb.CurrencyIsoCode = moeda.IsoCode;
                
                // adicionar a lista para subir tudo de uma vez
                newPricebook.add(pb);
            }
        }
        
        if(!newPricebook.isEmpty()) {
            insert newPricebook;
        }
    }
}