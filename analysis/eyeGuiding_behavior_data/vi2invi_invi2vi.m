% for normal participant blindspot/artificial scotoma experiment
% with random block number because if the subject gaze out of the fixation
% for more than 2 sec the whole block would abandoned and add a new block

clear all;
addpath '../../function';

eachtrial = 'y';  % 'y' mean for single subject plot eachtrial  'n' for draw each subject's ave illusion
barOnlyDraw = 'y'; % 'n' means bar only measurements was subtracted from all conditions
annulusPattern = 'sector';  %  blurredBoundary   sector
annulusWidth = 'CB'; % blindspot   artificialScotoma


sbjnames = {'yufengqi'}; % 'mali' 'maguangquan'  'wutianjiang' 'yufengqi'  %%%'xs','sry', 'hbb','hjh', 'xs','lxy'，'zcx','hyx'
path = strcat('../../data/corticalBlindness/Eyelink_guiding/',annulusPattern,'/',annulusWidth,'/');


visualField = 'l'; % u for upper l for lower


upperExp = {'_vi2invi_u','_invi2vi_u'}; %  '_vi2invi_u','_invi2vi_u'
lowerExp = {'_vi2invi_l','_invi2vi_l',}; % '_vi2invi_l','_invi2vi_l',


for sbjnum = 1:length(sbjnames)
    
    if sbjnum == 1
        datapath = sprintf([path  '%s/'],sbjnames{sbjnum});
        cd(datapath);
    else
        cd(strcat(sbjnames{sbjnum},'/'));
    end
    
    if strcmp(visualField,'u')
        %----------------------------------------------------------------------
        %        restore  upper visual field data
        %----------------------------------------------------------------------
        for expcondition = 1:length(upperExp)
            s1 = sbjnames(sbjnum);
            s2 = string(upperExp(expcondition));
            s3 = '*.mat';
            s4 = strcat(s1,s2,s3);
            
            Files = dir(s4);
            load (Files.name);
            
            validTrialIndex = find(perceived_location ~= 0);
            illusionCCWIndex = [];
            illusionCWIndex = [];
            

            % only 'invi2vi' have perceived_location data   'vi2invi' for
            % first subjects didn't have perceived_location data

            for i = 1:length(validTrialIndex)
                
                if data.flashTiltDirectionMat(validTrialIndex(i)) == 1
                    illusionCCWIndex = [illusionCCWIndex,validTrialIndex(i)];
                elseif data.flashTiltDirectionMat(validTrialIndex(i)) == 2
                    illusionCWIndex = [illusionCWIndex,validTrialIndex(i)];
                end
            end
            
            if strcmp(annulusPattern,'blurredBoundary')
                boundary_CCW_u(expcondition,:) = 90 - boundary(illusionCCWIndex);
                boundary_CW_u(expcondition,:) = 90 - boundary(illusionCWIndex);
            end
            
            bar_only_u(expcondition,:) = 90 - bar_only(validTrialIndex);
            off_sync_CCW_u(expcondition,:)  = 90 - off_sync(illusionCCWIndex);
            off_sync_CW_u(expcondition,:)  = 90 - off_sync(illusionCWIndex);
            flash_grab_CCW_u(expcondition,:)  = 90 - flash_grab(illusionCCWIndex);
            flash_grab_CW_u(expcondition,:)  = 90 - flash_grab(illusionCWIndex);
            perceived_location_CCW_u(expcondition,:)  = 90 -  perceived_location(illusionCCWIndex);
            perceived_location_CW_u(expcondition,:)   = 90 -  perceived_location(illusionCWIndex);

        end
        
        if strcmp(barOnlyDraw,'n')
            bar_only_u_ave = mean(mean(bar_only_u));
            bar_only_u_ave_temp = bar_only_u_ave;
        elseif strcmp(barOnlyDraw,'y')
            bar_only_u_ave = 0;
        end
        
        bar_only_u_ave_temp(sbjnum) = mean(mean(bar_only_u));
        off_sync_CCW_u_ave(sbjnum)  = mean(mean(off_sync_CCW_u)) - bar_only_u_ave;
        off_sync_CW_u_ave(sbjnum)  = mean(mean(off_sync_CW_u)) - bar_only_u_ave;
        if strcmp(annulusPattern,'blurredBoundary')
            boundary_CCW_u_ave(sbjnum) = mean(mean(boundary_CCW_u)) - bar_only_u_ave;
            boundary_CW_u_ave(sbjnum) = mean(mean(boundary_CW_u)) - bar_only_u_ave;
        end
        flash_grab_CCW_u_ave(sbjnum)  = mean(mean(flash_grab_CCW_u)) - bar_only_u_ave;
        perceived_location_CCW_u_ave(sbjnum)  = mean(mean(perceived_location_CCW_u)) - bar_only_u_ave;
        flash_grab_CW_u_ave(sbjnum)  = mean(mean(flash_grab_CW_u)) - bar_only_u_ave;
        perceived_location_CW_u_ave(sbjnum)  = mean(mean(perceived_location_CW_u)) - bar_only_u_ave;
        
        
        bar_only_u_sbj_mean = mean(bar_only_u_ave_temp);
        off_sync_CCW_u_sbj_mean = mean(off_sync_CCW_u_ave);
        off_sync_CW_u_sbj_mean = mean(off_sync_CW_u_ave);
        if strcmp(annulusPattern,'blurredBoundary')
            boundary_CCW_u_sbj_mean = mean(boundary_CCW_u_ave);
            boundary_CW_u_sbj_mean = mean(boundary_CW_u_ave);
        end
        flash_grab_CCW_u_sbj_mean = mean(flash_grab_CCW_u_ave);
        perceived_location_CCW_u_sbj_mean = mean(perceived_location_CCW_u_ave);
        flash_grab_CW_u_sbj_mean = mean(flash_grab_CW_u_ave);
        perceived_location_CW_u_sbj_mean = mean(perceived_location_CW_u_ave);
        
        
        % the first row of 'bar_only_u' is for 'upperExp =
        % {'_vi2invi_u','_invi2vi_u'}; '  upperExp(1) so it is vi2invi 
        eachtrial_bar_only_u = reshape(bar_only_u,1,numel(bar_only_u)) - bar_only_u_ave;
        eachtrial_off_sync_CCW_u = reshape(off_sync_CCW_u,1,numel(off_sync_CCW_u)) - bar_only_u_ave;
        eachtrial_off_sync_CW_u = reshape(off_sync_CW_u,1,numel(off_sync_CW_u)) - bar_only_u_ave;
        eachtrial_flash_grab_CCW_u= reshape(flash_grab_CCW_u,1,numel(flash_grab_CCW_u)) - bar_only_u_ave;
        eachtrial_perceived_location_CCW_u = reshape(perceived_location_CCW_u,1,numel(perceived_location_CCW_u)) - bar_only_u_ave;
        eachtrial_flash_grab_CW_u = reshape(flash_grab_CW_u,1,numel(flash_grab_CW_u)) - bar_only_u_ave;
        eachtrial_perceived_location_CW_u = reshape(perceived_location_CW_u,1,numel(perceived_location_CW_u)) - bar_only_u_ave;
        
        
    elseif strcmp(visualField,'l')
        %----------------------------------------------------------------------
        %        restore  lower visual field data
        %----------------------------------------------------------------------
        for expcondition = 1:length(lowerExp)
            s1 = sbjnames(sbjnum);
            s2 = string(lowerExp(expcondition));
            s3 = '*.mat';
            s4 = strcat(s1,s2,s3);
            
            Files = dir(s4);
            load (Files.name);
            
            validTrialIndex = find(perceived_location ~= 0);
            illusionCCWIndex = [];
            illusionCWIndex = [];
            
            for i = 1:length(validTrialIndex)
                
                if data.flashTiltDirectionMat(validTrialIndex(i)) == 1
                    illusionCCWIndex = [illusionCCWIndex,validTrialIndex(i)];
                elseif data.flashTiltDirectionMat(validTrialIndex(i)) == 2
                    illusionCWIndex = [illusionCWIndex,validTrialIndex(i)];
                end
            end
            
            
            if strcmp(annulusPattern,'blurredBoundary')
                boundary_CCW_l(expcondition,:) = boundary(illusionCCWIndex) - 90;
                boundary_CW_l(expcondition,:) = boundary(illusionCWIndex) - 90;
            end
            
            bar_only_l(expcondition,:)  = bar_only(validTrialIndex) - 90;
            off_sync_CCW_l(expcondition,:)  = off_sync(illusionCCWIndex) - 90;
            off_sync_CW_l(expcondition,:)  = off_sync(illusionCWIndex) - 90;
            flash_grab_CCW_l(expcondition,:)  = flash_grab(illusionCCWIndex) - 90;
            flash_grab_CW_l(expcondition,:)  = flash_grab(illusionCWIndex) - 90;
            perceived_location_CCW_l(expcondition,:)  = perceived_location(illusionCCWIndex) - 90;
            perceived_location_CW_l(expcondition,:)   = perceived_location(illusionCWIndex) - 90;
        end
        
        if strcmp(barOnlyDraw,'n')
            bar_only_l_ave = mean(mean(bar_only_l));
            bar_only_l_ave_temp = bar_only_l_ave;
        elseif strcmp(barOnlyDraw,'y')
            bar_only_l_ave = 0;
        end
        
        bar_only_l_ave_temp(sbjnum)  = mean(mean(bar_only_l));
        off_sync_CCW_l_ave(sbjnum)  = mean(mean(off_sync_CCW_l)) - bar_only_l_ave;
        off_sync_CW_l_ave(sbjnum)  = mean(mean(off_sync_CW_l)) - bar_only_l_ave;
        if strcmp(annulusPattern,'blurredBoundary')
            boundary_CCW_l_ave(sbjnum) = mean(mean(boundary_CCW_l)) - bar_only_l_ave;
            boundary_CW_l_ave(sbjnum) = mean(mean(boundary_CW_l)) - bar_only_l_ave;
        end
        flash_grab_CCW_l_ave(sbjnum)  = mean(mean(flash_grab_CCW_l)) - bar_only_l_ave;
        perceived_location_CCW_l_ave(sbjnum)  = mean(mean(perceived_location_CCW_l)) - bar_only_l_ave;
        flash_grab_CW_l_ave(sbjnum)  = mean(mean(flash_grab_CW_l)) - bar_only_l_ave;
        perceived_location_CW_l_ave(sbjnum)  = mean(mean(perceived_location_CW_l)) - bar_only_l_ave;
        
        bar_only_l_sbj_mean = mean(bar_only_l_ave_temp);
        off_sync_CCW_l_sbj_mean = mean(off_sync_CCW_l_ave);
        off_sync_CW_l_sbj_mean = mean(off_sync_CW_l_ave);
        if strcmp(annulusPattern,'blurredBoundary')
            boundary_CCW_l_sbj_mean = mean(boundary_CCW_l_ave);
            boundary_CW_l_sbj_mean = mean(boundary_CW_l_ave);
        end
        flash_grab_CCW_l_sbj_mean = mean(flash_grab_CCW_l_ave);
        perceived_location_CCW_l_sbj_mean = mean(perceived_location_CCW_l_ave);
        flash_grab_CW_l_sbj_mean = mean(flash_grab_CW_l_ave);
        perceived_location_CW_l_sbj_mean = mean(perceived_location_CW_l_ave);
        
        eachtrial_bar_only_l = reshape(bar_only_l,1,numel(bar_only_l)) - bar_only_l_ave;
        eachtrial_off_sync_CCW_l = reshape(off_sync_CCW_l,1,numel(off_sync_CCW_l)) - bar_only_l_ave;
        eachtrial_off_sync_CW_l = reshape(off_sync_CW_l,1,numel(off_sync_CW_l)) - bar_only_l_ave;
        if strcmp(annulusPattern,'blurredBoundary')
            eachtrial_boundary_CCW_l = reshape(boundary_CCW_l,1,numel(boundary_CCW_l)) - bar_only_l_ave;
            eachtrial_boundary_CW_l = reshape(boundary_CW_l,1,numel(boundary_CW_l)) - bar_only_l_ave;
        end
        eachtrial_flash_grab_CCW_l= reshape(flash_grab_CCW_l,1,numel(flash_grab_CCW_l)) - bar_only_l_ave;
        eachtrial_perceived_location_CCW_l = reshape(perceived_location_CCW_l,1,numel(perceived_location_CCW_l)) - bar_only_l_ave;
        eachtrial_flash_grab_CW_l = reshape(flash_grab_CW_l,1,numel(flash_grab_CW_l)) - bar_only_l_ave;
        eachtrial_perceived_location_CW_l = reshape(perceived_location_CW_l,1,numel(perceived_location_CW_l)) - bar_only_l_ave;
        
    end
    
    cd ../
    
