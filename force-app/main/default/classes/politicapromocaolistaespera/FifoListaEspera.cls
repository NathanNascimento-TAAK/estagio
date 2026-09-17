public with sharing class FifoListaEspera implements PoliticaPromocaoListaEspera {
    public Reserva selecionarReserva(List<Reserva> reservasPendentes, Mesa mesaDisponivel, PeriodoReserva periodo, LocalMesa localPreferencia) {
        for (Reserva reserva : reservasPendentes) {
            if (reserva.periodo == periodo && reserva.localPreferencia == localPreferencia) {
                return reserva;
            }
        }
        return null;
    }
}