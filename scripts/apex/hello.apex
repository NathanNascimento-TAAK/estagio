//Exercicio 16


ContaCorrente cc1 = new ContaCorrente();

cc1.depositar(1000);

System.debug('eu tenho:' + cc1.saldo);

cc1.sacar(413);
System.debug('eu tenho:' + cc1.saldo);
cc1.sacar(-10);


//Fim