# handwriting-recognition

This repository contains Matlab scripts for handwriting recognition using support vector machines (SVMs) and neural networks (NNs). The SVM and NN portions comprised the final projects for Yale's STAT 365 - Data Mining and Machine Learning and CPSC 576 - Advanced Computational Vision courses, respectively.

The data consists of 700 32x32 letter images (5 categories -- 'a' through 'e') hand drawn by me and a friend, split into 400/300 training/testing examples. The goal was to build classifiers that could distinguish between the letters, and also the _writers_.

For the SVMs I tested various kernels: linear, polynomial order 3/5/9, gaussian. Meanwhile for the NNs I tested different hidden layer configurations, ranging from 1 to 3 hidden layers, each having 4 to 1024 units. I also tested 'augmenting' the training data by adding modified examples of the original images with some filter applied -- Gaussian noise, median blur, Gaussian blur, etc. This effectively increased my training data size and improved test performance, at least with certain filters.

The best SVM letter recognition performance was a 99% f-score using a polynomial order 9 kernel, 1 vs. all classifiers, and Gaussian-noise-augmented training data. The best NN performance was 97% f-score with 3 hidden layers (256-64-16) and Gaussian-blur-augmented data. These are comparable with results in research (see http://yann.lecun.com/exdb/mnist), though on the other hand this data set is particularly 'clean' -- few odd-shaped letters and the like.

The best SVM writer recognition f-score was 93% using a polynomial order 3 kernel and Gaussian blur augmentation, while for NNs it was 92% using 2 hidden layers (256-1024) and Gaussian blur augmentation. It's unclear how impressive this result is, as I didn't test how well people could perform the task.

## Dependencies
- Matlab 2015a (or higher)

## Usage
To run the full analysis from start to finish, run `scriptSvm.m` and then `scriptNn.m`. This will create the following output files:

- `images.mat`: raw image data (one image per column)
- `data.mat`: labeled image data
- `train.mat`/`test.mat`: training/testing data
- `extra.mat`: augmented training data
- `models.mat`/`nn.mat`: SVM/NN models for classifying letters and person who wrote the letters
  - Note these are cell grids with a particular indexing scheme to identify particular models
    - For an SVM model with index `{k,i,j}`, `k` indicates training data augmentation (if any), `i` specifies the kernel, and 'j' give multiclass type (1v1 or 1vAll) -- with the index order implied in the [source code](https://github.com/vancezuo/handwriting-recognition/blob/master/scriptSvm.m#L141)
    - For an NN model with index `{i,j}`, `i` indicates training data augmentation (if any), and `j` specifies the hidden layer structure -- see the [source code](https://github.com/vancezuo/handwriting-recognition/blob/master/scriptNn.m#L12) for the index order
  - Admittedly this is a convoluted setup, and should be made more user friendly
- `eval.mat`/`nneval.mat`: SVM/NN model confusion matrices, accuracies, and f-scores (these are also written to text files in a `results` folder)
  - Has the same indexing as the models `models.mat`/`nn.mat`

To adapt these scripts to different data requires modifying accordingly the `%% Load data`, `%% Label data`, and `%% Randomly split into training/testing sets` sections in `scriptSvm.m` and their associated functions.

To test other training data augmentations or model hyperparameters, make the appropriate changes to the `%% Generate "extra" training data` and `%% Train SVMs` sections of `scriptSvm.m` and `%% Train NNs` section of `scriptNN.m`, as well as their associated functions. 
