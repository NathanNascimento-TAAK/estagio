// clientes

Documento documento1 = new Documento('11111111111');
Documento documento2 = new Documento('22222222222');
Documento documento3 = new Documento('33333333333');

Cliente cliente1 = new Cliente(documento1, 'Cliente 1');
Cliente cliente2 = new Cliente(documento2, 'Cliente 2');
Cliente cliente3 = new Cliente(documento3, 'Cliente 3');

// restaurantes e mesas

Restaurante restauranteCentro = new Restaurante('Restaurante Centro');
Restaurante restauranteJardim = new Restaurante('Restaurante Jardim');

Mesa mesaCentro1 = new Mesa(new IdentificadorMesa(1), new QuantidadePessoas(2), LocalMesa.SALAO);

Mesa mesaCentro2 = new Mesa(new IdentificadorMesa(2), new QuantidadePessoas(4), LocalMesa.SALAO);

Mesa mesaJardim1 = new Mesa(new IdentificadorMesa(1), new QuantidadePessoas(6), LocalMesa.JARDIM);

Mesa mesaJardim2 = new Mesa(new IdentificadorMesa(2), new QuantidadePessoas(8), LocalMesa.JARDIM);

restauranteCentro.adicionarMesa(mesaCentro1);
restauranteCentro.adicionarMesa(mesaCentro2);
restauranteJardim.adicionarMesa(mesaJardim1);
restauranteJardim.adicionarMesa(mesaJardim2);

// reservas confirmadas

Reserva reserva1 = new Reserva(cliente1, restauranteCentro, new QuantidadePessoas(2), LocalMesa.SALAO, PeriodoReserva.MANHA);

reserva1.mesa = mesaCentro1;
reserva1.confirmar();
restauranteCentro.registrarReserva(reserva1);

Reserva reserva2 = new Reserva(cliente1, restauranteJardim, new QuantidadePessoas(5), LocalMesa.JARDIM, PeriodoReserva.TARDE);

reserva2.mesa = mesaJardim1;
reserva2.confirmar();
restauranteJardim.registrarReserva(reserva2);

Reserva reserva3 = new Reserva(cliente2, restauranteCentro, new QuantidadePessoas(4), LocalMesa.SALAO, PeriodoReserva.NOITE);

reserva3.mesa = mesaCentro2;
reserva3.confirmar();
restauranteCentro.registrarReserva(reserva3);

Reserva reserva4 = new Reserva(cliente2, restauranteJardim, new QuantidadePessoas(7), LocalMesa.JARDIM, PeriodoReserva.NOITE);

reserva4.mesa = mesaJardim2;
reserva4.confirmar();
restauranteJardim.registrarReserva(reserva4);

// reservas que nao devem aparecer no relatorio

Reserva reservaPendente = new Reserva(cliente3, restauranteCentro, new QuantidadePessoas(2), LocalMesa.SALAO, PeriodoReserva.TARDE);

restauranteCentro.registrarReserva(reservaPendente);

Reserva reservaCancelada = new Reserva(cliente3, restauranteJardim, new QuantidadePessoas(6), LocalMesa.JARDIM, PeriodoReserva.MANHA);

reservaCancelada.confirmar();
reservaCancelada.cancelar();
restauranteJardim.registrarReserva(reservaCancelada);

// execucao do relatorio

RelatorioReservasService relatorioService = new RelatorioReservasService();

List<Documento> documentos = new List<Documento>{documento1, documento2, documento3};

List<Restaurante> restaurantes = new List<Restaurante>{restauranteCentro, restauranteJardim};

Map<Documento, List<Reserva>> relatorio = relatorioService.gerarRelatorioReservas(documentos, restaurantes);

System.debug('RELATORIO DE RESERVAS');

for (Documento documento : documentos) {
    List<Reserva> reservasCliente = relatorio.get(documento);

    System.debug('CPF: ' + documento.getDocumento());
    System.debug('Quantidade de reservas confirmadas: ' + reservasCliente.size());

    for (Reserva reserva : reservasCliente) {
        System.debug('Restaurante: ' + reserva.restaurante.getNome() + ' / Mesa: ' + reserva.mesa.getIdentificador() + ' / Periodo: ' + reserva.periodo + ' / Status: ' + reserva.status);
    }
}