public with sharing class MaiorMesaDisponivel implements PoliticaAlocacaoMesa {
    public MaiorMesaDisponivel() {

    }

    public Mesa selecionarMesa(List<Mesa> mesas, QuantidadePessoas qtdPessoas, LocalMesa localizacao, PeriodoReserva periodo) {
        Mesa maiorMesa;
        for (Mesa mesa : mesas) {
            if (mesa.getCapacidade() < qtdPessoas.getQuantidadePessoas() || mesa.getLocalizacao() != localizacao) {
                continue;
            }
            if (maiorMesa == null || mesa.getCapacidade() > maiorMesa.getCapacidade()) {
                maiorMesa = mesa;
            }
        }
        return maiorMesa;
    }
}