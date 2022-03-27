function [y, gate_name, operationsongate]= gateOperations(x, responseParameters) % Operations on gate
gateName = menu("Choose a gate", responseParameters(1,:).gate_name);

gate_name = responseParameters(gateName).gate_name;
ymax = responseParameters(gateName).ymax;
ymin = responseParameters(gateName).ymin;
K = responseParameters(gateName).K;
n = responseParameters(gateName).n;
low = responseParameters(gateName).low;
high = responseParameters(gateName).high;
check=true;
operationsongate= cell(1,7); 
while check==true
    questionprompt=input("Do you want to do an operation?(Yes/No) ","s");
    if  questionprompt== "Yes"
        operationNum = input("How many operations do you want to perform? (Max = 7): ");
        for i = 1:operationNum
            operationType = menu("Choose an operation", "Stretch", "Increase Slope", "Decrease Slope", "Stronger Promoter", "Weaker Promoter", "Stronger RBS", "Weaker RBS");

            switch operationType
                case 1
                    %stretch
                    ymax_new = ymax .* x;
                    ymin_new = ymin ./ x;
                    ymax = ymax_new;
                    ymin = ymin_new;
                    operationsongate{1,i}= "Stretch"; 
                case 2
                    %increase slope
                    n_new = n .* x;
                    n = n_new;
                    operationsongate{1,i}= "Increase Slope"; 
                case 3
                    %decrease slope
                    n_new = n ./ x;
                    n = n_new;
                    operationsongate{1,i}= "Decrease Slope"; 
                case 4
                    %stronger promoter
                    ymax_new = ymax .* x;
                    ymin_new = ymin .* x;
                    ymax = ymax_new;
                    ymin = ymin_new;
                    operationsongate{1,i}= "Stronger Promoter"; 
                case 5
                    %weaker promoter
                    ymax_new = ymax ./ x;
                    ymin_new = ymin ./ x;
                    ymax = ymax_new;
                    ymin = ymin_new;
                    operationsongate{1,i}= "Weaker Promoter"; 
                case 6
                    %stronger RBS
                    K_new = K./x;
                    K = K_new;
                    operationsongate{1,i}= "Stronger RBS"; 
                case 7
                    %weaker RBS
                    K_new = K .* x;
                    K = K_new;
                    operationsongate{1,i}= "Weaker RBS"; 
            end
        end
        check=false;
    elseif questionprompt == "No"
        check=false;
    elseif questionprompt~= "No" && questionprompt~= "Yes"
        fprintf("Error!Please input Yes or No!");
        check=true;
    end
end

%calculate response function
y = ymin + ( (ymax - ymin) ./ (1 + (x./K) .^ n));

end