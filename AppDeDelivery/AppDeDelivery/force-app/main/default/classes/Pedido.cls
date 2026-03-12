public class Pedido {
    private Cliente cliente;
    private Restaurante restaurante;
    private List<ItemPedido> item;
    StatusPedido status; //enum
    private Double total;
    
    public Pedido(Cliente cliente, Restaurante restaurante) {
        this.cliente = cliente;
        this.restaurante = restaurante;
        this.item = new List<ItemPedido>();
        this.status = StatusPedido.CARRINHO;
    }
    
    // 3. Getter (permite que os outros VEJAM o status)
    public StatusPedido getStatus() {
        return this.status;
    }
    public List<ItemPedido> getItem() { return this.item; }
    public Cliente getCliente() {return this.cliente; }
    
    // 4. Setter (permite que os outros MUDEM o status)
    public void setStatus(StatusPedido novoStatus) {
        this.status = novoStatus;
    }
    
    //metódos-------------------------------------
    public void adicionarItemPedido(Produto produto, Integer quantidade) {
        Boolean encontrouNoCardapio = false;
        Boolean encontrouNoItem = false;
        
        for (Produto p : this.restaurante.getCardapio()) {
            if (p.nome.equalsIgnoreCase(produto.nome)) {
                encontrouNoCardapio = true;
                break;
            }
        }
        
        if (!encontrouNoCardapio) {
            System.debug('Produto não está disponível no cardápio.');
            return;
        }
        
        for (ItemPedido ip : this.item) {
            if (ip.getProduto().nome.equalsIgnoreCase(produto.nome)) {
                ip.setQuantidade(ip.getQuantidade() + quantidade);
                encontrouNoItem = true;
                System.debug('Quantidade atualizada: Adicionado +' + quantidade + ' unidades de ' + produto.nome);
                break;
            }
        }
        
        if (!encontrouNoItem) {
            this.item.add(new ItemPedido(produto, quantidade));
            System.debug('Sucesso: ' + produto.nome + ' adicionado ao pedido.');
        }
        
        this.calcularTotal();
    }


    public void calcularTotal(){
        Decimal novoTotal = 0;
        for (ItemPedido it: item) {
            novoTotal += it.calcularSubtotal();
        }
        this.total = novoTotal;
    }

    public void confirmarPedido() {
        if (this.status != StatusPedido.CARRINHO) {
            System.debug('Apenas status CARRINHO podem ser confirmados.');
        }

        if (this.item.isEmpty()) {
            System.debug('Não é possível confirmar um pedido sem itens.');
        }

        this.status = StatusPedido.EM_PROCESSAMENTO;
        System.debug('Pedido confirmado com sucesso.');
    }

    public void exibirResumo() {
        System.debug('Cliente: ' + this.cliente);
        System.debug('Restaurante: ' + this.restaurante);
        System.debug('Itens:');
        for (ItemPedido ip: item) {
            System.debug('Item: ' + ip.getProduto());
            System.debug('Quantidade: ' + ip.getQuantidade());
        }
        System.debug('Valor total: ' + this.total );
        System.debug('Status do Pedido: ' + this.status);
    }

}