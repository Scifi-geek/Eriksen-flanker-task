function [counter_noresponse] = eriksen(subject,day,run)
% clear all
screens = Screen('Screens');
myscreens = Screen('Screens');
screenid = myscreens(1);
PScreen.white=WhiteIndex(screenid);
PScreen.black=BlackIndex(screenid);
PScreen.gray=(9.7*PScreen.white+0.3*PScreen.black)/10;
Screen('Preference', 'SkipSyncTests', 0)
% screenid = 1;
PScreen.wPtr = Screen('OpenWindow', screenid, PScreen.gray);
Screen('Flip',PScreen.wPtr);
PScreen.vbl=Screen('Flip', PScreen.wPtr);
PScreen.ifi = Screen('GetFlipInterval', PScreen.wPtr);
PScreen.textColor = [55 55 55];
[w, h] = Screen('WindowSize', PScreen.wPtr);
PScreen.h = h;
PScreen.w = w;
PScreen.h_2 = round(h/2);
h_2 = round(h/2);
PScreen.h_10 = round(h/10);
PScreen.w_2 = round(w/2);
w_2 = round(w/2);
PScreen.w_20 = round(w/20);
w_20 = round(w/20);
PScreen.w_200 = (w/200);
PScreen.lw = 5;

% on each day, different lists for the 2 runs of the 2 tasks: 
% first 2 for simon task, last 2 for eriksen task
load('bestlists.mat');
load('listorders.mat');
if strcmp(day,'first')
    P.listnumber=list_orders(2+run,subject);
    list=best_lists(:,P.listnumber);
elseif strcmp(day,'last')
    P.listnumber=list_orders(6+run,subject); % since there were already 4 runs on the first day
    list=best_lists(:,P.listnumber);
end
clear best_lists;
clear list_orders;

positive_stimuli=(1:400);
negative_stimuli=(-400:-1);

if strcmp(day,'first') & run==1
    %counterbalancing is prone to errors (research assistants can easily mix things up),
    %so i randomize instead which stimuli are used as
    %targets/distractors and which stimuli for pretest/posttest;
    %and this way, i also make sure that not always the same stimuli are paired
    %within trials (not always the same target-distractor combinations)
    random1=randi(1000,[1,400]);
    random2=randi(1000,[1,400]);
    array1(:,1)=positive_stimuli;
    array1(:,2)=random1;
    array2(:,1)=negative_stimuli;
    array2(:,2)=random2;
    sorted1=sortrows(array1,2);
    sorted2=sortrows(array2,2);
    
    %stimulus combinations for this subject
    positive_targets=sorted1(1:200,:);
    positive_distractors=sorted1(201:400,:);
    negative_targets=sorted2(1:200,:);
    negative_distractors=sorted2(201:400,:);
    save(['stimuli_task2_subject_' mat2str(subject) '.mat'],'positive_targets', 'negative_targets', 'positive_distractors', 'negative_distractors');
    
else
    load (['stimuli_task2_subject_' mat2str(subject) '.mat']);
end

if strcmp(day,'first')
    index=(run-1)*100;
elseif strcmp(day,'last')
    index=(run-1)*100+200;
end

%pairing of targets and distractors to trials:
%the event lists don't have all exactly the same number of
%congruent and incongruent trials, but i checked:
%no list has more than 50 trials of either type
congruent_trials(1:50,1)=positive_targets(index+1:index+50);
congruent_trials(51:100,1)=negative_targets(index+1:index+50);
incongruent_trials(1:50,1)=positive_targets(index+51:index+100);
incongruent_trials(51:100,1)=negative_targets(index+51:index+100);

congruent_trials(1:50,2)=positive_distractors(index+1:index+50);
congruent_trials(51:100,2)=negative_distractors(index+1:index+50);
incongruent_trials(1:50,2)=negative_distractors(index+51:index+100);
incongruent_trials(51:100,2)=positive_distractors(index+51:index+100);

%a column indicating whether the target was positive or negative so that i
%can easily compare it to the button press
congruent_trials(1:50,3)=1;
congruent_trials(51:100,3)=-1;
incongruent_trials(1:50,3)=1;
incongruent_trials(51:100,3)=-1;

random3=randi(1000,[1,100]);
random4=randi(1000,[1,100]);
congruent_trials(:,4)=random3;
incongruent_trials(:,4)=random4;
congruent_trials=sortrows(congruent_trials,4);
incongruent_trials=sortrows(incongruent_trials,4);

