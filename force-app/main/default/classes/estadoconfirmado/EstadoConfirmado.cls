public with sharing class EstadoConfirmado extends EstadoReserva {
    public EstadoConfirmado() {

    }

    public override EstadoReserva confirmar() {
        return this;
    }

    public override EstadoReserva cancelar() {
        return new EstadoCancelado();
    }

    public override EstadoReserva promover() {
        return this;
    }
}