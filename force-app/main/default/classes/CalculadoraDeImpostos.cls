public with sharing class CalculadoraDeImpostos {
    List<Tributavel> objsTributaveis = new List<Tributavel>();

    public CalculadoraDeImpostos(List<Tributavel> objs) {
        this.objsTributaveis = objs;
    }

    public Decimal calcularTodosImpostos() {
        Decimal total = 0.0;
        for(Tributavel obj : this.objsTributaveis) {
            total += obj.calcularTributo();
        }
        return total;
    }

}