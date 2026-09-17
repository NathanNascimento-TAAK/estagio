public with sharing class EstadoPendente extends EstadoReserva {
    public EstadoPendente() {

    }

    public override EstadoReserva confirmar() {
        return new EstadoConfirmado();
    }

    public override EstadoReserva cancelar() {
        return new EstadoCancelado();
    }

    public override EstadoReserva promover() {
        return new EstadoConfirmado();
    }
}