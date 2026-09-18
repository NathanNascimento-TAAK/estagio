public with sharing class Cliente {
    private Documento documento;
    private String nome;

    public Cliente(Documento documento, String nome) {
        this.documento = documento;
        this.nome = nome;
    }

    public String getDocumento() {
        return documento.getDocumento();
    }

    public String getNome() {
        return nome;
    }
    
}