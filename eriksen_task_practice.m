clear all
screens = Screen('Screens');
myscreens = Screen('Screens');
screenid = myscreens(1);
PScreen.white=WhiteIndex(screenid);
PScreen.black=BlackIndex(screenid);
PScreen.gray=(9.7*PScreen.white+0.3*PScreen.black)/10;
Screen('Preference', 'SkipSyncTests', 0) %not necessary here, only to let the subjects get used to ptb's alarmistic warning
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
P.day = 'first';
P.NFRunNr=1;
P.SubjectID=1;

load('practicelist.mat');
list=practicelist(20:50,1); %there are many null events to familiarize the subjects with the long pauses

positive_stimuli=(1:400);
negative_stimuli=(-400:-1);

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

if P.day == 'first'
    index=(P.NFRunNr-1)*50;
elseif P.day == 'last'
    index=(P.NFRunNr-1)*50+200;
end

%pairing of targets and distractors to trials:
%the event lists don't have all exactly the same number of
%congruent and incongruent trials, but i checked:
%no list has more than 50 trials of either type
congruent_trials(1:25,1)=positive_targets(index+1:index+25);
congruent_trials(26:50,1)=negative_targets(index+1:index+25);
incongruent_trials(1:25,1)=positive_targets(index+26:index+50);
incongruent_trials(26:50,1)=negative_targets(index+26:index+50);

congruent_trials(1:25,2)=positive_distractors(index+1:index+25);
congruent_trials(26:50,2)=negative_distractors(index+1:index+25);
incongruent_trials(1:25,2)=negative_distractors(index+26:index+50);
incongruent_trials(26:50,2)=positive_distractors(index+26:index+50);

%a column indicating whether the target was positive or negative so that i
%can easily compare it to the button press
congruent_trials(1:25,3)=1;
congruent_trials(26:50,3)=-1;
incongruent_trials(1:25,3)=1;
incongruent_trials(26:50,3)=-1;

random3=randi(1000,[1,50]);
random4=randi(1000,[1,50]);
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

trials=30;
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
start = tic;
for trial=1:20 %300;
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
                temp=KbName(KeyCode);
                pressed_button(trial)=str2num(temp(1));
                rt(trial)=time-starttime;
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
        % if no button was pressed within 1000ms, i slightly scold the subject
        test_con=toc(check_con);
        if rt(trial)==0
            Screen('TextSize',PScreen.wPtr,50);
            message='Kein Tastendruck!';
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
                temp=KbName(KeyCode);
                pressed_button(trial)=str2num(temp(1));
                rt(trial)=time-starttime;
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
        % if no button was pressed within 1000ms, i slightly scold the subject
        test_inc=toc(check_inc);
        if rt(trial)==0
            Screen('TextSize',PScreen.wPtr,50);
            message='Kein Tastendruck!';
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
    
    %ITI 750...1250ms - hopefully long enough for the depressed patients...
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

Screen('CloseAll');
ShowCursor;
fclose('all');
Priority(0);
return;




