_ = require('underscore')

class SqlFormatter
    @f: (v) ->
        if (_.isString(v))
            return "'" + v.replace("'","''") + "'"

        return v.toString()

module.exports = SqlFormatter
