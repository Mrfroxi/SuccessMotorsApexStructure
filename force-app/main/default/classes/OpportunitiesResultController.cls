public with sharing class OpportunitiesResultController {
   
    public static Map<String,List<Opportunity>> getAllAccount (){
        Map<String,List<Opportunity>> result = new Map<String,List<Opportunity>>();

        Set<Id> accountIds = new Set<Id>();

        for(Account acc : [
            SELECT
            Name,OpportunitiesSum__c
            FROM Account
            WHERE OpportunitiesSum__c != 0
            ORDER BY OpportunitiesSum__c DESC
        ]){
            accountIds.add(acc.Id);
            result.put(acc.Name + ' $' + acc.OpportunitiesSum__c.setScale(2), new List<Opportunity>()); 
        }

        List<Opportunity> opportunities = [
            SELECT Name,Amount,CreatedDate,CloseDate,Account.Name,Account.OpportunitiesSum__c
            FROM Opportunity
            WHERE StageName = 'Closed Won'
            AND AccountId IN :accountIds
        ];

        for(Opportunity opp : opportunities){
            result.get(opp.Account.Name +' $' +opp.Account.OpportunitiesSum__c).add(opp);
        }

        return result;
    }


    @AuraEnabled(cacheable = true)//{success $27.00=()}
    public static Map<String,List<opportunity>> getAccount(Id accId){
        Map<String,List<opportunity>>  result = new Map<String,List<opportunity>>();

        Account acc = [
            SELECT Name,OpportunitiesSum__c
            FROM Account
            WHERE ID = :accId
        ];

        result.put(acc.Name + ' $' + acc.OpportunitiesSum__c.setScale(2),[
            SELECT Name,CreatedDate,CloseDate,Amount
            FROM Opportunity
            WHERE StageName = 'Closed Won'
            AND AccountId = :accId
        ]); 
        
        return result;
    }

    @AuraEnabled(cacheable = true)
    public static List<OpportunityLineItem> getOpportunityProducts(Id oppId){
        return [
            SELECT Id,Name,Quantity,TotalPrice 
            FROM OpportunityLineItem
            WHERE OpportunityId = :oppId
        ];
    }


    static Pattern decimalPattern = Pattern.compile('^[-+]?\\d+(\\.\\d*)?$');

    @AuraEnabled(cacheable=true)
    public static Map<String, List<Opportunity>> searchAccounts(String searchTerm) {
        searchTerm = searchTerm.trim();
    
        if(searchTerm==''){
            return getAllAccount();
        }
            
        Map<String, List<Opportunity>> result = new Map<String, List<Opportunity>>();

        List<Account> accounts = new List<Account>();

        Set<Id> accountIds = new Set<Id>();
    


        if(!decimalPattern.matcher(searchTerm).find()){

            searchTerm = searchTerm + '%';

            accounts = [
                SELECT Name,OpportunitiesSum__c
                FROM Account
                WHERE Name LIKE :searchTerm
                ORDER BY OpportunitiesSum__c DESC
            ];

        }else{

            Decimal sum = Decimal.valueOf(searchTerm);

            accounts = [
                SELECT Name,OpportunitiesSum__c
                FROM Account
                WHERE OpportunitiesSum__c >= :sum
                ORDER BY OpportunitiesSum__c DESC
            ];

        }

        for(Account acc : accounts){
            accountIds.add(acc.Id);
            result.put(acc.Name + ' $' + acc.OpportunitiesSum__c.setScale(2), new List<Opportunity>()); 
        }

        List<Opportunity> opportunities = [
            SELECT Name,CreatedDate,CloseDate,Amount,Account.Name,Account.OpportunitiesSum__c
            FROM Opportunity
            WHERE StageName ='Closed Won'
            AND AccountId IN :accountIds
        ];

        for(Opportunity opp : opportunities){
            result.get(opp.Account.Name + ' $' + opp.Account.OpportunitiesSum__c).add(opp);
        }

        return result;

    }
}