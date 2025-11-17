% ===== SISTEM REKOMENDASI DRAFT PICK MOBILE LEGENDS =====

% Include semua fakta yang diperlukan
:- include('facts/hero.pl').
:- include('facts/role.pl').
:- include('facts/lane.pl').
:- include('facts/damage_type.pl').
:- include('facts/specialty.pl').
:- include('facts/compatible.pl').
:- include('facts/counter.pl').

% ===== UTILITY PREDICATES =====

% Cek apakah hero tidak dibanned dan tidak dipick tim/musuh
hero_tersedia(Hero, BannedHeroes, EnemyHeroes, TeamHeroes) :-
    hero(Hero),
    \+ member(Hero, BannedHeroes),
    \+ member(Hero, EnemyHeroes),
    \+ member(Hero, TeamHeroes).

% Hitung jumlah hero per role dalam tim
count_role_in_team(Role, Team, Count) :-
    findall(Hero, (member(Hero, Team), memiliki_role(Hero, Role)), RoleHeroes),
    length(RoleHeroes, Count).

% Hitung jumlah hero per lane dalam tim
count_lane_in_team(Lane, Team, Count) :-
    findall(Hero, (member(Hero, Team), memiliki_lane(Hero, Lane)), LaneHeroes),
    length(LaneHeroes, Count).

% Cek apakah lane sudah terpenuhi dalam tim (minimal 1)
lane_terpenuhi(Lane, Team) :-
    count_lane_in_team(Lane, Team, Count),
    Count > 0.

% Cek apakah tim kekurangan lane tertentu
lane_dibutuhkan(Lane, Team) :-
    lane(Lane),
    \+ lane_terpenuhi(Lane, Team).

% Hitung jumlah role yang berbeda dalam tim
count_unique_roles(Team, UniqueRoleCount) :-
    findall(Role, (member(Hero, Team), memiliki_role(Hero, Role)), AllRoles),
    sort(AllRoles, UniqueRoles),
    length(UniqueRoles, UniqueRoleCount).

% Cek apakah hero menambah diversity role ke tim
adds_role_diversity(Hero, Team) :-
    memiliki_role(Hero, Role),
    \+ (member(TeamMate, Team), memiliki_role(TeamMate, Role)).

% Hitung skor fleksibilitas hero (berdasarkan jumlah role dan lane)
flexibility_score(Hero, FlexScore) :-
    hero(Hero),
    findall(Role, memiliki_role(Hero, Role), Roles),
    findall(Lane, memiliki_lane(Hero, Lane), Lanes),
    length(Roles, RoleCount),
    length(Lanes, LaneCount),
    FlexScore is RoleCount + LaneCount.

% Cek apakah hero adalah counter untuk musuh
is_counter_pick(Hero, EnemyHeroes) :-
    member(Enemy, EnemyHeroes),
    iscounter(Hero, Enemy).

% Cek kompatibilitas dengan tim
good_synergy_with_team(Hero, Team) :-
    Team \= [],
    member(TeamMate, Team),
    compatible(Hero, TeamMate).

% Cek keseimbangan damage type
has_damage_balance(Team) :-
    length(Team, Len),
    Len =< 1,
    !.
has_damage_balance(Team) :-
    member(H1, Team), 
    memiliki_damage_type(H1, physical),
    member(H2, Team), 
    memiliki_damage_type(H2, magic).

% Cek hero jungle dalam tim
get_jungle_hero(Team, JungleHero) :-
    member(JungleHero, Team),
    memiliki_lane(JungleHero, jungle).

% Cek hero roam dalam tim  
get_roam_hero(Team, RoamHero) :-
    member(RoamHero, Team),
    memiliki_lane(RoamHero, roam).

% Rules: Kalau jungle assassin, roam tank
jungle_roam_rule_assassin_tank(Team) :-
    get_jungle_hero(Team, JungleHero),
    memiliki_role(JungleHero, assassin),
    get_roam_hero(Team, RoamHero),
    memiliki_role(RoamHero, tank).

% Rules: Kalau jungle tank/fighter, roam support
jungle_roam_rule_tank_support(Team) :-
    get_jungle_hero(Team, JungleHero),
    (memiliki_role(JungleHero, tank) ; memiliki_role(JungleHero, fighter)),
    get_roam_hero(Team, RoamHero),
    memiliki_role(RoamHero, support).

% Cek apakah jungle-roam combination valid
valid_jungle_roam_combination(Team) :-
    % Jika belum ada jungle atau roam, masih valid
    (\+ get_jungle_hero(Team, _) ; \+ get_roam_hero(Team, _)),
    !.
valid_jungle_roam_combination(Team) :-
    % Jika ada jungle assassin, roam tank
    get_jungle_hero(Team, JungleHero),
    memiliki_role(JungleHero, assassin),
    get_roam_hero(Team, RoamHero),
    memiliki_role(RoamHero, tank),
    !.
