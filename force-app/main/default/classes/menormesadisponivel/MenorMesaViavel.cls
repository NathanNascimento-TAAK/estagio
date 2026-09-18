public with sharing class MenorMesaViavel implements PoliticaAlocacaoMesa {
    public MenorMesaViavel() {

    }

    public Mesa selecionarMesa(List<Mesa> mesas, QuantidadePessoas qtdPessoas, LocalMesa localizacao, PeriodoReserva periodo) {
        Mesa menorMesa;
        for (Mesa mesa : mesas) {
            if (mesa.getCapacidade() < qtdPessoas.getQuantidadePessoas() || mesa.getLocalizacao() != localizacao) {
                continue;
            }
            if (menorMesa == null || mesa.getCapacidade() < menorMesa.getCapacidade()) {
                menorMesa = mesa;
            }
        }
        return menorMesa;
    }
}