Cliente c1 = new Cliente('Ana', '123.456.789-00', 'Rua Central, 123', '(11) 99999-8888');
Cliente c2 = new Cliente('Carlos', '987.654.321-00', 'Rua das Flores, 45', '(11) 98888-7777');
Cliente c3 = new Cliente('Julia', '111.222.333-44', 'Av. Brasil, 100', '(11) 97777-6666');

Produto p1 = new Produto('Pizza Mussarela', 35.00);
Produto p2 = new Produto('Pizza Calabresa', 38.00);
Produto p3 = new Produto('Refrigerante', 8.00);
Produto p4 = new Produto('Pastel', 6.50);

Restaurante r1 = new Restaurante('Bella Pizza', 'Endereço, 123', CategoriaRestaurante.PIZZARIA);
r1.adicionarProduto(p1); //adicionar produto funcionando
//r1.adicionarProduto(p1); regra de produto duplicado funcionando
r1.adicionarProduto(p2);
r1.adicionarProduto(p3);

r1.exibirCardapio(); //exibir cardapio funcionando

Pedido pedido1 = new Pedido(c1, r1);
Pedido pedido2 = new Pedido(c2, r1);
Pedido pedido3 = new Pedido(c3, r1);

pedido1.adicionarItemPedido(p1, 2);
pedido2.adicionarItemPedido(p2, 4);
pedido3.adicionarItemPedido(p3, 1);
//pedido1.adicionarItemPedido(p4, 1); produto que não está no cardapio funcionando
// pedido1.adicionarItemPedido(p1, 3); //somar nova quantidade funcionando
// pedido1.exibirResumo(); //ok 
// pedido1.confirmarPedido(); //funcionado 
// pedido1.exibirResumo();


List<Pedido> pedidosFinalizados = new List<Pedido>();
List<String> cpfs = new List<String>();
pedidosFinalizados.add(pedido1);
pedidosFinalizados.add(pedido2);
pedidosFinalizados.add(pedido3);
cpfs.add(c1.getCpf());
cpfs.add(c2.getCpf());
cpfs.add(c3.getCpf());
GerenciarRelatorios gerenciar1 = new GerenciarRelatorios();
gerenciar1.gerarRelatorioProdutosMaisVendidos(pedidosFinalizados); // funcionando
gerenciar1.gerarRelatorioPedidosPorCliente(pedidosFinalizados, cpfs); //funcionando tbm 