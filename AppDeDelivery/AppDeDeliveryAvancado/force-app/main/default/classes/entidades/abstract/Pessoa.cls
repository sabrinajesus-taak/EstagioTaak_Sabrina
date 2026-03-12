public abstract class Pessoa extends EntidadeBase {
    private final String nome;
    private final Documento documento;

    public Pessoa (String nome, Documento documento) {
        if (nome == null) {
            throw new IllegalArgumentException('O nome não pode ser vazio');
        }
        this.nome = nome;
        this.documento = documento;
    }

    public abstract void getTipoPessoa() ;

}