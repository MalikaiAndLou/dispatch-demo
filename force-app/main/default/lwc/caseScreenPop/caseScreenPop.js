import { LightningElement, api, wire } from 'lwc';
import getPanel from '@salesforce/apex/CaseScreenPopController.getPanel';

export default class CaseScreenPop extends LightningElement {
    @api recordId;
    panel;
    error;

    @wire(getPanel, { caseId: '$recordId' })
    wired({ data, error }) {
        if (data) { this.panel = data; this.error = undefined; }
        else if (error) { this.error = error; this.panel = undefined; }
    }

    get hasStation() { return !!(this.panel && this.panel.stationCode); }
    get isDown() { return !!(this.panel && this.panel.stationStatus === 'Out of Service'); }
    get routed() { return (this.panel && this.panel.routingDecision) || 'NOT ROUTED'; }
    get hasScore() { return !!(this.panel && this.panel.score !== null && this.panel.score !== undefined); }


    get badgeClass() {
        const h = (this.panel && this.panel.healthStatus) || '';
        if (h === 'RED') return 'badge badge-red';
        if (h === 'AMBER') return 'badge badge-amber';
        return 'badge badge-green';
    }
}