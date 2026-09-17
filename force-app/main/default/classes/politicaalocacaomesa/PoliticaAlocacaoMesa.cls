public interface PoliticaAlocacaoMesa {
    Mesa selecionarMesa(List<Mesa> mesas, QuantidadePessoas qtdPessoas, LocalMesa localizacao, PeriodoReserva periodo);
}