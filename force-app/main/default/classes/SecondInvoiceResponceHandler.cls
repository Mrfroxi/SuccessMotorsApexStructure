global class SecondInvoiceResponceHandler implements Messaging.InboundEmailHandler {


    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        String mainsubject = email.subject;
        String responseText = email.plainTextBody;
    
        try {
            if (mainsubject.startsWith('INV-') || mainsubject.startsWith('Re: INV-')) {

                if (mainsubject.startsWith('Re: INV-')) {
                    mainsubject = mainsubject.substring(4);
                }
    
                Opportunity opp = [SELECT StageName FROM Opportunity WHERE Invoice_Number__c = :mainsubject];
    
                responseText = responseText.toLowerCase();
    
                if (responseText.contains('approved') && opp.StageName != 'Closed Won') {

                    Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();

                    List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

                    Integer currentStageIndex = -1;
    
                    for (Integer i = 0; i < picklistValues.size(); i++) {

                        if (picklistValues[i].getLabel() == opp.StageName) {
                            currentStageIndex = i;
                            break;
                        }
                    }
    
                    if(currentStageIndex != -1 && currentStageIndex < picklistValues.size() - 1) {

                        opp.StageName = picklistValues[currentStageIndex + 1].getLabel();
                        
                        update opp;
                    }
    
                } else if (responseText.contains('rejected')) {
                    opp.StageName = 'Closed Lost';
                    update opp;
                }               
            }       
        } catch (System.QueryException e) {
            System.debug('SecondInvoiceResponceHandler Exception: ' + e);
        }  
    
        result.success = true;   
        return result;
    }
    

}