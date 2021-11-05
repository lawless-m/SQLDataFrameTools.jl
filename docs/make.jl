using Documenter
using SQLDataFrameTools
using Dates

using Documenter, SQLDataFrameTools

makedocs(
    modules = [SQLDataFrameTools],
    sitename="SQLDataFrameTools.jl", 
    authors = "Matt Lawless",
    format = Documenter.HTML(),
)

deploydocs(
    repo = "github.com/lawless-m/SQLDataFrameTools.jl.git", 
    devbranch = "main",
    push_preview = true,
)
