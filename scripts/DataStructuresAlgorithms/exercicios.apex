//Implement A Stack
public class Stack {
    
    List<Object> objs = new List<Object>();
    
    public void push(Object obj) {
        objs.add(obj);
    }
    
    public Object pop() {
        if(objs.size() == 0) return null;
        else return objs.remove(objs.size() - 1);
    }
    
    public Integer size() {
        return objs.size();
    }
    
    public Object peek(){
        if(objs.size() == 0) return objs[objs.size()];
        else return objs[objs.size() - 1];
    }
    
    public Boolean isEmpty() {
        if(objs.isEmpty()) return true;
        else return false;
    }
}

//Implement A Singly Linked List


//Valid Palindrome
public Boolean isPalindrome(String str){
    str = str.toLowerCase();
    str = str.replaceAll('[^a-zA-Z0-9]', '');
    String comparacao = '';

    for (Integer i = str.length() - 1; i >= 0; i--) {
        comparacao += str.substring(i, i + 1);
    }

    return str == comparacao;
}

//Merge Two Sorted Lists
public static List<Integer> mergeLists(List<Integer> list1, List<Integer> list2){
    List<Integer> listMerged = new List<Integer>(list1);
    listMerged.addAll(list2);
    listMerged.sort();
    return listMerged;
}

//Binary Search Opportunities
public static Integer search(List<Opportunity> opportunities, Integer target){
    List<Decimal> index = new List<Decimal>();
    for(Opportunity opp : opportunities) {
        index.add(opp.amount);
    }
    return index.indexOf(Decimal.valueOf(target));
}

//Valid Anagram
public boolean isAnagram(String s1, String s2) {
    if (String.isBlank(s1) || String.isBlank(s2) || s1.length() != s2.length()) return false;

    List<String> stringSep1 = new List<String>();
    List<String> stringSep2 = new List<String>();

    for (Integer i = 0; i < s1.length(); i++) {
        stringSep1.add(s1.substring(i, i + 1));
        stringSep2.add(s2.substring(i, i + 1));
    }

    stringSep1.sort();
    stringSep2.sort();

    return stringSep1.equals(stringSep2);
}

//Add One
public void plusOne(List<Integer> numbers) {
    for (Integer i = numbers.size() - 1; i >= 0; i--) {
        if (numbers.get(i) == 9) {
            numbers.set(i, 0);
        } else {
            numbers.set(i, numbers.get(i) + 1);
            return;
        }
    }
    numbers.add(0, 1);
}

//Valid Subsequence


//Reverse Words In String


//Buy Low and Sell High


//Square a sorted list


//Segregate Even and Odd numbers


//Balanced Parentheses


//Defragging


//Two Sum


//Maximum Sub-array


//Two sum II


//Count-and-say the Sequence


//Find Common Characters


//Longest Substring With Max K Distinct Ch


//Same String
