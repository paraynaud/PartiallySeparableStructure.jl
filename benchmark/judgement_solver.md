# Benchmark Report for *PartiallySeparableStructure*

## Job Properties
* Time of benchmarks:
    - Target: 18 May 2020 - 15:59
    - Baseline: 18 May 2020 - 15:58
* Package commits:
    - Target: e6c794
    - Baseline: e6c794
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

| ID                         | time ratio | memory ratio |
|----------------------------|------------|--------------|

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["P-BFGS"]`

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
       #1  1498 MHz    1128656            0       897468     20566171       377718  ticks
       #2  1498 MHz     697218            0       316343     21578531        12906  ticks
       #3  1498 MHz    1815203            0       630796     20146093        10937  ticks
       #4  1498 MHz     906906            0       341750     21343437         7734  ticks
       #5  1498 MHz    1533406            0       554734     20503953        10890  ticks
       #6  1498 MHz     997250            0       346875     21247953         5265  ticks
       #7  1498 MHz    1456390            0       398671     20737031         7875  ticks
       #8  1498 MHz    1226265            0       445187     20920609         4218  ticks
       
  Memory: 31.775043487548828 GB (17582.63671875 MB free)
  Uptime: 25606.0 sec
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
       #1  1498 MHz    1123187            0       895046     20517359       377203  ticks
       #2  1498 MHz     693890            0       315421     21526078        12890  ticks
       #3  1498 MHz    1808062            0       628953     20098375        10921  ticks
       #4  1498 MHz     900953            0       340656     21293781         7734  ticks
       #5  1498 MHz    1525296            0       553718     20456375        10875  ticks
       #6  1498 MHz     989750            0       346265     21199375         5265  ticks
       #7  1498 MHz    1441359            0       397562     20696468         7859  ticks
       #8  1498 MHz    1211671            0       443984     20879718         4218  ticks
       
  Memory: 31.775043487548828 GB (17554.07421875 MB free)
  Uptime: 25549.0 sec
  Load Avg:  0.0  0.0  0.0
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-6.0.1 (ORCJIT, cannonlake)
```