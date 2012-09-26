### OUTPUT  
{ sysdiagrams: 
   { pk: '_sysdiagr__C2B05B61060DEAE8',
     uq: 'principal_name',
     columns: 
      { name: [Object],
        principal_id: [Object],
        diagram_id: [Object],
        version: [Object],
        definition: [Object] } },
  users: 
   { pk: 'users_id',
     hasMany: [ 'msgs' ],
     columns: { users_id: [Object], login: [Object], pass: [Object] } },
  msgs: 
   { pk: 'msg_id',
     fk: [ 'FK__msgs__users_id__1920BF5C' ],
     belongsTo: [ 'users' ],
     columns: { msg_id: [Object], users_id: [Object], msg: [Object] } } }

[
  'tables' : [
    {
      name: 'users',
      pk: 'users_id',
      hasMany: [ 'msgs' ]
    }
  ]
]
###

#  --------- @Usage --------------------- #
DbSchema =  require("../mssql-orm").DbSchema
DbUtils =   require("../mssql-orm").DbUtils
DbTable =   require("../mssql-orm").DbTable

fs = require('fs')

env = "development"

data = JSON.parse(fs.readFileSync("./config.json", "utf-8"))
config = data[env].database.mssql
	
m = new DbSchema(config)
m.getDbTree((tree)->
  console.log(tree.tables.msgs)

)