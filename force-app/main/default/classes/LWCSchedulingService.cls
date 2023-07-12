public with sharing class LWCSchedulingService {

    @AuraEnabled
    public static void batchStart(String batchName){

        Type customType = Type.forName(batchName);

        database.executeBatch((Database.Batchable<sObject>)customType.newInstance());

    }
    
    @AuraEnabled
    public static Datetime getCurrentDateTime() {

        return Datetime.now();

    }

    @AuraEnabled
    public static Boolean scheduleJob(String cronString, String cronJobName) {

        try {
            
            SchedulableBirthdayBatch scheduler = new SchedulableBirthdayBatch();

            System.schedule(cronJobName, cronString, scheduler);

            return true;

        } catch (Exception e) {

            System.debug(e.getMessage());

            return false;

        }
    }

    @AuraEnabled
    public static Boolean deleteScheduledJob(String cronJobName) {

        try {

            List<CronTrigger> cronTriggers = [
                SELECT Id, CronExpression
                FROM CronTrigger
                WHERE CronJobDetail.Name = :cronJobName
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            CronTrigger cronTrigger = (cronTriggers.size() == 1) ? cronTriggers.get(0) : null;

            System.abortJob(cronTrigger.Id);

            return true;

        } catch (Exception e) {

            return false;

        }
    }

    @AuraEnabled
    public static cronTrigger checkFirstJobStatus(String cronJobName){

        List<CronTrigger> cronTriggers = [
            SELECT Id,State
            FROM CronTrigger
            WHERE CronJobDetail.Name = :cronJobName
            LIMIT 1
        ];

        CronTrigger cronTrigger = (cronTriggers.size() == 1) ? cronTriggers.get(0) : null;

        if (cronTrigger != null) {

            return cronTrigger;

        }
        
        return null;
    }
    
}