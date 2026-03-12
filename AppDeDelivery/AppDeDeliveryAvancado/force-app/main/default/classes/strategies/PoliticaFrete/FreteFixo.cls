public class FreteFixo implements PoliticaDeFrete {
    private Dinheiro valorFixo;

    public FreteFixo(Dinheiro valor) {
        this.valorFixo = valor;
    }

    public Dinheiro calcularFrete(Pedido pedido) {
        return this.valorFixo;
    }
}