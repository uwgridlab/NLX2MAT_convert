%% NLX to MAT conversion script
% converts one NLX recording to .MAT format
%
% t_stamps          timestamps of each data packet (us)
% chans             unsure
% fs                sampling frequency of each data point (all same value)
% n_valid_samples   number of valid samples (out of 512?)
% data              512 x samples of data (what does the 512 do)
% header            recording information

function NLX2MAT_convert
addpath('C:\Users\sunh20\Documents\Projects\NLX2MAT_convert\MatlabImportExport_v6.0.0')
addpath('C:\Users\sunh20\Documents\Projects\NLX2MAT_convert\natsortfiles')

tic 

% options
save_on = 1;
plot_on = 0; % will pause after every file

% get data directory - convert everything in this folder
datapath = uigetdir(pwd,'select NLX data folder');
outpath = uigetdir(pwd, 'select an output directory for MAT file');
chans = dir(fullfile(datapath, '*.ncs'));
chans = natsortfiles(extractfield(chans,'name'));
num_files = length(chans);

% setup data 
NLX_data = {};
chans_fs = [];
t_start = [];

% for all files in directory 
for idx = 1:num_files
    % get names
    ch = chans{idx};
    ch = split(ch,'.');
    ch = ch{1};
    chans{idx} = ch;
    
    filename = strcat(datapath,'\',chans{idx},'.ncs');

    
    % convert data
    [t_stamps, ~, fs, ~, data, header] = Nlx2MatCSC(filename,[1 1 1 1 1], 1, 1, [] );
    
    % if first time in loop, setup proper matrix sizes
    if idx == 1
        NLX_data = cell(1,num_files);
        chans_fs = zeros(1,num_files);
        t_start = zeros(1,num_files);
    end
    
    % convert data from ADC to voltage
    v_convert = split(header{17,1},' ');
    v_convert = str2double(v_convert{2});
    ECOG = data.* v_convert;
    NLX_data{idx} = reshape(ECOG,[1 size(data,1)*size(data,2)]);

    % modify data so it's useable
    chans_fs(idx) = fs(1); 
    t_stamps = t_stamps / 1e6; % convert to seconds
    t_start(idx) = t_stamps(1);
    % t = 1/fs:1/fs:length(ECOG)/fs;

    % plot data
    if plot_on == 1
        figure
        plot(t,ECOG.*1e3)
        xlabel('time (s)')
        ylabel('voltage (mV)')
        title(sprintf('%s',ch))
        pause
    end

    % save data to struct
%     NLX_data(idx).fs = fs;
%     NLX_data(idx).header = header;
%     NLX_data(idx).t = t;
%     NLX_data(idx).t_start = t_start;
%     NLX_data(idx).ECOG = ECOG;
    
    fprintf('Successfully converted %s\n',ch)
end

% save data to file
disp('Saving to file...')
if save_on == 1
    out_name = split(datapath,'\');
    outpath_name = strcat(outpath,'\',out_name{end},'.mat');
    save(outpath_name,'NLX_data','chans','chans_fs','t_start','-v7.3')
    fprintf('Finished in %.2f seconds\n',toc)
end




end
