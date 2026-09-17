public with sharing class MenorMesaViavel implements PoliticaAlocacaoMesa {
    public MenorMesaViavel() {

    }

    public Mesa selecionarMesa(List<Mesa> mesas, QuantidadePessoas qtdPessoas, LocalMesa localizacao, PeriodoReserva periodo) {
        Mesa menorMesa = new Mesa();
        for (Mesa mesa : mesas) {
            if (mesa.getCapacidade() < qtdPessoas || mesa.getLocalizacao() != localizacao) {
                continue;
            }
            if (menorMesa == null || mesa.getCapacidade().quantidadePessoas < menorMesa.getCapacidade().quantidadePessoas) {
                menorMesa = mesa;
            }
        }
        return menorMesa;
    }
}