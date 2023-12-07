clc; clear; close all;

%%
% data_dir = '../data/heart_artifact_data/';
data_dir = 'data/processed_data_2023_05_09/';

d = dir([data_dir '*.mat']);

stages = {'Art', 'A', 'N1', 'W', 'N2', 'N3', 'REM'};
data = [];
sleep_stage = [];
label = [];
subject = [];
record = [];
year = [];
month = [];
day = [];

for i_file = 1:size(d,1)
    file_name = d(i_file).name
    file_path = [data_dir file_name];
    
    % Split file name for indexing
    file_token = strsplit(file_name, '_');
    subject_name = file_token(1);
    file_record = str2double(file_token{3}(end-4));
   
    load(file_path)

    file_data = [];
    
    % Each struct has a field for the different stages
    % Loop through each stage,
    for i_stage = 1:size(stages,2)
        
        stage_name = stages{i_stage};
        
        if any(strcmp(fieldnames(STN), stage_name))
            x = cell2mat(STN.(stage_name))';
            file_data = [file_data; x];

            file_sleep_stage = repmat({stage_name}, size(x, 1),1);
            sleep_stage = [sleep_stage; file_sleep_stage];
            label = [label; ones(size(x,1),1)*i_stage];
        end
    end
    
    n_clips_file = size(file_data, 1);
    
    file_subject = repmat(subject_name, n_clips_file,1);
    file_record = repmat(file_record, n_clips_file,1);
   
    subject = [subject; file_subject];
    record = [record; file_record];
    data = [data; file_data];

end

%%
t = table(subject, record, sleep_stage, label, ...
    'VariableNames',{'subject', 'record', 'sleep_stage', 'label'});

%%
writetable(t, 'data/merged_metadata_2023_05_09.csv')
% writetable(t, '../data/merged_metadata_heart_artifact_clean.csv')
% 
%%
save('data/merged_data_2023_05_09.mat', 'data', '-v7.3')


%%
% clear
% load('../data/merged_data.mat')
% 
% %%
% fs = 500;
% 
% for i = 1:size(data,1)
% % for i = 2001
%     try 
%         data_clean(i,:) = ecg_removal(data(i,:), fs);
% 
%     catch e
%         sprintf('%d\n',i)
%     end
%     
% end





%%
idx_night = strcmp(t.subject, 'Buster') & t.record == 3;
t_night = t(idx_night,:);


mean(strcmp(t_night.sleep_stage,'A') | strcmp(t_night.sleep_stage,'W') ) 



