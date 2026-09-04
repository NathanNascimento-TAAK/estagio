//Teenager
public Boolean isTeenager(Integer age) {
    if(age >= 13 && age <= 19) {
        return true;
    }
    return false;
}

//Number Difference
public Integer diff(Integer a, Integer b) {
    if(a > b) return a - b;
    return b - a;
}

//Sum Equals
public Boolean sumEquals(Integer a, Integer b, Integer c) {
    if(a + b == c) return true;
    return false;
}

//Ascending Order
public Boolean ascendingOrder(Integer a, Integer b, Integer c) {
    if(a <= b && b <= c) return true;
    return false;
}

//A or An
public String aOrAn(String word) {
    if(word.startsWith('a') || word.startsWith('e') || word.startsWith('i') || word.startsWith('o') || word.startsWith('u')) return 'an ' + word;
    return 'a ' + word;
}

//Largest of Three
public static Integer findLargest(Integer num1, Integer num2, Integer num3) {
    if(num1 > num2 && num1 > num3) return num1;
    else if(num2 > num1 && num2 > num3) return num2;
    else return num3;
}

//Tip Calculator
public Decimal computeTip(Decimal total, Integer percent) {
    Decimal realPercent = percent * 0.01;
    Decimal resultado = total * realPercent;
    return resultado;
}

//Passing Students
public Boolean isPassed(Boolean passedExam, Boolean passedAssignments, Boolean passedProject) {
    Integer count = 0;
    if(passedExam) count++;
    if(passedProject) count++;
    if(passedAssignments) count++;

    if(count >= 2) return true;
    return false;
}

//Ends with 0
public Boolean isEndWithZero(Integer num){
    if(Math.mod(num, 10) == 0) return true;
    return false;
}

//Which Two
public String whichTwo(Integer a, Integer b, Integer c) {
    if(a + b == c) return 'c';
    else if(a + c == b) return 'b';
    else if(b + a == c) return 'c';
    else if(b + c == a) return 'a';
    else if(c + a == b) return 'b';
    else if(c + b == a) return 'a';
    else return '';
}

//Even or Odd
public String evenOrOdd(Integer num) {
    if(Math.mod(num, 2) == 0) return 'even';
    else return 'odd';
}

//Rock Paper Scissors
public Integer rockPaperScissors(String player1, String player2) {
    
    // empate
    if (player1 == player2) {
        return 0;
    }
    
    // player 1 vence
    if ((player1 == 'rock' && player2 == 'scissors') || (player1 == 'paper' && player2 == 'rock') || (player1 == 'scissors' && player2 == 'paper')) {
        return 1;
    }
    
    // player 2
    if ((player2 == 'rock' && player1 == 'scissors') || (player2 == 'paper' && player1 == 'rock') || (player2 == 'scissors' && player1 == 'paper')) {
        return 2;
    }
    
    return 0;
}

//Age Group
public String ageGroup(Integer n) {
    if(n >= 0 && n <=1) return 'Infant';
    else if(n >= 2 && n <= 14) return 'Child';
    else if(n >= 15 && n <= 21) return 'Youth';
    else return 'Adult';
}

//Companion Plants
public Boolean companionPlants(String plant1, String plant2) {
    
    if ((plant1 == 'lettuce' && plant2 == 'cucumbers') ||
        (plant1 == 'cucumbers' && plant2 == 'lettuce') ||
        
        (plant1 == 'lettuce' && plant2 == 'onions') ||
        (plant1 == 'onions' && plant2 == 'lettuce') ||
        
        (plant1 == 'onions' && plant2 == 'carrots') ||
        (plant1 == 'carrots' && plant2 == 'onions') ||
        
        (plant1 == 'onions' && plant2 == 'tomatoes') ||
        (plant1 == 'tomatoes' && plant2 == 'onions')) {
        return true;
    }
    
    return false;
}



//Leap Year
public Boolean isLeapYear(Integer year) {
    if(Math.mod(year, 4) == 0) {
        if(Math.mod(year, 100) == 0) {
            if(Math.mod(year, 400) == 0) {
                return true;
            }
            return false;
        }
        return true;
    }
    return false;
}

//Prime Number
public Boolean isPrime(Integer num) {
    if(num < 2) return false;
    else {
        for(Integer i = 2; i < num; i++) {
            if(Math.mod(num, i) == 0) {
                return false;
            }
        }
    }
    return true;
}

//Sum 1 to N
public Integer sumToN(Integer n) {
    Integer soma = 0;
    for(Integer i = n; i > 0; i--) {
        soma += i;
    }
    return soma;
}

//Full Name
public String formatName(String firstName, String lastName) {
    return firstName + ' ' + lastName;
}

//Format Name
public String formatName(String firstName, String lastName) {
    String fullName = '';
    if(String.isBlank(firstName) && String.isBlank(lastName)) fullName = '';
    else if(String.isBlank(firstName)) fullName = lastName;
    else if(String.isBlank(lastName)) fullName = firstName;
    else fullName = lastName + ', ' + firstName;
    return fullName;
}

//Name from Email
public String nameFromEmail(String email) {
    String filtro = email.substringBefore('@');

    String firstName = filtro.substringBefore('.');
    String lastName = filtro.substringAfter('.');

    firstName = firstName.toLowerCase();
    lastName = lastName.toLowerCase();


    return firstName.capitalize() + ' ' + lastName.capitalize();
}

//Change Time Format
public String changeTimeFormat(String strTime) {
    String hoursString = strTime.substringBefore(':');
    String minutes = strTime.substringAfter(':');

    Integer hours = Integer.valueOf(hoursString);
    String periodo;

    

    if (hours >= 12) {
        periodo = 'PM';
    } else {
        periodo = 'AM';
    }

    if (hours == 0) {
        hoursString = '12';
    } else if (hours > 12) {
        hoursString = String.valueOf(hours - 12);
    }

    if(hoursString.length() == 1) hoursString = '0' + hoursString;

    return hoursString + ':' + minutes + ' ' + periodo;
}

//Fibonacci
public Integer fibonacci(Integer n) {
    /*
    SIMPLESMENTE O JEITO MAIS DHR DE FAZER porem n funciona nessa linguagem
    List<Integer> fibo = new List<Integer>{0, 1};
    for(Integer i = 0; i < n; i++) {
        fibo = fibo[i] + fibo[i + 1];
        fibo.add(fibo); 
    }
    */
    List<Integer> fibo = new List<Integer>{1, 1};
    Integer addNum;
    for(Integer i = 0; i < n; i++) {
        addNum = fibo[i] + fibo[i + 1];
        fibo.add(addNum); 
    }
    return fibo[n - 1];
}

//Next Prime
public Integer nextPrime(Integer num) {
    if (num < 2) return 2;
    num++;
    while (true) {
        Boolean isPrime = true;

        for (Integer i = 2; i * i <= num; i++) {
            if (Math.mod(num, i) == 0) {
                isPrime = false;
                break;
            }
        }

        if (isPrime) {
            return num;
        }

        num++;
    }
    return num;
}

//Reverse Order of Words
public String reverseWordsInASentence(String sentence){
    if(sentence == '') return '';
    if(sentence == null) return null;
    List<String> palavras = sentence.split(' ');
    String palavraReverse = '';
    
    for(Integer i = palavras.size(); i > 0; i--) {
        palavraReverse = palavraReverse + ' ' + palavras[i - 1];
    }
    
    return palavraReverse.removeStart(' ');
}