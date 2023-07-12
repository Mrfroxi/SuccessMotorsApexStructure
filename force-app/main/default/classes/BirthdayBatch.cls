public with sharing class BirthdayBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext BC){

        String query = 'SELECT Name ,Birthdate,Email FROM Contact WHERE Birthdate = TODAY';
  
        return Database.getQueryLocator(query);
  
     }
  
     public void execute(Database.BatchableContext BC, List<sObject> scope){
      
        EmailTemplate emailTemplate = [
  
            SELECT Id FROM EmailTemplate
            WHERE Name = 'BirthdateTemplate'
  
        ];    
           
        Messaging.MassEmailMessage emails = new Messaging.MassEmailMessage();
         
        List<Contact> contacts = (List<Contact>) scope;
        Map<Id, Contact> contactMap = new Map<Id, Contact>(contacts);
        List<ID> contactIds = new List<ID>(contactMap.keySet());
         
        emails.setTargetObjectIds(contactIds);
        emails.setTemplateId(emailTemplate.Id);
         
        Messaging.sendEmail(New Messaging.MassEmailMessage[]{emails});
  
      }
  
     public void finish(Database.BatchableContext BC){
     }
     
}