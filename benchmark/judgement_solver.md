# Benchmark Report for *PartiallySeparableStructure*

## Job Properties
* Time of benchmarks:
    - Target: 18 May 2020 - 16:34
    - Baseline: 18 May 2020 - 16:30
* Package commits:
    - Target: 61f9d1
    - Baseline: 61f9d1
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

| ID                             | time ratio                   | memory ratio                 |
|--------------------------------|------------------------------|------------------------------|
| `["ros 10 var", "L-BFGS"]`     | 0.87 (5%) :white_check_mark: |                   1.00 (1%)  |
| `["ros 10 var", "L-SR1"]`      |                1.22 (5%) :x: |                   1.00 (1%)  |
| `["ros 10 var", "P-SR1"]`      |              484.71 (5%) :x: |               85.46 (1%) :x: |
| `["ros 10 var", "Trunk"]`      |                1.68 (5%) :x: |                   1.00 (1%)  |
| `["ros 10 var", "Trunk_LSR1"]` |                   1.00 (5%)  |                1.03 (1%) :x: |
| `["ros 20 var", "L-BFGS"]`     |                1.16 (5%) :x: |                   1.00 (1%)  |
| `["ros 20 var", "L-SR1"]`      |                1.25 (5%) :x: |                   1.00 (1%)  |
| `["ros 20 var", "P-SR1"]`      |                1.28 (5%) :x: |                   1.00 (1%)  |
| `["ros 20 var", "Trunk"]`      |                1.86 (5%) :x: |                   1.00 (1%)  |
| `["ros 20 var", "Trunk_LSR1"]` |                   1.00 (5%)  | 0.59 (1%) :white_check_mark: |
| `["ros 30 var", "L-BFGS"]`     | 0.91 (5%) :white_check_mark: |                   1.00 (1%)  |
| `["ros 30 var", "L-SR1"]`      |                1.62 (5%) :x: |                   1.00 (1%)  |
| `["ros 30 var", "P-BFGS"]`     | 0.92 (5%) :white_check_mark: |                   1.00 (1%)  |
| `["ros 30 var", "P-SR1"]`      |                1.27 (5%) :x: |                   1.00 (1%)  |
| `["ros 30 var", "Trunk"]`      | 0.94 (5%) :white_check_mark: |                   1.00 (1%)  |
| `["ros 30 var", "Trunk_LSR1"]` |                   1.00 (5%)  |                1.35 (1%) :x: |

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
       #1  1498 MHz    1353593            0      1026312     22309265       427093  ticks
       #2  1498 MHz     869515            0       366718     23452734        14796  ticks
       #3  1498 MHz    2167859            0       701656     21819453        12187  ticks
       #4  1498 MHz    1168609            0       404828     23115531         9953  ticks
       #5  1498 MHz    1876296            0       640265     22172406        13578  ticks
       #6  1498 MHz    1262578            0       392765     23033625         6359  ticks
       #7  1498 MHz    1852125            0       456937     22379906         9656  ticks
       #8  1498 MHz    1600281            0       501687     22586984         4953  ticks
       
  Memory: 31.775043487548828 GB (16442.609375 MB free)
  Uptime: 27703.0 sec
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
       #1  1498 MHz    1301953            0      1008312     22134968       423109  ticks
       #2  1498 MHz     832765            0       359125     23253140        14484  ticks
       #3  1498 MHz    2085234            0       689921     21669875        11875  ticks
       #4  1498 MHz    1105546            0       394468     22945015         9562  ticks
       #5  1498 MHz    1797500            0       626640     22020890        13187  ticks
       #6  1498 MHz    1204734            0       385656     22854640         6125  ticks
       #7  1498 MHz    1768093            0       444875     22232062         9296  ticks
       #8  1498 MHz    1529578            0       494703     22420734         4828  ticks
       
  Memory: 31.775043487548828 GB (16845.7734375 MB free)
  Uptime: 27459.0 sec
  Load Avg:  0.0  0.0  0.0
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-6.0.1 (ORCJIT, cannonlake)
```