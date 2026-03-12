public class ProcessadorPedido {
    private PoliticaDeFrete politicaFrete;
    
    public ProcessadorPedido(PoliticaDeFrete politicaFrete) {
        this.politicaFrete = politicaFrete;
    }
    
    public void confirmarPedido(Pedido pedido) {
        if (pedido != null) {
            if ( pedido.getStatus() != StatusPedido.CARRINHO) {
                if (pedido.getItens().isEmpty()) {
                    pedido.recalcularTotal();
                    Dinheiro valorFrete = this.politicaFrete.calcularFrete(pedido);
                    pedido.aplicarFrete(valorFrete);
                    if (pedido.getTotal().getValor() <= 0) {
                        throw new BusinessException('Total é maior que zero');
                    }
                    pedido.mudarStatusParaEmProcessamento();
                }
                throw new BusinessException('Não é possível confirmar um pedido sem itens.');
            }
            throw new BusinessException('Apenas pedidos no carrinho podem ser confirmados.');
        } throw new BusinessException('Entrada nula.');
    }
    
    public void cancelarPedido(Pedido pedido) {
        if (pedido != null) {
            if ( pedido.getStatus() != StatusPedido.CARRINHO) {
                if (pedido.getItens().isEmpty()) {
                    pedido.recalcularTotal();
                    pedido.mudarStatusParaCancelado();
                }
                throw new BusinessException('Não é possível confirmar um pedido sem itens.');
            }
            throw new BusinessException('Apenas pedidos no carrinho podem ser confirmados.');
        } throw new BusinessException('Entrada nula.');
    }
    
    public void finalizarEntrega(Pedido pedido) {
        if (pedido == null) {
            throw new BusinessException('Entrada nula.');
        }
        
        if (pedido.getStatus() != StatusPedido.EM_PROCESSAMENTO) {
            throw new BusinessException('Apenas pedidos em processamento podem ser marcados como entregues.');
        }
        
        pedido.mudarStatusParaEntregue();
    }
}