%Resolució d’un puzzle a partir d’imatges amb peces

%Carreguem les imatges del nostre dataset
final = imread('dat2/final/foto_final.jpeg');

compt = 0;
jpegFiles = dir('dat2/mateix_fons');
for k = 1:length(jpegFiles)
  baseFileName = jpegFiles(k).name;
  if endsWith(baseFileName,".jpeg")
      compt = compt+1;
      fullFileName = fullfile('dat2/mateix_fons', baseFileName);
      fprintf(1, 'Llegint %s\n', fullFileName);
      imageArray = imread(fullFileName);
      peces{compt} = imageArray;
      im_name{compt} = erase(baseFileName,".jpeg");
  end
end
array_name = [im_name; peces]; %tindrem una matriu on a cada columna hi ha el nom de la imatge i la seva matriu 3D

imshow(array_name{2,29});


%treiem el fons de les imatges
%aqui hauriem d'anar mirant metodes per veure quin es el que dona millors resultats
%opcio a)
lab_he = rgb2lab(array_name{2,29});
ab = lab_he(:,:,2:3); ab = im2single(ab); nColors = 8; % repeat the clustering 3 times to avoid local minima
pixel_labels = imsegkmeans(ab,nColors,'NumAttempts',3);
imshow(pixel_labels,[]); title('Image Labeled by Cluster Index');
pixel_labels2 = im2bw(pixel_labels,1/255);
imshow(pixel_labels2,[]);
%opcio b) (No es molt bona)
gris=rgb2gray(array_name{2,29});
gris2=imadjust(gris);
figure;imshow(gris2);
level=graythresh(gris2);
disp(level);
bw=imbinarize(gris2,level);
figure;imshow(bw);

%altres opcions, detectar contorns i mplir lo del mig
