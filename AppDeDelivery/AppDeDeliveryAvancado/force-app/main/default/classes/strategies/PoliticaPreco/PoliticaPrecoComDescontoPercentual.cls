public class PoliticaPrecoComDescontoPercentual implements PoliticaDePreco {
    private Decimal percentual;
    
    public PoliticaPrecoComDescontoPercentual(Decimal percentual) {
        if (percentual == null || percentual < 0 || percentual > 100) {
            throw new BusinessException('Percentual de desconto inválido!');
        }
        this.percentual = percentual;
    }
    
    public Dinheiro calcularPreco(Produto produto) {
        return produto.getPrecoBase().subtrair(produto.getPrecoBase().multiplicar(this.percentual / 100.0));
    }
}