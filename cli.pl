% ===== MOBILE LEGENDS DRAFT PICK CLI =====

:- include('draft_system.pl').

% ===== MAIN CLI INTERFACE =====

start_cli :-
    clear_screen,
    show_banner,
    main_menu.

% Banner dan header
show_banner :-
    write('==============================================================='), nl,
    write('           MOBILE LEGENDS DRAFT PICK SYSTEM               '), nl,
    write('                    Command Line Interface                 '), nl,
    write('==============================================================='), nl,
    nl.

% Clear screen
clear_screen :-
    (   current_prolog_flag(windows, true)
    ->  (shell('cls') ; true)
    ;   (shell('clear') ; true)
    ).

% Main menu
main_menu :-
    write('Pilih mode:'), nl,
    write('1. Draft Pick Recommendation'), nl,
    write('2. Team Analysis'), nl,
    write('3. Hero Info'), nl,
    write('4. Exit'), nl,
    write('Pilihan (1-4): '),
    read(Choice),
    handle_menu_choice(Choice).

handle_menu_choice(1) :- !, draft_pick_mode.
handle_menu_choice(2) :- !, team_analysis_mode.
handle_menu_choice(3) :- !, hero_info_mode.
handle_menu_choice(4) :- !, 
    write('Terima kasih telah menggunakan Mobile Legends Draft Pick System!'), nl,
    halt.
handle_menu_choice(_) :- 
    write('Pilihan tidak valid. Silakan pilih 1-4.'), nl, nl,
    main_menu.

% ===== DRAFT PICK MODE =====

draft_pick_mode :-
    nl,
    write('==============================================================='), nl,
    write('                DRAFT PICK RECOMMENDATION'), nl,
    write('==============================================================='), nl,
    nl,
    
    % Input banned heroes
    write('STEP 1: Masukkan hero yang di-ban'), nl,
    write('Format: [hero1, hero2, hero3] atau [] jika kosong'), nl,
    write('Contoh: [fanny, johnson, akai]'), nl,
    write('Banned heroes: '),
    read(BannedHeroes),
    
    % Validate banned heroes
    (validate_hero_list(BannedHeroes) -> 
        true 
    ; 
        write('Error: Ada hero yang tidak valid dalam banned list.'), nl,
        draft_pick_mode
    ),
    
    nl,
    % Input enemy heroes
    write('STEP 2: Masukkan hero yang sudah dipick musuh (0-5 hero)'), nl,
    write('Format: [hero1, hero2] atau [] jika kosong'), nl,
    write('Enemy heroes: '),
    read(EnemyHeroes),
    
    % Validate enemy heroes
    (validate_hero_list(EnemyHeroes) -> 
        true 
    ; 
        write('Error: Ada hero yang tidak valid dalam enemy list.'), nl,
        draft_pick_mode
    ),
    
    % Check enemy count
    length(EnemyHeroes, EnemyCount),
    (EnemyCount =< 5 -> 
        true 
    ; 
        write('Error: Enemy heroes tidak boleh lebih dari 5.'), nl,
        draft_pick_mode
    ),
    
    nl,
    % Input team heroes
    write('STEP 3: Masukkan hero yang sudah dipick tim (0-4 hero)'), nl,
    write('Format: [hero1-lane1, hero2-lane2] atau [hero1, hero2] atau [] jika kosong'), nl,
    write('Contoh: [kimmy-mid, esmeralda-exp] atau [tigreal-roam, harith-mid]'), nl,
    write('Team heroes: '),
    read(TeamHeroes),
    
    % Validate team heroes (support hero-lane format)
    (validate_hero_lane_list(TeamHeroes) -> 
        true 
    ; 
        write('Error: Ada hero yang tidak valid dalam team list.'), nl,
        write('Format yang benar: [hero1-lane1, hero2-lane2] atau [hero1, hero2]'), nl,
        draft_pick_mode
    ),
    
    % Check team count
    length(TeamHeroes, TeamCount),
    (TeamCount =< 4 -> 
        true 
    ; 
        write('Error: Team heroes tidak boleh lebih dari 4.'), nl,
        draft_pick_mode
    ),
    
    nl,
    % Input user lane
    write('STEP 4: Pilih lane yang ingin dimainkan'), nl,
    write('Pilihan: gold, mid, exp, jungle, roam'), nl,
    write('Lane: '),
    read(UserLane),
    
    % Validate lane
    (lane(UserLane) -> 
        true 
    ; 
        write('Error: Lane tidak valid. Pilihan: gold, mid, exp, jungle, roam'), nl,
        draft_pick_mode
    ),
    
    nl,
    % Process recommendation
    process_draft_recommendation(BannedHeroes, EnemyHeroes, TeamHeroes, UserLane),
    
    % Ask for continue
    nl,
    write('Tekan Enter untuk kembali ke menu utama...'),
    get_char(_),
    main_menu.

