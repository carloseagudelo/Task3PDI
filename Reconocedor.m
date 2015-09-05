%--------------------------------------------------------------------------
%------- TAREA 3 Reconocimiento de Placas en caracteres ASCII -------------
%------- Procesamiento Digital de Iágenes----------------------------------
%------- Por: Carlos Enrique Agudelo Giraldo carloskikea@gmail.com --------
%------------ Pablo Andres Diaz Gomez pandigoo@gmail.com ------------------
%------- Estudiantes Ingeniería de Sistemas  ----------------------------
%-------  Universidad de Antioquia ----------------------------------------
%------- 24 Mayo 2015------------------------------------------------------
%--------------------------------------------------------------------------

%Funcion que reconoce una imagen de letra o numero entregada como
%parametro, en una un caracter ASCII
function text = Reconocedor(d)
  
    vec = ['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
    text=' '; % Se inicializa un valor para la variable de retorno
    [x,y] = size(vec); % Se toma el tamano del vector
    dgris=rgb2gray(d); % Convierte la imagen a escala de grises la imagen entrada como parametro
    dgris = imresize(dgris, [100 60]); % Redimensiona la imagen a un tamaño estandar 
    pr = 'Caracteres\'; % Se arma el caracter que llamara la imagen
    ter='_'; % Se arma el caracter que llamara la imagen
    qui = '.png'; % Se arma el caracter que llamara la imagen
    for m=1:y % Se inicia el ciclo para recorrer las imagenes de prueba
        for l=1:14  % Se inicia el ciclo para recorrer las imagenes de prueba
            seg = vec(m); % Se guara el caracter sobre el que esta iterando el sistema en el vector 'vec'
            cuar = int2str(l); % Se convierte a String el iterador l para poder hacer la concatenacion siguiente
            im = strcat(pr,seg,ter,cuar,qui); % Se concatena las partes con el fin de unir la frase
            imag = imread(im); % Se carga la imagen a comparar
            imagris = rgb2gray(imag); % Se convierte a escala de grises la imagen a comparar
            imagris = imresize(imagris, [100 60]); % Redimensiona la imagen a un tamaño definido para hacer la correlación 
            r = corr2(dgris,imagris); % Se obtiene el valor de la correlacion entre las imagenes
            if r > 0.74
                text = seg; % Si el valor de la correlacion es mayor a 0,74 se almacena el valor del vector en el iterador
                return
            end            
        end
    end
end