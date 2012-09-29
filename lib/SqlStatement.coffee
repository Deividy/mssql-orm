class SqlStatement
	# SqlStatment knows everything about the table
	constructor: (@tableSchema) ->

	save: ->
		###
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
		###

	select: ->

	insert: ->

	update: ->

	where: ->
