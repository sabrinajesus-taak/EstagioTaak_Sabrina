public class ExerciciosApex {

    // Teenager
    public Boolean isTeenager(Integer age) {
        return age >= 13 && age <= 19;
    }

    // Number Difference
    public Integer diff(Integer a, Integer b) {
        if (a > b) {
            return a - b;
        } else {
            return b - a;
        }
    }

    // Sum Equals
    public Boolean sumEquals(Integer a, Integer b, Integer c) {
        Integer soma = a + b;
        if (soma == c) {
            return true;
        } else {
            return false;
        }
    }

    // Ascending Order
    public Boolean ascendingOrder(Integer a, Integer b, Integer c) {
        if (c >= b && b >= a) {
            return true;
        } else {
            return false;
        }
    }

    // A or an
    public String aOrAn(String word) {
        if (word.startsWith('a') || word.startsWith('e') || word.startsWith('i') || word.startsWith('o') || word.startsWith('u')) {
            return 'an ' + word;
        } else {
            return 'a ' + word;
        }
    }

    // Largest of Three
    public static Integer findLargest(Integer num1, Integer num2, Integer num3) {
        if (num1 > num2 && num1 > num3) {
            return num1;
        } else if (num2 > num3) {
            return num2;
        } else {
            return num3;
        }
    }

    // Tip Calculator
    public Decimal computeTip(Decimal total, Integer percent) {
        Decimal porcentagem = percent / 100.0;
        return total * porcentagem;
    }

    // Passing Students
    public Boolean isPassed(Boolean passedExam, Boolean passedAssignments, Boolean passedProject) {
        if ((passedExam == true && passedAssignments == true) || (passedAssignments == true && passedProject == true) || (passedExam == true && passedProject == true)) {
            return true;
        } else {
            return false;
        }
    }

    // Ends With 0
    public Boolean isEndWithZero(Integer num) {
        return Math.mod(num, 10) == 0;
    }

    // Which two
    public String whichTwo(Integer a, Integer b, Integer c) {
        if (a + b == c) {
            return 'c';
        } else if (b + c == a) {
            return 'a';
        } else if (a + c == b) {
            return 'b';
        } else {
            return '';
        }
    }

    // Even or Odd
    public String evenOrOdd(Integer num) {
        if (Math.mod(num, 2) == 0) {
            return 'even';
        } else {
            return 'odd';
        }
    }

    // Rock Paper Scissors
    public Integer rockPaperScissors(String player1, String player2) {
        if ((player1 == 'paper' && player2 == 'rock') || (player1 == 'scissors' && player2 == 'paper') || (player1 == 'rock' && player2 == 'scissors')) {
            return 1;
        } else if ((player2 == 'paper' && player1 == 'rock') || (player2 == 'scissors' && player1 == 'paper') || (player2 == 'rock' && player1 == 'scissors')) {
            return 2;
        } else {
            return 0;
        }
    }

    // Age Group
    public String ageGroup(Integer n) {
        if (n >= 0 && n <= 1) {
            return 'Infant';
        } else if (n <= 14) {
            return 'Child';
        } else if (n <= 21) {
            return 'Youth';
        } else {
            return 'Adult';
        }
    }

    // Companion Plants
    public Boolean companionPlants(String plant1, String plant2) {
        if ((plant1 == 'lettuce' && plant2 == 'cucumbers') || (plant1 == 'lettuce' && plant2 == 'onions') || (plant1 == 'onions' && plant2 == 'carrots') || (plant1 == 'onions' && plant2 == 'tomatoes')) {
            return true;
        } else if ((plant2 == 'lettuce' && plant1 == 'cucumbers') || (plant2 == 'lettuce' && plant1 == 'onions') || (plant2 == 'onions' && plant1 == 'carrots') || (plant2 == 'onions' && plant1 == 'tomatoes')) {
            return true;
        } else {
            return false;
        }
    }

    // Leap Year
    public Boolean isLeapYear(Integer year) {
        if (Math.mod(year, 4) != 0) {
            return false;
        } else if (Math.mod(year, 100) != 0) {
            return true;
        } else if (Math.mod(year, 400) != 0) {
            return false;
        } else {
            return true;
        }
    }

    // Prime Number
    public Boolean isPrime(Integer num) {
        Integer i = 2;
        if (num == 2) {
            return true;
        }

        do {
            if (Math.mod(num, i) == 0) {
                return false;
            }
            i++;
        } while (i < num);
        return true;
    }

    // Sum 1 to N
    public Integer sumToN(Integer n) {
        Integer soma = 0;
        Integer i = 1;
        do {
            soma += i;
            i++;
        } while (i <= n);
        return soma;
    }

    // Full Name
    public String formatName(String firstName, String lastName) {
        return firstName + ' ' + lastName;
    }

    // Format Name
    public String formatName(String firstName, String lastName) {
        if (String.IsBlank(firstName) == true && String.IsBlank(lastName) == true) {
            return '';
        } else if (String.IsBlank(firstName) == true) {
            return lastName;
        } else if (String.IsBlank(lastName) == true) {
            return firstName;
        } else {
            return lastName + ', ' + firstName;
        }
    }

    // Name from Email
    public String nameFromEmail(String email) {
        email = email.toLowerCase();

        String localPart = email.substringBefore('@');

        List<String> parts = localPart.split('\\.');

        String firstName = parts[0];
        String lastName = parts[1];

        String formattedFirstName = firstName.substring(0, 1).toUpperCase() + firstName.substring(1);
        String formattedLastName = lastName.substring(0, 1).toUpperCase() + lastName.substring(1);

        return formattedFirstName + ' ' + formattedLastName;
    }

    // Change Time Format
    public String changeTimeFormat(String strTime) {
        String horas = strTime.substring(0, 2);
        String minutos = strTime.substring(3, 5);

        Integer hora_int = Integer.valueOf(horas);

        if (hora_int == 0) {
            return '12:' + minutos + ' AM';
        } else if (hora_int < 12) {
            return horas + ':' + minutos + ' AM';
        } else if (hora_int == 12) {
            return '12:' + minutos + ' PM';
        } else {
            Integer nova_hora = hora_int - 12;
            String str_horas_2 = String.valueOf(nova_hora).leftPad(2, '0');
            return str_horas_2 + ':' + minutos + ' PM';
        }
    }

    // Fibonacci
    public Integer fibonacci(Integer n) {
        if (n == 1 || n == 2) {
            return 1;
        }

        Integer anterior = 1;
        Integer atual = 1;
        Integer proximo = 0;

        for (Integer i = 3; i <= n; i++) {
            proximo = anterior + atual;
            anterior = atual;
            atual = proximo;
        }

        return atual;
    }

    //next prime
    public Integer nextPrime(Integer num) {
        if (num <= 1) {
            return 2;
        }

        Integer nextNum = num + 1;

        while (true) {
            Boolean primo = true;

            for (Integer i = 2; i < nextNum; i++) {
                if (Math.mod(nextNum, i) == 0) {
                    primo = false;
                    break;
                }
            }

            if (primo) {
                return nextNum;
            } else {
                nextNum += 1;
            }

        }
        return -1;
    }

    //reverse orders of words
    public String reverseWordsInASentence(String sentence){
        if (sentence == null) return null;

        List<String> words = sentence.split(' ');
        String reversed = '';

        for (Integer i = words.size()-1; i >= 0; i--) {
            reversed += words[i];
            if (i != 0)  {
                reversed += ' ';
            }
        }
        return reversed;
    }
}