% Process and display draft recommendation
process_draft_recommendation(BannedHeroes, EnemyHeroes, TeamHeroes, UserLane) :-
    write('==============================================================='), nl,
    write('                    HASIL REKOMENDASI'), nl,
    write('==============================================================='), nl,
    nl,
    
    % Show input summary
    write('RINGKASAN INPUT:'), nl,
    write('   Banned Heroes: '), write(BannedHeroes), nl,
    write('   Enemy Heroes:  '), write(EnemyHeroes), nl,
    write('   Team Heroes:   '), write(TeamHeroes), nl,
    write('   Your Lane:     '), write(UserLane), nl,
    nl,
    
    % Get recommendation
    draft_recommendation(BannedHeroes, EnemyHeroes, TeamHeroes, UserLane, Result),
    
    % Display results
    display_recommendation_result(Result, TeamHeroes),
    
    % Show additional analysis
    show_additional_analysis(BannedHeroes, EnemyHeroes, TeamHeroes, UserLane).

% Display recommendation results
display_recommendation_result(first_pick_recommendations(Recommendations), _) :-
    write('FIRST PICK RECOMMENDATIONS:'), nl,
    (Recommendations = [] ->
        write('   Tidak ada rekomendasi tersedia.'), nl
    ;
        display_hero_recommendations(Recommendations)
    ).

display_recommendation_result(draft_analysis(Recommendations, TeamAnalysis, EnemyThreats), TeamHeroes) :-
    write('HERO RECOMMENDATIONS:'), nl,
    (Recommendations = [] ->
        write('   Tidak ada rekomendasi tersedia untuk lane ini.'), nl,
        write('   Kemungkinan penyebab:'), nl,
        write('      - Lane sudah terisi oleh hero lain dalam tim'), nl,
        write('      - Semua hero untuk lane ini sudah di-ban/dipick'), nl
    ;
        display_hero_recommendations(Recommendations)
    ),
    nl,
    
    write('TEAM ANALYSIS:'), nl,
    display_team_analysis(TeamAnalysis, TeamHeroes),
    nl,
    
    write('ENEMY THREATS & COUNTERS:'), nl,
    display_enemy_threats(EnemyThreats).

% Display hero recommendations with details
display_hero_recommendations(Recommendations) :-
    write('   Rank | Hero          | Priority | Roles'), nl,
    write('   -----|---------------|----------|----------------'), nl,
    display_recommendations_numbered(Recommendations, 1).

display_recommendations_numbered([], _).
display_recommendations_numbered([hero_priority(Hero, Priority)|Rest], Num) :-
    format('   ~w.   | ~w~t~15| | ~w~t~9| |', [Num, Hero, Priority]),
    findall(Role, memiliki_role(Hero, Role), Roles),
    format(' ~w~n', [Roles]),
    Num1 is Num + 1,
    display_recommendations_numbered(Rest, Num1).

% Display team analysis
display_team_analysis(team_analysis(_RoleCounts, _LaneCounts, RoleDiversity, MissingLanes, DamageBalance, JungleRoamValid, DuplicatedLanes, LaneValidation), TeamHeroes) :-
    write('   Role Diversity: '), write(RoleDiversity), write('/6'), nl,
    
    write('   Missing Lanes: '),
    (MissingLanes = [] -> 
        write('None (All lanes covered)') 
    ; 
        write(MissingLanes)
    ), nl,
    
    write('   Damage Balance: '), write(DamageBalance), nl,
    
    write('   Jungle-Roam Combo: '), write(JungleRoamValid), nl,
    
    write('   Lane Validation: '), write(LaneValidation),
    (LaneValidation = invalid ->
        (write(' (Duplicated: '), write(DuplicatedLanes), write(')'))
    ;
        true
    ), nl,
    
    % Show current team composition
    length(TeamHeroes, TeamSize),
    write('   Team Size: '), write(TeamSize), write('/5'), nl.

% Display enemy threats
display_enemy_threats([]) :-
    write('   Belum ada hero musuh yang dipick.'), nl.
display_enemy_threats(Threats) :-
    display_threats_list(Threats).

