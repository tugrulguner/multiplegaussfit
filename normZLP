function data = normZLP(data, xaxis, norm, ZLP)
% This function centers, normalizes and corrects the EELS spectrum by subtracting it from its background.
% data is for your 3D EELS data, xaxis is the corresponding xaxis, norm is for normalization parameter
% ('1' is for normalization based on total electron count, '2' for norm. wrt ZLP area, and '3' for norm. wrt to max. intensity),
% and ZLP is for to center the zero-loss peak signal to 0 eV if it is true or not if it is false
% Created by Tugrul Guner, 2019.

rowx = find(xaxis == 0);
f = waitbar(0, 'Process is starting...');
% 
% figure
for i = 1:1:size(data,1)
    for j = 1:1:size(data,2)
        if norm == 1
        data(i,j,:) = data(i,j,:)./sum(data(i,j,:));
        end
        if norm == 2
        sss(:) = data(i,j,:); 
        ff = @(x,xdata)x(1)*exp(-((xdata-x(2))./x(3)).^2);
        a = lsqcurvefit(ff,[double(max(sss)) double(rowx) 1], double(xaxis((rowx-20):(rowx+20))), double(sss((rowx-20):rowx+20)));
        fitfunc = a(1)*exp(-((xaxis-a(2))./a(3)).^2);
        area = sum(fitfunc);
        data(i,j,:) = data(i,j,:)./area;
        end
        if norm == 3
        data(i,j,:) = data(i,j,:)./max(data(i,j,:));
        end
        if ZLP == true
        row = find(data(i,j,:) == max(data(i,j,:)));
        dataara(:) = data(i,j,:);
        if row<rowx
        data(i,j,1:(rowx-row)) = 0;
        data(i,j,((rowx-row)+1):size(xaxis,2)) = dataara(1:(size(xaxis,2)-(rowx-row)));
        end
        if row == rowx
            continue
        end
        if row>rowx
        data(i,j,1:(size(xaxis,2)-(row-rowx))) = dataara((row-rowx+1):(size(xaxis,2)));
        data(i,j,(size(xaxis,2)-(row-rowx)):size(xaxis,2)) = 0;
        end
        end
        data(i,j,:) = data(i,j,:) - mean(data(i,j,1:20));
        %spec(:) = data(i,j,:);
        %data(i,j,:) = tailfit(xaxis, spec);
        %clear spec
        %spec(:) = data(i,j,:);
        %data(i,j,:) = deconvlucy(spec, gaussmf(xaxis,[3, 0]));
        waitbar(((i-1)*size(data,2)+j)/(size(data,1)*size(data,2)),f,['Processing...', '%', num2str(round(100*((i-1)*size(data,2)+j)/(size(data,1)*size(data,2))))]);
    end
end