end

%----------------------------------------------------------------------
%    draw upper visual field data
%----------------------------------------------------------------------
if strcmp(visualField,'u')
    if strcmp(barOnlyDraw,'y')
        if strcmp(annulusPattern,'blurredBoundary')
            y_u = [bar_only_u_sbj_mean off_sync_CCW_u_sbj_mean off_sync_CW_u_sbj_mean boundary_CCW_u_sbj_mean boundary_CW_u_sbj_mean ...
                flash_grab_CCW_u_sbj_mean perceived_location_CCW_u_sbj_mean flash_grab_CW_u_sbj_mean perceived_location_CW_u_sbj_mean];
        else
            
            y_u = [bar_only_u_sbj_mean off_sync_CCW_u_sbj_mean off_sync_CW_u_sbj_mean flash_grab_CCW_u_sbj_mean...
                perceived_location_CCW_u_sbj_mean flash_grab_CW_u_sbj_mean perceived_location_CW_u_sbj_mean];
        end
    elseif strcmp(barOnlyDraw,'n')
        y_u = [off_sync_CCW_u_sbj_mean off_sync_CW_u_sbj_mean flash_grab_CCW_u_sbj_mean...
            perceived_location_CCW_u_sbj_mean flash_grab_CW_u_sbj_mean perceived_location_CW_u_sbj_mean];
    end
    
    
    
    h_u = bar(y_u,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
    hold on;
    %----------------------------------------------------------------------
    %    draw each trial for upper visual field
    %----------------------------------------------------------------------
    if strcmp(eachtrial,'y')
        if strcmp(barOnlyDraw,'n')
            drawEachLoca = 0;
        elseif strcmp(barOnlyDraw,'y')
            drawEachLoca = 1;
%             for condition = 1: length(eachtrial_bar_only_u)
                plot(drawEachLoca + randn/10,eachtrial_bar_only_u(1:numel(eachtrial_bar_only_u)/2),'r--o');
                plot(drawEachLoca + randn/10,eachtrial_bar_only_u(numel(eachtrial_bar_only_u)/2+1:end),'g--o');
%             end
        end
        hold on;

        % the first part of 'eachtrial_off_sync_CCW_u' is 'upperExp =
        % {'_vi2invi_u','_invi2vi_u'}; '  upperExp(1) so it is vi2invi 
        % the red dot means vi2invi and green dot means invi2vi
%         for condition = 1: numel(off_sync_CCW_u)
            plot(drawEachLoca + 1 + randn/20,eachtrial_off_sync_CCW_u(1:numel(off_sync_CCW_u)/2),'r--o');
            plot(drawEachLoca + 1 + randn/20,eachtrial_off_sync_CCW_u(numel(off_sync_CCW_u)/2+1:numel(off_sync_CCW_u)),'g--o');

            plot(drawEachLoca + 2 + randn/20,eachtrial_off_sync_CW_u(1:numel(off_sync_CCW_u)/2),'r--o');
             plot(drawEachLoca + 2 + randn/20,eachtrial_off_sync_CW_u(numel(off_sync_CCW_u)/2+1:numel(off_sync_CCW_u)),'g--o');

            plot(drawEachLoca + 3 + randn/20,eachtrial_flash_grab_CCW_u(1:numel(off_sync_CCW_u)/2),'r--o');
            plot(drawEachLoca + 3 + randn/20,eachtrial_flash_grab_CCW_u(numel(off_sync_CCW_u)/2+1:end),'g--o');

            plot(drawEachLoca + 4 + randn/20,eachtrial_perceived_location_CCW_u(1:numel(off_sync_CCW_u)/2),'r--o');
            plot(drawEachLoca + 4 + randn/20,eachtrial_perceived_location_CCW_u(numel(off_sync_CCW_u)/2+1:numel(off_sync_CCW_u)),'g--o');

            plot(drawEachLoca + 5 + randn/20,eachtrial_flash_grab_CW_u(1:numel(off_sync_CCW_u)/2),'r--o');
            plot(drawEachLoca + 5 + randn/20,eachtrial_flash_grab_CW_u(numel(off_sync_CCW_u)/2+1:numel(off_sync_CCW_u)),'g--o');

            plot(drawEachLoca + 6 + randn/20,eachtrial_perceived_location_CW_u(1:numel(off_sync_CCW_u)/2),'r--o');
            plot(drawEachLoca + 6 + randn/20,eachtrial_perceived_location_CW_u(numel(off_sync_CCW_u)/2+1:end),'g--o');
%            legendUnq() 
% legend('vi2invi','invi2vi');
%         end
        hold on;
        %----------------------------------------------------------------------
        %    draw each subject data upper visual field
        %----------------------------------------------------------------------
    elseif strcmp(eachtrial,'n')
        if strcmp(barOnlyDraw,'n')
            drawEachLoca = 0;
        elseif strcmp(barOnlyDraw,'y')
            drawEachLoca = 1;
        end
        for condition = 1:length(sbjnames)
            if strcmp(barOnlyDraw,'y')
                plot(drawEachLoca + randn/20,bar_only_u_ave_temp(condition),'r--o');
            end
            plot(drawEachLoca + 1 + randn/20,off_sync_CCW_u_ave(condition),'r--o');
            plot(drawEachLoca + 2 + randn/20,off_sync_CW_u_ave(condition),'r--o');
            if strcmp(annulusPattern,'blurredBoundary')
                plot(drawEachLoca + 3 + randn/20,boundary_CCW_u_ave(condition),'r--o');
                plot(drawEachLoca + 4 + randn/20,boundary_CW_u_ave(condition),'r--o');
                
                plot(drawEachLoca + 5 + randn/20,flash_grab_CCW_u_ave(condition),'r--o');
                plot(drawEachLoca + 6 + randn/20,perceived_location_CCW_u_ave(condition),'r--o');
                plot(drawEachLoca + 7 +randn/20,flash_grab_CW_u_ave(condition),'r--o');
                plot(drawEachLoca + 8 +randn/20,perceived_location_CW_u_ave(condition),'r--o');
            else
                plot(drawEachLoca + 3 + randn/20,flash_grab_CCW_u_ave(condition),'r--o');
                plot(drawEachLoca + 4 + randn/20,perceived_location_CCW_u_ave(condition),'r--o');
                plot(drawEachLoca + 5 +randn/20,flash_grab_CW_u_ave(condition),'r--o');
                plot(drawEachLoca + 6 +randn/20,perceived_location_CW_u_ave(condition),'r--o');
            end
        end
    end
    
    %----------------------------------------------------------------------
    %    draw lower visual field data
    %----------------------------------------------------------------------
elseif strcmp(visualField,'l')
    if strcmp(barOnlyDraw,'n')
        drawBarNum = 6;
        y_l = [bar_only_l_sbj_mean off_sync_CCW_l_sbj_mean off_sync_CW_l_sbj_mean flash_grab_CCW_l_sbj_mean...
            perceived_location_CCW_l_sbj_mean flash_grab_CW_l_sbj_mean perceived_location_CW_l_sbj_mean];
    elseif strcmp(barOnlyDraw,'y')
        if strcmp(annulusPattern,'blurredBoundary')
            drawBarNum = 9;
            y_l = [bar_only_l_sbj_mean off_sync_CCW_l_sbj_mean off_sync_CW_l_sbj_mean boundary_CCW_l_sbj_mean boundary_CW_l_sbj_mean ...
                flash_grab_CCW_l_sbj_mean perceived_location_CCW_l_sbj_mean flash_grab_CW_l_sbj_mean perceived_location_CW_l_sbj_mean];
        else
            drawBarNum = 7;
            y_l = [bar_only_l_sbj_mean off_sync_CCW_l_sbj_mean off_sync_CW_l_sbj_mean flash_grab_CCW_l_sbj_mean...
                perceived_location_CCW_l_sbj_mean flash_grab_CW_l_sbj_mean perceived_location_CW_l_sbj_mean];
        end
    end
    
    
    
    h_l = bar(y_l,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
    hold on;
    %----------------------------------------------------------------------
    %    draw each trial in the lower visual field
    %----------------------------------------------------------------------
    if strcmp(eachtrial,'y')
        if strcmp(barOnlyDraw,'n')
            drawEachLoca = 0;
        elseif strcmp(barOnlyDraw,'y')
            drawEachLoca = 1;
%             for condition = 1: length(eachtrial_bar_only_l)
                plot(drawEachLoca+randn/20,eachtrial_bar_only_l(1:numel(eachtrial_bar_only_l)/2),'r--o');
                plot(drawEachLoca+randn/20,eachtrial_bar_only_l(1:numel(eachtrial_bar_only_l)/2+1:end),'b--o');
                %     plot(2,eachtrialdegree_off_sync(condition),'r--o');
%             end
        end
        hold on;
%         for condition = 1: numel(off_sync_CCW_l)
            plot(drawEachLoca + 1 + randn/20,eachtrial_off_sync_CCW_l(1:numel(eachtrial_off_sync_CCW_l)/2),'r--o');
            plot(drawEachLoca + 1 + randn/20,eachtrial_off_sync_CCW_l(numel(eachtrial_off_sync_CCW_l)/2+1:end),'b--o');

            plot(drawEachLoca + 2 + randn/20,eachtrial_off_sync_CW_l(1:numel(eachtrial_off_sync_CCW_l)/2),'r--o');
            plot(drawEachLoca + 2 + randn/20,eachtrial_off_sync_CW_l(numel(eachtrial_off_sync_CCW_l)/2+1:end),'b--o');

            plot(drawEachLoca + 3 + randn/20,eachtrial_flash_grab_CCW_l(1:numel(eachtrial_off_sync_CCW_l)/2),'r--o');
            plot(drawEachLoca + 3 + randn/20,eachtrial_flash_grab_CCW_l(numel(eachtrial_off_sync_CCW_l)/2+1:end),'b--o');

            plot(drawEachLoca + 4 + randn/20,eachtrial_perceived_location_CCW_l(1:numel(eachtrial_off_sync_CCW_l)/2),'r--o');
            plot(drawEachLoca + 4 + randn/20,eachtrial_perceived_location_CCW_l(numel(eachtrial_off_sync_CCW_l)/2+1:end),'b--o');

            plot(drawEachLoca + 5 + randn/20,eachtrial_flash_grab_CW_l(1:numel(eachtrial_off_sync_CCW_l)/2),'r--o');
             plot(drawEachLoca + 5 + randn/20,eachtrial_flash_grab_CW_l(numel(eachtrial_off_sync_CCW_l)/2+1:end),'b--o');

            plot(drawEachLoca + 6 + randn/20,eachtrial_perceived_location_CW_l(1:numel(eachtrial_off_sync_CCW_l)/2),'r--o');
            plot(drawEachLoca + 6 + randn/20,eachtrial_perceived_location_CW_l(numel(eachtrial_off_sync_CCW_l)/2+1:end),'b--o');

%         end
        
        %----------------------------------------------------------------------
        %    draw each subject data in lower visual field
        %----------------------------------------------------------------------
    elseif strcmp(eachtrial,'n')
        if strcmp(barOnlyDraw,'n')
            drawEachLoca = 0;
        elseif strcmp(barOnlyDraw,'y')
            drawEachLoca = 1;
        end
        
        for condition = 1:length(sbjnames)
            if strcmp(barOnlyDraw,'y')
                plot(drawEachLoca + randn/20,bar_only_l_ave_temp(condition),'r--o');
            end
            plot(drawEachLoca + 1 + randn/20,off_sync_CCW_l_ave(condition),'r--o');
            plot(drawEachLoca + 2 + randn/20,off_sync_CW_l_ave(condition),'r--o');
            if strcmp(annulusPattern,'blurredBoundary')
                plot(drawEachLoca + 3 + randn/20,boundary_CCW_l_ave(condition),'r--o');
                plot(drawEachLoca + 4 + randn/20,boundary_CW_l_ave(condition),'r--o');
                plot(drawEachLoca + 5 + randn/20,flash_grab_CCW_l_ave(condition),'r--o');
                plot(drawEachLoca + 6 + randn/20,perceived_location_CCW_l_ave(condition),'r--o');
                plot(drawEachLoca + 7 + randn/20,flash_grab_CW_l_ave(condition),'r--o');
                plot(drawEachLoca + 8 + randn/20,perceived_location_CW_l_ave(condition),'r--o');
            else
                plot(drawEachLoca + 3 + randn/20,flash_grab_CCW_l_ave(condition),'r--o');
                plot(drawEachLoca + 4 + randn/20,perceived_location_CCW_l_ave(condition),'r--o');
                plot(drawEachLoca + 5 + randn/20,flash_grab_CW_l_ave(condition),'r--o');
                plot(drawEachLoca + 6 + randn/20,perceived_location_CW_l_ave(condition),'r--o');
            end
            
        end
    end
    
end

%----------------------------------------------------------------------
%    xLable for draw and don't draw bar_only data   and yLable
%----------------------------------------------------------------------

if strcmp(barOnlyDraw,'n')
    drawBarNum = 6;
    xLable = {'off-sync-CCW' 'off-sync-CW' 'flash-grab-CCW' 'perceived-location-CCW' 'flash-grab-CW' 'perceived-location-CW'};
elseif strcmp(barOnlyDraw,'y')
    if strcmp(annulusPattern,'blurredBoundary')
        drawBarNum = 9;
        xLable = {'bar-only' 'off-sync-CCW' 'off-sync-CW' 'boundary-CCW' 'boundary-CW' 'flash-grab-CCW' ...
            'perceived-location-CCW' 'flash-grab-CW' 'perceived-location-CW'};
    else
        drawBarNum = 7;
        xLable = {'bar-only' 'off-sync-CCW' 'off-sync-CW' 'flash-grab-CCW' 'perceived-location-CCW' 'flash-grab-CW' 'perceived-location-CW'};
    end
end


set(gca, 'XTick', 1:drawBarNum, 'XTickLabels',xLable ,'fontsize',20,'FontWeight','bold');
% set(gca, 'XTick', 1:4, 'XTickLabels', {'flash-grab-CCW' 'perceived-location-CCW' 'flash-grab-CW' 'perceived-location-CW'},'fontsize',20,'FontWeight','bold');
% set(gca, 'XTick', 1:3, 'XTickLabels', {'bar-only' 'grab-CCW' 'grab-CW'},'fontsize',20,'FontWeight','bold');
set(gcf,'color','w');
set(gca,'box','off');
% ylim([20,40]);
xtickangle(45);
hold on;
ylabel('Shift degree from horizontal meridian','FontName','Arial','FontSize',25);

if strcmp(annulusWidth,'artificialScotoma')
    if strcmp(visualField,'u')
        bar_only_ave = bar_only_u_ave;
    elseif strcmp(visualField,'l')
        bar_only_ave = bar_only_l_ave;
    end
    ylabel('Shift degree from mapped blindfield border','FontName','Arial','FontSize',25);
    line([0 drawBarNum + 1], [(blindfield_from_horizontal_degree - bar_only_ave) (blindfield_from_horizontal_degree-bar_only_ave)],'LineWidth',1.5,'LineStyle','--');
end

if strcmp(visualField, 'l')
    % set the origin on the left top
    set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
end


