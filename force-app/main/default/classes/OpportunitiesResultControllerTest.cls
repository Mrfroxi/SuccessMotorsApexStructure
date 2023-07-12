@isTest
public with sharing class OpportunitiesResultControllerTest {
    @TestSetup
    static void setup(){
        Account acc1 = new Account(Name='TestAcc1');
        insert acc1;

        Account acc2 = new Account(Name='TestAcc2');
        insert acc2;

        Opportunity opp = new Opportunity(
            Name='TestOpp',
            StageName='Closed Won',
            CloseDate = date.today().addMonths(2),
            Amount=123,
            AccountId=acc1.Id
        );
        insert opp;
    }

    @isTest
    static void testSearchAccounts(){
        System.assert(OpportunitiesResultController.searchAccounts('').size() == 2);
        System.assert(OpportunitiesResultController.searchAccounts('TestAcc2').size() == 1);
        System.assert(OpportunitiesResultController.searchAccounts('100').size() == 1);
        System.assert(OpportunitiesResultController.searchAccounts('1000').size() == 0);
    }

    @isTest
    static void testGetAccounts(){
        Account acc = [SELECT Name
            FROM Account 
            WHERE Name = 'TestAcc1'
        ];

        Map<String,List<Opportunity>> resultMap = OpportunitiesResultController.getAccount(acc.Id);

        System.assert(resultMap.containsKey('TestAcc1 $123.00'));
    }   


    @isTest
    static void testGetOpportunityProducts(){
        Opportunity opp = [
            SELECT Id 
            FROM Opportunity
            WHERE Name = 'TestOpp'
        ];

        Id pricebookId = Test.getStandardPriceBookId();


        Product2 prod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            isActive = true
        );
        insert prod;



        PriceBookEntry priceBookEntry = new PriceBookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            isActive = true
        );
        insert priceBookEntry;


        OpportunityLineItem oppLineItem = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 5,
            PriceBookEntryId = priceBookEntry.Id,
            TotalPrice = 5*priceBookEntry.UnitPrice
        );
        insert oppLineItem;


        System.assert(OpportunitiesResultController.getOpportunityProducts(opp.Id).size() ==1);
    }
    
    @isTest
    static void testSearchAccounts2() {
      
        Test.startTest();
        Map<String, List<Opportunity>> result1 = OpportunitiesResultController.searchAccounts('Test');
        Test.stopTest();
        
        System.assertEquals(2, result1.size());
        System.assertEquals(1, result1.get('TestAcc1 $123.00').size());
        System.assertEquals('TestOpp', result1.get('TestAcc1 $123.00')[0].Name);
        System.assertEquals(0, result1.get('TestAcc2 $0.00').size());
        
       
        Test.startTest();
        Map<String, List<Opportunity>> result2 = OpportunitiesResultController.searchAccounts('100');
        Test.stopTest();
        
        
        System.assertEquals(1, result2.size());
        System.assertEquals(1, result2.get('TestAcc1 $123.00').size());
        System.assertEquals('TestOpp', result2.get('TestAcc1 $123.00')[0].Name);
    }
}