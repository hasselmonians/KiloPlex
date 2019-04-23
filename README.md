# KiloPlex

This is a class designed to be run as a protocol with [RatCatcher](https://github.com/hasselmonians/RatCatcher).
It converts raw data from Plexon (`.plx`) neurophysiology data files into MATLAB matrices,
and provides an interface to the [KiloSort2](https://github.com/hasselmonians/Kilosort2) cluster-cutting software.


## Converting data

You can use the `plx2mat` function to convert from Plexon files to MATLAB matrices.
The `convert` function scales matrices and converts to a `KiloSort`-readable format.

## Spike sorting

Spike sorting is done through `RatCatcher`. Instantiate a `RatCatcher` object,
and use the `'KiloPlex'` protocol. See the `setup` script for an example.
