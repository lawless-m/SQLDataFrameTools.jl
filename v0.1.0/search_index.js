var documenterSearchIndex = {"docs":
[{"location":"#SQLDataFrameTools.jl","page":"SQLDataFrameTools.jl","title":"SQLDataFrameTools.jl","text":"","category":"section"},{"location":"","page":"SQLDataFrameTools.jl","title":"SQLDataFrameTools.jl","text":"Documentation for SQLDataFrameTools.jl","category":"page"},{"location":"","page":"SQLDataFrameTools.jl","title":"SQLDataFrameTools.jl","text":"QueryCache","category":"page"},{"location":"#SQLDataFrameTools.QueryCache","page":"SQLDataFrameTools.jl","title":"SQLDataFrameTools.QueryCache","text":"QueryCache(sql, select, dir, format;  subformat=nothing, dictencode=true)\n\nis the Data Structure used in this module.\n\nArguments\n\nsql is the SQL Query\nselect is the function used to retrieve the dataset (which can be created with select_fn)\ndir is the directory in which to store the cache file\nformat is one of the file formats supported. See DataFrameTools.df_formats() for the list.\nsubformat and dictencode are optional parameters for DataFrameTools.df_write\n\nExamples\n\nquery = QueryCache(\"SELECT 1\",  select_fn(MySQL.Connection, SERVER, USER, PASSWORD), \".\", :jdf)\n\n\n\n\n\n","category":"type"},{"location":"","page":"SQLDataFrameTools.jl","title":"SQLDataFrameTools.jl","text":"df_cached","category":"page"},{"location":"#SQLDataFrameTools.df_cached","page":"SQLDataFrameTools.jl","title":"SQLDataFrameTools.df_cached","text":"df_cached(q::QueryCache, ttl_e::Union{Dates.Period, Dates.DateTime}; noisy::Bool=false)\n\nArguments\n\nq a QueryCache\nttl_e is either a DataTime or Period specifying how long the cache should be live.\n\nIf the cached version of the DataFrame is still live, return it from disk.\n\nIf it has expired, call the Query's sql_function with the sql, write the DataFrame to disk  in the specified formats and return the DataFrame.\n\nThe noisy flag indicates whether to print to stderr where the data is coming from.\n\nExamples\n\nAlways retreive the SQL from the server\n\ndf = df_cached(query, now())\n\nGet the cached version, if it exists, or is less than 7 days old\n\nPrint \"From Server\" or \"From Cache\" on stderr, depending where it came from, with the filename / sql snippet\n\ndf = df_cached(query, Dates.Day(7), noisy=true)\n\n\n\n\n\n","category":"function"},{"location":"","page":"SQLDataFrameTools.jl","title":"SQLDataFrameTools.jl","text":"expired","category":"page"},{"location":"#SQLDataFrameTools.expired","page":"SQLDataFrameTools.jl","title":"SQLDataFrameTools.expired","text":"expired(q::QueryCache, expires::Dates.DateTime)\nexpired(q::QueryCache, ttl::Dates.Period)\n\nHas the cache file expired?\n\nIf the file doesn't exist always return true, otherwise check the mtime against the given time.\n\nArguments\n\nq a QueryCache struct\nexpires a DateTime to check against the current time.\nttl a time period to compare the current time to the mtime of the cache + ttl \n\nExamples\n\nexpired(query, Dates.Day(3)) # returns a bool of whether the cache is more than 3 days old \nexpired(query, Dates.Minute(30)) # returns a bool of whether the cache is more than 30 minutes old \nexpired(query, Dates.DateTime(2021, 1, 1, 1, 2, 3)) # returns a bool compared to the given time\n\n\n\n\n\n","category":"function"},{"location":"","page":"SQLDataFrameTools.jl","title":"SQLDataFrameTools.jl","text":"select_fn","category":"page"},{"location":"#SQLDataFrameTools.select_fn","page":"SQLDataFrameTools.jl","title":"SQLDataFrameTools.select_fn","text":"select_fn(connection, args...; kw...)\n\nReturn a function which will execute the Query's sql on the supplied connection\n\nArguments\n\nconnection the appropriate Connection data structure from some other module\nargs splatted arguments to use in DBInterface.connect\nkw splatted kwarguments to use in DBInterface.connect\n\nExamples\n\nsql_fn = select_fn(MySQL.Connection, SERVER, USER, PASSWORD)\n\n\n\n\n\n","category":"function"},{"location":"","page":"SQLDataFrameTools.jl","title":"SQLDataFrameTools.jl","text":"fetch_and_combine","category":"page"},{"location":"#SQLDataFrameTools.fetch_and_combine","page":"SQLDataFrameTools.jl","title":"SQLDataFrameTools.fetch_and_combine","text":"fetch_and_combine(queries; ttl:Union{Dates.Period, Dates.DateTime}, noisy::Bool)\n\nGiven an iterable collection of queries, fetch them and combine them into a single DataFrame using as many threads as available.\n\nArguments\n\nqueries iterable collection of QueryCache\nttl Time To Live, a Period or DateTime (default 7 days)\nnoisy if so, report on stderr where the data is coming from (default false)\n\nExample\n\nIf we have a long_view that times out on a single connection then split it into 3 and re-combine them.\n\nThis is my actual use case for this Module. I'm querying from MySQL on AWS and only get 300 seconds. \n\nIf the network is busy, my queries risk being terminated, so I break them into chunks.\n\ndf = fetch_and_combine([\n\tQueryCache(\"SELECT long_view WHERE created BETWEEN '2019-01-01' AND '2019-12-13'\", sql_fn, \".\", :arrow),\n\tQueryCache(\"SELECT long_view WHERE created BETWEEN '2020-01-01' AND '2020-12-13'\", sql_fn, \".\", :arrow),\n\tQueryCache(\"SELECT long_view WHERE created BETWEEN '2021-01-01' AND '2021-12-13'\", sql_fn, \".\", :arrow),\n\t])\n\n\n\n\n\n","category":"function"},{"location":"","page":"SQLDataFrameTools.jl","title":"SQLDataFrameTools.jl","text":"Dfetch_and_combine","category":"page"},{"location":"#SQLDataFrameTools.Dfetch_and_combine","page":"SQLDataFrameTools.jl","title":"SQLDataFrameTools.Dfetch_and_combine","text":"Dfetch_and_combine(queries; ttl:Union{Dates.Period, Dates.DateTime}, noisy::Bool)\n\nThe same as [fetch_and_combine][@ref] but use a different process for each Query, spawning at :any.\n\n\n\n\n\n","category":"function"}]
}
