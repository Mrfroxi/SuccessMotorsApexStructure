@isTest
public class LWCSchedulingServiceTest {
	
    @isTest
    static void testGetCurrentDateTime() {

        Test.startTest();

            Datetime currentDatetime = LWCSchedulingService.getCurrentDateTime();

        Test.stopTest();
        
    }
    
    @IsTest
    static void testScheduleJobSuccess() {

        Test.startTest();

            Boolean result = LWCSchedulingService.scheduleJob('0 0 0 1 1 ? 2024', 'MyTestJob');
            Boolean result2 = LWCSchedulingService.scheduleJob('0 0 0 1 1 ? 2024', 'MyTestJob');
            
            System.assertEquals(false, result2);

        Test.stopTest();
      
    }

    @IsTest
        static void testDeleteScheduledJob() {

            SchedulableBirthdayBatch scheduler = new SchedulableBirthdayBatch();
			String cronJobName = 'MyTestJob2';
    		String cronString = '0 0 0 1 1 ? 2024';

        	System.schedule(cronJobName, cronString, scheduler);
            
            Test.startTest();

                Boolean result = LWCSchedulingService.deleteScheduledJob('MyTestJob2');
                Boolean result2 = LWCSchedulingService.deleteScheduledJob('MyTestJob');
                
            Test.stopTest();
     }

	   @IsTest
        static void testcheckScheduledJob() {

            SchedulableBirthdayBatch scheduler = new SchedulableBirthdayBatch();
			String cronJobName = 'MyTestJob1';
    		String cronString = '0 0 0 1 1 ? 2024';

        	System.schedule(cronJobName, cronString, scheduler);

			Test.startTest();
           
                CronTrigger cron = LWCSchedulingService.checkFirstJobStatus('MyTestJob1');
                
                CronTrigger cron2 = LWCSchedulingService.checkFirstJobStatus('MyTestJob');

                System.assertEquals(cron2,null);
                
            Test.stopTest();
     }
}