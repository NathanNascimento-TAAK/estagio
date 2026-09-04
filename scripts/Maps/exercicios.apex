//Employee Email
public String employeeEmail(Map<String, String> employeeIdToEmail, String employeeId) {
    if(employeeIdToEmail.containsKey(employeeId)) return employeeIdToEmail.get(employeeId);
    else return 'info@apexsandbox.io';
}

//Phonebook
public Map<String, String> phonebook(List<Contact> contacts) {
    Map<String, String> livroCtts = new Map<String, String>();
    for(Contact ctt : contacts) {
        if(!String.isBlank(ctt.Phone)) {
            livroCtts.put(ctt.Name, ctt.Phone);
        }
    }
    return livroCtts;
}

//Phone to Account
public Map<String, Account> phoneToAccount(List<Account> accounts) {
    Map<String, Account> accountPhone = new Map<String, Account>();
    for(Account acc : accounts) {
        if(!String.isBlank(acc.Phone)) {
            accountPhone.put(acc.Phone, acc);
        }
    }
    return accountPhone;
}

//Industry Summary
public Map<String, Decimal> industrySummary(List<Account> accounts) {
    Map<String, Decimal> sumario = new Map<String, Decimal>();
    for(Account acc : accounts) {
        if(sumario.containsKey(acc.Industry)) {
            Decimal valorAtual = sumario.get(acc.Industry);
            valorAtual += acc.AnnualRevenue;
            sumario.put(acc.Industry, valorAtual);
        }
        else {
            sumario.put(acc.Industry, acc.AnnualRevenue);
        }
    }
    return sumario;
}

//Cases by Type
public Map<String, List<Case>> casesByType(List<Case> cases) {
    
    Map<String, List<Case>> casoPorTipo = new Map<String, List<Case>>();

    for (Case caso : cases) {
        if (caso.Type != null) {
            if (casoPorTipo.containsKey(caso.Type)) {
                casoPorTipo.get(caso.Type).add(caso);
            } else {
                casoPorTipo.put(caso.Type, new List<Case>{ caso });
            }
        }
    }

    return casoPorTipo;

}