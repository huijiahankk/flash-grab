

function [barTiltStart,perceivedCondiStartDeg] = paraSetBarTiltEyelinkHealthyPatient(particiType, barLocation,annulusWidth,blindfield_from_horizontal_degree,CBfieldDegree,blindfield)

if nargin < 5
   CBfieldDegree = 0;
   blindfield = 'r';
end

if  strcmp(particiType,'CB')
    if strcmp(blindfield,'l') && strcmp(barLocation,'u')
        barTiltStart = 270 + CBfieldDegree/2;
        perceivedCondiStartDeg = 270 + CBfieldDegree/2;
    elseif strcmp(blindfield,'l') && strcmp(barLocation,'l')
        barTiltStart = 270 - CBfieldDegree/2;
        perceivedCondiStartDeg = 270 - CBfieldDegree/2;
    elseif strcmp(blindfield,'r') && strcmp(barLocation,'u')
        barTiltStart = 90 - CBfieldDegree/2;
        perceivedCondiStartDeg = 90 - CBfieldDegree/2;
    elseif strcmp(blindfield,'r') && strcmp(barLocation,'l')
        barTiltStart= 90 + CBfieldDegree/2;
        perceivedCondiStartDeg = 90 + CBfieldDegree/2;
    end
elseif strcmp(particiType,'healthyParticipant')
    if strcmp(barLocation,'u') && strcmp(annulusWidth,'artificialScotoma')
        barTiltStart = 90 - blindfield_from_horizontal_degree;
        perceivedCondiStartDeg = 90 - blindfield_from_horizontal_degree;
    elseif strcmp(barLocation,'u') && strcmp(annulusWidth,'blindspot')
        barTiltStart = 90;
        perceivedCondiStartDeg = 90;
    elseif strcmp(barLocation,'l') && strcmp(annulusWidth,'artificialScotoma')
        barTiltStart = 90 + blindfield_from_horizontal_degree;
        perceivedCondiStartDeg = 90 + blindfield_from_horizontal_degree;
    elseif strcmp(barLocation,'l') && strcmp(annulusWidth,'blindspot')
        barTiltStart = 90;
        perceivedCondiStartDeg = 90;
    end
end

   

    