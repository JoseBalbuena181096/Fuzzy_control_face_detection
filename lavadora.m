a=newfis("Lavadora", "mamdani","min",  "max",  "prod", "max", "centroid");
%'centroid' | 'bisector' | 'mom' | 'lom' | 'som' | 'wtaver' | 'wtsum' | character vector | string
%PESO
a=addvar(a,"input","peso",[0 20]);
a=addmf(a,"input",1,"liviano","trimf",[0 0 10]);
a=addmf(a,"input",1,"normal","trimf",[0 10 20]);
a=addmf(a,"input",1,"pesado","trimf",[10 20 20]);
%SUCIEDAD
a=addvar(a,"input","suciedad",[0 20]);
a=addmf(a,"input",2,"LS","trimf",[0 0 10]);
a=addmf(a,"input",2,"NS","trimf",[0 10 20]);
a=addmf(a,"input",2,"HS ","trimf",[10 20 20]);
%VELOCIDAD
a=addvar(a,"output","velocidad",[0 100]);
a=addmf(a,"output",1,"baja","trimf",[0 0 25]);
a=addmf(a,"output",1,"medioBajo","trimf",[0 25 50]);
a=addmf(a,"output",1,"medio","trimf",[25 50 75]);
a=addmf(a,"output",1,"medioAlto","trimf",[50 75 100]);
a=addmf(a,"output",1,"alto","trimf",[75 100 100]);
%TIEMPO
a=addvar(a,"output","tiempo",[0 30]);
a=addmf(a,"output",2,"t1","trimf",[0 0 7.5]);
a=addmf(a,"output",2,"t2","trimf",[0 7.5 15]);
a=addmf(a,"output",2,"t3","trimf",[7.5 15 22.5]);
a=addmf(a,"output",2,"t4","trimf",[15 22.5 30]);
a=addmf(a,"output",2,"t5","trimf",[22.5 30 30]);

ruleList = [1 1 1 1 1 1 ;
            1 2 2 2 1 1;
            1 3 3 3 1 1;
            2 1 2 3 1 1;
            2 2 3 3 1 1;
            2 3 4 4 1 1;
            3 1 3 3 1 1;
            3 2 4 4 1 1;
            3 3 5 5 1 1];
a=addrule(a,ruleList);
showrule(a)
inputs = [5 15];
output=evalfis(inputs,a)
plotfis(a)
