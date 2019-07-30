%% NLX to MAT conversion script
% converts one NLX recording to .MAT format
% TODO: need to deal with non-continuous data, right now the time vector
% assumes continuous data stream 

% options
save_on = 0;
plot_on = 0;

% get data directory - convert everything in this folder

% get all .ncs files as filenames

% data filename
filename = 'BNC21.ncs';

% convert
% t_stamps = timestamps of each data packet (us)
% chans = unsure
% fs = sampling frequency of each data point (all same value)
% n_valid_samples = number of valid samples (out of 512?)
% data = 512 x samples of data (what does the 512 do)
% header = recording information
[t_stamps, chans, fs, n_valid_samples, data, header] = Nlx2MatCSC(filename,[1 1 1 1 1], 1, 1, [] );

% get voltage conversion info
v_convert = split(header{17,1},' ');
v_convert = str2double(v_convert{2});

% modify data so it's useable
fs = fs(1);
data = data.* v_convert;
data_reshape = reshape(data,[1 size(data,1)*size(data,2)]);
t_stamps = t_stamps / 1e6; % convert to seconds
t_start = t_stamps(1);
t = 1/fs:1/fs:length(data_reshape)/fs;

% plot data
if plot_on == 1
    figure
    plot(t,data_reshape.*1e3)
    xlabel('time (s)')
    ylabel('voltage (mV)')
    title(sprintf('%s',filename))
end

% save data as .MAT
if save_on == 1
    filename = split(filename,'.');
    filename = strcat(filename(1),'.mat');
    save(filename,'fs','data','header','t_stamps')
end


