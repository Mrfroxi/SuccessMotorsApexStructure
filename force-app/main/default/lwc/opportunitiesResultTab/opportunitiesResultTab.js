import { LightningElement,track,wire,api } from 'lwc';

import getAccount from '@salesforce/apex/OpportunitiesResultController.getAccount';

import getOpportunityProducts from '@salesforce/apex/OpportunitiesResultController.getOpportunityProducts';

import searchAccounts from '@salesforce/apex/OpportunitiesResultController.searchAccounts';

import ModalRosterOpportunity from 'c/modalRosterOpportunity';

const OPP_COLUMNS =[
    {label:'Opportunity Name' , fieldName:'recordLink',type:'url',
    typeAttributes:{label:{fieldName:'Name'},target:'_blank'}
},
    {label:'Created Date' , fieldName:'CreatedDate',type:'date'},
    {label:'Close Date' , fieldName:'CloseDate',type:'date'},
    {label:'Amount' , fieldName:'Amount',type:'currency'},
    {
        type:"button",
        label:"Products",
        typeAttributes:{
            label:'Look',
            name:'Look',
            title:'Look',
            disabled:false,
            value:'Look',
            iconPosition:'right'
        }
    }
];

const PROD_COLUMNS =[
    {label:'Name' , fieldName:'Name',type:'text'},
    {label:'Quantity' , fieldName:'Quantity',type:'number'},
    {label:'Price' , fieldName:'TotalPrice',type:'currency'},
]

export default class OpportunitiesResultTab extends LightningElement {

    @api recordId;

    @api searchTerm = '';

    totalAccounts;

    visibleAccounts;

    products;

    columns = OPP_COLUMNS;


    connectedCallback(){

        if(this.recordId){
          
            getAccount({
                accId:this.recordId
            }).then((result) => {
          
                this.visibleAccounts = [];

                for(let key in result){

                    this.visibleAccounts.push({value:result[key] , key:key});

                }

                this.visibleAccounts.map( elem => {
     
                    if(elem.value){
                 
                        var tempOppList = [];
     
                        for(var i = 0; i<elem.value.length; i++){
                   
                            let tempRecord = Object.assign({},elem.value[i]);
                         
                            tempRecord.recordLink = "/" + tempRecord.Id;

                            tempOppList.push(tempRecord);

                        }
                  
                        elem.value = tempOppList;
                       
                    }
              
                });
               
            })
        }
    }


     showProducts(event){

        getOpportunityProducts({
             oppId:event.detail.row.Id
         }).then((result) => {

             this.products = result;

             ModalRosterOpportunity.open({

                content:this.products,
                structure:PROD_COLUMNS

            }).then((result) =>{

                console.log(result);

            });

         })
         .catch((error) =>{

            console.log(`Error showProducts:${error}`)

         })

     }



     @wire(searchAccounts,{searchTerm:'$searchTerm'})

        loadAccounts({error,data}){
            
        if(data){

            this.totalAccounts = [];
        
            for(let key in data){
                
                this.totalAccounts.push({value:data[key],key:key});
            }
           
            this.totalAccounts.map(elem => {

                if(elem.value){

                    var tempOppList = [];

                    for(var i =0 ; i <elem.value.length ;i++){

                        let tempRecord = Object.assign({},elem.value[i]);

                        tempRecord.recordLink = '/' + tempRecord.Id;

                        tempOppList.push(tempRecord);

                    }

                    elem.value = tempOppList;

                }});
                
        }
    }

    handleSearchTermChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchTerm = event.target.value;
        this.delayTimeout = setTimeout(() =>{
            this.searchTerm = searchTerm;
        },300);
    }

    updateAccountHandler(event){
        this.visibleAccounts = [...event.detail.records];
    }

}