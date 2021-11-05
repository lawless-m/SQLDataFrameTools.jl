using SQLDataFrameTools
using Test



@testset "SQLDataFrameTools.jl" begin
   @test SQLDataFrameTools.expired("", SQLDataFrameTools.Dates.now())
   @test SQLDataFrameTools.expired("", SQLDataFrameTools.Dates.Day(1))
   @test SQLDataFrameTools.cachepath("a", "hash", :jdf) == "a\\hash.jdf"
   @test isa(SQLDataFrameTools.QueryCache("SELECT 1", ()->true, ".", :jdf), SQLDataFrameTools.QueryCache)
   @test isa(SQLDataFrameTools.QueryCache("SELECT 1", ()->true, ".", :jdf, dictencode=false), SQLDataFrameTools.QueryCache)
   @test isa(SQLDataFrameTools.QueryCache("SELECT 1", ()->true, ".", :jdf, subformat=:zip), SQLDataFrameTools.QueryCache)
   @test isa(SQLDataFrameTools.QueryCache("SELECT 1", ()->true, ".", :jdf, dictencode=false, subformat=:zip), SQLDataFrameTools.QueryCache)
end
