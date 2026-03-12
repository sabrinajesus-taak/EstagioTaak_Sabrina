public  class CadastroDeContas {

    private List<Conta> contas = new List<Conta>();

    //construtor
    public CadastroDeContas() {
        contas = new List<Conta>();
    }

    //metodos
    public void adicionarConta(Conta nova_conta) {
        conta.add(nova_conta); //adiciona uma nova conta a lista de contas
    }

    public listarContas(){
        for(Conta c: contas) {
            return c;
        }
    }

    public Decimal totalDeTaxas(List<Conta> lista) {
        Decimal total = 0;
        for (Conta c: lista) {
            total += c.calcularTaxa();
        }
        return total;
    }
}