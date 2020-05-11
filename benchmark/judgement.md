# Benchmark Report for *PartiallySeparableStructure*

## Job Properties
* Time of benchmarks:
    - Target: 11 May 2020 - 22:28
    - Baseline: 11 May 2020 - 22:27
* Package commits:
    - Target: 61f590
    - Baseline: 9aec19
* Julia commits:
    - Target: 2d5741
    - Baseline: 2d5741
* Julia command flags:
    - Target: None
    - Baseline: None
* Environment variables:
    - Target: None
    - Baseline: None

## Results
A ratio greater than `1.0` denotes a possible regression (marked with :x:), while a ratio less
than `1.0` denotes a possible improvement (marked with :white_check_mark:). Only significant results - results
that indicate possible regressions or improvements - are shown below (thus, an empty table means that all
benchmark results remained invariant between builds).

| ID                                        | time ratio                   | memory ratio |
|-------------------------------------------|------------------------------|--------------|
| `["SPS_function", "Hessien ros 100 var"]` |                1.12 (5%) :x: |   1.00 (1%)  |
| `["SPS_function", "Hessien ros 200 var"]` |                1.12 (5%) :x: |   1.00 (1%)  |
| `["SPS_function", "Hessien ros 500 var"]` |                1.10 (5%) :x: |   1.00 (1%)  |
| `["SPS_function", "OBJ ros 100 var"]`     |             1510.24 (5%) :x: |   1.00 (1%)  |
| `["SPS_function", "OBJ ros 200 var"]`     |              417.24 (5%) :x: |   1.00 (1%)  |
| `["SPS_function", "OBJ ros 500 var"]`     |              248.52 (5%) :x: |   1.00 (1%)  |
| `["SPS_function", "grad ros 100 var"]`    | 0.79 (5%) :white_check_mark: |   1.00 (1%)  |
| `["SPS_function", "grad ros 200 var"]`    | 0.60 (5%) :white_check_mark: |   1.00 (1%)  |
| `["SPS_function", "grad ros 500 var"]`    |                1.20 (5%) :x: |   1.00 (1%)  |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["SPS_function"]`

## Julia versioninfo

### Target
```
Julia Version 1.3.1
Commit 2d5741174c (2019-12-30 21:36 UTC)
Platform Info:
  OS: Windows (x86_64-w64-mingw32)
      Microsoft Windows [version 10.0.18362.476]
  CPU: Intel(R) Core(TM) i7-1065G7 CPU @ 1.30GHz: 
              speed         user         nice          sys         idle          irq
       #1  1498 MHz    2135375            0      1345343     21181968       507640  ticks
       #2  1498 MHz    3001312            0       497828     21163312        44953  ticks
       #3  1498 MHz    3448468            0       730406     20483593        15812  ticks
       #4  1498 MHz    2064296            0       456484     22141671         7875  ticks
       #5  1498 MHz    2531921            0       707234     21423296        23640  ticks
       #6  1498 MHz    2061750            0       721718     21879000        10171  ticks
       #7  1498 MHz    2830953            0       665187     21166328        18906  ticks
       #8  1498 MHz    2379093            0       551875     21731484        14281  ticks
       
  Memory: 31.775043487548828 GB (15314.46484375 MB free)
  Uptime: 27579.0 sec
  Load Avg:  0.0  0.0  0.0
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-6.0.1 (ORCJIT, cannonlake)
```

### Baseline
```
Julia Version 1.3.1
Commit 2d5741174c (2019-12-30 21:36 UTC)
Platform Info:
  OS: Windows (x86_64-w64-mingw32)
      Microsoft Windows [version 10.0.18362.476]
  CPU: Intel(R) Core(TM) i7-1065G7 CPU @ 1.30GHz: 
              speed         user         nice          sys         idle          irq
       #1  1498 MHz    2109609            0      1336968     21113093       506968  ticks
       #2  1498 MHz    2976640            0       493546     21089265        44796  ticks
       #3  1498 MHz    3413093            0       724125     20422234        15734  ticks
       #4  1498 MHz    2030453            0       451593     22077406         7796  ticks
       #5  1498 MHz    2499937            0       700406     21359109        23500  ticks
       #6  1498 MHz    2032453            0       716406     21810593        10156  ticks
       #7  1498 MHz    2795125            0       659953     21104375        18781  ticks
       #8  1498 MHz    2340328            0       546875     21672250        14187  ticks
       
  Memory: 31.775043487548828 GB (17001.4140625 MB free)
  Uptime: 27476.0 sec
  Load Avg:  0.0  0.0  0.0
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-6.0.1 (ORCJIT, cannonlake)
```