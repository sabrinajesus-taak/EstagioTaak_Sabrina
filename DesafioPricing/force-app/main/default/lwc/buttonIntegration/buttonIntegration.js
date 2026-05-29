import { LightningElement, api } from 'lwc';

import sendOrder
from '@salesforce/apex/OrderIntegrationController.sendOrder';

import { ShowToastEvent }
from 'lightning/platformShowToastEvent';

export default class ButtonIntegration extends LightningElement {

    @api recordId;

    async sendOrder() {

        try {

            const result = await sendOrder({
                orderId: this.recordId
            });

            if(result === 'Erro na integração') {

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erro',
                        message: result,
                        variant: 'error'
                    })
                );

            } else {

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Sucesso',
                        message: result,
                        variant: 'success'
                    })
                );

            }

        } catch(error) {

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro',
                    message: error.body.message,
                    variant: 'error'
                })
            );

        }

    }

}