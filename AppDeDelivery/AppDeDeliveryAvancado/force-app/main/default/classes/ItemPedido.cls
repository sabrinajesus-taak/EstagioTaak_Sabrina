public class ItemPedido {
    private final Produto produto;
    private Integer quantidade;
    private Dinheiro subtotal;
    
    // Construtor protegido: só o Pedido pode criar
    public ItemPedido(Produto produto, Integer quantidade) { //o certo é sem o public para somente pedido ter acesso
        if (produto == null) throw new BusinessException('Produto é obrigatório.');
        if (quantidade <= 0) throw new BusinessException('Quantidade deve ser maior que zero');
        this.produto = produto;
        this.quantidade = quantidade;
        this.recalcularSubtotal();
    }
    
    public void recalcularSubtotal() {
        this.subtotal = this.produto.calcularPrecoFinal().multiplicar(this.quantidade);
    }
    
    // Método quando o produto já existe na lista
    public void adicionarQuantidade(Integer qtd) { //o certo é sem o public para somente pedido ter acesso
        this.quantidade += qtd;
        this.recalcularSubtotal();
    }
    
    public void definirNovaQuantidade(Integer novaQuantidade) {
        if (novaQuantidade <= 0) {
            throw new BusinessException('A quantidade deve ser maior que zero.');
        }
        this.quantidade = novaQuantidade;
        this.recalcularSubtotal(); 
    }
    
    
    public Boolean equals(Object obj) {
        if (obj instanceof ItemPedido) {
            ItemPedido other = (ItemPedido)obj;
            // A igualdade é baseada no ID do produto
            return this.produto == other.produto;
        }
        return false;
    }
    
    // Getters
    public Dinheiro getSubtotal() { return subtotal; }
    public Produto getProduto() { return produto; }
    public Integer getQuantidade() { return quantidade; }
}