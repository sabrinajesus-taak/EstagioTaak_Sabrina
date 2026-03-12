public class Cliente extends Pessoa {
    private final Endereco endereco;
    private final String telefone; 

    public Cliente(String nome, Documento documento, Endereco endereco, String telefone) {
        super(nome, documento); //deve ser sempre a primeira linha do construtor, chamando o construtor pai.
        this.endereco = endereco;
        this.telefone = telefone;
    }

    public override void getTipoPessoa(){
        System.debug('O tipo de Pessoa é: Cliente.');
    }
}