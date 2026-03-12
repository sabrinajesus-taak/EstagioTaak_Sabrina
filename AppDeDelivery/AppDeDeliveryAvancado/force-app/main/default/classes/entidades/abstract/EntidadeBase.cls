public abstract class EntidadeBase{
    private final String Id;
    
    public EntidadeBase() {
        //o generateAesKey cria o id em binario e o convert to hex converte para hexa
        //EncodingUtil é a classe que tem a conversao
        this.id = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
    }

    public Boolean equals(Object obj) { //Se o id for igual é o mesmo obj
        if (obj instanceof EntidadeBase) {
            EntidadeBase other = (EntidadeBase)obj;
            return this.id == other.id;
        }
        return false;
    }

    public Integer hashCode() {
        return System.hashCode(id);//transforma em um número para melhora de busca
    }
}