% buttons for left and right index finger
taste4=52;
taste7=55;

% for simon and eriksen task, the buttons are always:
button_positive=7;
button_negative=4;

% odd_or_even=num2str(SubjectID/2);
% if str2num(odd_or_even(3))==0 % subject number is even
%     button_positive=4;
%     button_negative=7;
% elseif str2num(odd_or_even(3))==5 % subject number is odd
%     button_positive=7;
%     button_negative=4;
% end

trials=200;
rt(1:trials)=zeros;
jitter=randi(500,[1,trials]);
counter_congruent=0;
counter_incongruent=0;
counter_correct_congruent=0;
counter_correct_incongruent=0;
counter_incorrect_congruent=0;
counter_incorrect_incongruent=0;
counter_noresponse=0;
KbCheck;
WaitSecs(0.1);
GetSecs;
HideCursor;
priorityLevel=MaxPriority(w);
Priority(priorityLevel);

pulse= 65; % KbName('a'); 
ttl_signal=0;
for pulses=1:4 % 3 dummy scans
    [KeyIsDown, endrt, KeyCode]=KbCheck;
    while ~KeyCode(pulse)
        [KeyIsDown, endrt, KeyCode]=KbCheck;
        WaitSecs(0.001);
    end
    if KeyCode(pulse)
        while KbCheck;
        end
    end
    ttl_signal=ttl_signal+1;
    if ttl_signal<4
        Screen('TextSize',PScreen.wPtr,50);   
        DrawFormattedText(PScreen.wPtr,'START','center',PScreen.h_2-PScreen.h_10/3,PScreen.textColor);
        PScreen.vbl=Screen('Flip', PScreen.wPtr,PScreen.vbl+PScreen.ifi/2);
    elseif ttl_signal==4
        start = tic; % this is time 0, now paradigm start
        break,
    end      
end

for trial=1:trials;
    if list(trial)==0
        %ideally, the null events would last exactly as long as the real
        %events, but since one cannot know that duration in advance,
        %i work with a rough estimation and make the null events last about
        %700ms plusminus 50 ms
        trial_duration=((650+randi(100,1))/1000);
        imdata=imread('fixation_cross.jpg');
        tex=Screen('MakeTexture',PScreen.wPtr,imdata);
        Screen('DrawTexture',PScreen.wPtr,tex);
        PScreen.vbl=Screen('Flip', PScreen.wPtr,PScreen.vbl+PScreen.ifi/2);
        WaitSecs(trial_duration);
        
    elseif list(trial)==1
        counter_congruent=counter_congruent+1;
        %warning 200ms before trialstart because of the many null events
        imdata=imread('warning.jpg');
        tex=Screen('MakeTexture',PScreen.wPtr,imdata);
        Screen('DrawTexture',PScreen.wPtr,tex);
        PScreen.vbl=Screen('Flip', PScreen.wPtr,PScreen.vbl+PScreen.ifi/2);
        WaitSecs(0.2);
        
        %stimulus presentation with recording of button presses
        [KeyIsDown, time, KeyCode]=KbCheck;
        Screen('TextSize',PScreen.wPtr,50);
%         DrawFormattedText(PScreen.wPtr,congruent_trials(counter_congruent,2),'center',PScreen.h_2-PScreen.h_10*2,PScreen.textColor);
%         DrawFormattedText(PScreen.wPtr,congruent_trials(counter_congruent,1),'center',PScreen.h_2,PScreen.textColor);
%         DrawFormattedText(PScreen.wPtr,congruent_trials(counter_congruent,2),'center',PScreen.h_2+PScreen.h_10*2,PScreen.textColor);
if congruent_trials(counter_congruent,3)==1
    DrawFormattedText(PScreen.wPtr,'>>>>>','center',PScreen.h_2-PScreen.h_10/3,PScreen.textColor);
elseif congruent_trials(counter_congruent,3)==-1
    DrawFormattedText(PScreen.wPtr,'<<<<<','center',PScreen.h_2-PScreen.h_10/3,PScreen.textColor);
