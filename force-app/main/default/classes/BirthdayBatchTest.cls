@isTest
public with sharing class BirthdayBatchTest {

    @isTest
    static void testExecute() {        
     
      List<Contact> contacts = new List<Contact>();

      for (Integer i = 0; i < 5; i++) {

        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact', Birthdate = Date.today()));
        
      }

      insert contacts;
        
     
      Test.startTest();

        BirthdayBatch testBatch = new BirthdayBatch(); 

        database.executeBatch(testBatch);

      Test.stopTest();
    
    }

}