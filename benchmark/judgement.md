# Benchmark Report for *PartiallySeparableStructure*

## Job Properties
* Time of benchmarks:
    - Target: 11 May 2020 - 21:50
    - Baseline: 11 May 2020 - 21:49
* Package commits:
    - Target: 61f590
    - Baseline: 4cc812
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

| ID | time ratio | memory ratio |
|----|------------|--------------|

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:


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
       #1  1498 MHz    2023750            0      1235781     19102421       462703  ticks
       #2  1498 MHz    2910734            0       469156     18981828        43671  ticks
       #3  1498 MHz    3277031            0       681296     18403406        14437  ticks
       #4  1498 MHz    1947671            0       407671     20006375         7031  ticks
       #5  1498 MHz    2405234            0       657343     19299156        22062  ticks
       #6  1498 MHz    1964578            0       680000     19717140         9281  ticks
       #7  1498 MHz    2703890            0       624515     19033328        17156  ticks
       #8  1498 MHz    2256078            0       512859     19592796        13015  ticks
       
  Memory: 31.775043487548828 GB (17095.50390625 MB free)
  Uptime: 25278.0 sec
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
       #1  1498 MHz    2013828            0      1232234     19036312       462125  ticks
       #2  1498 MHz    2902859            0       467890     18911406        43640  ticks
       #3  1498 MHz    3263718            0       678921     18339515        14390  ticks
       #4  1498 MHz    1931078            0       403765     19947312         6984  ticks
       #5  1498 MHz    2392953            0       654359     19234843        22015  ticks
       #6  1498 MHz    1954390            0       678468     19649296         9250  ticks
       #7  1498 MHz    2691203            0       622578     18968375        17093  ticks
       #8  1498 MHz    2238218            0       510937     19533000        13000  ticks
       
  Memory: 31.775043487548828 GB (17091.1875 MB free)
  Uptime: 25198.0 sec
  Load Avg:  0.0  0.0  0.0
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-6.0.1 (ORCJIT, cannonlake)
```