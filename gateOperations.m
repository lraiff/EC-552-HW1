% Operations on gate
gateName = menu("Choose a gate", responseParameters(1,:).gate_name);

gate_name = responseParameters(gateName).gate_name;
ymax = responseParameters(gateName).ymax;
ymin = responseParameters(gateName).ymin;
K = responseParameters(gateName).K;
n = responseParameters(gateName).n;
low = responseParameters(gateName).low;
high = responseParameters(gateName).high;
    
operationNum = input("How many operations do you want to perform?: ");


for i = 1:operationNum
    operationType = menu("Choose an operation", "Stretch", "Increase Slope", "Decrease Slope", "Stronger Promoter", "Weaker Promoter", "Stronger RBS", "Weaker RBS");

    switch operationType
        case 1 
            %stretch
            ymax_new = ymax * input;
            ymin_new = ymin / input;
        case 2
            %increase slope
            n_new = n * input;
        case 3
            %decrease slope
            n_new = n / input;
        case 4
            %stronger promoter
            ymax_new = ymax * input;
            ymin_new = ymin * input;
        case 5
            %weaker promoter
            ymax_new = ymax / input;
            ymin_new = ymin / input;
        case 6
            %stronger RBS
            K_new = K /input;
        case 7
            %weaker RBS
            K_new = K * input;
    end
    ymax = ymax_new;
    ymin = ymin_new;
    n = n_new;
    K = K_new;
end

%calculate response function
y = ymin + (ymax - ymin) / (1 + (input/K) ^ n);