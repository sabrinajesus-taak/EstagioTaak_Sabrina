public class Produto {
    public String nome;
    public Decimal preco;

    public Produto (String nome, Decimal preco) {
        this.nome = nome;
        this.preco = preco;
    }

    public String getNome() {return this.nome; }
    public Decimal getPreco() {return this.preco; }
    
}