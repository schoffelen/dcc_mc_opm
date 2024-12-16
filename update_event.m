function event = update_event(event)

% UPDATE_EVENT replaces the numeric codes by more meaningful strings
%
% FIXME does not oddball versus faces/houses esperiment require the trigger sequence
% to be cut in two? How to detect the transition?


% Triggers Faces/Houses Paradigm
% 
% 1-6: onset female faces
% 7-18: onset houses
% 19-24: onset male faces (Yes, sorry about that, I numbered the triggers according to the alphabetical order of the images, without thinking twice that female face files start with ‘F’ and male face files start with ‘M’)
% 25: onset fixation square
% 50: onset background music
% 51: offset background music
% 101-107: onset attention getter
% 108-114: offset attention getter
 
numericvalue = [event.value];
stringvalue = num2cell(numericvalue);

stringvalue(cellfun(@(x) x==1, num2cell(numericvalue))) = {'female'};
stringvalue(cellfun(@(x) x==2, num2cell(numericvalue))) = {'female'};
stringvalue(cellfun(@(x) x==3, num2cell(numericvalue))) = {'female'};
stringvalue(cellfun(@(x) x==4, num2cell(numericvalue))) = {'female'};
stringvalue(cellfun(@(x) x==5, num2cell(numericvalue))) = {'female'};
stringvalue(cellfun(@(x) x==6, num2cell(numericvalue))) = {'female'};

stringvalue(cellfun(@(x) x== 7, num2cell(numericvalue))) = {'house'};
stringvalue(cellfun(@(x) x== 8, num2cell(numericvalue))) = {'house'};
stringvalue(cellfun(@(x) x== 9, num2cell(numericvalue))) = {'house'};
stringvalue(cellfun(@(x) x==10, num2cell(numericvalue))) = {'house'};
stringvalue(cellfun(@(x) x==11, num2cell(numericvalue))) = {'house'};
stringvalue(cellfun(@(x) x==12, num2cell(numericvalue))) = {'house'};
stringvalue(cellfun(@(x) x==13, num2cell(numericvalue))) = {'house'};
stringvalue(cellfun(@(x) x==14, num2cell(numericvalue))) = {'house'};
stringvalue(cellfun(@(x) x==15, num2cell(numericvalue))) = {'house'};
stringvalue(cellfun(@(x) x==16, num2cell(numericvalue))) = {'house'};
stringvalue(cellfun(@(x) x==17, num2cell(numericvalue))) = {'house'};
stringvalue(cellfun(@(x) x==18, num2cell(numericvalue))) = {'house'};

stringvalue(cellfun(@(x) x==19, num2cell(numericvalue))) = {'male'};
stringvalue(cellfun(@(x) x==20, num2cell(numericvalue))) = {'male'};
stringvalue(cellfun(@(x) x==21, num2cell(numericvalue))) = {'male'};
stringvalue(cellfun(@(x) x==22, num2cell(numericvalue))) = {'male'};
stringvalue(cellfun(@(x) x==23, num2cell(numericvalue))) = {'male'};
stringvalue(cellfun(@(x) x==24, num2cell(numericvalue))) = {'male'};

stringvalue(cellfun(@(x) x==25, num2cell(numericvalue))) = {'fix'};
stringvalue(cellfun(@(x) x==50, num2cell(numericvalue))) = {'music_on'};
stringvalue(cellfun(@(x) x==24, num2cell(numericvalue))) = {'music_off'};

stringvalue(cellfun(@(x) x==101, num2cell(numericvalue))) = {'att_on'};
stringvalue(cellfun(@(x) x==102, num2cell(numericvalue))) = {'att_on'};
stringvalue(cellfun(@(x) x==103, num2cell(numericvalue))) = {'att_on'};
stringvalue(cellfun(@(x) x==104, num2cell(numericvalue))) = {'att_on'};
stringvalue(cellfun(@(x) x==105, num2cell(numericvalue))) = {'att_on'};
stringvalue(cellfun(@(x) x==106, num2cell(numericvalue))) = {'att_on'};
stringvalue(cellfun(@(x) x==107, num2cell(numericvalue))) = {'att_on'};

stringvalue(cellfun(@(x) x==108, num2cell(numericvalue))) = {'att_off'};
stringvalue(cellfun(@(x) x==109, num2cell(numericvalue))) = {'att_off'};
stringvalue(cellfun(@(x) x==110, num2cell(numericvalue))) = {'att_off'};
stringvalue(cellfun(@(x) x==111, num2cell(numericvalue))) = {'att_off'};
stringvalue(cellfun(@(x) x==112, num2cell(numericvalue))) = {'att_off'};
stringvalue(cellfun(@(x) x==113, num2cell(numericvalue))) = {'att_off'};
stringvalue(cellfun(@(x) x==114, num2cell(numericvalue))) = {'att_off'};

for i=1:numel(event)
  event(i).value = stringvalue{i};
end

% Triggers oddball Paradigm
%
% Stuff related to the fixation square and attention getter onset/offsets is the same as above.
% Furthermore, given that potentially triggers can overlap (i.e. a luminance change may by coincidence overlap with the onset of a tone), the other triggers are unique bytes:
%
% 1: standard tone onset
% 2: deviant tone onset
% 4: luminance change to dark
% 8: luminance change to intermediate
% 16: luminance change to bright

