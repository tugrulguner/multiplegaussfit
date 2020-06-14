function [values, gaussdeger, pcasora] = gcfittinglsq(data, xaxis, norm, ZLP, gfit, xtol)
% here data is for your 3D data, xaxis is for corresponding xaxis for data, norm and ZLP you can use if you want to use normalization function
% gfit for gaussian filtering level and xtol is the contraint for intensity tolerance of the gaussian that you put to least square method 
% Created by Tugrul Guner, 2019

data = normZLP(file, xaxis, norm, ZLP);
% You can ignore this function if you are not dealing with EELS spectrum. What it does is simply puts zero-loss peak to 0 eV
% position, normalizes it, and then subtracts from background.

figure
du = permute(data,[3 1 2]);
du = reshape(du,2048,[]);
%du = tanh(du);
% [app, score, lat] = pca(du');
opt = statset('MaxIter',300,'Display','final');
[w, h] = nnmf(du, 10, 'algorithm', 'mult', 'replicates', 10, 'options', opt);
D = h' * w';

% apprd = app(:,1:10);
% scorerd = score(:,1:10);
% D = apprd * scorerd';
% D = D';

xaxiinv = xaxis;
plot(xaxiinv, sum(D,1));
xlabel('eV');
pcasor = input('Is this principal component okay ? ');


while true
    if pcasor == true
        pcasora = 10;
        break
    else
        close all
        clear w h D apprd scorerdr
        pcasora = input('Principal component : ');
        [w, h] = nnmf(du, pcasora, 'algorithm' , 'mult', 'replicates', 10, 'options', opt);
        D = h' * w';
%         apprd = app(:,1:pcasora);
%         scorerd = score(:,1:pcasora);
%         D = apprd * scorerd';
%         D = D';
        xaxiinv = xaxis';
        plot(xaxiinv, sum(D,1));
        xlabel('eV');
        pcasort = input('Is this principal component okay ? ');
        if pcasort == false
            continue
        else
            break
        end
    end
end


close all

%totalsumspec = squeeze(sum(sum(data,1),2));
totalsumspec = sum(D,1);


options = optimset('TolFun', 1e-9, 'MaxFunEvals', 50000, 'MaxIter', 50000, 'Display', 'off');

function g = gag(x, mu, sigma)
    g = exp(-0.5*((x-mu)/sigma).^2);
end

function F  = myfit(x, xdata)
    F = 0;
    len = size(x,2);
    for m = 1:3:len
        F = F + x(m)*gag(xdata, x(m+1), x(m+2));
    end
end


figure
while true
        plot(xaxis, totalsumspec);
        xlabel('eV');
        ZLPsor = input('Do you want ZLP extraction ? ');
        if ZLPsor == true
                zvalues = lsqcurvefit(@myfit, [double(max(totalsumspec)) 0 1], xaxis, double(totalsumspec),[],[],options);
                resultz = myfit(zvalues, xaxis);
                plot(xaxis, resultz, xaxis, totalsumspec)
                xlabel('eV');
                Zcorr = input('Is the ZLP fitting correct ? ');
                if Zcorr == true
                    totalsumspec = totalsumspec - resultz;
                    break
                else
                    continue
                end
         else
            continue
         end
        
end


plot(xaxis, totalsumspec);
xlabel('eV');
araeleman = totalsumspec;        
        
while true
    sorbakalim = input('Do you want to select region to filter ? ');
    if sorbakalim == true
        [sx, sy] = ginput();
        sx, sy
        gf = input('Gauss Filter : ');
        [rrow ccolumn] = find(round(xaxis,1) == round(sx,1));
        totalsumspec(1:ccolumn) = imgaussfilt(totalsumspec(1:ccolumn), gf);
        totalsumspec(1:ccolumn) = 0;
        plot(xaxis, totalsumspec)
        xlabel('eV');
        sorbakalimyine = input('Is this filter okay ? ');
        if sorbakalimyine == true
            gaussdeger = [ccolumn, gf];                
            break
        else
            totalsumspec = araeleman;
            plot(xaxis, totalsumspec);
            continue
        end
    else
        break
    end
end

araeleman = totalsumspec; 

% while true
%     sorbakalimarka = input('Do you want to select region to filter ? ');
%     if sorbakalimarka == true
%         [sxx, syy] = ginput();
%         sxx, syy
%         gff = input('Gauss Filter : ');
%         [rrrow cccolumn] = find(round(xaxis,1) == round(sxx,1));
%         totalsumspec(cccolumn:end) = imgaussfilt(totalsumspec(cccolumn:end), gff);
%         %totalsumspec(cccolumn:end) = 0;
%         plot(xaxis, totalsumspec)
%         xlabel('eV');
%         sorbakalimyinearka = input('Is this filter okay ? ');
%         if sorbakalimyinearka == true
%             gaussdeger = [gaussdeger, cccolumn, gff];                
%             break
%         else
%             totalsumspec = araeleman;
%             plot(xaxis, totalsumspec);
%             continue
%         end
%     else
%         break
%     end
% end

xaxisson = xaxis;

% while true
%    removal = input('Do you want to crop any region ? ');
%    if removal == true
%        [rx, ry] = ginput();
%         rx, ry
%         [rrrow cccolumn] = find(xaxis == round(ry));
%         totalsumspec(1:cccolumn) = [];
%         xaxis(1:cccolumn) = [];
%         removearea = cccolumn;
%         plot(xaxis, totalsumspec)
%         remov = input('Is crop okay ? ');
%         if remov == true
%             break
%         else           
%             totalsumspec = araelemanson;
%             xaxis = xaxisson;
%             plot(xaxis, totalsumspec)
%             continue
%         end
%    
%    else
%        break
%    end
% end

%ZLPgfit = resultz;

totalsumspec = imgaussfilt(totalsumspec, gfit);

while true
    
    peakx = [];
    peaky = [];
    plot(xaxis, totalsumspec);  
    xlabel('eV');
    while true
        peaksor = input('Do you want to add more peaks ? ');
        if peaksor == true
            [px, py] = ginput();
            px, py
            koordsor = input('Are these coordinates okay ? ');
            if koordsor == true
                peakx = [peakx px];
                peaky = [peaky py];
                continue
            else
                continue
            end
        else
            break
        end
    


    end

    x0 = [];
    for l = 1:size(peakx,2)
        x0 = [x0 peaky(l) peakx(l) 1];
    end
    lb = zeros(1,size(x0,2));
    ub = x0;
    for kk = 1:3:size(x0,2)
        
        lb(kk+1) = x0(kk+1) - xtol;
        ub(kk) = 2*x0(kk);
        ub(kk+1) = x0(kk+1) + xtol;
        ub(kk+2) = x0(kk+2) + 9;
        
    end
    
    lb(lb<0) = 0;
    values = lsqcurvefit(@myfit, x0, xaxis, double(totalsumspec),lb,[],options);
    
    plot(xaxis, totalsumspec)
    xlabel('eV');
    hold on
    leny = size(values,2);
    for mm = 1:3:leny
        FF = values(mm)*gag(xaxis, values(mm+1), values(mm+2));
        plot(xaxis, FF);
        hold on
    end   
    result = myfit(values, xaxis);

    plot(xaxis, result)
    xlabel('eV');

    grafsor = input('Is this fitting okay ? ');
    
    if grafsor == true
        close all
        break
    else
        close all
        plot(xaxis, totalsumspec)
        xlabel('eV');
        continue
    end
     
end
    


end
    


