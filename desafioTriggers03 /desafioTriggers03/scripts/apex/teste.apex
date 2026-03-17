// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

//criar a conta
Account conta = new Account(Name = 'Conta Teste Apex');
insert conta;

//criar o local para o AssociatedLocation
//o Schema é para não dar problema com o nome "System.Location"
Schema.Location local = new Schema.Location(Name = 'Predio A', LocationType = 'Site');
insert local;

//Id do usuario (meu id)
Id meuId = '005bm00000NBno9AAD';

//------------------------------------------------------------------------
//Teste do fluxo 01 
AssociatedLocation al = new AssociatedLocation(
    ParentRecordId = conta.Id,        
    LocationId = local.Id,           
    Representative_User__c = meuId
);
insert al;
System.debug('Check 1: O usuário foi inserido no AccountTeamMember?');

------------------------------------------------------------------------
//Teste de fluxo 02/03
AssociatedLocation alExistente = [SELECT Id, Representative_User__c 
                                  FROM AssociatedLocation 
                                  WHERE ParentRecord.Name = 'Conta Teste Apex' 
                                  LIMIT 1];

Id outroUsuario = '005bm00000NBnplAAD';
alExistente.Representative_User__c = outroUsuario;
update alExistente;
System.debug('Representante atualizado para: ' + alExistente.Representative_User__c);

//------------------------------------------------------------------------
//fluxo 04 - delete
AssociatedLocation alParaDeletar = [SELECT Id 
                                    FROM AssociatedLocation 
                                    WHERE ParentRecord.Name = 'Conta Teste Apex' 
                                    LIMIT 1];
delete alParaDeletar;
System.debug('Check 3: O usuário saiu da equipe da conta?');    