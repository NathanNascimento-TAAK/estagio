//clientes

Documento doc1 = new Documento('12345678901');
Documento doc2 = new Documento('98765432109');

Cliente cliente1 = new Cliente(doc1, 'Selmit');
Cliente cliente2 = new Cliente(doc2, 'AnnieMiawn');

System.debug('teste CLIENTES');
System.debug('Cliente 1: ' + cliente1.getNome());
System.debug('CPF 1: ' + cliente1.getDocumento());

System.debug('Cliente 2: ' + cliente2.getNome());
System.debug('CPF 2: ' + cliente2.getDocumento());

//restaurante

Restaurante restaurante = new Restaurante('Restaurante Teste');

System.debug('Nome: ' + restaurante.getNome());



//mesas
Mesa mesa1 = new Mesa(
    new IdentificadorMesa(1),
    new QuantidadePessoas(2),
    LocalMesa.SALAO
);

Mesa mesa2 = new Mesa(
    new IdentificadorMesa(2),
    new QuantidadePessoas(4),
    LocalMesa.SALAO
);

Mesa mesa3 = new Mesa(
    new IdentificadorMesa(3),
    new QuantidadePessoas(6),
    LocalMesa.JARDIM
);

Mesa mesa4 = new Mesa(
    new IdentificadorMesa(4),
    new QuantidadePessoas(8),
    LocalMesa.JARDIM
);

//add mesas ao restaurante

restaurante.adicionarMesa(mesa1);
restaurante.adicionarMesa(mesa2);
restaurante.adicionarMesa(mesa3);
restaurante.adicionarMesa(mesa4);

System.debug('Quantidade de mesas: ' + restaurante.getMesas().size());

//teste de mesa duplicada

try {
    Mesa mesaDuplicada = new Mesa(
        new IdentificadorMesa(1),
        new QuantidadePessoas(10),
        LocalMesa.SALAO
    );
    restaurante.adicionarMesa(mesaDuplicada);
    System.debug('ERRO: mesa duplicada foi adicionada.');

} catch (Exception e) {
    System.debug('Mesa duplicada corretamente rejeitada: ' + e.getMessage());
}


//politicas de mesa

PoliticaAlocacaoMesa politicaMenor = new MenorMesaViavel();

PoliticaAlocacaoMesa politicaMaior = new MaiorMesaDisponivel();

PoliticaPromocaoListaEspera politicaFifo = new FifoListaEspera();


//gerenciador de reserva

GerenciadorReservas gerenciador = new GerenciadorReservas(politicaMenor, politicaFifo);


//buscador de disponibilidade

List<Mesa> mesasDisponiveis =
    gerenciador.buscarDisponibilidade(
        restaurante,
        new QuantidadePessoas(3),
        LocalMesa.SALAO,
        PeriodoReserva.NOITE
    );

System.debug('Mesas disponíveis para 3 pessoas no salão: ' + mesasDisponiveis.size());

for (Mesa mesa : mesasDisponiveis) {
    System.debug('Mesa disponível: ' + mesa.getIdentificador());
}


//criando reservas

Reserva reserva1 = new Reserva(
    cliente1,
    restaurante,
    new QuantidadePessoas(3),
    LocalMesa.SALAO,
    PeriodoReserva.NOITE
);

System.debug('========== RESERVA 1 ==========');
System.debug('Status inicial: ' + reserva1.status);

reserva1.confirmar();

System.debug('Status após confirmação: ' + reserva1.status);


//estados reserva

Reserva reservaTeste =
    new Reserva(
        cliente1,
        restaurante,
        new QuantidadePessoas(2),
        LocalMesa.SALAO,
        PeriodoReserva.TARDE
    );

System.debug('Estado inicial: ' + reservaTeste.status);

reservaTeste.confirmar();

System.debug('Estado após confirmar: ' + reservaTeste.status);

reservaTeste.cancelar();

System.debug('Estado após cancelar: ' + reservaTeste.status);


//promocao de reserva

Reserva reservaPromocao =
    new Reserva(
        cliente2,
        restaurante,
        new QuantidadePessoas(2),
        LocalMesa.SALAO,
        PeriodoReserva.NOITE
    );

System.debug('Estado antes de promover: ' + reservaPromocao.status);

reservaPromocao.promover();

