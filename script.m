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
%{
%opcio a) Utilitzar un kmeans, el negre serà el fons
lab_he = rgb2lab(array_name{2,11});
ab = lab_he(:,:,2:3); ab = im2single(ab); nColors = 8; % repeat the clustering 3 times to avoid local minima
pixel_labels = imsegkmeans(ab,nColors,'NumAttempts',3);
imshow(pixel_labels,[]); title('Image Labeled by Cluster Index');
pixel_labels2 = im2bw(pixel_labels,1/255);
imshow(pixel_labels2,[]);


%opcio b) Mirant l'histograma de la imatge
gris=rgb2gray(array_name{2,21});
fontSize = 25;
[rows, columns, numberOfColorChannels] = size(gris);
% Display the image.
subplot(2, 2, 1);
imshow(gris, []);
axis on;
axis image;
caption = sprintf('Original Gray Scale Image');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
drawnow;
hp = impixelinfo();
% Set up figure properties:
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% Get rid of tool bar and pulldown menus that are along top of figure.
% set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off')
drawnow;
% Let's compute and display the histogram.
[pixelCount, grayLevels] = imhist(gris);
subplot(2, 2, 2); 
bar(grayLevels, pixelCount); % Plot it as a bar chart.
grid on;
title('Histogram of original image', 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Gray Level', 'FontSize', fontSize);
ylabel('Pixel Count', 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.
% Binarize the image by thresholding.
mask = gris < 125;
% Display the mask image.
subplot(2, 2, 3);
imshow(mask);
axis on;
axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.
title('Binary Image Mask', 'fontSize', fontSize);
drawnow;
% Get rid of blobs touching the border.
mask = imclearborder(mask);
% Extract just the largest blob.
mask = bwareafilt(mask, 1);
% Display the mask image.
subplot(2, 2, 4);
imshow(mask);
axis on;
axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.
title('Lobster-only Mask', 'FontSize', fontSize);
drawnow;
% Get rid of black islands (holes) in struts without filling large black areas.
subplot(2, 2, 4);
mask = ~bwareaopen(~mask, 1000);
imshow(mask);
axis on;
axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.
title('Final Cleaned Mask', 'FontSize', fontSize);
drawnow;
%}


%opcio c) utilitzant el detector de contorns i omplint els forats de dins - CREC QUE ES LA MILLOR OPCIO
I = rgb2gray(array_name{2,15});
detector = 'Prewitt';%despres de fer vàries proves arribem a la conclusió que el millor detector es el Prewitt amb el valor 0.25
[~,threshold] = edge(I,detector); fudgeFactor = 0.25; BWs = edge(I,detector,threshold * fudgeFactor); %li apliquem el detector Prewitt
se90 = strel('line',3,90); se0 = strel('line',3,0);
BWsdil = imdilate(BWs,[se90 se0]); imshow(BWsdil); title('Dilated Gradient Mask') %fem una dilatació
BWdfill = imfill(BWsdil,'holes'); imshow(BWdfill); title('Binary Image with Filled Holes') %ompliem els forats de dins la peça
BWnobord = imclearborder(BWdfill,4); imshow(BWnobord); title('Cleared Border Image') %treiem els bordes de la peça
seD = strel('diamond',1); BWfinal = imerode(BWnobord,seD); BWfinal = imerode(BWfinal,seD); imshow(BWfinal); title('Segmented Image');%fem l'erode per 'invertir' la dilatació 
%imshow(labeloverlay(I,BWfinal)); title('Mask Over Original Image')

BW2 = bwareaopen(BWfinal, 400); %eliminem les illes que no son la peça
imshowpair(array_name{2,15},BW2,'montage')

%la peça 15 pot donar problemes

%si fem la resolucio 2, la dels costats, utlitzem les imatges amb blanc i negre

%Rotació de la imatge per que estigui recta

figure; imshow(BW2);
disp("selecciona les esquines que estiguin més a dalt i d'esquerra a dreta");
[x,y]=ginput(2);
m1=[x(1) y(1); x(2) y(2)]; %Matriu dels punts de la hipotenusa
m2=[x(1) y(1); x(1) y(2)]; %Matriu dels punts del costat adjacent
h=pdist(m1); %distància de la hipotenusa
a=pdist(m2); %distància del costat adjacent
c=a/h; %calcul del cosinus per mitjà dels costats
rad=acos(c); %Obtenim l'angle en radians amb l'arcosinus
deg=rad2deg(rad); %Passem l'angle a graus
J=imrotate(BW2,-deg,'bilinear','loose'); %Rotem la imatge per ficar-la recta
J90=imrotate(J,-90,'bilinear','loose'); %Rotem la imatge 90 graus
J180=imrotate(J,-180,'bilinear','loose'); %Rotem la imatge 180 graus
J270=imrotate(J,-270,'bilinear','loose'); %Rotem la imatge 270 graus
figure; imshowpair(J,J180,'montage');


%eliminem les linies i columnes que no hi ha cap pixel de peça
[rows, columns] = find(J);
row1 = min(rows);
row2 = max(rows)-row1;
col1 = min(columns);
col2 = max(columns)-col1;
BWretallat = imcrop(J,[col1 row1 col2 row2]); %retallem
figure; imshow(BWretallat); title('Imatge peça retallada')

%detectem el tipus dels costats de les peces
%havia pensat en erosionar la imatge. aixi crec que es podra veure si un
%costat es golf, cap o borde.
BWretallat = imerode(BWretallat,se90);

imshow(BWprova); title('Imatge peça retallada')
