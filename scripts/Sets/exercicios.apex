//Union
public Set<Integer> setUnion(Set<Integer> set1, Set<Integer> set2) {
    Set<Integer> allSets = new Set<Integer>(set1);
    allSets.addAll(set2);
    return allSets;
}

//Intersection
public Set<Integer> setIntersection(Set<Integer> set1, Set<Integer> set2) {
    Set<Integer> newSet = new Set<Integer>();
    
    for(Integer num : set1) {
        if(set2.contains(num))newSet.add(num);
    }

    return newSet;
}

//Related Accounts
public Set<Id> accountIds(List<Opportunity> opps) {
    Set<Id> ids = new Set<Id>();
    for(Opportunity opt : opps) {
        if(!String.isBlank(opt.AccountId)) {
            ids.add(opt.AccountId);
        }
    }
    return ids;
}

//Same Elements
public Boolean sameElements(List<Integer> nums1, List<Integer> nums2) {
    Set<Integer> elements1 = new Set<Integer>(nums1);
    Set<Integer> elements2 = new Set<Integer>(nums2);
    if(elements1.equals(elements2) && elements2.equals(elements1)) return true;
    else return false;
}

//Duplicate Integers
public Boolean containsDuplicates(List<Integer> nums) {
    Set<Integer> duplicates = new Set<Integer>(nums);
    if(duplicates.size() != nums.size()) return true;
    else return false;
}

//Contacts De-duplicatior
public static List<Contact> ContactDeduplicator(List<Contact> contacts) {
    if(contacts == null) return new List<Contact>();
    Set<String> seenEmails = new Set<String>();
    List<Contact> uniqueContacts = new List<Contact>();

    for (Contact ctt : contacts) {
        String email = String.isBlank(ctt.Email) ? '' : ctt.Email.trim().toLowerCase();

        if (!seenEmails.contains(email)) {
            seenEmails.add(email);
            uniqueContacts.add(ctt);
        }
    }

    return uniqueContacts;
}