% FILE: sample_td_script.m
%
% PURPOSE: Matlab script to build up the files listed below into a valid
%          training data file, for use in page classification
%
% USEAGE: matlab -nojvm -nosplash < sample_td_script.m > /dev/null
%
% NOTES: All data is saved to the output file outfile

# change the output file below
outfile = './sample.data';

# list the path and filename of each page to be included in training data
# (enclose each in single quotes)
imgs = {
'/h/42/scottl/research/READY_TO_TAG/allwein00a.aa.tif'
'/h/42/scottl/research/READY_TO_TAG/allwein00a.ab.tif'
'/h/42/scottl/research/READY_TO_TAG/allwein00a.ac.tif'
}

s = create_training_data(imgs);
dump_training_data(s, outfile);
