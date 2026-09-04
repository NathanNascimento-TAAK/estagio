//sObject Type
public Boolean isTypeAccount(sObject record)
{
    if(record instanceof Account) return true;
    return false;
}

//Convert 15-digit ID to 18-digit ID
public String convert15to18DigitId(String fifteenDigit)
{
    if(fifteenDigit == null) return '';
    if(fifteenDigit.length() != 15) return '-1';
    ID id = (ID) fifteenDigit;
    return id;
}

//Handle Exception
public String divide(Integer a, Integer b){
    if(a == 0 || b == 0) return 'Divide by 0';
    if(a == null || b == null) return 'Attempt to de-reference a null object';
    return String.valueOf(a / b);
}

//Throw An Exception
public List<Account> checkAccounts(List<Account> accounts)
{

    if(accounts == null) throw new IllegalArgumentException('accounts should not be null');
    
    for(Account account : accounts) {
        if(account.BillingCity == '' || account.BillingCity == null) {
            throw new AccountException('Invalid BillingCity');
        }
    }
    return accounts;

}

//do not remove the following custom-defined exception
public class AccountException extends Exception {}

//Safe Navigation Operator
public String getAccountBillingCityWithSafeNavigation(List<Account> accounts){
   return accounts[0].BillingCity?.toUpperCase();
}

//Dynamic Field Values
public List<String> getFieldsValue(Account acc, List<String> fields)
{
    List<String> campos = new List<String>();

    for(String field : fields) {
        if(acc.get(field) != null || acc.get(field) != '') campos.add(String.valueOf(acc.get(field)));
    }
    return campos;
}

//Serialize sObjects
public String getAccountsInJSONFormat(List<Account> accounts){
  return JSON.serialize(accounts);
}

//List sObjects
public List<sObject> getListOfsObject(List<Account> accounts, List<Contact> contacts)
{
    List<sObject> allObjects = new List<sObject>();
    
    if(accounts == null && contacts == null) return new List<sObject>();
    
    if(accounts != null) {
        for(Account account : accounts) {
            allObjects.add(account);
        }
    }
    
    if(contacts != null) {
        for(Contact contact : contacts) {
            allObjects.add(contact);
        }
    }

    return allObjects;
}

//Desserealize Objects
public List<Account> getAccountsFromJSONString(String inputJSON){
    if(String.isBlank(inputJSON)) return null;
    return (List<Account>) JSON.deserialize(inputJSON, List<Account>.class);
}

//Context User
public Map<String,String> getContextUserInformation(){
    Map<String, String> userInfoMap = new Map<String, String>();
    userInfoMap.put('EmailId', UserInfo.getUserEmail());
    userInfoMap.put('ProfileId', UserInfo.getProfileId());
    userInfoMap.put('Type', UserInfo.getUserType());
    userInfoMap.put('UserName', UserInfo.getUserName());
    return userInfoMap;
}

//Trigger Validation
public void validateInsert(List<Opportunity> opportunities){
    for(Opportunity opportunity : opportunities) {
        if(opportunity.StageName == 'Closed Won' && String.isBlank(opportunity.Description)) {
            opportunity.Description.addError('Description should not be empty for Closed Won opportunity.');
        }
    }
}

//Sort List of sObjects
public List<Account> getAccounts(List<Account> accounts) {
    if (accounts == null) {
        return new List<Account>();
    }

    List<AccountWrapper> wrappers = new List<AccountWrapper>();

    for (Account acc : accounts) {
        wrappers.add(new AccountWrapper(acc));
    }

    wrappers.sort();

    List<Account> result = new List<Account>();

    for (AccountWrapper wrapper : wrappers) {
        result.add(wrapper.account);
    }

    return result;
}
// write extra class here -- consertar dps -- lembrar
public class AccountWrapper implements Comparable {
    public Account account;

    public AccountWrapper(Account account) {
        this.account = account;
    }

    public Integer compareTo(Object obj) {
        AccountWrapper other = (AccountWrapper)obj;

        Decimal thisRevenue = account.AnnualRevenue == null
            ? 0
            : account.AnnualRevenue;

        Decimal otherRevenue = other.account.AnnualRevenue == null
            ? 0
            : other.account.AnnualRevenue;

        // Descending order
        if (thisRevenue > otherRevenue) {
            return -1;
        } else if (thisRevenue < otherRevenue) {
            return 1;
        }

        return 0;
    }
}