public with sharing abstract class EstadoReserva {
    public EstadoReserva() {

    }

    public abstract EstadoReserva confirmar();

    public abstract EstadoReserva cancelar();

    public abstract EstadoReserva promover();
}