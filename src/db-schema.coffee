Database = require("./database")

class DbSchema
    constructor: (config) ->
        @db = new Database(config)

    getAllTablesName: (tables, callback) ->
        @db.getRows("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES", (data) ->
            data.forEach((item)->
                tblName = item.getValue('TABLE_NAME')
                tables[tblName] = {}
            )
            callback(tables)
        )

    getConstraints: (tables, callback) ->
        self = @
        @db.getRows("SELECT a.CONSTRAINT_NAME, a.TABLE_NAME, a.CONSTRAINT_TYPE,
            b.COLUMN_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS a
            LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE b on
            a.CONSTRAINT_NAME = b.CONSTRAINT_NAME", (data) ->
            fkeys = []
            uniques = []
            fkColumns = []

            data.forEach((item) ->
                colName = item['CONSTRAINT_NAME']
                tblName = item['TABLE_NAME']
                constraintKey = item['CONSTRAINT_TYPE']
                column = item['COLUMN_NAME']

                if (!tables[tblName])
                    tables[tblName] = {}
                    tables[tblName]['name'] = tblName
                    tables[tblName]["fk"] = []
                    tables[tblName]["uniques"] = []
                    tables[tblName]["belongsTo"] = []
                    tables[tblName]["hasMany"] = []
                    tables[tblName]['columns'] = {}

                switch (constraintKey)
                    when "PRIMARY KEY", "UNIQUE"
                        if (!uniques[tblName])
                            uniques[tblName] = []

                        if (!uniques[tblName][colName])
                            uniques[tblName][colName] = {}
                            uniques[tblName][colName].columns = []
                            uniques[tblName][colName].type = constraintKey.replace(" ","_")

                        uniques[tblName][colName].columns.push(column)

                    when "FOREIGN KEY"
                        if (!fkColumns[tblName])
                            fkColumns[tblName] = []

                        if (!fkColumns[tblName][colName])
                            fkColumns[tblName][colName] = []

                        fkColumns[tblName][colName].push(column)
                        fkeys.push( { "tblName": tblName, fKey :colName  })
            )
            for tbl of uniques
                for ck of uniques[tbl]
                    keys = { name: ck, columns: [] }
                    for cl in uniques[tbl][ck].columns
                        keys.columns.push(cl)

                    keys.type = uniques[tbl][ck].type

                tables[tbl].uniques.push(keys)

            fkeys.forEach((fk) ->
                # SHOULD: Replace it with a single query
                self.db.getRows("SELECT a.CONSTRAINT_TYPE, a.TABLE_NAME,
                        b.CONSTRAINT_NAME, b.UNIQUE_CONSTRAINT_NAME,
                        b.UPDATE_RULE, b.DELETE_RULE FROM
                            INFORMATION_SCHEMA.TABLE_CONSTRAINTS a LEFT JOIN
                            INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS b
                                on a.CONSTRAINT_NAME = b.UNIQUE_CONSTRAINT_NAME

                        WHERE b.CONSTRAINT_NAME = '#{fk.fKey}'", (data) ->

                    data.forEach((item) ->
                        belongs = item['TABLE_NAME']
                        tkey = item['UNIQUE_CONSTRAINT_NAME']
                        ck = item['CONSTRAINT_NAME']

                        targetKey = {
                            name: tkey
                            columns: fkColumns[fk.tblName][ck]
                        }
                        fKey = {
                            fk: ck
                            targetKey: targetKey
                            targetTable: belongs
                            onDelete: item['DELETE_RULE']
                            onUpdate: item['UPDATE_RULE']
                        }

                        tables[fk.tblName]["fk"].push(fKey)
                        tables[fk.tblName]["belongsTo"].push(belongs)
                        tables[belongs]["hasMany"].push(fk.tblName)

                        callback(tables)
                    )
                )
            )
        )

    getColumns: (tables, callback) ->
        @db.getRows("SELECT TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION,
            COLUMN_DEFAULT, IS_NULLABLE, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH,
            CHARACTER_OCTET_LENGTH FROM INFORMATION_SCHEMA.COLUMNS", (data) ->
            data.forEach((item) ->
                tblName = item['TABLE_NAME']
                colName = item['COLUMN_NAME']

                tables[tblName]['columns'][colName] = {
                     index: item['ORDINAL_POSITION']
                     default: item['COLUMN_DEFAULT']
                     isNull: item['IS_NULLABLE']
                    type: item['DATA_TYPE']
                    maxLength: item['CHARACTER_MAXIMUM_LENGTH']
                    octLength: item['CHARACTER_OCTET_LENGTH']
                }
            )
            callback(tables)
        )

    buildDbTree: (callback) ->
        self = @
        dbTree = {}
        @getConstraints(dbTree, (tables) ->
            self.getColumns(tables, (tables) ->
                dbTree = { tables: tables }
                callback(dbTree)
            )
        )

    getDbTree: (callback) ->
        @buildDbTree(callback)

module.exports = DbSchema
