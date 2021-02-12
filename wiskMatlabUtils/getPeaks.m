function getPeaks(Tpole, ID_2)


[o,points,curve_widths,curve_peak] = findpeaks(-Tpole.delta_curv,'MinPeakHeight',0.0004,'MinPeakProminence',0.0004,'MinPeakWidth',4,'MinPeakDistance',10,'MaxPeakWidth',50,'WidthReference','halfprom','Annotate','extents');
[amp_peak_pro,locs,wdths] = findpeaks(Tpole.angfilt,'MinPeakHeight',4,'MinPeakWidth',5,'MinPeakDistance',20,'WidthReference','halfheight','Annotate','extents');
[amp_peak_ret,l] = findpeaks(-Tpole.angfilt,'MinPeakHeight',4,'MinPeakWidth',5,'MinPeakDistance',20,'WidthReference','halfheight','Annotate','extents');
%Write peaks files to xlsx
%Get angular velocity from protraction peaks

%Determine Angular Velocity by taking derivative of angle
ang_savgol = sgolayfilt(Tpole.angfilt,3,9);
ang_vel = diff(ang_savgol);
%ang_vel = diff(angfilt);
ang_vel_filt = sgolayfilt(ang_vel,2,13);

if locs(1) < 6
locs(1) = locs(1)+6;
end

%Get angular velocity from retraction peaks
if l < 6
l(1) = l(1)+6;
end

ang_ret = ang_vel_filt(l-5);
ang_vel_pro = ang_vel_filt(locs-5);
ang_vel_ret = -ang_ret;

%% export the data
Tcurv = table(curve_peak, curve_widths, points);
Tcurv.type(:,1) = {'cuvature'};
Tcurv.Properties.VariableNames = {'peak' 'width_velocity' 'locations_index' 'type'};

Tpro = table(amp_peak_pro, ang_vel_pro, locs);
Tpro.type(:,1) = {'protraction'};
Tpro.Properties.VariableNames = {'peak' 'width_velocity' 'locations_index' 'type'};

Tret = table(amp_peak_ret, ang_vel_ret, l);
Tret.type(:,1) = {'retraction'};
Tret.Properties.VariableNames = {'peak' 'width_velocity' 'locations_index' 'type'};

comboT = [Tcurv; Tpro; Tret];
writetable(comboT, ID_2);