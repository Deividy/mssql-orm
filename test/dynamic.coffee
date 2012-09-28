#  --------- @Usage --------------------- #
DynamicModels = require("../mssql-orm").DynamicModels

fs = require('fs')

env = "development"

data = JSON.parse(fs.readFileSync("./config.json", "utf-8"))
config = data[env].database.mssql

dnm = new DynamicModels(config)
dnm.makeModels((m) ->
  user = new m.Users()

  user.setLogin("xxxx")
  console.log(user.getLogin())
  user.save()

  data = {
    id: 2
    login: "test"
    pass: 123
  }
  user = new m.Users(data)
  user.save()

  user = new m.Users([ data, { login: 'TestMan', pass: 'idontahave'} ])
  user.save()
)
