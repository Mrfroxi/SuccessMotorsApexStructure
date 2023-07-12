import getEmailBody from '@salesforce/apex/SecondOpportunityInvoiceExtension.getEmailBody';
import getInvoicePDFId from '@salesforce/apex/SecondOpportunityInvoiceExtension.getInvoicePDFId';
import getPrimaryContact from '@salesforce/apex/SecondOpportunityInvoiceExtension.getPrimaryContact';
import { NavigationMixin } from 'lightning/navigation';
import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';

import INVOICE_NUMBER from '@salesforce/schema/Opportunity.Invoice_Number__c';
import sendEmail from '@salesforce/apex/SecondOpportunityInvoiceExtension.sendEmail';

export default class SendInvoice extends NavigationMixin(LightningElement) {

    @api recordId;

    contactDataEmail;

    contactDataName;

    hasData=false;

    HTMLBody;


    @wire( getPrimaryContact, {recordId:'$recordId'})
    wiredGetPrimaryContact({error,data}){
        if(data){
            
            this.contactDataEmail = data.Email;

            this.contactDataName = data.Name;

            this.hasData = true;
         
        }else if(error){

            console.log('error' , JSON.parse(JSON.stringify(error)));

        }

    }


    @wire(getRecord , {recordId:'$recordId',fields:[INVOICE_NUMBER]})
    opportunity;


    get emailSubject(){

        return getFieldValue(this.opportunity.data , INVOICE_NUMBER);

    }


    @wire(getEmailBody)
    EmailBody;

    @wire( getInvoicePDFId , {recordId:'$recordId'})
    invoicePdfId;

    previewActionPdf(){

        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: this.invoicePdfId.data
            }
        });
    }
    
    closeFlow(){

        this.dispatchEvent(new CloseActionScreenEvent());

    }


    sendEmailAction(){
      
        this.HTMLBody = this.template.querySelector('lightning-input-rich-text').value;

        sendEmail({emailBody: this.HTMLBody , recordId: this.recordId})
        .then(()=>{
            console.log('Send Email');
        })
        .catch((erroe) =>{
            console.error("Error in the sendEmail",error);
        })

        this.dispatchEvent(new CloseActionScreenEvent());
    }

}