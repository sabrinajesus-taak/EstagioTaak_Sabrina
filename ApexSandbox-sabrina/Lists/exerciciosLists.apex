public class exerciciosLists {
    // Sorting a List
    public List<String> getNamesInAscOrder(List<String> accountNames) {
        if (accountNames == null) {
            return null;
        }

        accountNames.sort();

        return accountNames;
    }

    // Array Sum
    public static Integer arraySum(List<Integer> numbers) {
        Integer sum = 0;

        if (numbers != null) {
            for (Integer num : numbers) {
                sum += num;
            }
        }
        return sum;
    }

    // Count Target in List
    public Integer findTargetCount(List<Integer> nums, Integer target) {
        Integer conta = 0;
        for (Integer n : nums) {
            if (n == target) {
                conta += 1;
            }
        }
        return conta;
    }

    // Last Occurrence
    public static Integer findLast(List<Integer> nums, Integer target) {
        for (Integer i = nums.size() - 1; i >= 0; i--) {
            if (nums.get(i) == target) {
                return i;
            }
        }

        return -1;
    }

    // Even Numbers
    public List<Integer> evenNumbers(Integer n) {
        List<Integer> num_par = new List<Integer>();
        Integer i = 2;
        Integer conta = 0;

        if (n <= 0) return num_par;

        do {
            num_par.add(i);
            i += 2;
            conta += 1;
        } while (conta < n);

        return num_par;
    }

    // Largest Element
    public static Integer findLargest(List<Integer> nums) {
        Integer maior = nums.get(0);

        for (Integer num : nums) {
            if (num > maior) {
                maior = num;
            }
        }
        return maior;
    }

    // Positive Integers
    public List<Integer> positiveIntegers(List<Integer> numbers) {
        List<Integer> lista_positivos = new List<Integer>();

        for (Integer n : numbers) {
            if (n > 0) {
                lista_positivos.add(n);
            }
        }
        return lista_positivos;
    }

    // Consecutive Ones
    public Integer maxConsecutiveOnes(Integer[] numbers) {
        Integer conta_ums = 0;
        Integer maximo = 0;

        for (Integer n : numbers) {
            if (n == 1) {
                conta_ums += 1;
                if (conta_ums > maximo) {
                    maximo = conta_ums;
                }
            } else {
                conta_ums = 0;
            }
        }
        return maximo;
    }

    // Number Average
    public Decimal average(List<Decimal> numbers) {
        Decimal soma = 0;

        for (Decimal n : numbers) {
            soma += n;
        }

        Decimal media = soma / numbers.size();
        return media.setScale(2); // reduz a 2 casas decimais
    }

    // Insert at Beginning
    public void insertAtStart(String cityName, List<String> cities) {
        if (cities.isEmpty()) {
            cities.add(cityName);
        } else {
            cities.add(0, cityName);
        }
    }

    // Full Names
    public List<String> fullNames(List<String> firstNames, List<String> lastNames) {
        List<String> nomes = new List<String>();

        for (Integer i = 0; i < firstNames.size(); i++) {
            String nome_completo = firstNames.get(i) + ' ' + lastNames.get(i);
            nomes.add(nome_completo);
        }
        return nomes;
    }

    // Companion Plants 2
    public Boolean companionPlants(List<String> plants) {
        if (plants.isEmpty()) {
            return true;
        }

        for (Integer i = 0; i < plants.size(); i++) {
            String atual = plants.get(i);
            Boolean temCompanheiro = false;

            if (i > 0) {
                String esquerda = plants.get(i - 1);
                if ((atual == 'onions' && (esquerda == 'tomatoes' || esquerda == 'carrots')) ||
                    (atual == 'tomatoes' && esquerda == 'onions') ||
                    (atual == 'carrots' && esquerda == 'onions')) {
                    temCompanheiro = true;
                }
            }

            if (!temCompanheiro && i + 1 < plants.size()) {
                String direita = plants.get(i + 1);
                if ((atual == 'onions' && (direita == 'tomatoes' || direita == 'carrots')) ||
                    (atual == 'tomatoes' && direita == 'onions') ||
                    (atual == 'carrots' && direita == 'onions')) {
                    temCompanheiro = true;
                }
            }

            if (!temCompanheiro) {
                return false;
            }
        }

        return true;
    }

    // Fibonacci Series
    public List<Integer> fibonacciSeries(Integer n) {
        List<Integer> sequence = new List<Integer>();

        if (n <= 0) {
            return sequence;
        }

        sequence.add(1);

        if (n == 1) {
            return sequence;
        }

        sequence.add(1);

        for (Integer i = 2; i < n; i++) {
            Integer nextVal = sequence.get(i - 1) + sequence.get(i - 2);
            sequence.add(nextVal);
        }

        return sequence;
    }

    // Org Names
    public List<String> orgNames(List<String> adjectives, List<String> animals) {
        List<String> orgs = new List<String>();

        for (Integer i = 0; i < adjectives.size(); i++) {
            for (Integer j = 0; j < animals.size(); j++) {
                String resultado = adjectives.get(i) + '-' + animals.get(j);
                orgs.add(resultado);
            }
        }
        return orgs;
    }

    // Sorted List
    public boolean isSorted(List<Integer> numbers) {
        if (numbers == null || numbers.size() <= 1) {
            return true;
        }

        Boolean crescente = true;
        Boolean decrescente = true;

        for (Integer i = 1; i < numbers.size(); i++) {
            if (numbers.get(i) < numbers.get(i - 1)) {
                crescente = false;
            }

            if (numbers.get(i) > numbers.get(i - 1)) {
                decrescente = false;
            }
        }

        return crescente || decrescente;
    }

    // Second Largest Element
    public Integer secondLargest(List<Integer> numbers) {
        Integer primeiro_maior = -2147483647 - 1;
        Integer segundo_maior = -2147483647 - 1;

        for (Integer i = 0; i < numbers.size(); i++) {
            Integer atual = numbers.get(i);

            if (atual > primeiro_maior) {
                segundo_maior = primeiro_maior;
                primeiro_maior = atual;
            } else if (atual > segundo_maior && atual < primeiro_maior) {
                segundo_maior = atual;
            }
        }

        return segundo_maior;
    }

}