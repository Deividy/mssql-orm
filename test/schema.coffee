#  --------- @Usage --------------------- #
DbSchema =  require("../mssql-orm").DbSchema
DbTable =   require("../mssql-orm").DbTable
DbUtils =   require("../mssql-orm").DbUtils
fs = require('fs')

env = "development"

data = JSON.parse(fs.readFileSync("./config.json", "utf-8"))
config = data[env].database.mssql
	
dbs = new DbSchema(config)
dbs.getDbTree((tree)->
  tables = tree.tables
  models = {}

  for tableName, tableData of tables
    # Debugging..
    console.log("---")
    console.log("#{tableName}:")
    console.log(tableData)
    console.log("Uniques: ")
    console.log(tableData.uniques)
    console.log("FK")
    console.log(tableData.fk)
    console.log("---")
    # ..

   ### Tests with dynamic model
    models[tableName] = class extends DbTable
      table: tableData.name

      constructor: (@data) ->
        if(!@data) then @data = []

      save: ->
        console.log(@data)

    for colName, data of tableData.columns
      models[tableName]::["set"] = (field, value) -> 
        @data[field] = value

      models[tableName]::["get"] = (field) -> 
        return @data[field]

  user = new models['users']
  user.set("login", "testing")
  user.set('pass', 123)
  user.save()

  data = {
    users_id: 2
    login: "test"
    pass: 123
  }
  user = new models['users'](data)
  user.save()
  ###
)