public class PokemonDTO {

    public Integer count;
    public String next;
    public String previous;
    public List<PokemonResultDTO> results;

    public class PokemonResultDTO {
        public String name;
        public String url;
    }

}