end
        [VBLTimestamp starttime]=Screen('Flip', PScreen.wPtr,PScreen.vbl+PScreen.ifi/2);
        onset=toc(start);
        [KeyIsDown, time, KeyCode]=KbCheck;
        check_con=tic;
        while (GetSecs - starttime)<=1 %timeout after 1000ms
            [KeyIsDown, time, KeyCode]=KbCheck;
            if KeyCode(taste4) | KeyCode(taste7)
                rt(trial)=time-starttime;
                if KeyCode(taste4)
                pressed_button(trial)=4;
                elseif KeyCode(taste7)
                pressed_button(trial)=7;
                end
                if KeyCode(65)
                    disp a
                end
                while KbCheck;
                end
                if congruent_trials(counter_congruent,3)==1 & pressed_button(trial)==button_positive
                    accuracy(trial)=1;
                    counter_correct_congruent=counter_correct_congruent+1;
                    correct_congruent_durations(counter_correct_congruent)=rt(trial);
                    correct_congruent_onsets(counter_correct_congruent)=onset;
                elseif congruent_trials(counter_congruent,3)==-1 & pressed_button(trial)==button_negative
                    accuracy(trial)=1;
                    counter_correct_congruent=counter_correct_congruent+1;
                    correct_congruent_durations(counter_correct_congruent)=rt(trial);
                    correct_congruent_onsets(counter_correct_congruent)=onset;
                elseif congruent_trials(counter_congruent,3)==1 & pressed_button(trial)==button_negative
                    accuracy(trial)=-1;
                    counter_incorrect_congruent=counter_incorrect_congruent+1;
                    incorrect_congruent_durations(counter_incorrect_congruent)=rt(trial);
                    incorrect_congruent_onsets(counter_incorrect_congruent)=onset;
                elseif congruent_trials(counter_congruent,3)==-1 & pressed_button(trial)==button_positive
                    accuracy(trial)=-1;
                    counter_incorrect_congruent=counter_incorrect_congruent+1;
                    incorrect_congruent_durations(counter_incorrect_congruent)=rt(trial);
                    incorrect_congruent_onsets(counter_incorrect_congruent)=onset;
                end
                break,
            end
            WaitSecs(0.001);
        end
        % if no button was pressed within 1000ms, slightly scold the subject
        test_con=toc(check_con);
        if rt(trial)==0
            Screen('TextSize',PScreen.wPtr,50);
            message='No button press!';
            DrawFormattedText(PScreen.wPtr,message,'center','center',BlackIndex(PScreen.wPtr));
            PScreen.vbl=Screen('Flip', PScreen.wPtr,PScreen.vbl+PScreen.ifi/2);
            WaitSecs(0.3);
            counter_noresponse=counter_noresponse+1;
            noresponse_durations(counter_noresponse)=1;
            noresponse_onsets(counter_noresponse)=onset;
            accuracy(trial)=0;
        end
        
    elseif list(trial)==2
        counter_incongruent=counter_incongruent+1;
        %warning 200ms before trialstart because of the many null events
        imdata=imread('warning.jpg');
        tex=Screen('MakeTexture',PScreen.wPtr,imdata);
        Screen('DrawTexture',PScreen.wPtr,tex);
        PScreen.vbl=Screen('Flip', PScreen.wPtr,PScreen.vbl+PScreen.ifi/2);
        WaitSecs(0.2);
        
        %stimulus presentation with recording of button presses
        [KeyIsDown, time, KeyCode]=KbCheck;
        Screen('TextSize',PScreen.wPtr,50);
%         DrawFormattedText(PScreen.wPtr,incongruent_trials(counter_incongruent,2),'center',PScreen.h_2-PScreen.h_10*2,PScreen.textColor);
%         DrawFormattedText(PScreen.wPtr,incongruent_trials(counter_incongruent,1),'center',PScreen.h_2,PScreen.textColor);
%         DrawFormattedText(PScreen.wPtr,incongruent_trials(counter_incongruent,2),'center',PScreen.h_2+PScreen.h_10*2,PScreen.textColor);
if incongruent_trials(counter_incongruent,3)==1
        DrawFormattedText(PScreen.wPtr,'<<><<','center',PScreen.h_2-PScreen.h_10/3,PScreen.textColor);    
elseif incongruent_trials(counter_incongruent,3)==-1
        DrawFormattedText(PScreen.wPtr,'>><>>','center',PScreen.h_2-PScreen.h_10/3,PScreen.textColor);
