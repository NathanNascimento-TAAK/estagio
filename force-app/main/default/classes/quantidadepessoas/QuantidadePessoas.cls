public with sharing class QuantidadePessoas {
    private Integer quantidadePessoas { get; set; }
    public QuantidadePessoas(Integer quantidadePessoas) {
        if(quantidadePessoas > 0) {
            this.quantidadePessoas = quantidadePessoas;
        } else {
            throw new IllegalArgumentException('A quantidade de pessoas deve ser maior que zero.');
        }
    }

    public Integer getQuantidadePessoas() {
        return this.quantidadePessoas;
    }
}