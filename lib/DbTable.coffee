_ = require("underscore")
SqlStatement = require('./SqlStatement')

class DbTable
	constructor: (@data) ->
		if(!@data) then @data = { }

	@insert: (data) ->
		console.log("INSERT")
		console.log(data)

	@update: (data, where) ->
		console.log("UPDATE")
		console.log(data)
		console.log(where)

	save: ->
		self = @
		id = 0
		pk = ''

		if (_.isObject(@data))
			console.log("OBJECT")
			if (self.data['id']) then id = self.data['id'] 

			# Check keys
			@tableSchema.uniques.forEach((uks)->
				console.log("UKS")
				console.log(uks)
				console.log("---")
				for col in uks.columns
					if (self.data[col]) then id = self.data[col]
						pk = col
			)

			if (!id)
				@insert(@data)
			else
				@update(@data, { pk: pk, id: id })

		else
			console.log("ARRAY")
			console.log(@data)



module.exports = DbTable