valid_jungle_roam_combination(Team) :-
    % Jika ada jungle tank/fighter, roam support
    get_jungle_hero(Team, JungleHero),
    (memiliki_role(JungleHero, tank) ; memiliki_role(JungleHero, fighter)),
    get_roam_hero(Team, RoamHero),
    memiliki_role(RoamHero, support),
    !.

% Cek recommended roam role berdasarkan jungle
recommended_roam_role_for_jungle(JungleHero, RecommendedRoamRole) :-
    (memiliki_role(JungleHero, assassin) ->
        RecommendedRoamRole = tank
    ;
        (memiliki_role(JungleHero, tank) ; memiliki_role(JungleHero, fighter)) ->
        RecommendedRoamRole = support
    ;
        RecommendedRoamRole = tank  % default
    ).

% ===== ATURAN DRAFT PICK UTAMA =====

% Rule untuk First Pick - prioritas hero fleksibel
recommend_first_pick(Hero, BannedHeroes, EnemyHeroes, TeamHeroes, UserLane) :-
    hero_tersedia(Hero, BannedHeroes, EnemyHeroes, TeamHeroes),
    memiliki_lane(Hero, UserLane),
    flexibility_score(Hero, FlexScore),
    FlexScore >= 3,  % Hero dengan minimal 3 poin fleksibilitas
    % Pastikan hero memiliki sedikit counter yang diketahui
    \+ (findall(Counter, iscounter(Counter, Hero), Counters), 
        length(Counters, CounterCount), 
        CounterCount > 2).

% Rule utama untuk rekomendasi hero
recommend_hero(Hero, BannedHeroes, EnemyHeroes, TeamHeroes, UserLane, Priority) :-
    hero_tersedia(Hero, BannedHeroes, EnemyHeroes, TeamHeroes),
    memiliki_lane(Hero, UserLane),
    calculate_priority(Hero, EnemyHeroes, TeamHeroes, UserLane, Priority).

% Kalkulasi prioritas hero berdasarkan berbagai faktor
calculate_priority(Hero, EnemyHeroes, TeamHeroes, UserLane, Priority) :-
    % Base priority
    BasePriority = 10,
    
    % Bonus untuk counter pick
    (is_counter_pick(Hero, EnemyHeroes) -> CounterBonus = 20; CounterBonus = 0),
    
    % Bonus untuk lane yang dibutuhkan tim (prioritas utama)
    (check_needed_lane_bonus(Hero, TeamHeroes, UserLane, LaneBonus) -> true; LaneBonus = 0),
    
    % Bonus untuk role diversity
    (check_role_diversity_bonus(Hero, TeamHeroes, RoleDiversityBonus) -> true; RoleDiversityBonus = 0),
    
    % Bonus untuk jungle-roam combination rules
    (check_jungle_roam_bonus(Hero, TeamHeroes, UserLane, JungleRoamBonus) -> true; JungleRoamBonus = 0),
    
    % Bonus untuk synergy dengan tim
    (good_synergy_with_team(Hero, TeamHeroes) -> SynergyBonus = 10; SynergyBonus = 0),
    
    % Bonus untuk keseimbangan damage
    (check_damage_balance_bonus(Hero, TeamHeroes, DamageBonus) -> true; DamageBonus = 0),
    
    % Bonus fleksibilitas
    flexibility_score(Hero, FlexScore),
    FlexibilityBonus is FlexScore * 2,
    
    % Total priority
    Priority is BasePriority + CounterBonus + LaneBonus + RoleDiversityBonus + JungleRoamBonus + SynergyBonus + DamageBonus + FlexibilityBonus.

% Helper untuk bonus role diversity
check_role_diversity_bonus(Hero, TeamHeroes, Bonus) :-
    count_unique_roles(TeamHeroes, CurrentDiversity),
    (adds_role_diversity(Hero, TeamHeroes) ->
        % Bonus berdasarkan seberapa diverse tim saat ini
        % Semakin sedikit diversity, semakin besar bonus untuk menambah role baru
        Bonus is 20 - (CurrentDiversity * 3)
    ;
        Bonus = 0
    ),
    Bonus >= 0.  % Minimal 0, tidak negatif

% Helper untuk bonus lane yang dibutuhkan (prioritas utama)
check_needed_lane_bonus(Hero, TeamHeroes, UserLane, 25) :-
    memiliki_lane(Hero, UserLane),
    lane_dibutuhkan(UserLane, TeamHeroes),
    !.
check_needed_lane_bonus(Hero, TeamHeroes, _, 20) :-
    memiliki_lane(Hero, Lane),
    lane_dibutuhkan(Lane, TeamHeroes),
    !.
check_needed_lane_bonus(_, _, _, 0).

% Helper untuk bonus jungle-roam combination
check_jungle_roam_bonus(Hero, TeamHeroes, UserLane, 15) :-
    UserLane = roam,
    get_jungle_hero(TeamHeroes, JungleHero),
    recommended_roam_role_for_jungle(JungleHero, RecommendedRole),
    memiliki_role(Hero, RecommendedRole),
    !.
