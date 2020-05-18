# Benchmark Report for *PartiallySeparableStructure*

## Job Properties
* Time of benchmarks:
    - Target: 18 May 2020 - 14:32
    - Baseline: 18 May 2020 - 14:31
* Package commits:
    - Target: 5f0d24
    - Baseline: 334a42
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

| ID                        | time ratio                   | memory ratio |
|---------------------------|------------------------------|--------------|
| `["Trunk", "ros 10 var"]` |                1.29 (5%) :x: |   1.00 (1%)  |
| `["Trunk", "ros 20 var"]` |                1.10 (5%) :x: |   1.00 (1%)  |
| `["Trunk", "ros 30 var"]` | 0.68 (5%) :white_check_mark: |   1.00 (1%)  |

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
       #1  1498 MHz     799609            0       585781     15989156       217484  ticks
       #2  1498 MHz     401125            0       203203     16770015         8718  ticks
       #3  1498 MHz    1318578            0       481234     15574531         7031  ticks
       #4  1498 MHz     549656            0       212703     16611984         3609  ticks
       #5  1498 MHz    1043484            0       404312     15926546         6609  ticks
       #6  1498 MHz     579718            0       239562     16555062         2890  ticks
       #7  1498 MHz     887687            0       291421     16195234         4843  ticks
       #8  1498 MHz     606609            0       313531     16454187         2937  ticks
       
  Memory: 31.775043487548828 GB (17872.09765625 MB free)
  Uptime: 20388.0 sec
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
       #1  1498 MHz     793156            0       582859     15931703       217015  ticks
       #2  1498 MHz     396609            0       201609     16709296         8593  ticks
       #3  1498 MHz    1305328            0       478828     15523359         7000  ticks
       #4  1498 MHz     542468            0       211015     16554031         3546  ticks
       #5  1498 MHz    1032250            0       401250     15874015         6468  ticks
       #6  1498 MHz     568312            0       237984     16501218         2859  ticks
       #7  1498 MHz     871734            0       289703     16146078         4718  ticks
       #8  1498 MHz     590859            0       311671     16404968         2937  ticks
       
  Memory: 31.775043487548828 GB (17864.28515625 MB free)
  Uptime: 20321.0 sec
  Load Avg:  0.0  0.0  0.0
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-6.0.1 (ORCJIT, cannonlake)
```