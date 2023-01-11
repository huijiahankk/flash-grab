

dummymode=0;
if ~IsOctave
    commandwindow;
else
    more off;
end

%%%%%%%%%%
% STEP 1 %
%%%%%%%%%%

% Added a dialog box to set your own EDF file name before opening
% experiment graphics. Make sure the entered EDF file name is 1 to 8
% characters in length and only numbers or letters are allowed.
if IsOctave
    edfFile = 'DEMO';
else
    prompt = {'Enter tracker EDF file name (1 to 8 letters or numbers)'};
    dlg_title = 'Create EDF file';
    num_lines= 1;
    def     = {'DEMO'};
    answer  = inputdlg(prompt,dlg_title,num_lines,def);
    edfFile = answer{1};
    fprintf('EDFFile: %s\n', edfFile );
end