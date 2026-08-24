// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

// Exercicio 14

interface Tributavel {
    Decimal calcularTributo();
}

abstract class Conta {
    Integer numeroConta;
    String nomeTitular;
    Decimal saldo;

    public Conta() {
        this.numeroConta = 0;
        this.nomeTitular = '';
        this.saldo = 0.0;
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



ContaCorrente cc = new ContaCorrente();
cc.depositar(1000);
ContaCorrente cc2 = new ContaCorrente();
cc2.depositar(500);

CalculadoraDeImpostos calc = new CalculadoraDeImpostos(new List<Tributavel>{cc, cc2});

System.debug('Total de impostos: ' + calc.calcularTodosImpostos().setScale(2));

class SeguroDeVida implements Tributavel {
    public Decimal calcularTributo() {
        return 42;
    }
}

//Fim