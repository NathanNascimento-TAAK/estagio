public with sharing class Restaurante {
    private String nome;

    private List<Mesa> mesas;
    private List<Reserva> reservas;

    public Restaurante(String nome) {
        if(String.isBlank(nome)) {
            throw new IllegalArgumentException('Nome do restaurante não pode ser vazio.');
        }
        this.nome = nome;
        this.mesas = new List<Mesa>();
        this.reservas = new List<Reserva>();
    }

    public String getNome() {
        return nome;
    }

    public void adicionarMesa(Mesa mesa) {
        if(mesa == null || mesa.getIdentificador() == null || mesa.getLocalizacao() == null || mesa.getCapacidade() == null || mesa.getCapacidade() == 0) {
            throw new IllegalArgumentException('Não pode ser nulo');
        }
        for (Mesa existente : mesas) {
            if (existente.getIdentificador().equals(mesa.getIdentificador())) {
                throw new RestauranteException('Já existe uma mesa com esse identificador.');
            }
        }

        mesas.add(mesa);
    }

    public void registrarReserva(Reserva reserva) {
        reservas.add(reserva);
    }

    public List<Mesa> getMesas() {
        return new List<Mesa>(mesas);
    }

    public List<Reserva> getReservas() {
        return new List<Reserva>(reservas);
    }
    
    public void adicionarMesas(List<Mesa> mesas) {
        if(mesas == null || mesas.isEmpty()) return;
        for(Mesa mesa : mesas) {
            if(mesa.getCapacidade() > 0 && !this.mesas.contains(mesa)) {
                this.mesas.add(mesa);
                System.debug('Mesa adicionada com sucesso!');
            }
            else {
                System.debug('A mesa desejada já existe ou não há capacidade.');
            }
        }
    }
}