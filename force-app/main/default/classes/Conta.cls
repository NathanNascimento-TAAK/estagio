public with sharing abstract class Conta {
    public static Integer totalDeContas = 0;
    public Integer numeroConta;
    public String nomeTitular;
    public Decimal saldo;

    public Conta() {
        Conta.totalDeContas++;
        this.saldo = 0;
        this.nomeTitular = '';
    }

    public void depositar(Decimal valor) {
        if(ValidadorFinanceiro.isValorValido(valor)) {
            this.saldo += valor;
        } else {
            System.debug('Não foi possivel realizar o deposito para o valor de: ' + valor);
        }
    }

    public void sacar(Decimal valor) {
        if(ValidadorFinanceiro.isValorValido(valor) && valor <= saldo){
            this.saldo -= valor;
        } else {
            throw new SaldoInsuficienteException('Saldo insuficiente para o saque');
        }
    }

    public abstract Decimal calcularTaxa();
}