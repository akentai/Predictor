clear all;
close all;
clc;

%% LCK Teams
teamInd = 1:1:10;
startElo = [1000 900 1000 1100 900 900 1100 1000 900 1100]; 
Nteams = length(teamInd);
history = 4;

%%
% Matches, Win(Match), Streak, elo, Games, Win(Game)
% Weeks 1-10, 18 matches for every team, 90 series in total

Nseries = 90;
statsBefore = zeros(Nseries, 10);
teamStats = zeros(Nteams, 6 + history );
teamStats(:,4) = startElo';

%Spring Scores and Teams
scores = [ 2 0 2 0 1 2 0 2 0 2 0 2 2 0 2 0 0 2 0 2 0 2 0 2 2 1 1 2 2 0 0 2 2 0 2 0 2 1 1 2 ...
           1 2 2 0 2 0 2 1 2 0 0 2 0 2 2 1 2 1 2 0 2 0 2 1 2 0 2 0 2 0 2 0 1 2 0 2 2 0 2 1 ...
           0 2 0 2 0 2 2 1 0 2 0 2 0 2 2 0 2 1 2 1 2 0 2 0 2 0 2 0 1 2 0 2 1 2 0 2 ...
           2 1 2 1 1 2 2 1 2 0 0 2 0 2 0 2 ...
           0 2 2 1 2 0 2 1 2 1 1 2 1 2 0 2 ...
           2 0 2 0 0 2 2 0 0 2 2 0 0 2 1 2 ...
           0 2 0 2 2 0 0 2 2 1 2 0 0 2 0 2 ];
       
scores = reshape(scores, 2, Nseries)';

teams = [ 10 6 2 3 8 5 7 4 3 9 1 10 2 8 4 6 7 9 1 5 8 7 5 4 9 10 3 1 8 6 2 4 7 1 9 5 10 2 6 3 ...
          2 9 1 6 4 10 3 8 7 2 6 5 1 8 4 9 7 3 10 5 5 3 10 7 2 1 9 6 4 8 5 7 3 10 6 2 4 1 9 8 ...
          3 4 8 10 6 7 1 9 5 2 8 4 9 7 3 6 2 10 5 1 9 1 2 6 7 5 10 3 1 2 6 9 3 5 7 10 ...
          9 2 6 1 10 4 8 3 5 6 2 7 8 1 9 4 4 3 10 8 7 6 2 5 1 4 8 9 5 10 3 7 ...
          4 5 7 8 1 3 10 9 6 8 4 2 5 9 1 7 6 10 3 2 5 8 4 7 9 3 10 1 6 4 8 2 ];
teams = reshape(teams, 2, Nseries)';
result = zeros(Nseries,1);

for i = 1:Nseries
    
    % Which teams are playing
    teamA = teams(i,1);
    teamB = teams(i,2);
    statsBefore(i, :) = [teamStats(teamA,1:4) teamStats(teamA,6)/teamStats(teamA,5) ...
                        teamStats(teamB,1:4) teamStats(teamB,6)/teamStats(teamB,5)];
    
    % Elo of these teams
    eloA = teamStats(teamA, 4);
    eloB = teamStats(teamB, 4);
    
    % Games won for every team in this serie
    gameA = scores(i, 1);
    gameB = scores(i, 2);
    
    if gameA + gameB < 2 || teamA == teamB
        display('Error');
        display(i);
        break;
    end
    
    % Increase Series/Games played for these teams
    teamStats(teamA,1) = teamStats(teamA,1) + 1;
    teamStats(teamB,1) = teamStats(teamB,1) + 1;
    teamStats(teamA,5:6) = teamStats(teamA,5:6) + [gameA+gameB gameA];
    teamStats(teamB,5:6) = teamStats(teamB,5:6) + [gameA+gameB gameB];
    
    strikeA = circshift( teamStats(teamA, 7:end)', 1 );
    strikeB = circshift( teamStats(teamB, 7:end)', 1 );
    
    % Team A won Team B
    if gameA > gameB
        % Increase Won Series for Team A
        teamStats(teamA,2) = teamStats(teamA,2) + 1;
        
        % Increase Streak for Team A and decrease for Team B
        strikeA(1) = 1;
        teamStats(teamA, 7:end) = strikeA;
        teamStats(teamA,3) = sum(strikeA);
        
        strikeB(1) = -1;
        teamStats(teamB, 7:end) = strikeB;
        teamStats(teamB,3) = sum(strikeB);

        flagA = 1;
        flagB = 0;
        result(i) = 1;
        
    % Team B won Team A
    else  
        % Increase Won Series for Team B
        teamStats(teamB,2) = teamStats(teamB,2) + 1;
        
        % Increase Streak for Team B and decrease for Team A
        strikeA(1) = -1;
        teamStats(teamA, 7:end) = strikeA;
        teamStats(teamA,3) = sum(strikeA);
        
        strikeB(1) = 1;
        teamStats(teamB, 7:end) = strikeB;
        teamStats(teamB,3) = sum(strikeB);
        
        flagA = 0;
        flagB = 1;
        result(i) = -1;
    end
    
    PA = 1/( 10^( -(eloA-eloB)/400 ) + 1);
    PB = 1 - PA;
    if gameA + gameB == 2
        K = 40;
    else
        K = 30;
    end
    
    % Update elo for each team
    teamStats(teamA,4) = round(eloA + K*(flagA - PA));
    teamStats(teamB,4) = round(eloB + K*(flagB - PB));
   
end

teamStats = teamStats(:,1:6);
output = [statsBefore  result];