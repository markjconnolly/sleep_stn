% function Nathan_data_organization

d = dir('data/raw_data/*.edf');

for j = 1:size(d,1)

    file_path = [d(j).folder filesep d(j).name];
    save_path = strrep(file_path, '.edf', '.mat');
    [data, annotations] = edfread(file_path);
    
    %Artefact=10.026504921034565;
    %A= 1.030762188143743;
    %W=-0.031235217822534
    %REM=2.030289158464946
    %N1= 3.029816128786148
    %N2= 4.029343099107351
    %N3=5.028870069428553
    
    n_clips = size(data, 1);

    % initial indice
    ar = 0;
    w = 0;
    a = 0;
    rem = 0;
    n1 = 0;
    n2 = 0;
    n3 = 0;

    for i = 1:3:n_clips-3
        B = cell2mat(data{i,3}); % Looking at the sleep score column
        % A
        if B(1)>1 && B(1)<2
            a = a+1;
            STN.A{a} = cell2mat(data{i:i+2,2});
            EEG.A{a} = cell2mat(data{i:i+2,1});
        end

        % Wake
        if B(1)<0
            w = w+1;
            STN.W{w} = cell2mat(data{i:i+2,2});
            EEG.W{w} = cell2mat(data{i:i+2,1});
        end

        % Artefact
        if B(1)>10 && B(1)<11
            ar = ar+1;
            STN.Art{ar} = cell2mat(data{i:i+2,2});
            EEG.Art{ar} = cell2mat(data{i:i+2,1});
        end

        % REM
        if B(1)>2 && B(1)<3
            rem = rem+1;
            STN.REM{rem} = cell2mat(data{i:i+2,2});
            EEG.REM{rem} = cell2mat(data{i:i+2,1});
        end

        % N1
        if B(1)>3 && B(1)<4
            n1 = n1+1;
            STN.N1{n1} = cell2mat(data{i:i+2,2});
            EEG.N1{n1} = cell2mat(data{i:i+2,1});
        end

        % N2
        if B(1)>4 && B(1)<5
            n2 = n2+1;
            STN.N2{n2} = cell2mat(data{i:i+2,2});
            EEG.N2{n2} = cell2mat(data{i:i+2,1});
        end

        % N3
        if B(1)>5 && B(1)<6
            n3 = n3+1;
            STN.N3{n3} = cell2mat(data{i:i+2,2});
            EEG.N3{n3} = cell2mat(data{i:i+2,1});
        end
    end

    save(save_path,'EEG*','STN*')
end