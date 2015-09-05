%-----------------------------------------------------------------------------------------------------------------
%-------------------------------------- TAREA 3 Reconocimiento de Placas en caracteres ASCII ---------------------
%-------------------------------------- Procesamiento Digital de Imágenes-----------------------------------------
%-------------------------------------- Carlos Enrique Agudelo Giraldo carlose.agudelo@udea.edu.co ---------------
%-------------------------------------- CC 1038410721 ------------------------------------------------------------
%-------------------------------------- Pablo Andres Diaz Gomez pandres.diaz@udea.edu.co -------------------------
%-------------------------------------- CC 1214717460 ------------------------------------------------------------
%------------------------------------   Estudiantes Ingeniería de Sistemas  --------------------------------------
%-------------------------------------  Universidad de Antioquia -------------------------------------------------
%-------------------------------------- 10 de Julio 2015--------------------------------------------------------------
%---------------------------------------------------------------------- ------------------------------------------

%-----------------------------------------------------------------------------------------------------------------
%--1. se inicializa el sistema -----------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------

clear all   % limpia el workspace todas las variables
close all   % Cierra todas las ventanas, archivos y procesos abiertos
clc         % Limpia la ventana de comandos

%-----------------------------------------------------------------------------------------------------------------
%--2. Carga de imagen y eliminacion de ruido ---------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------

imagen=imread('Placas\carro (37).jpg'); % lee la imagen.
[fil,col,cap]=size(imagen); % Toma el tamaño de la imagen
[b, a_org] = recortarImagen(imagen, fil,col,cap); % Recorta la imagen reduciendo el ruido en el escenario

%-----------------------------------------------------------------------------------------------------------------
%--3. Primer procesado de la imagen y seleccion del area de interes ----------------------------------------------
%-----------------------------------------------------------------------------------------------------------------

trans = makecform('srgb2cmyk'); % Crea una estructura de transformación del color, convirtiendo de un espacio RGB a cmyk espacio de color 
imagen = applycform(b, trans); % Aplica la transformacion del espacio

im=imagen(:,:,3); % Abstrae los componentes amarillos de la placa con la y de cmyk %imshow(im);
im(find(im<200))=0; % Pone en blanco las partes amarillas de la imagen
im(find(im<0))=255; % Pone en negro el resto de la imagen

BW = im2bw(im); % Binariza la imagen

BW=bwareaopen(BW, 20000); % Elimina los objetos de color blanco con area menos a 20000px

props=regionprops(BW, 'All'); % Obteniene las propiedades de los elementos blancos en la imagen
numeroObjetos=size(props, 1); % Captura el numero de objetos blancos en la imagen

while numeroObjetos>1
    SE=strel('disk', 4); % Transforma  
    BW=imdilate(BW, SE); % Dilata los objetos de color blanco en la imagen
    BW=bwareaopen(BW, 20000); % Elimina los objetos de color blanco con area menor a 20000
    
    SE=strel('disk', 9);
    BW=imerode(BW, SE); % Erosiona los objetos de color blanco en la imagen
    BW=bwareaopen(BW, 20000); % Elimina los objetos de color blanco con area menor a 20000

    props=regionprops(BW, 'All'); % Obteniene las propiedades de los elementos blancos en la imagen
    numeroObjetos=size(props, 1); % Captura el numero de objetos blancos en la imagen
end

%-----------------------------------------------------------------------------------------------------------------
%--4. Se extraen las propiedadesd de los elementos de la imagen --------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------

region = props; % Asigna las propiedades del prop a la variable region.
RectangleOfChoice = region.BoundingBox;
PlateExtent = region.Extent;
RectangleOfChoice(4) = RectangleOfChoice(4)-20; % Remueve 5 pixeles del ancho de la placa para quitar el nombre de la matricula    
PlateStartX = fix(RectangleOfChoice(1));  % Asigna la posicion inicial de la region de la placa en la cordenada x
PlateStartY = fix(RectangleOfChoice(2)); % Asigna la posicion inicial de la region de la placa en la cordenada y
PlateWidth  = fix(RectangleOfChoice(3)); % Asigna el ancho de la region selecionada
PlateHeight = fix(RectangleOfChoice(4)); % Asigna el alto de la region seleccionada
Centroid = region.Centroid; % Asigna el centro de la region seleccionada

%-----------------------------------------------------------------------------------------------------------------
%--5. Extrae la placa de la imagen original ----------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------

if PlateWidth >= PlateHeight*1 
    im4 = imcrop(b, RectangleOfChoice); % Recorta la placa de la imagen inicial en las cordenadas especificadas.
    imp = im4;
    im4 = imresize(im4, [1000 2600]); % Redimensiona la imagen a un tamaño estandar  
   
%-----------------------------------------------------------------------------------------------------------------
%--6. Procesado de la imagen de la placa original ----------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------

    a=rgb2gray(imp); % Convierte la imagen a escala de grises la imagen de la placa
    
    umb_min = 71; % Se define el umbral minimo para la imagen de la placa
    
    c = a*0; % Se crea una matriz con el tamaño de la placa con valores en 0
    ind = find(a < umb_min); % Busca en la matriz que representa la imagen los valores que sean menores al umbral definido
    c(ind) = 255; % Donde estan los valore menores al umbral, cambia a estos por 255
    
    bn= im2bw(c); % Binariza la imagen de la placa
    
%-----------------------------------------------------------------------------------------------------------------
%--7. Extraccion de las letras y numeros de las placas -----------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------
    
    [l,num] = bwlabel(c); % Etiqueta cada uno de los elementos de la imagen
    
    for i=1:num
       d = c*0; % Crea una matriz del tamaño de la placa con valores igual a 0
       ind = find(l == i); % Encuentra las etiquetas de la imagen binarizada y etiquetada
       d(ind) = 255; % Donde encuentra estas etiquetas cambia el valor a 255
       [fil, col] = find(l == i); % Encuentra las etiquetas de la imagen binarizada y etiquetada y toma el tamaño de estos
       fil_min = min(fil(:)); % Toma el valor minimo de la fila de la imagen seleccionada de la placa
       fil_max = max(fil(:)); % Toma el valor maximo de la fila de la imagen seleccionada de la placa
       col_min = min(col(:)); % Toma el valor minimo de la columna de la imagen seleccionada de la placa
       col_max = max(col(:)); % Toma el valor maximo de las fila de de la imagen seleccionada de la placa
       d = imp(fil_min: fil_max, col_min: col_max,:); % Recorta la componente encontrada de la placa de la imagen a color de la placa.
       [t,s] = size(d); % Toma el tamaño de la componente de la placa
       txt = ' '; % Se toma un valor minimo para lo que se va a imprimir
       if t>45 && t<150 
            texto = Reconocedor(d); % Se llama la funcion Reconocedor
            fprintf(texto); % Imprime lo que se retorna de Reconocedor
            imshow(d); % Muestra la imagen que se esta reconociendo
            pause(1); % Tiempor durante el cual se mostrala la imagen anterior
       end       
    end        
end

%------------------------------------------------------------------------------------------------------------------
%------------------------ FINALIZA EL SISTEMA ---------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------