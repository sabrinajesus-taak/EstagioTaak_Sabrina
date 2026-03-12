public class Endereco {
    private final String logradouro;
    private final String numero;
    private final String complemento;
    private final String cidade;

    //contrutor completo
    public Endereco(String logradouro, String numero, String complemento, String cidade) {
        this.logradouro = logradouro;
        this.numero = numero;
        this.complemento = complemento;
        this.cidade = cidade;
    }

    //contrutor com complemento opcional
    public Endereco(String logradouro, String numero, String cidade) {
        this(logradouro, numero, '', cidade);
    }

    public Boolean equals(Object obj) {
        if (obj instanceof Endereco) {
            Endereco outro = (Endereco)obj;
            return this.logradouro == outro.logradouro &&
                    this.numero == outro.numero &&
                    this.complemento == outro.complemento &&
                    this.cidade == outro.cidade;
        }
        return false;
    }

    //precisa criar o hashcode?
}