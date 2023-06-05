function pixel = dva2pix(dva,eyeScreenDistence,rect,screenHeight);

pixel = round(tand(dva) * eyeScreenDistence *  rect(4)/screenHeight);