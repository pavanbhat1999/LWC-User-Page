import { LightningElement } from 'lwc';
import USER_TEMPLATE from '@salesforce/resourceUrl/User_Template';
import searchUser from '@salesforce/apex/lightningUserPage.searchUser';
import createUserModal from 'c/createUserFlow';
import insertUserBulk from '@salesforce/apex/lightningUserPage.insertUserBulk';
import userModal from 'c/userModalForm';
//?import {ShowToastEvent} from "lightning/platformShowToastEvent";
import { NavigationMixin } from 'lightning/navigation';

 const actions = [
     { label: 'View', name: 'View' },
     { label: 'Edit', name: 'Edit' },
 ];
const columns = [
    { 
        label: 'Name', 
        fieldName: 'newID', 
        type: 'url',
        typeAttributes: { 
            label: { fieldName: 'Name' },
            } 
    },
    {
        type: 'button-icon',
        label: 'View',
        // initialWidth: 75,
        typeAttributes: {
            iconName: 'action:preview',
            title: 'Preview',
            variant: 'brand',
            alternativeText: 'View',
            rowActions: actions
        }
    },
    {
        type: 'button-icon',
        label: 'Edit',
        // initialWidth: 75,
        typeAttributes: {
            iconName: 'action:edit',
            title: 'Edit',
            variant: 'brand',
            alternativeText: 'Edit',
            rowActions: actions
        }
    },

 
];
export default class NnioUserAutomationCustom extends NavigationMixin(LightningElement) {
    searchUserName;
    existingUserList;
    selectedUser;
    columns = columns;
    userQueueList;
    classicUserPageURL;
    downloadTemplateURL;
    // Variables for bulk data load  
    allCSVData;  
    datacsv; //uploading data
    headers; //headers extracted from file
    mappingHeaders={};
    //*NOTE: can modify to add all fields which can be imported 
    // ? can use a custom label here to make it easy for the admins
    headersUserObject = ["Alias","FirstName","LastName","Username","Email","Country","Department","ProfileId","TimeZoneSidKey","LocaleSidKey","EmailEncodingKey","LanguageLocalKey","CommunityNickname"];
    headersOptionsFromFile; // options object for lighitng-combobox
  
    async connectedCallback(){
        //? should use initial load or not
        this.initUser();
        console.log(window.location.origin)
        this.classicUserPageURL = window.location.origin+'/lightning/setup/ManageUsers/home';
        this.downloadTemplateURL = USER_TEMPLATE;
    }
    // Init Data - User Details
    async initUser(){
        let loadUser = await searchUser({UserName : 'Pavan Bhat'});
        this.existingUserList = loadUser.map(
            (data) => ({...{'Name':data.Name,'Id':data.Id,'newID':'/'+data.Id}})
        )
    }
    // clearing the temporary data 
    clearTmpData(){
        this.existingUserList = null;
        this.searchUserName = null;
        this.values.length = 0;
        this.options.length = 0;
    }
    //* Currently working on it
    // Download user template
    downloadTemplate(event){
      console.log('Download Template Clicked');
      console.log(USER_TEMPLATE);
      
      // event.preventDefault();
      // const link = document.createElement('a');
      // link.href = window.URL.createObjectURL(USER_TEMPLATE);
      // link.download = 'data.csv';
      // link.click();

    }
    // File upload handler
    handleFileUpload(event) {
        const files = event.detail.files;
    
        if (files.length > 0) {
          const file = files[0];
          
          // start reading the uploaded csv file
          this.read(file);
        }
      }
      async read(file) {
        try {
          const result = await this.load(file);
          
          // execute the logic for parsing the uploaded csv file
          this.parse(result);
        } catch (e) {
          this.error = e;
        }
      }
      async load(file) {
        return new Promise((resolve, reject) => {
          const reader = new FileReader();
    
          reader.onload = () => {
            resolve(reader.result);
          };
          reader.onerror = () => {
            reject(reader.error);
          };
          reader.readAsText(file);
        });
      }
      async parse(csv) {
  // parse the csv file and treat each line as one item of an array
  this.allCSVData = csv.split(/\r\n|\n/);
  console.log('All csv Data Initial = ',JSON.stringify(this.allCSVData) )
  
  //parse the first line containing the csv column headers
  const headers = await this.allCSVData[0].split(',');
  console.log('headers',JSON.stringify(headers))
  this.headers = headers;
  this.headersOptionsFromFile = await this.headers.map((data)=>({...{'label':data,'value':data}}));
  console.log('options headers',JSON.stringify(this.headersOptionsFromFile));
  
  //! remove after migration to another function
  // const data = [];
  
  // //? why -1 is required
  // lines.forEach((line, i) => {
  //   if (i === 0) return;

  //   const obj = {};
  //   const currentline = line.split(',');

  //   for (let j = 0; j < headers.length; j++) {
  //     obj[headers[j]] = currentline[j];
  //   }
  //   console.log('each obj',JSON.stringify(obj));
  //   data.push(obj);
  // });
  
  // // assign the converted csv data for the lightning datatable
  // //this.datacsv = data.map((data)=>(data.NAME));
  // this.datacsv = data;
  
  // console.log('data',JSON.stringify(this.datacsv));
  // try {
  //   //await insertUserBulk({'userJSON':JSON.stringify(this.datacsv)});
  // } catch (error) {
  //   alert('Error:  Please Use Given Template and fill required details \n');
  //   alert(error.body.message)
  // }
 //!
  //? remove this after testing  insert one by one
  // for (let index = 0; index < this.datacsv.length; index++) {
  //   console.log('index',index,this.datacsv[index])
  //   await insertUserBulk(this.datacsv[index]);
    
  // }
 
}
// create User record according to the mapping
async handleUploadWithMapping(e){
  //this.mappingHeaders['Alias'] = "Alias";
  //this.mappingHeaders['firstname'] = "firstname";
  console.log('Fields and Mapped Fields = ',JSON.stringify(this.mappingHeaders));
  console.log('All csv Data after Submit = ',JSON.stringify(this.allCSVData) );

  const data = [];
  const headers = await this.allCSVData[0].split(',');
  for (let key in this.mappingHeaders) {
    console.log(`${key}: ${this.mappingHeaders[key]}`);
    let index = this.headers.indexOf(this.mappingHeaders[key]);
    console.log(index)
    headers[index] = key;
  }

  console.log('headers after mapping ',JSON.stringify(headers));
  const lines = this.allCSVData;
  // //? why -1 is required
  lines.forEach((line, i) => {
    if (i === 0) return;

    const obj = {};
    const currentline = line.split(',');

    for (let j = 0; j < headers.length; j++) {
      obj[headers[j]] = currentline[j];
    }
    console.log('each obj',JSON.stringify(obj));
    data.push(obj);
  });
  
  // assign the converted csv data for the lightning datatable
  //this.datacsv = data.map((data)=>(data.NAME));
  this.datacsv = data;
  
  console.log('data = ',JSON.stringify(this.datacsv));
  try {
    await insertUserBulk({'userJSON':JSON.stringify(this.datacsv)});
    alert('Bulk user creation successful');
  } catch (error) {
    alert('Error:  Please Use Given Template and fill required details \n');
    alert(error.body.message)
  }
//window.location.reload();
}
onchangeMapping(e){
  //? Method 1 : For loop
  //! test this new method less code
  for (let index = 0; index < this.headersUserObject.length; index++) {
    console.log(this.headersUserObject[index]);
    this.mappingHeaders[e.target.label] = e.target.value;
  }
  //? Method 2 : switch case less time complexity 
  // switch (e.target.label) {
  //   case 'Alias':
  //     this.mappingHeaders['Alias'] = e.target.value;
  //     break;
  //   case 'FirstName':
  //     this.mappingHeaders['FirstName'] = e.target.value;
  //     break;
  //   case 'LastName':
  //     this.mappingHeaders['LastName'] = e.target.value;
  //     break;
  //   case 'Email':
  //     this.mappingHeaders['Email'] = e.target.value;
  //     break;      
  //   default:
  //     break;
  // }

}

