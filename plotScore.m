
function plotScore(scoreVal, newDesign)
%plot .mat file that holds the scores of one design at a time
%the .mat file will be deleted and created again for each new design
    close all;
    
        
    if (isfile('plotScore.mat') && contains(newDesign,'Yes'))
        %if the file exists and we are still on the same design, append file
        scores = [scores scoreVal];
        save('plotScore.mat', 'scores', '-append');
        
        
    elseif (~isfile('plotScore.mat') && contains(newDesign,'Yes'))
        %if the file doesn't exist yet but we are on the same design, create file with new value
         
        save('plotScore.mat', 'scores');
        
    else
        delete 'plotScore.mat'
        scores = scoreVal;
        save('plotScore.mat', 'scores');
    end
    
    %load and plot a bar graph of the scores from this design
    data = load('plotScore.mat');
    bar(data.scoreVal)
    ylabel('Final Score of Circuit')
    xlabel('Circuit Design Number')
end