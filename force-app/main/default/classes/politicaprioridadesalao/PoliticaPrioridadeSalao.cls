public with sharing class PoliticaPrioridadeSalao implements PoliticaAlocacaoMesa {
    public PoliticaPrioridadeSalao() {

    }

    public Mesa selecionarMesa(List<Mesa> mesas, QuantidadePessoas qtdPessoas, LocalMesa localizacao, PeriodoReserva periodo) {
        Mesa menorMesa;
        for (Mesa mesa : mesas) {
            if (mesa.getLocalizacao() == LocalMesa.SALAO && mesa.getCapacidade() >= qtdPessoas.getQuantidadePessoas() && (menorMesa == null || mesa.getCapacidade() < menorMesa.getCapacidade())) {
                menorMesa = mesa;
            }
        }
        return menorMesa != null ? menorMesa : new MenorMesaViavel().selecionarMesa(mesas, qtdPessoas, localizacao, periodo);
    }
}