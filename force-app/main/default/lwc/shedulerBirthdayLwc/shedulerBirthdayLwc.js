import { LightningElement ,track , api} from 'lwc';
import batchStart from '@salesforce/apex/LWCSchedulingService.batchStart';
import scheduleJob from '@salesforce/apex/LWCSchedulingService.scheduleJob';
import deleteScheduledJob from '@salesforce/apex/LWCSchedulingService.deleteScheduledJob';
import checkFirstJobStatus from '@salesforce/apex/LWCSchedulingService.checkFirstJobStatus';

export default class ShedulerBirthdayLwc extends LightningElement {

  @api cronJobNameIdentifier = "Sheduler Birth Day";

  @api batchNameIdentifier = "BithdateBatch";

  @api currentCronAsString='0 0 0 * * ?';

  @track state;

  connectedCallback() {
    this.getScheduledCron(); 
  }

  getScheduledCron() {

    checkFirstJobStatus({ cronJobName: this.cronJobNameIdentifier })

      .then(result => {
        if(result){
          this.state=true;
        }else{
          this.state =false;
        }
      })

      .catch(error => {
 
        console.log(error.message);
      });
  }

  batchOnce(){
    batchStart({batchName:this.batchNameIdentifier});
  }

  handleFormInputChange(event){
    console.log(this.currentCronAsString);
    this.currentCronAsString = event.target.value;
  }

  scheduleHandlerActivate(){

    scheduleJob({
      cronString: this.currentCronAsString,
      cronJobName: this.cronJobNameIdentifier
    })
    .then(data => {
      this.state=true;
      console.log(data);
    })
    .catch(error => {
      
      console.log(error.message);
    });
  
  
  
  }

  scheduleHandlerDelete(){

    deleteScheduledJob({cronJobName:this.cronJobNameIdentifier}).then(data =>{
      console.log(data);
    })
    .then(data => {
      this.state=false;
      console.log(data)
    })
    .catch(error => {
      console.log(error.message);
    });
   
  }

}