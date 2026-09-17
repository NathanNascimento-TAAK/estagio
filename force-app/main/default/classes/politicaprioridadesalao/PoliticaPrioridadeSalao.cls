public with sharing class PoliticaPrioridadeSalao implements PoliticaAlocacaoMesa {
    public PoliticaPrioridadeSalao() {

    }

    public Mesa selecionarMesa(List<Mesa> mesas, QuantidadePessoas qtdPessoas, LocalMesa localizacao, PeriodoReserva periodo) {
        Mesa menorMesa = new Mesa();
        for (Mesa mesa : mesas) {
            if (mesa.getLocalizacao() == LocalMesa.SALAO && mesa.getCapacidade() >= qtdPessoas && (menorMesa == null || mesa.getCapacidade().quantidadePessoas < menorMesa.getCapacidade().quantidadePessoas)) {
                menorMesa = mesa;
            }
        }
        return menorMesa != null ? menorMesa : new MenorMesaViavel().selecionarMesa(mesas, qtdPessoas, localizacao, periodo);
    }
}