public class PoliticaPrecoPromocionalPorHorario implements PoliticaDePreco {
    private Time horaInicio;
    private Time horaFim;
    private Decimal desconto;
   
    public PoliticaPrecoPromocionalPorHorario (Time horaInicio, Time horaFim, Decimal desconto) {
        this.horaInicio = horaInicio;
        this.horaFim = horaFim;
        this.desconto = desconto;
    }
    
    public Dinheiro calcularPreco(Produto produto){

        Time agora = Datetime.now().time();
        
        if (agora >= horaInicio && agora <= horaFim) {
            Decimal fatorDesconto = this.desconto / 100.0;
            return produto.getPrecoBase().subtrair(produto.getPrecoBase().multiplicar(fatorDesconto));
        }
        
        return produto.getPrecoBase();
    }
}