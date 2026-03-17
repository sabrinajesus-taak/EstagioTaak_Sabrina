public class AssociatedLocationTriggerHandler extends TriggerHandler {
    
    private List<AssociatedLocation> newRecords;
    private List<AssociatedLocation> oldRecords;
    private Map<Id, AssociatedLocation> newRecordsMap;
    private Map<Id, AssociatedLocation> oldRecordsMap;
    
    public AssociatedLocationTriggerHandler() {
        this.newRecords = (List<AssociatedLocation>) Trigger.new;
        this.oldRecords = (List<AssociatedLocation>) Trigger.old;
        this.newRecordsMap = (Map<Id, AssociatedLocation>) Trigger.newMap;
        this.oldRecordsMap = (Map<Id, AssociatedLocation>) Trigger.oldMap;
    }

    //--------------------------------------------------------------------------
    
    /* * FLUXO 1: Adicionar ao Time de Contas na criação */
    public override void afterInsert() {
        // 1. Criar um Set de IDs de conta e de usuários para a busca
        Set<Id> accountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        
        for (AssociatedLocation al : newRecords) {
            if (al.Representative_User__c != null && al.ParentRecordId != null) {
                accountIds.add(al.ParentRecordId);
                userIds.add(al.Representative_User__c);
            }
        }
        
        // 2. Busca SOQL para verificar quem já existe na Equipe de Contas
        List<AccountTeamMember> existingMembers = [
            SELECT UserId, AccountId 
            FROM AccountTeamMember 
            WHERE AccountId IN :accountIds AND UserId IN :userIds];
        
        List<AccountTeamMember> membersToInsert = new List<AccountTeamMember>();
        
        for (AssociatedLocation al : newRecords) {
            Boolean jaExiste = false;
            for (AccountTeamMember atm: existingMembers) {
                if ( atm.AccountId == al.ParentRecordId && atm.UserId == al.Representative_User__c) {
                    jaExiste = true; //se já existe em TeamMember para aqui
                    break;
                }
            }
            
            
            //se não existe, adicona a lista para o insert
            if(!jaExiste) {
                membersToInsert.add(new AccountTeamMember(
                    AccountId = al.ParentRecordId,
                UserId = al.Representative_User__c,
                TeamMemberRole = 'Sales Rep',
                AccountAccessLevel = 'Edit'
                    ));
            }
        }
        
        // Se a lista não for vazia
        if (!membersToInsert.isEmpty()) {
            insert membersToInsert;
        }
        
    }
    //--------------------------------------------------------------------------
    
    //Fluxos 02 e 03
    public override void afterUpdate() {
        Set<Id> userIdsToCheck = new Set<Id>(); //mudou usuario
        Set<Id> accountIdsToCheck = new Set<Id>(); //contas
        List<AccountTeamMember> membersToAdd = new List<AccountTeamMember>();
        
        
        
        for(AssociatedLocation al : newRecords) {
            AssociatedLocation oldAl = oldRecordsMap.get(al.Id);
            
            // Se mudou o Representante ou a Conta
            if(al.Representative_User__c != oldAl.Representative_User__c || al.ParentRecordId != oldAl.ParentRecordId) {
                //adiciono a equipe de contas
                membersToAdd.add( new AccountTeamMember(
                    AccountId = al.ParentRecordId,
                UserId = al.Representative_User__c,
                TeamMemberRole = 'Sales Rep',
                AccountAccessLevel = 'Edit'
                    ));
                
                // Guardamos quem "saiu" para verificar se removemos o acesso
                userIdsToCheck.add(oldAl.Representative_User__c);
                accountIdsToCheck.add(oldAl.ParentRecordId);
            }
        }
        
        if(!membersToAdd.isEmpty()) insert membersToAdd;
        if(userIdsToCheck.isEmpty()) return;
        
        List<AssociatedLocation> existingUserLA = [
        SELECT Representative_User__c, ParentRecordId 
        FROM AssociatedLocation 
        WHERE Representative_User__c IN :userIdsToCheck  // "Procure por esses vendedores"
          AND ParentRecordId IN :accountIdsToCheck      // "Nesses prédios específicos"
          AND Id NOT IN :newRecordsMap.keySet()          // "IGNORE as salas que estou mexendo agora"
        ];
        
        // MAPA de Sobreviventes: Usuário -> Set de Contas onde ainda tem LA
        Map<Id, Set<Id>> userToAccountsMap = new Map<Id, Set<Id>>();
        
        for(AssociatedLocation la : existingUserLA) {
            if(!userToAccountsMap.containsKey(la.Representative_User__c)) { //ve se o usuario já esta no map
                userToAccountsMap.put(la.Representative_User__c, new Set<Id>()); //o set é para guardar os ParentRecords(contas/predios)
            }
            userToAccountsMap.get(la.Representative_User__c).add(la.ParentRecordId); //pega o set que é do usuario e adiciona o id da conta.
        }
        
        // 1. Busca os registros da equipe que podem ser deletados
        List<AccountTeamMember> delAccountMember = [
            SELECT Id, UserId, AccountId
            FROM AccountTeamMember
            WHERE UserId IN :userIdsToCheck
                AND AccountId IN :accountIdsToCheck
            ];
        
        List<AccountTeamMember> userDelete = new List<AccountTeamMember>();
        
        for (AccountTeamMember ac : delAccountMember) {
            // Tradução: "Se o Map NÃO tem esse usuário OU se o Set de contas desse usuário NÃO tem essa conta"
            Boolean aindaTemLocal = userToAccountsMap.containsKey(ac.UserId) &&
                userToAccountsMap.get(ac.UserId).contains(ac.AccountId);
            
            if (!aindaTemLocal) {
                userDelete.add(ac);
            }
        }
        
        // 3. Deleta de uma vez só
        if (!userDelete.isEmpty()) {
            delete userDelete;
        }
    }
    
    //--------------------------------------------------------------------------
    
    /* * FLUXO 4: Remoção ao excluir o Local Associado */
    public override void afterDelete() {
        // é posssivel reutilizar boa parte do afterUpadate, mas não usa o newRecords e sim oldRecords
        Set<Id> userIdsToCheck = new Set<Id>(); //mudou usuario
        Set<Id> accountIdsToCheck = new Set<Id>(); //contas
        
        for(AssociatedLocation al: oldRecords) {
            if(al.Representative_User__c != null) {
                userIdsToCheck.add(al.Representative_User__c);
                accountIdsToCheck.add(al.ParentRecordId);
            }
        }
        
        if(userIdsToCheck.isEmpty()) return; //ainda possui LA
        
        List<AssociatedLocation> existingUserLA = [
        SELECT Representative_User__c, ParentRecordId 
        FROM AssociatedLocation 
        WHERE Representative_User__c IN :userIdsToCheck  // "Procure por esses vendedores"
          AND ParentRecordId IN :accountIdsToCheck      // "Nesses prédios específicos"      
        ];
        
        // MAPA de Sobreviventes: Usuário -> Set de Contas onde ainda tem LA
        Map<Id, Set<Id>> userToAccountsMap = new Map<Id, Set<Id>>();
        
        for(AssociatedLocation la : existingUserLA) {
            if(!userToAccountsMap.containsKey(la.Representative_User__c)) { //ve se o usuario já esta no map
                userToAccountsMap.put(la.Representative_User__c, new Set<Id>()); //o set é para guardar os ParentRecords(contas/predios)
            }
            userToAccountsMap.get(la.Representative_User__c).add(la.ParentRecordId); //pega o set que é do usuario e adiciona o id da conta.
        }
        
        // 1. Busca os registros da equipe que podem ser deletados
        List<AccountTeamMember> delAccountMember = [
            SELECT Id, UserId, AccountId
            FROM AccountTeamMember
            WHERE UserId IN :userIdsToCheck
                AND AccountId IN :accountIdsToCheck
            ];
        
        List<AccountTeamMember> userDelete = new List<AccountTeamMember>();
        
        for (AccountTeamMember ac : delAccountMember) {
            // Tradução: "Se o Map NÃO tem esse usuário OU se o Set de contas desse usuário NÃO tem essa conta"
            Boolean aindaTemLocal = userToAccountsMap.containsKey(ac.UserId) &&
                userToAccountsMap.get(ac.UserId).contains(ac.AccountId);
            
            if (!aindaTemLocal) {
                userDelete.add(ac);
            }
        }
        
        // 3. Deleta de uma vez só
        if (!userDelete.isEmpty()) {
            delete userDelete;
        }
        
    }
    
    
}