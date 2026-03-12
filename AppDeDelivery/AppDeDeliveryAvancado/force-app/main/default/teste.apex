Dinheiro d1 = new Dinheiro(10);
Dinheiro d2 = new Dinheiro(15);
// System.debug(d1.getValor());
// System.debug(d2.getValor());
// System.debug(d1.somar(d2));   ok
// System.debug(d2.subtrair(d1));  ok
// System.debug(d1.multiplicar(2));  ok

Produto pizza = new Produto('Pizza', new Dinheiro(50.00));
Produto suco = new Produto('Suco', new Dinheiro(10.00));
Documento cpfJoao = new Documento('123.456.789-00');
Endereco enderecoJoao = new Endereco('Rua das Flores', '123', 'Bairro Centro', 'São Paulo');
Cliente clienteJoao = new Cliente('João', cpfJoao, enderecoJoao, '123456789');
Pedido pedido01 = new Pedido(clienteJoao);
Time inicio = Time.newInstance(8, 0, 0, 0);
Time fim = Time.newInstance(18, 0, 0, 0);

pizza.alterarPolitica(new PoliticaPrecoPromocionalPorHorario(inicio, fim, 10.0)); //funcionando ok
suco.alterarPolitica( new PoliticaPrecoComDescontoPercentual(10.0));// funcioando
pedido01.adicionarProduto(suco, 1);
pedido01.adicionarProduto(pizza, 1);

System.debug('Total' + pedido01.getTotal());

Endereco enderecoCarla = new Endereco('Rua rua', '123', 'Sp');//funciona
System.debug(enderecoCarla);
System.debug(enderecoJoao);