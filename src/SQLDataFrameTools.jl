module SQLDataFrameTools

using DataFrameTools
using SHA
using DBInterface
using Dates
using DataFrames

export QueryCache, df_cached, select_fn, expired

"""
QueryCache(sql, select, dir, format;  subformat=nothing, dictencode=true)
is the Data Structure used in this module.

`sql` is the SQL Query
`select` is the function used to retrieve the dataset (which can be created with select_sql)
`dir` is the directory in which to store the cache file
`format` is one of the file formats supported. See DataFrameTools.df_formats() for the list.
`subformat` and `dictencode` are optional parameters for DataFrameTools.df_write

Example:

query = QueryCache("SELECT 1",  select_fn(MySQL.Connection, SERVER, USER, PASSWORD), ".", :jdf)
"""
struct QueryCache
	sql
	select
	cachepath
	subformat::Union{Nothing,Symbol}
	dictencode::Bool
	QueryCache(sql, select, dir, format;  subformat=nothing, dictencode=true) = new(sql, select, cachepath(dir, bytes2hex(sha256(sql)), format), subformat, dictencode)
end

cachepath(dir, hash, sformat) = joinpath(dir, hash * '.' * string(sformat))

"""
expired(q::QueryCache, expires::DateTime)
expired(q::QueryCache, ttl::Period)

Has the cache file expired. If the file doesn't exist always return true, otherwise check the mtime against the given time

`expired(query, Dates.Day(3))` # returns a bool of whether the cache is more than 3 days old 
`expired(query, Dates.Minute(30))` # returns a bool of whether the cache is more than 30 minutes old 
`expired(query, Dates.DateTime(2021, 1, 1, 1, 2, 3))` # returns a bool compared to the given time

"""
expired(q::QueryCache, expires::DateTime) = expires <= now() || stat(q.cachepath).device == 0
expired(q::QueryCache, ttl::Period) = expired(q, unix2datetime(mtime(q.cachepath)) + ttl)
	
"""	
df_cached[q, ttl_e; noisy=false)

ttl_e is either a DataTime or Period specifying how long the cache should be live.

If the cached version of the DataFrame is still live, return it from disk.

If it has expired, call the Query's sql_function with the sql, write the DataFrame to disk 
in the specified formats and return the DataFrame.

The noisy flag indicates whether to print where the data is coming from to stderr.

Example

`df = df_cached(query, now())` # this will always retrive the SQL from the server
`df = df_cached(query, Dates.Day(7), noisy=true)` # this use the cached version until it is 7 days old and will print "From Server" or "From Cache" depending where it came from.

"""
function df_cached(q::QueryCache, ttl_e; noisy=false)
	if expired(q.cachepath, ttl_e)
		if noisy
			println(stderr, "From Server")
		end
		df = q.select(q.sql)
		df_write(q.cachepath, df, subformat=q.subformat, dictencode=q.dictencode)
		return df
	else
		if noisy
			println(stderr, "From Cache")
		end
		df_read(q.cachepath)
	end
end

"""
select_fn(conn, server, user, password) = sql->...

Return a function which will `execute` the supplied sql

Example:

sql_fn = select_fn(MySQL.Connection, SERVER, USER, PASSWORD)

"""
select_fn(conn, server, user, password) = sql->DBInterface.execute(DBInterface.connect(conn, server, user, password), sql) |> DataFrame 

###
end

