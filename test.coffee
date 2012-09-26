### OUTPUT  
{ 
	"users": { 
		"pk": "users_id",
		"columns": { 
			"users_id": { },
			"login": { },
			"pass": { }
		},
		"hasMany": [ "msgs" ]
	},
	"msgs": { 
		"pk": "msg_id",
		"fk": { 
			"FK__MSG...." : "pk_users_id" 
		}, 
		"columns": { 
			"msg_id": { },
			"users_id": { },
			"message": { }
		},
		"belongsTo": [ "users" ]
	}
}
###

#  --------- @Usage --------------------- #
DbSchema = require("./DbSchema")
tds = require('tds')
fs = require('fs')

env = "development"

data = JSON.parse(fs.readFileSync("./config.json", "utf-8"))
config = data[env].database.mssql
conn = new tds.Connection(config)	

m = new DbSchema(conn)
m.mountDbTree(console.log)
