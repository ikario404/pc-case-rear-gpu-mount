// =============================================================================
// ProArt PA602 - Support GPU Externe sur vis PSU
// Fichier : config.scad
// Description : Paramètres généraux du modèle OpenSCAD
// =============================================================================

/* [Qualité de rendu] */
$fn = $preview ? 32 : 64;

/* [Dégagement et Positionnement] */
// Déport libre entre la face arrière du boîtier et le plateau du riser (mm)
// Laisse la place à la fiche secteur C13/C14 (45mm), aux câbles et au flux d'air
standoff_depth = 60; // [45:5:110]

// Hauteur du plateau riser par rapport au centre de l'alimentation ATX (mm)
// (Le haut du PSU est à +43mm ; 60mm place le riser juste au-dessus de l'alim, face aux slots PCIe)
riser_elevation_from_psu_center = 60; // [30:5:140]

// Épaisseur des bras structurels (mm)
arm_thickness = 10.0;
flange_width  = 26.0;

/* [Interface Alimentation (Norme ATX)] */
// Dimensions de la face arrière de l'alimentation ATX standard (mm)
atx_psu_width  = 150.0;
atx_psu_height = 86.0;

// Largeur et hauteur hors-tout de la platine PSU (mm)
psu_plate_width     = 172.0; // S'étend à X = ±86mm pour dégager les vis du riser
psu_plate_height    = 98.0;  // S'étend à Z = ±49mm
psu_plate_thickness = 5.0;

// Diamètre des trous de vis PSU (vis standard 6-32 UNC = ~3.5mm, 4.0mm pour tolérance)
psu_screw_hole_d = 4.0;
psu_screw_head_d = 7.8;

// Découpe centrale agrandie pour dégager l'espace face alimentation (prise secteur C13/C14, interrupteur I/O et ventilation)
psu_receptacle_width  = 118.0;
psu_receptacle_height = 62.0;

/* [Interface Riser PCIe] */
// Entraxe des trous de vis de fixation du riser PCB (mm)
// Typiquement 108mm (Linkup, ADT-Link, Lian-Li), 125mm ou 100mm selon modèle
riser_hole_spacing_x = 108.0;

// Entraxe en Y si le riser possède 4 trous (mettre 0 si seulement 2 trous centrés)
riser_hole_spacing_y = 0.0;

// Position en Y de l'axe du connecteur PCIe sur le plateau (mm depuis le bord arrière du plateau)
riser_Axis_y = 20.0;

// Diamètre des vis de fixation du riser (M3 standard = 3.2mm de perçage)
riser_screw_d = 3.2;

// Hauteur des entretoises sous le PCB du riser (mm)
riser_standoff_h = 5.0;

// Dimensions du plateau Riser (mm)
riser_tray_width     = psu_plate_width; // 172.0 mm
riser_tray_depth     = 75.0;            // Profondeur accueillant un GPU 3 à 3.5 slots
riser_tray_thickness = 5.0;

// Fente de passage pour nappe souple sous le riser (compatible risers 90° et 180°)
riser_cable_slot_w = 92.0;
riser_cable_slot_d = 14.0;

/* [Tour de verrouillage Équerre PCIe (PCIe Bracket Tower)] */
// Nombre de slots du GPU (2, 2.5, 3 ou 3.5 slots)
gpu_slots = 3;

// Hauteur standard de l'équerre métallique PCIe au-dessus du PCB du riser (mm)
pcie_bracket_screw_h = 112.0;

// Pas standard entre slots PCIe (20.32 mm / 0.8 pouce)
pcie_slot_pitch = 20.32;

// Largeur utile de retenue de l'équerre (selon le nombre de slots)
pcie_bracket_width = gpu_slots * pcie_slot_pitch + 4.0;

/* [Jambe d'appui au sol / bureau (Optionnelle)] */
// Décharge 100% du poids vertical (1.5 à 2.5 kg) sur le bureau/sol
enable_support_foot = true;

// Hauteur entre le bas de la platine PSU (Z = -49mm) et le sol/bureau (mm)
support_foot_height = 35.0; // [15:5:120]
