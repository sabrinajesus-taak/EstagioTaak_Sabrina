public class GerenciarRelatorios {
    private List<Pedido> pedidos;
    private List<String> cpf;
    
    public GerenciarRelatorios(){
        this.pedidos = new List<Pedido>();
        this.cpf = new List<String>();
    }
    
    public Map<Produto, Integer> gerarRelatorioProdutosMaisVendidos(List<Pedido> pedidos) {
        Map<Produto, Integer> totalQtdVendidas = new Map<Produto, Integer>();
        
        for (Pedido p : pedidos) { 
            for (ItemPedido ip : p.getItem()) { 
                Produto prod = ip.getProduto();
                Integer qtd = ip.getQuantidade();
                
                if (totalQtdVendidas.containsKey(prod)) {
                    totalQtdVendidas.put(prod, totalQtdVendidas.get(prod) + qtd);
                } else {
                    totalQtdVendidas.put(prod, qtd);
                }
            }
        }
        
        List<ProdutosWrapper> maisVendidos = gerarRankingDeProdutos(totalQtdVendidas);
        
        for (Integer i = 0; i < Math.min(3, maisVendidos.size()); i++) {
            System.debug((i + 1) + '. ' + maisVendidos.get(i).produto.getNome() + ' - '
                + maisVendidos.get(i).quantidade + ' unidades');
        }
        
        return totalQtdVendidas;
    }
    
    public List<ProdutosWrapper> gerarRankingDeProdutos(Map<Produto, Integer> total) {
        List<ProdutosWrapper> ranking = new List<ProdutosWrapper>();
        for (Produto p : total.keySet()) {
            ranking.add(new ProdutosWrapper(p, total.get(p)));
        }
        ranking.sort(); 
        return ranking;
    }

    public Map<String, List<Pedido>> gerarRelatorioPedidosPorCliente(List<Pedido> pedidos, List<String> cpfs) {
        Map<String, List<Pedido>> pedidosCliente = new Map<String, List<Pedido>>();
        
        for (String cpf : cpfs) {
            Integer qtdPedidos = 0;
            List<Pedido> listaPedidosDoCpf = new List<Pedido>();
            
            for (Pedido p : pedidos) {
                if (p.getCliente().getCpf() == cpf) {
                    listaPedidosDoCpf.add(p);
                    qtdPedidos += 1;
                }
            }
            
            pedidosCliente.put(cpf, listaPedidosDoCpf);
            System.debug('Cliente: ' + cpf + ' – ' + qtdPedidos + ' pedidos.');
        }
        
        return pedidosCliente;
    }

    //class wrapper------------------------------------------
    public class ProdutosWrapper implements Comparable {
        public Produto produto;
        public Integer quantidade;

        public ProdutosWrapper(Produto p, Integer q) {
            this.produto = p;
            this.quantidade = q;
        }

        public Integer compareTo(Object compareTo) {
            ProdutosWrapper other = (ProdutosWrapper)compareTo;
            if (this.quantidade == other.quantidade) return 0;
            return (this.quantidade > other.quantidade) ? -1 : 1;
        }
    }
}