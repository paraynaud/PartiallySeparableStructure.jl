# using GitHub, JSON,
using PkgBenchmark

using PartiallySeparableStructure

pkg = "PartiallySeparableStructure"
pkg = "Krylov"
pkgid = Base.identify_package(pkg)
pkgfile_from_pkgname = pkgid === nothing ? nothing : Base.locate_package(pkgid)

if pkgfile_from_pkgname===nothing
    if isdir(pkg)
        pkgdir = pkg
    else
        error("No package '$pkg' found.")
    end
else
    pkgdir = normpath(joinpath(dirname(pkgfile_from_pkgname), ".."))
end
@show pkgid, pkgfile_from_pkgname, pkgdir

dvpt = BenchmarkConfig("dvpt")

commit = benchmarkpkg("PartiallySeparableStructure", dvpt)  # current state of repository , script="../benchmark/benchmark.jl"
# pathof(PartiallySeparableStructure) , script="/benchmark/benchmarks.jl"
master = benchmarkpkg("PartiallySeparableStructure", "master")

judgement = judge(commit, master)

export_markdown("judgement.md", judgement)
export_markdown("master.md", master)
export_markdown("commit.md", commit)
