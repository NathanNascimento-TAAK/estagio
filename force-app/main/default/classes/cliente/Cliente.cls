public with sharing class Cliente {
    private Documento documento;
    private String nome;

    public Cliente(
        Documento documento,
        String nome
    ) {
        this.documento = documento;
        this.nome = nome;
    }

    public Documento getDocumento() {
        return documento;
    }

    public String getNome() {
        return nome;
    }
    
}