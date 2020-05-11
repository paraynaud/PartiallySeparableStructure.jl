# Benchmark Report for *PartiallySeparableStructure*

## Job Properties
* Time of benchmarks:
    - Target: 11 May 2020 - 16:39
    - Baseline: 11 May 2020 - 16:38
* Package commits:
    - Target: 61f590
    - Baseline: 170d7f
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
| `["SPS_function", "grad ros 100 var"]`    | 0.94 (5%) :white_check_mark: |   1.00 (1%)  |

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
       #1  1498 MHz    1405031            0       550781      4685218       127734  ticks
       #2  1498 MHz    2446156            0       299109      3895546        34953  ticks
       #3  1498 MHz    2134187            0       366421      4140203         8687  ticks
       #4  1498 MHz    1270312            0       205187      5165312         3593  ticks
       #5  1498 MHz    1650406            0       388093      4602312        15515  ticks
       #6  1498 MHz    1280578            0       388593      4971640         5265  ticks
       #7  1498 MHz    1872781            0       378781      4389250        10875  ticks
       #8  1498 MHz    1394500            0       273921      4972390         7578  ticks
       
  Memory: 31.775043487548828 GB (19703.91015625 MB free)
  Uptime: 6640.0 sec
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
       #1  1498 MHz    1399875            0       547875      4612250       126875  ticks
       #2  1498 MHz    2441093            0       298343      3820343        34937  ticks
       #3  1498 MHz    2121656            0       364234      4073890         8656  ticks
       #4  1498 MHz    1259812            0       203906      5096062         3593  ticks
       #5  1498 MHz    1641890            0       386625      4531265        15515  ticks
       #6  1498 MHz    1269218            0       385828      4904718         5250  ticks
       #7  1498 MHz    1860125            0       377265      4322390        10843  ticks
       #8  1498 MHz    1371890            0       272328      4915546         7546  ticks
       
  Memory: 31.775043487548828 GB (19307.73046875 MB free)
  Uptime: 6559.0 sec
  Load Avg:  0.0  0.0  0.0
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-6.0.1 (ORCJIT, cannonlake)
```