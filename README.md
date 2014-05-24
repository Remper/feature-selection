Implementation Task: a feature selection application
=======

Pointwise Mutual Information and Chi-Squared algorithms implementation
for feature selection for binary features.

Uses Grand Central Dispatch for multithreading. If it's available in
your system it should kick in automatically

How to use
------------------------------------
Dist directory contains binary file compiled for x64 Mac OS X.
Binary accepts 4 parameters:

1. File from which to read the dataset (defaults to sample.dat). File
should be in LIBSVM format

2. Feature selection metric — "pmi" or "chi2" (defaults to chi2)

3. Number of features to select (defaults to 10)

4. File in which to store features (defaults to result.txt)

Here are some examples:
```
./ml trivial.dat chi2 25 result1.txt
./ml a9a.dat pmi 25 result1.txt
```

How to compile
------------------------------------
Just open ml.xcodeproj in XCode and build.

There is also GNUStep makefile available for Linux compilation,
but this option is not currently supported due to author's excessive usage
of Objective-C 2.0's syntactic sugar. Please forgive me.
