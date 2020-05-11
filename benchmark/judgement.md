# Benchmark Report for *PartiallySeparableStructure*

## Job Properties
* Time of benchmarks:
    - Target: 8 May 2020 - 13:43
    - Baseline: 8 May 2020 - 13:44
* Package commits:
    - Target: fed94a
    - Baseline: 61f590
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
| `["SPS_function", "OBJ ros 100 var"]`     | 0.00 (5%) :white_check_mark: |   1.00 (1%)  |
| `["SPS_function", "OBJ ros 200 var"]`     | 0.00 (5%) :white_check_mark: |   1.00 (1%)  |
| `["SPS_function", "OBJ ros 500 var"]`     | 0.00 (5%) :white_check_mark: |   1.00 (1%)  |

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
       #1  1498 MHz     351000            0       316437      8677218       101000  ticks
       #2  1498 MHz     199687            0        92812      9051937         2343  ticks
       #3  1498 MHz     574453            0       184437      8585546         2828  ticks
       #4  1498 MHz     311625            0       102890      8929921         2359  ticks
       #5  1498 MHz     403500            0       157500      8783437         5750  ticks
       #6  1498 MHz     296578            0       116046      8931812        10468  ticks
       #7  1498 MHz     420421            0       140703      8783312         3328  ticks
       #8  1498 MHz     438015            0       213125      8693296         2671  ticks
       
  Memory: 31.775043487548828 GB (18158.27734375 MB free)
  Uptime: 9344.0 sec
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
       #1  1498 MHz     354718            0       318500      8743718       101140  ticks
       #2  1498 MHz     204687            0        93500      9118531         2406  ticks
       #3  1498 MHz     584937            0       185734      8646046         2828  ticks
       #4  1498 MHz     319390            0       103984      8993343         2375  ticks
       #5  1498 MHz     410250            0       158625      8847843         5765  ticks
       #6  1498 MHz     305656            0       116984      8994078        10500  ticks
       #7  1498 MHz     431593            0       141859      8843265         3328  ticks
       #8  1498 MHz     449000            0       215000      8752718         2671  ticks
       
  Memory: 31.775043487548828 GB (18127.13671875 MB free)
  Uptime: 9416.0 sec
  Load Avg:  0.0  0.0  0.0
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-6.0.1 (ORCJIT, cannonlake)
```