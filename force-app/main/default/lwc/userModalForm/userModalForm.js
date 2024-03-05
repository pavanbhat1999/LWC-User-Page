import { api,wire } from 'lwc';
import LightningModal from 'lightning/modal';
import NAME_FIELD from '@salesforce/schema/User.Name';
import getUserDetail from '@salesforce/apex/lightningUserPage.getUserDetail';
import getQueuesFromUser from '@salesforce/apex/lightningUserPage.getQueueFromUser';
import getQueuesAll from '@salesforce/apex/lightningUserPage.getQueueFromAll';
import getPublicGroupFromUser from '@salesforce/apex/lightningUserPage.getPublicGroupFromUser';
import getPublicGroupAll from '@salesforce/apex/lightningUserPage.getPublicGroupFromAll';
import updateUser from '@salesforce/apex/lightningUserPage.updateUser';
import insertQueueForUser from '@salesforce/apex/lightningUserPage.insertQueueForUser';
import getProfilesAll from '@salesforce/apex/lightningUserPage.getProfiles';
import getAllPS from '@salesforce/apex/lightningUserPage.getAllPS';
import getPS from '@salesforce/apex/lightningUserPage.getPS';
import insertPermissionSetAssignment from '@salesforce/apex/lightningUserPage.insertPermissionSetAssignment';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import LightningAlert from 'lightning/alert';

export default class UserModalForm extends LightningModal {
    @api content;
   // @api options=[];
    nameField = NAME_FIELD;
    userId;
    userDetails;
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
    // General variables
    disabledValue;
    // User form fields 
    formChanged=false;
    userName=''; //!not tested
    userAlias;
    userIsActive;
    profile;
    profileOptions;
    classicUserPageURL;
    async connectedCallback(){
        //1 :  Get Data from Parent Item
        // this.values.length = 0;
        // this.options.length = 0;
        this.userId = this.content[0];
        this.disabledValue = this.content[1];
        this.classicUserPageURL = window.location.origin+'/lightning/setup/ManageUsers/page?address=%2F'+this.userId+'%3Fnoredirect%3D1%26isUserEntityOverride%3D1';
        //-------------------------------------------------------------------------
        //2 : Get User details
        this.userDetails = await getUserDetail({'UserId':this.userId})
        console.log('Username = ',JSON.stringify(this.userDetails));
        //TODO: initialize all user variables
        this.userName = this.userDetails[0].Name;
        this.userAlias = this.userDetails[0].Alias;
        this.userIsActive = this.userDetails[0].IsActive;
        console.log('alias',this.userAlias)
        //-------------------------------------------------------------------------
        //3:  get all the queues available
        let allQueues = await getQueuesAll();
        console.log('modal queues',allQueues);
        // TODO: Unit Test
        let newallQueues = await this.convertToOptions(allQueues);
        console.log('new = ',JSON.stringify(newallQueues));

        //-------------------------------------------------------------------------
        //4: get existing queues for user
        this.existingQueues = await getQueuesFromUser({Id : this.userId});
        let newexistingQueues = [];
        for(let j=0;j<this.existingQueues.length;j++)
        newexistingQueues.push(
            this.existingQueues[j].Group.Name
        )
        this.options = newallQueues;
        this.values.push(...newexistingQueues);
        console.log('Exisitng Queues for the user = ',JSON.stringify(this.values))
        //-------------------------------------------------------------------------
        // Public group all details
        await this.initPublicGroup();
        this.existingPublicGroups = await getPublicGroupFromUser({'Id':this.userId})
        let newexistingPublicGroups = [];
        for(let j=0;j<this.existingPublicGroups.length;j++)
        newexistingPublicGroups.push(
            this.existingPublicGroups[j].Group.Name
        )
        this.optionsPG = await this.convertToOptions(this.allPublicGroups);
        this.valuesPG.push(...newexistingPublicGroups); // !ERROR: retest it
        //! testing required for this one line 
        //this.selectedPublicGroups = this.valuesPG;
        //5:  get permission set 
        await this.initPermissionSets();
        let ps = await getPS({'usernameps':this.userId});
        this.existingPermissionSets = ps;
        console.log('assigned ps = ',ps);
        this.optionPS = await this.allPermissionSets.map((data)=>({...{'label':data.Name,'value':data.Name}}));
        for(let k=0;k<ps.length;k++)
        this.valuesPS.push(ps[k].PermissionSet.Name)
        console.log(this.valuesPS)
        //-------------------------------------------------------------------------
        //6: get all profile details
        let profileNames = await getProfilesAll();
        profileNames = profileNames.map((data)=>({...{'label':data.Name,'value':data.Name}}))
        this.profileOptions = profileNames;

   }
   // Get initial data for Public Group
    async initPublicGroup(){
        this.allPublicGroups = await getPublicGroupAll();
   }
   // Get All permission Sets
   async initPermissionSets(){
        this.allPermissionSets = await getAllPS();
   }
   // Mapping function for options extraction
    async convertToOptions(listOptions){
       return listOptions.map((data)=>({...{'label':data.Name,'value':data.Name}}));
   }
   // onchange - get all queues in selected section
   async handleQueueChange(e){
    console.log(e.detail.value);
    this.selectedQueues = e.detail.value;
   }
   // on change - public groups 
   handlePublicGroupChange(e){
    this.selectedPublicGroups = e.detail.value;
   }
   // on change - permission set
   handlePermissionSetChange(e){
    this.selectedPermissionSets = e.detail.value;
   }
   // * All The change event handlers in the form
   // handle Name change 
   handleFormChange(e){
    // get the label of the form input field
    let choice = e.target.label;
    this.formChanged = true;
    // save it in the required variables
    switch (choice) {
        case 'Name':
            console.log('Name',e.target.value);
            this.userName = e.target.value;
            break;
        case 'Email':
            console.log('Email',e.target.value)
            break;
        case 'Alias':
            console.log('Alias',e.target.value)
            this.userAlias = e.target.value;
            break;
        case 'Profile':
            console.log('Profile',e.target.value)
            this.profile = e.target.value;
            break;
        case 'isActive':
            console.log('is active',e.target.checked);
            this.userIsActive = e.target.checked;
            break;
        default:
            break;
    }
    //this.userName = e.detail.value;
   }
  
