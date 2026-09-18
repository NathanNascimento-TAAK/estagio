public with sharing class Reserva {
    public Cliente cliente { get; set; }
    public Restaurante restaurante { get; set; }
    public Mesa mesa { get; set; }
    public QuantidadePessoas quantidadePessoas { get; set; }
    public LocalMesa localPreferencia{ get; set; }
    public PeriodoReserva periodo { get; set; }
    public EstadoReserva status { get; set; }
    
    public Reserva(Cliente cliente, Restaurante restaurante, QuantidadePessoas quantidadePessoas, LocalMesa localPreferencia, PeriodoReserva periodo) {
        this.cliente = cliente;
        this.restaurante = restaurante;
        this.quantidadePessoas = quantidadePessoas;
        this.localPreferencia = localPreferencia;
        this.periodo = periodo;
        this.mesa = null;
        this.status = new EstadoPendente();
    }

    public void confirmar() {
        status = status.confirmar();
    }

    public void cancelar() {
        status = status.cancelar();
    }

    public void promover() {
        status = status.promover();
    }
}