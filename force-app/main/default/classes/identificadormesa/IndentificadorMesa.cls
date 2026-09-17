public with sharing class IndentificadorMesa {
    private final Integer identificadorMesa { get; set; }
    public IndentificadorMesa(Integer identificadorMesa) {
        this.identificadorMesa = identificadorMesa;
    }

    public Integer getIdentificadorMesa() {
        return this.identificadorMesa;
    }
}