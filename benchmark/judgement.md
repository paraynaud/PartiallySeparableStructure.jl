# Benchmark Report for *PartiallySeparableStructure*

## Job Properties
* Time of benchmarks:
    - Target: 11 May 2020 - 16:56
    - Baseline: 11 May 2020 - 16:54
* Package commits:
    - Target: 61f590
    - Baseline: 2f52ce
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
| `["SPS_function", "OBJ ros 100 var"]`     |                1.08 (5%) :x: |   1.00 (1%)  |
| `["SPS_function", "grad ros 100 var"]`    | 0.88 (5%) :white_check_mark: |   1.00 (1%)  |
| `["SPS_function", "grad ros 500 var"]`    |                1.08 (5%) :x: |   1.00 (1%)  |

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
       #1  1498 MHz    1491171            0       618750      5527218       156937  ticks
       #2  1498 MHz    2503046            0       315187      4818687        35484  ticks
       #3  1498 MHz    2283593            0       402296      4951031         9218  ticks
       #4  1498 MHz    1370937            0       223281      6042703         3984  ticks
       #5  1498 MHz    1757625            0       415906      5463390        16156  ticks
       #6  1498 MHz    1389593            0       423984      5823343         5656  ticks
       #7  1498 MHz    2001218            0       404515      5231187        11500  ticks
       #8  1498 MHz    1545109            0       295343      5796468         7859  ticks
       
  Memory: 31.775043487548828 GB (17917.75390625 MB free)
  Uptime: 7636.0 sec
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
       #1  1498 MHz    1475593            0       611687      5457343       155031  ticks
       #2  1498 MHz    2489765            0       312609      4742031        35328  ticks
       #3  1498 MHz    2258859            0       397906      4887640         9140  ticks
       #4  1498 MHz    1349843            0       219781      5974781         3890  ticks
       #5  1498 MHz    1737812            0       411593      5395000        15937  ticks
       #6  1498 MHz    1369250            0       419625      5755531         5609  ticks
       #7  1498 MHz    1978718            0       400796      5164890        11437  ticks
       #8  1498 MHz    1514734            0       292328      5737328         7859  ticks
       
  Memory: 31.775043487548828 GB (18002.58984375 MB free)
  Uptime: 7544.0 sec
  Load Avg:  0.0  0.0  0.0
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-6.0.1 (ORCJIT, cannonlake)
```