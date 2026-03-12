public class FretePorPercentualDoTotal implements PoliticaDeFrete {
    private Decimal percentual;

    public FretePorPercentualDoTotal(Decimal percentual) {
        this.percentual = percentual;
    }

    public Dinheiro calcularFrete(Pedido pedido) {
        return pedido.getTotal().multiplicar(this.percentual / 100.0);
    }
}