System.debug('Estado após promover: ' + reservaPromocao.status);

// 13. CRIAÇÃO DE RESERVA PELO GERENCIADOR

gerenciador.criarReserva(
    cliente1,
    restaurante,
    new QuantidadePessoas(1),
    LocalMesa.SALAO,
    PeriodoReserva.NOITE,
    false
);

System.debug('Quantidade de reservas no restaurante: ' + restaurante.getReservas().size());

// 14. TESTE DE LISTA DE ESPERA

gerenciador.criarReserva(
    cliente2,
    restaurante,
    new QuantidadePessoas(8),
    LocalMesa.SALAO,
    PeriodoReserva.NOITE,
    true
);

System.debug('Reservas pendentes: ' + restaurante.getReservas().size());

// 15. TESTE DA POLÍTICA MENOR MESA VIÁVEL

List<Mesa> mesasTeste = restaurante.getMesas();

Mesa menorMesa =
    politicaMenor.selecionarMesa(
        mesasTeste,
        new QuantidadePessoas(3),
        LocalMesa.SALAO,
        PeriodoReserva.NOITE
    );

if (menorMesa != null) {
    System.debug('========== MENOR MESA VIÁVEL ==========');

    System.debug('Mesa escolhida: ' + menorMesa.getIdentificador());

    System.debug('Capacidade: ' +  menorMesa.getCapacidade());
}

// 16. TESTE DA POLÍTICA MAIOR MESA DISPONÍVEL

Mesa maiorMesa =
    politicaMaior.selecionarMesa(
        mesasTeste,
        new QuantidadePessoas(3),
        LocalMesa.JARDIM,
        PeriodoReserva.NOITE
    );

if (maiorMesa != null) {
    System.debug('MAIOR MESA DISPONÍVEL');

    System.debug('Mesa escolhida: ' + maiorMesa.getIdentificador());

    System.debug('Capacidade: ' + maiorMesa.getCapacidade());
}

// 17. TESTE DA LISTA FIFO

List<Reserva> reservasPendentes = new List<Reserva>();

Reserva pendente1 =
    new Reserva(
        cliente1,
        restaurante,
        new QuantidadePessoas(4),
        LocalMesa.JARDIM,
        PeriodoReserva.NOITE
    );

Reserva pendente2 =
    new Reserva(
        cliente2,
        restaurante,
        new QuantidadePessoas(4),
        LocalMesa.JARDIM,
        PeriodoReserva.NOITE
);

reservasPendentes.add(pendente1);
reservasPendentes.add(pendente2);

Reserva reservaSelecionada = politicaFifo.selecionarReserva(reservasPendentes, mesa3, PeriodoReserva.NOITE, LocalMesa.JARDIM);

System.debug('FIFO');

if (reservaSelecionada != null) {
    System.debug('Reserva selecionada: ' + reservaSelecionada.cliente.getNome());
} else {
    System.debug('Nenhuma reserva encontrada.');
}

// 18. TESTE DE CANCELAMENTO

if (reserva1 != null) {
    System.debug('CANCELAMENTO');
    System.debug('Status antes: ' + reserva1.status);
    reserva1.cancelar();
    System.debug('Status depois: ' + reserva1.status);
}

// 19. TESTE DO RELATÓRIO

RelatorioReservasService relatorioService = new RelatorioReservasService();

List<Documento> documentos = new List<Documento>();

documentos.add(doc1);
documentos.add(doc2);

List<Restaurante> restaurantes = new List<Restaurante>();

restaurantes.add(restaurante);

Map<Documento, List<Reserva>> relatorio = relatorioService.gerarRelatorioReservasPorCpf(documentos, restaurantes);

System.debug('RELATÓRIO');

for (Documento documento : relatorio.keySet()) {

    System.debug('CPF: ' +documento.getDocumento());

    System.debug('Quantidade de reservas confirmadas: ' + relatorio.get(documento).size());

    for (Reserva reserva : relatorio.get(documento)) {
        System.debug('Restaurante: ' + reserva.restaurante.getNome() + ' | Mesa: ' + (reserva.mesa != null ? String.valueOf(reserva.mesa.getIdentificador()) : 'Sem mesa') + ' | Status: ' + reserva.status);
    }
}

System.debug('TESTES FINALIZADOS');