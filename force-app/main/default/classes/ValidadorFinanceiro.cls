public with sharing class ValidadorFinanceiro {
    public ValidadorFinanceiro() {

    }

    public static Boolean isValorValido(Decimal valor) {
        if(valor < 0) {
            System.debug('Valor menor que 0: ' + valor);
            return false;
        } else if(valor == 0) {
            System.debug('Valor igual a zero');
            return false;
        }
        System.debug('Valor maior que zero: ' + valor);
        return true;
    }

}