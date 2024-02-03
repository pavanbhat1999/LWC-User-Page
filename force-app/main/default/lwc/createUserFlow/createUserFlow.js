import { api, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import getProfilesAll from '@salesforce/apex/lightningUserPage.getProfiles';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import TIMEZONE_FIELD from '@salesforce/schema/User.TimeZoneSidKey';
import createUser from '@salesforce/apex/lightningUserPage.insertUser'
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import NAME_FIELD from '@salesforce/schema/User.Name';
import getUserDetail from '@salesforce/apex/UserSearch.getUserDetail';
import getQueuesFromUser from '@salesforce/apex/lightningUserPage.getQueueFromUser';
import getQueuesAll from '@salesforce/apex/lightningUserPage.getQueueFromAll';
import getPublicGroupFromUser from '@salesforce/apex/lightningUserPage.getPublicGroupFromUser';
import getPublicGroupAll from '@salesforce/apex/lightningUserPage.getPublicGroupFromAll';
import updateUser from '@salesforce/apex/lightningUserPage.updateUser';
import insertQueueForUser from '@salesforce/apex/lightningUserPage.insertQueueForUser';
import getAllPS from '@salesforce/apex/lightningUserPage.getAllPS';
import getPS from '@salesforce/apex/lightningUserPage.getPS';
import insertPermissionSetAssignment from '@salesforce/apex/lightningUserPage.insertPermissionSetAssignment';
import LightningAlert from 'lightning/alert';

export default class CreateUserFlow extends LightningModal {
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: TIMEZONE_FIELD })
    timeZoneValues;
    timeZoneOptions;
    createUser = true;
    formChanged;
    userFirstName;
    userLastName;
    userUserName;
    userEmail;
    userAlias;
    userIsActive = false;
    userProfile;
    userTimeZone;
    profileOptions;
    //Queues
    selectedQueues;
    existingQueues;
    options = [];
    values = [];
    // public group variables 
    allPublicGroups;
    selectedPublicGroups;
    existingPublicGroups;
    optionsPG = [];
    valuesPG = [];
    // permission set variables
    allPermissionSets;
    selectedPermissionSets;
    existingPermissionSets;
    optionPS = [];
    valuesPS = [];
    async connectedCallback() {
        // Get All Profiles and use it in options
        const profileNames = await getProfilesAll();
        this.profileOptions = profileNames.map((data) => ({ ...{ 'label': data.Name, 'value': data.Name } }))
        // Get timezone values from wire method
        console.log(this.timeZoneValues);
        this.timeZoneOptions = this.timeZoneValues.data.values.map(option => ({ label: option.label, value: option.value }));

        //1 Get all the queues available
        let allQueues = await getQueuesAll();
        console.log('modal queues', allQueues);
        let newallQueues = await this.convertToOptions(allQueues);
        console.log('new = ', JSON.stringify(newallQueues));
        this.options = newallQueues;

        //2 Get Public group all details
        await this.initPublicGroup();
        this.optionsPG = await this.convertToOptions(this.allPublicGroups);

        //3 Get permission set 
        await this.initPermissionSets();
        this.optionPS = await this.allPermissionSets.map((data) => ({ ...{ 'label': data.Name, 'value': data.Name } }));

    }
    async initPublicGroup() {
        this.allPublicGroups = await getPublicGroupAll();
    }
    // Get All permission Sets
    async initPermissionSets() {
        this.allPermissionSets = await getAllPS();
    }
    async renderedCallback() {
        if (this.options && this.optionsPG) {
            console.log('Queue loaded');
        }

    }
    async convertToOptions(listOptions) {
        return listOptions.map((data) => ({ ...{ 'label': data.Name, 'value': data.Name } }));
    }
    // onchange - get all queues in selected section
    async handleQueueChange(e) {
        console.log(e.detail.value);
        this.selectedQueues = e.detail.value;
    }
    //on change - public groups 
    handlePublicGroupChange(e) {
        this.selectedPublicGroups = e.detail.value;
    }
    // on change - permission set
    handlePermissionSetChange(e) {
        this.selectedPermissionSets = e.detail.value;
    }
    // handler for any changes performed in the user create form
    handleFormChange(e) {
        // get the label of the form input field
        let choice = e.target.label;
        this.formChanged = true;
        // save it in the required variables
        switch (choice) {
            case 'FirstName':
                console.log('FirstName', e.target.value);
                this.userFirstName = e.target.value;
                break;
            case 'LastName':
                console.log('LastName', e.target.value);
                this.userLastName = e.target.value;
                break;
            case 'UserName':
                console.log('UserName', e.target.value);
                this.userUserName = e.target.value;
                break;
            case 'Email':
                console.log('Email', e.target.value);
                this.userEmail = e.target.value;
                break;
            case 'Alias':
                console.log('Alias', e.target.value)
                this.userAlias = e.target.value;
                break;
            case 'Profile':
                console.log('Profile', e.target.value)
                this.userProfile = e.target.value;
                break;
            case 'Time Zone':
                console.log('Time Zone', e.target.value)
                this.userTimeZone = e.target.value;
                break;
            case 'isActive':
                console.log('is active', e.target.checked);
                this.userIsActive = e.target.checked;
                break;
            default:
                break;
        }

    }
    async handleSave(e) {
        console.log('Save clicked');
        console.log("🚀 ~ this.userFirstName:", this.userFirstName);
        console.log("🚀 ~ this.userLastName:", this.userLastName);
        console.log("🚀 ~ this.userUserName:", this.userUserName);
        console.log("🚀 ~ this.userEmail:", this.userEmail);
        console.log("🚀 ~ this.userAlias:", this.userAlias);
        console.log("🚀 ~ this.userProfile:", this.userProfile);
        console.log("🚀 ~ this.userIsActive:", this.userIsActive);
        console.log("🚀 ~ this.userTimeZone:", this.userTimeZone);
        this.close();
        try {
            let useridACK = await createUser({'Alias':this.userAlias,'Email':this.userEmail,'firstName':this.userFirstName,'UserName':this.userUserName,'lastName':this.userLastName,'Profile':this.userProfile,'isActive':this.userIsActive,'TimeZone':this.userTimeZone});
            console.log("🚀 ~ useridACK:", useridACK);
            if(useridACK){
                if (this.selectedQueues != undefined) {
                    let queues = this.selectedQueues;
                    console.log("🚀 ~  queues:", queues);
                    let res = await insertQueueForUser({'QueueName':queues,'deleteQueues':null,'UserId':useridACK});
                }
                if (this.selectedPublicGroups != undefined) {
                    let publicGroups = this.selectedPublicGroups;
                    console.log("🚀 ~ publicGroups:", publicGroups);
                    let res = await insertQueueForUser({'QueueName':publicGroups,'deleteQueues':null,'UserId':useridACK});
                }

                if( this.selectedPermissionSets != undefined){
                    let permissionSets = this.selectedPermissionSets;
                    console.log("🚀 ~ permissionSets:", permissionSets);
                    await insertPermissionSetAssignment({'AssigneeId':useridACK,'insertPermissionSet':permissionSets ,'deletePermissionSet':null});
                }
                await LightningAlert.open({
                    message: '😊 User Details updated Successfully',
                    theme: 'Success', // a green theme intended for success status
                    label: '🎊🎉 Success 🎉🎊', // this is the header text
                });
            }
        } catch (error) {
            alert(error.body.message)
        }

        
       
    }
}