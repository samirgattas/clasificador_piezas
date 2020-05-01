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

lee_archivos = dir('C:\Users\samir\Documents\Facultad\IA I\Proyecto Final IA I\Fotos aprendizaje\*.jpg'); %el formato de imagen puede ser modificado. 
%lee_archivos = dir('C:\Users\samir\Documents\Facultad\IA I\Proyecto Final IA I\Fotos aprendizaje1\*.jpg'); %el formato de imagen puede ser modificado. 
excentricidad=zeros(1,length(lee_archivos));
for i=1:length(lee_archivos)    %recorre número de archivos guardados en el directorio
    nombreFotoAprendizaje = lee_archivos(i).name; %Obtiene el nombre de los archivos
    rutaAprendizaje='C:\Users\samir\Documents\Facultad\IA I\Proyecto Final IA I\Fotos aprendizaje\';
    %rutaAprendizaje='C:\Users\samir\Documents\Facultad\IA I\Proyecto Final IA I\Fotos aprendizaje1\'; %Recore el diretorio
    foto = imread(strcat(rutaAprendizaje,nombreFotoAprendizaje));% lee la primera imagen
    fotoBin = im2bw(foto); %procesa imagen a binaria
    %fotoBin = im2bw(foto,0.2); %procesa imagen a binaria
    fotoBinInv = ~fotoBin;    %invierto matriz binaria
    fotoSinPuntos = bwareaopen(fotoBinInv,75); %elimina pixeles aislados
    se=strel('disk',30);
    dilataFoto=imdilate(fotoSinPuntos,se);
%     figure
%     subplot(2,3,1)
%     imshow(foto);
%     title('Imagen original')
%     subplot(2,3,2)
%     imshow(fotoBin)
%     title('Imagen binaria')
%     subplot(2,3,3)
%     imshow(fotoBinInv)
%     title('Imagen binarizada invertida')
%     subplot(2,3,4)
%     imshow(fotoSinPuntos)
%     title('Imagen sin pixeles')
%     subplot(2,3,5)
%     imshow(dilataFoto)
%     title('Imagen dilatada')
%     figure(3)
%     subplot(4,4,i)
%     imshow(foto)

    figure(1)
    subplot(4,4,i);
    imshow(dilataFoto);
    propiedad=regionprops(dilataFoto, 'Eccentricity');
    excentricidad(1,i) = propiedad.Eccentricity;
end

c1=excentricidad(1,1);  %toma el valor del primer elemento 
c1_viejo=0;
c2=excentricidad(1,length(lee_archivos));   %toma valor del ultimo elemento
c2_viejo=0;
distancia=zeros(2,length(lee_archivos));
cercano=zeros(1,length(lee_archivos));
%% Kmeans
while(c1_viejo~=c1&&c2_viejo~=c2)   %recorre el bucle hasta que el centroide encontrado sea igual al anterior
    valorC1=0;
    valorC2=0;
    cantidad =0;
    c1_viejo = c1;
    c2_viejo = c2;
    distancia(1,:) = abs(c1-excentricidad);
    distancia(2,:)=abs(c2-excentricidad);
    for j=1:length(lee_archivos)    %divide en 2 clusters diferenciados con 1 y 0 en matriz cercano
        if distancia(1,j)<distancia(2,j)
            cercano(1,j) = 1;
        else
            cercano(1,j) = 0; 
        end
    end
    for j=1:length(lee_archivos)
        if cercano (1,j) == 1
            cantidad = cantidad + 1;
        end
    end
    for j=1:length(lee_archivos)
        if cercano(1,j)== 1
            valorC1 = valorC1 + excentricidad(1,j);
        else
            valorC2 = valorC2 + excentricidad(1,j);
        end
        c1 = valorC1/cantidad;
        c2 = valorC2/(length(lee_archivos)-cantidad);
    end
end

for i=1:length(lee_archivos)
    subplot(4,4,i)
    if cercano(1,i) == 1
        title('arandela')
    else
        title('clavo')
    end
end
%% Rutina para clasificar imagen
i=0;
while 1
    fin = input('¿Ingresar imagen?\n1-Si\n2-No');
    if fin == 2
        break
    else
        nombreFotoPrueba = input('nombre de archivo: ','s'); %Obtiene el nombre de los archivos
        rutaPrueba='C:\Users\samir\Documents\Facultad\IA I\Proyecto Final IA I\Fotos prueba\'; %Recore el diretorio
        prueba = imread(strcat(rutaPrueba,nombreFotoPrueba));% lee la primera imagen
        pruebaBin = im2bw(prueba);
        %pruebaBin = im2bw(prueba,0.2); %procesa imagen a binaria
        pruebaBinInv = ~pruebaBin;    %invierto matriz binaria
        pruebaSinPuntos = bwareaopen(pruebaBinInv,75); %elimina pixeles aislados
        se=strel('disk',30);
        dilataPrueba=imdilate(pruebaSinPuntos,se);
        propiedad=regionprops(dilataPrueba, 'Eccentricity');
        excentricidadImagen = propiedad.Eccentricity;

%         figure(3)
%         subplot(2,3,1)
%         imshow(prueba);
%         title('Imagen original')
%         subplot(2,3,2)
%         imshow(pruebaBin)
%         title('Imagen binaria')
%         subplot(2,3,3)
%         imshow(pruebaBinInv)
%         title('Imagen binarizada invertida')
%         subplot(2,3,4)
%         imshow(pruebaSinPuntos)
%         title('Imagen sin pixeles')
%         subplot(2,3,5)
%         imshow(dilataPrueba)
%         title('Imagen dilatada')
%         figure(3)
%         subplot(4,4,indice)
%         imshow(foto)

        figure(3)
        subplot(3,4,indice)
        imshow(prueba)
        
        figure(2)
        subplot(3,4,indice)
        imshow(dilataPrueba)
        hold on

%%Knn
        k=3;
        distanciaKnn=zeros(1,length(lee_archivos));
        X=zeros(1,k);
        clavo=0;
        arandela=0;
        distanciaKnn(1,:) = abs(excentricidadImagen-excentricidad);
        for i=1:k
            distanciaMinima = min(distanciaKnn);
            [X]=find(distanciaKnn(1,:)==distanciaMinima);
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
    indice=indice+1;
end

