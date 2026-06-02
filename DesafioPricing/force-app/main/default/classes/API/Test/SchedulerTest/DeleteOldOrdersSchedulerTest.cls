@isTest
public with sharing class DeleteOldOrdersSchedulerTest {
    
    @isTest
    static void testScheduler(){
        
        Test.startTest();
        //segundos minutos horas diaDoMes mês diaDaSemana ano
        //executa às 00:00 do dia 1 de janeiro de 2099
        String dateExecute = '0 0 0 1 1 ? 2099';
        System.schedule('Test Schedule Delete Old Orders', dateExecute, new DeleteOldOrdersScheduler());
        Test.stopTest();
        
        //o obj interno do schedule é o CronTrigger, então é necessário consultar esse objeto para validar se o agendamento foi criado corretamente
        //timesTriggered é o número de vezes que o agendamento foi executado
        CronTrigger cronTrigger = [
            SELECT Id,
            CronExpression,
            TimesTriggered,
            CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name = 'Test Schedule Delete Old Orders'
            LIMIT 1];
        
        System.assertEquals(dateExecute, cronTrigger.CronExpression, 'A expressão cron do agendamento deveria ser igual a definida no teste');
        System.assertEquals('Test Schedule Delete Old Orders', cronTrigger.CronJobDetail.Name, 'O nome do job agendado deveria ser Test Schedule Delete Old Orders');
    }
}