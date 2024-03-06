Addding a field into the form

User Role in create 

html 
                <lightning-combobox type="" label="Role" value={userRole} options={userRoleOptions} disabled={disabledValue} onchange={handleFormChange}></lightning-combobox><br>


js
1. 

  import getUserRolesAll from '@salesforce/apex/lightningUserPage.getUserRoles';
2.
     userRole 
3.
userRoleOptions;
4. 
            case 'Role':
                console.log('Role',e.target.value)
                this.userRole = e.target.value;
                break;

5.
update or create


apex 

create or update 
   
           UserRole myRole = [select id from UserRole where Name = :UserRole LIMIT 1]; 