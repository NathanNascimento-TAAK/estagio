public with sharing class EstadoCancelado extends EstadoReserva {
    public EstadoCancelado() {

    }

    public override EstadoReserva confirmar() {
        return this;
    }

    public override EstadoReserva cancelar() {
        return this;
    }

    public override EstadoReserva promover() {
        return this;
    }
}