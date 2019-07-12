import { LightningElement, wire, track } from 'lwc';
import getGrants from '@salesforce/apex/TimecardsAppController.getGrants';
import getGrantWorkItems from '@salesforce/apex/TimecardsAppController.getGrantWorkItems';
import saveTimecardsRecord from '@salesforce/apex/TimecardsAppController.saveTimecardsRecord';

/** The delay used when debouncing event handlers before invoking Apex. */
//const DELAY = 300;

export default class TimecardAppComponent extends LightningElement {
  @track contactId;
  @track grantId;
  @track grants;
  @track grantWorkItems;
  @track grantWorkItemId;
  @track date;
  @track hours;

  connectedCallback() {
    let search = window.location.search.substring(1);
    let urlParams = search.split('&');
    let conId;
    urlParams.map(item => {
      let key = item.substring(0, item.indexOf('='));
      let value = item.substring(item.indexOf('=') + 1);
      if (key === 'contactId') { conId = value; }
    });
    this.contactId = conId;
  }

  @wire(getGrants, {contactId: "$contactId"}) wiredGrants({error, data}) {
    console.log(this.contactId);
    if (data) {
      this.grants = data;
      console.log(this.grants);
    }
  }

  handleSelectGrant(e) {
    this.grantId = e.target.value;
    getGrantWorkItems({"grantId": this.grantId}).then((response) => {
      this.grantWorkItems = response;
    });
  }

  handleSelectGrantWorkItem(e) {
    this.grantWorkItemId = e.target.value;
  }

  handleDateChange(e) {
    this.date = e.target.value;
  }

  handleHoursChange(e) {
    this.hours = e.target.value;
  }

  handleSubmit() {
    let timecardRecord = { "sobjectType" : "Timecards__c" };
    timecardRecord.Contact__c = this.contactId;
    timecardRecord.Date__c = this.date;
    timecardRecord.Grant__c = this.grantId;
    timecardRecord.Hours__c = this.hours;
    timecardRecord.Work_Items__c = this.grantWorkItemId;

    let jsonString = JSON.stringify(timecardRecord);
    console.log(jsonString);

    saveTimecardsRecord({ jsonString })
      .then(response => {
        console.log(JSON.stringify(response));
      })
      .catch(error => {
        console.log(JSON.stringify(error));
      })
  }

  /*@wire(getGrantWorkItems, {grantId: "$grantId"}) wiredGrantWorkItems({error, data}) {
    if (data) {
      this.grantWorkItems = data;
      console.log(this.grantWorkItems);
    }
  }*/

  @wire(saveTimecardsRecord, {jsonString: "$timecardRecord"}) wiredSaveTimecardsRecord({error, data}) {}

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
