# Support Externe GPU pour ASUS ProArt PA602

Projet OpenSCAD paramétrique permettant de fixer proprement et solidement un 3ᵉ GPU à l'arrière d'un boîtier **ASUS ProArt PA602**, ancré sur la platine de l'alimentation ATX avec déport ventilé et reprise de charge au sol.

---

## 🎯 Architecture & Conception Mécanique

1. **Fixation rigide sur l'alimentation ATX (`psu_bracket.scad`) :**
   - Empreinte universelle 8 trous (4 trous standard Intel ATX + 4 trous symétriques pour alimentations montées ventilateur vers le haut, filetage 6-32 UNC) avec bossages de renfort périphériques.
   - **Évidement central dégagé (104 × 50 mm)** et tunnel central libre de 120 mm de large : laisse un accès total à la prise secteur 230V (C13/C14/C20), à l'interrupteur I/O et au bouton Zero-Fan.
   - **Poutres latérales en C (C-Channel)** auto-porteuses : rigidité maximale en flexion/torsion et **impression FDM à plat sans aucun support** (angles à 45° intégrés).

2. **Orientation du GPU & Thermique (`riser_tray.scad`) :**
   - Le GPU est installé **debout sur son riser PCIe** :
     - **Ventilateurs orientés vers l'extérieur (`+Y`)** : aspirent l'air frais ambiant de la pièce.
     - **Plaque métallique arrière (Backplate) orientée vers le boîtier (`-Y`)**.
     - **Déport libre (`standoff_depth = 60 mm`)** entre la tôle arrière du PC et le plateau du riser : dégage la fiche secteur C13/C14, permet le passage fluide de la nappe du riser vers les slots PCIe ouverts, et évite que l'air chaud extrait du boîtier ne chauffe la backplate.
   - **Portique d'équerre PCIe ajouré** : verrouille les languettes inférieures et la patte supérieure pliée à 90° de l'équerre métallique (jusqu'à 3,5 slots) tout en laissant un accès libre aux connecteurs HDMI / DisplayPort et aux vis d'assemblage M4.
   - **Berceau anti-affaissement (Anti-Sag)** : soutient la tranche inférieure du PCB et du carénage à l'autre extrémité du slot PCIe.

3. **Reprise de charge verticale (`support_foot.scad`) :**
   - Deux pieds d'appui sous les semelles inférieures des poutres C-Channel transmettent 100 % du poids du GPU (1,5 à 2,5 kg) au bureau/sol avec logement d'écrou M4 captif, éliminant tout porte-à-faux sur la tôle du boîtier.

---

## 📁 Structure du Projet

* [`config.scad`](config.scad) : Paramètres globaux (déport, élévation, entraxes riser, nombre de slots, tolérances).
* [`psu_bracket.scad`](psu_bracket.scad) : Platine PSU ATX à poutres latérales en C.
* [`riser_tray.scad`](riser_tray.scad) : Plateau du riser PCIe, portique d'équerre PCIe et berceau anti-sag.
* [`support_foot.scad`](support_foot.scad) : Pied d'appui inférieur avec logement pour écrou M4 captif.
* [`assembly.scad`](assembly.scad) : Assemblage complet 3D avec alimentation, câbles et GPU fantômes en situation.
* [`print_plates.scad`](print_plates.scad) : Pièces orientées à plat (`Z >= 0`) prêtes pour le slicer FDM.
* [`render_stls.sh`](render_stls.sh) : Script de génération automatique des fichiers STL et des aperçus PNG.
* [`stl_output/`](stl_output/) : Fichiers STL prêts à trancher (`psu_bracket.stl`, `riser_tray.stl`, `support_foot.stl`).
* [`previews/`](previews/) : Rendus PNG de contrôle géométrique.

---

## ⚙️ Paramètres Clés (`config.scad`)

| Paramètre | Défaut | Description |
| :--- | :---: | :--- |
| `standoff_depth` | `60 mm` | Déport libre entre le dos du boîtier et le plateau du riser |
| `riser_elevation_from_psu_center` | `60 mm` | Hauteur du plateau riser par rapport au centre de l'alim ATX |
| `riser_hole_spacing_x` | `108 mm` | Entraxe X des trous de vis du riser PCB (ex: 108 mm Linkup/ADT, 125 mm) |
| `riser_hole_spacing_y` | `0 mm` | Entraxe Y si le riser possède 4 trous (0 = 2 trous centrés) |
| `gpu_slots` | `3` | Épaisseur du GPU en slots PCIe (2, 2.5, 3, 3.5) |
| `enable_support_foot` | `true` | Active/désactive les pieds de décharge au sol |
| `support_foot_height` | `35 mm` | Hauteur des pieds sous la platine PSU (ajuster selon la garde au sol) |

---

## 🛠️ Quincaillerie Recommandée (BOM)

- **4× Vis 6-32 UNC longues (12 à 16 mm)** : pour visser la platine `psu_bracket` sur l'alimentation ATX.
- **4× Vis M4 × 16 mm + 4× Écrous M4** : pour boulonner le `riser_tray` sur les semelles supérieures du `psu_bracket`.
- **2× Vis M4 × 25 mm + 2× Écrous M4** : pour fixer les deux pieds `support_foot` sous les semelles inférieures.
- **2× Vis M3 × 10 mm** : pour fixer le PCB du riser sur ses entretoises.
- **1× à 3× Vis 6-32 UNC ou M3.5** : pour verrouiller la patte supérieure de l'équerre métallique PCIe du GPU.

---

## 🖨️ Conseils d'Impression 3D

* **Matériau :** **PETG**, **ABS** ou **ASA** recommandé (éviter le PLA standard pour prévenir tout fluage thermique lié à l'air chaud extrait du boîtier).
* **Périmètres (Parois) :** 4 à 5 parois (buse 0.4 mm).
* **Remplissage (Infill) :** 30 % à 40 % (Gyroid ou Cubic).
* **Supports :** **Aucun support requis** sur les 3 pièces (toutes les pentes et goussets sont limités à ≤ 45° dans le sens d'impression généré par `print_plates.scad`).
