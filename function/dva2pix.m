function pixel = dva2pix(dva,eyeScreenDistence,rect,screenHeight);

% 'OpenWindow
pixel = round(tand(dva) * eyeScreenDistence *  rect(4)/screenHeight);