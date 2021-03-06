function [spectd, specorj, specextd, outimage, imspectd, resultd, valuestd, values] = EELSmapping_TG(file, xaxis, norm, ZLP, gfit, xtol)
% Mapping of 3D spectral data to 2D image function using pre-determined Gaussian peaks. Created by Tugrul Guner, 2019.

data = normZLP(file, xaxis, norm, ZLP);

[values, gaussdeger, pcasora] = gcfittinglsq(file, xaxis, norm, ZLP, gfit, xtol);
%[values, gaussdeger] = gcfittinglsq(file, xaxis, norm, ZLP, gfit);

du = permute(data,[3 1 2]);
du = reshape(du,2048,[]);
% app = pca(du');
opt = statset('MaxIter',300);
[w, h] = nnmf(du, pcasora, 'algorithm', 'mult', 'replicates', 10, 'options', opt);
D = h' * w';
specdata = reshape(D, size(data,1), size(data,2), []);
clear data
data = specdata;
f = waitbar(0, 'Calculations are starting: ');

for i = 1:1:size(data,1)
    for j = 1:1:size(data,2)
        spec(:) = data(i,j,:);
        specorj(i,j,1) = {spec};
        %spec = abs(app(:,1))'.*spec;
        %specmultip(i,j,1) = {spec};
        [areas, specout, specext, imspec, results, valpos, valamp] = gcfitting(spec, xaxis, values, gaussdeger, gfit, xtol);
        title(['x: ' num2str(j) ', y: ' num2str(i)])
        spectd(i,j,1) = {specout};
        resultd(i,j,1) = {results};
        imspectd(i,j,1) = {imspec};
        valuestd(i,j,:) = {valpos, valamp};
        specextd(i,j,1) = {specext};
        waitbar((i*size(data,2)+j)/(size(data,1)*size(data,2)), f, [num2str(round((i*100*size(data,2)+j)/(size(data,1)*size(data,2)))) '%'])
        for a = 1:1:size(areas,2)
            outimage(i,j,a) = areas(a);
        end
    end
end



% figure

% rectangle('Position',[ev 0 evwidth 0.04])
% hold on
% plot(xaxi,spec)
% spec(:) = data(1,1,:);
% specs(:) = data(45,45,:);
% specss(:) = data(70,70,:);
% 
% plot(spec, specs, 'ro', spec, specss, 'ob')
% % deneme = deconvlucy(xaxi,spec,iter,2.5);
% % plot(xaxi,deneme./max(deneme), xaxi, spec./max(spec))
% xlabel('eV')
% ylabel('First Principal Component')
% xlim([-5 50])
% ylim([-1*10^-4 15*10^-4])
% %imtool(outimage)
% 
db =  1;
for lm = 1:1:size(outimage,3)
figure
imagesc(outimage(:,:,lm))
colormap(gca, 'jet')
% caxis([0.01 0.053])
xlabel('x nm')
ylabel('y nm')
title(['yaxis : ' int2str(values(db)) ', xaxis : ' int2str(values(db+1))])
db = db + 3;
end

