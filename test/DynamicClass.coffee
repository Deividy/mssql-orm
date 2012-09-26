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

for tbl in tables
	tbl.class = class
		@table = tbl.name

		constructor: ->

		getTable: ->
			@table

m = new tables[0].class()
console.log(m)
