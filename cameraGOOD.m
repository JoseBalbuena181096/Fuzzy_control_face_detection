  
    s = serial('COM10','BaudRate',115200,'DataBits',8);
    fopen(s);
    while 1
    cam=webcamlist;
    cam = webcam('USB2.0 Camera');  
    preview(cam);
    rgbImage = snapshot(cam);
    I = rgb2gray(rgbImage);
    bw = imbinarize(I);
    [y1,x1]=find(bw);
    escala_x=max([x1]);
    escala_y=max([y1]);
    [y,x]=find(bw==0);
    xy=[x,y];
    average=mean(xy)
    imshow(bw);
    hold on;
    plot(average(:,1),average(:,2),'*b');
    a=newfis("control", "mamdani","min",  "max",  "min", "max", "centroid");
    %'centroid' | 'bisector' | 'mom' | 'lom' | 'som' | 'wtaver' | 'wtsum' | character vector | string
    %x
    a=addvar(a,"input","x",[0 escala_x]);
    a=addmf(a,"input",1,"veryleft","trimf",[0 0 0.5*escala_x]);
    a=addmf(a,"input",1,"left","trimf",[0 0.25*escala_x 0.5*escala_x]);
    a=addmf(a,"input",1,"center","trimf",[0 0.5*escala_x escala_x]);
    a=addmf(a,"input",1,"Right","trimf",[0.5*escala_x  0.75*escala_x escala_x]);
    a=addmf(a,"input",1,"veryRight","trimf",[0.5*escala_x  escala_x escala_x]);
    %y
    a=addvar(a,"input","y",[0 escala_y]);
    a=addmf(a,"input",2,"veryleft","trimf",[0 0 0.5*escala_y/2]);
    a=addmf(a,"input",2,"left","trimf",[0 0.25*escala_y 0.5*escala_y]);
    a=addmf(a,"input",2,"center","trimf",[0  0.5*escala_y escala_y]);
    a=addmf(a,"input",2,"right","trimf",[0.5*escala_y 0.75*escala_y escala_y]);
    a=addmf(a,"input",2,"veryright","trimf",[0.5*escala_y escala_y escala_y]);

    a=addvar(a,"output","x_salida",[-22.5 22.5]);
    a=addmf(a,"output",1,"VeryLeft","trimf",[-22.5 -22.5 -7.5]);
    a=addmf(a,"output",1,"Left","trimf",[-15 -7.5 0]);
    a=addmf(a,"output",1,"center","trimf",[-7.5 0 7.5]);
    a=addmf(a,"output",1,"Right","trimf",[0 7.5 15]);
    a=addmf(a,"output",1,"VeryRight","trimf",[7.5 22.5 22.5]);
    %%%
    a=addvar(a,"output","y_salida",[-22.5 22.5]);
    a=addmf(a,"output",2,"VeryLeft","trimf",[-22.5 -22.5 -7.5]);
    a=addmf(a,"output",2,"Left","trimf",[-15 -7.5 0]);
    a=addmf(a,"output",2,"center","trimf",[-7.5 0 7.5]);
    a=addmf(a,"output",2,"Right","trimf",[0 7.5 15]);
    a=addmf(a,"output",2,"VeryRight","trimf",[7.5 22.5 22.5]);
    %TIEMPO
    ruleList = [1 1 1 1 1 1 ;
                1 2 1 2 1 1;
                1 3 1 3 1 1;
                1 4 1 4 1 1;
                1 5 1 5 1 1;
                2 1 2 1 1 1;
                2 2 2 2 1 1;
                2 3 2 3 1 1;
                2 4 2 4 1 1;
                2 5 2 5 1 1;
                3 1 3 1 1 1;
                3 2 3 2 1 1;
                3 3 3 3 1 1;
                3 4 3 4 1 1;
                3 5 3 5 1 1;
                4 1 4 1 1 1;
                4 2 4 2 1 1;
                4 3 4 3 1 1;
                4 4 4 4 1 1;
                4 5 4 5 1 1;
                5 1 5 1 1 1;
                5 2 5 2 1 1;
                5 3 5 3 1 1;
                5 4 5 4 1 1;
                5 5 5 5 1 1     
                ];  
    a=addrule(a,ruleList);
    showrule(a)
    output=evalfis(average,a)
    x1=num2str(output(1))
    y1=num2str(output(2))
    escalaX=num2str(escala_x)
    escalaY=num2str(escala_y)
    enviar=strcat('x',x1,'y',y1,'z')
    fprintf(s,'%s',enviar); 
    clear('cam');
    pause(3)
    end;
    fclose(s);
