tables = [
    {
      name: 'users',
      pk: 'users_id',
      hasMany: [ 'msgs' ]
    },
    {
      name: 'msgs',
      pk: 'msg_id',
      belongsTo: [ 'users' ]
    }
]

DbTable = require('../lib/DbTable')

for tbl in tables
  tbl.class = class extends DbTable
    table: tbl.name
  
m = new tables[0].class
# m.select
q = m.query()
console.log q
# console.log(m.getTable())