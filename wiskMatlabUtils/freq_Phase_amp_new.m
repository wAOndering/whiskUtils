%Change Animal and Type as well as measurements patha and filename below
%Add animal ID for saving the csv file
%For Baseline Comment out between line 164 and 174 %Find peaks from filtered curvature
%As well as the xlsx write, lines 187-194
Animal = '851';
Type = '_pole';
%Type = '_baseline';

%Add path and file name we want to analyze
measurements = LoadMeasurements('851_p.measurements');




%For csv file
ID = [Animal,Type,'.csv'];

%For loading baseline curvature: use the baseline file
filename = [Animal,'_baseline.csv'];

%For making peaks table
ID_2 = [Animal,Type,'_peaks.xlsx'];

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


%Plot ang, filtered angle, instantaneous frequency and phase, phase
figure 
subplot(5,1,1); 
plot(ang) %plot the angle
hold on
plot(setpoints) %plot the setpoints
title('Angle')
subplot(5,1,2); 
plot(angfilt) %plot the filtered angle
title('Filtered Angle')
subplot(5,1,3);
plot(inst_freq_filt)
title('Instantaneous Frequency')
subplot(5,1,4);
plot(phase)
title('Phase')
subplot(5,1,5);
plot(inst_amplitude)
title('Instantaneous Amplitude')

%Determine Angular Velocity by taking derivative of angle
ang_savgol = sgolayfilt(angfilt,3,9);
ang_vel = diff(ang_savgol);
%ang_vel = diff(angfilt);
ang_vel_filt = sgolayfilt(ang_vel,2,13);
figure
plot(ang_vel_filt)
%plot(ang_vel)
title('Angular Velocity')

%Determine Angular Accleration by taking derivative of angular velocity
ang_accel = diff(ang_vel_filt);
ang_accel_filt = sgolayfilt(ang_accel,2,13);
figure
plot(ang_accel_filt)
title('Angular Acceleration')

%Make variables have equal rows for output
add = NaN;
add2 = [NaN;add];
ang_accel_ = [ang_accel;add2];
ang_accel_filt_ = [ang_accel_filt;add2];
ang_vel_ = [ang_vel;add];
ang_vel_filt_ = [ang_vel_filt;add];
inst_freq_ = [inst_freq;add];
inst_freq_filt_ = [inst_freq_filt;add];


%Find peaks from filtered angle for protraction
% amp_peak_pro = peak amplitude
% locs = location of peak
[amp_peak_pro,locs,wdths] = findpeaks(angfilt,'MinPeakHeight',4,'MinPeakWidth',5,'MinPeakDistance',20,'WidthReference','halfheight','Annotate','extents');
figure
findpeaks(angfilt,'MinPeakHeight',4,'MinPeakWidth',5,'MinPeakDistance',20,'WidthReference','halfheight','Annotate','extents');
xlabel('Frames')
ylabel('Angle')
title('Protraction')

%Find peaks from filtered angle for retraction
% amp_peak_ret = peak amplitude
% l = location of peak
[amp_peak_ret,l] = findpeaks(-angfilt,'MinPeakHeight',4,'MinPeakWidth',5,'MinPeakDistance',20,'WidthReference','halfheight','Annotate','extents');
figure
findpeaks(-angfilt,'MinPeakHeight',4,'MinPeakWidth',5,'MinPeakDistance',20,'WidthReference','halfheight','Annotate','extents');
xlabel('Frames')
ylabel('Angle')
title('Retraction')

%Get angular velocity from protraction peaks
ang_vel_pro = ang_vel_filt(locs-5);

%Get angular velocity from retraction peaks
ang_ret = ang_vel_filt(l-5);
ang_vel_ret = -ang_ret;

%Plot curvature
filt_curvature = sgolayfilt(curvature,2,11);
figure
plot(filt_curvature);
title('Filtered Curvature');

%Create table for variables
T = table(curvature,filt_curvature,ang,angfilt,setpoints,phase,inst_phase,inst_freq_,inst_freq_filt_,inst_amplitude,inst_amplitude_filt,ang_vel_,ang_vel_filt_,ang_accel_,ang_accel_filt_);
writetable(T,ID);

%take baseline curvature
baseline1 = importfile(filename, 2, inf);
baseline_curv = mean(baseline1);
delta_curv = filt_curvature - baseline_curv;

%take baseline curvature
%balls = 0.001842;
%delta_curv = filt_curvature - balls;

%Plot curvature
figure
plot(delta_curv);
title('Delta Curvature');

%
%Find peaks from filtered curvature
% curve_peak = peak amplitude
[o,points,curve_widths,curve_peak] = findpeaks(-delta_curv,'MinPeakHeight',0.0004,'MinPeakProminence',0.0004,'MinPeakWidth',4,'MinPeakDistance',10,'MaxPeakWidth',50,'WidthReference','halfprom','Annotate','extents');
%[y,x] = findpeaks(-delta_curv,'MinPeakHeight',4,'MinPeakWidth',5,'MinPeakDistance',20,'WidthReference','halfheight','Annotate','extents');
figure
findpeaks(-delta_curv,'MinPeakHeight',0.0004,'MinPeakProminence',0.0004,'MinPeakWidth',4,'MinPeakDistance',10,'MaxPeakWidth',50,'WidthReference','halfprom','Annotate','extents');
xlabel('Frames')
ylabel('Delta Curvature')
title('Curvature');
%}

%Find AUC for delta curvature
%fid = [measurements2.fid].';
%fids = fid / fs;
%auc = trapz(fids,delta_curv);

%Create table for variables
T = table(curvature,filt_curvature,ang,angfilt,setpoints,phase,inst_phase,inst_freq_,inst_freq_filt_,inst_amplitude,inst_amplitude_filt,ang_vel_,ang_vel_filt_,ang_accel_,ang_accel_filt_,delta_curv);
writetable(T,ID);

%Write peaks files to xlsx
warning( 'off', 'MATLAB:xlswrite:AddSheet' ) ;
%
xlswrite(ID_2,'P','Curvature','A1');
xlswrite(ID_2,curve_peak,'Curvature','A2');
xlswrite(ID_2,'W','Curvature','B1');
xlswrite(ID_2,curve_widths,'Curvature','B2');
xlswrite(ID_2,'L','Curvature','C1');
xlswrite(ID_2,points,'Curvature','C2');
%}

xlswrite(ID_2,'A','Peaks protract','A1');
xlswrite(ID_2,amp_peak_pro,'Peaks protract','A2');
xlswrite(ID_2,'V','Peaks protract','B1');
xlswrite(ID_2,ang_vel_pro,'Peaks protract','B2');
xlswrite(ID_2,'A','Peaks retract','A1');
xlswrite(ID_2,amp_peak_ret,'Peaks retract','A2');
xlswrite(ID_2,'V','Peaks retract','B1');
xlswrite(ID_2,ang_vel_ret,'Peaks retract','B2');

%close all;
clear all;