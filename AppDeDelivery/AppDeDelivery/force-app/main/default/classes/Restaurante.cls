public class Restaurante {
    private String nome;
    private String endereco;
    CategoriaRestaurante categoria; //atributo do tipo enum
    private List<Produto> cardapio; //os produtos são adicionados nos testes

    public Restaurante (String nome, String endereco, CategoriaRestaurante categoria){
        this.nome = nome;
        this.endereco = endereco;
        this.categoria = categoria;
        this.cardapio = new List<Produto>(); //garante que a lista inicie vazia
    }

    // O Getter retorna uma das opções do Enum
    public CategoriaRestaurante getCategoria() {
        return categoria;
    }
    public List<Produto> getCardapio() { return cardapio; }

    // O Setter exige que escolha uma das opções do Enum
    public void setCategoria(CategoriaRestaurante categoria) {
        this.categoria = categoria;
    }

    //metodos------------------------------
    public void adicionarProduto(Produto novoProduto) {
        Boolean jaExiste = false;

        for (Produto p : cardapio) {
            if (p.getNome().equalsIgnoreCase(novoProduto.getNome())) {
                jaExiste = true;
                break; // Se achou, para de procurar
            }
        }

    
        if (jaExiste) {
            System.debug(LoggingLevel.ERROR, 'O produto ' + novoProduto.getNome() + ' já existe.');
        } else {
            cardapio.add(novoProduto);
            System.debug('Produto Adicionado com sucesso: ' + novoProduto.getNome());
        }
    }

    //-----------------------------------------
    public void exibirCardapio() {
        for (Integer i = 0; i < cardapio.size(); i++) {
            Produto p = cardapio.get(i);
            System.debug((i + 1) + '.' + p.getNome() + '- R$' + p.getPreco());
        }
    }

    //-------------------------------------------
    public List<Produto> buscarProdutos(String termoBusca) {
        List<Produto> produtosEncontrados = new List<Produto>();

        for (Produto p: cardapio) {
            if (p.getNome().containsIgnoreCase(termoBusca)) {
                produtosEncontrados.add(p);
            }
        }
        if (!produtosEncontrados.isEmpty()) {
            for(Produto p : produtosEncontrados) {
                System.debug(p.getNome() + ' - ' + p.getPreco());
            }
        } else {
            System.debug('Nenhum produto encontrado.');
        }

        return produtosEncontrados; 
    }
}