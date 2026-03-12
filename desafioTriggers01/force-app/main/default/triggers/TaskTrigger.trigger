trigger TaskTrigger on Task (before insert) {
    Set<Id> casesId = new Set<Id>();
    Set<Id> casesOpen = new Set<Id>();
    
    //id se for case para a busca
    for (Task t: Trigger.new) {
        if (t.WhatId != null && String.valueOf(t.WhatId).startsWith('500')) { 
            casesId.add(t.WhatId);
        }
    }
    
    //já possuem taks aberta
    if (!casesId.isEmpty()) {
        for (Task temTask : [select WhatId from Task
                            where WhatId in :casesId
                            and Status in ('Not Started', 'In Progress', 'Waiting on someone else')]) {
            casesOpen.add(temTask.WhatId);
        }
    }
    
    //erro
    for (Task t : Trigger.new) {
        if (casesOpen.contains(t.WhatId)) {
            t.addError('Já existe uma tarefa em aberto nesse caso. Encerre-a antes de abrir uma nova.');
        }
    }
}