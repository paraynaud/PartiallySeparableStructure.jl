# Benchmark Report for *PartiallySeparableStructure*

## Job Properties
* Time of benchmarks:
    - Target: 11 May 2020 - 16:20
    - Baseline: 11 May 2020 - 16:19
* Package commits:
    - Target: 61f590
    - Baseline: 320eb5
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

| ID                                        | time ratio    | memory ratio |
|-------------------------------------------|---------------|--------------|
| `["SPS_function", "Hessien ros 100 var"]` | 1.15 (5%) :x: |   1.00 (1%)  |
| `["SPS_function", "Hessien ros 500 var"]` | 1.14 (5%) :x: |   1.00 (1%)  |
| `["SPS_function", "grad ros 500 var"]`    | 1.11 (5%) :x: |   1.00 (1%)  |

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
       #1  1498 MHz    1296578            0       456734      3746578       102968  ticks
       #2  1498 MHz    2321625            0       257703      2920343        33796  ticks
       #3  1498 MHz    1960593            0       293234      3245843         7890  ticks
       #4  1498 MHz    1161593            0       164500      4173578         3078  ticks
       #5  1498 MHz    1523125            0       333359      3643187        14953  ticks
       #6  1498 MHz    1133296            0       298890      4067484         4625  ticks
       #7  1498 MHz    1720625            0       318953      3460093        10343  ticks
       #8  1498 MHz    1215656            0       229015      4055000         7078  ticks
       
  Memory: 31.775043487548828 GB (19292.8046875 MB free)
  Uptime: 5499.0 sec
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
       #1  1498 MHz    1285859            0       452312      3670125       102281  ticks
       #2  1498 MHz    2313468            0       256203      2838406        33781  ticks
       #3  1498 MHz    1944984            0       289718      3173375         7843  ticks
       #4  1498 MHz    1148500            0       162921      4096656         3046  ticks
       #5  1498 MHz    1508890            0       330453      3568734        14875  ticks
       #6  1498 MHz    1116406            0       293515      3998156         4562  ticks
       #7  1498 MHz    1705109            0       316125      3386843        10312  ticks
       #8  1498 MHz    1192687            0       226468      3988921         7046  ticks
       
  Memory: 31.775043487548828 GB (19331.3984375 MB free)
  Uptime: 5408.0 sec
  Load Avg:  0.0  0.0  0.0
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-6.0.1 (ORCJIT, cannonlake)
```