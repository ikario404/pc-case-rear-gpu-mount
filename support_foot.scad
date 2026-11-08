// =============================================================================
// ProArt PA602 - Support GPU Externe sur vis PSU
// Fichier : support_foot.scad
// Description : Pied d'appui vertical sous les poutres du support PSU
//               Reprend 100% de la charge verticale vers le bureau/sol
// =============================================================================

include <config.scad>;

module support_foot(h = support_foot_height) {
    if (enable_support_foot && h > 0) {
        col_w    = flange_width; // 26.0 mm
        col_d    = 26.0;
        pad_diam = 42.0;
        pad_h    = 4.0;

        difference() {
            union() {
                // 1. Patin circulaire élargi à la base (centré en X=0, Y=0)
                cylinder(d = pad_diam, h = pad_h);

                // 2. Transition conique à 45° entre le patin et le fût carré
                hull() {
                    cylinder(d = pad_diam, h = pad_h);
                    translate([-col_w/2, -col_d/2, min(h, pad_h + 8.0) - 1])
                        cube([col_w, col_d, 1]);
                }

                // 3. Fût vertical venant en butée sous la semelle inférieure du psu_bracket
                translate([-col_w/2, -col_d/2, 0])
                    cube([col_w, col_d, h]);
            }

            // A. Perçage vertical M4 centré (aligné avec la vis de la semelle inférieure)
            translate([0, 0, -1])
                cylinder(d = 4.3, h = h + 2);

            // B. Logement latéral pour écrou M4 captif (à 10mm sous le sommet du pied)
            if (h >= 18) {
                translate([0, 0, h - 10]) {
                    cylinder(d = 8.1, h = 3.6, center = true, $fn = 6);
                    // Fente d'insertion latérale de l'écrou M4
                    translate([0, col_d/4, 0])
                        cube([7.1, col_d/2 + 2, 3.6], center = true);
                }
            }
        }
    }
}

support_foot();