display_threats_list([]).
display_threats_list([threat(Enemy, Counters)|Rest]) :-
    write('   '), write(Enemy), write(' -> Counter dengan: '),
    (Counters = [] ->
        write('(Tidak ada counter yang terdaftar)')
    ;
        write_counter_list(Counters)
    ), nl,
    display_threats_list(Rest).

write_counter_list([]).
write_counter_list([Counter]) :- 
    write(Counter).
write_counter_list([Counter|Rest]) :-
    write(Counter), write(', '),
    write_counter_list(Rest).

% Show additional analysis
show_additional_analysis(_BannedHeroes, EnemyHeroes, TeamHeroes, _UserLane) :-
    nl,
    write('TIPS & ANALYSIS:'), nl,
    
    % Check if it's first pick
    (EnemyHeroes = [], TeamHeroes = [] ->
        write('   First Pick: Pilih hero fleksibel yang sulit di-counter'), nl
    ;
        true
    ),
    
    % Check lane coverage
    findall(Lane, (lane(Lane), \+ lane_terpenuhi(Lane, TeamHeroes)), MissingLanes),
    (MissingLanes \= [] ->
        write('   Lane yang masih kosong: '), write(MissingLanes), nl
    ;
        true
    ),
    
    % Check role diversity
    count_unique_roles(TeamHeroes, RoleDiversity),
    (RoleDiversity < 3, TeamHeroes \= [] ->
        write('   Pertimbangkan menambah variasi role untuk fleksibilitas'), nl
    ;
        true
    ),
    
    % Check damage balance
    (\+ has_damage_balance(TeamHeroes), TeamHeroes \= [] ->
        write('   Tim perlu keseimbangan physical dan magic damage'), nl
    ;
        true
    ).

% ===== TEAM ANALYSIS MODE =====

team_analysis_mode :-
    nl,
    write('==============================================================='), nl,
    write('                     TEAM ANALYSIS'), nl,
    write('==============================================================='), nl,
    nl,
    
    write('Masukkan komposisi tim untuk dianalisis:'), nl,
    write('Format: [hero1-lane1, hero2-lane2, hero3-lane3, hero4-lane4, hero5-lane5]'), nl,
    write('Contoh: [kimmy-mid, esmeralda-exp, tigreal-roam, granger-gold, hayabusa-jungle]'), nl,
    write('Tim: '),
    read(Team),
    
    (validate_hero_lane_list(Team) ->
        (analyze_team_composition(Team, Analysis),
         display_detailed_team_analysis(Team, Analysis))
    ;
        write('Error: Ada hero yang tidak valid dalam list.')
    ),
    
    nl,
    write('Tekan Enter untuk kembali ke menu utama...'),
    get_char(_),
    main_menu.

display_detailed_team_analysis(Team, team_analysis(RoleCounts, LaneCounts, RoleDiversity, MissingLanes, DamageBalance, JungleRoamValid, DuplicatedLanes, LaneValidation)) :-
    nl,
    write('DETAILED TEAM ANALYSIS'), nl,
    write('==============================================================='), nl,
    
    write('Team: '), write(Team), nl,
    length(Team, Size),
    write('Size: '), write(Size), write('/5 heroes'), nl,
    write('Lane Assignments:'), nl,
    display_team_lane_assignments(Team), nl,
    
    write('ROLE DISTRIBUTION:'), nl,
    display_role_counts(RoleCounts),
    nl,
    
    write('LANE DISTRIBUTION:'), nl,
    display_lane_counts(LaneCounts),
    nl,
    
    write('STATISTICS:'), nl,
    write('   Role Diversity: '), write(RoleDiversity), write('/6'), nl,
    write('   Damage Balance: '), write(DamageBalance), nl,
    write('   Jungle-Roam Combo: '), write(JungleRoamValid), nl,
    write('   Lane Validation: '), write(LaneValidation), nl,
    
    (MissingLanes \= [] ->
        (write('   Missing Lanes: '), write(MissingLanes), nl)
    ;
        write('   Missing Lanes: None'), nl
    ),
    
    (DuplicatedLanes \= [] ->
        (write('   Duplicated Lanes: '), write(DuplicatedLanes), nl)
    ;
        write('   Duplicated Lanes: None'), nl
    ), nl,
    
    write('RECOMMENDATIONS:'), nl,
    give_team_recommendations(Team, RoleDiversity, DamageBalance, MissingLanes, DuplicatedLanes).

