public abstract class Conta {

    // Atributos
    public Integer numeroConta;
    public String nomeTitular;
    public Decimal saldo = 0;
    public static Integer totalDeContas = 0;

    private static Set<Integer> numerosDeContas = new Set<Integer>();
    private static Map<Integer, Conta> contasPorNumero = new Map<Integer, Conta>();

    // Construtor
    public Conta(Integer numeroConta, String nomeTitular) {

        if (numerosDeContas.contains(numeroConta)) {
            throw new NumeroDeContaDuplicadoException();
        }

        this.numeroConta = numeroConta;
        this.nomeTitular = nomeTitular;

        numerosDeContas.add(numeroConta);
        contasPorNumero.put(numeroConta, this); // adicionar a chave e o objeto atual
        totalDeContas++;
    }

    // Métodos
    public void depositar(Decimal valor) {
        ValidadorFinanceiro.validarValor(valor);
        this.saldo += valor;
    }

    public void sacar(Decimal valor) {
        if (valor <= 0) { //confere com valores negativos 
            throw new NumeroInvalidoException();
        }
        if (valor > this.saldo) {
            throw new SaldoInsuficienteException();
        }
        this.saldo -= valor;
    }

    public static Conta buscarContaPorNumero(Integer numero) {
        return contasPorNumero.get(numero); //se a conta existir, retorna o objeto; se não, retorna null
    }

    public static List<Conta> buscarContas(Set<Integer> numeros) {
        List<Conta> resultado = new List<Conta>();

        for (Integer numero: numeros) {
            if (contasPorNumero.containsKey(numero)) {
                resultado.add(contasPorNumero.get(numero));
            }
        }
        return resultado;
    }

    public abstract Decimal calcularTaxa();
}