//Exercicios

//ex12
Conta cTeste = new ContaCorrente();
Conta cConta1 = new ContaCorrente();
Conta cConta2 = new ContaCorrente();
cTeste.numeroConta = 12345;
cTeste.nomeTitular = 'Selmit';
cTeste.depositar(666);
cTeste.depositar(-100);
cConta1.numeroConta = 12346;
cConta1.nomeTitular = 'AnnieMiawn';
cConta1.depositar(1000);
cConta2.numeroConta = 12347;
cConta2.nomeTitular = 'Carlos Birinto';
cConta2.depositar(2000);

CadastroDeContas cadastro = new CadastroDeContas();
cadastro.adicionarConta(cTeste);
cadastro.adicionarConta(cConta1);
cadastro.adicionarConta(cConta2);

cadastro.listarContas();

for (Conta conta : cadastro.listarContas()) {
    System.debug('\nConta: ' + conta.numeroConta + '\nTitular: ' + conta.nomeTitular + '\nSaldo: ' + conta.saldo);
}

//ex14

public Decimal calcularTodasTaxas(List<Conta> contas) {
    Decimal totalTaxas = 0.0;
    for(Conta conta : contas) {
        conta.calcularTaxa();
        if(conta instanceof ContaCorrente) {
            totalTaxas += ((ContaCorrente)conta).calcularTaxa();
        } else if(conta instanceof ContaPoupanca) {
            totalTaxas += ((ContaPoupanca)conta).calcularTaxa();
        }
    }
    return totalTaxas;
}
ContaCorrente ccex = new ContaCorrente();
ccex.numeroConta = 123;
ccex.nomeTitular = 'Selmit';
ContaCorrente cc1 = new ContaCorrente();
ContaPoupanca cp1 = new ContaPoupanca();
ccex.depositar(1000);
ccex.calcularTaxa();

ContaPoupanca cpex = new ContaPoupanca();
cpex.numeroConta = 456;
cpex.nomeTitular = 'AnnieMiawn';
cpex.depositar(1000);
cpex.calcularTaxa();

System.debug('Saldo da Conta Corrente: ' + ccex.saldo);
System.debug('Taxa da Conta Corrente: ' + ccex.calcularTaxa());
System.debug('Saldo da Conta Poupança: ' + cpex.saldo);
System.debug('Taxa da Conta Poupança: ' + cpex.calcularTaxa());

List<Conta> listaContas = new List<Conta>();
listaContas.add(ccex);
listaContas.add(cpex);

System.debug('Total de taxas: ' + calcularTodasTaxas(listaContas).setScale(2, RoundingMode.HALF_UP));

//ex14

ContaCorrente cc = new ContaCorrente();
cc.depositar(1000);
ContaCorrente cc2 = new ContaCorrente();
cc2.depositar(500);

CalculadoraDeImpostos calc = new CalculadoraDeImpostos(new List<Tributavel>{cc, cc2});

System.debug('Total de impostos: ' + calc.calcularTodosImpostos().setScale(2));

//ex15

cc1.depositar(1000);
cc2.depositar(-2000);

System.debug('Saldo das contas:' + '\n' + cc1.saldo + '\n' + cc2.saldo);


//ex16
System.debug('eu tenho:' + cc1.saldo);

cc1.sacar(413);
System.debug('eu tenho:' + cc1.saldo);


//ex19
cc1.depositar(1000);
cc2.depositar(413);
cp1.depositar(2000);

List<Conta> contas = new List<Conta>();

contas.add(cc1);
contas.add(cc2);
contas.add(cp1);

Decimal totalTaxas = 0;

for(Conta conta : contas) {
    totalTaxas += conta.calcularTaxa();
}

System.debug('Total das taxas: ' + totalTaxas);

Set<Integer> numContas = new Set<Integer>();

cc1.numeroConta = 123;
cc2.numeroConta = 321;
cp1.numeroConta = 231;

for(Conta conta : contas) {
    numContas.add(conta.numeroConta);
}

System.debug(numContas);

Map<Integer, Conta> mapaContas = new Map<Integer, Conta>();

mapaContas.put(1, cp1);
mapaContas.put(2, cc1);
mapaContas.put(31, cc2);

System.debug('Conta encontrada: ' + mapaContas.get(31));

numContas.add(111);
numContas.add(222);
numContas.add(666);

List<Conta> contasEncontradas = new List<Conta>();

for(Conta conta : mapaContas.values()) {
    for (Integer numero : numContas) {
        if(numero == conta.numeroConta){
            contasEncontradas.add(conta);
        }
    }
}

System.debug('Contas encontradas: ' + contasEncontradas);

//Fim