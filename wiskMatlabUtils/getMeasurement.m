
function T = getMeasurement(measurements)

%Convert to obtain only whisker related data
d = cell2struct(cellfun(@double,struct2cell(measurements),'uni',false),fieldnames(measurements),1);
array = cell2mat( struct2cell(d));
array2 = transpose(array);
x = array2(:,3) ~=0;
array2(x,:) = [];
array3 = sortrows(array2);
fields2 = {'fid' 'wid' 'lable' 'face_x' 'face_y' 'length' 'score' 'angle' 'curvature' 'follicle_x' 'follicle_y' 'tip_x' 'tip_y'};
measurements2 = table2struct(array2table(array3,'VariableNames',fields2));
frames = length(measurements2); %Get number of frames

%Get frames
fid = [measurements2.fid].';

% create an artificial time duration to regularize the timeseries that contains duplicate and missing values
fid = seconds(fid);

%Filter using Butterworth bandpass
curvature = [measurements2.curvature].';
ang = [measurements2.angle].';
fs = 500; %sampling frequency in Hz
lowcut = 4; %unit in Hz
highcut = 30; %unit in Hz
[b,a]=butter(2, [lowcut highcut]/(fs/2)); % open ephys
angfilt = filtfilt(b,a,ang);
%angfilt = filter(b,a,ang);

%Find setpoint
[b,a]=butter(4,7/(fs/2));
%setpoints = filtfilt(b,a,angfilt);
setpoints = filtfilt(b,a,ang);

%Hilbert transformation to obtain phase, amp, freq 
z = hilbert(angfilt); %form the analytical signal
inst_amplitude = abs(z); %envelope extraction
[b,a]=butter(2, [lowcut highcut]/(fs/2)); 
inst_amplitude_filt = filtfilt(b,a,inst_amplitude);
phase = angle(z);
inst_phase = unwrap(angle(z)); %inst phase
%inst_freq = diff(inst_phase)/(2*pi)*fs; %inst frequency
inst_freq = fs/(2*pi)*diff(inst_phase); %inst frequency
inst_freq_filt = sgolayfilt(inst_freq,2,11);

%Determine Angular Velocity by taking derivative of angle
ang_savgol = sgolayfilt(angfilt,3,9);
ang_vel = diff(ang_savgol);
%ang_vel = diff(angfilt);
ang_vel_filt = sgolayfilt(ang_vel,2,13);

%Determine Angular Accleration by taking derivative of angular velocity
ang_accel = diff(ang_vel_filt);
ang_accel_filt = sgolayfilt(ang_accel,2,13);


%Make variables have equal rows for output
add = NaN;
add2 = [NaN;add];
ang_accel_ = [ang_accel;add2];
ang_accel_filt_ = [ang_accel_filt;add2];
ang_vel_ = [ang_vel;add];
ang_vel_filt_ = [ang_vel_filt;add];
inst_freq_ = [inst_freq;add];
inst_freq_filt_ = [inst_freq_filt;add];



filt_curvature = sgolayfilt(curvature,2,11);

%Create table for variables
T = timetable(fid, curvature,filt_curvature,ang,angfilt,setpoints,phase,inst_phase,inst_freq_,inst_freq_filt_,inst_amplitude,inst_amplitude_filt,ang_vel_,ang_vel_filt_,ang_accel_,ang_accel_filt_);

% regularize the time series of the table 
T = retime(T,'secondly');
T = retime(T,'secondly', 'spline');
T = timetable2table(T);
T.fid = seconds(T.fid);
