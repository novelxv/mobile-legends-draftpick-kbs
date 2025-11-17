% ===== TEST FILE UNTUK SISTEM DRAFT PICK MLBB =====

% Load sistem draft pick
:- include('draft_system.pl').

% ===== TEST CASES =====

% Test 1: First Pick Scenario
test_first_pick :-
    write('=== TEST FIRST PICK ==='), nl,
    BannedHeroes = [johnson, akai, estes],
    draft_recommendation(BannedHeroes, [], [], gold, Result),
    write('Banned Heroes: '), write(BannedHeroes), nl,
    write('User Lane: gold'), nl,
    write('Result: '), write(Result), nl, nl.

% Test 2: Counter Pick Scenario 
test_counter_pick :-
    write('=== TEST COUNTER PICK ==='), nl,
    BannedHeroes = [johnson, akai],
    EnemyHeroes = [fanny, eudora],
    TeamHeroes = [angela],
    draft_recommendation(BannedHeroes, EnemyHeroes, TeamHeroes, jungle, Result),
    write('Banned Heroes: '), write(BannedHeroes), nl,
    write('Enemy Heroes: '), write(EnemyHeroes), nl,
    write('Team Heroes: '), write(TeamHeroes), nl,
    write('User Lane: jungle'), nl,
    write('Result: '), write(Result), nl, nl.

% Test 3: Mid Game Pick Scenario
test_mid_game_pick :-
    write('=== TEST MID GAME PICK ==='), nl,
    BannedHeroes = [johnson, akai, estes, fanny],
    EnemyHeroes = [hayabusa, eudora, layla],
    TeamHeroes = [tigreal, harith],
    draft_recommendation(BannedHeroes, EnemyHeroes, TeamHeroes, exp, Result),
    write('Banned Heroes: '), write(BannedHeroes), nl,
    write('Enemy Heroes: '), write(EnemyHeroes), nl,
    write('Team Heroes: '), write(TeamHeroes), nl,
    write('User Lane: exp'), nl,
    write('Result: '), write(Result), nl, nl.

% Test 4: Late Pick Scenario (hampir lengkap)
test_late_pick :-
    write('=== TEST LATE PICK ==='), nl,
    BannedHeroes = [johnson, akai, estes, fanny, gusion, cecilion],
    EnemyHeroes = [hayabusa, eudora, layla, bruno, chou],
    TeamHeroes = [tigreal, harith, angela, granger],
    draft_recommendation(BannedHeroes, EnemyHeroes, TeamHeroes, roam, Result),
    write('Banned Heroes: '), write(BannedHeroes), nl,
    write('Enemy Heroes: '), write(EnemyHeroes), nl,
    write('Team Heroes: '), write(TeamHeroes), nl,
    write('User Lane: roam'), nl,
    write('Result: '), write(Result), nl, nl.

% Test 5: Specific Counter Scenario
test_specific_counter :-
    write('=== TEST SPECIFIC COUNTER ==='), nl,
    BannedHeroes = [],
    EnemyHeroes = [layla, eudora],  % Heroes dengan banyak counter
    TeamHeroes = [],
    draft_recommendation(BannedHeroes, EnemyHeroes, TeamHeroes, jungle, Result),
    write('Enemy Heroes: '), write(EnemyHeroes), nl,
    write('User Lane: jungle'), nl,
    write('Looking for counters to: layla, eudora'), nl,
    write('Result: '), write(Result), nl, nl.

% Test 6: Jungle-Roam Combination Rules
test_jungle_roam_rules :-
    write('=== TEST JUNGLE-ROAM COMBINATION RULES ==='), nl,
    
    % Test 6a: Need roam tank for jungle assassin
    write('6a. Need roam tank (team has jungle assassin):'), nl,
    BannedHeroes1 = [],
    EnemyHeroes1 = [],
    TeamHeroes1 = [hayabusa, harith, granger],  % hayabusa = jungle assassin
    draft_recommendation(BannedHeroes1, EnemyHeroes1, TeamHeroes1, roam, Result1),
    write('Team: '), write(TeamHeroes1), nl,
    write('Need roam for jungle assassin (hayabusa)'), nl,
    write('Expected: Tank roamers prioritized'), nl,
    write('Result: '), write(Result1), nl, nl,
    
    % Test 6b: Need roam support for jungle fighter  
    write('6b. Need roam support (team has jungle fighter):'), nl,
    BannedHeroes2 = [],
    EnemyHeroes2 = [],
    TeamHeroes2 = [alpha, harith, granger],  % alpha = jungle fighter
    draft_recommendation(BannedHeroes2, EnemyHeroes2, TeamHeroes2, roam, Result2),
    write('Team: '), write(TeamHeroes2), nl,
    write('Need roam for jungle fighter (alpha)'), nl,
    write('Expected: Support roamers prioritized'), nl,
    write('Result: '), write(Result2), nl, nl.

% Test utility functions
test_utilities :-
    write('=== TEST UTILITY FUNCTIONS ==='), nl,
    
    % Test flexibility score
    write('Flexibility scores:'), nl,
    flexibility_score(chou, ChouScore),
    write('Chou: '), write(ChouScore), nl,
    flexibility_score(angela, AngelaScore),
    write('Angela: '), write(AngelaScore), nl,
    flexibility_score(layla, LaylaScore),
    write('Layla: '), write(LaylaScore), nl,
    
    % Test counter detection
    write('Counter tests:'), nl,
    (is_counter_pick(saber, [layla, eudora]) -> 
        write('Saber counters layla/eudora: YES') ; 
        write('Saber counters layla/eudora: NO')), nl,
    
    % Test team analysis
    TestTeam = [tigreal, harith, angela],
    analyze_team_composition(TestTeam, Analysis),
    write('Team analysis for [tigreal, harith, angela]: '), write(Analysis), nl,
    
    % Test role diversity
    count_unique_roles([tigreal, harith, angela], Diversity1),
    write('Role diversity for [tigreal, harith, angela]: '), write(Diversity1), nl,
    
    % Test adds_role_diversity
    (adds_role_diversity(chou, [tigreal, harith]) ->
        write('Chou adds role diversity to [tigreal, harith]: YES') ;
        write('Chou adds role diversity to [tigreal, harith]: NO')), nl,
    
    % Test jungle-roam combination
    TestJungleAssassin = [hayabusa, tigreal, harith],  % jungle assassin + roam tank
    analyze_team_composition(TestJungleAssassin, JRAnalysis1),
    write('Jungle Assassin + Roam Tank analysis: '), write(JRAnalysis1), nl,
    
    TestJungleFighter = [alpha, angela, harith],  % jungle fighter + roam support
    analyze_team_composition(TestJungleFighter, JRAnalysis2), 
    write('Jungle Fighter + Roam Support analysis: '), write(JRAnalysis2), nl,
    nl.

% Run semua test
run_all_tests :-
    write('========================================'), nl,
    write('  MOBILE LEGENDS DRAFT PICK SYSTEM'), nl,
    write('========================================'), nl, nl,
    test_utilities,
    test_first_pick,
    test_counter_pick,
    test_mid_game_pick,
    test_late_pick,
    test_specific_counter,
    test_jungle_roam_rules,
    write('========================================'), nl,
    write('           ALL TESTS COMPLETED'), nl,
    write('========================================'), nl.

% Shortcut untuk menjalankan test
:- initialization(run_all_tests).