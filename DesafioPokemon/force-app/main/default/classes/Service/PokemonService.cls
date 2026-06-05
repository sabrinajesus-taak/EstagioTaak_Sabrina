public class PokemonService {
    public static PokemonDTO integrationPokemon(Integer offset){
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://pokeapi.co/api/v2/pokemon?offset=' + offset + '&limit=20');
        request.setMethod('GET');
        
        Http http = new Http();
        HttpResponse response = http.send(request);

        if(response.getStatusCode() == 200) {
            String responseBody = response.getBody();
            PokemonDTO pokemonDTO = (PokemonDTO) JSON.deserialize(responseBody, PokemonDTO.class);
            return pokemonDTO;
        } else {
            throw new CalloutException('Failed to integrate with Pokemon API. Status code: ' + response.getStatusCode());
        }
    }
}