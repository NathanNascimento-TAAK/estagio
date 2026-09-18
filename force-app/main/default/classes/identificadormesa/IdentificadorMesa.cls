public with sharing class IdentificadorMesa {
    private final Integer identificadorMesa { get; set; }
    public IdentificadorMesa(Integer identificadorMesa) {
        if(identificadorMesa != null) this.identificadorMesa = (Integer) identificadorMesa;
        else System.debug('teste');
    }

    public Integer getIdentificadorMesa() {
        return this.identificadorMesa;
    }
}