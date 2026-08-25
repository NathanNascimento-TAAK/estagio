public with sharing class ContaCorrente extends Conta implements Tributavel {
    public override Decimal calcularTaxa() {
        return this.saldo * 0.01;
    }

    public Decimal calcularTributo() {
        return this.saldo * 0.02;
    }
}