check_jungle_roam_bonus(Hero, TeamHeroes, UserLane, 15) :-
    UserLane = jungle,
    get_roam_hero(TeamHeroes, RoamHero),
    % Cek apakah hero jungle cocok dengan roam yang sudah ada
    ((memiliki_role(RoamHero, tank), memiliki_role(Hero, assassin)) ;
     (memiliki_role(RoamHero, support), (memiliki_role(Hero, tank) ; memiliki_role(Hero, fighter)))),
    !.
check_jungle_roam_bonus(_, _, _, 0).

% Helper untuk bonus keseimbangan damage
check_damage_balance_bonus(Hero, TeamHeroes, 8) :-
    % Jika tim kekurangan magic damage dan hero adalah mage
    \+ (member(TeamMate, TeamHeroes), memiliki_damage_type(TeamMate, magic)),
    memiliki_damage_type(Hero, magic),
    !.
check_damage_balance_bonus(Hero, TeamHeroes, 8) :-
    % Jika tim kekurangan physical damage dan hero adalah physical
    \+ (member(TeamMate, TeamHeroes), memiliki_damage_type(TeamMate, physical)),
    memiliki_damage_type(Hero, physical),
    !.
check_damage_balance_bonus(_, _, 0).

% ===== MAIN SYSTEM PREDICATES =====

% Sistem utama untuk first pick
get_first_pick_recommendations(BannedHeroes, UserLane, Recommendations) :-
    EnemyHeroes = [],
    TeamHeroes = [],
    findall(
        hero_priority(Hero, Score),
        (recommend_first_pick(Hero, BannedHeroes, EnemyHeroes, TeamHeroes, UserLane),
         flexibility_score(Hero, Score)),
        UnsortedRecs
    ),
    sort(2, @>=, UnsortedRecs, SortedRecs),  % Sort by score descending
    take_top_n(SortedRecs, 5, Recommendations).

% Sistem utama untuk rekomendasi hero
get_hero_recommendations(BannedHeroes, EnemyHeroes, TeamHeroes, UserLane, Recommendations) :-
    findall(
        hero_priority(Hero, Priority),
        recommend_hero(Hero, BannedHeroes, EnemyHeroes, TeamHeroes, UserLane, Priority),
        UnsortedRecs
    ),
    sort(2, @>=, UnsortedRecs, SortedRecs),  % Sort by priority descending
    take_top_n(SortedRecs, 5, Recommendations).

% Helper untuk mengambil top N recommendations
take_top_n(List, N, TopN) :-
    length(List, Len),
    (Len > N -> 
        length(TopN, N), 
        append(TopN, _, List)
    ; 
        TopN = List
    ).

% ===== ANALYSIS PREDICATES =====

% Analisis komposisi tim saat ini
analyze_team_composition(Team, Analysis) :-
    findall(Role-Count, (role(Role), count_role_in_team(Role, Team, Count)), RoleCounts),
    findall(Lane-Count, (lane(Lane), count_lane_in_team(Lane, Team, Count)), LaneCounts),
    count_unique_roles(Team, RoleDiversity),
    findall(Lane, (lane(Lane), lane_dibutuhkan(Lane, Team)), MissingLanes),
    (has_damage_balance(Team) -> DamageBalance = balanced; DamageBalance = unbalanced),
    (valid_jungle_roam_combination(Team) -> JungleRoamValid = valid; JungleRoamValid = invalid),
    Analysis = team_analysis(RoleCounts, LaneCounts, RoleDiversity, MissingLanes, DamageBalance, JungleRoamValid).

% Analisis threat dari tim musuh
analyze_enemy_threats(EnemyHeroes, Threats) :-
    findall(
        threat(Enemy, Counters),
        (member(Enemy, EnemyHeroes),
         findall(Counter, iscounter(Counter, Enemy), Counters)),
        Threats
    ).

% ===== INTERFACE PREDICATES =====

% Interface utama sistem
draft_recommendation(BannedHeroes, EnemyHeroes, TeamHeroes, UserLane, Result) :-
    % Cek apakah ini first pick
    (EnemyHeroes = [], TeamHeroes = [] ->
        get_first_pick_recommendations(BannedHeroes, UserLane, Recommendations),
        Result = first_pick_recommendations(Recommendations)
    ;
        get_hero_recommendations(BannedHeroes, EnemyHeroes, TeamHeroes, UserLane, Recommendations),
        analyze_team_composition(TeamHeroes, TeamAnalysis),
        analyze_enemy_threats(EnemyHeroes, EnemyThreats),
        Result = draft_analysis(Recommendations, TeamAnalysis, EnemyThreats)
    ).

% ===== CONTOH QUERY =====
/*
Contoh penggunaan:

Format:
draft_recommendation(BannedList, EnemyList, TeamList, UserLane, Result).

1. First Pick:
?- draft_recommendation([], [], [], gold, Result).

2. Counter Pick:
?- draft_recommendation([], [fanny, gusion], [angela], mid, Result).

3. Melengkapi tim:
?- draft_recommendation([johnson, akai], [hayabusa, eudora, layla], [tigreal, harith], jungle, Result).
*/