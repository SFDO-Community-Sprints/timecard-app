import { LightningElement, wire, track } from 'lwc';
import getGrants from '@salesforce/apex/TimecardsAppController.getGrants';

/** The delay used when debouncing event handlers before invoking Apex. */
//const DELAY = 300;

export default class TimecardAppComponent extends LightningElement {
  @track contactId = '0032f000006xwONAAY';
  @track grants;

  @wire(getGrants, {contactId: "$contactId"}) wiredGrants({error, data}) {
    if (data) {
      this.grants = data;
      console.log(this.grants);
    }
  }

/*
  handleKeyChange(event) {
    // Debouncing this method: Do not update the reactive property as long as this function is
    // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
    window.clearTimeout(this.delayTimeout);
    const contactId = event.target.value;
    this.delayTimeout = setTimeout(() => {
      this.contactId = contactId;
    }, DELAY);
  }*/
}
