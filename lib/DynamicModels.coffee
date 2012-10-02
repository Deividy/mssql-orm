DbSchema = require('./DbSchema')
DbTable = require('./DbTable')

class DynamicModels extends DbSchema
    _nameConvention = (name) ->
        # Up first char and format name
        upc = name.substring(0, 1)
        name = name.replace(upc, upc.toUpperCase());
        return name

    makeModels: (callback) ->
        self = @
        nConvetion = @_nameConvention

        @getDbTree((tree)->
            tables = tree.tables
            models = {}
            for tableName, tableData of tables
                # Create the model
                models[nConvetion(tableName)] = class extends DbTable
                    # For static methods
                    @tableName: tableName
                    @tableSchema: tableData

                    # For instance methods
                    tableName: tableName 
                    tableSchema: tableData

                # Getters and setters
                for column of tableData.columns
                    models[nConvetion(tableName)]::["get#{nConvetion(column)}"] = -> 
                        @data[column]
                    models[nConvetion(tableName)]::["set#{nConvetion(column)}"] = (val) -> 
                        @data[column] = val

            callback(models)
        )

module.exports = DynamicModels
