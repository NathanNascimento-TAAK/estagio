

public abstract class Conta {
    //public static Integer totalDeContas = 0;
    static Integer numeroConta;
    String nomeTitular;
    Decimal saldo;

    public Conta() {
        this.numeroConta = 0;
        this.nomeTitular = '';
        this.saldo = 0.0;
        totalDeContas++;
    }

    public void depositar(Decimal valor) {
        if(valor > 0) {
            this.saldo += valor;
        } else {
            System.debug('Valor de depósito inválido: ' + valor);
        }
    }

    public abstract Decimal calcularTaxa();
}

interface Tributavel {
    Decimal calcularTributo();
}

class ContaCorrente extends Conta implements Tributavel {

    public override Decimal calcularTaxa() {
        return this.saldo * 0.01;
    }

    public Decimal calcularTributo() {
        return this.saldo * 0.02;
    }
}

class ContaPoupanca extends Conta {

    public override Decimal calcularTaxa() {
        return this.saldo * 0.005;
    }
}

class CalculadoraDeImpostos {
    List<Tributavel> objsTributaveis = new List<Tributavel>();

    public CalculadoraDeImpostos(List<Tributavel> objs) {
        this.objsTributaveis = objs;
    }

    public Decimal calcularTodosImpostos() {
        Decimal total = 0.0;
        for(Tributavel obj : this.objsTributaveis) {
            total += obj.calcularTributo();
        }
        return total;
    }
}

class SeguroDeVida implements Tributavel {
    public Decimal calcularTributo() {
        return 42;
    }
}

static class ValidadorFinanceiro {
    public Boolean valorValido(Decimal valor){
        if(valor > 0) {
            return true;
        }
        else {
            return false;
        }
    }
}

ContaCorrente contaCorrente = new ContaCorrente();
contaCorrente.depositar(1000);
ContaPoupanca contaPoupanca = new ContaPoupanca();

ValidadorFinanceiro val = new VaidadorFinanceiro();
val.valorValido(1);

val.valorValido(-69);

System.debug('Total de contas: ' + totalDeContas);


//Fim