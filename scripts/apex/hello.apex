//Exercicio 19

ContaCorrente cc1 = new ContaCorrente();
ContaCorrente cc2 = new ContaCorrente();
ContaPoupanca cp1 = new ContaPoupanca();

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