   // onclick - on save button click update queue assignment
   async handleSave(e){
    console.log('Save clicked and Value ',this.userName);
    // TODO: remove this after testing
    // if(this.selectedQueues == undefined){
    //     console.log('Queues not changed ');
    //     return;
    // }
    //TODO: Get all field values and update record using apex
    //!FIXME: check if something changed in form and then perform this
    if(this.formChanged){
        let arr = this.userName.split(/ (.*)/);
        console.log('split ',JSON.stringify(arr));
        console.log('alias' , this.userAlias);
        console.log('Active',this.userIsActive);
        //! remove after testing
        let userCreateResponse = await updateUser({'UserId':this.userId,'FirstName':arr[0],'LastName':arr[1],'Alias':this.userAlias,'IsActive':this.userIsActive,'Profile':this.profile});
    }
    // TODO: refactor it.  
    if(this.selectedQueues != undefined ){
    let a = this.selectedQueues; 
    console.log('selected Queues',JSON.stringify(a))
    let b = this.existingQueues.map((data)=>(data.Group.Name)); 
    console.log('existing queues ',JSON.stringify(b))
    let c = a.filter((x)=>!b.includes(x))  //* a difference b : a-b 
    console.log('Inserting Queue',JSON.stringify(c))
    let d = b.filter((x)=>!a.includes(x))  //* b difference a : b-a
    console.log('Deleting Queue',JSON.stringify(d))
    
    // Public Group details
    console.log('Selected Groups ',JSON.stringify(this.selectedPublicGroups));

    let res = await insertQueueForUser({'QueueName':c,'deleteQueues':d,'UserId':this.userId});
    }
    if(this.selectedPublicGroups != undefined ){
        let a = this.selectedPublicGroups; 
        console.log('selected Groups ',JSON.stringify(a))
        let b = this.existingPublicGroups.map((data)=>(data.Group.Name)); 
        console.log('existing Groups ',JSON.stringify(b))
        let c = a.filter((x)=>!b.includes(x))  //* a difference b : a-b 
        console.log('Inserting Groups ',JSON.stringify(c))
        let d = b.filter((x)=>!a.includes(x))  //* b difference a : b-a
        console.log('Deleting Groups ',JSON.stringify(d))
        
        // Public Group details
        console.log('Selected Groups ',JSON.stringify(this.selectedPublicGroups));
    
        let res = await insertQueueForUser({'QueueName':c,'deleteQueues':d,'UserId':this.userId});
        }
    
    // ! Permission set addition and deletion
    if( this.selectedPermissionSets != undefined){
        let a1 = this.selectedPermissionSets;
        let b1 = this.existingPermissionSets.map((data)=>(data.PermissionSet.Name)); 
        let c1 = a1.filter((x)=>!b1.includes(x))  //* a difference b : a-b 
        console.log('Inserting Permission Set',JSON.stringify(c1))
        let d1 = b1.filter((x)=>!a1.includes(x))  //* b difference a : b-a
        console.log('Deleting Permission Set',JSON.stringify(d1))
        await insertPermissionSetAssignment({'AssigneeId':this.userId,'insertPermissionSet':c1 ,'deletePermissionSet':d1});
    }
    //!
    // ? should use toast message or alert message
    // this.dispatchEvent(
    //     new ShowToastEvent({
    //         title: "Success",
    //         message: "Operation Successfully completed",
    //         variant: "success",
    //     })
    // );
        // ? should use toast message or alert message
    await LightningAlert.open({
        message: '😊 User Details updated Successfully',
        theme: 'Success', // a green theme intended for success status
        label: '🎊🎉 Success 🎉🎊', // this is the header text
    });
    this.close(this.userName);
   }
}