public class ContaCorrente extends Conta{

    public override Decimal calcularTaxa(){
        return this.saldo * 0.01;
    }
}