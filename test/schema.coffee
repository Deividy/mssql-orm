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

    models[tableName] = class
      constructor: (@data) ->
        if(!@data) then @data = []

      save: ->
        console.log(@data)

    for colName, data of tableData.columns
      models[tableName]::["set"] = (field, value) -> 
        @data[field] = value

      models[tableName]::["get"] = (field) -> 
        return @data[field]

  user = new models['users']()
  user.set("users_id", 'oi')
  user.set("login", "Teste")
  user.save()
)