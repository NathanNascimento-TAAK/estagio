public interface PoliticaPromocaoListaEspera {
    Reserva selecionarReserva(List<Reserva> reservas, Mesa mesa, PeriodoReserva periodo, LocalMesa localizacao);
}