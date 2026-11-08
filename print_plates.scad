// =============================================================================
// ProArt PA602 - Support GPU Externe sur vis PSU
// Fichier : print_plates.scad
// Description : Pièces orientées à plat (Z >= 0) prêtes pour le slicer FDM
// =============================================================================

include <config.scad>;
use <psu_bracket.scad>;
use <riser_tray.scad>;
use <support_foot.scad>;

// Choisissez quelle pièce générer pour l'export STL :
// 1 = Support PSU (psu_bracket)
// 2 = Plateau Riser (riser_tray)
// 3 = Pied d'appui (support_foot)
part_to_render = 1; // [1:Support PSU, 2:Plateau Riser, 3:Pied d'appui]

module printable_psu_bracket() {
    // Rotation +90° autour de X : Y=0 (face arrière plane) repose sur le plateau Z=0
    // et les bras +Y montent verticalement en +Z (auto-porteurs, zéro support)
    rotate([90, 0, 0])
        psu_bracket();
}

module printable_riser_tray() {
    // Repose déjà à plat sur sa base Z=0
    riser_tray();
}

module printable_support_foot() {
    // Repose à plat sur son patin circulaire à Z=0
    support_foot();
}

if (part_to_render == 1) {
    printable_psu_bracket();
} else if (part_to_render == 2) {
    printable_riser_tray();
} else if (part_to_render == 3) {
    printable_support_foot();
}
