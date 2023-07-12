trigger OpportunityPayment on Payment__c (after insert) {
    
    List<Payment__c> paymentList = new List<Payment__c>();
	
    String oppName = null;
    
    
    for(Payment__c pay : Trigger.new) {

        oppName = pay.OpportunityName__c;

    }
    
    
    Opportunity opp = [SELECT Id,OwnerId ,Amount, paymentStatus__c,	Name  FROM Opportunity WHERE Name = :oppName];

    paymentList = [SELECT Id, OpportunityName__c,Amount__c FROM Payment__c Where OpportunityName__c = :oppName];
   	

    Schema.DescribeFieldResult fieldResult = Opportunity.paymentStatus__c.getDescribe();
    
    List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
    
    Double currentsum = 0;

     
    for(Integer i =0 ; i < paymentList.size(); i++ ){

        if(paymentList[i].Amount__c != null){
      
        	currentsum = currentsum + paymentList[i].Amount__c;
        }    

    }
    
    if(currentsum > 0){

        if(currentsum >= opp.Amount){

            opp.paymentStatus__c = picklistValues[2].getLabel();
            
            //creating a task for a user
            DateTime reminderDateTimeSet = DateTime.newInstance(System.today().addDays(1), Time.newInstance(10, 0, 0, 0));
            
            Task task = new Task(
                OwnerId = opp.OwnerId,
                Priority= 'High',
                Status='Not Started',
                Subject='Delivery of goods',
                WhatId = opp.Id,
                IsReminderSet = true,
				ReminderDateTime = reminderDateTimeSet
            );

            insert task;
          	
        }else{

            opp.paymentStatus__c = picklistValues[1].getLabel();

        }

        update opp;

    }
    
}
