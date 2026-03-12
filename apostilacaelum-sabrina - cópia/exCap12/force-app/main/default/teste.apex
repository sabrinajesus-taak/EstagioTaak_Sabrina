Cap12.ContaCorrente c1 = new Cap12.ContaCorrente(1, 'Sabrina');
Conta c2 = new Cap12.ContaPoupanca(2, 'Luis');
Cap12.ContaCorrente c3 = new Cap12.ContaCorrente(3, 'Maria');
//Cap12.ContaCorrente c4 = new Cap12.ContaCorrente(3, 'Claudia');

Cap12.CadastroDeContas cadastro = new Cap12.CadastroDeContas();

c1.depositar(100.0);
c2.depositar(300.0);
c3.depositar(500.0);

cadastro.adicionarConta(c1); //conta corrente
cadastro.adicionarConta(c2);
cadastro.adicionarConta(c3); // conta corrente

List<Cap12.Tributavel> tributaveis = new List<Cap12.Tributavel>();
tributaveis.add(c1);

Cap12.CalculadoraDeImpostos calculadoraImpostos =
    new Cap12.CalculadoraDeImpostos(tributaveis);

Decimal totalImpostos = calculadoraImpostos.somaImpostos();
// System.debug(totalImpostos);
// System.debug(c1.nomeTitular);
// System.debug(c1.saldo);
// System.debug(c2.saldo);

// Cap12.tentarSaque(c1, 1000);
//c1.sacar(1000);

// System.debug(cadastro.totalTaxas());

//Conta contaEncontrada = Conta.buscarContaPorNumero(1);
//System.debug(contaEncontrada.nomeTitular);

Set<Integer> numeros = new Set<Integer>{1, 2, 99};

List<Conta> contasEncontradas = Conta.buscarContas(numeros);

for (Conta c : contasEncontradas) {
    System.debug(c);
}

