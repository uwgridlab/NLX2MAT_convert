# NLX2MAT_convert
Converts Neuralynx data to useable .mat format using the [Neuralynx MATLAB converter](https://neuralynx.com/software/category/matlab-netcom-utilities)

Primary function: NLX2MAT_convert.m

Options in function: 
 - save_on (1 to save data)
 - plot_on (1 to see every data stream coming in, will pause after each one)

**TODO**: need to deal with non-continuous data, right now the time vector
assumes continuous data stream 

**TODO**: fix order - right now it's alphabetical but we need it to be in
order of NLX system (right now its grid1 grid10 grid11...)

