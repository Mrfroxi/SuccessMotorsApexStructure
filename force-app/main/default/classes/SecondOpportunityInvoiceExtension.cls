public with sharing class SecondOpportunityInvoiceExtension {

    public final Id oppId { get; set; }

    private final Opportunity opp;

    public SecondOpportunityInvoiceExtension(ApexPages.StandardController stdController) {

        this.oppId = ApexPages.currentPage().getParameters().get('Id');

        this.opp = [SELECT Invoice_Number__c, OwnerId FROM Opportunity WHERE Id = :oppId];

    }

    public ID getPrimaryContactId() {

        OpportunityContactRole ocr = [

            SELECT Id, ContactId
            FROM OpportunityContactRole 
            WHERE (isPrimary=True 
            AND OpportunityId = :oppId)
            LIMIT 1

        ];

        return ocr.ContactId;

    }

    public Contact getPrimaryContact() {

        Id conId = getPrimaryContactId();

        return [

            SELECT Name, Phone, Email 
            FROM Contact 
            WHERE Id = :conId 
            LIMIT 1

       ];

    }

    public PageReference attachPDF() {

        PageReference pref  = Page.InvoicePage;

        pref.getParameters().put('id', oppId);

        Blob bdata;

        if(Test.isRunningTest()) { 

            bdata = blob.valueOf('Unit.Test');

          } else {

            bdata = pref.getContentAsPDF();

        }

        String docName = opp.Invoice_Number__c + '.pdf';

        ContentVersion attachedFile = getAttachedInvoice(oppId);

        ContentVersion cv = new ContentVersion();
        
        cv.ContentLocation = 'S'; 
        cv.PathOnClient = docName;
        cv.Origin = 'C';
        cv.OwnerId = opp.OwnerId;
        cv.Title = docName;
        cv.VersionData = bdata;

        if (attachedFile != null) {

            cv.ContentDocumentId = attachedFile.ContentDocumentId;

        }
        insert cv;

        if (attachedFile == null) {

            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            
            ContentDocumentLink cdl = new ContentDocumentLink();

            cdl.ContentDocumentId = conDocId;
            cdl.LinkedEntityId = oppId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';

            insert cdl;

        }

        return cancel();

    }

    public PageReference cancel() {

        PageReference Pdf = new PageReference('/'+oppId);

        Pdf.setredirect(True);

        return Pdf;

    }

    public static String getInvoiceNumber(Id recordId){

        return [SELECT Invoice_Number__c FROM Opportunity WHERE Id = :recordId]?.Invoice_Number__c;

    }

    @AuraEnabled(cacheable=true)
    public static String getEmailBody(String templateName){

        return [
            SELECT HtmlValue
            FROM EmailTemplate 
            WHERE Name = :templateName WITH SECURITY_ENFORCED
        ]?.HtmlValue;

    }

    @AuraEnabled(cacheable=true)
    public static Contact getPrimaryContact(Id recordId){

        OpportunityContactRole ocr = [

            SELECT Id, ContactId
            FROM OpportunityContactRole 
            WHERE (isPrimary=True 
            AND OpportunityId = :recordId)
            WITH SECURITY_ENFORCED
            LIMIT 1

        ];

        return [
            SELECT Email, Name 
            FROM Contact 
            WHERE Id = :ocr.ContactId 
            WITH SECURITY_ENFORCED LIMIT 1
        ];

    }

    @AuraEnabled(cacheable=true)
    public static String getInvoicePDFId(String recordId){

        String documentName = getInvoiceNumber(recordId) + '.pdf';

        List<ContentDocumentLink> files = [

            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId= :recordId

        ];
    
        List<Id> fileIDs = new List<Id>();

        for(ContentDocumentLink docLink:files){

            fileIDs.add(docLink.ContentDocumentId);

        }
    
        return [

            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE ContentDocumentId IN :fileIDs 
            AND Title = :documentName
            LIMIT 1

        ].ContentDocumentId;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getAttachedInvoiceId(Id recordId){

        ContentVersion attachedFile = getAttachedInvoice(recordId);

        return attachedFile?.ContentDocumentId;

    }

    @AuraEnabled
    public static void sendEmail(String emailBody, Id recordId){

        try {

            messaging.SingleEmailMessage mail = new messaging.SingleEmailMessage();

            Messaging.EmailFileAttachment attachedInvoice = new Messaging.EmailFileAttachment();

            ContentVersion attachedFile = getAttachedInvoice(recordId);

            if(attachedFile != null) {

                attachedInvoice.setBody(attachedFile.VersionData);

                attachedInvoice.setFileName('Invoice.pdf');

                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachedInvoice});

            }
 
            mail.setToAddresses(new String[]{'pilutikas340@gmail.com'});
            mail.setReplyTo('secondemailresponcehandler@vae006tjvd6vkxj0t6rbcnxgx5d1ldqhy5pq3tdtymea1c43g.2w-rpieqeav.ap16.apex.salesforce.com');
            mail.setSenderDisplayName('SuccessMotors');
            mail.setSubject(getInvoiceNumber(recordId));
            mail.setHtmlBody(emailBody);

            Messaging.sendEmail(new List<messaging.SingleEmailMessage>{ mail });

        } catch (Exception e) {

            throw new AuraHandledException(e.getMessage());

        }

    }

    public static ContentVersion getAttachedInvoice(Id recordId) {

        String docName = getInvoiceNumber(recordId) + '.pdf';

        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];

        List<ID> fileIDs = new List<ID>();

        for (ContentDocumentLink docLink : files) {

            fileIDs.add(docLink.ContentDocumentId);

        }

        List<ContentVersion> cv = [

            SELECT VersionData, ContentDocumentId, ContentDocument.Title
            FROM ContentVersion 
            WHERE ContentDocumentId IN :fileIDs 
            AND ContentDocument.Title = :docName AND IsLatest = true 
            LIMIT 1

        ];

        if(cv.IsEmpty()) {

            return null;

        }

        return cv[0];
        
    }
}