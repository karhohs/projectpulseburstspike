function [out] = CWTFeatureGen(myCWT)
% [] = CWTFeatureGen()
% Input:
%
%
% Output:
% out.cwt(i).features =
%
% Description:
% Can the information from a CWT be transformed into a set of features that
% can be used to distinguish singals from one another? This function will
% create the features that will be used to answer this question.
%
% Other Notes:
%
out(length(myCWT.cwt)).low = [];
for i=1:length(myCWT.cwt)
    lowrng = 1:round(length(myCWT.scales)/3);
    medrng = (lowrng(end)+1):round(length(myCWT.scales)*2/3);
    highrng = (medrng(end)+1):length(myCWT.scales);
    peakinfo = [myCWT.ridgepks(i).ridgepeaks.scaleindex, myCWT.ridgepks(i).ridgepeaks.time, myCWT.ridgepks(i).ridgepeaks.cfs];
    if isempty(peakinfo) %no peaks were found...
        low.num = 0;
        med.num = 0;
        high.num = 0;
        low.meancfs = 0;
        med.meancfs = 0;
        high.meancfs = 0;
        out(i).low = low;
        out(i).med = med;
        out(i).high = high;
        continue;
    end
    peakinfo = sortrows(peakinfo,1);
    lowindtemp = find(peakinfo(:,1)<=lowrng(end),1,'last');
    medindtemp = find((peakinfo(:,1)>lowrng(end))&(peakinfo(:,1)<=medrng(end)),1,'last');
    lowind = zeros(size(myCWT.ridgepks(i).ridgepeaks.scaleindex));
    if ~isempty(lowindtemp)
        lowind(1:lowindtemp) = 1;
    else
        lowindtemp = 0;
    end
    medind = zeros(size(myCWT.ridgepks(i).ridgepeaks.scaleindex));
    if ~isempty(medindtemp)
        medind((lowindtemp+1):medindtemp) = 1;
    else
        medindtemp = lowindtemp;
    end
    highind = zeros(size(myCWT.ridgepks(i).ridgepeaks.scaleindex));
    if (medindtemp+1)<=length(highind)
        highind((medindtemp+1):end) = 1;
    end
    
    lowind = logical(lowind);
    medind = logical(medind);
    highind = logical(highind);
    %count the number of peaks
    low.num = sum(lowind);
    med.num = sum(medind);
    high.num = sum(highind);
    %calculate the average value of these peaks
    cfsarray = peakinfo(:,3);
    if low.num ~= 0
        low.meancfs = mean(cfsarray(lowind));
    else
        low.meancfs = 0;
    end
    if med.num ~=0
        med.meancfs = mean(cfsarray(medind));
    else
        med.meancfs = 0;
    end
    if high.num ~= 0
        high.meancfs = mean(cfsarray(highind));
    else
        high.meancfs = 0;
    end
    out(i).low = low;
    out(i).med = med;
    out(i).high = high;
end
for i=1:length(myCWT.cwt)
    for j=1:length(myCWT.scales)
        ind = myCWT.ridgepks(i).ridgepeaks.scaleindex==myCWT.scales(j);
        if sum(ind)==0
            out(i).scalesmean(j) = 0;
        else
            out(i).scalesmean(j) = mean(myCWT.ridgepks(i).ridgepeaks.cfs(ind));
        end
        out(i).scalesnum(j) = sum(ind);
    end
end
%out.vector = [out.cwt(1).features.low.num, out.cwt(1).features.low.meancfs, out.cwt(1).features.med.num, out.cwt(1).features.med.meancfs, out.cwt(1).features.high.num, out.cwt(1).features.high.meancfs, ...
    %out.cwt(2).features.low.num, out.cwt(2).features.low.meancfs, out.cwt(2).features.med.num, out.cwt(2).features.med.meancfs, out.cwt(2).features.high.num, out.cwt(2).features.high.meancfs, ...
    %out.cwt(3).features.low.num, out.cwt(3).features.low.meancfs, out.cwt(3).features.med.num, out.cwt(3).features.med.meancfs, out.cwt(3).features.high.num, out.cwt(3).features.high.meancfs];