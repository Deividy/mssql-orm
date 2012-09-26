#  --------- @Usage --------------------- #
DbSchema =  require("../mssql-orm").DbSchema
DbTable =   require("../mssql-orm").DbTable
fs = require('fs')

env = "development"

data = JSON.parse(fs.readFileSync("./config.json", "utf-8"))
config = data[env].database.mssql
	
m = new DbSchema(config)
m.getDbTree((tree)->
  tables = tree.tables
  console.log(tables.msgs)
)

###
  for table of tables
    table = class extends DbTable

  new users()
data = [{ users_id:1, login: 'deividy', pass: '123' }, { login: 'deividy', pass: '123' }]
models = {
  User: {
    ...
  },
  Msg: {
    ...
  } 
}
u = new m.User(data)
u.setLogin('d')
u.save()
###