end
        [VBLTimestamp starttime]=Screen('Flip', PScreen.wPtr,PScreen.vbl+PScreen.ifi/2);
        onset=toc(start);
        [KeyIsDown, time, KeyCode]=KbCheck;
        check_inc=tic;
        while (GetSecs - starttime)<=1 %timeout after 1000ms
            [KeyIsDown, time, KeyCode]=KbCheck;
            if KeyCode(taste4) | KeyCode(taste7)
                rt(trial)=time-starttime;
                if KeyCode(taste4)
                pressed_button(trial)=4;
                elseif KeyCode(taste7)
                pressed_button(trial)=7;
                end
                if KeyCode(65)
                    disp a
                end
                while KbCheck;
                end
                if incongruent_trials(counter_incongruent,3)==1 & pressed_button(trial)==button_positive
                    accuracy(trial)=1;
                    counter_correct_incongruent=counter_correct_incongruent+1;
                    correct_incongruent_durations(counter_correct_incongruent)=rt(trial);
                    correct_incongruent_onsets(counter_correct_incongruent)=onset;
                elseif incongruent_trials(counter_incongruent,3)==-1 & pressed_button(trial)==button_negative
                    accuracy(trial)=1;
                    counter_correct_incongruent=counter_correct_incongruent+1;
                    correct_incongruent_durations(counter_correct_incongruent)=rt(trial);
                    correct_incongruent_onsets(counter_correct_incongruent)=onset;
                elseif incongruent_trials(counter_incongruent,3)==1 & pressed_button(trial)==button_negative
                    accuracy(trial)=-1;
                    counter_incorrect_incongruent=counter_incorrect_incongruent+1;
                    incorrect_incongruent_durations(counter_incorrect_incongruent)=rt(trial);
                    incorrect_incongruent_onsets(counter_incorrect_incongruent)=onset;
                elseif incongruent_trials(counter_incongruent,3)==-1 & pressed_button(trial)==button_positive
                    accuracy(trial)=-1;
                    counter_incorrect_incongruent=counter_incorrect_incongruent+1;
                    incorrect_incongruent_durations(counter_incorrect_incongruent)=rt(trial);
                    incorrect_incongruent_onsets(counter_incorrect_incongruent)=onset;
                end
                break,
            end
            WaitSecs(0.001);
        end
        % if no button was pressed within 1000ms, slightly scold the subject
        test_inc=toc(check_inc);
        if rt(trial)==0
            Screen('TextSize',PScreen.wPtr,50);
            message='No button press!';
            DrawFormattedText(PScreen.wPtr,message,'center','center',BlackIndex(PScreen.wPtr));
            PScreen.vbl=Screen('Flip', PScreen.wPtr,PScreen.vbl+PScreen.ifi/2);
            WaitSecs(0.3);
            counter_noresponse=counter_noresponse+1;
            noresponse_durations(counter_noresponse)=1;
            noresponse_onsets(counter_noresponse)=onset;
            accuracy(trial)=0;
        end
        
    end
    Screen('Close');
    
    %ITI 750...1250ms 
    iti(trial)=((750+jitter(trial))/1000);
    imdata=imread('fixation_cross.jpg');
    tex=Screen('MakeTexture',PScreen.wPtr,imdata);
    Screen('DrawTexture',PScreen.wPtr,tex);
    PScreen.vbl=Screen('Flip', PScreen.wPtr,PScreen.vbl+PScreen.ifi/2);
    %if the following trial is not a null event, i subtract the prewarning time from the ITI
    if trial<trials
        if list(trial+1)==0
            WaitSecs(iti(trial));
        elseif list(trial+1)==1 | list(trial+1)==2
            WaitSecs(iti(trial)-0.2);
        end
    end
    Screen('Close'); 
end

imdata=imread('fixation_cross.jpg');
tex=Screen('MakeTexture',PScreen.wPtr,imdata);
Screen('DrawTexture',PScreen.wPtr,tex);
PScreen.vbl=Screen('Flip', PScreen.wPtr,PScreen.vbl+PScreen.ifi/2);

  
% ptb window closes at the end of the scanning sequence 
% even a super fast subject with 0% no responses and an average rt of 750ms will need 174 volumes
% (50x1700+150x1750=85.000+262.500=348sec=174volumes)
% and a super slow subject with 33% no responses and an average rt just below the cutoff of 999ms will need 200 volumes
% (50x1700+100x2000+50x2300=85.000+200.000+115.000=400sec=200volumes)
% so if we are at vol 200 or later, we just wait till all 207 volumes are acquired
if toc(start)>=400
    while toc(start)<412
    pause(0.1)
    end
    % otherwise we wait 4+1 volumes to let the hrf return to baseline and then stop the scanner manually
else
    pause(8)
end
last_volume=ceil(toc(start)/2);
disp('eriksen run ',run, ': last_volume = ',last_volume)
 
