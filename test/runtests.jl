using SQLDataFrameTools
using Test
using DataFrames
using Dates

df = DataFrame([[1, 2, 3, 4, 5, 6]], ["a"])

sql_fn_stub(args...;kwargs...) =  df

@testset "SQLDataFrameTools.jl" begin
   @test SQLDataFrameTools.expired(SQLDataFrameTools.QueryCache("SELECT 1", ()->true, ".", :jdf), SQLDataFrameTools.Dates.now())
   @test SQLDataFrameTools.expired(SQLDataFrameTools.QueryCache("SELECT 2", ()->true, ".", :jdf), SQLDataFrameTools.Dates.Day(1))
   @test endswith(SQLDataFrameTools.cachepath("a", "hash", :jdf), "hash.jdf")
   @test isa(SQLDataFrameTools.QueryCache("SELECT 3", ()->true, ".", :jdf), SQLDataFrameTools.QueryCache)
   @test isa(SQLDataFrameTools.QueryCache("SELECT 4", ()->true, ".", :jdf, dictencode=false), SQLDataFrameTools.QueryCache)
   @test isa(SQLDataFrameTools.QueryCache("SELECT 5", ()->true, ".", :jdf, subformat=:zip), SQLDataFrameTools.QueryCache)
   @test isa(SQLDataFrameTools.QueryCache("SELECT 6", ()->true, ".", :jdf, dictencode=false, subformat=:zip), SQLDataFrameTools.QueryCache)
   @test SQLDataFrameTools.df_cached(SQLDataFrameTools.QueryCache("UNUSED", sql_fn_stub, ".", :arrow), now()) == df
   @test SQLDataFrameTools.df_cached(SQLDataFrameTools.QueryCache("UNUSED", sql_fn_stub, ".", :arrow), now(), noisy=true) == df
   @test SQLDataFrameTools.df_cached(SQLDataFrameTools.QueryCache("UNUSED", sql_fn_stub, ".", :arrow), Day(30)) == df
   @test SQLDataFrameTools.df_cached(SQLDataFrameTools.QueryCache("UNUSED", sql_fn_stub, ".", :arrow), Day(30)) == df
end
