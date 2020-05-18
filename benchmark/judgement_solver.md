# Benchmark Report for *PartiallySeparableStructure*

## Job Properties
* Time of benchmarks:
    - Target: 18 May 2020 - 14:06
    - Baseline: 18 May 2020 - 14:05
* Package commits:
    - Target: 5f0d24
    - Baseline: 06303b
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
| `["Trunk", "ros 10 var"]` | 0.56 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Trunk", "ros 20 var"]` | 0.75 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Trunk", "ros 30 var"]` | 0.85 (5%) :white_check_mark: |   1.00 (1%)  |

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
       #1  1498 MHz     664937            0       480734     14641218       174828  ticks
       #2  1498 MHz     280343            0       160828     15345515         7000  ticks
       #3  1498 MHz    1104531            0       421140     14261015         5671  ticks
       #4  1498 MHz     408062            0       164125     15214500         2046  ticks
       #5  1498 MHz     855140            0       339109     14592437         4781  ticks
       #6  1498 MHz     434156            0       195093     15157437         2000  ticks
       #7  1498 MHz     693437            0       245968     14847281         3562  ticks
       #8  1498 MHz     423312            0       261796     15101562         2453  ticks
       
  Memory: 31.775043487548828 GB (20054.40234375 MB free)
  Uptime: 18801.0 sec
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
       #1  1498 MHz     656750            0       476843     14589984       174265  ticks
       #2  1498 MHz     271718            0       158828     15292828         6953  ticks
       #3  1498 MHz    1088781            0       418187     14216406         5609  ticks
       #4  1498 MHz     396171            0       161578     15165625         2000  ticks
       #5  1498 MHz     841203            0       335593     14546578         4734  ticks
       #6  1498 MHz     419828            0       193359     15110187         1968  ticks
       #7  1498 MHz     677578            0       243796     14802000         3531  ticks
       #8  1498 MHz     406843            0       259671     15056843         2453  ticks
       
  Memory: 31.775043487548828 GB (20960.70703125 MB free)
  Uptime: 18737.0 sec
  Load Avg:  0.0  0.0  0.0
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-6.0.1 (ORCJIT, cannonlake)
```