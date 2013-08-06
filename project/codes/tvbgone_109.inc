; -----------------------------------------------------------------------------
; Code 109 - A.R.Systems, Aiko, Aim, Akai, Akiba, Akura, Alba, Allstar,
; Amstrad, Anitech, Ansonic, Aristona, Asberg, Atlantic, Audiosonic,
; Basic Line, Baur, Beko, Beon, Bestar, Blue Sky, BPL, Brinkmann, Brionvega,
; Bush, Carena, Cascade, Cathay, Centurion, Clatronic, Condor, Crown, Daewoo,
; Dansai, Dawa, Decca, Desmet, Diamant, Dixi, Dual, Dynatron, Elbe, Elin,
; Elite, Emerson, Erres, Euromann, Europhon, Exquisit, Fidelity, Finlux,
; Firstline, Flint, Fraba, Galaxi, Galaxis, GEC, Genexxa, Goldline, GoldStar,
; Goodmans, Granada, Grundig, Hanseatic, Hantarex, Hantor, Harwood, HCM,
; HiLine, Hinari, Hitachi, Hornyphone, Hypson, Iberia, ICE, Imperial, Indiana,
; Inno Hit, Interfunk, Intervision, Irradio, Isukai, ITS, ITV, Kaisui, Karcher,
; Kendo, Kneissel, Kolster, Korpel, Kosmos, Leyco, LG, Liesenkotter, Lifetec,
; Loewe, Luma, Lumatron, M Elecectronic, Manesth, Marantz, Mark, Matsui,
; Mediator, Medion, Mercury, Minoka, Mitsubishi, Multitech, Neckermann, NEI,
; Neufunk, New Tech, Nikkai, Novatronic, Okano, Opera, Orbit, Orion, Orline,
; Orsowe, Osaki, Otto Versand, Palladium, Panama, Panasonic, Panavision,
; Perdio, Perfekt, Philco, Philips, Phoenix, Phonola, Pioneer, Plantron,
; Profi-Tronic, Proline, Prosonic, Provision, Pye, Quelle, Radialva, Raiola,
; Radiomarelli, RadioShack, Radiotone, Recor, Redstar, Reflex, Revox, R-Line,
; Samsung, Sansui, SBR, Schneider, SEG, SEI, Siarem, Sierra, Sinudyne, Sonoko,
; Sontec, Soundwave, Standard, Star Lite, Strato, Sunstar, Sunwood, SuperTech,
; Tatung, Teac, Teleccor, Telefunken, Telegazi, Telemeister, Telesonic,
; Telestar, Teletech, Tensai, Thomson, Thorn, Tokai, Trans Continens, Triumph,
; Uher, Ultravox, Unic Line, Universum, Univox, Vestel, Vexa,
; VideoSystemVision, Vortec, Voxson, Waltham, Watson, Wega, Weltclick,
; White Westinghouse, Xrypton, Yamishi, Yokan, Yoko

; Carrier Freq = 34.80 KHz
.db (((XTAL / 34800.0) / 2.0) - 1.0), 92

.db 1, 1 // 92       92
.db 2, 1 // 184       92
.db 1, 1 // 92       92
.db 1, 1 // 92       92
.db 1, 1 // 92       92
.db 1, 1 // 92       92
.db 1, 1 // 92       92
.db 1, 1 // 92       92
.db 1, 2 // 92      184
.db 1, 1 // 92       92
.db 2, 1 // 184       92
.db 1, 100 // 92     9217
.db 1, 1 // 91       92
.db 2, 1 // 184       92
.db 1, 1 // 92       92
.db 1, 1 // 92       92
.db 1, 1 // 92       92
.db 1, 1 // 92       92
.db 1, 1 // 92       92
.db 1, 1 // 92       92
.db 1, 2 // 92      184
.db 1, 1 // 92       92
.db 2, 1 // 184       92
.db 1, 0 // 92       0
