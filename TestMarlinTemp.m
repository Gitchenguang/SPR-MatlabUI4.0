s = serial( 'COM6' , 'BaudRate' , 57600 );
fopen(s);
tic;
MyTemp =[] ;
MyTime =[];
while( toc < 3600*6)

    temp = ReadTemp( s, 9 );
    timenow =toc;
    MyTemp = [ MyTemp ,temp ];
    MyTime = [ MyTime , timenow];
    plot( MyTime, MyTemp );
    pause(1);

end