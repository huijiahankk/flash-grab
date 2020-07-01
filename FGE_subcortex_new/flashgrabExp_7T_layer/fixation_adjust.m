%the programm is used to adjust the fixation which could see in far
%vertical meridian(y-oritation).press 1/2 to adjust the fixaiton,
%press 3 to  confirm the position.
%the data is saved in the "location of fixation.ini"
%1st row is x-postion, 2nd row is y-postion.

%writed by chengwen, 2016/09

function fixation_adjust

gray=127.5;
whichScreen=max(Screen('Screens'));
wptr1 = Screen('OpenWindow', whichScreen,gray,[]);
wrect=Screen('Rect',wptr1);
fixationSize=min(wrect(3),wrect(4))*3/100;
txtSize=floor(fixationSize);
if ~mod(fixationSize,2)
    fixationSize=fixationSize+1;
end

if exist(['Location_of_Fixation.ini'],'file')
    fid=fopen(['Location_of_Fixation.ini'],'r');
    if fid~=-1
        tline=fgetl(fid);
        fixation_center_x = str2num(tline);
        tline=fgetl(fid);
        fixation_center_y = str2num(tline);
    end
    fclose(fid);
else
    error(['Can not open file : Location_Of_Fixation.ini']);
end

Screen('DrawLine',wptr1,0,fixation_center_x - fixationSize/2,fixation_center_y,fixation_center_x + fixationSize/2,fixation_center_y,3);
Screen('DrawLine',wptr1,0,fixation_center_x,fixation_center_y - fixationSize/2,fixation_center_x,fixation_center_y + fixationSize/2,3);

while(1)
    [keyIsDown,~,keyCode ]=KbCheck(-1);
    if keyIsDown
        if keyCode(KbName('1!'))
            fixation_center_y = fixation_center_y +5;
            WaitSecs(0.1);
        end
        if keyCode(KbName('2@'))
            fixation_center_y = fixation_center_y -5;
            WaitSecs(0.1);
        end
        if keyCode(KbName('3#'))
            WaitSecs(0.5)
            Screen('DrawLine',wptr1,0,fixation_center_x - fixationSize/2,fixation_center_y,fixation_center_x + fixationSize/2,fixation_center_y,3);
            Screen('DrawLine',wptr1,0,fixation_center_x,fixation_center_y - fixationSize/2,fixation_center_x,fixation_center_y + fixationSize/2,3);
            Screen('Flip',wptr1);
            break;
        end
    end
    Screen('DrawLine',wptr1,0,fixation_center_x - fixationSize/2,fixation_center_y,fixation_center_x + fixationSize/2,fixation_center_y,3);
    Screen('DrawLine',wptr1,0,fixation_center_x,fixation_center_y - fixationSize/2,fixation_center_x,fixation_center_y + fixationSize/2,3);
    
    Screen('Flip',wptr1);
    
end

% change Data of fixation

if exist(['Location_of_Fixation.ini'],'file')
    fid=fopen(['Location_of_Fixation.ini'],'w');
    if fid~=-1
        fprintf(fid,'%s\n',num2str(fixation_center_x));
        fprintf(fid,'%s\n',num2str(fixation_center_y));
    end
    fclose(fid);
else
    error(['Can not open file : Location_Of_Fixation.ini']);
end
GetClicks;
sca;

end

