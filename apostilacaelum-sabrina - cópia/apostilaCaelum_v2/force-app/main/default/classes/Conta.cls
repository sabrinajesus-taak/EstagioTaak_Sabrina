public abstract class Conta {
    //Atributos 
    Integer num_conta;
    String nome_titular;
    Decimal saldo;

    //Construtor
    public Conta(Integer num_conta, String nome_titular) {
        this.num_conta = num_conta;
        this.nome_titular = nome_titular;
        this.saldo = 0;
    }

    //metodos
    public Decimal depositar(Interger num_conta, Decimal valor) {
        if (valor <= 0) {
            
        } else {
            Decimal novo_valor = this.saldo + valor;
            this.saldo = novo_valor;
        }
    }

    public abstract Decimal calcularTaxa() {}


}