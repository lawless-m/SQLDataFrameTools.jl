module SQLDataFrameTools

using DataFrameTools
using SHA
using DBInterface
using Dates
using DataFrames

export QueryCache, df_cached, select_fn

struct QueryCache
	sql
	select
	cachepath
	subformat::Union{Nothing,Symbol}
	dictencode::Bool
	QueryCache(sql, select, dir, format;  subformat=nothing, dictencode=true) = new(sql, select, cachepath(dir, bytes2hex(sha256(sql)), format), subformat, dictencode)
end

cachepath(dir, hash, sformat) = joinpath(dir, hash * '.' * string(sformat))

expired(path, expires::DateTime) = expires <= now() || stat(path).device == 0
expired(path, ttl::Period) = expired(path, unix2datetime(mtime(path)) + ttl)
	
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

select_fn(conn, server, user, password) = sql->DBInterface.execute(DBInterface.connect(conn, server, user, password), sql) |> DataFrame 
# e.g.
# sql_fn = select_fn(MySQL.Connection, SERVER, USER, PASSWORD)

###
end

