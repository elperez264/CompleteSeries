function s = getSquares(data)

    % Primero pasamos la imagen a binaria con el umbral para poder usarla bien
    % en las siguientes operaciones
    umbral = graythresh(data);
    Igray = rgb2gray(data);
    binary = imbinarize(Igray,umbral);%a binaria
    
    %Tapa los agujeros para que no pille un hueco dentro(apertura de area)
    
    diff_im = bwareaopen(binary, 300);%elimina componentes conectadas con menos de p pixeles
    
    s = regionprops(diff_im, 'BoundingBox','Centroid','Area');
    %Eliminamos el primer rectangulo que siempre es el borde de toda la imagen
    s = s(2:end);
end