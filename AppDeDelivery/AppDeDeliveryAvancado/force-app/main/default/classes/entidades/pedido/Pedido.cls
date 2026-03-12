public class Pedido extends EntidadeBase {
    private Cliente cliente;
    private Restaurante restaurante;
    private List<ItemPedido> itens;
    private StatusPedido status; //enum
    private Dinheiro total;
    
    // Construtor principal
    public Pedido(Cliente cliente) {
        if (cliente == null) {
            throw new BusinessException('Um pedido deve obrigatoriamente ter um cliente.');
        }
        this.cliente = cliente;
        this.status = StatusPedido.CARRINHO; // Regra da Parte 4: Iniciar no CARRINHO
        this.itens = new List<ItemPedido>();      // Inicializa a lista para evitar nulos
        this.total = Dinheiro.zero();        // Parte 3: Total começa em zero
    }
    
    //só altera se estiver no carrinho
    private void possivelAlterar() {
        if (this.status != StatusPedido.CARRINHO) {
            throw new BusinessException('Não é permitido alterar itens.');
        }
    }
    
    public void adicionarProduto(Produto produto, Integer quantidade) {
        possivelAlterar();
        
        if (quantidade < = 0) {
            throw new BusinessException('A quantidade deve ser positiva');
        }
        
        ItemPedido existeItem = encontrarItemPorProduto(produto);
        if (existeItem != null) {
            existeItem.adicionarQuantidade(quantidade);
        } else {
            this.itens.add(new ItemPedido(produto, quantidade));
        }
        
        recalcularTotal();
    }
    
    public void removerProduto(Produto produto) {
        possivelAlterar();
        
        for (Integer i = 0; i < itens.size(); i++) {
            if (itens[i].getProduto().equals(produto)) {
                itens.remove(i);
                break;
            }
        }
        recalcularTotal();
    }
    
    public void alterarQuantidade(Produto produto, Integer novaQuantidade) {
        possivelAlterar();
        
        if(novaQuantidade == null || novaQuantidade < 0) {
            this.removerProduto(produto);
            return;
        }
        
        ItemPedido itemExistente = encontrarItemPorProduto(produto);
        
        if (itemExistente != null) {
            itemExistente.definirNovaQuantidade(novaQuantidade);
            recalcularTotal();
        } else {
            this.adicionarProduto(produto, novaQuantidade); // se o produto não estava no carrinho é adicionado.
        }
    }
    
    public void mudarStatusParaEmProcessamento() {
        this.status = StatusPedido.EM_PROCESSAMENTO;
    }
    
    public void mudarStatusParaCancelado(){
        this.status = StatusPedido.CANCELADO;
    }
    
    public void aplicarFrete(Dinheiro valorFrete) {
        if (valorFrete == null) {
            throw new BusinessException('O valor do frete não pode ser nulo.');
        }
        
        this.total = this.total.somar(valorFrete);
    }
    
    public void mudarStatusparaEntregue(){
        this.status = StatusPedido.ENTREGUE;
    }
    
    // --- --- ---
    
    private ItemPedido encontrarItemPorProduto(Produto produto) {
        for (ItemPedido item : this.itens) {
            if (item.getProduto().equals(produto)) {
                return item;
            }
        }
        return null;
    }
    
    public void recalcularTotal(){
        this.total = Dinheiro.zero(); //zero o total antes de recalcular
        
        for (ItemPedido ip: itens) {
            this.total = this.total.somar(ip.getSubtotal());
        }
    }
    
    public Dinheiro getTotal(){ return this.total; }
    public StatusPedido getStatus() {return this.status; }
    public List<ItemPedido> getItens() {return new List<ItemPedido>(this.itens);}
    
    
    //item pedido ---------------------------------
    
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
    
}