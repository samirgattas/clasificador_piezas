% Título: Clasificador de piezas metálicas
% Autor: Samir Gattás
% Año de creación: 2016
% Carrera: Ingeniería en Mecatrónica
% Cátedra: Inteligencia Artificial I
% Facultad de Ingeniería - Universidad Nacional de Cuyo

%=========================================================================

clear;
clc;
close all;
indice = 1;

dir_actual = pwd;

%el formato de imagen puede ser modificado.
lee_archivos = dir('**\Fotos aprendizaje\*.jpg'); 

excentricidad = zeros(1,length(lee_archivos));

figure(1)
for i = 1:length(lee_archivos)    
    % Recorre número de archivos guardados en el directorio
    
    % Obtiene nombre y ruta del archivo
    nombreFotoAprendizaje = lee_archivos(i).name; 
    rutaAprendizaje = strcat(dir_actual, '\Fotos aprendizaje\');
     
    [img_procesada, excentricidad(1,i)] = ...
        procesarImagen(rutaAprendizaje, nombreFotoAprendizaje);

    subplot(4,4,i);
    imshow(img_procesada);
end

c1 = excentricidad(1,1);  %toma el valor del primer elemento 
c1_viejo = 0;
c2 = excentricidad(1,length(lee_archivos));   %toma valor del ultimo elemento
c2_viejo = 0;
distancia = zeros(2,length(lee_archivos));
cercano = zeros(1,length(lee_archivos));
%% Kmeans
while(c1_viejo ~= c1) && (c2_viejo ~= c2)   %recorre el bucle hasta que el centroide encontrado sea igual al anterior
    valorC1 = 0;
    valorC2 = 0;
    cantidad = 0;
    c1_viejo = c1;
    c2_viejo = c2;
    distancia(1,:) = abs(c1-excentricidad);
    distancia(2,:) = abs(c2-excentricidad);
    for j = 1:length(lee_archivos)    %divide en 2 clusters diferenciados con 1 y 0 en matriz cercano
        if distancia(1,j) < distancia(2,j)
            cercano(1,j) = 1;
        else
            cercano(1,j) = 0; 
        end
    end
    for j = 1:length(lee_archivos)
        if cercano (1,j) == 1
            cantidad = cantidad + 1;
        end
    end
    for j = 1:length(lee_archivos)
        if cercano(1,j) == 1
            valorC1 = valorC1 + excentricidad(1,j);
        else
            valorC2 = valorC2 + excentricidad(1,j);
        end
        c1 = valorC1 / cantidad;
        c2 = valorC2 / (length(lee_archivos) - cantidad);
    end
end

for i = 1:length(lee_archivos)
    subplot(4,4,i)
    if cercano(1,i) == 1
        title('arandela')
    else
        title('clavo')
    end
end
%% Rutina para clasificar imagen
i = 0;
while 1
    fin = input('¿Ingresar imagen?\n1-Si\n2-No');
    if fin == 2
        break
    else
        nombreFotoPrueba = input('nombre de archivo: ','s'); %Obtiene el nombre de los archivos
        rutaPrueba = strcat(pwd, '\Fotos prueba\');
        
        [dilataPrueba, excentricidadImagen] = ...
            procesarImagen(rutaPrueba, nombreFotoPrueba);
        
        figure(3)
        subplot(3,4,indice)
        imshow(imread(strcat(rutaPrueba,nombreFotoPrueba)))
        
        figure(2)
        subplot(3,4,indice)
        imshow(dilataPrueba)
        hold on

%%Knn
        k = 3;
        distanciaKnn = zeros(1,length(lee_archivos));
        X = zeros(1,k);
        clavo = 0;
        arandela = 0;
        distanciaKnn(1,:) = abs(excentricidadImagen-excentricidad);
        for i = 1:k
            distanciaMinima = min(distanciaKnn);
            [X] = find(distanciaKnn(1,:) == distanciaMinima);
            distanciaKnn(X) = 10e6;
            if cercano(X) == 1
                arandela = arandela + 1;
            else
                clavo = clavo + 1;
            end
        end
        figure(2)
        if arandela > clavo
            subplot(3,4,indice)
            title('arandela');
        else
            subplot(3,4,indice)
            title('clavo');
        end
    end
    indice = indice + 1;
end


%% FUNCIONES
function [d, e] = procesarImagen(ruta, nombre)
img = imread(strcat(ruta, nombre));
imgBin = im2bw(img);
imgBinInv = ~imgBin;    %invierto matriz binaria
imgSinPuntos = bwareaopen(imgBinInv,75); %elimina pixeles aislados
se = strel('disk',30);
imgDilatada = imdilate(imgSinPuntos,se);
propiedad = regionprops(imgDilatada, 'Eccentricity');
excentricidadImg = propiedad.Eccentricity;

d = imgDilatada;
e = excentricidadImg;
end