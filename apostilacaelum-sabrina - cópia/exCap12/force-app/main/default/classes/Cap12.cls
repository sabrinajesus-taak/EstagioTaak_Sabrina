public class Cap12 {

    public class ContaCorrente extends Conta implements Tributavel{

        public ContaCorrente(Integer numeroConta, String nomeTitular) {
            super(numeroConta, nomeTitular);
        }

        public override Decimal calcularTaxa() {
            return this.saldo * 0.01;
        }

        public Decimal calcularImposto() {
            return saldo * 0.02;
        }
    }

    public class ContaPoupanca extends Conta{

        public ContaPoupanca(Integer numeroConta, String nomeTitular) {
            super(numeroConta, nomeTitular);
        }

        public override Decimal calcularTaxa() {
            return this.saldo * 0.05;
        }
    }

    public class CadastroDeContas{
       
        private List<Conta> contas = new List<Conta>();

        //contrutor
        public CadastroDeContas(){
            contas = new List<Conta>();
        }

        public void adicionarConta(Conta novaConta) {
            contas.add(novaConta);
        }

        public void listarContas() {
            for (Conta c: contas){
                System.debug(c);
            }
        }

        public Decimal totalTaxas() {
            Decimal total = 0;
            for (Conta c: contas){
                total += c.calcularTaxa();
            }
            return total;
        }
    }

    public interface Tributavel {
        Decimal calcularImposto();
    }

    public class CalculadoraDeImpostos {
        List<Cap12.Tributavel> tributaveis = new List<Cap12.Tributavel>();

        public CalculadoraDeImpostos(List<Cap12.Tributavel> lista) {
            this.tributaveis = lista;
        }

        public Decimal somaImpostos(){
            Decimal soma = 0;
            for (Cap12.Tributavel t: tributaveis) {
                soma += t.calcularImposto();
            }
            return soma;
        }
    }

    public class SeguroVida implements Tributavel {
        public Decimal calcularImposto() {
            return 42.0;
        }
    }

    public static void tentarSaque(Conta conta, Decimal valor) {
        try {
            conta.sacar(valor); //se throw, vai para o catch
            System.debug('Saque realizado com sucesso.');
        } catch (SaldoInsuficienteException e) { //e é o objeto de excecao
            System.debug(LoggingLevel.ERROR, 
                'Erro ao tentar sacar: saldo insuficiente. Valor solicitado: ' + valor
            );
        } catch (NumeroInvalidoException e) {
            System.debug(LoggingLevel.ERROR, 
                'Erro: valor de saque inválido.'
            );
        }
    }

}