% i only make failsafes for inexistent incorrect congruent trials, inexistent incorrect incongruent trials, and inexistent no response trials,
% because if correct trials of either trialtype don't exist, then the participant should better be excluded from the study
if counter_incorrect_congruent>0 & counter_incorrect_incongruent>0 & counter_noresponse>0
    save(['timings_subject' mat2str(subject) '_task2_run' mat2str(run) '.mat'],'pressed_button','rt','accuracy','correct_congruent_durations','correct_congruent_onsets',...
        'incorrect_congruent_durations','incorrect_congruent_onsets','correct_incongruent_durations','correct_incongruent_onsets',...
        'incorrect_incongruent_durations','incorrect_incongruent_onsets','noresponse_durations','noresponse_onsets','last_volume');
elseif counter_incorrect_congruent>0 & counter_incorrect_incongruent>0 & counter_noresponse==0
    save(['timings_subject' mat2str(subject) '_task2_run' mat2str(run) '.mat'],'pressed_button','rt','accuracy','correct_congruent_durations','correct_congruent_onsets',...
        'incorrect_congruent_durations','incorrect_congruent_onsets','correct_incongruent_durations','correct_incongruent_onsets',...
        'incorrect_incongruent_durations','incorrect_incongruent_onsets','last_volume');
elseif counter_incorrect_congruent>0 & counter_incorrect_incongruent==0 & counter_noresponse>0
    save(['timings_subject' mat2str(subject) '_task2_run' mat2str(run) '.mat'],'pressed_button','rt','accuracy','correct_congruent_durations','correct_congruent_onsets',...
        'incorrect_congruent_durations','incorrect_congruent_onsets','correct_incongruent_durations','correct_incongruent_onsets',...
        'noresponse_durations','noresponse_onsets','last_volume');
elseif counter_incorrect_congruent==0 & counter_incorrect_incongruent>0 & counter_noresponse>0
    save(['timings_subject' mat2str(subject) '_task2_run' mat2str(run) '.mat'],'pressed_button','rt','accuracy','correct_congruent_durations','correct_congruent_onsets',...
        'correct_incongruent_durations','correct_incongruent_onsets',...
        'incorrect_incongruent_durations','incorrect_incongruent_onsets','noresponse_durations','noresponse_onsets','last_volume');
elseif counter_incorrect_congruent==0 & counter_incorrect_incongruent==0 & counter_noresponse>0
    save(['timings_subject' mat2str(subject) '_task2_run' mat2str(run) '.mat'],'pressed_button','rt','accuracy','correct_congruent_durations','correct_congruent_onsets',...
        'correct_incongruent_durations','correct_incongruent_onsets',...
        'noresponse_durations','noresponse_onsets','last_volume');
elseif counter_incorrect_congruent==0 & counter_incorrect_incongruent>0 & counter_noresponse==0
    save(['timings_subject' mat2str(subject) '_task2_run' mat2str(run) '.mat'],'pressed_button','rt','accuracy','correct_congruent_durations','correct_congruent_onsets',...
        'correct_incongruent_durations','correct_incongruent_onsets',...
        'incorrect_incongruent_durations','incorrect_incongruent_onsets','last_volume');
elseif counter_incorrect_congruent>0 & counter_incorrect_incongruent==0 & counter_noresponse==0
    save(['timings_subject' mat2str(subject) '_task2_run' mat2str(run) '.mat'],'pressed_button','rt','accuracy','correct_congruent_durations','correct_congruent_onsets',...
        'incorrect_congruent_durations','incorrect_congruent_onsets','correct_incongruent_durations','correct_incongruent_onsets','last_volume');
end

Screen('TextSize',PScreen.wPtr,50);
if counter_noresponse>10
    DrawFormattedText(PScreen.wPtr,'Das war schon ganz gut - ','center',PScreen.h_2-PScreen.h_10*2,PScreen.textColor);
    DrawFormattedText(PScreen.wPtr,'nur noch etwas schneller werden','center',PScreen.h_2,PScreen.textColor);
else
    DrawFormattedText(PScreen.wPtr,'Das war super!','center',PScreen.h_2-PScreen.h_10/3,PScreen.textColor);
end
PScreen.vbl=Screen('Flip', PScreen.wPtr,PScreen.vbl+PScreen.ifi/2);

pause(2);
Screen('CloseAll');
ShowCursor;
fclose('all');
Priority(0);
return

end




