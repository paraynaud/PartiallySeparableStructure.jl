# Benchmark Report for *PartiallySeparableStructure*

## Job Properties
* Time of benchmarks:
    - Target: 18 May 2020 - 14:46
    - Baseline: 18 May 2020 - 14:45
* Package commits:
    - Target: 5f0d24
    - Baseline: ab3254
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
       #1  1498 MHz     836312            0       633781     16704796       242250  ticks
       #2  1498 MHz     436328            0       218781     17519578         9359  ticks
       #3  1498 MHz    1375578            0       500406     16298703         7562  ticks
       #4  1498 MHz     587984            0       233312     17353390         4062  ticks
       #5  1498 MHz    1099875            0       424515     16650296         7453  ticks
       #6  1498 MHz     623250            0       253375     17298062         3046  ticks
       #7  1498 MHz     958312            0       305234     16911140         5343  ticks
       #8  1498 MHz     672843            0       330734     17171093         3062  ticks
       
  Memory: 31.775043487548828 GB (18242.296875 MB free)
  Uptime: 21189.0 sec
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
       #1  1498 MHz     832093            0       632078     16651265       241906  ticks
       #2  1498 MHz     432515            0       217984     17464734         9281  ticks
       #3  1498 MHz    1366343            0       499031     16249859         7562  ticks
       #4  1498 MHz     581234            0       231437     17302562         4000  ticks
       #5  1498 MHz    1091250            0       422593     16601390         7421  ticks
       #6  1498 MHz     615156            0       252734     17247343         3046  ticks
       #7  1498 MHz     947812            0       303984     16863437         5328  ticks
       #8  1498 MHz     659640            0       329296     17126281         3062  ticks
       
  Memory: 31.775043487548828 GB (18161.29296875 MB free)
  Uptime: 21129.0 sec
  Load Avg:  0.0  0.0  0.0
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-6.0.1 (ORCJIT, cannonlake)
```