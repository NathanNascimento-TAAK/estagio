//Sorting a List
public List<String> getNamesInAscOrder(List<String> accountNames)
{
    if(accountNames == null) return null;
    accountNames.sort();
    return accountNames;
}


//Array Sum
public static Integer arraySum(List<Integer> numbers) {
    Integer soma = 0;
    for(Integer numero : numbers) {
        soma += numero;
    }
    return soma;
}

//Count Target in List
public Integer findTargetCount(List<Integer> nums, Integer target) {
    Integer count = 0;
    for(Integer i = 0; i < nums.size(); i++) {
        if(nums[i] == target) {
            count++;
        }
    }
    return count;
}

//Last Occurrence
public static Integer findLast(List<Integer> nums, Integer target) {
    if(!nums.contains(target)) return -1;
    Integer lastIndex = 0;
    Integer i = 0;
    for(Integer numb : nums) {
        if(numb == target) lastIndex = i; 
        i++;
    }

    return lastIndex;
}

//Even Numbers
public List<Integer> evenNumbers(Integer n) {
    Integer numbToAdd = 0;
    List<Integer> even = new List<Integer>();
    for(Integer i = n; i > 0; i--) {
        numbToAdd += 2;
        even.add(numbToAdd);
    }
    return even;
}

//Largest Element
public static Integer findLargest(List<Integer> nums) {
	nums.sort();
    return nums[nums.size() - 1];
}

//Positive Integers
public List<Integer> positiveIntegers(List<Integer> numbers) {
    List<Integer> positivos = new List<Integer>();
    for(Integer numb : numbers) {
        if(numb > 0) positivos.add(numb);
    }
    return positivos;
}

//Consecutive Ones
public Integer maxConsecutiveOnes(Integer[] numbers) {
    Integer consecutivos = 0;
    Integer maxConsec = 0;

    for (Integer i = 0; i < numbers.size(); i++) {
        if (numbers[i] == 1) {
            consecutivos++;
            if (consecutivos > maxConsec) {
                maxConsec = consecutivos;
            }
        } else {
            consecutivos = 0;
        }
    }

    return maxConsec;
}

//Number Avarage
public Decimal average(List<Decimal> numbers){
    Decimal media = 0;
    
    for(Decimal num : numbers) {
        media += num;
    }

    media = media / numbers.size();

    return media.setScale(2);
}

//Insert at Beginning
public void insertAtStart(String cityName, List<String> cities) {
    if(cities.size() == 0) cities.add(cityName);
    else cities.add(0, cityName);
}

//Full Names
public List<String> fullNames(List<String> firstNames, List<String> lastNames) {
    List<String> nomes = new List<String>();
    if(firstNames.size() == 0 || lastNames.size() == 0) return new List<String>();
    for(Integer i = 0; i < firstNames.size(); i++) {
        String nomeCompleto = firstNames[i] + ' ' + lastNames[i];
        nomes.add(nomeCompleto);
    }
    return nomes;
}

//Companion Plants 2
public Boolean companionPlants(List<String> plants) {
    if(plants.size() == 1) return false;
    for (Integer i = 0; i < plants.size() - 1; i++) {
        String first = plants[i];
        String second = plants[i + 1];

        if (first == 'onions') {
            if (second != 'lettuce' && second != 'carrots' && second != 'tomatoes') {
                return false;
            }
        } else if (first == 'lettuce') {
            if (second != 'cucumbers' && second != 'onions') {
                return false;
            }
        } else if (first == 'cucumbers') {
            if (second != 'lettuce') {
                return false;
            }
        } else if (first == 'carrots') {
            if (second != 'onions') {
                return false;
            }
        } else if (first == 'tomatoes') {
            if (second != 'onions') {
                return false;
            }
        } else {
            return false;
        }
    }

    return true;
}

//Fibonacci Series
public List<Integer> fibonacciSeries(Integer n) {
    if(n == 1) return new List<Integer>{1};
    n -= 2;
    List<Integer> fibonacci = new List<Integer>{1, 1};
    Integer numToAdd = 0;
    for(Integer i = 0; i < n; i++) {
        numToAdd = fibonacci[i] + fibonacci[i + 1];
        fibonacci.add(numToAdd);
    }

    return fibonacci;
}

//Org Names
public List<String> orgNames(List<String> adjectives, List<String> animals) {
    List<String> nomes = new list<String>();
    for(Integer i = 0; i < adjectives.size(); i++) {
        for(Integer j = 0; j < animals.size(); j++) {
            String nomeComposto = adjectives[i] + '-' + animals[j];
            nomes.add(nomeComposto);
        }
    }
    return nomes;
}

//Sorted List
public boolean isSorted(List<Integer> numbers) {
    List<Integer> numsSorted = new List<Integer>(numbers);
    numsSorted.sort();
    List<Integer> numsReverseSort = new List<Integer>();
    for(Integer i = numsSorted.size() - 1; i >= 0; i--) {
        numsReverseSort.add(numsSorted[i]);
    }

    if(numbers.equals(numsSorted) || numbers.equals(numsReverseSort)) return true;
    else return false;
}

//Second Largest Element
public Integer secondLargest(List<Integer> numbers) {
    Set<Integer> numsSet = new Set<Integer>();
    numbers.sort();
    numsSet.addAll(numbers);
    List<Integer> nums = new List<Integer>(numsSet);
    return nums[nums.size() - 2];
}