public with sharing class ContaPoupanca extends Conta {
    public ContaPoupanca() {

    }

    public override Decimal calcularTaxa() {
        return this.saldo * 0.005;
    }
}