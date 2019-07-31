%% NLX to MAT conversion script
% converts one NLX recording to .MAT format
%
% t_stamps          timestamps of each data packet (us)
% chans             unsure
% fs                sampling frequency of each data point (all same value)
% n_valid_samples   number of valid samples (out of 512?)
% data              512 x samples of data (what does the 512 do)
% header            recording information

% TODO: need to deal with non-continuous data, right now the time vector
% assumes continuous data stream 

function NLX2MAT_convert

tic 

% options
save_on = 1;
plot_on = 0; % will pause after every file

% get data directory - convert everything in this folder
datapath = uigetdir(pwd,'select NLX data folder');
outpath = uigetdir(pwd, 'select an output directory for MAT file');
file_list = dir(fullfile(datapath, '*.ncs'));
num_files = length(file_list);

% setup data structs
NLX_data = struct;

% for all files in directory 
for idx = 1:num_files
    % get names
    chan = file_list(idx).name;
    chan = split(chan,'.');
    chan = chan{1};
    
    filename = strcat(datapath,'\',file_list(idx).name);
    NLX_data(idx).name = chan;
    
    % convert data
    [t_stamps, chans, fs, n_valid_samples, data, header] = Nlx2MatCSC(filename,[1 1 1 1 1], 1, 1, [] );
    
    % convert data from ADC to voltage
    v_convert = split(header{17,1},' ');
    v_convert = str2double(v_convert{2});
    ECOG = data.* v_convert;
    ECOG = reshape(ECOG,[1 size(data,1)*size(data,2)]);

    % modify data so it's useable
    fs = fs(1);
    t_stamps = t_stamps / 1e6; % convert to seconds
    t_start = t_stamps(1);
    t = 1/fs:1/fs:length(ECOG)/fs;

    % plot data
    if plot_on == 1
        figure
        plot(t,ECOG.*1e3)
        xlabel('time (s)')
        ylabel('voltage (mV)')
        title(sprintf('%s',chan))
        pause
    end

    % save data to struct
    NLX_data(idx).fs = fs;
    NLX_data(idx).header = header;
    NLX_data(idx).t = t;
    NLX_data(idx).t_start = t_start;
    NLX_data(idx).ECOG = ECOG;
    
    fprintf('Successfully saved %s\n',chan)
end

% save data to file

if save_on == 1
    out_name = split(datapath,'\');
    outpath_name = strcat(outpath,'\',out_name{end},'.mat');
    save(outpath_name,'NLX_data','-v7.3')
    fprintf('Finished in %.2f seconds\n',toc)
end




end
