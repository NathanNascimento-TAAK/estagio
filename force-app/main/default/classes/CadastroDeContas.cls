public with sharing class CadastroDeContas {
    List<Conta> contas = new List<Conta>();
    public CadastroDeContas() {

    }
    public void adicionarConta(Conta conta) {
        contas.add(conta);
    }
    
    public List<Conta> listarContas() {
        return contas;
    }
}