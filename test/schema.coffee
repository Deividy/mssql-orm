#  --------- @Usage --------------------- #
DbSchema =  require("../mssql-orm").DbSchema
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
)
