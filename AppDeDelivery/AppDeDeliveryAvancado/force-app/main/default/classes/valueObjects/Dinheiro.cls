public class Dinheiro {
    private final Decimal valor;

    public Dinheiro(Decimal valor) {
        this.valor = (valor == null) ? 0.00 : valor.setScale(2);
        
        if (this.valor < 0) {
            throw new BusinessException('O valor monetário não pode ser negativo.');
        }
    }

    public Decimal getValor() {
        return this.valor;
    }

    public static Dinheiro zero() {
        return new Dinheiro(0.00);
    }

    // Operaçoes----------------------
    
    public Dinheiro somar(Dinheiro outro) {
        return new Dinheiro(this.valor + outro.getValor());
    }

    public Dinheiro subtrair(Dinheiro outro) {
        return new Dinheiro(this.valor - outro.getValor());
    }

    public Dinheiro multiplicar(Decimal quantidade) {
        return new Dinheiro(this.valor * quantidade);
    }

    // COMPARAÇÃO
    
    public Boolean equals(Object obj) {
        if (obj instanceof Dinheiro) {
            Dinheiro outro = (Dinheiro)obj;
            return this.valor == outro.valor;
        }
        return false;
    }

    public Integer hashCode() {
        return System.hashCode(valor);
    }
}