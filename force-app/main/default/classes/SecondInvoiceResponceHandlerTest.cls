@isTest
private class SecondInvoiceResponceHandlerTest {

    @isTest
    static void testHandlerInboundEmail(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        
        Opportunity opp = new Opportunity(
            Name='TestOpp',
            stageName='Prospecting',
            closeDate=date.today().addMonths(3),
            OwnerId= '0052w00000GTIhFAAX'
        );
        	
        insert opp;
        
        System.debug(opp);
        
        Opportunity newOpp = [
            SELECT Invoice_Number__c
            FROM Opportunity
            WHERE ID = :opp.Id
        ];

        email.subject = newOpp.Invoice_Number__c;
        email.plainTextBody='approved';


        SecondInvoiceResponceHandler handler = new SecondInvoiceResponceHandler();

        handler.handleInboundEmail(email,env);
        
        Opportunity result = [
            SELECT StageName
            FROM Opportunity
            WHERE Id = :opp.Id
        ];


        System.assertEquals('Qualification',result.StageName);
    }
}