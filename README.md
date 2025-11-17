# Mobile Legends Draft Pick Knowledge-Based System

Sistem rekomendasi draft pick untuk Mobile Legends: Bang Bang menggunakan Prolog sebagai knowledge-based system.

![Mobile Legends](assets/mlbb.jpg)

![Draft Pick](assets/draft_pick.png)

## Table of Contents
- [Struktur Project](#struktur-project)
- [Fitur Sistem](#fitur-sistem)
- [Cara Menggunakan Sistem](#cara-menggunakan-sistem)
- [Algoritma Scoring](#algoritma-scoring)
- [Knowledge Base](#knowledge-base)
- [References](#references)
- [Authors](#authors)

## Quick Links
- **[CLI Quick Start Guide](CLI_GUIDE.md)** - Panduan lengkap penggunaan Command Line Interface
- **[Interactive Demo](main.pl)** - Demo sistem dengan contoh preset

## Struktur Project

```
mobile-legends-draftpick-kbs/
├── facts/                    # Knowledge base (fakta-fakta)
│   ├── hero.pl              # Daftar semua hero
│   ├── role.pl              # Role hero (tank, fighter, assassin, dll)
│   ├── lane.pl              # Lane hero (gold, jungle, roam, mid, exp)
│   ├── damage_type.pl       # Tipe damage (physical, magic, true)
│   ├── specialty.pl         # Specialty hero (cc, burst, poke, dll)
│   ├── compatible.pl        # Kompatibilitas antar hero
│   └── counter.pl           # Counter relationship antar hero
├── draft_system.pl          # Sistem utama draft pick
├── cli.pl                   # Command Line Interface
├── main.pl                  # Interface demo dan testing
├── test_system.pl           # File test untuk mencoba sistem
└── README.md               # Dokumentasi ini
```

## Fitur Sistem

### 1. Input yang Diterima
- **Banned Heroes**: List hero yang sudah dibanned
- **Enemy Heroes**: List hero yang sudah dipick musuh (0-5 hero)
- **Team Heroes**: List hero yang sudah dipick tim (0-4 hero)
- **User Lane**: Lane yang diinginkan user (gold/jungle/roam/mid/exp)

### 2. Output yang Diberikan
- **List Rekomendasi Hero**: Hero-hero terbaik untuk situasi saat ini
- **Priority Score**: Skor prioritas untuk setiap hero
- **Team Analysis**: Analisis komposisi tim saat ini
- **Enemy Threats**: Analisis ancaman dari tim musuh

### 3. Aturan Draft Pick yang Diimplementasi

#### First Pick Strategy
- Prioritas hero dengan fleksibilitas tinggi (bisa main di banyak lane/role)
- Hero dengan sedikit counter yang diketahui
- Hero meta yang kuat

#### Counter Pick Strategy
- Identifikasi hero yang meng-counter musuh
- Bonus prioritas tinggi untuk counter pick yang efektif
- Analisis threat dari komposisi musuh

#### Team Composition Balance
- **Lane Coverage**: Memastikan semua 5 lane terisi (gold, jungle, roam, mid, exp) - PRIORITAS UTAMA
- **Role Diversity**: Semakin banyak role berbeda, semakin seimbang tim (ideal: 5 role berbeda)
- **Damage Balance**: Kombinasi physical dan magic damage
- **Jungle-Roam Synergy**: Kombinasi jungle-roam yang optimal

#### Synergy Optimization
- Hero yang kompatibel dengan tim yang sudah ada
- Specialty yang saling melengkapi (CC + Burst, Initiator + Damage, dll)

#### Jungle-Roam Combination Rules
- **Jungle Assassin → Roam Tank**: Assassin butuh frontliner untuk initiate
- **Jungle Tank/Fighter → Roam Support**: Tank/Fighter jungle butuh sustain dan utility
- Bonus prioritas +15 untuk kombinasi yang cocok

#### Anti-Duplicate Lane Validation
- **Lane Uniqueness**: Sistem mencegah duplikasi lane dalam satu tim
- **Automatic Filtering**: Hero yang akan menyebabkan duplikasi lane otomatis difilter
- **Real-time Validation**: Analisis tim mendeteksi lane yang duplikat
- **Penalty System**: -50 poin penalti untuk hero yang menyebabkan duplikasi (safety measure)

## Cara Menggunakan Sistem

### 1. Command Line Interface (CLI)
```bash
# Jalankan CLI interaktif
swipl -s cli.pl -g "start_cli."

# Atau manual start setelah load
swipl -s cli.pl
?- start_cli.
```

**Fitur CLI:**
- **Draft Pick Recommendation**: Input banned heroes, enemy picks, team picks, dan lane untuk mendapat rekomendasi
- **Team Analysis**: Analisis komposisi tim secara detail
- **Hero Info**: Informasi lengkap tentang hero (roles, lanes, counters, synergies)
- **User-friendly Interface**: Menu interaktif dengan validasi input

**Cara Menggunakan CLI:**
1. Pilih mode (1-4)
2. Ikuti instruksi input:
   - Format hero list: `[hero1, hero2, hero3]` atau `[]` untuk kosong
   - Format lane: `gold`, `mid`, `exp`, `jungle`, atau `roam`
3. Sistem akan memberikan rekomendasi dan analisis

### 2. Menjalankan Test
```prolog
% Load file test
?- [test_system].

% Atau jalankan test individual
?- test_first_pick.
?- test_counter_pick.
```

### 2. Query Manual
```prolog
% Load sistem
?- [draft_system].

% First pick untuk gold lane
?- draft_recommendation([], [], [], gold, Result).

% Counter pick scenario
?- draft_recommendation([johnson, akai], [fanny, eudora], [angela], jungle, Result).

% Late pick scenario  
?- draft_recommendation([johnson, akai, estes], [hayabusa, eudora, layla], [tigreal, harith], exp, Result).
```

### 3. Contoh Penggunaan CLI

#### CLI Session Example
```
===============================================================
           MOBILE LEGENDS DRAFT PICK SYSTEM               
                    Command Line Interface                 
===============================================================

Pilih mode:
1. Draft Pick Recommendation
2. Team Analysis  
3. Hero Info
4. Exit
Pilihan (1-4): 1

===============================================================
                DRAFT PICK RECOMMENDATION
===============================================================

STEP 1: Masukkan hero yang di-ban
Format: [hero1, hero2, hero3] atau [] jika kosong
Contoh: [fanny, johnson, akai]
Banned heroes: [fanny, johnson].

STEP 2: Masukkan hero yang sudah dipick musuh (0-5 hero)
Format: [hero1, hero2] atau [] jika kosong
Enemy heroes: [layla, eudora].

STEP 3: Masukkan hero yang sudah dipick tim (0-4 hero)
Format: [hero1, hero2] atau [] jika kosong
Team heroes: [].

STEP 4: Pilih lane yang ingin dimainkan
Pilihan: gold, mid, exp, jungle, roam
Lane: jungle.

===============================================================
                    HASIL REKOMENDASI
===============================================================

RINGKASAN INPUT:
   Banned Heroes: [fanny,johnson]
   Enemy Heroes:  [layla,eudora]
   Team Heroes:   []
   Your Lane:     jungle

HERO RECOMMENDATIONS:
   Rank | Hero          | Priority | Roles
   -----|---------------|----------|----------------
   1.   | saber         | 45       | [assassin]
   2.   | karina        | 38       | [assassin,mage]
   3.   | hayabusa      | 35       | [assassin]
   4.   | ling          | 33       | [assassin]
   5.   | lancelot      | 30       | [assassin]
```

### 4. Contoh Query Manual dan Expected Output

#### First Pick Example
```prolog
?- draft_recommendation([], [], [], gold, Result).
Result = first_pick_recommendations([
    hero_priority(granger, 8),
    hero_priority(claude, 7),
    hero_priority(karrie, 6),
    hero_priority(bruno, 6),
    hero_priority(clint, 5)
]).
```

#### Jungle-Roam Rule Example
```prolog
?- draft_recommendation([], [], [hayabusa, harith, granger], roam, Result).
% hayabusa = jungle assassin, butuh tank roamer
Result = draft_analysis([
    hero_priority(tigreal, 60),    % Tank roam + lane bonus + jungle-roam bonus
    hero_priority(atlas, 58),      % Tank roam + bonus
    hero_priority(franco, 55),     % Tank roam + bonus
    ...
], team_analysis(...), enemy_threats(...))
```

#### Role Diversity Example
```prolog
?- draft_recommendation([], [], [tigreal, harith], exp, Result).
% Current team: tank + mage (2 roles)
% Hero yang menambah role baru dapat bonus 20-3×2 = 14 poin
Result = draft_analysis([
    hero_priority(chou, 54),      % Fighter (role baru) + exp lane + diversity bonus
    hero_priority(alpha, 52),     % Fighter (role baru) + exp lane + diversity bonus  
    hero_priority(fredrinn, 49),  % Fighter/Tank (tank sudah ada) + exp lane
    ...
])
```

#### Counter Pick Example
```prolog
?- draft_recommendation([], [layla, eudora], [], jungle, Result).
Result = draft_analysis(
    [hero_priority(saber, 45), hero_priority(karina, 38), ...],
    team_analysis([tank-0, fighter-0, ...], [tank, fighter, marksman], unbalanced),
    [threat(layla, [saber, karina, ...]), threat(eudora, [saber, karina, ...])]
).
```

#### Anti-Duplicate Lane Example
```prolog
% Tim sudah ada Layla (gold lane), coba pick gold lagi
?- draft_recommendation([], [], [layla], gold, Result).
Result = draft_analysis(
    [],  % Empty recommendations - tidak ada hero yang bisa dipick
    team_analysis([...], [...], 1, [jungle,roam,mid,exp], balanced, valid, [], valid),
    []
).

% Tim ada Layla (gold), pick lane berbeda -> OK
?- draft_recommendation([], [], [layla], roam, Result).
Result = draft_analysis(
    [hero_priority(tigreal, 52), hero_priority(franco, 50), ...],  % Ada rekomendasi
    ...,
    ...
).
```

## Algoritma Scoring

### Priority Calculation
```
Total Priority = Base(10) + Counter(20) + Lane(25) + RoleDiversity(20-3×current) + JungleRoam(15) + Synergy(10) + Damage(8) + Flexibility(2×score)
```

### Komponen Scoring
1. **Base Priority**: 10 poin untuk semua hero eligible
2. **Counter Bonus**: 20 poin jika hero counter musuh
3. **Lane Bonus**: 25 poin jika hero mengisi lane yang dibutuhkan (PRIORITAS UTAMA)
4. **Role Diversity**: 20-17-14-11-8 poin untuk menambah role baru (semakin diverse semakin bagus)
5. **Jungle-Roam Bonus**: 15 poin jika hero cocok dengan jungle-roam combination rules
6. **Synergy Bonus**: 10 poin jika hero kompatibel dengan tim
7. **Damage Balance**: 8 poin jika hero membantu balance damage tim
8. **Flexibility**: 2x jumlah role+lane yang bisa dimainkan hero

### Flexibility Score
```
Flexibility = Jumlah Role + Jumlah Lane
Contoh: Chou (fighter, tank) + (exp, roam, jungle) = 2 + 3 = 5
```

## Knowledge Base

### Hero Facts (120+ heroes)
- Semua hero yang ada di Mobile Legends
- Terus diupdate sesuai release hero baru

### Role System
- **Tank**: Frontliner, initiator, crowd control
- **Fighter**: Versatile, sustain damage, semi-tanky  
- **Assassin**: High burst, mobile, single target
- **Mage**: Magic damage, AoE, burst/poke
- **Marksman**: Consistent DPS, ranged physical
- **Support**: Utility, heal/shield, team enabler

### Lane System
- **Gold Lane**: Farming priority, carry potential
- **Jungle**: Mobility, ganking, objective control
- **Roam**: Map presence, team support, vision
- **Mid Lane**: Wave clear, rotation, burst
- **Exp Lane**: Solo lane, sustain, initiation

### Counter System
- Database 300+ counter relationships
- Berdasarkan meta analysis dan pro play
- Regularly updated

## References

- Mobile Legends Official Documentation
- Professional Scene Analysis (MPL, M-Series)
- Meta Analysis dari berbagai sumber
- Community feedback dan testing

## Authors

- Novelya Putri Ramadhani
- Thea Josephine Halim
- Raffael Boymian Siahaan
- Devinzen Gaming

---
*Sistem ini dikembangkan untuk membantu pemain Mobile Legends dalam membuat keputusan draft pick yang lebih baik dan strategis.*