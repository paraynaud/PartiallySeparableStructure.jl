# Benchmark Report for *PartiallySeparableStructure*

## Job Properties
* Time of benchmarks:
    - Target: 18 May 2020 - 14:21
    - Baseline: 18 May 2020 - 14:18
* Package commits:
    - Target: 5f0d24
    - Baseline: becf2e
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

| ID                        | time ratio                   | memory ratio                 |
|---------------------------|------------------------------|------------------------------|
| `["Trunk", "ros 10 var"]` | 0.01 (5%) :white_check_mark: | 0.00 (1%) :white_check_mark: |
| `["Trunk", "ros 20 var"]` |                3.90 (5%) :x: |                   1.00 (1%)  |
| `["Trunk", "ros 30 var"]` | 0.81 (5%) :white_check_mark: |                   1.00 (1%)  |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["Trunk"]`

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
       #1  1498 MHz     740328            0       540484     15378109       199437  ticks
       #2  1498 MHz     352468            0       185859     16120390         8046  ticks
       #3  1498 MHz    1218515            0       455796     14984406         6406  ticks
       #4  1498 MHz     484265            0       190343     15984109         2656  ticks
       #5  1498 MHz     955375            0       372218     15331125         5593  ticks
       #6  1498 MHz     515421            0       221328     15921968         2406  ticks
       #7  1498 MHz     795437            0       271859     15591421         4062  ticks
       #8  1498 MHz     523781            0       292187     15842734         2734  ticks
       
  Memory: 31.775043487548828 GB (17028.98046875 MB free)
  Uptime: 19673.0 sec
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
       #1  1498 MHz     720703            0       533140     15277078       198218  ticks
       #2  1498 MHz     334015            0       180875     16015828         7890  ticks
       #3  1498 MHz    1185296            0       449500     14895921         6281  ticks
       #4  1498 MHz     459234            0       185937     15885546         2562  ticks
       #5  1498 MHz     924078            0       365906     15240734         5421  ticks
       #6  1498 MHz     489890            0       216265     15824562         2281  ticks
       #7  1498 MHz     760484            0       266218     15504015         3953  ticks
       #8  1498 MHz     484531            0       285234     15760937         2687  ticks
       
  Memory: 31.775043487548828 GB (18375.55078125 MB free)
  Uptime: 19545.0 sec
  Load Avg:  0.0  0.0  0.0
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-6.0.1 (ORCJIT, cannonlake)
```