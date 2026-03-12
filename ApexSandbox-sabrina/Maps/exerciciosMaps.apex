public class exerciciosMaps {
    // Employee Email
    public String employeeEmail(Map<String, String> employeeIdToEmail, String employeeId) {
        if (employeeIdToEmail != null && employeeIdToEmail.containsKey(employeeId)) {
            return employeeIdToEmail.get(employeeId); // retorna o email referente ao Id no get
        }
        return 'info@apexsandbox.io';
    }

    // Phonebook
    public Map<String, String> phonebook(List<Contact> contacts) {
        Map<String, String> telefone = new Map<String, String>();
        if (contacts != null) {
            for (Contact c : contacts) {
                if (c.Phone != null) {
                    telefone.put(c.Name, c.Phone);
                }
            }
        }
        return telefone;
    }

    // Phone to Account
    public Map<String, Account> phoneToAccount(List<Account> accounts) {
        Map<String, Account> telefones = new Map<String, Account>();
        if (accounts != null) {
            for (Account acc : accounts) {
                if (acc.Phone != null) {
                    telefones.put(acc.Phone, acc);
                }
            }
        }
        return telefones;
    }

    // Industry Summary
    public Map<String, Decimal> industrySummary(List<Account> accounts) {
        Map<String, Decimal> somaSetor = new Map<String, Decimal>();
        for (Account acc : accounts) {
            if (somaSetor.containsKey(acc.Industry)) {
                Decimal soma = somaSetor.get(acc.Industry) + acc.AnnualRevenue;
                somaSetor.put(acc.Industry, soma);
            } else {
                somaSetor.put(acc.Industry, acc.AnnualRevenue);
            }
        }
        return somaSetor;
    }

    // Cases by Type
    public Map<String, List<Case>> casesByType(List<Case> cases) {
        Map<String, List<Case>> mapa = new Map<String, List<Case>>();
        for (Case c : cases) {
            if (c.Type == null) continue; // vai para o próximo c
            if (!mapa.containsKey(c.Type)) { // se não houver um mapa desse tipo, cria um novo
                mapa.put(c.Type, new List<Case>());
            }
            mapa.get(c.Type).add(c);
        }
        return mapa;
    }
}