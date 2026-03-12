public class ValidadorFinanceiro {
        
    public static void validarValor(Decimal valor){
        if (valor <= 0) {
            throw new NumeroInvalidoException(); //para o codigo e lanca a mensagem de erro
        }
    }
}