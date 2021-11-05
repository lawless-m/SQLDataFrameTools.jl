using SQLDataFrameTools
using Test

@testset "SQLDataFrameTools.jl" begin
   @test SQLDataFrameTools.expired(SQLDataFrameTools.QueryCache("SELECT 1", ()->true, ".", :jdf), SQLDataFrameTools.Dates.now())
   @test SQLDataFrameTools.expired(SQLDataFrameTools.QueryCache("SELECT 2", ()->true, ".", :jdf), SQLDataFrameTools.Dates.Day(1))
   @test endswith(SQLDataFrameTools.cachepath("a", "hash", :jdf), "hash.jdf")
   @test isa(SQLDataFrameTools.QueryCache("SELECT 3", ()->true, ".", :jdf), SQLDataFrameTools.QueryCache)
   @test isa(SQLDataFrameTools.QueryCache("SELECT 4", ()->true, ".", :jdf, dictencode=false), SQLDataFrameTools.QueryCache)
   @test isa(SQLDataFrameTools.QueryCache("SELECT 5", ()->true, ".", :jdf, subformat=:zip), SQLDataFrameTools.QueryCache)
   @test isa(SQLDataFrameTools.QueryCache("SELECT 6", ()->true, ".", :jdf, dictencode=false, subformat=:zip), SQLDataFrameTools.QueryCache)
end
