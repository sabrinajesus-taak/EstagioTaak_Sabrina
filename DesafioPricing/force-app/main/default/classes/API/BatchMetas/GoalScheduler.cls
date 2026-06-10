public with sharing class GoalScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new GoalBatch());
    }

    public static void scheduleJob() {
        System.schedule(
            'Goal Scheduler',
            '0 0 9 ? * MON-SUN',
            new GoalScheduler()
        );
    }
}