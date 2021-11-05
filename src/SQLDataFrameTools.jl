module SQLDataFrameTools

using DataFrameTools
using SHA
using DBInterface
using Dates
using DataFrames
using Distributed

export QueryCache, df_cached, select_fn, expired, fetch_and_combine, Dfetch_and_combine

"""
    QueryCache(sql, select, dir, format;  subformat=nothing, dictencode=true)
	
is the Data Structure used in this module.

# Arguments

- `sql` is the SQL Query
- `select` is the function used to retrieve the dataset (which can be created with [`select_fn`](@ref))
- `dir` is the directory in which to store the cache file
- `format` is one of the file formats supported. See DataFrameTools.df_formats() for the list.
- `subformat` and `dictencode` are optional parameters for DataFrameTools.df_write

# Examples

`query = QueryCache("SELECT 1",  select_fn(MySQL.Connection, SERVER, USER, PASSWORD), ".", :jdf)`

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
    expired(q::QueryCache, expires::Dates.DateTime)
    expired(q::QueryCache, ttl::Dates.Period)

Has the cache file expired?
If the file doesn't exist always return true, otherwise check the mtime against the given time.

# Examples

`expired(query, Dates.Day(3))` # returns a bool of whether the cache is more than 3 days old 
`expired(query, Dates.Minute(30))` # returns a bool of whether the cache is more than 30 minutes old 
`expired(query, Dates.DateTime(2021, 1, 1, 1, 2, 3))` # returns a bool compared to the given time

"""
expired(q::QueryCache, expires::DateTime) = expires <= now() || stat(q.cachepath).device == 0
expired(q::QueryCache, ttl::Period) = expired(q, unix2datetime(mtime(q.cachepath)) + ttl)

	
"""	
    df_cached(q::QueryCache, ttl_e::Union{Dates.Period, Dates.DateTime}; noisy::Bool=false)
	
	
# Arguments
- `q` a QueryCache
- `ttl_e` is either a DataTime or Period specifying how long the cache should be live.

If the cached version of the DataFrame is still live, return it from disk.

If it has expired, call the Query's sql_function with the sql, write the DataFrame to disk 
in the specified formats and return the DataFrame.

The noisy flag indicates whether to print to stderr where the data is coming from.

# Examples

Always retreive the SQL from the server

`df = df_cached(query, now())` 

Get the cached version, if it exists, or is less than 7 days old

Print "From Server" or "From Cache" on stderr, depending where it came from, with the filename / sql snippet

`df = df_cached(query, Dates.Day(7), noisy=true)` 

"""
function df_cached(q::QueryCache, ttl_e; noisy=false)
	if expired(q, ttl_e)
		if noisy
			println(stderr, "From Server - ", q.sql[1:(length(q.sql) < 20 ? end : 20)])
		end
		df = q.select(q.sql)
		df_write(q.cachepath, df, subformat=q.subformat, dictencode=q.dictencode)
		return df
	else
		if noisy
			println(stderr, "From Cache - ", splitpath(q.cachepath)[end])
		end
		df_read(q.cachepath)
	end
end

"""
    select_fn(connection, args...; kw...)

Return a function which will `execute` the Query's sql on the supplied connection

# Arguments
- `connection` the appropriate Connection data structure from some other module
- `args` splatted arguments to use in DBInterface.connect
- `kw` splatted kwarguments to use in DBInterface.connect

# Examples

`sql_fn = select_fn(MySQL.Connection, SERVER, USER, PASSWORD)`

"""
select_fn(connection, args...; kw...) = sql->DBInterface.execute(DBInterface.connect(connection, args...; kw...), sql) |> DataFrame 

"""
	fetch_and_combine(queries; ttl:Union{Dates.Period, Dates.DateTime}, noisy::Bool)
	
Given an iterable collection of queries, fetch them and combine them into a single DataFrame

# Arguments

- `queries` iterable collection of QueryCache
- `ttl` Time To Live, a Period or DateTime (default 7 days)
- `noisy` if so, report on stderr where the data is coming from (default false)

# Example

If we have a long_view that times out on a single connection then split it into 3 and re-combine them.
This is my actual use case for this Module. I'm querying from MySQL on AWS and only get 300 seconds. 
If the network is busy, my queries risk being terminated, so I break them into chunks.

```
df = fetch_and_combine([
	QueryCache("SELECT long_view WHERE created BETWEEN '2019-01-01' AND '2019-12-13'", sql_fn, ".", :arrow),
	QueryCache("SELECT long_view WHERE created BETWEEN '2020-01-01' AND '2020-12-13'", sql_fn, ".", :arrow),
	QueryCache("SELECT long_view WHERE created BETWEEN '2021-01-01' AND '2021-12-13'", sql_fn, ".", :arrow),
	])
```

"""
fetch_and_combine(queries; ttl=Day(7), noisy=false) = reduce((adf, query)->append!(adf, df_cached(query, ttl, noisy=noisy)), queries, init=DataFrame())

"""
	Dfetch_and_combine(queries; ttl:Union{Dates.Period, Dates.DateTime}, noisy::Bool)
	
The same as fetch\\_and\\_combine but use a different process for each Query, spawning at :any.
"""
Dfetch_and_combine(queries; ttl=Day(7), noisy=false) = reduce((adf, query)->append!(adf, fetch(future)), [@spawnat :any df_cached(query, ttl, noisy=noisy) for query in queries], init=DataFrame())

###
end

