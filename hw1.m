%Homework 1
clear

%% load files
fprintf('Select UCF json file\n')
filenameUCF = uigetfile('*.json');
fid = fopen(filenameUCF); %open file
raw = fread(fid,inf); %read the contents of the file
fid_str = char(raw');
fclose(fid);

libUCF = jsondecode(fid_str);

fprintf('Select input json file\n')
filenameInput = uigetfile('*.json');
fid1 = fopen(filenameInput); %open file
raw1 = fread(fid1,inf); %read the contents of the file
fid_str1 = char(raw1');
fclose(fid1);

libInput = jsondecode(fid_str1);

% fprintf('Select output json file\n')
% filenameOutput = uigetfile('*.json');
% fid2 = fopen(filenameOutput); %open file
% raw2 = fread(fid2,inf); %read the contents of the file
% fid_str2 = char(raw2');
% fclose(fid2);
% 
% libOutput = jsondecode(fid_str2);



%% get promoters from input file

lenLibIn = size(libInput);
inputParameters = struct('sensor_name', cell(1,1), 'on', cell(1,1), 'off', cell(1,1), 'promoter', cell(1,1));
circuitParameters = struct('outputs', cell(1,1), 'inputs_name', cell(1,1),'inputs_table', cell(1,1), 'design', cell(1,1));

count = 1;
countCircuit = 1;

for i = 1:lenLibIn
    if libInput{i,1}.collection == "models"
        inputParameters(count).sensor_name = libInput{i,1}.name;
        inputParameters(count).on = libInput{i,1}.parameters(1).value;
        inputParameters(count).off= libInput{i,1}.parameters(2).value;
        count = count +1;
    end
    if libInput{i,1}.collection == "circuit"
        circuitParameters(countCircuit).outputs = libInput{i,1}.outputs;
        for j= 1: length(libInput{i,1}.inputs)
        circuitParameters(countCircuit,j).inputs_name = libInput{i,1}.inputs(j).name;
        circuitParameters(countCircuit,j).inputs_table = libInput{i,1}.inputs(j).table;
        end 
        circuitParameters(countCircuit).design = libInput{i,1}.design;
        
    end
        
end

count2 = 1;
for i = 1:lenLibIn
    if libInput{i,1}.collection == "structures"
        inputParameters(count2).promoter = libInput{i,1}.outputs{1,1};
        count2 = count2 + 1;
    end
end


%% Get gate paramters
lenLib = size(libUCF);
responseParameters = struct('gate_name', cell(1,1),'ymax',cell(1,1),'ymin',cell(1,1),'K',cell(1,1),'n',cell(1,1),'low', cell(1,1),'high', cell(1,1), 'gate_type', cell(1,1));
count = 1;

for i = 1:lenLib 
    if libUCF{i,1}.collection == "response_functions"
        responseParameters(count).gate_name = libUCF{i,1}.gate_name;
        responseParameters(count).ymax = libUCF{i,1}.parameters(1).value;
        responseParameters(count).ymin= libUCF{i,1}.parameters(2).value;
        responseParameters(count).K= libUCF{i,1}.parameters(3).value;
        responseParameters(count).n= libUCF{i,1}.parameters(4).value;
        responseParameters(count).low = libUCF{i,1}.variables.off_threshold;
        responseParameters(count).high = libUCF{i,1}.variables.on_threshold;
        count = count + 1;   
    end
        
end

count2 = 1;
for i = 1:lenLib
    if libUCF{i,1}.collection == "gates"
        responseParameters(count2).gate_type = libUCF{i,1}.gate_type;
        count2 = count2 + 1;
    end
end

%% Generate Truth Table for the Circuit

inputVal = zeros(1,length(circuitParameters(1).inputs_table)); 
outputVal = zeros(length(circuitParameters(1).inputs_table), length(circuitParameters(1).design));
outputNames = cell(1,length(circuitParameters(1).design));
inputGate = cell(1,3);
inputGate(1,:) = {{},{},{}};


for k = 1:length(circuitParameters(1).design) %loops every line of design
    g = 0;
    for n = 1:length(responseParameters)
        %finds gates in current line of design
        if contains(string(circuitParameters(1).design(k)),string(responseParameters(n).gate_name))
            if strfind(string(circuitParameters(1).design(k)),string(responseParameters(n).gate_name)) == 5 %this works for nor, not, and gates
                %gate in output position 
                outputNames(1,k) = {responseParameters(n).gate_name};
            else
                %if the gate is not in the output position it is an input
                inputGate(g+1) = {responseParameters(n).gate_name};
                g = g + 1;
            end
                
        end
        
    end
    
    for i = 1:length(circuitParameters) %loops through each promoter
        for j = 1:length(circuitParameters(i).inputs_table) %loops truth table for each promoter     
            if contains(circuitParameters(1).design(k), circuitParameters(i).inputs_name)
                inputVal(j) = inputVal(j) + circuitParameters(i).inputs_table(j); %adds input truth table to get a vector of values 0, 1, or 2
            end
        end      
    end
    
    %if one of the inputs is a gate, add its previous output to the current input
    if  sum(~cellfun(@isempty,inputGate)) ~= 0
        while(g > 0)
            ind = find(strcmp(outputNames, inputGate(g)));
            inputVal(:) = inputVal(:) + outputVal(:,ind);
            g = g - 1;
        end
    end
    
    %find where input vector satifies NOR and/or NOT gate
    on = find(inputVal == 0);
    outputVal(on,k) = 1; %when both inputs are off, the output is one.
    
    %reset values
    inputVal(:) = 0; 
    inputGate(1,:) = {{},{},{}};
    on(:) = 0;
    
end
outputNames(end) = {'y'};

%% Display results and ask for operations


