// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

Id casoId = '500fj0000198SizAAE'; 
List<Task> tarefas = new List<Task>();
tarefas.add(new Task(Subject='Teste 1', WhatId=casoId, Status='Not Started'));
tarefas.add(new Task(Subject='Teste 2', WhatId=casoId, Status='Not Started'));

// O Database.insert retorna uma lista de resultados (sucesso ou erro)
Database.SaveResult[] resultados = Database.insert(tarefas, false);

for (Database.SaveResult sr : resultados) {
    if (sr.isSuccess()) {
        System.debug('Tarefa criada com sucesso: ' + sr.getId());
    } else {
        for(Database.Error err : sr.getErrors()) {
            System.debug('Erro detectado: ' + err.getMessage());
        }
    }
}