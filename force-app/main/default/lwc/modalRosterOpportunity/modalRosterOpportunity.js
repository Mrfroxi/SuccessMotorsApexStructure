import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class ModalRosterOpportunity extends LightningModal {

    @api content;

    @api structure;

    hasData = false;

    connectedCallback() {

        if (this.content && this.content.length > 0) {

            this.hasData = true;

        }

    }

    handleClose(){

        this.close('close');

    }
    
}