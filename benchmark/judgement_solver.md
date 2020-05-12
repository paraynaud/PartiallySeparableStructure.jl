# Benchmark Report for *PartiallySeparableStructure*

## Job Properties
* Time of benchmarks:
    - Target: 12 May 2020 - 16:41
    - Baseline: 12 May 2020 - 16:39
* Package commits:
    - Target: 5f0d24
    - Baseline: 5f0d24
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
| `["Trunk", "ros 20 var"]` | 0.84 (5%) :white_check_mark: |   1.00 (1%)  |

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
       #1  1498 MHz    1853171            0      1440359     20525718       765296  ticks
       #2  1498 MHz    1349078            0       523203     21946750        49078  ticks
       #3  1498 MHz    2169750            0       610328     21038953        19390  ticks
       #4  1498 MHz    1146375            0       458765     22213890        14890  ticks
       #5  1498 MHz    1541109            0       570046     21707875        22968  ticks
       #6  1498 MHz    1007875            0       388312     22422828         9656  ticks
       #7  1498 MHz    2323765            0       469546     21025703        17671  ticks
       #8  1498 MHz    1289421            0       420718     22108875         6937  ticks
       
  Memory: 31.775043487548828 GB (17720.24609375 MB free)
  Uptime: 23819.0 sec
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
       #1  1498 MHz    1840000            0      1435000     20458140       764546  ticks
       #2  1498 MHz    1334156            0       520656     21878109        48921  ticks
       #3  1498 MHz    2149312            0       605906     20977703        19281  ticks
       #4  1498 MHz    1127328            0       454312     22151281        14812  ticks
       #5  1498 MHz    1525515            0       565031     21642375        22890  ticks
       #6  1498 MHz     994328            0       385125     22353468         9609  ticks
       #7  1498 MHz    2307671            0       465281     20959953        17531  ticks
       #8  1498 MHz    1272296            0       416437     22044171         6859  ticks
       
  Memory: 31.775043487548828 GB (17846.62109375 MB free)
  Uptime: 23732.0 sec
  Load Avg:  0.0  0.0  0.0
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-6.0.1 (ORCJIT, cannonlake)
```