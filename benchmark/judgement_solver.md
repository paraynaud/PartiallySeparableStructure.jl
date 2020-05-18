# Benchmark Report for *PartiallySeparableStructure*

## Job Properties
* Time of benchmarks:
    - Target: 18 May 2020 - 14:58
    - Baseline: 18 May 2020 - 14:56
* Package commits:
    - Target: 5f0d24
    - Baseline: 567bd3
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

| ID                        | time ratio      | memory ratio     |
|---------------------------|-----------------|------------------|
| `["Trunk", "ros 10 var"]` | 140.27 (5%) :x: | 1007.31 (1%) :x: |
| `["Trunk", "ros 20 var"]` |   1.30 (5%) :x: |       1.00 (1%)  |
| `["Trunk", "ros 30 var"]` |   1.78 (5%) :x: |       1.00 (1%)  |

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
       #1  1498 MHz     955843            0       682984     17285468       252812  ticks
       #2  1498 MHz     525031            0       241453     18157609        10093  ticks
       #3  1498 MHz    1545078            0       538343     16840671         8406  ticks
       #4  1498 MHz     719000            0       261875     17943218         4812  ticks
       #5  1498 MHz    1263265            0       462812     17198031         8109  ticks
       #6  1498 MHz     771671            0       280453     17871984         3687  ticks
       #7  1498 MHz    1152828            0       336343     17434921         6000  ticks
       #8  1498 MHz     881171            0       366234     17676671         3312  ticks
       
  Memory: 31.775043487548828 GB (17041.1640625 MB free)
  Uptime: 21938.0 sec
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
       #1  1498 MHz     938312            0       675921     17187656       251796  ticks
       #2  1498 MHz     515609            0       239125     18046953        10031  ticks
       #3  1498 MHz    1522859            0       532609     16746218         8281  ticks
       #4  1498 MHz     704343            0       259453     17837890         4734  ticks
       #5  1498 MHz    1240921            0       458203     17102562         7984  ticks
       #6  1498 MHz     748578            0       277671     17775437         3656  ticks
       #7  1498 MHz    1125093            0       332734     17343859         5859  ticks
       #8  1498 MHz     842359            0       358812     17600500         3265  ticks
       
  Memory: 31.775043487548828 GB (17497.015625 MB free)
  Uptime: 21816.0 sec
  Load Avg:  0.0  0.0  0.0
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-6.0.1 (ORCJIT, cannonlake)
```