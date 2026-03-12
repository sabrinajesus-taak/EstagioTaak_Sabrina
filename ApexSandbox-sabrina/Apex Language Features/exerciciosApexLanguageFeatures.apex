public class exerciciosApexLanguageFeatures {
    // sObject Type
    public Boolean isTypeAccount(sObject record) {
        return record instanceof Account;
    }

    // Convert 15-digit ID to 18-digit ID
    public String convert15to18DigitId(String fifteenDigit) {
        String tabela32 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ012345';

        if (fifteenDigit == null || fifteenDigit.length() != 15) {
            return '-1';
        }

        String bloco1 = fifteenDigit.substring(0, 5);
        String bloco2 = fifteenDigit.substring(5, 10);
        String bloco3 = fifteenDigit.substring(10, 15);

        Integer soma_bloco1 = 0;
        for (Integer i = 0; i < bloco1.length(); i++) {
            String c = bloco1.substring(i, i + 1);
            if (c >= 'A' && c <= 'Z') {
                soma_bloco1 += (1 << i);
            }
        }

        Integer soma_bloco2 = 0;
        for (Integer j = 0; j < bloco2.length(); j++) {
            String d = bloco2.substring(j, j + 1);
            if (d >= 'A' && d <= 'Z') {
                soma_bloco2 += (1 << j);
            }
        }

        Integer soma_bloco3 = 0;
        for (Integer k = 0; k < bloco3.length(); k++) {
            String e = bloco3.substring(k, k + 1);
            if (e >= 'A' && e <= 'Z') {
                soma_bloco3 += (1 << k);
            }
        }

        String char_bloco1 = tabela32.substring(soma_bloco1, soma_bloco1 + 1);
        String char_bloco2 = tabela32.substring(soma_bloco2, soma_bloco2 + 1);
        String char_bloco3 = tabela32.substring(soma_bloco3, soma_bloco3 + 1);

        String id18 = fifteenDigit + char_bloco1 + char_bloco2 + char_bloco3;

        return id18;
    }

    // Handle Exception
    public String divide(Integer a, Integer b) {
        try {
            Integer divisao = a / b;
            String divisao_str = String.valueOf(divisao);
            return divisao_str;
        } catch (Exception e) {
            String mensagem = e.getMessage();
            return mensagem;
        }
    }

    // Throw An Exception
    public List<Account> checkAccounts(List<Account> accounts) {
        if (accounts == null) {
            throw new IllegalArgumentException('accounts should not be null');
        }

        for (Account c : accounts) {
            if (c.BillingCity == null) {
                throw new AccountException('Invalid BillingCity');
            }
        }

        return accounts;
    }

    // do not remove the following custom-defined exception
    public class AccountException extends Exception {}

    // Safe Navigation Operator
    public String getAccountBillingCityWithSafeNavigation(List<Account> accounts) {
        String cidade = accounts?.get(0)?.BillingCity?.toUpperCase();
        return cidade;
    }

    // Dynamic Field Values
    public List<String> getFieldsValue(Account acc, List<String> fields) {
        List<String> resultado = new List<String>();

        for (String name : fields) {
            Object valor = acc.get(name);
            String strValor = String.valueOf(valor);
            resultado.add(strValor);
        }

        return resultado;
    }

    // Serialize sObjects
    public String getAccountsInJSONFormat(List<Account> accounts) {
        String accountsJson = JSON.serialize(accounts);
        return accountsJson;
    }

    // List of sObjects
    public List<sObject> getListOfsObject(List<Account> accounts, List<Contact> contacts) {
        List<SObject> resultado = new List<SObject>();

        if (accounts != null && !accounts.isEmpty()) {
            resultado.addAll(accounts);
        }

        if (contacts != null && !contacts.isEmpty()) {
            resultado.addAll(contacts);
        }

        return resultado;
    }

    // Deserialize sObjects
    public List<Account> getAccountsFromJSONString(String inputJSON) {
        if (inputJSON == null || inputJSON == '') {
            return null;
        }

        List<Account> accounts = (List<Account>) JSON.deserialize(inputJSON, List<Account>.class);

        return accounts;
    }

    // Context User
    public Map<String, String> getContextUserInformation() {
        Map<String, String> userMap = new Map<String, String>();

        userMap.put('UserName', UserInfo.getUserName());
        userMap.put('ProfileId', UserInfo.getProfileId());
        userMap.put('EmailId', UserInfo.getUserEmail());
        userMap.put('Type', UserInfo.getUserType());

        return userMap;
    }

    // Trigger Validation
    public void validateInsert(List<Opportunity> opportunities) {
        for (Opportunity opp : opportunities) {
            if (opp.StageName == 'Closed Won' && String.isBlank(opp.Description)) {
                opp.Description.addError('Description should not be empty for Closed Won opportunity.');
            }
        }
    }

    // Sort List of sObjects
    public List<Account> getAccounts(List<Account> accounts) {
        List<Account> contasOrdenadas = new List<Account>(accounts);

        for (Integer i = 0; i < contasOrdenadas.size() - 1; i++) {
            for (Integer j = 0; j < contasOrdenadas.size() - i - 1; j++) {
                if (contasOrdenadas[j].AnnualRevenue < contasOrdenadas[j + 1].AnnualRevenue) {
                    Account temp = contasOrdenadas[j];
                    contasOrdenadas[j] = contasOrdenadas[j + 1];
                    contasOrdenadas[j + 1] = temp;
                }
            }
        }

        return contasOrdenadas;
    }

    // write extra class here

}