public class ItemPedido{
    private Produto produto;
    private Integer quantidade;
    private Double subTotal;

    public ItemPedido(Produto produto, Integer quantidade) {
        this.produto = produto;
        this.quantidade = quantidade;
        this.subTotal = calcularSubtotal();
    }

    //getter--------------------
    public produto getProduto() { return produto; }
    public Integer getQuantidade() {return quantidade; } 

    public Double calcularSubtotal(){
        return this.quantidade * this.produto.preco;
    }

    //setter-----------------
    public void setQuantidade(Integer novaQuantidade){ 
        this.quantidade = novaQuantidade; 
        this.subTotal = calcularSubtotal();
    }

    public Double calcularSubtotal(Produto produto, Integer quantidade) {
        return this.produto.preco * this.quantidade;
    }
}