import { LightningElement, api } from 'lwc';
import addEmployee from '@salesforce/apex/ServiceDealEmployeeAssigmentService.addEmployee';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AssignEmployeeButton extends LightningElement {
    @api recordId;
    handleClick() {
        addEmployee({ serviceId: this.recordId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Employee assigned successfully!',
                        variant: 'success'
                    })
                );
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}