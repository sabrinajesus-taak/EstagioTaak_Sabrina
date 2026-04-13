public class AccountSelector {
    public static Map<Id, Account> getAccountByIds(Set<Id> ids) {
        return new Map<Id, Account>([
            SELECT Id, AccountGroup__c 
            FROM Account 
            WHERE Id IN :ids]);
    }
}