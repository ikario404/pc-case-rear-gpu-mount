// =============================================================================
// ProArt PA602 - Support GPU Externe sur vis PSU
// Fichier : psu_bracket.scad
// Description : Platine de fixation sur la face arrière de l'alimentation ATX
//               - Empreintes ATX inversées gauche-droite (conformes au boîtier PA602)
//               - Espace face alimentation agrandi (118 x 62 mm)
//               - Évidements rectangulaires sur les deux faces latérales (flancs)
// =============================================================================

include <config.scad>;

// Coordonnées des trous de vis ATX par rapport au centre de la face PSU (150x86mm)
// Inversion gauche-droite appliquée (X -> -X) conformément au montage réel PA602 :
// - Haut-Gauche : [-69, 37]
// - Haut-Droite : [69, 37]
// - Bas-Gauche  : [-45, -37] (Inversé, cas réel utilisateur)
// - Bas-Droite  : [69, -27]  (Inversé, cas réel utilisateur)
atx_holes_standard = [
    [-69,  37], // Haut - Gauche
    [ 69,  37], // Haut - Droite
    [-45, -37], // Bas - Gauche (Inversé - PA602)
    [ 69, -27], // Bas - Droite (Inversé - PA602)
    // Trous symétriques assurant une compatibilité universelle
    [ 45, -37],
    [-69, -27],
    [-69, -37],
    [ 69, -37],
    [-45,  37],
    [ 45,  37]
];

// Positions Y des 2 vis M4 par bras (dans le repère global)
m4_bolt_y1 = standoff_depth + 22;
m4_bolt_y2 = standoff_depth + 52;
m4_bolt_x  = psu_plate_width/2 - flange_width/2; // ±73.0 mm

module atx_mounting_holes(d = psu_screw_hole_d, h = 30) {
    for (pos = atx_holes_standard) {
        translate([pos[0], 0, pos[1]])
            rotate([-90, 0, 0])
                cylinder(d = d, h = h, center = true);
    }
}

module side_c_beam(side = 1) {
    // side = -1 (Gauche) ou +1 (Droite)
    x_start = (side > 0) ? (psu_plate_width/2 - flange_width) : -psu_plate_width/2;
    web_w   = 9.0; // Épaisseur de l'âme verticale
    x_web   = (side > 0) ? (psu_plate_width/2 - web_w) : -psu_plate_width/2;

    z_bot   = -psu_plate_height/2;                // -49 mm
    z_plate_top = psu_plate_height/2;             // +49 mm
    z_top   = riser_elevation_from_psu_center;    // +60 mm

    y_top_end = standoff_depth + 65;              // 125 mm
    y_bot_end = standoff_depth + 26;              // 86 mm (reçoit le support_foot)

    // Décalage Y pour monter de z_plate_top (+49) à z_top (+60) à 45° sans porte-à-faux
    y_chamfer = max(0, z_top - z_plate_top);

    difference() {
        union() {
            // 1. Semelle supérieure (reçoit le riser_tray à Z = z_top)
            hull() {
                translate([x_start, 0, z_plate_top - arm_thickness])
                    cube([flange_width, 1, arm_thickness]);
                translate([x_start, y_chamfer + 1, z_top - arm_thickness])
                    cube([flange_width, 1, arm_thickness]);
                translate([x_start, y_top_end - 1, z_top - arm_thickness])
                    cube([flange_width, 1, arm_thickness]);
            }

            // 2. Semelle inférieure (Z = -49 à -39, reçoit le support_foot)
            translate([x_start, 0, z_bot])
                cube([flange_width, y_bot_end, arm_thickness]);

            // 3. Âme extérieure de liaison (relie semelle basse et semelle haute -> poutre en C)
            hull() {
                translate([x_web, 0, z_bot])
                    cube([web_w, y_bot_end, z_plate_top - z_bot]);
                translate([x_web, y_chamfer + 1, z_bot])
                    cube([web_w, y_bot_end - y_chamfer - 1, z_top - z_bot]);
                translate([x_web, y_top_end - 1, z_top - arm_thickness])
                    cube([web_w, 1, arm_thickness]);
            }
        }

        // --- DÉCOUPE TRAPÉZOÏDALE SUR LA FACE LATÉRALE (Demande utilisateur) ---
        // Évidement en forme de trapèze : bord haut allongé, bord bas préservé
        hull() {
            // Bord inférieur (court)
            translate([x_web - 1, side_cutout_y, -side_cutout_h/2])
                cube([web_w + 2, side_cutout_len_bot, 0.1]);
            // Bord supérieur (allongé)
            translate([x_web - 1, side_cutout_y, side_cutout_h/2 - 0.1])
                cube([web_w + 2, side_cutout_len_top, 0.1]);
        }
    }
}

module psu_bracket() {
    z_bot = -psu_plate_height/2;
    z_top = riser_elevation_from_psu_center;

    difference() {
        union() {
            // A. Platine frontale contre le boîtier / PSU (Y = 0 à psu_plate_thickness)
            translate([-psu_plate_width/2, 0, -psu_plate_height/2])
                cube([psu_plate_width, psu_plate_thickness, psu_plate_height]);

            // B. Poutres latérales gauche et droite avec fenêtres rectangulaires
            side_c_beam(-1);
            side_c_beam(1);

            // C. Bossages de renfort renforcés pour TOUS les trous ATX (normaux et inversés)
            for (pos = atx_holes_standard) {
                translate([pos[0], 0, pos[1]])
                    rotate([-90, 0, 0])
                        cylinder(d = 16, h = psu_plate_thickness);
            }
        }

        // --- DÉCOUPES ---

        // 1. Évidement agrandi pour la face de l'alimentation (118 x 62 mm)
        difference() {
            translate([0, psu_plate_thickness/2, 0])
                cube([psu_receptacle_width, psu_plate_thickness + 4, psu_receptacle_height], center = true);
            // Préserver la matière autour des trous de vis ATX intérieurs (X = ±45, Z = -37)
            for (pos = atx_holes_standard) {
                translate([pos[0], -1, pos[1]])
                    rotate([-90, 0, 0])
                        cylinder(d = 16, h = psu_plate_thickness + 6);
            }
        }

        // 2. Perçages traversants pour les vis ATX 6-32
        translate([0, psu_plate_thickness/2, 0])
            atx_mounting_holes(d = psu_screw_hole_d, h = 40);

        // 3. Trous de fixation M4 + empreintes d'écrous M4 sur la semelle supérieure
        for (side = [-1, 1]) {
            x_pos = side * m4_bolt_x;
            for (y_pos = [m4_bolt_y1, m4_bolt_y2]) {
                // Trou traversant M4
                translate([x_pos, y_pos, z_top - arm_thickness - 2])
                    cylinder(d = 4.3, h = arm_thickness + 4);
                // Empreinte hexagonale pour écrou M4 sous la semelle supérieure
                translate([x_pos, y_pos, z_top - arm_thickness - 0.5])
                    cylinder(d = 8.0, h = 4.0, $fn = 6);
            }
        }

        // 4. Trous de fixation M4 sur la semelle inférieure pour les pieds d'appui (support_foot)
        for (side = [-1, 1]) {
            x_pos = side * m4_bolt_x;
            translate([x_pos, standoff_depth + 13, z_bot - 1])
                cylinder(d = 4.3, h = arm_thickness + 2);
            // Lamage tête de vis M4 sur le dessus de la semelle inférieure
            translate([x_pos, standoff_depth + 13, z_bot + arm_thickness - 3.5])
                cylinder(d = 8.2, h = 5.0);
        }
    }
}

psu_bracket();
