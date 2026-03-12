public class Documento {
    private final String cpf; //final garante que seja definido apenas uma vez

    public Documento (String cpfEntrada){
        this.cpf = cpfEntrada;
    }

    public String getCpf() {return this.cpf; }

    // O EQUALS: Compara se o conteúdo do CPF é o mesmo
    public Boolean equals(Object obj) {
        if (obj instanceof Documento) {
            Documento outro = (Documento)obj;
            // Se as strings dos CPFs forem iguais, os objetos são iguais
            return this.cpf == outro.cpf;
        }
        return false;
    }
}