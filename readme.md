## Game Of Life Benchmarks

Impl | Without Stdout | With Stdout
-|-|-
Padded 2D Array | 561ms | 1387ms
Padded 1D Array | 395ms | 1190ms
Padded 1D Array + `write_rune` | 400ms | 1183ms
Padded 1D Array + []u8 | 85ms | 922ms
Padded 1D Array + []u8 + Preallocate 2 Arrays | 44ms | 899ms
Unpadded 1D Array + []u8 + Preallocate 2 Arrays | 100ms+ | untested
Padded 1D Array + strings.Builder + virtual buffer | 273ms | 356ms
