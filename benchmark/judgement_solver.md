# Benchmark Report for *PartiallySeparableStructure*

## Job Properties
* Time of benchmarks:
    - Target: 20 May 2020 - 10:04
    - Baseline: 20 May 2020 - 10:01
* Package commits:
    - Target: a2711c
    - Baseline: a2711c
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

| ID                             | time ratio                   | memory ratio  |
|--------------------------------|------------------------------|---------------|
| `["ros 10 var", "L-SR1"]`      |                1.12 (5%) :x: |    1.00 (1%)  |
| `["ros 10 var", "Trunk"]`      | 0.93 (5%) :white_check_mark: |    1.00 (1%)  |
| `["ros 20 var", "L-SR1"]`      | 0.80 (5%) :white_check_mark: |    1.00 (1%)  |
| `["ros 20 var", "P-SR1"]`      | 0.85 (5%) :white_check_mark: |    1.00 (1%)  |
| `["ros 20 var", "Trunk_LSR1"]` |                   0.97 (5%)  | 1.10 (1%) :x: |
| `["ros 30 var", "L-BFGS"]`     | 0.81 (5%) :white_check_mark: |    1.00 (1%)  |
| `["ros 30 var", "P-BFGS"]`     | 0.78 (5%) :white_check_mark: |    1.00 (1%)  |
| `["ros 30 var", "Trunk"]`      | 0.61 (5%) :white_check_mark: |    1.00 (1%)  |
| `["ros 30 var", "Trunk_LSR1"]` |                   1.00 (5%)  | 1.29 (1%) :x: |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["ros 10 var"]`
- `["ros 20 var"]`
- `["ros 30 var"]`

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
       #1  1498 MHz    2246156            0      2519796     52066593      1030515  ticks
       #2  1498 MHz    3519296            0      1086703     52226328        84625  ticks
       #3  1498 MHz    4249250            0      1122765     51460312        36734  ticks
       #4  1498 MHz    1778843            0       726625     54326859        25203  ticks
       #5  1498 MHz    2913265            0      1013546     52905515        28718  ticks
       #6  1498 MHz    1478265            0       675953     54678109        15484  ticks
       #7  1498 MHz    2580843            0       843578     53407906        50578  ticks
       #8  1498 MHz    1460078            0       481906     54890328        10093  ticks
       
  Memory: 31.775043487548828 GB (19652.10546875 MB free)
  Uptime: 89978.0 sec
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
       #1  1498 MHz    2228171            0      2511656     51877781      1029062  ticks
       #2  1498 MHz    3512359            0      1084281     52020750        84593  ticks
       #3  1498 MHz    4204828            0      1116562     51296000        36500  ticks
       #4  1498 MHz    1757531            0       715281     54144578        24656  ticks
       #5  1498 MHz    2876343            0       998328     52742718        28015  ticks
       #6  1498 MHz    1461234            0       673171     54482984        15250  ticks
       #7  1498 MHz    2518937            0       837687     53260765        50406  ticks
       #8  1498 MHz    1436625            0       480140     54700609        10093  ticks
       
  Memory: 31.775043487548828 GB (19593.72265625 MB free)
  Uptime: 89763.0 sec
  Load Avg:  0.0  0.0  0.0
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-6.0.1 (ORCJIT, cannonlake)
```