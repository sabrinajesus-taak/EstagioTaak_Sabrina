public class Produto extends EntidadeBase{
    public String nome;
    public Dinheiro precoBase;
    public PoliticaDePreco politica;
    
    public Produto (String nome, Dinheiro preco) {
        this.nome = nome;
        this.precoBase = preco;
        this.politica = (politica != null) ? politica : new PoliticaPrecoPadrao();
    }
    
    public Dinheiro calcularPrecoFinal() {
        return this.politica.calcularPreco(this);
    }
    
    public void alterarPolitica(PoliticaDePreco novaPolitica) {
        if (novaPolitica != null) {
            this.politica = novaPolitica;
        }
    }   
    
    public String getNome() {return this.nome; }
    public Dinheiro getPrecoBase() { return this.precoBase; }
    
}