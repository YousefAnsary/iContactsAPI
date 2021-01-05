**A Token Authenticated Vapor Swift RESTful-API that provides basic CRUD functionality for contacts using a local SQLite DB** <br/> <br/>
## Running The API <br/>
firstly make sure you have installed Vapor on your machine <br/>
Clone the repo then Navigate your terminal to its path then run <br/> 
``` vapor run ``` <br/>
and the build process will begin and deploy the API on <br/>
``` http://localhost:8080/ ``` <br/> <br/>
***Endpoints:*** <br/>
***Authentication:***
| path  | Params  | Return Type |
| :------------ |:---------------:|:-----:|
| login | email: String, password: String | UserData
| register | name: String, email: String, <br/> password: String, confirmPassword: String | UserData
<br/>

***Contacts:*** <br/>

| path | Params | Headers | Return Type |
| :--- | :---: | :---: | :---: |
| contacts/get | - | Authorization | Array<Contact>
| contacts/create | [Contact] | Authorization | -
| contacts/update | Contact | Authorization | -
| contacts/delete | contactId: Int (Query Param) | Authorization | -
    
<br/>***Types:*** <br/>
***UserData*** <br/>
```
var name: String
var email: String
var token: String
var tokenCreationDate: Date
var tokenExpireDate: Date
```
<br/>***UserData*** <br/>
```
var id: Int
var name: String
var phoneNumbers: [String]
var emails: [String]
```
