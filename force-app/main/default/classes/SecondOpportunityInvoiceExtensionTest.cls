@isTest
public with sharing class SecondOpportunityInvoiceExtensionTest {

    @TestSetup
    static void setup(){

        Opportunity opp = new Opportunity(

            Name='TestOpp',
            StageName='Prospecting',
            CloseDate = date.today().addMonths(2),
            OwnerId = '0052w00000GTIhFAAX'

        );
        insert opp;

        Contact cont = new Contact(LastName = 'TestContact', Email='test@gmail.com');
        insert cont;

        OpportunityContactRole oli = new OpportunityContactRole(OpportunityId = opp.Id,ContactId = cont.Id,IsPrimary = true);
        insert oli;

    }
   
    @isTest
    static void testGetPrimaryContact(){

        Opportunity opp = [
            SELECT Id 
            FROM Opportunity 
            LIMIT 1
        ];
       
        Contact cont = [
            SELECT Id 
            FROM Contact 
            WHERE LastName='TestContact' 
            LIMIT 1
        ];
       
        Test.startTest();
       
            PageReference testPage = Page.InvoicePage;
       
        Test.setCurrentPage(testPage);
       
            testPage.getParameters().put('Id',String.valueOf(opp.Id));
        
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        
            SecondOpportunityInvoiceExtension ext = new SecondOpportunityInvoiceExtension(sc);
        
            System.assertEquals(cont.Id, ext.getPrimaryContact().Id);

        Test.stopTest();
        
    }
   
   
    @isTest
    static void testAttachPDF(){

        Opportunity opp = [

            SELECT Id 
            FROM Opportunity
            LIMIT 1

        ];
       
       PageReference testPage = Page.InvoicePage;

       Test.setCurrentPage(testPage);

       testPage.getParameters().put('Id',String.valueOf(opp.Id));

       ApexPages.StandardController sc = new ApexPages.StandardController(opp);
       
       SecondOpportunityInvoiceExtension ext = new SecondOpportunityInvoiceExtension(sc);
       
       ext.attachPDF();
       
       List<ContentVersion> listVersion = [

           SELECT contentDocumentId,contentDocument.title 
           FROM contentVersion

       ];

       System.assert(listversion.size() == 1);

       ext.attachPDF();

       listVersion = [

           SELECT contentDocumentId,contentDocument.title 
           FROM contentVersion

       ];

        System.assert(listversion.size() == 2);

   }
   
    @isTest
    static void testGetAttachedInvoiceId(){

       Opportunity opp = [

            SELECT Id ,OwnerId 
            FROM Opportunity 
            LIMIT 1

        ];

        System.assertEquals(null, SecondOpportunityInvoiceExtension.getAttachedInvoiceId(opp.Id));

        ContentVersion cv = new ContentVersion();
       
        cv.ContentLocation = 'S';
        cv.PathOnClient = SecondOpportunityInvoiceExtension.getInvoiceNumber(opp.Id) + '.pdf';
        cv.Origin = 'C';
        cv.OwnerId = opp.OwnerId;
        cv.Title = SecondOpportunityInvoiceExtension.getInvoiceNumber(opp.Id) + '.pdf';
        cv.VersionData = blob.valueOf('Unit.Test');
        
        insert cv;
       
        Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
       
        ContentDocumentLink cdl = new ContentDocumentLink();

        cdl.ContentDocumentId = cdId;
        cdl.LinkedEntityId = opp.Id;
        cdl.ShareType ='v';
        cdl.Visibility = 'AllUsers';

        insert cdl;

        System.assertEquals(cdId, SecondOpportunityInvoiceExtension.getAttachedInvoiceId(opp.Id));
    
    }
    
    @isTest
    static void testCancel(){
       Opportunity opp = [
            SELECT Id 
            FROM Opportunity 
            LIMIT 1
        ];

       Test.startTest();

            PageReference testPage = Page.InvoicePage;

            Test.setCurrentPage(testPage);

            testPage.getParameters().put('Id',String.valueOf(opp.Id));

            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            
            SecondOpportunityInvoiceExtension ext = new SecondOpportunityInvoiceExtension(sc);

            Pagereference pref = ext.cancel();

        Test.stopTest();

        Assert.isNotNull(pref);

    }
    
    @isTest
    static void testStaticGetPrimaryContact(){

        Opportunity opp = [

            SELECT Id 
            FROM Opportunity 
            LIMIT 1

        ];

        COntact cont = [

            SELECT Id 
            FROM Contact 
            WHERE LastName='TestContact' 
            LIMIT 1

        ];
        
        System.assertEquals(cont.Id, SecondOpportunityInvoiceExtension.getPrimaryContact(opp.Id).Id);
         
    }
    
    @isTest
    static void testEmailWasSent(){

            Opportunity opp = [

                SELECT Id 
                FROM Opportunity 
                LIMIT 1

            ];
            
            ContentVersion cv = new ContentVersion();
        
            cv.ContentLocation = 'S';
            cv.PathOnClient = SecondOpportunityInvoiceExtension.getInvoiceNumber(opp.Id) + '.pdf';
            cv.Origin = 'C';
            cv.OwnerId = opp.OwnerId;
            cv.Title = SecondOpportunityInvoiceExtension.getInvoiceNumber(opp.Id) + '.pdf';
            cv.VersionData = blob.valueOf('Unit.Test');
           
           insert cv;
           
            Id cdId = [

                SELECT ContentDocumentId 
                FROM ContentVersion 
                WHERE Id = :cv.Id

            ].ContentDocumentId;
           
           ContentDocumentLink cdl = new ContentDocumentLink();

           cdl.ContentDocumentId = cdId;
           cdl.LinkedEntityId = opp.Id;
           cdl.ShareType ='v';
           cdl.Visibility = 'AllUsers';

           insert cdl;

			Test.startTest();

                SecondOpportunityInvoiceExtension.sendEmail('test', opp.Id);

                integer invocations =Limits.getEmailInvocations();

            Test.stopTest();
        
        System.assertEquals(1, invocations);

    }

    @isTest
    static void testGetInvoicePDFId(){
     
        Opportunity opp = [SELECT Id,OwnerId FROM Opportunity LIMIT 1];
 
        ContentVersion cv = new ContentVersion();
       
        cv.ContentLocation = 'S';
        cv.PathOnClient = SecondOpportunityInvoiceExtension.getInvoiceNumber(opp.Id) + '.pdf';
        cv.Origin = 'C';
        cv.OwnerId = opp.OwnerId;
        cv.Title = SecondOpportunityInvoiceExtension.getInvoiceNumber(opp.Id) + '.pdf';
        cv.VersionData = blob.valueOf('Unit.Test');
        
        insert cv;

        Id cdId = [

            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv.Id

        ].ContentDocumentId;
    
        ContentDocumentLink cdl = new ContentDocumentLink();

        cdl.ContentDocumentId = cdId;
        cdl.LinkedEntityId = opp.Id;
        cdl.ShareType ='v';
        cdl.Visibility = 'AllUsers';

        insert cdl;
    
    
        Test.startTest();

            String pdfId = SecondOpportunityInvoiceExtension.getInvoicePDFId(opp.Id);

        Test.stopTest();
    
        System.assertEquals([SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId, pdfId);
        
    }

}