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

%% Scoring and Operations
% Results.outputname=
%each row is a promoter

%replace 0s and 1s with the scoring value for the promoters
for i = 1:length(circuitParameters)
    Results(i).name= string(circuitParameters(i).inputs_name);
    for j = 1:length(inputParameters)
        if contains(circuitParameters(i).inputs_name, inputParameters(j).promoter)
            offInd = find(circuitParameters(i).inputs_table == 0);
            onInd = find(circuitParameters(i).inputs_table == 1);
            Results(i).Score(1,:) = circuitParameters(i).inputs_table;
            Results(i).Score(1,:) = circuitParameters(i).inputs_table;
            Results(i).Score(2,offInd) = inputParameters(j).off;
            Results(i).Score(2,onInd) = inputParameters(j).on;
            Results(i).Gate_type={};
            Results(i).x={};
            Results(i).gate_name={};
        end
    end
end

%Inputs all input_names and output_names in the result table
for k = i+1:i+length(circuitParameters(1).design) %loops every line of design
    g = 0;
    A= string(circuitParameters(1).design(k-i,1));
    Gate_Type= split(A, '('); % extract gate type
    Results(k).Gate_type= Gate_Type(1);
    InOut = split(Gate_Type(2), ','); %Seperate the inputs and the outputs
    Results(k).name= InOut(1);
    if contains(circuitParameters(1).design(k-i), "NOR")==1 || contains(circuitParameters(1).design(i), 'AND')==1
        InOut(3)= erase(InOut(3),')');
        Results(k).input_names1= InOut(2);
        Results(k).input_names2= InOut(3);
    elseif contains(circuitParameters(1).design(k-i), 'NOT')==1
        InOut(2)= erase(InOut(2),')');
        Results(k).input_names1= InOut(2);
        Results(k).input_names2= {};
    end
end

inputVal1 = zeros(1,length(circuitParameters(1).inputs_table));
inputVal2 = zeros(1,length(circuitParameters(1).inputs_table));
outputVal = zeros(1,length(circuitParameters(1).inputs_table));

%Scoring and Truth Table
for k = i+1:i+length(circuitParameters(1).design) %loops every line of design
     % Find the index of the Result fields that contains the input parameters of the gate 
    for j = 1: length(Results)
        if contains(Results(j).name, Results(k).input_names1)==1
            input1index=j;
            inputVal1= Results(input1index).Score(1,:);
        end
        if contains(Results(j).name, Results(k).input_names2)
            input2index=j;
            if input2index ~= 0 % When it is a NOT gate
                inputVal2= Results(input2index).Score(1,:);
            end
        end
    end

    % Making the truth table and x_value
    if contains(Results(k).Gate_type, 'NOR')==1
        outputVal= inputVal1+inputVal2;
        two= find(outputVal == 2); % Change the addition of 1+1 into 1
        outputVal(1,two) = 1; % OR gate 
        outputVal(:)=~outputVal; % NOR gate 
        Results(k).x= Results(input1index).Score(2,:)+ Results(input2index).Score(2,:);
    elseif contains(Results(k).Gate_type, 'AND')==1
        outputVal= inputVal1+inputVal2;
        two= find(outputVal == 2); 
        outputVal(1,two) = 1; % Change the addition of 1+1 into 1
        one= find(outputVal == 1);
        outputVal(1,two) = 0;% Change the addition of 1 into 0 because its an AND gate
        Results(k).x= Results(input1index).Score(2,:)+ Results(input2index).Score(2,:);
    elseif contains(Results(k).Gate_type, 'NOT')==1
        outputVal(:)= ~inputVal1; % Opposite of input values 
        Results(k).x= Results(input1index).Score(2,:);
    end

    Results(k).Score(1,:)= outputVal; % Input the Truth table into results
    [Results(k).Score(2,:),Results(k).gate_name]= gateOperations(Results(k).x, responseParameters); %Scoring 
end

%% Display
Displaytruthtable= zeros(length(Results(1).Score(1,:)), length(Results)); 
Displayscores= zeros(length(Results(1).Score(1,:)), length(Results));
for j = 1: length(Results)
    Displaytruthtable(:,j)=(Results(j).Score(1,:))'; 
    Displayscores(:,j)=(Results(j).Score(2,:))'; 
end 



