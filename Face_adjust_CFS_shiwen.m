


clear all
%% sbj & contrast setup
sbj.name       = input('Subject Name? ','s');
CFS_contrast   = 1;
face_contrast0 = 0.4;
tGuess         = 1;%input('Estimate threshold : ');
tGuessSd       = 0.5;%input('Estimate the standard deviation of your guess, above, (e.g. 2): ');




Screen('Preference', 'SkipSyncTests', 1);
whichscreen=max(Screen('Screens'));
stereomode=4;
black=BlackIndex(whichscreen); 
white=WhiteIndex(whichscreen);
gray=round((white-black)/2);
kec=80; %% mac

%% stimuli setup 
onsetT=0.2;
frameRate=60;
prtime=0.2;
pausetime=0.5;
total_trial=300;
[windowPtr, rect]=Screen('OpenWindow',whichscreen,gray,[], [], [],stereomode);
Screen('BlendFunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);



 
%% stimuli make
%Face

face_name={'2_1','2_7','3_1','3_7','4_1','4_7'};

face=[length(face_name),1];

for i=1:length(face_name)
        face_pic=imread(['hfp_face_rsw/',face_name{i},'.jpg']);  
        face_pic=double(face_pic); 
        
        face(i)=Screen('MakeTexture',windowPtr,face_pic);   
        
end  

face_index(:,1)=mod((1:total_trial),length(face_name))+1;
face_index(1:total_trial/2,2)=1;
face_index=face_index(randperm(size(face_index,1)), :);
rect_index=mod(randperm(total_trial),4)+1;
eye_index=mod(randperm(total_trial),2);


%CFS

load CFSMatMovie3.mat
CFSMatMovie=Shuffle(CFSMatMovie);
CFSFrames=100;
CFSTex={CFSFrames,1};
for i=1:CFSFrames
    CFSMatMovie{i} =CFS_contrast*(CFSMatMovie{i}-128)+128;
    CFSImage=CFSMatMovie{i};
    CFSTex{i}=Screen('MakeTexture',windowPtr,CFSImage);
end
CFSFrequency=6;

%CFS alpha

pThreshold=0.9;
beta=3.5;delta=0.01;gamma=0.5;
q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma);
q.normalizePdf=1;

%bg

bgimg=Screen('MakeTexture',windowPtr,imread('background.jpg'));

%rect

rectheight=calculateEccenticH(5,700);
rectwidth=calculateEccenticW(4.2,700);
offset =10; 
offsetrange=5;
bottom_offset=rectwidth/2;
Rect1=[0 0 rectwidth rectheight];
Rect20=CenterRect(Rect1,rect);
Rect200{1}=OffsetRect(Rect20,offset,-offset-rectheight/4);
Rect200{2}=OffsetRect(Rect20,-offset,-offset-rectheight/4);
Rect200{3}=OffsetRect(Rect20,offset,-offset/2-rectheight/4);
Rect200{4}=OffsetRect(Rect20,-offset,-offset/2-rectheight/4);
bgRect=Rect20+[-rectwidth -rectheight rectwidth rectheight];
%% show

Screen('FillRect',windowPtr,gray);
Screen('DrawText',windowPtr,'Click SPACE key when ready',50,80);
Screen('SelectStereoDrawBuffer', windowPtr, 1);
Screen('DrawTexture', windowPtr, bgimg, [],bgRect);
Screen('DrawDots', windowPtr, [(Rect20(1)+Rect20(3))*0.5 (Rect20(2)+Rect20(4))*0.5],4, black, [], 2);

Screen('SelectStereoDrawBuffer', windowPtr, 0);
Screen('DrawTexture', windowPtr, bgimg, [],bgRect);
Screen('DrawDots', windowPtr, [(Rect20(1)+Rect20(3))*0.5 (Rect20(2)+Rect20(4))*0.5],4, black, [], 2);

Screen('Flip', windowPtr);


[keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
while ~(keyCode(44)) %%%spacekey
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
end
WaitSecs(1);

% fixation

Screen('SelectStereoDrawBuffer', windowPtr, 1);
Screen('DrawTexture', windowPtr, bgimg, [],bgRect);
Screen('DrawDots', windowPtr, [(Rect20(1)+Rect20(3))*0.5 (Rect20(2)+Rect20(4))*0.5],4, black, [], 2);

Screen('SelectStereoDrawBuffer', windowPtr, 0);
Screen('DrawTexture', windowPtr, bgimg, [],bgRect );
Screen('DrawDots', windowPtr, [(Rect20(1)+Rect20(3))*0.5 (Rect20(2)+Rect20(4))*0.5],4, black, [], 2);

Screen('Flip', windowPtr);

WaitSecs(1);

press=0; CycleCounter=1;

while CycleCounter<length(face_index)+1
%% have a rest every 'restcount' trials
%     while restcount<CycleCounter
%         restcount=restcount+restcount;
%         Screen('DrawText',windowPtr,'Now,you can have a rest.',50,80);
%         Screen('SelectStereoDrawBuffer', windowPtr, righteye);
%         Screen('DrawTexture', windowPtr, bgimg, [],bgRect);
%         Screen('DrawDots', windowPtr, [(Rect20(1)+Rect20(3))*0.5 (Rect20(2)+Rect20(4))*0.5],8, black, [], 2);
% 
%         Screen('SelectStereoDrawBuffer', windowPtr, lefteye);
%         Screen('DrawTexture', windowPtr, bgimg, [],bgRect );
%         Screen('DrawDots', windowPtr, [(Rect20(1)+Rect20(3))*0.5 (Rect20(2)+Rect20(4))*0.5],8, black, [], 2);
% 
%         Screen('Flip', windowPtr);
%         [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
%         while ~(keyCode(44)) %%%spacekey
%             [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
%         end
%         WaitSecs(1);
%     
%     end


%%    random rect
    
    
     position=rectwidth/2;     
    offset_2=randi(offsetrange)-(offsetrange+1)/2;
    Rect2=Rect200{rect_index(CycleCounter)}+[offset_2 offset_2 offset_2 offset_2];
    if face_index(CycleCounter,2)
        Rect2=OffsetRect(Rect2,position,0);
    else
        Rect2=OffsetRect(Rect2,-position,0);
    end
    Rect3=Rect2+[0 Rect2(2)/2 0 0];
    Rect_bottom=Rect2+[0 rectheight/2 0 0];
    Rect_bottom=OffsetRect(Rect_bottom,randsrc(1,1,[bottom_offset -bottom_offset]),0);
    Rect_CFS=bgRect+[30 Rect2(2)-bgRect(2)+rectheight/2 -30 -30];
    
    
%% show Face 
    

     w=1;
    for i=1:(prtime*frameRate)
    
        if mod(i,CFSFrequency)==0
            w=w+1;
            w=mod(w,CFSFrames)+1;
        end
             
%         contrast =1-QuestQuantile(q);
        if i < onsetT*frameRate
            face_contrast = (1-cos(pi/onsetT/frameRate*i))/2*face_contrast0;
        else
            face_contrast = 0;
        end
        CFS_contrast=QuestQuantile(q);
        
         righteye=eye_index(CycleCounter);
%         righteye=1;
        if righteye==1
            lefteye=0;
        else  
            lefteye=1;
        end
        Screen('SelectStereoDrawBuffer', windowPtr, righteye);
        Screen('DrawTexture', windowPtr, bgimg, [],bgRect);
        Screen('DrawTexture',windowPtr,face(face_index(CycleCounter)),[],Rect2,[],[],face_contrast);
        Screen('DrawDots', windowPtr, [(Rect20(1)+Rect20(3))*0.5 (Rect20(2)+Rect20(4))*0.5],4, black, [], 2);
        
        
     
        Screen('SelectStereoDrawBuffer', windowPtr, lefteye);
        Screen('DrawTexture', windowPtr, bgimg, [],bgRect);
        Screen('DrawTexture',windowPtr,CFSTex{w},[],Rect_CFS,[],[],CFS_contrast);
        Screen('DrawDots', windowPtr, [(Rect20(1)+Rect20(3))*0.5 (Rect20(2)+Rect20(4))*0.5],4, black, [], 2);

        Screen('Flip', windowPtr);
        
        CFS_ResponseMatBlock(CycleCounter,1) = face_index(CycleCounter,1);
        
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        if (keyIsDown == 1)
            PressedKey = find(keyCode>0);
            CurrentKeyCode = PressedKey;
            CFS_ResponseMatBlock(CycleCounter,2) = kec-CurrentKeyCode;%%%left=0;Right=1;
            press=1;
            
            if keyCode(41) %%%% ESC
                outputFileName1 = sprintf('Data/Face_%d_%s_%s_%s_%d%d' ,righteye,sbj.name , date);
                save( sprintf('%s.mat',outputFileName1) , 'CFS_ResponseMatBlock');
                disp('UserBreak');
                Screen('CloseAll'); 
                break;
            end
            break;
        end
      
    end
    
    %% response   
     Screen('SelectStereoDrawBuffer', windowPtr, righteye);
     Screen('DrawTexture', windowPtr, bgimg, [],bgRect);
     Screen('DrawDots', windowPtr, [(Rect20(1)+Rect20(3))*0.5 (Rect20(2)+Rect20(4))*0.5],4, black, [], 2);
     
     Screen('SelectStereoDrawBuffer', windowPtr, lefteye);
     Screen('DrawTexture', windowPtr, bgimg, [],bgRect );
     Screen('DrawDots', windowPtr, [(Rect20(1)+Rect20(3))*0.5 (Rect20(2)+Rect20(4))*0.5],4, black, [], 2);
     
     Screen('Flip', windowPtr);
    

   if ~press
%     tt=GetSecs;
%     while GetSecs<tt+resptime
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    while ~keyIsDown
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    end
        if (keyIsDown == 1)&&press==0
            PressedKey = find(keyCode>0);
            CurrentKeyCode = PressedKey;
            CFS_ResponseMatBlock(CycleCounter,2) = kec-CurrentKeyCode;%%%left=0;Right=1;
            
             press=1;
           
            if keyCode(41) %%%% ESC
                outputFileName1 = sprintf('Data/Face_%d_%s_%s_%s_%d%d' ,righteye, sbj.name , date);
                save( sprintf('%s.mat',outputFileName1) , 'CFS_ResponseMatBlock');
                disp('UserBreak');
                Screen('CloseAll'); 
                break;
            end
%             break;
        end
%     end
   end
    
%     if ~press
%       
%       
%        CFS_ResponseMatBlock(CycleCounter,2) =-1;%%%left=0;Right=1;
%         
%     end
    
%% pause pausetime
    
    ttt=GetSecs;
    while GetSecs<ttt+pausetime
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        if (keyIsDown == 1)&&keyCode(41) %%%% ESC
                outputFileName1 = sprintf('Data/Face_%d_%s_%s_%s_%d%d' ,righteye, sbj.name , date);
                save( sprintf('%s.mat',outputFileName1) , 'CFS_ResponseMatBlock');
                disp('UserBreak');
                Screen('CloseAll'); 
                break;
        end
    end
  
     if CFS_ResponseMatBlock(CycleCounter,2) ==36;
         response=0;
     else
         response=1;
     end
         
    
    
    q=QuestUpdate(q,face_contrast,response);
    
    CFS_ResponseMatBlock(CycleCounter,3)=CFS_contrast;
    
    press=0;
    keyIsDown = 0;
    CycleCounter=CycleCounter+1;
    
end

QuestMean(q)

outputFileName1 = sprintf('Data/Face_%d_%s_%s_%s_%d%d' ,righteye, sbj.name , date);

save( sprintf('%s.mat',outputFileName1) , 'CFS_ResponseMatBlock');

Screen('DrawText', windowPtr, sprintf('Exp is over. thank you.'),  rect(3)*0.25, 100, [130 130 130]);

Screen('Flip', windowPtr);

[keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
while ~(keyCode(44)) %%%spacekey
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
end

Screen('CloseAll'); fclose all; disp('Well')
