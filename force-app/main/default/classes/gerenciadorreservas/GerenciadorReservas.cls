public with sharing class GerenciadorReservas {
    private List<Reserva> reservas;
    private List<Reserva> reservasPendentes;
    private PoliticaAlocacaoMesa politicaAlocacao;
    private FifoListaEspera politicaPromocaoFifo;

    public GerenciadorReservas() {
        
    }

    public GerenciadorReservas(PoliticaAlocacaoMesa politicaAlocacao, PoliticaPromocaoListaEspera politicaPromocaoFifo) {
        this.reservas = new List<Reserva>();
        this.reservasPendentes = new List<Reserva>();
        this.politicaAlocacao = politicaAlocacao;
        this.politicaPromocaoFifo = politicaPromocaoFifo;
    }

    public void criarReserva(Cliente cliente, Restaurante restaurante, Integer quantidadePessoas, LocalMesa localPreferencia, PeriodoReserva periodo, Boolean aceitaListaEspera) {
        QuantidadePessoas quantidade = new QuantidadePessoas(quantidadePessoas);
        List<Mesa> mesasDisponiveis = buscarDisponibilidade(restaurante, quantidade, localPreferencia, periodo);
        Mesa mesa = politicaAlocacao.selecionarMesa(mesasDisponiveis, quantidade, localPreferencia, periodo);

        Reserva reserva = new Reserva(cliente, restaurante, quantidadePessoas, localPreferencia, periodo);
        if (mesa != null) {
            reserva.mesa = mesa;
            reserva.confirmar();
            reservas.add(reserva);
            restaurante.registrarReserva(reserva);
        } else if (aceitaListaEspera) {
            reservasPendentes.add(reserva);
            restaurante.registrarReserva(reserva);
        }
    }

    public List<Mesa> buscarDisponibilidade(Restaurante restaurante, QuantidadePessoas quantidade, LocalMesa localizacao, PeriodoReserva periodo) {
        List<Mesa> disponiveis = new List<Mesa>();
        for (Mesa mesa : restaurante.getMesas()) {
            if (mesa.getQuantidadePessoas() < quantidade.getQuantidade() || mesa.getLocalizacao() != localizacao) {
                continue;
            }
            Boolean ocupada = false;
            for (Reserva reserva : reservas) {
                if (reserva.restaurante == restaurante && reserva.mesa == mesa && reserva.periodo == periodo && reserva.status instanceof EstadoConfirmado) {
                    ocupada = true;
                    break;
                }
            }
            if (!ocupada) {
                disponiveis.add(mesa);
            }
        }
        return disponiveis;
    }

    public void cancelarReserva(Reserva reserva) {
        Mesa mesaDisponivel = reserva.mesa;
        reserva.cancelar();
        reservas.remove(reservas.indexOf(reserva));
        if (mesaDisponivel == null) {
            return;
        }

        Reserva promovida = politicaPromocaoFifo.selecionarReserva(reservasPendentes, mesaDisponivel, reserva.periodo, reserva.localPreferencia);
        if (promovida != null) {
            promovida.mesa = mesaDisponivel;
            promovida.promover();
            reservasPendentes.remove(reservasPendentes.indexOf(promovida));
            reservas.add(promovida);
        }
    }
}