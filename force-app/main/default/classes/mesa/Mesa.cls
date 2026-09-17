public with sharing class Mesa {
    private IndentificadorMesa identificador;
    private QuantidadePessoas capacidade;
    private LocalMesa localizacao;

    public Mesa(IndentificadorMesa identificador, QuantidadePessoas capacidade, LocalMesa localizacao) {
        this.identificador = identificador;
        this.capacidade = capacidade;
        this.localizacao = localizacao;
    }

    public IndentificadorMesa getIdentificador() {
        return identificador;
    }

    public QuantidadePessoas getCapacidade() {
        return capacidade;
    }

    public LocalMesa getLocalizacao() {
        return localizacao;
    }
}