%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NOTES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note of 20210209
%%% inculde bacth capacity
%%% incude fid within the output files 
%%% CAREFUL duplicate values are present in fid those would be remove during downstream processing in python
%%% probably could clean up the getMeasurement and getPeaks function
%%% see repos

% IMPORTANT Segmentation of tmpDir and dirs may differe depending on os used and can lead to error 
% if strucuture of the folder are changed etc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% KEY FOLDERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input the path of interest
addpath(genpath('/home/rum/MatlabSoft/whisker_analysis_for_tom'))
mypath = '/run/user/1000/gvfs/smb-share:server=ishtar,share=millerrumbaughlab/Sheldon/Highspeed/analyzed' %'Y:\Sheldon\Highspeed\analyzed';
mypath = 'Y:\Sheldon\Highspeed\analyzed';
% get a subset of all the files present in the main folder this happens recursively
filelist = dir(fullfile(mypath, '**/*p*.measurements')); % to process multi-experiments at once
% filelist = dir(fullfile(mypath, '/*005*/**/*p*.measurements'));
mainExportFolder = 'NewExport20210209';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CREATE FOLDER STRUCTURE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create the full list of folder to keep the original folder structrue constant
% the output files will be exported there 
% once the folder strucuture created once no need to repeat
folderToCreate = unique({filelist.folder}')
for ij = 1:length(folderToCreate)
	% display(folderToCreate(ij));
	dirs = split(folderToCreate(ij), filesep);
	dirs = cat(1,{mainExportFolder},dirs([5:end],1));
	% loop to make all subsequent folder
	for k = 1 :length(dirs)
	  Thisdir = [mypath,filesep,fullfile(dirs{1:k})];
	  % display(Thisdir)
	  mkdir(Thisdir);
	end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ITERATE OVER POLE MEASUREMENT FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iterate of measurement file with pole + baseline extraction
filelist = dir(fullfile(mypath, '**/*p*.measurements')); % to p
for ii = 1:length(filelist) % stop at 102

	measurements_name = [filelist(ii).folder,filesep,filelist(ii).name];
	display(strjoin([ii, '/', string(length(filelist))]))
	display(measurements_name)
	measurements = LoadMeasurements(measurements_name);
	% export data as csv
	% recreate the folders name
	tmpDir = split(filelist(ii).folder, filesep);
	mainDir = strjoin(tmpDir([1:5]), filesep);% get the major experimental dir
	tmpDir = cat(1,tmpDir([1:4]),{mainExportFolder},tmpDir([5:end],1));
	tmpDir = strjoin(tmpDir, filesep);
	
	% retrieve the name of the name of th file
	if contains(filelist(ii).name, '_2_') % if statement to deal with specific file strucuture
	tmpFileName = strrep(filelist(ii).name, '_2_', '_');
	else
	tmpFileName = filelist(ii).name;
	end

	animalID = regexprep(tmpFileName,'\D',''); % extract only the digit from the name
	ID = [tmpDir, filesep, animalID, '_p.csv'];
	baselineID = strrep(ID, '_p.csv', '_b.csv');
	% function to get the table for the pole data
	Tpole = getMeasurement(measurements);


	% function to get the table for the baseline data
	try
		% this section is necessary to deal with different naming structure
		tmp1 = dir(fullfile(mainDir, ['**/*b*',animalID,'.measurements']));
		tmp2 = dir(fullfile(mainDir, ['**/*',animalID,'*b*.measurements']));
		% this section enables to deal with multiple baseline file and only work with one
		% this makes sense as baseline is to account for animal natural 
		% whisker curvature
		tmp = [tmp1, tmp2];
		tmp = tmp(1);

		baseline_file = [tmp.folder, filesep, tmp.name];
		baseline_measurements = LoadMeasurements(baseline_file);
		Tbaseline = getMeasurement(baseline_measurements);
		
		% get the baseline curvature 
		baseline_curv = mean(Tbaseline.curvature);
		delta_curv = Tpole.filt_curvature - baseline_curv;
		Tpole.delta_curv = delta_curv;

		% save both baseline 
		writetable(Tbaseline, baselineID);
		display(baselineID)
		display('DONE')

	catch
		display(baseline_measurements)
		display('ERROR ON ---^')

	end
	writetable(Tpole, ID);

	% get the peaks table from the data
	ID_2 = strrep(ID, '.csv', 'eaks.csv');
	getPeaks(Tpole, ID_2);


	display(ID)
	display('DONE')

end