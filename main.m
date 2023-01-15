clc, clear all, close all

path = ".\imagenes\volteada5.jpg";
original   = imread(path);
data = original;
Igray = rgb2gray(data);

%% Calcular rotación

BW = edge(Igray,'canny');
figure, imshow(BW);

[H,theta,rho] = hough(BW);

P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));

angulo = theta(P(end,2));

%Si el angulo es 0 es un poco a suerte si esta a un lado u a otra, habría
%que investigarlo.
if angulo >= 0
    desviacion = 90;
else
    desviacion = -90;
end
Rotado = false;
if abs(angulo) < 86 || abs(angulo) > 94
    %Posiciones originales para escribir ahí
    s2 = getSquares(data);
    data = imrotate(data,angulo -desviacion,'crop');
    ele =  strel('square',4);
    data = imclose(data,ele);
    figure, imshow(data);
    Rotado = true;
    
end


%% Reconocimiento de recuadros

%De aquí leeremos los cuadrados donde estan los numeros en la imagen ya
%horizontal
s = getSquares(data);


%% Reconocimiento de números

umbral = graythresh(data);
Igray = rgb2gray(data);

binary = imbinarize(Igray,umbral);%a binaria

%Eliminamos todo lo que no es un número, es decir, las casillas

BWComplement = ~binary;
%Buscamos todas las componentes conexas de la imagen
CC = bwconncomp(BWComplement);

%Las componentes conexas más grandes, con más pixeles, será el recuadro y
%los bordes en el caso de que la imagen esté rotada mal(se quedan bordes
%negros)
numberPixels = cellfun(@numel, CC.PixelIdxList);
idx = find(numberPixels > 5000);
for i=1: length(idx)
    BWComplement(CC.PixelIdxList{idx(i)}) = 0;
end


%Le indicamos donde tiene que buscar los numeros, es decir, 
%en las casillas que ya hemos calculado
roi = vertcat(s(:).BoundingBox);

%Obtenemos los números de la siguiente imagen
BWComplement = imerode(BWComplement, strel('square',1));
figure, imshow(BWComplement);
results = ocr(BWComplement, roi, 'TextLayout', 'Word','CharacterSet','0':'9');

% Eliminamos los espacios en blanco de los resultados
ce = cell(1,numel(results));
for i = 1:numel(results)
    ce{i} = deblank(results(i).Text);
end

final = insertObjectAnnotation(im2uint8(binary), 'Rectangle', roi, ce);
figure
imshow(final)

%% reconocer serie

%Como le hemos pasado todas las casillas y hay algunas que están vacías
%entonces separamos los números para mejor manejo
numbers = [];
for i=1:numel(results)
    if "" ~= results(i).Text
        numbers = [numbers str2num(results(i).Text)];
    end
end

Nextnumbers = getSeries(numbers);

figure, imshow(original);
title("Resultado final");
hold on;

%% Escribir
if Rotado
    s = s2;
end

for i = length(numbers)+1:length(s)
    a = text(s(i,:).Centroid(1)-30,s(i,:).Centroid(2),string(Nextnumbers(i)));
    set(a,'FontName','Arial','FontWeight','bold','FontSize',28,'Color','black');
    j = j + 1;
end

hold off;
