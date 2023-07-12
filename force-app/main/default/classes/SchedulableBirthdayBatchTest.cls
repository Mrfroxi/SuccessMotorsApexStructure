@isTest
public class SchedulableBirthdayBatchTest {

	@isTest
    static void testScheduleJob() {

        Test.startTest();

        SchedulableBirthdayBatch scheduler = new SchedulableBirthdayBatch();

                String cronJobName = 'MyTestJob1';

                String cronString = '0 0 0 1 1 ? 2024';

                System.schedule(cronJobName, cronString, scheduler);

        
        Test.stopTest();
    
    }
}