display_role_counts([]).
display_role_counts([Role-Count|Rest]) :-
    format('   ~w: ~w heroes~n', [Role, Count]),
    display_role_counts(Rest).

display_lane_counts([]).
display_lane_counts([Lane-Count|Rest]) :-
    format('   ~w: ~w heroes~n', [Lane, Count]),
    display_lane_counts(Rest).

give_team_recommendations(Team, RoleDiversity, DamageBalance, MissingLanes, DuplicatedLanes) :-
    length(Team, Size),
    (Size < 5 ->
        write('   Tim belum lengkap, pertimbangkan:'), nl,
        (MissingLanes \= [] ->
            (write('      - Tambah hero untuk lane: '), write(MissingLanes), nl)
        ;
            true
        ),
        (RoleDiversity < 4 ->
            write('      - Tambah variasi role untuk fleksibilitas'), nl
        ;
            true
        ),
        (DamageBalance = unbalanced ->
            write('      - Perhatikan keseimbangan physical/magic damage'), nl
        ;
            true
        )
    ;
        write('   Tim sudah lengkap (5 heroes)'), nl
    ),
    
    (DuplicatedLanes \= [] ->
        write('   Ada duplikasi lane yang perlu diperbaiki'), nl
    ;
        true
    ).

% ===== HERO INFO MODE =====

hero_info_mode :-
    nl,
    write('==============================================================='), nl,
    write('                       HERO INFO'), nl,
    write('==============================================================='), nl,
    nl,
    
    write('Masukkan nama hero untuk melihat informasi detail:'), nl,
    write('Hero: '),
    read(Hero),
    
    (hero(Hero) ->
        display_hero_info(Hero)
    ;
        write('Error: Hero tidak ditemukan dalam database.')
    ),
    
    nl,
    write('Tekan Enter untuk kembali ke menu utama...'),
    get_char(_),
    main_menu.

display_hero_info(Hero) :-
    nl,
    write('HERO INFORMATION: '), write(Hero), nl,
    write('==============================================================='), nl,
    
    write('Roles: '),
    findall(Role, memiliki_role(Hero, Role), Roles),
    write(Roles), nl,
    
    write('Lanes: '),
    findall(Lane, memiliki_lane(Hero, Lane), Lanes),
    write(Lanes), nl,
    
    write('Damage Type: '),
    findall(DmgType, memiliki_damage_type(Hero, DmgType), DamageTypes),
    write(DamageTypes), nl,
    
    write('Specialties: '),
    findall(Spec, has_specialty(Hero, Spec), Specialties),
    write(Specialties), nl,
    
    nl,
    write('COUNTERS (Heroes that counter this hero):'), nl,
    findall(Counter, iscounter(Counter, Hero), Counters),
    (Counters = [] ->
        write('   No registered counters')
    ;
        write('   '), write(Counters)
    ), nl,
    
    nl,
    write('CAN COUNTER (Heroes this hero can counter):'), nl,
    findall(Target, iscounter(Hero, Target), Targets),
    (Targets = [] ->
        write('   No registered targets')
    ;
        write('   '), write(Targets)
    ), nl,
    
    nl,
    write('SYNERGIES (Compatible heroes):'), nl,
    findall(Ally, compatible(Hero, Ally), Allies),
    (Allies = [] ->
        write('   No registered synergies')
    ;
        write('   '), write(Allies)
    ), nl,
    
    % Calculate flexibility score
    flexibility_score(Hero, FlexScore),
    write('Flexibility Score: '), write(FlexScore), nl.

% ===== VALIDATION HELPERS =====

validate_hero_list([]).
validate_hero_list([Hero|Rest]) :-
    hero(Hero),
    validate_hero_list(Rest).

% Validasi untuk format hero-lane
validate_hero_lane_list([]).
validate_hero_lane_list([Hero-Lane|Rest]) :-
    hero(Hero),
    lane(Lane),
    validate_hero_lane_list(Rest).
validate_hero_lane_list([Hero|Rest]) :-
    hero(Hero),
    validate_hero_lane_list(Rest).

% Display lane assignments tim
display_team_lane_assignments([]).
display_team_lane_assignments([Hero-Lane|Rest]) :-
    format('   ~w -> ~w~n', [Hero, Lane]),
    display_team_lane_assignments(Rest).
display_team_lane_assignments([Hero|Rest]) :-
    format('   ~w -> (lane tidak dispesifikasi)~n', [Hero]),
    display_team_lane_assignments(Rest).