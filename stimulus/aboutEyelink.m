
%% Eyelink
filename_eye='S00';
if isEyelink
    
    screenid=1;
    dummymode=0;

    %Initialize
    el=EyelinkInitDefaults(win);
    if ~EyelinkInit(dummymode,1)           
        fprintf('Eyelink Init aborted.\n');
        cleanup;
        return;
    end

    % [v vs]=Eyelink('GetTrakerVersion');
    % fprintf('Runninig experiment on a "%s" tracker.\n',vs)

    Eyelink('command','link sample data = LEFT,GAZE ,GAZERES,HREF,AREA,PUPIL');
    Eyelink('command','link event data = GAZE ,GAZERES,HREF,AREA,VELOCITY');
    Eyelink('command','link event filter = LEFT,FIXATION,FIXUPDATE,BLINK,SACCADE,MESSAGE,BUTTON');

    Eyelink('command','file sample data = LEFT,GAZE ,GAZERES,HREF,AREA,PUPIL');
    Eyelink('command','file event data = GAZE ,GAZERES,HREF,AREA,VELOCITY');
    Eyelink('Command','file_event_filter = LEFT,FIXATION,FIXUPDATE,BLINK,SACCADE,MESSAGE,BUTTON');

    edfFile=[filename_eye '.edf'];
    open=Eyelink('Openfile',edfFile);
    if open ~=0
        fprintf('Can not open the edfile');
        Eyelink('Shutdown');
        return;
    end

    %Calibrate
    % EyelinkUpdateDefaults(el); what dose this mean?
    EyelinkDoTrackerSetup(el);
    success=EyelinkDoDriftCorrection(el);
    if success~=1
        cleanup;
        return;
    end

    %start recording
    % Eyelink('Command', 'set_idle_mode');what dose this mean?
    Eyelink('startrecording',1,1,1,1);
    eyeused = Eyelink('EyeAvailable');
    % if eyeused==el.BINOCULAR
    %     eyeused==el.LEFT EYE;
    % end
    WaitSecs(0.1);

    while true
        disp('checkrecording');
        error=Eyelink('CheckRecording');
        if (error==0)
            disp('success');
            break;
        end
    end
end

%%
if isEyelink
    if frameK==1
         if stim_type(Ntrial) == 1
             Eyelink('Message','LHit start');
         end
         if stim_type(Ntrial) == 2
            Eyelink('Message','LNMiss start');
         end
         if stim_type(Ntrial) == 3
             Eyelink('Message','LRec start');
         end
         if stim_type(Ntrial) == 4
             Eyelink('Message','RHit start');
         end
         if stim_type(Ntrial) == 5
             Eyelink('Message','RNMiss start');
         end
         if stim_type(Ntrial) == 6
             Eyelink('Message','RRec start');
         end
    end
              
            
if isEyelink
    Eyelink('Message',[num2str(Ntrial) ' end']);  
end

%% stop recording
if isEyelink
    Eyelink('stopRecording');
    Eyelink('command','set_idle_mode');
    WaitSecs(0.5);
    Eyelink('CloseFile')

    try
        fprint('Receiving data file "%s"\n',edfFile);
        status = Eyelink('ReceivingFile');
        if status > 0
            fprintf('ReciveFile status %d\n',status);
        end
        if 2==exist(edfFile,'file')
            fprintf('Data file "%s" can be found in "%s"\n',edfFile,pwd)
        end
    catch
        fprintf('Problem Receiving data file "%s"\n',edfFile);
    end

    Eyelink('ShutDown');
end
