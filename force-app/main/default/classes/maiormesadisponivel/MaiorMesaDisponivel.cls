public with sharing class MaiorMesaDisponivel implements PoliticaAlocacaoMesa {
    public MaiorMesaDisponivel() {

    }

    public Mesa selecionarMesa(List<Mesa> mesas, QuantidadePessoas qtdPessoas, LocalMesa localizacao, PeriodoReserva periodo) {
        Mesa maiorMesa = new Mesa();
        for (Mesa mesa : mesas) {
            if (mesa.getCapacidade() < qtdPessoas || mesa.getLocalizacao() != localizacao) {
                continue;
            }
            if (maiorMesa == null || mesa.getCapacidade().quantidadePessoas > maiorMesa.getCapacidade().quantidadePessoas) {
                maiorMesa = mesa;
            }
        }
        return maiorMesa;
    }
}