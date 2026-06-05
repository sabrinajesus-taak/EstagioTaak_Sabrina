public class PokemonBatch implements Database.Batchable<Integer> , Database.AllowsCallouts {
    
    public List<Integer> start(Database.BatchableContext bc) {
        List<Integer> repeat = new List<Integer>();
        for(Integer i = 0; i < 68; i++){
            repeat.add(i);
        }
        return repeat;
    }
    
    public void execute(Database.BatchableContext bc, List<Integer> scope) {
        List<ChallengeUser__c> usersToInsert = new List<ChallengeUser__c>();
        
        for(Integer page : scope) {
            Integer offset = page * 20;
            PokemonDTO pokemonDTO = PokemonService.integrationPokemon(offset);
            
            for(PokemonDTO.PokemonResultDTO iResults: pokemonDTO.results) {
                ChallengeUser__c user = new ChallengeUser__c();
                user.Name = iResults.name;
                user.url__c = iResults.url;
                usersToInsert.add(user);
            }
        }
        insert usersToInsert; 
    }
    
    public void finish(Database.BatchableContext bc) {
        // Post-processing logic here
    }
}