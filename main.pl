% ===== MAIN FILE - MOBILE LEGENDS DRAFT PICK SYSTEM =====

% Load sistem
:- include('draft_system.pl').

% ===== INTERFACE =====

% Query untuk first pick
first_pick_gold :-
    write('=== FIRST PICK RECOMMENDATION (GOLD LANE) ==='), nl,
    draft_recommendation([], [], [], gold, Result),
    write('Result: '), write(Result), nl.

first_pick_jungle :-
    write('=== FIRST PICK RECOMMENDATION (JUNGLE) ==='), nl,
    draft_recommendation([], [], [], jungle, Result),
    write('Result: '), write(Result), nl.

% Query untuk counter pick
counter_fanny :-
    write('=== COUNTER PICK: Enemy has Fanny ==='), nl,
    draft_recommendation([], [fanny], [], jungle, Result),
    write('Result: '), write(Result), nl.

counter_layla_eudora :-
    write('=== COUNTER PICK: Enemy has Layla + Eudora ==='), nl,
    draft_recommendation([], [layla, eudora], [], jungle, Result),
    write('Result: '), write(Result), nl.

% Query tim hampir lengkap
complete_team :-
    write('=== COMPLETE TEAM: Need EXP Laner ==='), nl,
    draft_recommendation([johnson, fanny], [hayabusa, eudora, layla], [tigreal, harith, angela, granger], exp, Result),
    write('Result: '), write(Result), nl.

% Query jungle-roam combination: need tank roam for assassin jungle
jungle_assassin_need_tank :-
    write('=== JUNGLE-ROAM RULE: Assassin Jungle needs Tank Roam ==='), nl,
    draft_recommendation([], [], [hayabusa, harith, granger], roam, Result),
    write('Team has: hayabusa (jungle assassin), harith (mid), granger (gold)'), nl,
    write('Expected: Tank roamers get priority bonus'), nl,
    write('Result: '), write(Result), nl.

% Query jungle-roam combination: need support roam for fighter jungle  
jungle_fighter_need_support :-
    write('=== JUNGLE-ROAM RULE: Fighter Jungle needs Support Roam ==='), nl,
    draft_recommendation([], [], [alpha, harith, granger], roam, Result),
    write('Team has: alpha (jungle fighter), harith (mid), granger (gold)'), nl,
    write('Expected: Support roamers get priority bonus'), nl,
    write('Result: '), write(Result), nl.

% Demo
demo :-
    write('========================================'), nl,
    write('  MOBILE LEGENDS DRAFT PICK DEMO'), nl,
    write('========================================'), nl, nl,
    first_pick_gold,
    nl,
    first_pick_jungle,  
    nl,
    counter_fanny,
    nl,
    counter_layla_eudora,
    nl,
    complete_team,
    nl,
    jungle_assassin_need_tank,
    nl,
    jungle_fighter_need_support,
    nl,
    write('========================================'), nl,
    write('           DEMO COMPLETED'), nl,
    write('========================================'), nl.

% Help
help :-
    write('========================================'), nl,
    write('  MOBILE LEGENDS DRAFT PICK SYSTEM'), nl,
    write('========================================'), nl,
    write('Available commands:'), nl,
    write('  ?- demo.                    % Run full demo'), nl,
    write('  ?- first_pick_gold.         % First pick for gold lane'), nl,
    write('  ?- first_pick_jungle.       % First pick for jungle'), nl,
    write('  ?- counter_fanny.           % Counter when enemy has Fanny'), nl,
    write('  ?- counter_layla_eudora.    % Counter Layla + Eudora'), nl,
    write('  ?- complete_team.           % Complete team scenario'), nl,
    write('  ?- jungle_assassin_need_tank. % Demo jungle-roam rule 1'), nl,
    write('  ?- jungle_fighter_need_support. % Demo jungle-roam rule 2'), nl,
    write('  ?- help.                    % Show this help'), nl,
    nl,
    write('Manual query format:'), nl,
    write('  ?- draft_recommendation(BannedList, EnemyList, TeamList, Lane, Result).'), nl,
    nl,
    write('Examples:'), nl,
    write('  ?- draft_recommendation([], [], [], gold, R).'), nl,
    write('  ?- draft_recommendation([johnson], [fanny], [angela], jungle, R).'), nl,
    write('========================================'), nl.

% Auto-run demo saat load
:- initialization(help).