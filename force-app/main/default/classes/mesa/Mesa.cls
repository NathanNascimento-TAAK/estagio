public with sharing class Mesa {
    private IdentificadorMesa identificador;
    private QuantidadePessoas capacidade;
    private LocalMesa localizacao;

    public Mesa(IdentificadorMesa identificador, QuantidadePessoas capacidade, LocalMesa localizacao) {
        if(identificador == null || capacidade == null || localizacao == null) {
            throw new IllegalArgumentException('Identificador, capacidade e localizacao não podem ser nulos.');
        }
        this.identificador = identificador;
        this.capacidade = capacidade;
        this.localizacao = localizacao;
    }

    public Integer getIdentificador() {
        return identificador.getIdentificadorMesa();
    }

    public Integer getCapacidade() {
        return capacidade.getQuantidadePessoas();
    }

    public LocalMesa getLocalizacao() {
        return localizacao;
    }
}