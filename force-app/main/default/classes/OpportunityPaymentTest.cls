@isTest
public class OpportunityPaymentTest {

    @isTest 
    static void testTrigger(){
    
        Opportunity testOpp = new Opportunity(

            Name = 'Test Opportunity',
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting',
            Amount = 4000,
            OwnerId = '0052w00000GTIhFAAX'

        );

        insert testOpp;

        Payment__c payment1 = new Payment__c(

            Amount__c = 5000,
            OpportunityName__c = testOpp.Name

        );

        Test.startTest();

            insert payment1;
                
            testOpp = [SELECT Id, paymentStatus__c FROM Opportunity WHERE Id = :testOpp.Id];
            
            System.assertEquals('Fully Paid', testOpp.paymentStatus__c);

        Test.stopTest();
            
    }

}