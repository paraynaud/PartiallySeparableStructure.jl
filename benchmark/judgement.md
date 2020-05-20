# Benchmark Report for *PartiallySeparableStructure*

## Job Properties
* Time of benchmarks:
    - Target: 20 May 2020 - 09:48
    - Baseline: 20 May 2020 - 09:46
* Package commits:
    - Target: c75cd0
    - Baseline: c75cd0
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

| ID                                       | time ratio                   | memory ratio |
|------------------------------------------|------------------------------|--------------|
| `["SPS_function", "Hessien ros 20 var"]` |                1.33 (5%) :x: |   1.00 (1%)  |
| `["SPS_function", "Hessien ros 30 var"]` | 0.84 (5%) :white_check_mark: |   1.00 (1%)  |
| `["SPS_function", "OBJ ros 10 var"]`     | 0.93 (5%) :white_check_mark: |   1.00 (1%)  |
| `["SPS_function", "OBJ ros 20 var"]`     |                1.63 (5%) :x: |   1.00 (1%)  |
| `["SPS_function", "OBJ ros 30 var"]`     | 0.77 (5%) :white_check_mark: |   1.00 (1%)  |
| `["SPS_function", "grad ros 10 var"]`    | 0.88 (5%) :white_check_mark: |   1.00 (1%)  |
| `["SPS_function", "grad ros 20 var"]`    |                1.44 (5%) :x: |   1.00 (1%)  |

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
       #1  1498 MHz    2157500            0      2464031     51209593      1021750  ticks
       #2  1498 MHz    3482218            0      1070781     51277906        84250  ticks
       #3  1498 MHz    4082515            0      1089375     50659015        35953  ticks
       #4  1498 MHz    1692625            0       685250     53453031        23640  ticks
       #5  1498 MHz    2774343            0       956000     52100562        26687  ticks
       #6  1498 MHz    1400562            0       659578     53770765        14843  ticks
       #7  1498 MHz    2367390            0       811843     52651671        49734  ticks
       #8  1498 MHz    1336625            0       467437     54026828         9890  ticks
       
  Memory: 31.775043487548828 GB (19261.0703125 MB free)
  Uptime: 88977.0 sec
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
       #1  1498 MHz    2147140            0      2458937     51155046      1021187  ticks
       #2  1498 MHz    3474531            0      1068828     51217546        84203  ticks
       #3  1498 MHz    4067921            0      1086750     50606234        35843  ticks
       #4  1498 MHz    1682453            0       683781     53394671        23609  ticks
       #5  1498 MHz    2762593            0       953843     52044468        26609  ticks
       #6  1498 MHz    1388578            0       657828     53714500        14812  ticks
       #7  1498 MHz    2351578            0       809531     52599796        49687  ticks
       #8  1498 MHz    1315281            0       465765     53979843         9875  ticks
       
  Memory: 31.775043487548828 GB (19371.16015625 MB free)
  Uptime: 88907.0 sec
  Load Avg:  0.0  0.0  0.0
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-6.0.1 (ORCJIT, cannonlake)
```