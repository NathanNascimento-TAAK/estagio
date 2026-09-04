//Duplicated Contacts
public Boolean duplicateContacts(Contact c1, Contact c2) {
    if(c1.Email == null || c2.Email == null || c1.Phone == null || c2.Phone == null) return false;
    else if((c1.Email == c2.Email) || (c1.Phone == c2.Phone)) return true;
    return false;
}

//Account Rating
public void setAccountRating(Account a) {
    if(a.AnnualRevenue <= 100000) a.Rating = 'Cold';
    else if(a.AnnualRevenue <= 500000) a.Rating = 'Warm';
    else a.Rating = 'Hot';
}

//Contact Birthday
public Boolean isBirthday(Contact c) {
    Date aniversario = c.Birthdate;
    if(Date.today().day() == aniversario.day() && Date.today().month() == aniversario.month()) return true;
    return false;
}

//Key Account
public Boolean isKeyAccount(Account a) {
    if(a.AnnualRevenue != null && a.Industry != null) {
        if(a.Industry == 'Banking' && a.AnnualRevenue >= 600000) return true;
        else if(a.Industry == 'Technology' && a.AnnualRevenue >= 800000) return true;
        else if(a.Industry == 'Retail' && a.AnnualRevenue >= 2000000) return true;
        else if(a.Industry == 'Construction' && a.AnnualRevenue >= 500000) return true;
    }
    return false;
}

//Escalate Case
public void escalateIfMeetsCriteria(Case c) {
    if(c.Type == 'Mechanical' && c.Status == 'Closed' || c.Reason == 'Performance') return;
    if(c.Type == 'Mechanical' || c.Type == 'Electrical' && c.Reason == 'Breakdown' && c.Status == 'In Progress') c.IsEscalated = true;
}

//Same Parent
public Boolean sameParent(Contact c, Opportunity opp) {
    if(String.isBlank(c.AccountId) || String.isBlank(opp.AccountId)) return false;
    if(c.AccountId == opp.AccountId) return true;
    return false;
}

//Same Parent II
public Boolean sameParent(Account acc, Contact con, Opportunity opp) {
    if(String.isBlank(acc.Id)) return false;
    else if(con.AccountId == acc.Id && opp.AccountId == acc.Id) return true;
    else return false;
}

//Set Parent Account
public void setParent(Account acc, Contact con, Opportunity opp) {
    if(acc == null ) {
        con.AccountId = con.AccountId;
        opp.AccountId = opp.AccountId;
    }
    else if(String.isBlank(acc.Id)) {
        return;
    }
    else {
        con.AccountId = acc.Id;
        opp.AccountId = acc.Id;
    }
}

//Set Parent Case
public void linkParent(Case c1, Case c2) {
    if(c1 == null || c2 == null || String.isBlank(c1.ContactId) || String.isBlank(c2.ContactId)) return;
    else if(c1.ContactId == c2.ContactId && c1.CreatedDate > c2.CreatedDate) c1.ParentId = c2.Id;
    else if(c1.ContactId == c2.ContactId && c2.CreatedDate > c1.CreatedDate) c2.ParentId = c1.Id;
    else {
        c1.ParentId = null;
        c2.ParentId = null;
    }
}