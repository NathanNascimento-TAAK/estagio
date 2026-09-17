public with sharing class Documento {
    private final string documento { get; set; }
    public Documento(string documento) {
        if(validarDocumento(documento)) this.documento = documento;
        else throw new IllegalArgumentException('Documento inválido. O documento deve conter 11 dígitos e não pode ser nulo ou vazio.');
    }

    public Boolean validarDocumento(string documento) {
        if(!String.isBlank(documento) && documento.length() == 11) return true;
        else return false;
    }

    public String getDocumento() {
        return documento;
    }

}