     //*END Currently working on it 
    // onchange - Getting user name which is to be searched 
    changeSearchUserName(event){
        console.log('Search User Changing = '+event.target.value);
        this.searchUserName = event.target.value;
    } 
    // onkeypress - when enter is pressed
    handleEnter(event){
        console.log(event.keyCode);
        if(event.keyCode === 13){
            this.handleSubmitUser();
        }
    }
    // onsubmit - Getting user name which is to be searched 
    async handleSubmitUser(event){
        // clear the selected user selection
        this.selectedUser = null;
        console.log("User to be searched = ",this.searchUserName);
        const res = await searchUser({UserName : this.searchUserName});
        // TODO: Optimize and refactor newres 
        // get details and make a url out of it to navigate  
        let newres = [];
        for(var j=0;j<res.length;j++)
        newres.push({'Name':res[j].Name,'Id':res[j].Id,'Profile':res[j].Profile.Name,'newID':'/'+res[j].Id});  
        this.existingUserList = newres;
        console.log('Export User Json stringify',JSON.stringify(newres));
    }
    // export user list after search
    async handleUserExport(event){
      console.log("🚀 ~ event:", event);
      console.log("🚀 ~ this.existingUserList:", JSON.stringify(this.existingUserList));
      const csvData = this.convertJSONToCSV(this.existingUserList);
      console.log("🚀 ~ csvData:", csvData);
      this.createAndDownloadFile(csvData, 'output.csv');
    }
    convertJSONToCSV(jsonData){
      if (!jsonData || jsonData.length === 0) {
        console.error('Invalid JSON data');
        return null;
    }

    const headers = Object.keys(jsonData[0]);
    const csvContent = [
        headers.join(','),
        ...jsonData.map(obj => headers.map(header => obj[header]).join(','))
    ].join('\n');

    return csvContent;
    }
    createAndDownloadFile(fileContent, fileName) {
      const blob = new Blob([fileContent], { type: 'text/plain' });

      const link = document.createElement('a');
      link.href = window.URL.createObjectURL(blob);
      link.download = fileName;

      // Trigger a click on the link to initiate download
      link.click();
  }
    
    // onrowaction - Clicked on action icons on data table
    async onRowActionClick(event){
        console.log(event.detail.action.title);
        if(event.detail.action.title === 'Preview'){
            const result = await userModal.open({
                size: 'large',
                description: 'Accessible description of modal\'s purpose',
                content : [event.detail.row.Id,true],
            });
            console.log('User result = ',result);
        }
        if(event.detail.action.title === 'Edit'){
            const result = await userModal.open({
                size: 'large',
                description: 'Accessible description of modal\'s purpose',
                content : [event.detail.row.Id,false],
            });
            console.log('User result = ',result);
            //! find optimal way to reload only apex
            //window.location.reload()
            //this.clearTmpData();
        }
    }

    // opening user create modal - onclick - Create User Icon
    async OpenUserCreateModal(event){
        const result = await createUserModal.open({
            size: 'large',
            description: 'Create User Modal',
            content: 'Passed into content api',
        });
        console.log('flow result = ',result);
    }
}