public class ContaPoupanca extends Conta { //extends pega os atributos e metodos de conta, des de que não sejam private

    //metodos 
    public override Decimal calcularTaxa(){ //override é obrigatório quando implementa um metodo abstrato.
        return saldo * 0.05;
    }
}